#pragma once

#include "laya_numeric_tasks.h"

namespace laya::full {

// Dispatch-only tickets. No RAM state, READY flag, physical claim or retirement
// is changed by this allocator. Rebuild it for a new request after real drain;
// committed epochs are supplied by the persistent authoritative owner table.
class TaskReservation {
  struct RefCursor {
    Buffer id = Buffer::NONE;
    uint8_t bank = 0, region = 0;
    uint32_t high_water = 0;
  } refs_[32];
  uint32_t task_cursor_ = 0;
  static bool physical(const RefCursor& c, Buffer id, uint8_t bank, uint8_t region) {
    if (c.id == Buffer::NONE || c.region != region) return false;
    if (id == Buffer::ROPE_TABLE && c.id == id) return true;
    if (c.bank != bank) return false;
    return c.id == id || (c.id == Buffer::WI && id == Buffer::DEC_FF) ||
      (c.id == Buffer::DEC_FF && id == Buffer::WI);
  }
public:
  uint32_t task_high_water(uint32_t committed) const {
    return task_cursor_ > committed ? task_cursor_ : committed;
  }
  bool can_tasks(uint32_t committed, unsigned count) const {
    return uint64_t(task_high_water(committed)) + count <= kMaxEpoch;
  }
  TaskContext context(uint32_t committed, Op op, uint8_t stage, uint8_t layer,
                      uint8_t batch, RowSpace space, uint16_t row0, uint8_t rows) {
    task_cursor_ = task_high_water(committed);
    uint32_t id = task_cursor_ < kMaxEpoch ? ++task_cursor_ : 0;
    return {id, op, stage, layer, batch, space, row0, rows};
  }
  uint32_t ref_high_water(Buffer id, uint8_t bank, uint8_t region, uint32_t committed) const {
    for (const RefCursor& c : refs_) if (physical(c, id, bank, region))
      return c.high_water > committed ? c.high_water : committed;
    return committed;
  }
  bool can_refs(Buffer id, uint8_t bank, uint8_t region, uint32_t committed, unsigned count) const {
    if (!check_ref({id, bank, 1}, region)) return false;
    bool capacity = false;
    for (const RefCursor& c : refs_) if (c.id == Buffer::NONE || physical(c, id, bank, region)) capacity = true;
    return capacity && uint64_t(ref_high_water(id, bank, region, committed)) + count <= kMaxEpoch;
  }
  BufferRef ref(Buffer id, uint8_t bank, uint8_t region, uint32_t committed) {
    unsigned index = 32, empty = 32;
    for (unsigned i = 0; i < 32; ++i) {
      if (physical(refs_[i], id, bank, region)) { index = i; break; }
      if (empty == 32 && refs_[i].id == Buffer::NONE) empty = i;
    }
    if (index == 32) index = empty;
    if (index == 32 || !can_refs(id, bank, region, committed, 1)) return {id, bank, 0};
    const uint32_t next = ref_high_water(id, bank, region, committed) + 1;
    refs_[index] = {id, bank, region, next};
    return {id, bank, next};
  }
};

// One persistent allocator for the compute service, retained across requests.
class PortalReservation {
  uint64_t high_water_ = 0;
public:
  explicit PortalReservation(uint64_t high_water = 0) : high_water_(high_water) {}
  uint64_t high_water() const { return high_water_; }
  bool can(unsigned count) const { return uint64_t(count) <= UINT64_MAX - high_water_; }
  uint64_t next() { return can(1) ? ++high_water_ : 0; }
};
struct ViewTicket { uint64_t generation = 0; uint8_t row_block = 0, rows = 0; };
constexpr unsigned kMatrixViews = 6;
inline unsigned view_count(unsigned rows) { return rows / 4 + rows % 4; }
inline bool reserve_views(PortalReservation& allocator, uint8_t rows,
                          ViewTicket (&view)[kMatrixViews], uint8_t& count) {
  if (!rows || rows > 16 || !allocator.can(view_count(rows))) return false;
  count = 0;
  for (unsigned row = 0; row < rows;) {
    const uint8_t extent = uint8_t(rows - row >= 4 ? 4 : 1);
    view[count++] = {allocator.next(), uint8_t(row), extent}; row += extent;
  }
  for (unsigned i = count; i < kMatrixViews; ++i) view[i] = ViewTicket{};
  return true;
}
constexpr unsigned kGDownWindows = 128;
enum class WindowState : uint8_t { RESERVED, PRODUCED, QUANT_DONE, LINEAR_DONE, CANCELED };
struct GDownWindow {
  VectorTask producer;
  QuantTask quant;
  LinearTask linear;
  uint64_t producer_generation = 0, quant_generation = 0;
  ViewTicket view[kMatrixViews];
  uint8_t views = 0;
  WindowState state = WindowState::CANCELED;
};
struct DispatchBinding {
  TaskContext producer_context;
  QuantTask quant;
  LinearTask linear;
  uint64_t quant_generation = 0;
  ViewTicket view[kMatrixViews];
  uint8_t views = 0;
  bool valid = false;
};
struct GDownPlan {
  NumericIdentity identity;
  GDownWindow window[kGDownWindows];
  LoadTask load;
  uint64_t load_generation = 0;
  uint16_t count = 0;
  bool valid = false;
  void cancel() {
    valid = false;
    for (unsigned i = 0; i < count; ++i)
      if (window[i].state != WindowState::LINEAR_DONE) window[i].state = WindowState::CANCELED;
  }
};

// All identity/resource overflow checks precede reservation. Descriptor data
// here is the frozen structural model table, never a read of future weights.
// Its actual validation and numerical errors remain at the LOAD issue point.
inline Check reserve_g_down(TaskReservation& allocator, PortalReservation& portal, uint32_t last_task,
    const NumericIdentity& identity, uint8_t layer, BufferRef wi, BufferRef gate,
    BufferRef dst, uint32_t w_committed, uint32_t a_committed, uint32_t ps_committed,
    uint8_t bias_kind, GDownPlan& plan) {
  // Probe distinct cursor capacity without consuming the authoritative tickets.
  TaskReservation capacity_probe = allocator;
  const bool cursor_capacity = capacity_probe.ref(Buffer::WEIGHT, 0, 0, w_committed).epoch &&
    capacity_probe.ref(Buffer::A8, 0, 0, a_committed).epoch &&
    capacity_probe.ref(Buffer::PS, 0, 0, ps_committed).epoch;
  const unsigned windows = unsigned(identity.B) * ((unsigned(identity.S) + 15) / 16);
  const bool legal_s = identity.S == 64 || identity.S == 128 || identity.S == 256 ||
    identity.S == 512 || identity.S == 1024;
  if (!identity.request_id || !identity.generation || identity.B < 1 || identity.B > 2 ||
      !legal_s || layer > 27 || windows > kGDownWindows || !cursor_capacity ||
      wi.id != Buffer::WI || gate.id != Buffer::GATE || dst.id != Buffer::TMP ||
      !check_ref(wi) || !check_ref(gate) || !check_ref(dst) || bias_kind > 1 ||
      !allocator.can_tasks(last_task, windows * 3 + 1) || !portal.can(windows * 6 + 1) ||
      !allocator.can_refs(Buffer::WEIGHT, 0, 0, w_committed, 1) ||
      !allocator.can_refs(Buffer::A8, 0, 0, a_committed, windows) ||
      !allocator.can_refs(Buffer::PS, 0, 0, ps_committed, windows))
    return {Status::E_PROTOCOL, detail(7, uint8_t(Op::GEGLU), 9)};
  plan.valid = false; plan.identity = identity; plan.count = uint16_t(windows);
  unsigned index = 0;
  for (unsigned b = 0; b < identity.B; ++b) for (unsigned row = 0; row < identity.S; row += 16) {
    GDownWindow& record = plan.window[index++]; record = GDownWindow{};
    record.state = WindowState::RESERVED; record.producer_generation = portal.next();
    record.producer.ctx = allocator.context(last_task, Op::GEGLU, 2, layer, uint8_t(b),
        RowSpace::TOKEN, uint16_t(row), uint8_t(identity.S - row < 16 ? identity.S - row : 16));
    record.producer.src0 = wi; record.producer.dst = gate; record.producer.length = 2624;
  }
  plan.load = LoadTask{}; plan.load_generation = portal.next();
  plan.load.ctx = allocator.context(last_task, Op::LOAD_W, 2, layer, 0, RowSpace::BATCH, 0, 1);
  plan.load.dst = allocator.ref(Buffer::WEIGHT, 0, 0, w_committed);
  plan.load.weight = {4, layer}; plan.load.byte_count = 1024u * 82u * 34u;
  for (unsigned i = 0; i < windows; ++i) {
    GDownWindow& record = plan.window[i]; const TaskContext& p = record.producer.ctx;
    record.quant_generation = portal.next();
    QuantTask& q = record.quant;
    q.ctx = allocator.context(last_task, Op::QUANT, p.stage, p.layer, p.batch, p.row_space, p.row0, p.rows);
    q.src = gate; q.a_dst = allocator.ref(Buffer::A8, 0, 0, a_committed); q.K = 2624;
    LinearTask& l = record.linear;
    l.ctx = allocator.context(last_task, Op::LIN_DOWN, p.stage, p.layer, p.batch, p.row_space, p.row0, p.rows);
    l.a = q.a_dst; l.w = plan.load.dst; l.ps = allocator.ref(Buffer::PS, 0, 0, ps_committed);
    l.dst = dst; l.weight = plan.load.weight; l.K = 2624; l.N = 1024; l.bias_kind = bias_kind;
    // Prechecked capacity; explicit view tickets are independent of typed IDs.
    if (!reserve_views(portal, p.rows, record.view, record.views))
      return {Status::E_INTERNAL, detail(7, uint8_t(Op::GEGLU), 9)};
  }
  plan.valid = true;
  return ok();
}
} // namespace laya::full
