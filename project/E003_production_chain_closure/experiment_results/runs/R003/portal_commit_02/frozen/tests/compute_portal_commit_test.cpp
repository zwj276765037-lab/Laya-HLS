#include "laya_compute_portal_commit.h"
#include "laya_model_layout_generated.h"
#include <cassert>
#include <iostream>

using namespace laya;
using namespace laya::full;
using namespace laya::portal;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 9; id.generation = 17; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = kFullModelTag[i];
    id.numeric_tag[i] = kFullNumericTag[i];
    id.layout_tag[i] = kFullLayoutTag[i];
    id.build_tag[i] = kFullBuildTag[i];
  }
  return id;
}

TaskDone succeeded(uint32_t task_id, uint32_t elements, OutputUnit unit) {
  TaskDone done;
  done.task_id = task_id; done.status = Status::OK;
  done.output_elements = elements; done.output_unit = unit;
  done.drained = true;
  return done;
}

void fill_owner(FullRuntime& rt, const FullOwnerSpec& owner) {
  assert(full_claim_owner(rt, owner));
  for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
    for (unsigned row = 0; row < owner.rows; row += 16)
      assert(full_cover_owner(rt, owner, uint8_t(batch), uint16_t(row),
                              uint16_t(owner.rows - row < 16 ?
                                       owner.rows - row : 16)));
  assert(full_publish_owner(rt, owner));
}

} // namespace

int main() {
  static FullRuntime rt;
  rt.inputs.identity = identity();
  rt.request_valid = true; rt.model_header_valid = true;
  // Task 1 is the real producer that published the source tensor.
  rt.last_task_id = 1; rt.tasks_retired = 1;
  const FullOwnerSpec source{{Buffer::NORM, 0, 1}, 0, 2, 0, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  fill_owner(rt, source);
  const FullOwnerSpec output{{Buffer::TMP, 0, 1}, 0, 2, 0, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  assert(full_claim_owner(rt, output));

  FullWeightDescriptor descriptor;
  assert(full_lookup_weight({2, 0}, descriptor));
  LoadTask load;
  load.ctx = {2, Op::LOAD_W, 2, 0, 0, RowSpace::BATCH, 0, 1};
  load.kind = 0; load.dst = {Buffer::WEIGHT, 0, 1};
  load.weight = {2, 0}; load.head = 255;
  load.byte_count = ((uint32_t(descriptor.N) + 7u) & ~7u) *
                    (descriptor.K / 32u) * 34u;
  TaskDone done = succeeded(load.ctx.task_id, load.byte_count,
                            OutputUnit::BYTES);
  assert(commit_load(rt, descriptor, load, done));
  assert(rt.current_weight_ref == load.dst && rt.last_task_id == 2);

  for (unsigned window = 0; window < 4; ++window) {
    const uint16_t row0 = uint16_t(window * 16);
    QuantTask quant;
    quant.ctx = {uint32_t(3 + 2 * window), Op::QUANT, 2, 0, 0,
                 RowSpace::TOKEN, row0, 16};
    quant.src = source.ref; quant.a_dst = {Buffer::A8, 0,
                                           uint32_t(window + 1)};
    quant.K = 1024;
    done = succeeded(quant.ctx.task_id, 16u * 32u,
                     OutputUnit::Q8_GROUP);
    assert(commit_quant(rt, source, quant, done));
    LinearTask linear;
    linear.ctx = {uint32_t(4 + 2 * window), Op::LIN_WO, 2, 0, 0,
                  RowSpace::TOKEN, row0, 16};
    linear.a = quant.a_dst; linear.w = load.dst;
    linear.ps = {Buffer::PS, 0, uint32_t(window + 1)};
    linear.dst = output.ref; linear.weight = {2, 0};
    linear.K = 1024; linear.N = 1024;
    done = succeeded(linear.ctx.task_id, 16u * 1024u,
                     OutputUnit::F32);
    assert(commit_matrix(rt, output, nullptr, linear, done));
    if (window != 3) assert(!full_publish_owner(rt, output));
  }
  assert(full_publish_owner(rt, output));
  FullOwnerRecord snapshot;
  assert(full_owner_snapshot(rt, output.ref, 0, snapshot));
  assert(snapshot.valid && snapshot.state == CacheState::READY &&
         rt.last_task_id == 10 && rt.tasks_retired == 10);

  // A later failed parent cannot publish the partially covered next tensor.
  assert(full_release_owner(rt, output));
  FullOwnerSpec failed_output = output;
  failed_output.ref.epoch = 2;
  assert(full_claim_owner(rt, failed_output));
  for (unsigned window = 0; window < 2; ++window) {
    QuantTask quant;
    quant.ctx = {uint32_t(11 + 2 * window), Op::QUANT, 2, 0, 0,
                 RowSpace::TOKEN, uint16_t(window * 16), 16};
    quant.src = source.ref;
    quant.a_dst = {Buffer::A8, 0, uint32_t(5 + window)};
    quant.K = 1024;
    done = succeeded(quant.ctx.task_id, 16u * 32u,
                     OutputUnit::Q8_GROUP);
    assert(commit_quant(rt, source, quant, done));
    LinearTask linear;
    linear.ctx = {uint32_t(12 + 2 * window), Op::LIN_WO, 2, 0, 0,
                  RowSpace::TOKEN, uint16_t(window * 16), 16};
    linear.a = quant.a_dst; linear.w = load.dst;
    linear.ps = {Buffer::PS, 0, uint32_t(5 + window)};
    linear.dst = failed_output.ref; linear.weight = {2, 0};
    linear.K = 1024; linear.N = 1024;
    if (!window) {
      done = succeeded(linear.ctx.task_id, 16u * 1024u,
                       OutputUnit::F32);
      assert(commit_matrix(rt, failed_output, nullptr, linear, done));
    } else {
      done = TaskDone{};
      done.task_id = linear.ctx.task_id;
      done.status = Status::E_NUMERICAL;
      done.error_detail = laya::detail(7, uint8_t(Op::LIN_WO), 15);
      done.bad_element = 3; done.drained = true;
      const Check failure = commit_matrix(rt, failed_output, nullptr,
                                          linear, done);
      assert(failure.code == Status::E_NUMERICAL &&
             done.status == Status::E_NUMERICAL);
    }
  }
  assert(!full_publish_owner(rt, failed_output));
  assert(full_invalidate_owner(rt, failed_output.ref, 0));

  // GEGLU covers its physical GATE tensor window by window and never retires
  // a tensor-level publication after only one local success.
  const FullOwnerSpec wide{{Buffer::WI, 0, 1}, 0, 2, 0, 255,
                           RowSpace::TOKEN, 0, 64, 5248, Content::F32};
  fill_owner(rt, wide);
  const FullOwnerSpec gate{{Buffer::GATE, 0, 1}, 0, 2, 0, 255,
                           RowSpace::TOKEN, 0, 64, 2624, Content::F32};
  assert(full_claim_owner(rt, gate));
  for (unsigned window = 0; window < 4; ++window) {
    VectorTask task;
    task.ctx = {uint32_t(15 + window), Op::GEGLU, 2, 0, 0,
                RowSpace::TOKEN, uint16_t(window * 16), 16};
    task.src0 = wide.ref; task.dst = gate.ref; task.length = 2624;
    done = succeeded(task.ctx.task_id, 16u * 2624u, OutputUnit::F32);
    assert(commit_geglu(rt, wide, gate, task, done));
    if (window != 3) assert(!full_publish_owner(rt, gate));
  }
  assert(full_publish_owner(rt, gate));
  assert(rt.last_task_id == 18 && rt.tasks_retired == 18);

  std::cout << "FULL_CURRENT_PORTAL_COMMIT_PASS load_ready=1 quant_a_once=1 "
               "matrix_parent_once=1 tensor_parents=4 no_early_publish=1 "
               "later_failure_sticky=1 geglu_windows=4 typed_retired=17\n";
}

