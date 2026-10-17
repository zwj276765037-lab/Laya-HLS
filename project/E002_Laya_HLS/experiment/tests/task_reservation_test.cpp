#include "laya_full_runtime.h"
#include "laya_task_reservation.h"
#include <cassert>
#include <iostream>
#include <memory>
#include <set>

using namespace laya;
using namespace laya::full;
int main() {
  auto runtime = std::make_unique<FullRuntime>();
  runtime->inputs.identity.request_id = 1; runtime->inputs.identity.generation = 7;
  runtime->inputs.identity.B = 2; runtime->inputs.identity.S = 1024;
  runtime->last_task_id = 41; runtime->tasks_retired = 41; runtime->op_calls[0x60] = 3;
  runtime->owners.record[0].ref = {Buffer::WEIGHT, 0, 7};
  runtime->owners.record[0].max_claimed_epoch = 7;
  runtime->owners.record[0].state = CacheState::READY;
  runtime->cache.activation_meta.ref = {Buffer::A8, 0, 5};
  runtime->cache.activation_meta.state = CacheState::INVALID;
  TaskReservation allocator; PortalReservation portal; GDownPlan plan;
  assert(reserve_g_down(allocator, portal, runtime->last_task_id, runtime->inputs.identity, 27,
      {Buffer::WI, 0, 4}, {Buffer::GATE, 0, 8}, {Buffer::TMP, 0, 11}, 7, 5, 9, 0, plan));
  assert(plan.count == 128 && plan.valid);
  // Tickets cannot retire work, change owner epochs, fill a slot, or publish READY.
  assert(runtime->last_task_id == 41 && runtime->tasks_retired == 41 && runtime->op_calls[0x60] == 3);
  assert(runtime->owners.record[0].max_claimed_epoch == 7 && runtime->owners.record[0].state == CacheState::READY);
  assert(runtime->cache.activation_meta.ref.epoch == 5 && runtime->cache.activation_meta.state == CacheState::INVALID);
  std::set<uint32_t> ids, a_epochs, ps_epochs;
  uint32_t next = 42;
  for (unsigned b = 0; b < 2; ++b) for (unsigned row = 0; row < 1024; row += 16) {
    const auto& w = plan.window[b*64+row/16];
    assert(w.producer.ctx.task_id == next++); ids.insert(w.producer.ctx.task_id);
    assert(w.producer.ctx.batch == b && w.producer.ctx.row0 == row && w.producer.ctx.rows == 16);
    assert(w.producer.dst == (BufferRef{Buffer::GATE, 0, 8}));
    assert(w.state == WindowState::RESERVED);
  }
  assert(plan.load.ctx.task_id == next++ && plan.load.dst.epoch == 8 && plan.load.byte_count == 2854912);
  ids.insert(plan.load.ctx.task_id);
  for (unsigned i = 0; i < 128; ++i) {
    const auto& w = plan.window[i];
    assert(w.quant.ctx.task_id == next++ && w.linear.ctx.task_id == next++);
    ids.insert(w.quant.ctx.task_id); ids.insert(w.linear.ctx.task_id);
    a_epochs.insert(w.quant.a_dst.epoch); ps_epochs.insert(w.linear.ps.epoch);
    assert(w.quant.src == w.producer.dst && w.quant.a_dst == w.linear.a && w.linear.w == plan.load.dst);
    assert(w.linear.dst == (BufferRef{Buffer::TMP, 0, 11}));
    assert(w.quant.a_dst.epoch == i+6 && w.linear.ps.epoch == i+10);
    assert(w.quant.ctx.batch == w.producer.ctx.batch && w.quant.ctx.row0 == w.producer.ctx.row0);
    assert(w.linear.ctx.batch == w.producer.ctx.batch && w.linear.ctx.row0 == w.producer.ctx.row0);
  }
  assert(ids.size() == 385 && a_epochs.size() == 128 && ps_epochs.size() == 128);
  assert(allocator.task_high_water(41) == 426);
  assert(allocator.ref(Buffer::A8, 0, 0, 5).epoch == 134);
  assert(portal.high_water() == 769);
  uint64_t g = 1;
  for (unsigned i = 0; i < 128; ++i) assert(plan.window[i].producer_generation == g++);
  assert(plan.load_generation == g++);
  for (unsigned i = 0; i < 128; ++i) {
    const auto& w = plan.window[i]; assert(w.quant_generation == g++ && w.views == 4);
    for (unsigned v = 0; v < 4; ++v) assert(w.view[v].generation == g++ && w.view[v].row_block == v*4 && w.view[v].rows == 4);
  }
  // Ref cursors preserve real aliases while independent physical slots/regions remain independent.
  TaskReservation aliases;
  assert(aliases.ref(Buffer::WI, 0, 0, 9).epoch == 10);
  assert(aliases.ref(Buffer::DEC_FF, 0, 0, 9).epoch == 11);
  assert(aliases.ref(Buffer::ROPE_TABLE, 0, 0, 3).epoch == 4);
  assert(aliases.ref(Buffer::ROPE_TABLE, 1, 0, 3).epoch == 5);
  assert(aliases.ref(Buffer::HEAD_WORK, 0, 1, 0).epoch == 1);
  assert(aliases.ref(Buffer::HEAD_WORK, 0, 2, 0).epoch == 1);
  assert(aliases.ref(Buffer::A8, 1, 0, 0).epoch == 1);
  // No partial reservation on illegal capacity or epoch/task overflow.
  TaskReservation untouched; PortalReservation unused; GDownPlan rejected;
  auto invalid = runtime->inputs.identity; invalid.S = 2048;
  assert(!reserve_g_down(untouched, unused, 41, invalid, 27, {Buffer::WI,0,4}, {Buffer::GATE,0,8},
      {Buffer::TMP,0,11}, 7, 5, 9, 0, rejected));
  assert(untouched.task_high_water(41) == 41 && untouched.ref_high_water(Buffer::WEIGHT,0,0,7) == 7);
  assert(!reserve_g_down(untouched, unused, kMaxEpoch-384, runtime->inputs.identity, 27,
      {Buffer::WI,0,4}, {Buffer::GATE,0,8}, {Buffer::TMP,0,11}, 7, 5, 9, 0, rejected));
  assert(!reserve_g_down(untouched, unused, 41, runtime->inputs.identity, 27,
      {Buffer::WI,0,4}, {Buffer::GATE,0,8}, {Buffer::TMP,0,11}, 7, kMaxEpoch-127, 9, 0, rejected));
  assert(untouched.task_high_water(41) == 41);
  // Cancellation changes plan validity only; committed physical high-water survives.
  plan.window[0].state = WindowState::PRODUCED; plan.cancel();
  assert(!plan.valid && plan.window[0].state == WindowState::CANCELED && runtime->owners.record[0].max_claimed_epoch == 7);
  TaskReservation recovered; GDownPlan recovery;
  auto next_request = runtime->inputs.identity; next_request.request_id = 2; next_request.B = 1; next_request.S = 64;
  assert(reserve_g_down(recovered, portal, 0, next_request, 0, {Buffer::WI,0,5}, {Buffer::GATE,0,9},
      {Buffer::TMP,0,12}, 8, 6, 10, 1, recovery));
  assert(recovery.count == 4 && recovery.window[0].producer.ctx.task_id == 1);
  assert(recovery.identity.generation == 7 && recovery.identity.request_id == 2);
  assert(recovery.load.dst.epoch == 9 && recovery.window[0].quant.a_dst.epoch == 7);
  assert(recovery.window[0].producer_generation == 770 && portal.high_water() == 794);
  // All legal parent extents use bounded 4-row plus 1-row tail tickets.
  for (uint8_t rows = 1; rows <= 16; ++rows) {
    PortalReservation tails; ViewTicket view[kMatrixViews]; uint8_t count = 0;
    assert(reserve_views(tails, rows, view, count) && count == view_count(rows));
    unsigned row = 0;
    for (unsigned v = 0; v < count; ++v) {
      assert(view[v].row_block == row && (view[v].rows == 1 || view[v].rows == 4)); row += view[v].rows;
    }
    assert(row == rows && count <= 6);
  }
  assert(unused.high_water() == 0);
  PortalReservation exhausted(UINT64_MAX - 768); TaskReservation overflow_tasks; GDownPlan no_wrap;
  assert(!reserve_g_down(overflow_tasks, exhausted, 0, runtime->inputs.identity, 0,
      {Buffer::WI,0,4}, {Buffer::GATE,0,8}, {Buffer::TMP,0,11}, 7, 5, 9, 0, no_wrap));
  assert(exhausted.high_water() == UINT64_MAX - 768 && overflow_tasks.task_high_water(0) == 0);
  PortalReservation last(UINT64_MAX - 1);
  assert(last.next() == UINT64_MAX && last.next() == 0 && last.high_water() == UINT64_MAX);
  std::cout << "FULL_CURRENT_RESERVATION_PASS windows=128 typed_tasks=385 portal_commands=769 tails_1_16=1 burned_unsent_g=1 unique_A=128 unique_PS=128 no_claim=1 same_generation_rebuild=1 allocator_bytes="
      << sizeof(TaskReservation) << " window_bytes=" << sizeof(GDownWindow) << " plan_bytes=" << sizeof(GDownPlan) << "\n";
}
