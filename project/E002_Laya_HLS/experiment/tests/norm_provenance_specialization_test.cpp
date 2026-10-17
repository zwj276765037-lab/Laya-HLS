#include "laya_generated_provenance_events.h"

#include <array>
#include <cstdlib>
#include <iostream>
#include <string>

// Independent LPV1 oracle. No DUT address, descriptor, geometry, encode,
// identity serializer or generic result is used to construct expected bytes.
// The generic path is a second comparison, not the source of the gold.
using namespace laya;
namespace {
using provenance::Action;
using provenance::Request;
using full::FullOwnerSpec;
constexpr uint64_t kBase = 8388608, kMappedEnd = 16777216;
constexpr uint64_t kBatchBytes = 4194304, kRowBytes = 4096;
#ifdef LAYA_TRANSACTION_SEQUENCER_CODEC
constexpr bool kBypass = true;
constexpr const char* kMode = "sequencer";
#else
constexpr bool kBypass = false;
constexpr const char* kMode = "wire";
#endif
unsigned checks = 0, comparisons = 0, owner_events = 0, begins = 0;
std::string label;
static full::FullRuntime specialized, generic;
static uint8_t present_byte = 0;

void require(bool yes, const char* what) {
  ++checks;
  if (!yes) {
    std::cerr << "FULL_CURRENT_NORM_PROVENANCE_SPECIALIZATION_FAIL mode="
              << kMode << " case=" << label << " " << what << '\n';
    std::exit(1);
  }
}
Check failure(Status status, uint32_t detail_value, uint64_t bad = UINT64_MAX) {
  return {status, detail_value, bad};
}
Check ref_error(unsigned id, unsigned reason) {
  return failure(Status::E_BUFFER, (4u << 24) | (id << 16) | reason);
}
Check local_protocol(unsigned op = 0) {
  return failure(Status::E_PROTOCOL, (7u << 24) | (op << 16) | 9u);
}
Check wire_error() { return failure(Status::E_ABI, 0x04000016, 16); }
void check_equal(Check got, Check want) {
  if (got.code != want.code || got.detail != want.detail ||
      got.bad_element != want.bad_element) {
    std::cerr << "actual=" << unsigned(got.code) << ":" << got.detail
              << ":" << got.bad_element << " expected=" << unsigned(want.code)
              << ":" << want.detail << ":" << want.bad_element << '\n';
    require(false, "complete Check differs");
  }
  ++checks;
}
NumericIdentity identity(uint16_t B = 2, uint16_t S = 64) {
  NumericIdentity id;
  id.request_id = 0x1020304050607081ull;
  id.generation = 0x9080706050403021ull;
  id.B = B; id.S = S;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x10 + i);
    id.numeric_tag[i] = uint8_t(0x30 + i);
    id.layout_tag[i] = uint8_t(0x50 + i);
    id.build_tag[i] = uint8_t(0x70 + i);
  }
  return id;
}
portal::ModelBinding model(unsigned salt = 0) {
  portal::ModelBinding m;
  for (unsigned i = 0; i < 416; ++i)
    m.identity[i] = uint8_t(i * 19 + 3 + salt);
  for (unsigned i = 0; i < 128; ++i)
    m.expected_aux_header[i] = uint8_t(i * 7 + 5 + salt);
  return m;
}
FullOwnerSpec owner(uint16_t S = 64, uint32_t epoch = 7) {
  return {{Buffer::NORM, 0, epoch}, 0, 2, 3, 255, RowSpace::TOKEN,
          0, S, 1024, Content::F32};
}
full::FullMemory memory(uint64_t bytes = kMappedEnd + 12288, bool present = true) {
  full::FullMemory m;
  // Builders inspect presence/ranges only. No numeric payload is read or
  // written; this one-byte sentinel is never dereferenced by these cases.
  m.state0 = present ? &present_byte : nullptr; m.state0_bytes = bytes;
  return m;
}
LayerNormTask task(const FullOwnerSpec& o, uint8_t batch = 0,
                   uint16_t row0 = 0, uint8_t rows = 16) {
  LayerNormTask t;
  t.ctx = {0x10203, Op::LN_ATTN, o.stage, o.layer, batch,
           RowSpace::TOKEN, row0, rows};
  t.src = {Buffer::HIDDEN, 1, o.ref.epoch + 1}; t.dst = o.ref;
  return t;
}
full::FullOwnerRecord record(const NumericIdentity& id, const FullOwnerSpec& o,
                             CacheState state = CacheState::FILL,
                             BufferRef old = none()) {
  full::FullOwnerRecord r;
  r.identity = id; r.ref = o.ref; r.lease_old_ref = old;
  r.max_claimed_epoch = o.ref.epoch; r.region = o.region;
  r.stage = o.stage; r.layer = o.layer; r.batch = o.batch;
  r.row_space = o.row_space; r.row0 = o.row0; r.rows = o.rows;
  r.width = o.width; r.content = o.content; r.state = state;
  r.valid = true; r.readers = 0;
  r.covered_rows[3] = 0x12345678; r.old_consumed_rows[9] = 0x87654321;
  return r;
}
void reset(full::FullRuntime& rt, const NumericIdentity& id, uint64_t seq,
           const full::FullOwnerRecord& installed) {
  rt.inputs.identity = id; rt.provenance_event_high_water = seq;
  for (auto& r : rt.owners.record) r = full::FullOwnerRecord{};
  rt.owners.record[0] = installed;
  rt.last_task_id = 123; rt.tasks_retired = 456;
}
Request sentinel() {
  Request r;
  r.action = Action::END; r.event_seq = 0xdeadbeef01234567ull;
  r.origin_seq = 0xabcdef0123456789ull;
  r.identity = identity(1, 1024); r.model_identity = model(37).identity;
  r.reported_error_detail = 0x55555555; r.issued_store_bytes[1] = 0x12345678;
  return r;
}
void put(std::array<uint8_t, 1024>& p, unsigned at, uint64_t v, unsigned n) {
  for (unsigned i = 0; i < n; ++i) p[at + i] = uint8_t(v >> (8 * i));
}
void put_ref(std::array<uint8_t, 1024>& p, unsigned at, BufferRef r, uint8_t region) {
  put(p, at, r.epoch, 4); p[at + 4] = uint8_t(r.id);
  p[at + 5] = r.bank; p[at + 6] = region;
}
// With state=true this also covers inactive descriptor/geometry fields that
// a valid LPV1 packet leaves reserved. The wire gold still requires all those
// reserved wire bytes to be zero.
std::array<uint8_t, 1024> literal_packet(const Request& r, bool state = false) {
  std::array<uint8_t, 1024> p{};
  p[0] = 'L'; p[1] = 'P'; p[2] = 'V'; p[3] = '1';
  put(p, 4, 1, 2); put(p, 6, uint16_t(r.action), 2);
  put(p, 8, r.event_seq, 8); put(p, 16, r.context.task_id, 4);
  put(p, 24, 16, 2); put(p, 26, 8, 2); put(p, 32, r.origin_seq, 8);
  put(p, 40, uint16_t(r.reported_status), 2); p[42] = uint8_t(r.reported_unit);
  put(p, 44, r.reported_elements, 4); put(p, 48, r.reported_error_detail, 4);
  put(p, 56, r.reported_bad_element, 8);
  put(p, 64, r.identity.request_id, 8); put(p, 72, r.identity.generation, 8);
  put(p, 80, r.identity.B, 2); put(p, 82, r.identity.S, 2);
  for (unsigned i = 0; i < 16; ++i) {
    p[84 + i] = r.identity.model_tag[i]; p[100 + i] = r.identity.numeric_tag[i];
    p[116 + i] = r.identity.layout_tag[i]; p[132 + i] = r.identity.build_tag[i];
  }
  put(p, 148, r.context.task_id, 4); p[152] = uint8_t(r.context.op);
  p[153] = r.context.stage; p[154] = r.context.layer; p[155] = r.context.batch;
  p[156] = uint8_t(r.context.row_space); put(p, 157, r.context.row0, 2);
  p[159] = r.context.rows;
  for (unsigned i = 0; i < 416; ++i) p[160 + i] = r.model_identity[i];
  p[576] = r.descriptor_count; p[578] = uint8_t(r.expected_unit);
  put(p, 580, r.expected_elements, 4);
  put(p, 584, r.issued_store_bytes[0], 8); put(p, 592, r.issued_store_bytes[1], 8);
  for (unsigned i = 0; i < (state ? 2u : unsigned(r.descriptor_count)); ++i) {
    const auto& d = r.descriptor[i]; const unsigned a = 608 + 128 * i;
    put_ref(p, a, d.target_ref, d.target_region); put_ref(p, a + 8, d.old_ref, d.old_region);
    p[a + 16] = d.stage; p[a + 17] = d.layer; p[a + 18] = d.batch;
    p[a + 19] = uint8_t(d.row_space); put(p, a + 20, d.row0, 2);
    put(p, a + 22, d.rows, 2); put(p, a + 24, d.width, 2);
    p[a + 26] = uint8_t(d.content); p[a + 27] = d.layout; p[a + 28] = uint8_t(d.role);
    put(p, a + 32, d.bo_span, 8); put(p, a + 40, d.owner_base_offset, 8);
    put(p, a + 48, d.row_stride, 8); put(p, a + 56, d.batch_stride, 8);
    put(p, a + 64, d.owner_extent_span, 8); put(p, a + 72, d.head_stride, 8);
    put(p, a + 80, d.plane_stride, 8);
  }
  if (state || r.action == Action::BEGIN || r.action == Action::END)
    for (unsigned i = 0; i < (state ? 2u : unsigned(r.descriptor_count)); ++i) {
      const auto& g = r.geometry[i]; const unsigned a = 864 + 64 * i;
      put(p, a, g.first_offset, 8); put(p, a + 8, g.segment_bytes, 4);
      put(p, a + 12, g.row_count, 2); put(p, a + 14, g.repeat_count, 2);
      put(p, a + 16, g.row_step, 8); put(p, a + 24, g.repeat_step, 8);
      put(p, a + 32, g.total_write_bytes, 8); p[a + 40] = uint8_t(g.component);
      p[a + 41] = g.head; p[a + 42] = g.plane_mask;
    }
  return p;
}
void bytes_equal(const std::array<uint8_t, 1024>& got,
                 const std::array<uint8_t, 1024>& want, const char* what) {
  for (unsigned i = 0; i < 1024; ++i) {
    if (got[i] != want[i]) {
      std::cerr << "byte=" << i << " actual=" << unsigned(got[i])
                << " expected=" << unsigned(want[i]) << '\n';
      require(false, what);
    }
  }
  ++checks;
}
enum class Prefix { EMPTY, METADATA, FULL };
provenance::OwnerDescriptor descriptor_gold(const FullOwnerSpec& o,
    const NumericIdentity& id, uint64_t capacity, Prefix prefix,
    BufferRef old = none()) {
  provenance::OwnerDescriptor d;
  if (prefix == Prefix::EMPTY) return d;
  d.target_ref = o.ref; d.target_region = o.region; d.old_ref = old;
  d.old_region = old.id == Buffer::NONE ? 0 : o.region;
  d.stage = o.stage; d.layer = o.layer; d.batch = o.batch; d.row_space = o.row_space;
  d.row0 = o.row0; d.rows = o.rows; d.width = o.width; d.content = o.content;
  d.role = Bo::STATE0; d.bo_span = capacity;
  if (prefix == Prefix::METADATA) return d;
  const uint64_t first_batch = o.batch == 255 ? 0 : o.batch;
  const uint64_t batch_count = o.batch == 255 ? id.B : 1;
  d.owner_base_offset = kBase + first_batch * kBatchBytes + uint64_t(o.row0) * kRowBytes;
  d.row_stride = o.rows == 1 ? 0 : kRowBytes;
  d.batch_stride = o.batch == 255 ? kBatchBytes : 0;
  d.owner_extent_span = (batch_count - 1) * kBatchBytes +
                        uint64_t(o.rows - 1) * kRowBytes + uint64_t(o.width) * 4;
  return d;
}
Request base_gold(Action action, uint64_t seq, const NumericIdentity& id,
                  const portal::ModelBinding& m) {
  Request r; r.action = action; r.event_seq = seq;
  r.identity = id; r.model_identity = m.identity; return r;
}
Request owner_gold(Action action, uint64_t seq, const NumericIdentity& id,
                    const portal::ModelBinding& m, const FullOwnerSpec& o,
                    const full::FullMemory& mem, Prefix prefix = Prefix::FULL) {
  Request r = base_gold(action, seq, id, m);
  r.descriptor[0] = descriptor_gold(o, id, mem.state0_bytes, prefix); return r;
}
Request begin_gold(uint64_t seq, const NumericIdentity& id,
                    const portal::ModelBinding& m, const FullOwnerSpec& o,
                    const full::FullMemory& mem, const LayerNormTask& t,
                    uint32_t elements, Prefix prefix = Prefix::FULL,
                    unsigned geometry_prefix = 2, BufferRef old = none()) {
  Request r = base_gold(Action::BEGIN, seq, id, m);
  r.origin_seq = seq; r.context = t.ctx;
  r.expected_unit = OutputUnit::F32; r.expected_elements = elements;
  r.descriptor[0] = descriptor_gold(o, id, mem.state0_bytes, prefix, old);
  if (!geometry_prefix) return r;
  auto& g = r.geometry[0];
  g.first_offset = kBase + uint64_t(t.ctx.batch) * kBatchBytes + uint64_t(t.ctx.row0) * kRowBytes;
  g.segment_bytes = 4096; g.row_count = t.ctx.rows; g.repeat_count = 1;
  if (geometry_prefix == 1) return r;
  g.row_step = t.ctx.rows > 1 ? 4096 : 0;
  g.total_write_bytes = uint64_t(t.ctx.rows) * 4096;
  g.head = 255; return r;
}
void unchanged_runtime(const full::FullRuntime& rt,
                       const full::FullOwnerRecord& r) {
  require(rt.last_task_id == 123 && rt.tasks_retired == 456,
          "builder must not retire tasks");
  const auto& a = rt.owners.record[0];
  require(a.ref == r.ref && a.lease_old_ref == r.lease_old_ref &&
          a.state == r.state && a.readers == r.readers && a.valid == r.valid &&
          a.max_claimed_epoch == r.max_claimed_epoch && a.region == r.region &&
          a.stage == r.stage && a.layer == r.layer && a.batch == r.batch &&
          a.row_space == r.row_space && a.row0 == r.row0 && a.rows == r.rows &&
          a.width == r.width && a.content == r.content,
          "builder mutated owner metadata");
  for (unsigned i = 0; i < 64; ++i)
    require(a.covered_rows[i] == r.covered_rows[i] &&
            a.old_consumed_rows[i] == r.old_consumed_rows[i], "builder mutated coverage");
}
void owner_compare(const NumericIdentity& id, const FullOwnerSpec& o,
    const full::FullMemory& mem, const portal::ModelBinding& m, Action action,
    uint64_t before, Check expected, const Request& gold, uint64_t after) {
  const auto installed = record(id, o);
  reset(specialized, id, before, installed); reset(generic, id, before, installed);
  Request a = sentinel(), b = sentinel();
  const Check ca = provenance::build_norm_owner_event(specialized, mem, m, action, o, a);
  const Check cb = provenance::build_owner_event(generic, mem, m, action, &o, nullptr, 1, b);
  check_equal(ca, expected); check_equal(cb, expected);
  require(specialized.provenance_event_high_water == after &&
          generic.provenance_event_high_water == after, "owner event sequence differs");
  bytes_equal(literal_packet(a, true), literal_packet(gold, true), "owner state differs from gold");
  bytes_equal(literal_packet(b, true), literal_packet(gold, true), "generic owner differs from gold");
  bytes_equal(provenance::encode(a), literal_packet(gold), "all owner wire bytes differ");
  bytes_equal(provenance::encode(b), literal_packet(gold), "all generic owner wire bytes differ");
  unchanged_runtime(specialized, installed); unchanged_runtime(generic, installed);
  ++comparisons; ++owner_events;
}
void begin_compare(const NumericIdentity& id, const FullOwnerSpec& o,
    const full::FullMemory& mem, const portal::ModelBinding& m, const LayerNormTask& t,
    uint32_t elements, OutputUnit unit, uint64_t before, Check expected,
    const Request& gold, uint64_t after, const full::FullOwnerRecord* override_record = nullptr) {
  const auto installed = override_record ? *override_record : record(id, o);
  reset(specialized, id, before, installed); reset(generic, id, before, installed);
  Request a = sentinel(), b = sentinel(); bool pa = false, pb = false;
  const Check ca = provenance::build_norm_generated_begin(specialized, mem, m, t, elements, unit, a, pa);
  const Check cb = provenance::build_generated_begin(generic, mem, m, t, elements, unit, b, pb);
  check_equal(ca, expected); check_equal(cb, expected);
  require(pa && pb, "NORM protected_task must be true on success and rejection");
  require(specialized.provenance_event_high_water == after &&
          generic.provenance_event_high_water == after, "BEGIN event sequence differs");
  bytes_equal(literal_packet(a, true), literal_packet(gold, true), "BEGIN state differs from gold");
  bytes_equal(literal_packet(b, true), literal_packet(gold, true), "generic BEGIN differs from gold");
  bytes_equal(provenance::encode(a), literal_packet(gold), "all BEGIN wire bytes differ");
  bytes_equal(provenance::encode(b), literal_packet(gold), "all generic BEGIN wire bytes differ");
  unchanged_runtime(specialized, installed); unchanged_runtime(generic, installed);
  ++comparisons; ++begins;
}
void matrix() {
  const uint32_t epochs[] = {7, 41, 0xfffffffeu};
  const uint16_t shapes[] = {1, 16, 64, 1024};
  for (uint16_t B : {1, 2}) for (uint16_t S : shapes) for (uint32_t epoch : epochs) {
    const auto id = identity(B, S); auto o = owner(S, epoch);
    const auto mem = memory(); const auto m = model(unsigned(B) + S + epoch);
    label = "matrix/B" + std::to_string(B) + "/S" + std::to_string(S) + "/epoch" + std::to_string(epoch);
    const bool legal = S >= 64;
    for (Action action : {Action::CLAIM, Action::PUBLISH, Action::INVALIDATE})
      owner_compare(id, o, mem, m, action, 101, legal ? ok() : ref_error(2, 5),
          owner_gold(action, 102, id, m, o, mem, legal ? Prefix::FULL : Prefix::METADATA), 102);
    for (uint8_t batch = 0; batch < B; ++batch) {
      for (uint16_t row0 = 0; row0 < S; row0 = uint16_t(row0 + 16)) {
        const uint8_t rows = uint8_t(S - row0 < 16 ? S - row0 : 16);
        auto t = task(o, batch, row0, rows);
        t.ctx.task_id += row0 + batch * 1024;
        begin_compare(id, o, mem, m, t, uint32_t(rows) * 1024, OutputUnit::F32,
          1001 + row0, legal ? ok() : ref_error(2, 5),
          begin_gold(1002 + row0, id, m, o, mem, t, uint32_t(rows) * 1024,
                     legal ? Prefix::FULL : Prefix::METADATA, legal ? 2 : 0), 1002 + row0);
      }
      if (legal) {
        const auto t = task(o, batch, uint16_t(S - 1), 1);
        begin_compare(id, o, mem, m, t, 1024, OutputUnit::F32, 9001, ok(),
          begin_gold(9002, id, m, o, mem, t, 1024), 9002);
      }
    }
  }
}
void owner_rejections() {
  const auto mem = memory(); const auto m = model(); const auto id = identity();
  auto run = [&](const char* name, FullOwnerSpec o, Check c, Prefix prefix,
                 NumericIdentity input) {
    label = name;
    owner_compare(input, o, mem, m, Action::CLAIM, 17, c,
                   owner_gold(Action::CLAIM, 18, input, m, o, mem, prefix), 18);
  };
  auto o = owner(); o.ref.id = Buffer(0x7f); run("unknown-ref", o, ref_error(0x7f, 4), Prefix::EMPTY, id);
  o = owner(); o.ref.epoch = 0; run("zero-epoch", o, ref_error(2, 9), Prefix::EMPTY, id);
  o = owner(); o.ref.epoch = UINT32_MAX; run("reserved-epoch", o, ref_error(2, 9), Prefix::EMPTY, id);
  o = owner(); o.ref.bank = 1; run("wrong-bank", o, ref_error(2, 4), Prefix::EMPTY, id);
  o = owner(); o.region = 1; run("unknown-region", o, ref_error(2, 4), Prefix::EMPTY, id);
  o = owner(); o.row_space = RowSpace(255);
  run("unknown-row-layout", o, kBypass ? ok() : wire_error(), Prefix::FULL, id);
  o = owner(); o.width = 1025; run("over-width", o, ref_error(2, 8), Prefix::METADATA, id);
  o = owner(); o.width = 0; run("zero-width", o, ref_error(2, 8), Prefix::METADATA, id);
  o = owner(); o.rows = 0; run("zero-owner-rows", o, ref_error(2, 8), Prefix::METADATA, id);
  o = owner(); o.rows = 65; run("owner-end-overrun", o, ref_error(2, 8), Prefix::METADATA, id);
  o = owner(); o.row0 = 64; run("owner-first-overrun", o, ref_error(2, 5), Prefix::METADATA, id);
  o = owner(); o.batch = 2; run("owner-wrong-batch", o, ref_error(2, 5), Prefix::METADATA, id);
  for (uint16_t B : {0, 3}) run("bad-B", owner(), ref_error(2, 5), Prefix::METADATA, identity(B, 64));
  for (uint16_t S : {0, 1025}) run("bad-S", owner(), ref_error(2, 5), Prefix::METADATA, identity(2, S));
  label = "wrong-owner-action";
  owner_compare(id, owner(), mem, m, Action::BEGIN, 17, local_protocol(), sentinel(), 17);
  // S65 is not admitted by task context validation, but owner metadata's old
  // address/wire range accepts it. This compatibility edge must be preserved.
  label = "S65-owner-range-compatibility";
  owner_compare(identity(2, 65), owner(65), mem, m, Action::CLAIM, 17, ok(),
    owner_gold(Action::CLAIM, 18, identity(2, 65), m, owner(65), mem), 18);
}
void capacity_cases() {
  const auto id = identity(); const auto o = owner(); const auto m = model();
  for (uint64_t cap : {uint64_t(0), kMappedEnd - 1, kMappedEnd, kMappedEnd + 1,
                       uint64_t(UINT32_MAX), uint64_t(UINT64_MAX)}) {
    label = "capacity-" + std::to_string(cap); const auto mem = memory(cap);
    const bool legal = cap >= kMappedEnd;
    owner_compare(id, o, mem, m, Action::PUBLISH, 19, legal ? ok() : ref_error(2, 8),
      owner_gold(Action::PUBLISH, 20, id, m, o, mem, legal ? Prefix::FULL : Prefix::EMPTY), 20);
    const auto t = task(o);
    begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, 19,
      legal ? ok() : ref_error(2, 8),
      begin_gold(20, id, m, o, mem, t, 16384,
        legal ? Prefix::FULL : Prefix::EMPTY, legal ? 2 : 0), 20);
  }
  label = "missing-STATE0-with-full-capacity"; const auto mem = memory(kMappedEnd, false);
  owner_compare(id, o, mem, m, Action::INVALIDATE, 19, ref_error(6, 9),
    owner_gold(Action::INVALIDATE, 20, id, m, o, mem, Prefix::METADATA), 20);
  const auto t = task(o);
  begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, 19, ref_error(6, 9),
    begin_gold(20, id, m, o, mem, t, 16384, Prefix::METADATA, 0), 20);
}
void begin_rejections() {
  const auto id = identity(); const auto o = owner(); const auto m = model(); const auto mem = memory();
  const auto baseline = task(o);
  for (OutputUnit unit : {OutputUnit::NONE, OutputUnit::Q8_GROUP, OutputUnit::BYTES}) {
    label = "wrong-output-unit";
    begin_compare(id, o, mem, m, baseline, 16384, unit, 21,
      local_protocol(0x11), sentinel(), 21);
  }
  label = "zero-elements";
  begin_compare(id, o, mem, m, baseline, 0, OutputUnit::F32, 21,
    local_protocol(0x11), sentinel(), 21);
  for (unsigned kind = 0; kind < 6; ++kind) {
    auto t = baseline; auto r = record(id, o); label = "snapshot-reject-" + std::to_string(kind);
    if (kind == 0) t.dst.epoch++;
    if (kind == 1) t.dst.id = Buffer(0x7f);
    if (kind == 2) t.dst.bank = 1;
    if (kind == 3) r.region = 1;
    if (kind == 4) r.state = CacheState::READY;
    if (kind == 5) r.state = CacheState::READ;
    begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, 21,
      ref_error(uint8_t(t.dst.id), 8), sentinel(), 21, &r);
  }
  // Every identity tag byte and both 64-bit identities must be checked by the
  // snapshot; the owner may not be accepted by a short prefix comparison.
  for (unsigned field = 0; field < 68; ++field) {
    auto r = record(id, o); label = "foreign-owner-identity-" + std::to_string(field);
    if (field < 16) r.identity.model_tag[field] ^= 0x80;
    else if (field < 32) r.identity.numeric_tag[field - 16] ^= 0x80;
    else if (field < 48) r.identity.layout_tag[field - 32] ^= 0x80;
    else if (field < 64) r.identity.build_tag[field - 48] ^= 0x80;
    else if (field == 64) r.identity.request_id ^= uint64_t(1) << 63;
    else if (field == 65) r.identity.generation ^= uint64_t(1) << 63;
    else if (field == 66) r.identity.B++;
    else r.identity.S++;
    begin_compare(id, o, mem, m, baseline, 16384, OutputUnit::F32, 21,
      ref_error(2, 8), sentinel(), 21, &r);
  }
  for (unsigned kind = 0; kind < 12; ++kind) {
    auto t = baseline; unsigned gp = 2; Check c = kBypass ? ok() : wire_error();
    label = "wrong-context-" + std::to_string(kind);
    if (kind == 0) { t.ctx.batch = 2; gp = 0; c = ref_error(2, 5); }
    if (kind == 1) { t.ctx.row0 = 64; gp = 0; c = ref_error(2, 5); }
    if (kind == 2) { t.ctx.row0 = 63; t.ctx.rows = 2; gp = 1; c = ref_error(2, 8); }
    if (kind == 3) t.ctx.rows = 0;
    if (kind == 4) t.ctx.rows = 17;
    if (kind == 5) t.ctx.task_id = 0;
    if (kind == 6) t.ctx.op = Op(0xff);
    if (kind == 7) t.ctx.stage = 8;
    if (kind == 8) t.ctx.layer = 28;
    if (kind == 9) t.ctx.row_space = RowSpace(255);
    if (kind == 10) t.ctx.task_id = UINT32_MAX;
    // Generic geometry checks first/next row, not the last row. Strict wire
    // context catches this overrun; sequencer mode requires upstream checks.
    if (kind == 11) { t.ctx.row0 = 62; t.ctx.rows = 16; }
    begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, 21, c,
      begin_gold(22, id, m, o, mem, t, 16384, Prefix::FULL, gp), 22);
  }
  auto t = baseline; t.ctx.row0 = 64; t.ctx.rows = 1;
  label = "S65-tail1-context-compatibility";
  begin_compare(identity(2, 65), owner(65), mem, m, t, 1024, OutputUnit::F32, 21,
    kBypass ? ok() : wire_error(),
    begin_gold(22, identity(2, 65), m, owner(65), mem, t, 1024), 22);
}
void sequence_cases() {
  const auto id = identity(); const auto o = owner(); const auto mem = memory(); const auto m = model();
  const auto t = task(o);
  label = "last-owner-sequence";
  owner_compare(id, o, mem, m, Action::CLAIM, UINT64_MAX - 1, ok(),
    owner_gold(Action::CLAIM, UINT64_MAX, id, m, o, mem), UINT64_MAX);
  label = "exhausted-owner-sequence"; Request owner_empty; owner_empty.action = Action::PUBLISH;
  owner_compare(id, o, mem, m, Action::PUBLISH, UINT64_MAX, local_protocol(), owner_empty, UINT64_MAX);
  label = "last-BEGIN-sequence";
  begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, UINT64_MAX - 1, ok(),
    begin_gold(UINT64_MAX, id, m, o, mem, t, 16384), UINT64_MAX);
  label = "exhausted-BEGIN-sequence"; Request begin_empty; begin_empty.action = Action::BEGIN;
  begin_compare(id, o, mem, m, t, 16384, OutputUnit::F32, UINT64_MAX,
    local_protocol(), begin_empty, UINT64_MAX);
  label = "unit-before-sequence-exhaustion";
  begin_compare(id, o, mem, m, t, 0, OutputUnit::NONE, UINT64_MAX,
    local_protocol(0x11), sentinel(), UINT64_MAX);
  label = "snapshot-before-sequence-exhaustion"; auto stale = t; stale.dst.epoch++;
  begin_compare(id, o, mem, m, stale, 16384, OutputUnit::F32, UINT64_MAX,
    ref_error(2, 8), sentinel(), UINT64_MAX);
}
void old_owner_and_model() {
  const auto id = identity(); const auto o = owner(); const auto mem = memory(); const auto baseline = task(o);
  for (unsigned kind = 0; kind < 3; ++kind) {
    BufferRef old = kind == 0 ? BufferRef{Buffer::NORM, 0, 5} :
                    kind == 1 ? none() : BufferRef{Buffer(0x7f), 1, 11};
    auto r = record(id, o, CacheState::EXCLUSIVE_RW, old); const auto m = model();
    label = "exclusive-old-ref-" + std::to_string(kind);
    begin_compare(id, o, mem, m, baseline, 16384, OutputUnit::F32, 31,
      kind == 2 && !kBypass ? wire_error() : ok(),
      begin_gold(32, id, m, o, mem, baseline, 16384, Prefix::FULL, 2, old), 32, &r);
  }
  // Complete opaque MODEL_IDENTITY propagation, including its last byte.
  // These builders copy metadata; model acceptance belongs to admission.
  for (unsigned i = 0; i < 416; ++i) {
    auto m = model(); m.identity[i] ^= 0x80; label = "model-byte-" + std::to_string(i);
    begin_compare(id, o, mem, m, baseline, 16384, OutputUnit::F32, 31, ok(),
      begin_gold(32, id, m, o, mem, baseline, 16384), 32);
  }
  auto t = baseline; t.src = {Buffer(0xff), 1, UINT32_MAX};
  t.D = 1; t.gamma = 255; t.eps_bits = UINT32_MAX;
  label = "arithmetic-task-fields-are-upstream";
  begin_compare(id, o, mem, model(), t, 7, OutputUnit::F32, 31, ok(),
    begin_gold(32, id, model(), o, mem, t, 7), 32);
}
} // namespace

int main(int argc, char** argv) {
  if (argc != 2) return 2;
  const std::string which = argv[1];
  if (which == "matrix") matrix();
  else if (which == "owner-rejections") owner_rejections();
  else if (which == "capacity") capacity_cases();
  else if (which == "begin-rejections") begin_rejections();
  else if (which == "sequence") sequence_cases();
  else if (which == "old-owner-model") old_owner_and_model();
  else return 2;
  std::cout << "FULL_CURRENT_NORM_PROVENANCE_SPECIALIZATION_PASS case=" << which
            << " mode=" << kMode << " checks=" << checks << " comparisons=" << comparisons
            << " owner_events=" << owner_events << " begins=" << begins
            << " complete_wire_bytes=1024 independent_gold=1 generic_compare=1"
            << " arithmetic_payload=NOT_RUN HLS=NOT_RUN\n";
  return 0;
}
