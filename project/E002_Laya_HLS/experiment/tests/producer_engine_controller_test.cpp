#include "laya_compute_portal_controller.h"
#include "laya_generated_provenance_events.h"
#include "laya_generated_provenance_client.h"
#include "laya_model_layout_generated.h"
#include "laya_producer_engine_client.h"

#include <cassert>
#include <iostream>

using namespace laya;
using namespace laya::full;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 61;
  id.generation = 73;
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

void initialize(FullRuntime& rt) {
  rt.inputs.identity = identity();
  rt.request_valid = true;
  rt.model_header_valid = true;
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

provenance::Response provenance_success(const provenance::Request& request) {
  provenance::Response response;
  response.action = request.action;
  response.event_seq = request.event_seq;
  response.origin_seq = request.origin_seq;
  response.status = request.action == provenance::Action::END ?
                    request.reported_status : Status::OK;
  response.error_detail = request.action == provenance::Action::END ?
                          request.reported_error_detail : 0;
  response.bad_element = request.action == provenance::Action::END ?
                         request.reported_bad_element : UINT64_MAX;
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
  if (request.action == provenance::Action::END &&
      request.reported_status == Status::OK) {
    response.output_elements = request.expected_elements;
    response.unit = request.expected_unit;
  }
  return response;
}

ap_uint<512> pack(const uint8_t* bytes) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = bytes[byte];
  return word;
}

void queue_provenance(hls::stream<ap_uint<512>>& responses,
                      const provenance::Request& request) {
  const provenance::ResponsePacket packet =
      provenance::encode(provenance_success(request));
  for (unsigned beat = 0; beat < provenance::kResponseBeats; ++beat)
    responses.write(pack(packet.data() + beat * 64));
}

void queue_completion(hls::stream<ap_uint<512>>& completions,
                      const producer::Completion& completion) {
  const producer::CompletionPacket packet = producer::encode(completion);
  for (unsigned beat = 0; beat < producer::kCompletionBeats; ++beat)
    completions.write(pack(packet.data() + beat * 64));
}

void queue_completion_packet(hls::stream<ap_uint<512>>& completions,
                             const producer::CompletionPacket& packet) {
  for (unsigned beat = 0; beat < producer::kCompletionBeats; ++beat)
    completions.write(pack(packet.data() + beat * 64));
}

void compare_packet(hls::stream<ap_uint<512>>& stream,
                    const uint8_t* expected, unsigned beats) {
  assert(stream.size() >= beats);
  for (unsigned beat = 0; beat < beats; ++beat) {
    const ap_uint<512> actual = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      assert(uint8_t(actual.range(byte * 8 + 7, byte * 8)) ==
             expected[beat * 64 + byte]);
  }
}

producer::Completion successful_completion(
    const producer::Request& request) {
  producer::Completion completion;
  completion.family = request.family;
  completion.request_seq = request.request_seq;
  completion.provenance_origin_seq = request.provenance_origin_seq;
  completion.status = Status::OK;
  completion.unit = OutputUnit::F32;
  completion.finished = true;
  completion.bad_element = UINT64_MAX;
  completion.output_elements = request.expected_elements;
  completion.issued_store_bytes =
      uint64_t(request.expected_elements) * 4u;
  completion.consumed_source_bytes =
      uint64_t(request.expected_elements) * 4u;
  completion.identity = request.identity;
  completion.context = request.context;
  completion.source = request.source;
  completion.destination = request.destination;
  completion.D = request.D;
  completion.gamma = request.gamma;
  completion.source_region = request.source_region;
  completion.destination_region = request.destination_region;
  completion.source_role = request.source_role;
  completion.destination_role = request.destination_role;
  completion.eps_bits = request.eps_bits;
  completion.row_bytes = request.row_bytes;
  completion.source_first_offset = request.source_first_offset;
  completion.destination_first_offset = request.destination_first_offset;
  completion.source_row_step = request.source_row_step;
  completion.destination_row_step = request.destination_row_step;
  return completion;
}

} // namespace

int main() {
  FullMemory ports = memory();
  const FullOwnerSpec source{{Buffer::HIDDEN, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  const FullOwnerSpec output{{Buffer::NORM, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  LayerNormTask task;
  task.ctx = {1, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  task.src = source.ref;
  task.dst = output.ref;
  task.gamma = 0;

  // Construct the exact command/response transcript using a separate runtime
  // so the tested Controller must independently produce the same bytes.
  static FullRuntime expected_rt;
  initialize(expected_rt);
  fill_owner(expected_rt, source);
  portal::ModelBinding model;
  assert(portal::build_l13m_model_binding(model));
  provenance::Request claim;
  assert(provenance::build_owner_event(
      expected_rt, ports, model, provenance::Action::CLAIM,
      &output, nullptr, 1, claim));
  assert(full_claim_owner(expected_rt, output));
  assert(full_bind_task_source(expected_rt, source));
  provenance::Request begin;
  bool protected_task = false;
  assert(provenance::build_generated_begin(
      expected_rt, ports, model, task, 16u * 1024u, OutputUnit::F32,
      begin, protected_task));
  assert(protected_task);
  producer::Request engine_request;
  assert(producer::build_layernorm_request(
      expected_rt, ports, model, task, begin, engine_request));
  const producer::Completion completion =
      successful_completion(engine_request);
  provenance::Request end = begin;
  end.action = provenance::Action::END;
  end.event_seq = 3;
  end.origin_seq = begin.event_seq;
  end.reported_status = Status::OK;
  end.reported_unit = OutputUnit::F32;
  end.reported_elements = 16u * 1024u;
  end.reported_bad_element = UINT64_MAX;
  end.issued_store_bytes[0] = 16u * 1024u * 4u;

  static FullRuntime actual_rt;
  initialize(actual_rt);
  fill_owner(actual_rt, source);
  hls::stream<ap_uint<512>> provenance_commands, provenance_responses;
  hls::stream<ap_uint<512>> producer_requests, producer_completions;
  queue_provenance(provenance_responses, claim);
  queue_provenance(provenance_responses, begin);
  queue_provenance(provenance_responses, end);
  queue_completion(producer_completions, completion);

  const Check result = full_execute_generated_layernorm_lifecycle_portal(
      actual_rt, ports, source, output, task, 16u * 1024u, false,
      provenance_commands, provenance_responses,
      producer_requests, producer_completions);
  assert(result && provenance_responses.empty() &&
         producer_completions.empty());

  for (const provenance::Request* request :
       {&claim, &begin, &end}) {
    const provenance::RequestPacket packet = provenance::encode(*request);
    compare_packet(provenance_commands, packet.data(),
                   provenance::kRequestBeats);
  }
  assert(provenance_commands.empty());
  const producer::RequestPacket request_packet =
      producer::encode(engine_request);
  compare_packet(producer_requests, request_packet.data(),
                 producer::kRequestBeats);
  assert(producer_requests.empty());

  FullOwnerRecord source_record, output_record;
  assert(full_owner_snapshot(actual_rt, source.ref, source.region,
                             source_record));
  assert(full_owner_snapshot(actual_rt, output.ref, output.region,
                             output_record));
  SourceProvenanceRecord proof;
  assert(full_source_snapshot(actual_rt, output, proof));
  assert(source_record.readers == 0 &&
         source_record.state == CacheState::READY &&
         output_record.state == CacheState::FILL && !output_record.valid &&
         proof.window[1].close_valid &&
         proof.window[1].close_context.task_id == 1 &&
         actual_rt.last_task_id == 1 && actual_rt.tasks_retired == 1 &&
         actual_rt.op_calls[uint8_t(Op::LN_ATTN)] == 1 &&
         actual_rt.provenance_event_high_water == 3 &&
         actual_rt.producer_request_high_water == 1 &&
         !actual_rt.generated_store.active &&
         !actual_rt.generated_store.source_lease_active);

  // A bound numerical failure preserves the engine's actual partial store
  // amount in END, releases the source only after the completion, retires the
  // typed task once, and leaves no publication proof.
  static FullRuntime partial_expected_rt;
  initialize(partial_expected_rt);
  partial_expected_rt.inputs.identity.request_id = 62;
  fill_owner(partial_expected_rt, source);
  provenance::Request partial_claim;
  assert(provenance::build_owner_event(
      partial_expected_rt, ports, model, provenance::Action::CLAIM,
      &output, nullptr, 1, partial_claim));
  assert(full_claim_owner(partial_expected_rt, output));
  assert(full_bind_task_source(partial_expected_rt, source));
  provenance::Request partial_begin;
  assert(provenance::build_generated_begin(
      partial_expected_rt, ports, model, task, 16u * 1024u,
      OutputUnit::F32, partial_begin, protected_task));
  producer::Request partial_request;
  assert(producer::build_layernorm_request(
      partial_expected_rt, ports, model, task, partial_begin,
      partial_request));
  producer::Completion partial_completion =
      successful_completion(partial_request);
  partial_completion.status = Status::E_NUMERICAL;
  partial_completion.unit = OutputUnit::NONE;
  partial_completion.error_detail =
      laya::detail(7, uint8_t(Op::LN_ATTN), 15);
  partial_completion.bad_element = 1024;
  partial_completion.output_elements = 0;
  partial_completion.issued_store_bytes = 4096;
  partial_completion.consumed_source_bytes = 8192;
  provenance::Request partial_end = partial_begin;
  partial_end.action = provenance::Action::END;
  partial_end.event_seq = 3;
  partial_end.origin_seq = partial_begin.event_seq;
  partial_end.reported_status = partial_completion.status;
  partial_end.reported_unit = OutputUnit::NONE;
  partial_end.reported_elements = 0;
  partial_end.reported_error_detail = partial_completion.error_detail;
  partial_end.reported_bad_element = partial_completion.bad_element;
  partial_end.issued_store_bytes[0] = 4096;

  static FullRuntime partial_rt;
  initialize(partial_rt);
  partial_rt.inputs.identity.request_id = 62;
  fill_owner(partial_rt, source);
  hls::stream<ap_uint<512>> partial_provenance_commands,
                            partial_provenance_responses;
  hls::stream<ap_uint<512>> partial_producer_requests,
                            partial_producer_completions;
  queue_provenance(partial_provenance_responses, partial_claim);
  queue_provenance(partial_provenance_responses, partial_begin);
  queue_provenance(partial_provenance_responses, partial_end);
  queue_completion(partial_producer_completions, partial_completion);
  const Check partial_result =
      full_execute_generated_layernorm_lifecycle_portal(
          partial_rt, ports, source, output, task, 16u * 1024u, false,
          partial_provenance_commands, partial_provenance_responses,
          partial_producer_requests, partial_producer_completions);
  assert(partial_result.code == Status::E_NUMERICAL &&
         partial_result.detail == partial_completion.error_detail &&
         partial_result.bad_element == partial_completion.bad_element &&
         partial_provenance_responses.empty() &&
         partial_producer_completions.empty());
  for (const provenance::Request* request :
       {&partial_claim, &partial_begin, &partial_end}) {
    const provenance::RequestPacket packet = provenance::encode(*request);
    compare_packet(partial_provenance_commands, packet.data(),
                   provenance::kRequestBeats);
  }
  assert(partial_provenance_commands.empty());
  const producer::RequestPacket partial_request_packet =
      producer::encode(partial_request);
  compare_packet(partial_producer_requests, partial_request_packet.data(),
                 producer::kRequestBeats);
  assert(partial_producer_requests.empty());
  assert(full_owner_snapshot(partial_rt, source.ref, source.region,
                             source_record));
  assert(full_owner_snapshot(partial_rt, output.ref, output.region,
                             output_record));
  assert(source_record.readers == 0 &&
         source_record.state == CacheState::READY &&
         output_record.state == CacheState::INVALID &&
         !output_record.valid && partial_rt.last_task_id == 1 &&
         partial_rt.tasks_retired == 1 &&
         partial_rt.op_calls[uint8_t(Op::LN_ATTN)] == 1 &&
         partial_rt.provenance_event_high_water == 3 &&
         partial_rt.producer_request_high_water == 1 &&
         !partial_rt.generated_store.active &&
         !partial_rt.generated_store.source_lease_active);

  // A malformed completion is not accepted as a fence.  No END or typed
  // retirement occurs, and both the physical store tracker and exact source
  // read lease remain available for cancellation/fence recovery.
  static FullRuntime malformed_expected_rt;
  initialize(malformed_expected_rt);
  malformed_expected_rt.inputs.identity.request_id = 63;
  fill_owner(malformed_expected_rt, source);
  provenance::Request malformed_claim;
  assert(provenance::build_owner_event(
      malformed_expected_rt, ports, model, provenance::Action::CLAIM,
      &output, nullptr, 1, malformed_claim));
  assert(full_claim_owner(malformed_expected_rt, output));
  assert(full_bind_task_source(malformed_expected_rt, source));
  provenance::Request malformed_begin;
  assert(provenance::build_generated_begin(
      malformed_expected_rt, ports, model, task, 16u * 1024u,
      OutputUnit::F32, malformed_begin, protected_task));
  producer::Request malformed_request;
  assert(producer::build_layernorm_request(
      malformed_expected_rt, ports, model, task, malformed_begin,
      malformed_request));
  producer::CompletionPacket malformed_packet =
      producer::encode(successful_completion(malformed_request));
  malformed_packet[224] = 1;

  static FullRuntime malformed_rt;
  initialize(malformed_rt);
  malformed_rt.inputs.identity.request_id = 63;
  fill_owner(malformed_rt, source);
  hls::stream<ap_uint<512>> malformed_provenance_commands,
                            malformed_provenance_responses;
  hls::stream<ap_uint<512>> malformed_producer_requests,
                            malformed_producer_completions;
  queue_provenance(malformed_provenance_responses, malformed_claim);
  queue_provenance(malformed_provenance_responses, malformed_begin);
  queue_completion_packet(malformed_producer_completions, malformed_packet);
  const Check malformed_result =
      full_execute_generated_layernorm_lifecycle_portal(
          malformed_rt, ports, source, output, task, 16u * 1024u, false,
          malformed_provenance_commands, malformed_provenance_responses,
          malformed_producer_requests, malformed_producer_completions);
  assert(malformed_result.code == Status::E_ABI &&
         malformed_provenance_responses.empty() &&
         malformed_producer_completions.empty());
  for (const provenance::Request* request :
       {&malformed_claim, &malformed_begin}) {
    const provenance::RequestPacket packet = provenance::encode(*request);
    compare_packet(malformed_provenance_commands, packet.data(),
                   provenance::kRequestBeats);
  }
  assert(malformed_provenance_commands.empty());
  const producer::RequestPacket malformed_request_packet =
      producer::encode(malformed_request);
  compare_packet(malformed_producer_requests,
                 malformed_request_packet.data(), producer::kRequestBeats);
  assert(malformed_producer_requests.empty());
  assert(full_owner_snapshot(malformed_rt, source.ref, source.region,
                             source_record));
  assert(full_owner_snapshot(malformed_rt, output.ref, output.region,
                             output_record));
  assert(source_record.readers == 1 &&
         source_record.state == CacheState::READ &&
         output_record.state == CacheState::FILL &&
         malformed_rt.last_task_id == 0 &&
         malformed_rt.tasks_retired == 0 &&
         malformed_rt.op_calls[uint8_t(Op::LN_ATTN)] == 0 &&
         malformed_rt.provenance_event_high_water == 2 &&
         malformed_rt.producer_request_high_water == 1 &&
         malformed_rt.generated_store.active &&
         malformed_rt.generated_store.source_lease_active &&
         malformed_rt.generated_store.source_lease.ref == source.ref &&
         malformed_rt.generated_store.issued_bytes[0] == 0);

  std::cout << "FULL_CURRENT_PRODUCER_ENGINE_CONTROLLER_PASS "
               "family=layernorm rows=16 elements=16384 "
               "producer_requests=3 provenance_events=8 "
               "issued_store_bytes=65536 consumed_source_bytes=65536 "
               "source_lease_released=1 retired_once=1 source_window_p=1 "
               "partial_failure_bytes=4096 partial_failure_retired_once=1 "
               "malformed_completion_scope_held=1\n";
}
