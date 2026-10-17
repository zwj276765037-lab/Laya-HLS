#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

#include <cassert>
#include <iostream>

using namespace laya;
using namespace laya::full;

namespace {

NumericIdentity identity(uint64_t request, uint16_t B = 1) {
  NumericIdentity id;
  id.request_id = request;
  id.generation = 73;
  id.B = B;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = kFullModelTag[i];
    id.numeric_tag[i] = kFullNumericTag[i];
    id.layout_tag[i] = kFullLayoutTag[i];
    id.build_tag[i] = kFullBuildTag[i];
  }
  return id;
}

void admit(FullRuntime& rt, uint64_t request, uint16_t B = 1) {
  rt.inputs.identity = identity(request, B);
  rt.request_valid = true;
  rt.model_header_valid = true;
}

TaskDone retire(FullRuntime& rt, const TaskContext& context,
                uint32_t elements) {
  assert(context.task_id == rt.last_task_id + 1);
  rt.last_task_id = context.task_id;
  ++rt.tasks_retired;
  ++rt.op_calls[uint8_t(context.op)];
  TaskDone done;
  done.task_id = context.task_id;
  done.output_elements = elements;
  done.output_unit = OutputUnit::F32;
  done.drained = true;
  return done;
}

void accept_att(FullRuntime& rt, const FullOwnerSpec& owner, uint8_t head,
                uint8_t batch, uint16_t row0, uint32_t& next_id) {
  const TaskContext context{next_id++, Op::AV, 2, 0, batch,
                            RowSpace::TOKEN, row0, 16};
  assert(full_cover_att_head(rt, owner, head, batch, row0, 16));
  const TaskDone done = retire(rt, context, 16u * 64u);
  assert(full_source_accept_completion(rt, owner.ref, owner.region, context,
                                       head, UINT16_MAX, done,
                                       16u * 64u, OutputUnit::F32));
}

void accept_full(FullRuntime& rt, const FullOwnerSpec& owner,
                 Op op, uint8_t stage, uint8_t layer,
                 uint8_t batch, uint16_t row0, uint32_t& next_id,
                 TaskContext* saved = nullptr) {
  const TaskContext context{next_id++, op, stage, layer, batch,
                            owner.row_space, row0, 16};
  assert(full_cover_owner(rt, owner, batch, row0, 16));
  const TaskDone done = retire(rt, context, 16u * owner.width);
  assert(full_source_accept_completion(rt, owner.ref, owner.region, context,
                                       0, 1, done, 16u * owner.width,
                                       OutputUnit::F32));
  if (saved) *saved = context;
}

void attention_b1() {
  static FullRuntime rt;
  admit(rt, 101);
  const FullOwnerSpec att{{Buffer::ATT_OUT, 0, 1}, 0, 2, 0, 255,
                          RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  assert(full_claim_owner(rt, att));
  uint32_t next_id = 1;
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned row = 0; row < 64; row += 16)
      accept_att(rt, att, uint8_t(head), 0, uint16_t(row), next_id);

  TaskContext close;
  assert(!full_source_query(rt, att, 0, 0, 16, close));
  SourceProvenanceRecord snapshot;
  assert(full_source_snapshot(rt, att, snapshot));
  assert(!snapshot.published && snapshot.required_mask == UINT16_MAX);
  for (unsigned window = 0; window < 4; ++window) {
    assert(snapshot.window[window].close_valid);
    assert(snapshot.window[window].close_context.task_id == 61 + window);
    assert(snapshot.window[window].close_context.op == Op::AV);
  }
  assert(full_publish_att(rt, att));
  for (unsigned window = 0; window < 4; ++window) {
    assert(full_source_query(rt, att, 0, uint16_t(window * 16), 16, close));
    assert(close.task_id == 61 + window && close.row0 == window * 16);
  }
  const TaskContext duplicate{64, Op::AV, 2, 0, 0,
                              RowSpace::TOKEN, 48, 16};
  TaskDone duplicate_done;
  duplicate_done.task_id = 64;
  duplicate_done.output_elements = 16u * 64u;
  duplicate_done.output_unit = OutputUnit::F32;
  duplicate_done.drained = true;
  assert(!full_source_accept_completion(rt, att.ref, 0, duplicate, 15,
                                        UINT16_MAX, duplicate_done,
                                        16u * 64u, OutputUnit::F32));
  assert(!full_cover_att_head(rt, att, 15, 0, 48, 16));
  assert(full_release_owner(rt, att));

  FullOwnerSpec missing = att;
  missing.ref.epoch = 2;
  assert(full_claim_owner(rt, missing));
  for (unsigned head = 0; head < 15; ++head)
    for (unsigned row = 0; row < 64; row += 16)
      accept_att(rt, missing, uint8_t(head), 0, uint16_t(row), next_id);
  assert(!full_publish_att(rt, missing));
  assert(full_source_snapshot(rt, missing, snapshot));
  assert(!snapshot.published);
  assert(full_invalidate_owner(rt, missing.ref, 0));
}

void attention_b2() {
  static FullRuntime rt;
  admit(rt, 102, 2);
  const FullOwnerSpec att{{Buffer::ATT_OUT, 0, 1}, 0, 2, 0, 255,
                          RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  assert(full_claim_owner(rt, att));
  uint32_t next_id = 1;
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned batch = 0; batch < 2; ++batch)
      for (unsigned row = 0; row < 64; row += 16)
        accept_att(rt, att, uint8_t(head), uint8_t(batch),
                   uint16_t(row), next_id);
  assert(full_publish_att(rt, att));
  bool seen[129] = {};
  for (unsigned batch = 0; batch < 2; ++batch)
    for (unsigned window = 0; window < 4; ++window) {
      TaskContext close;
      assert(full_source_query(rt, att, uint8_t(batch),
                               uint16_t(window * 16), 16, close));
      assert(close.task_id >= 121 && close.task_id <= 128 &&
             !seen[close.task_id] && close.batch == batch &&
             close.row0 == window * 16);
      seen[close.task_id] = true;
    }
}

void ordinary_and_old_lease() {
  static FullRuntime rt;
  admit(rt, 103);
  const FullOwnerSpec norm{{Buffer::NORM, 0, 1}, 0, 1, 255, 255,
                           RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  assert(full_claim_owner(rt, norm));
  uint32_t next_id = 1;
  TaskContext expected[4];
  for (unsigned row = 0; row < 64; row += 16)
    accept_full(rt, norm, Op::LN_EMB, 1, 255, 0, uint16_t(row), next_id,
                &expected[row / 16]);
  TaskContext close;
  assert(!full_source_query(rt, norm, 0, 0, 16, close));
  assert(full_publish_owner(rt, norm));
  for (unsigned window = 0; window < 4; ++window) {
    assert(full_source_query(rt, norm, 0, uint16_t(window * 16), 16, close));
    assert(close.task_id == expected[window].task_id &&
           close.stage == 1 && close.layer == 255);
    TaskContext second;
    assert(full_source_query(rt, norm, 0, uint16_t(window * 16), 16, second));
    assert(second.task_id == close.task_id);
  }
  ++rt.inputs.identity.request_id;
  assert(!full_source_query(rt, norm, 0, 0, 16, close));
  --rt.inputs.identity.request_id;

  const FullOwnerSpec old{{Buffer::DEC_FF, 0, 1}, 0, 4, 0, 255,
                          RowSpace::TOKEN, 0, 64, 4096, Content::F32};
  assert(full_claim_owner(rt, old));
  for (unsigned row = 0; row < 64; row += 16)
    accept_full(rt, old, Op::LIN_DEC_FC1, 4, 0, 0,
                uint16_t(row), next_id);
  assert(full_publish_owner(rt, old));
  FullOwnerSpec next = old;
  next.ref.epoch = 2;
  assert(full_begin_inplace_owner(rt, old, next));
  assert(full_source_query(rt, old, 0, 0, 16, close));
  assert(full_consume_inplace_rows(rt, next, 0, 0, 16));
  assert(!full_source_query(rt, old, 0, 0, 16, close));
  assert(full_invalidate_owner(rt, next.ref, next.region));
}

void failed_completion() {
  static FullRuntime rt;
  admit(rt, 104);
  const FullOwnerSpec source{{Buffer::TMP, 0, 1}, 0, 2, 0, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  assert(full_claim_owner(rt, source));
  const TaskContext context{1, Op::LIN_WO, 2, 0, 0,
                            RowSpace::TOKEN, 0, 16};
  assert(full_cover_owner(rt, source, 0, 0, 16));
  TaskDone done = retire(rt, context, 16u * 1024u);
  done.status = Status::E_NUMERICAL;
  done.error_detail = detail(7, uint8_t(Op::LIN_WO), 15);
  done.bad_element = 7;
  done.output_elements = 0;
  done.output_unit = OutputUnit::NONE;
  assert(!full_source_accept_completion(rt, source.ref, 0, context, 0, 1,
                                        done, 16u * 1024u,
                                        OutputUnit::F32));
  SourceProvenanceRecord snapshot;
  assert(full_source_snapshot(rt, source, snapshot));
  assert(!snapshot.window[0].close_valid &&
         snapshot.window[0].component_mask == 0);
}

} // namespace

int main() {
  attention_b1();
  attention_b2();
  ordinary_and_old_lease();
  failed_completion();
  std::cout << "FULL_CURRENT_SOURCE_PROVENANCE_PASS "
               "att_b1_windows=4 att_b2_windows=8 heads=16 "
               "early_publish_rejected=1 missing_head_rejected=1 "
               "duplicate_rejected=1 cross_request_rejected=1 "
               "readonly_multi_consumer=1 old_lease_once=1 "
               "failed_completion_ignored=1\n";
}
