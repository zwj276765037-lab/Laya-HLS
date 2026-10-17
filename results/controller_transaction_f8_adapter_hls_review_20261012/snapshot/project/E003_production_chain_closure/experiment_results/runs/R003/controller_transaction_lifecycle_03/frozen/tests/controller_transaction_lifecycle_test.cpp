#include "laya_compute_portal_controller.h"
#include "laya_controller_transaction_adapter.h"
#include "laya_model_layout_generated.h"

#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>
#include <vector>

using namespace laya;
using namespace laya::full;

namespace {

struct Streams {
  hls::stream<ap_uint<512>> transaction_request{"transaction_request"};
  hls::stream<ap_uint<512>> transaction_completion{"transaction_completion"};
  hls::stream<ap_uint<512>> compute_command{"compute_command"};
  hls::stream<ap_uint<512>> compute_response{"compute_response"};
  hls::stream<ap_uint<512>> provenance_command{"provenance_command"};
  hls::stream<ap_uint<512>> provenance_response{"provenance_response"};
  hls::stream<ap_uint<512>> producer_request{"producer_request"};
  hls::stream<ap_uint<512>> producer_completion{"producer_completion"};
};

NumericIdentity identity(uint64_t request_id, uint64_t generation) {
  NumericIdentity value;
  value.request_id = request_id;
  value.generation = generation;
  value.B = 1;
  value.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    value.model_tag[i] = kFullModelTag[i];
    value.numeric_tag[i] = kFullNumericTag[i];
    value.layout_tag[i] = kFullLayoutTag[i];
    value.build_tag[i] = kFullBuildTag[i];
  }
  return value;
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

void initialize(FullRuntime& rt, const NumericIdentity& id) {
  rt.inputs.identity = id;
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

template<std::size_t Bytes>
ap_uint<512> pack(const std::array<uint8_t, Bytes>& packet, unsigned beat) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  return word;
}

template<std::size_t Bytes>
std::array<uint8_t, Bytes> dequeue(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

template<std::size_t Bytes>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat)
    stream.write(pack(packet, beat));
}

provenance::Response provenance_response(
    const provenance::Request& request, bool terminal) {
  provenance::Response response;
  response.action = request.action;
  response.event_seq = request.event_seq;
  response.origin_seq = request.origin_seq;
  response.identity = request.identity;
  response.context = request.context;
  response.descriptor_count = request.descriptor_count;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    response.target_ref[i] = request.descriptor[i].target_ref;
    response.target_region[i] = request.descriptor[i].target_region;
    response.old_ref[i] = request.descriptor[i].old_ref;
    response.old_region[i] = request.descriptor[i].old_region;
  }
  response.status = request.action == provenance::Action::END ?
                    request.reported_status : Status::OK;
  response.error_detail = request.action == provenance::Action::END ?
                          request.reported_error_detail : 0;
  response.bad_element = request.action == provenance::Action::END ?
                         request.reported_bad_element : UINT64_MAX;
  response.drained = request.action != provenance::Action::END || terminal;
  response.scope_active = request.action == provenance::Action::BEGIN ||
      (request.action == provenance::Action::END && !terminal);
  if (request.action == provenance::Action::END && terminal &&
      request.reported_status == Status::OK) {
    response.unit = request.expected_unit;
    response.output_elements = request.expected_elements;
    for (unsigned i = 0; i < request.descriptor_count; ++i)
      response.observed_store_bytes[i] = request.issued_store_bytes[i];
  }
  return response;
}

producer::Completion producer_success(const producer::Request& request) {
  producer::Completion response;
  response.family = request.family;
  response.request_seq = request.request_seq;
  response.provenance_origin_seq = request.provenance_origin_seq;
  response.status = Status::OK;
  response.unit = OutputUnit::F32;
  response.finished = true;
  response.bad_element = UINT64_MAX;
  response.output_elements = request.expected_elements;
  response.issued_store_bytes = uint64_t(request.expected_elements) * 4u;
  response.consumed_source_bytes = response.issued_store_bytes;
  response.identity = request.identity;
  response.context = request.context;
  response.source = request.source;
  response.destination = request.destination;
  response.source_region = request.source_region;
  response.destination_region = request.destination_region;
  response.source_role = request.source_role;
  response.destination_role = request.destination_role;
  response.D = request.D;
  response.gamma = request.gamma;
  response.eps_bits = request.eps_bits;
  response.row_bytes = request.row_bytes;
  response.source_first_offset = request.source_first_offset;
  response.destination_first_offset = request.destination_first_offset;
  response.source_row_step = request.source_row_step;
  response.destination_row_step = request.destination_row_step;
  return response;
}

struct Outcome {
  Check result;
  std::vector<provenance::Request> provenance;
  std::vector<producer::Request> producer;
  bool producer_external_empty = true;
};

enum class EndMode {
  TERMINAL_AFTER_FENCE,
  BAD_HEADER_AFTER_FENCE,
  WRONG_BINDING_AFTER_FENCE,
};

Outcome execute(FullRuntime& rt, FullMemory& ports,
                const FullOwnerSpec& source, const FullOwnerSpec& output,
                const LayerNormTask& task, bool local_reject,
                EndMode end_mode = EndMode::TERMINAL_AFTER_FENCE) {
  Streams streams;
  Outcome outcome;
  std::atomic<bool> completed{false};
  std::thread sequencer([&] {
    outcome.result = full_execute_generated_layernorm_lifecycle_transaction(
        rt, ports, source, output, task, 16u * 1024u, false,
        streams.transaction_request, streams.transaction_completion);
    completed.store(true, std::memory_order_release);
  });

  bool cancel = false;
  unsigned end_count = 0;
  for (unsigned cycle = 0; cycle < 2000000 &&
       !completed.load(std::memory_order_acquire); ++cycle) {
    laya_command_provenance_adapter(
        cancel, streams.transaction_request, streams.transaction_completion,
        streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);

    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request request;
      assert(provenance::decode(
          dequeue<provenance::kRequestBytes>(streams.provenance_command),
          request));
      outcome.provenance.push_back(request);
      bool terminal = true;
      if (request.action == provenance::Action::BEGIN && local_reject)
        cancel = true;
      if (request.action == provenance::Action::END) {
        ++end_count;
        terminal = !local_reject || end_count > 1;
      }
      provenance::Response response = provenance_response(request, terminal);
      if (request.action == provenance::Action::END && end_count == 2 &&
          end_mode == EndMode::WRONG_BINDING_AFTER_FENCE)
        ++response.event_seq;
      provenance::ResponsePacket packet = provenance::encode(response);
      if (request.action == provenance::Action::END && end_count == 2 &&
          end_mode == EndMode::BAD_HEADER_AFTER_FENCE)
        packet[0] ^= 1;
      enqueue(streams.provenance_response, packet);
    }

    if (!streams.producer_request.empty()) {
      outcome.producer_external_empty = false;
      if (streams.producer_request.size() >= producer::kRequestBeats) {
        producer::Request request;
        assert(producer::decode(
            dequeue<producer::kRequestBytes>(streams.producer_request),
            request));
        outcome.producer.push_back(request);
        enqueue(streams.producer_completion,
                producer::encode(producer_success(request)));
      }
    }
    std::this_thread::yield();
  }
  assert(completed.load(std::memory_order_acquire));
  sequencer.join();
  assert(streams.compute_command.empty() && streams.compute_response.empty() &&
         streams.provenance_command.empty() &&
         streams.provenance_response.empty() &&
         streams.producer_request.empty() &&
         streams.producer_completion.empty() &&
         streams.transaction_request.empty() &&
         streams.transaction_completion.empty());
  return outcome;
}

void check_rejected_end(EndMode mode, uint64_t request_id,
                        uint64_t generation) {
  FullMemory ports = memory();
  FullRuntime rt;
  initialize(rt, identity(request_id, generation));
  const FullOwnerSpec source{{Buffer::HIDDEN, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  const FullOwnerSpec output{{Buffer::NORM, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  fill_owner(rt, source);
  LayerNormTask task;
  task.ctx = {1, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  task.src = source.ref;
  task.dst = output.ref;
  task.gamma = 0;

  const Outcome rejected = execute(rt, ports, source, output, task, true, mode);
  assert(rejected.result.code == Status::E_PROTOCOL &&
         rejected.producer_external_empty && rejected.producer.empty() &&
         rejected.provenance.size() == 4 &&
         rejected.provenance[2].action == provenance::Action::END &&
         rejected.provenance[3].action == provenance::Action::END &&
         rejected.provenance[2].event_seq ==
             rejected.provenance[3].event_seq &&
         rejected.provenance[2].origin_seq ==
             rejected.provenance[3].origin_seq);

  FullOwnerRecord source_record, output_record;
  SourceProvenanceRecord output_proof;
  assert(full_owner_snapshot(rt, source.ref, source.region, source_record));
  assert(full_owner_snapshot(rt, output.ref, output.region, output_record));
  assert(full_source_snapshot(rt, output, output_proof));
  assert(source_record.state == CacheState::READY &&
         source_record.readers == 0 &&
         output_record.state == CacheState::INVALID &&
         !output_record.valid && output_proof.invalid &&
         !output_proof.published && rt.generated_store.active &&
         !rt.generated_store.source_lease_active &&
         rt.last_task_id == 0 && rt.tasks_retired == 0 &&
         rt.op_calls[uint8_t(Op::LN_ATTN)] == 0);
}

} // namespace

int main() {
  FullMemory ports = memory();
  static FullRuntime rt;
  initialize(rt, identity(601, 31));
  const FullOwnerSpec source{{Buffer::HIDDEN, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  const FullOwnerSpec output{{Buffer::NORM, 0, 1}, 0, 2, 1, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  fill_owner(rt, source);
  LayerNormTask task;
  task.ctx = {1, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  task.src = source.ref;
  task.dst = output.ref;
  task.gamma = 0;

  const Outcome rejected = execute(rt, ports, source, output, task, true);
  const uint32_t reject_detail = laya::detail(7, 0, 14);
  assert(rejected.result.code == Status::E_PROTOCOL &&
         rejected.result.detail == reject_detail &&
         rejected.producer_external_empty && rejected.producer.empty() &&
         rejected.provenance.size() == 4 &&
         rejected.provenance[0].action == provenance::Action::CLAIM &&
         rejected.provenance[1].action == provenance::Action::BEGIN &&
         rejected.provenance[2].action == provenance::Action::END &&
         rejected.provenance[3].action == provenance::Action::END &&
         rejected.provenance[2].event_seq ==
             rejected.provenance[3].event_seq &&
         rejected.provenance[2].origin_seq ==
             rejected.provenance[3].origin_seq &&
         rejected.provenance[2].reported_status == Status::E_PROTOCOL &&
         rejected.provenance[2].issued_store_bytes[0] == 0 &&
         rejected.provenance[3].issued_store_bytes[0] == 0);

  FullOwnerRecord source_record, output_record;
  assert(full_owner_snapshot(rt, source.ref, source.region, source_record));
  assert(full_owner_snapshot(rt, output.ref, output.region, output_record));
  SourceProvenanceRecord rejected_proof;
  assert(full_source_snapshot(rt, output, rejected_proof));
  assert(source_record.state == CacheState::READY &&
         source_record.readers == 0 &&
         output_record.state == CacheState::INVALID &&
         !output_record.valid && rejected_proof.invalid &&
         !rejected_proof.published && rt.last_task_id == 1 &&
         rt.tasks_retired == 1 &&
         rt.op_calls[uint8_t(Op::LN_ATTN)] == 1 &&
         rt.provenance_event_high_water == 3 &&
         rt.producer_request_high_water == 1 &&
         !rt.generated_store.active &&
         !rt.generated_store.source_lease_active);

  // Recycle the same persistent runtime only after every owner and task scope
  // is safe, then prove a higher NumericIdentity can execute the same path.
  assert(full_release_owner(rt, source));
  assert(full_recycle_request(rt));
  initialize(rt, identity(602, 32));
  FullOwnerSpec source2 = source;
  FullOwnerSpec output2 = output;
  source2.ref.epoch = 2;
  output2.ref.epoch = 2;
  fill_owner(rt, source2);
  LayerNormTask task2 = task;
  task2.src = source2.ref;
  task2.dst = output2.ref;

  const Outcome recovered = execute(rt, ports, source2, output2, task2, false);
  assert(recovered.result && !recovered.producer_external_empty &&
         recovered.producer.size() == 1 &&
         recovered.provenance.size() == 3 &&
         recovered.provenance[0].event_seq == 4 &&
         recovered.provenance[1].event_seq == 5 &&
         recovered.provenance[2].event_seq == 6 &&
         recovered.provenance[2].issued_store_bytes[0] == 65536 &&
         recovered.producer[0].request_seq == 2 &&
         recovered.producer[0].identity.request_id == 602 &&
         recovered.producer[0].identity.generation == 32);
  SourceProvenanceRecord recovered_proof;
  assert(full_owner_snapshot(rt, source2.ref, source2.region, source_record));
  assert(full_owner_snapshot(rt, output2.ref, output2.region, output_record));
  assert(full_source_snapshot(rt, output2, recovered_proof));
  assert(source_record.state == CacheState::READY &&
         source_record.readers == 0 &&
         output_record.state == CacheState::FILL && !output_record.valid &&
         recovered_proof.window[1].close_valid &&
         recovered_proof.window[1].close_context.task_id == 1 &&
         !recovered_proof.published && rt.last_task_id == 1 &&
         rt.tasks_retired == 1 &&
         rt.op_calls[uint8_t(Op::LN_ATTN)] == 1 &&
         !rt.generated_store.active &&
         !rt.generated_store.source_lease_active);

  // A transport or binding failure in the second END attempt must be acted on
  // using that iteration's trust flags.  Neither case may silently reuse the
  // first non-terminal response and send a third END.
  check_rejected_end(EndMode::BAD_HEADER_AFTER_FENCE, 603, 33);
  check_rejected_end(EndMode::WRONG_BINDING_AFTER_FENCE, 604, 34);

  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_LIFECYCLE_PASS "
            << "controller_branch=1 adapter_branch=1 begin_ok=2 "
            << "local_reject_no_external_request=1 issued_zero=1 "
            << "source_lease_released_once=1 end_nonterminal_retry=1 "
            << "end_terminal=1 destination_unpublished=1 retired_once=1 "
            << "same_runtime_higher_identity_recovery=1 "
            << "end_bad_header_abort=1 end_wrong_binding_abort=1 "
            << "no_third_end=2 tracker_preserved=2\n";
  return 0;
}
