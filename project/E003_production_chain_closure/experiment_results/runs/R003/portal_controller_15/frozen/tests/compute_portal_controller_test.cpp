#include "laya_compute_portal_controller.h"
#include "laya_model_layout_generated.h"

#include <cassert>
#include <iostream>
#include <vector>

using namespace laya;
using namespace laya::full;
using namespace laya::portal;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 31;
  id.generation = 47;
  id.B = 1;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = kFullModelTag[i];
    id.numeric_tag[i] = kFullNumericTag[i];
    id.layout_tag[i] = kFullLayoutTag[i];
    id.build_tag[i] = kFullBuildTag[i];
  }
  return id;
}

FullMemory memory() {
  static uint8_t byte = 0;
  FullMemory m;
  m.embedding = &byte; m.embedding_bytes = kFullModelBoSizes[0];
  m.io = &byte; m.io_bytes = 32768;
  m.w_q0 = &byte; m.w_q0_bytes = kFullModelBoSizes[1];
  m.w_q1 = &byte; m.w_q1_bytes = kFullModelBoSizes[2];
  m.w_scale = &byte; m.w_scale_bytes = kFullModelBoSizes[3];
  m.aux = &byte; m.aux_bytes = kFullModelBoSizes[4];
  m.state0 = &byte; m.state0_bytes = 16920576;
  m.state1 = &byte; m.state1_bytes = 16919104;
  m.qkv0 = &byte; m.qkv0_bytes = 12u * 1024u * 1024u;
  m.qkv1 = &byte; m.qkv1_bytes = 12u * 1024u * 1024u;
  m.ff0 = &byte; m.ff0_bytes = 41u * 1024u * 1024u;
  m.ff1 = &byte; m.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  m.att_out = &byte; m.att_out_bytes = 8u * 1024u * 1024u;
  return m;
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

TaskDone retired(FullRuntime& rt, const TaskContext& context,
                 uint32_t elements, OutputUnit unit) {
  assert(context.task_id == rt.last_task_id + 1);
  rt.last_task_id = context.task_id;
  ++rt.tasks_retired;
  ++rt.op_calls[uint8_t(context.op)];
  TaskDone done;
  done.task_id = context.task_id;
  done.output_elements = elements;
  done.output_unit = unit;
  done.drained = true;
  return done;
}

void produce_norm_source(FullRuntime& rt, const FullOwnerSpec& source,
                         TaskContext (&producer)[4]) {
  assert(full_claim_owner(rt, source));
  for (unsigned window = 0; window < 4; ++window) {
    producer[window] = {uint32_t(window + 1), Op::LN_EMB, 1, 255, 0,
                        RowSpace::TOKEN, uint16_t(window * 16), 16};
    assert(full_cover_owner(rt, source, 0, uint16_t(window * 16), 16));
    const TaskDone done = retired(rt, producer[window], 16u * 1024u,
                                  OutputUnit::F32);
    assert(full_source_accept_completion(rt, source.ref, source.region,
                                         producer[window], 0, 1, done,
                                         16u * 1024u, OutputUnit::F32));
  }
  TaskContext unavailable;
  assert(!full_source_query(rt, source, 0, 0, 16, unavailable));
  assert(full_publish_owner(rt, source));
}

Response success(const Command& command) {
  Response response;
  response.status = Status::OK;
  response.service = command.service;
  response.rows = command.rows;
  response.row_block = command.row_block;
  response.generation = command.generation;
  response.task_id = command.context.task_id;
  response.drained = true;
  response.published = true;
  if (command.service == Service::LOAD_W) {
    response.output_elements = ((uint32_t(command.N) + 7u) & ~7u) *
                               (command.K / 32u) * 34u;
    response.unit = OutputUnit::BYTES;
  } else if (command.service == Service::QUANT) {
    response.output_elements = uint32_t(command.rows) * command.K / 32u;
    response.unit = OutputUnit::Q8_GROUP;
  } else if (command.service == Service::MATRIX) {
    response.output_elements = uint32_t(command.rows) * command.N;
    response.unit = OutputUnit::F32;
  } else {
    response.output_elements = uint32_t(command.rows) * command.K;
    response.unit = OutputUnit::F32;
  }
  response.identity = command.identity;
  response.context = command.context;
  response.producer_context = command.producer_context;
  response.quant_context = command.quant_context;
  response.linear_context = command.linear_context;
  response.source = command.source;
  response.a = command.a;
  response.w = command.w;
  response.ps = command.ps;
  response.dst = command.dst;
  response.future_dst = command.future_dst;
  response.source_region = command.source_region;
  response.dst_region = command.dst_region;
  response.future_dst_region = command.future_dst_region;
  response.a_epoch = command.a_epoch;
  response.w_epoch = command.w_epoch;
  return response;
}

ap_uint<512> pack(const Word512& word) {
  ap_uint<512> packed = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    packed.range(byte * 8 + 7, byte * 8) = word.byte[byte];
  return packed;
}

void queue(hls::stream<ap_uint<512>>& responses,
           std::vector<Word512>& expected, const Command& command) {
  for (const Word512& word : command_words(encode(command)))
    expected.push_back(word);
  for (const Word512& word : response_words(encode(success(command))))
    responses.write(pack(word));
}

void compare_commands(hls::stream<ap_uint<512>>& commands,
                      const std::vector<Word512>& expected) {
  assert(commands.size() == expected.size());
  for (const Word512& word : expected) {
    const ap_uint<512> actual = commands.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      assert(uint8_t(actual.range(byte * 8 + 7, byte * 8)) ==
             word.byte[byte]);
  }
  assert(commands.empty());
}

provenance::Response provenance_success(
    const provenance::Request& request) {
  provenance::Response response;
  response.action = request.action;
  response.event_seq = request.event_seq;
  response.origin_seq = request.origin_seq;
  response.status = Status::OK;
  response.bad_element = UINT64_MAX;
  response.drained = true;
  response.scope_active = request.action == provenance::Action::BEGIN;
  response.owner_published = request.action == provenance::Action::PUBLISH;
  response.descriptor_count = request.descriptor_count;
  response.identity = request.identity;
  response.context = request.context;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    response.target_ref[i] = request.descriptor[i].target_ref;
    response.target_region[i] = request.descriptor[i].target_region;
    response.old_ref[i] = request.descriptor[i].old_ref;
    response.old_region[i] = request.descriptor[i].old_region;
    if (request.action == provenance::Action::END)
      response.observed_store_bytes[i] = request.issued_store_bytes[i];
  }
  if (request.action == provenance::Action::END) {
    response.output_elements = request.expected_elements;
    response.unit = request.expected_unit;
  }
  return response;
}

ap_uint<512> pack_provenance(const provenance::Word512& word) {
  ap_uint<512> packed = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    packed.range(byte * 8 + 7, byte * 8) = word.byte[byte];
  return packed;
}

void queue_provenance(hls::stream<ap_uint<512>>& responses,
                      const provenance::Request& request) {
  for (const provenance::Word512& word : provenance::response_words(
           provenance::encode(provenance_success(request))))
    responses.write(pack_provenance(word));
}

void compare_provenance_commands(
    hls::stream<ap_uint<512>>& commands,
    const provenance::Request& begin, const provenance::Request& end) {
  const provenance::Request expected[2] = {begin, end};
  for (const provenance::Request& request : expected)
    for (const provenance::Word512& word : provenance::request_words(
             provenance::encode(request))) {
      assert(!commands.empty());
      const ap_uint<512> actual = commands.read();
      for (unsigned byte = 0; byte < 64; ++byte)
        assert(uint8_t(actual.range(byte * 8 + 7, byte * 8)) ==
               word.byte[byte]);
    }
  assert(commands.empty());
}

} // namespace

int main() {
  static FullRuntime rt;
  rt.inputs.identity = identity();
  rt.request_valid = true;
  rt.model_header_valid = true;
  FullMemory mem = memory();

  const FullOwnerSpec wide{{Buffer::WI, 0, 1}, 0, 2, 0, 255,
                           RowSpace::TOKEN, 0, 64, 5248, Content::F32};
  fill_owner(rt, wide);

  TaskReservation reservations = rt.dispatch_reservations;
  PortalReservation portal_generations = rt.portal_reservations;
  GDownPlan expected_plan;
  assert(reserve_g_down(reservations, portal_generations, rt.last_task_id,
                        rt.inputs.identity, 0, wide.ref,
                        {Buffer::GATE, 0, 1}, {Buffer::TMP, 0, 1},
                        0, 0, 0, 0, expected_plan));
  assert(expected_plan.count == 4);

  ModelBinding model;
  assert(build_l13m_model_binding(model));
  FullWeightDescriptor descriptor;
  assert(full_lookup_weight(expected_plan.load.weight, descriptor));

  hls::stream<ap_uint<512>> commands, responses;
  std::vector<Word512> expected_words;
  Command command;
  for (unsigned window = 0; window < expected_plan.count; ++window) {
    const GDownWindow& record = expected_plan.window[window];
    const TaskBinding binding{record.producer.ctx,
                              record.quant, record.linear};
    assert(build_geglu_command(rt.inputs.identity, mem, model,
                               record.producer, binding,
                               record.producer_generation, command));
    queue(responses, expected_words, command);
  }
  assert(build_load_command(rt.inputs.identity, mem, model, descriptor,
                            expected_plan.load,
                            expected_plan.load_generation, command));
  queue(responses, expected_words, command);
  for (unsigned window = 0; window < expected_plan.count; ++window) {
    const GDownWindow& record = expected_plan.window[window];
    const TaskBinding binding{record.producer.ctx,
                              record.quant, record.linear};
    assert(build_quant_command(rt.inputs.identity, mem, model, binding,
                               record.quant_generation, command));
    queue(responses, expected_words, command);
    for (unsigned view = 0; view < record.views; ++view) {
      assert(build_matrix_command(rt.inputs.identity, mem, model, binding,
                                  record.view[view], command));
      queue(responses, expected_words, command);
    }
  }
  assert(expected_words.size() == 25u * kCommandBeats);
  assert(responses.size() == 25u * kResponseBeats);

  FullOwnerSpec down;
  assert(full_execute_g_down_portal(rt, mem, wide, 0,
                                    commands, responses, down));
  assert(responses.empty());
  compare_commands(commands, expected_words);
  const BufferRef expected_down{Buffer::TMP, 0, 1};
  assert(down.ref == expected_down &&
         down.rows == 64 && down.width == 1024 &&
         down.content == Content::F32);
  assert(rt.last_task_id == 13 && rt.tasks_retired == 13);
  assert(rt.op_calls[uint8_t(Op::GEGLU)] == 4 &&
         rt.op_calls[uint8_t(Op::LOAD_W)] == 1 &&
         rt.op_calls[uint8_t(Op::QUANT)] == 4 &&
         rt.op_calls[uint8_t(Op::LIN_DOWN)] == 4);

  FullOwnerRecord owner;
  assert(full_owner_snapshot(rt, wide.ref, wide.region, owner));
  assert(!owner.valid && owner.state == CacheState::FREE);
  assert(full_owner_snapshot(rt, {Buffer::GATE, 0, 1}, 0, owner));
  assert(!owner.valid && owner.state == CacheState::FREE);
  assert(full_owner_snapshot(rt, down.ref, down.region, owner));
  assert(owner.valid && owner.state == CacheState::READY);
  assert(full_owner_snapshot(rt, expected_plan.load.dst, 0, owner));
  assert(owner.valid && owner.state == CacheState::READY);
  assert(!rt.cache.activation_meta.valid &&
         rt.cache.activation_meta.state == CacheState::FREE);
  assert(!rt.g_down_plan.valid && !rt.dispatch_binding.valid);

  static FullRuntime ordinary_rt;
  ordinary_rt.inputs.identity = identity();
  ordinary_rt.inputs.identity.request_id = 32;
  ordinary_rt.request_valid = true;
  ordinary_rt.model_header_valid = true;
  const FullOwnerSpec norm{{Buffer::NORM, 0, 1}, 0, 1, 255, 255,
                           RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  TaskContext producer[4];
  produce_norm_source(ordinary_rt, norm, producer);

  TaskReservation task_tickets = ordinary_rt.dispatch_reservations;
  PortalReservation portal_tickets = ordinary_rt.portal_reservations;
  const uint32_t committed = ordinary_rt.last_task_id;
  FullWeightDescriptor wi_descriptor;
  assert(full_lookup_weight({3, 0}, wi_descriptor));
  LoadTask load;
  load.ctx = task_tickets.context(committed, Op::LOAD_W, 2, 0, 0,
                                  RowSpace::BATCH, 0, 1);
  load.dst = task_tickets.ref(Buffer::WEIGHT, 0, 0, 0);
  load.weight = {3, 0};
  load.head = 255;
  load.byte_count = ((uint32_t(wi_descriptor.N) + 7u) & ~7u) *
                    (wi_descriptor.K / 32u) * 34u;
  const uint64_t load_generation = portal_tickets.next();

  hls::stream<ap_uint<512>> ordinary_commands, ordinary_responses;
  std::vector<Word512> ordinary_expected;
  ModelBinding ordinary_model;
  assert(build_l13m_model_binding(ordinary_model));
  assert(build_load_command(ordinary_rt.inputs.identity, mem, ordinary_model,
                            wi_descriptor, load, load_generation, command));
  queue(ordinary_responses, ordinary_expected, command);
  TaskContext expected_linear[4];
  for (unsigned window = 0; window < 4; ++window) {
    QuantTask quant;
    quant.ctx = task_tickets.context(committed, Op::QUANT, 2, 0, 0,
                                     RowSpace::TOKEN,
                                     uint16_t(window * 16), 16);
    quant.src = norm.ref;
    quant.a_dst = task_tickets.ref(Buffer::A8, 0, 0, 0);
    quant.K = wi_descriptor.K;
    LinearTask linear;
    linear.ctx = task_tickets.context(committed, Op::LIN_WI, 2, 0, 0,
                                      RowSpace::TOKEN,
                                      uint16_t(window * 16), 16);
    linear.a = quant.a_dst;
    linear.w = load.dst;
    linear.ps = task_tickets.ref(Buffer::PS, 0, 0, 0);
    linear.dst = {Buffer::WI, 0, 1};
    linear.weight = {3, 0};
    linear.K = wi_descriptor.K;
    linear.N = wi_descriptor.N;
    linear.bias_kind = wi_descriptor.bias_kind;
    const TaskBinding binding{producer[window], quant, linear};
    const uint64_t quant_generation = portal_tickets.next();
    assert(build_quant_command(ordinary_rt.inputs.identity, mem,
                               ordinary_model, binding, quant_generation,
                               command));
    queue(ordinary_responses, ordinary_expected, command);
    ViewTicket views[kMatrixViews];
    uint8_t view_count = 0;
    assert(reserve_views(portal_tickets, 16, views, view_count));
    assert(view_count == 4);
    for (unsigned view = 0; view < view_count; ++view) {
      assert(build_matrix_command(ordinary_rt.inputs.identity, mem,
                                  ordinary_model, binding, views[view],
                                  command));
      queue(ordinary_responses, ordinary_expected, command);
    }
    expected_linear[window] = linear.ctx;
  }
  assert(ordinary_expected.size() == 21u * kCommandBeats);
  assert(ordinary_responses.size() == 21u * kResponseBeats);
  FullOwnerSpec wi;
  assert(full_execute_linear_portal(
      ordinary_rt, mem, norm, Op::LIN_WI, {3, 0}, 2, 0,
      {Buffer::WI, 0, 1}, 0, ordinary_commands, ordinary_responses, wi));
  assert(ordinary_responses.empty());
  compare_commands(ordinary_commands, ordinary_expected);
  for (unsigned window = 0; window < 4; ++window) {
    TaskContext close;
    assert(full_source_query(ordinary_rt, wi, 0, uint16_t(window * 16),
                             16, close));
    assert(close.task_id == expected_linear[window].task_id &&
           close.op == Op::LIN_WI && close.row0 == window * 16);
  }
  assert(ordinary_rt.last_task_id == 13 &&
         ordinary_rt.tasks_retired == 13 &&
         ordinary_rt.op_calls[uint8_t(Op::LN_EMB)] == 4 &&
         ordinary_rt.op_calls[uint8_t(Op::LOAD_W)] == 1 &&
         ordinary_rt.op_calls[uint8_t(Op::QUANT)] == 4 &&
         ordinary_rt.op_calls[uint8_t(Op::LIN_WI)] == 4 &&
         !ordinary_rt.dispatch_binding.valid);
  assert(ordinary_rt.cache.activation_meta.source_context.task_id ==
             producer[3].task_id &&
         ordinary_rt.cache.activation_meta.quant_context.task_id + 1 ==
             expected_linear[3].task_id);

  static FullRuntime generated_rt;
  generated_rt.inputs.identity = identity();
  generated_rt.inputs.identity.request_id = 33;
  generated_rt.request_valid = true;
  generated_rt.model_header_valid = true;
  static std::vector<uint8_t> generated_state0(17u * 1024u * 1024u, 0);
  static std::vector<uint8_t> generated_state1(17u * 1024u * 1024u, 0);
  FullMemory generated_memory = memory();
  generated_memory.state0 = generated_state0.data();
  generated_memory.state0_bytes = generated_state0.size();
  generated_memory.state1 = generated_state1.data();
  generated_memory.state1_bytes = generated_state1.size();
  const FullOwnerSpec add_left{{Buffer::TMP, 0, 1}, 0, 2, 0, 255,
                               RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  const FullOwnerSpec add_right{{Buffer::HIDDEN, 0, 1}, 0, 2, 0, 255,
                                RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  const FullOwnerSpec add_output{{Buffer::HIDDEN, 1, 1}, 0, 2, 0, 255,
                                 RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  fill_owner(generated_rt, add_left);
  fill_owner(generated_rt, add_right);
  assert(full_claim_owner(generated_rt, add_output));
  VectorTask add;
  add.ctx = {1, Op::ADD_RESIDUAL, 2, 0, 0,
             RowSpace::TOKEN, 0, 1};
  add.src0 = add_left.ref;
  add.src1 = add_right.ref;
  add.dst = add_output.ref;
  add.length = 1024;
  ModelBinding generated_model;
  assert(build_l13m_model_binding(generated_model));
  provenance::Request add_begin;
  bool generated_protected = false;
  assert(provenance::build_generated_begin(
      generated_rt, generated_memory, generated_model, add, 1024,
      OutputUnit::F32, add_begin, generated_protected));
  assert(generated_protected && add_begin.event_seq == 1);
  provenance::Request add_end = add_begin;
  add_end.action = provenance::Action::END;
  add_end.event_seq = 2;
  add_end.origin_seq = add_begin.event_seq;
  add_end.reported_status = Status::OK;
  add_end.reported_unit = OutputUnit::F32;
  add_end.reported_elements = 1024;
  add_end.reported_bad_element = UINT64_MAX;
  add_end.issued_store_bytes[0] = 1024u * 4u;
  generated_rt.provenance_event_high_water = 0;
  hls::stream<ap_uint<512>> provenance_commands, provenance_responses;
  queue_provenance(provenance_responses, add_begin);
  queue_provenance(provenance_responses, add_end);
  assert(full_execute_generated_vector_portal(
      generated_rt, generated_memory, add_left, add_right, add, 1024,
      provenance_commands, provenance_responses));
  assert(provenance_responses.empty());
  compare_provenance_commands(provenance_commands, add_begin, add_end);
  assert(generated_rt.provenance_event_high_water == 2 &&
         generated_rt.last_task_id == 1 &&
         generated_rt.tasks_retired == 1 &&
         generated_rt.op_calls[uint8_t(Op::ADD_RESIDUAL)] == 1 &&
         !generated_rt.defer_task_retirement &&
         !generated_rt.generated_store.active);
  SourceProvenanceRecord add_provenance;
  assert(full_source_snapshot(generated_rt, add_output, add_provenance));
  assert(add_provenance.window[0].close_valid &&
         add_provenance.window[0].close_context.task_id == 1 &&
         add_provenance.window[0].close_context.op == Op::ADD_RESIDUAL);

  std::cout << "FULL_CURRENT_PORTAL_CONTROLLER_PASS B=1 S=64 "
               "windows=4 portal_commands=25 command_beats=400 "
               "response_beats=200 typed_tasks=13 geglu=4 load=1 quant=4 "
               "linear_parents=4 matrix_views=16 full_tensor_ready=1 "
               "wi_released=1 gate_released=1 weight_ready=1 a_released=1 "
               "ordinary_p_windows=4 ordinary_portal_commands=21 "
               "ordinary_p_cross_stage=1 ordinary_parent_ready=1 "
               "a_provenance_frozen=1 generated_provenance_events=2 "
               "generated_store_bytes=4096 deferred_retirement_once=1\n";
}
