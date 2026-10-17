#include "laya_compute_portal_dispatch.h"
#include "laya_model_layout_generated.h"
#include <cassert>
#include <iostream>

using namespace laya;
using namespace laya::portal;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 1; id.generation = 2; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(1 + i);
    id.numeric_tag[i] = uint8_t(17 + i);
    id.layout_tag[i] = uint8_t(33 + i);
    id.build_tag[i] = uint8_t(49 + i);
  }
  return id;
}

NumericIdentity canonical_identity() {
  NumericIdentity id;
  id.request_id = 9; id.generation = 17; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = full::kFullModelTag[i];
    id.numeric_tag[i] = full::kFullNumericTag[i];
    id.layout_tag[i] = full::kFullLayoutTag[i];
    id.build_tag[i] = full::kFullBuildTag[i];
  }
  return id;
}

full::FullMemory memory() {
  static uint8_t byte = 0;
  full::FullMemory m;
  m.embedding = &byte; m.embedding_bytes = full::kFullModelBoSizes[0];
  m.io = &byte; m.io_bytes = 32768;
  m.w_q0 = &byte; m.w_q0_bytes = full::kFullModelBoSizes[1];
  m.w_q1 = &byte; m.w_q1_bytes = full::kFullModelBoSizes[2];
  m.w_scale = &byte; m.w_scale_bytes = full::kFullModelBoSizes[3];
  m.aux = &byte; m.aux_bytes = full::kFullModelBoSizes[4];
  m.state0 = &byte; m.state0_bytes = 16920576;
  m.state1 = &byte; m.state1_bytes = 16919104;
  m.qkv0 = &byte; m.qkv0_bytes = 12u * 1024u * 1024u;
  m.qkv1 = &byte; m.qkv1_bytes = 12u * 1024u * 1024u;
  m.ff0 = &byte; m.ff0_bytes = 41u * 1024u * 1024u;
  m.ff1 = &byte; m.ff1_bytes = 21u * 1024u * 1024u - 512u * 1024u;
  m.att_out = &byte; m.att_out_bytes = 8u * 1024u * 1024u;
  return m;
}

Command command() {
  Command c;
  c.service = Service::MATRIX; c.generation = 9; c.identity = identity();
  c.context = {3, Op::LIN_DOWN, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.producer_context = {1, Op::GEGLU, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.quant_context = {2, Op::QUANT, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.linear_context = c.context;
  c.source = {Buffer::GATE, 0, 1}; c.a = {Buffer::A8, 0, 1};
  c.w = {Buffer::WEIGHT, 0, 1}; c.ps = {Buffer::PS, 0, 1};
  c.dst = {Buffer::TMP, 0, 1}; c.future_dst = c.dst;
  c.K = 2624; c.N = 1024; c.rows = 4; c.row_block = 0;
  c.a_epoch = 1; c.w_epoch = 1; c.weight_key = 4;
  c.output_role[0] = Bo::STATE1;
  c.output[0] = {16919104, 8388608, 8388608};
  c.row_stride = 4096; c.batch_stride = 4194304;
  for (unsigned i = 0; i < c.model_identity.size(); ++i)
    c.model_identity[i] = uint8_t(i * 13u + 5u);
  return c;
}

Response success(const Command& c) {
  Response r;
  r.status = Status::OK; r.service = c.service; r.rows = c.rows;
  r.row_block = c.row_block; r.generation = c.generation;
  r.task_id = c.context.task_id; r.drained = true; r.published = true;
  if (c.service == Service::LOAD_W) {
    r.output_elements = ((uint32_t(c.N) + 7u) & ~7u) *
                        (c.K / 32u) * 34u;
    r.unit = OutputUnit::BYTES;
  } else if (c.service == Service::QUANT) {
    r.output_elements = uint32_t(c.rows) * c.K / 32u;
    r.unit = OutputUnit::Q8_GROUP;
  } else if (c.service == Service::MATRIX) {
    r.output_elements = uint32_t(c.rows) * c.N;
    r.unit = OutputUnit::F32;
  } else {
    r.output_elements = uint32_t(c.rows) * c.K;
    r.unit = OutputUnit::F32;
  }
  r.identity = c.identity; r.context = c.context;
  r.producer_context = c.producer_context; r.quant_context = c.quant_context;
  r.linear_context = c.linear_context; r.source = c.source; r.a = c.a;
  r.w = c.w; r.ps = c.ps; r.dst = c.dst; r.future_dst = c.future_dst;
  r.a_epoch = c.a_epoch; r.w_epoch = c.w_epoch;
  return r;
}

ap_uint<512> pack(const Word512& word) {
  ap_uint<512> result = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    result.range(byte * 8 + 7, byte * 8) = word.byte[byte];
  return result;
}

void push_response(hls::stream<ap_uint<512>>& stream, const Response& response) {
  for (const Word512& word : response_words(encode(response)))
    stream.write(pack(word));
}

void drain_commands(hls::stream<ap_uint<512>>& stream, unsigned beats) {
  assert(stream.size() == beats);
  for (unsigned i = 0; i < beats; ++i) (void)stream.read();
  assert(stream.empty());
}

} // namespace

int main() {
  const Command expected = command();
  const CommandWords expected_words = command_words(encode(expected));
  hls::stream<ap_uint<512>> command_stream, response_stream;
  const ResponseWords response = response_words(encode(success(expected)));
  for (const Word512& word : response) response_stream.write(pack(word));

  Response decoded;
  assert(exchange(command_stream, response_stream, expected, decoded));
  assert(command_stream.size() == kCommandBeats && response_stream.empty());
  for (const Word512& word : expected_words) {
    const ap_uint<512> actual = command_stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      assert(uint8_t(actual.range(byte * 8 + 7, byte * 8)) == word.byte[byte]);
  }
  assert(command_stream.empty() && decoded.generation == expected.generation);

  const NumericIdentity id = canonical_identity();
  const full::FullMemory mem = memory();
  ModelBinding model;
  assert(build_l13m_model_binding(model));
  full::TaskReservation reservations;
  full::PortalReservation portal_generations;
  full::GDownPlan plan;
  assert(full::reserve_g_down(reservations, portal_generations, 0, id, 0,
      {Buffer::WI, 0, 1}, {Buffer::GATE, 0, 1}, {Buffer::TMP, 0, 1},
      0, 0, 0, 0, plan));
  const full::GDownWindow& window = plan.window[0];
  const TaskBinding binding{window.producer.ctx, window.quant, window.linear};
  full::FullWeightDescriptor descriptor;
  assert(full::full_lookup_weight(plan.load.weight, descriptor));

  // Each typed single-command service produces exactly one TaskDone.
  hls::stream<ap_uint<512>> load_commands, load_responses;
  Command built;
  assert(build_load_command(id, mem, model, descriptor, plan.load,
                            plan.load_generation, built));
  push_response(load_responses, success(built));
  TaskDone done;
  assert(dispatch_load(load_commands, load_responses, id, mem, model,
                       descriptor, plan.load, plan.load_generation, done));
  assert(load_commands.size() == 16 && done.task_id == plan.load.ctx.task_id &&
         done.output_unit == OutputUnit::BYTES);
  drain_commands(load_commands, 16);

  hls::stream<ap_uint<512>> geglu_commands, geglu_responses;
  assert(build_geglu_command(id, mem, model, window.producer, binding,
                             window.producer_generation, built));
  push_response(geglu_responses, success(built));
  assert(dispatch_geglu(geglu_commands, geglu_responses, id, mem, model,
                        window.producer, binding,
                        window.producer_generation, done));
  assert(geglu_commands.size() == 16 && done.task_id == window.producer.ctx.task_id);
  drain_commands(geglu_commands, 16);

  hls::stream<ap_uint<512>> quant_commands, quant_responses;
  assert(build_quant_command(id, mem, model, binding,
                             window.quant_generation, built));
  push_response(quant_responses, success(built));
  assert(dispatch_quant(quant_commands, quant_responses, id, mem, model,
                        binding, window.quant_generation, done));
  assert(quant_commands.size() == 16 && done.task_id == window.quant.ctx.task_id &&
         done.output_unit == OutputUnit::Q8_GROUP);
  drain_commands(quant_commands, 16);

  // Four physical views consume four distinct generations and retire one
  // typed parent only after every response has drained.
  hls::stream<ap_uint<512>> matrix_commands, matrix_responses;
  for (unsigned view = 0; view < window.views; ++view) {
    assert(build_matrix_command(id, mem, model, binding,
                                window.view[view], built));
    push_response(matrix_responses, success(built));
  }
  assert(dispatch_matrix(matrix_commands, matrix_responses, id, mem, model,
                         binding, window.view, window.views, done));
  assert(window.views == 4 && matrix_commands.size() == 64 &&
         matrix_responses.empty() && done.task_id == window.linear.ctx.task_id &&
         done.output_elements == uint32_t(window.linear.ctx.rows) * window.linear.N);
  drain_commands(matrix_commands, 64);

  // A failed early view does not skip later views. The lowest u64 rank wins.
  hls::stream<ap_uint<512>> failed_commands, failed_responses;
  for (unsigned view = 0; view < window.views; ++view) {
    assert(build_matrix_command(id, mem, model, binding,
                                window.view[view], built));
    Response response = success(built);
    if (view == 0 || view == 1) {
      response.status = Status::E_NUMERICAL;
      response.error_detail = laya::detail(7, uint8_t(Op::LIN_DOWN), 15);
      response.first_error_rank = view == 0 ? 2112000 : 5280;
      response.bad_element = view == 0 ? 19 : 3;
      response.output_elements = 0; response.unit = OutputUnit::NONE;
      response.published = false;
    }
    push_response(failed_responses, response);
  }
  const Check failure = dispatch_matrix(
      failed_commands, failed_responses, id, mem, model, binding,
      window.view, window.views, done);
  assert(failure.code == Status::E_NUMERICAL && failure.bad_element == 3 &&
         done.status == Status::E_NUMERICAL && done.bad_element == 3 &&
         failed_commands.size() == 64 && failed_responses.empty());
  drain_commands(failed_commands, 64);

  std::cout << "FULL_CURRENT_PORTAL_HLS_PASS ap_uint_bits=512 command_beats=16 "
               "response_beats=8 blocking_exchange=1 byte_order=1 services=4 "
               "matrix_views=4 parent_taskdone=1 rank_merge=1 failure_drain=1\n";
}

