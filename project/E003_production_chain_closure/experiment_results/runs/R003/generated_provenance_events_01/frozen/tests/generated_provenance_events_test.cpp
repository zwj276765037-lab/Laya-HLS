#include "laya_generated_provenance_events.h"
#include "laya_model_layout_generated.h"

#include <cstdlib>
#include <iostream>
#include <vector>

using namespace laya;

namespace {

unsigned checks = 0;

void require(bool condition, const char* message) {
  ++checks;
  if (!condition) {
    std::cerr << "FULL_CURRENT_GENERATED_PROVENANCE_EVENTS_FAIL "
              << message << '\n';
    std::exit(1);
  }
}

void expect(Check actual, Status expected, const char* message) {
  require(actual.code == expected, message);
}

NumericIdentity identity(uint64_t request_id) {
  NumericIdentity result;
  result.request_id = request_id;
  result.generation = 73;
  result.B = 1;
  result.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    result.model_tag[i] = full::kFullModelTag[i];
    result.numeric_tag[i] = full::kFullNumericTag[i];
    result.layout_tag[i] = full::kFullLayoutTag[i];
    result.build_tag[i] = full::kFullBuildTag[i];
  }
  return result;
}

full::FullOwnerSpec owner(BufferRef ref, uint8_t stage, uint8_t layer,
                          uint16_t width, Content content) {
  return {ref, 0, stage, layer, 255, RowSpace::TOKEN,
          0, 64, width, content};
}

TaskDone success(const TaskContext& context, uint32_t elements) {
  TaskDone done;
  done.task_id = context.task_id;
  done.output_elements = elements;
  done.output_unit = OutputUnit::F32;
  done.drained = true;
  return done;
}

void cover_and_publish_qkv(full::FullRuntime& rt,
                           const full::FullOwnerSpec (&pair)[2]) {
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      expect(full::full_cover_qkv(rt, pair, uint8_t(plane), uint8_t(head),
                                  0, 0, 64),
             Status::OK, "cover raw QKV plane/head");
  expect(full::full_publish_qkv_pair(rt, pair), Status::OK,
         "publish raw QKV pair");
}

} // namespace

int main() {
  constexpr uint64_t MB = 1024ull * 1024;
  static full::FullRuntime rt;
  std::vector<uint8_t> state0(17 * MB, 0);
  std::vector<uint8_t> qkv0(12 * MB, 0), qkv1(12 * MB, 0);
  std::vector<uint8_t> att(8 * MB, 0);
  rt.memory.state0 = state0.data();
  rt.memory.state0_bytes = state0.size();
  rt.memory.qkv0 = qkv0.data();
  rt.memory.qkv0_bytes = qkv0.size();
  rt.memory.qkv1 = qkv1.data();
  rt.memory.qkv1_bytes = qkv1.size();
  rt.memory.att_out = att.data();
  rt.memory.att_out_bytes = att.size();
  rt.inputs.identity = identity(901);
  rt.request_valid = true;
  rt.model_header_valid = true;

  portal::ModelBinding model;
  expect(portal::build_l13m_model_binding(model), Status::OK,
         "canonical L13M model binding");

  const full::FullOwnerSpec norm =
      owner({Buffer::NORM, 0, 1}, 2, 0, 1024, Content::F32);
  expect(full::full_claim_owner(rt, norm), Status::OK, "claim NORM owner");

  provenance::Request claim, publish;
  expect(provenance::build_owner_event(rt, rt.memory, model,
                                       provenance::Action::CLAIM,
                                       &norm, nullptr, 1, claim),
         Status::OK, "build CLAIM metadata");
  require(claim.action == provenance::Action::CLAIM &&
              claim.event_seq == 1 && claim.origin_seq == 0 &&
              claim.context.task_id == 0 && claim.descriptor_count == 1 &&
              claim.descriptor[0].target_ref == norm.ref &&
              claim.descriptor[0].role == Bo::STATE0 &&
              claim.descriptor[0].owner_base_offset == 8 * MB &&
              claim.descriptor[0].row_stride == 4096 &&
              claim.descriptor[0].batch_stride == 4 * MB,
          "CLAIM descriptor and metadata fields");
  expect(provenance::build_owner_event(rt, rt.memory, model,
                                       provenance::Action::PUBLISH,
                                       &norm, nullptr, 1, publish),
         Status::OK, "build PUBLISH metadata");
  require(publish.event_seq == 2 &&
              publish.action == provenance::Action::PUBLISH,
          "PUBLISH independent event sequence");

  LayerNormTask ln;
  ln.ctx = {1, Op::LN_ATTN, 2, 0, 0, RowSpace::TOKEN, 16, 16};
  ln.dst = norm.ref;
  provenance::Request ln_begin;
  bool protected_task = false;
  expect(provenance::build_generated_begin(rt, rt.memory, model, ln,
                                            16u * 1024u, OutputUnit::F32,
                                            ln_begin, protected_task),
         Status::OK, "build LN BEGIN");
  require(protected_task && ln_begin.event_seq == 3 &&
              ln_begin.origin_seq == 3 &&
              ln_begin.context.task_id == ln.ctx.task_id &&
              ln_begin.geometry[0].first_offset == 8 * MB + 16 * 4096 &&
              ln_begin.geometry[0].segment_bytes == 4096 &&
              ln_begin.geometry[0].row_count == 16 &&
              ln_begin.geometry[0].row_step == 4096 &&
              ln_begin.geometry[0].total_write_bytes == 16u * 4096u,
          "LN ordinary write geometry");

  const full::FullOwnerSpec attended =
      owner({Buffer::ATT_OUT, 0, 1}, 2, 0, 1024, Content::F32);
  expect(full::full_claim_owner(rt, attended), Status::OK,
         "claim ATT_OUT owner");
  AVTask av;
  av.ctx = {2, Op::AV, 2, 0, 0, RowSpace::TOKEN, 16, 16};
  av.dst = attended.ref;
  av.head = 3;
  provenance::Request av_begin;
  expect(provenance::build_generated_begin(rt, rt.memory, model, av,
                                            16u * 64u, OutputUnit::F32,
                                            av_begin, protected_task),
         Status::OK, "build AV BEGIN");
  require(protected_task && av_begin.event_seq == 4 &&
              av_begin.geometry[0].component ==
                  provenance::Component::ATT_HEAD &&
              av_begin.geometry[0].head == 3 &&
              av_begin.geometry[0].segment_bytes == 64u * 4u &&
              av_begin.geometry[0].first_offset ==
                  16u * 4096u + 3u * 64u * 4u &&
              av_begin.geometry[0].row_step == 4096,
          "AV head-only write geometry");

  full::FullOwnerSpec raw[2] = {
      owner({Buffer::QKV, 0, 1}, 2, 0, 64, Content::QKV_RAW),
      owner({Buffer::QKV, 1, 1}, 2, 0, 64, Content::QKV_RAW)};
  expect(full::full_claim_qkv_pair(rt, raw), Status::OK,
         "claim raw QKV pair");
  cover_and_publish_qkv(rt, raw);
  full::FullOwnerSpec final[2] = {raw[0], raw[1]};
  final[0].ref.epoch = 2;
  final[1].ref.epoch = 2;
  final[0].content = Content::QKV_FINAL;
  final[1].content = Content::QKV_FINAL;
  expect(full::full_begin_qkv_rope_pair(rt, raw, final), Status::OK,
         "begin QKV RoPE pair lease");

  RopeTask rope;
  rope.ctx = {3, Op::ROPE, 2, 0, 0, RowSpace::TOKEN, 16, 16};
  rope.src_qkv_ref = {raw[0].ref, raw[1].ref};
  rope.dst_qkv_ref = {final[0].ref, final[1].ref};
  rope.head = 3;
  provenance::Request rope_begin;
  expect(provenance::build_generated_begin(rt, rt.memory, model, rope,
                                            16u * 2u * 64u,
                                            OutputUnit::F32, rope_begin,
                                            protected_task),
         Status::OK, "build RoPE BEGIN");
  Address q_first, k_first;
  expect(qkv_address(0, 0, 3, 16, 0, 1, 64, q_first), Status::OK,
         "Q plane address");
  expect(qkv_address(1, 0, 3, 16, 0, 1, 64, k_first), Status::OK,
         "K plane address");
  require(protected_task && rope_begin.event_seq == 5 &&
              rope_begin.descriptor_count == 2 &&
              rope_begin.descriptor[0].target_ref == final[1].ref &&
              rope_begin.descriptor[1].target_ref == final[1].ref &&
              rope_begin.descriptor[0].old_ref == raw[1].ref &&
              rope_begin.descriptor[1].old_ref == raw[1].ref &&
              rope_begin.descriptor[0].role == Bo::QKV1 &&
              rope_begin.descriptor[1].role == Bo::QKV1 &&
              rope_begin.geometry[0].first_offset == q_first.offset &&
              rope_begin.geometry[1].first_offset == k_first.offset &&
              rope_begin.geometry[0].plane_mask == 1 &&
              rope_begin.geometry[1].plane_mask == 2 &&
              rope_begin.geometry[0].row_step == 64u * 4u &&
              rope_begin.geometry[1].row_step == 64u * 4u,
          "RoPE duplicated owner and Q/K geometries");

  expect(provenance::arm_generated_store_tracker(rt, rope_begin), Status::OK,
         "arm two-descriptor store tracker");
  expect(full::full_note_generated_store(
             rt, {Bo::QKV1, uint32_t(rope_begin.geometry[0].first_offset)}, 4),
         Status::OK, "account partial Q store");
  expect(full::full_note_generated_store(
             rt, {Bo::QKV1, uint32_t(rope_begin.geometry[1].first_offset)}, 4),
         Status::OK, "account partial K store");
  TaskDone rope_failure;
  rope_failure.task_id = rope.ctx.task_id;
  rope_failure.status = Status::E_NUMERICAL;
  rope_failure.error_detail = detail(7, uint8_t(Op::ROPE), 15);
  rope_failure.bad_element = 19;
  rope_failure.drained = true;
  provenance::Request rope_end;
  expect(provenance::build_generated_end(rt, rope_begin, rope_failure,
                                          rope_end),
         Status::OK, "build failed RoPE END with partial stores");
  require(rope_end.action == provenance::Action::END &&
              rope_end.origin_seq == rope_begin.event_seq &&
              rope_end.event_seq == 6 &&
              rope_end.reported_status == Status::E_NUMERICAL &&
              rope_end.reported_unit == OutputUnit::NONE &&
              rope_end.reported_elements == 0 &&
              rope_end.issued_store_bytes[0] == 4 &&
              rope_end.issued_store_bytes[1] == 4,
          "failed END preserves actual partial issued bytes");
  provenance::clear_generated_store_tracker(rt);

  expect(provenance::arm_generated_store_tracker(rt, ln_begin), Status::OK,
         "arm LN store tracker");
  const uint64_t before = ln_begin.geometry[0].first_offset - 4;
  expect(full::full_note_generated_store(rt, {Bo::STATE0, uint32_t(before)}, 4),
         Status::E_BUFFER, "reject store outside active geometry");
  provenance::Request rejected_end;
  const TaskDone ln_success = success(ln.ctx, 16u * 1024u);
  expect(provenance::build_generated_end(rt, ln_begin, ln_success,
                                          rejected_end),
         Status::E_BUFFER,
         "tracker error overrides a logically successful END");
  provenance::clear_generated_store_tracker(rt);

  full::FullRuntime retirement;
  retirement.defer_task_retirement = true;
  const TaskContext retirement_context{
      1, Op::LN_ATTN, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  TaskDone prepared;
  expect(full::full_finish_task(retirement, retirement_context, ok(),
                                OutputUnit::F32, 16u * 1024u, prepared),
         Status::OK, "prepare deferred typed retirement");
  require(retirement.last_task_id == 0 && retirement.tasks_retired == 0 &&
              prepared.drained,
          "logical completion does not retire before physical END");
  expect(full::full_retire_prepared_task(retirement, retirement_context,
                                          prepared),
         Status::OK, "retire prepared task once");
  require(retirement.last_task_id == 1 && retirement.tasks_retired == 1 &&
              retirement.op_calls[uint8_t(Op::LN_ATTN)] == 1,
          "physical completion retires exactly once");
  expect(full::full_retire_prepared_task(retirement, retirement_context,
                                          prepared),
         Status::E_PROTOCOL, "duplicate deferred retirement rejected");

  const uint64_t high_water = rt.provenance_event_high_water;
  require(high_water == 7, "failed END allocation consumes its event sequence");
  full::full_begin_request(rt);
  require(rt.provenance_event_high_water == high_water,
          "provenance event high-water survives request reset");

  std::cout << "FULL_CURRENT_GENERATED_PROVENANCE_EVENTS_PASS checks="
            << checks << " final_event_seq=" << high_water
            << " partial_store_bytes=8 retired_once=1\n";
  return 0;
}
