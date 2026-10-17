#include "laya_controller_transaction_adapter.h"
#include "laya_graph_program_sequencer.h"
#include "laya_model_layout_generated.h"
#include "laya_task_lifecycle_executor.h"

#include <algorithm>
#include <atomic>
#include <cassert>
#include <fstream>
#include <iostream>
#include <iterator>
#include <thread>
#include <vector>

using namespace laya;

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

NumericIdentity patterned_identity() {
  NumericIdentity id;
  id.request_id = 0x1111222233334444ull;
  id.generation = 0x5555666677778888ull;
  id.B = 1;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x10 + i);
    id.numeric_tag[i] = uint8_t(0x20 + i);
    id.layout_tag[i] = uint8_t(0x30 + i);
    id.build_tag[i] = uint8_t(0x40 + i);
  }
  return id;
}

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 701;
  id.generation = 41;
  id.B = 1;
  id.S = 64;
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

void fill_owner(full::FullRuntime& rt, const full::FullOwnerSpec& owner) {
  assert(full::full_claim_owner(rt, owner));
  for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch)
    for (unsigned row = 0; row < owner.rows; row += 16)
      assert(full::full_cover_owner(
          rt, owner, uint8_t(batch), uint16_t(row),
          uint16_t(owner.rows - row < 16 ? owner.rows - row : 16)));
  assert(full::full_publish_owner(rt, owner));
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

provenance::Response provenance_response(const provenance::Request& request) {
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
  response.drained = true;
  response.scope_active = request.action == provenance::Action::BEGIN;
  response.owner_published = request.action == provenance::Action::PUBLISH;
  if (request.action == provenance::Action::END &&
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

action::Request oracle_request() {
  action::Request request;
  request.kind = action::Kind::NORM;
  request.pc = 7;
  request.op = Op::LN_ATTN;
  request.stage = 2;
  request.layer = 3;
  request.ordinal = 0x0102030405060708ull;
  request.identity = patterned_identity();
  request.source.slot = 0;
  request.source.version = 0x1112131415161718ull;
  request.source.owner = {{Buffer::HIDDEN, 0, 9}, 0, 2, 2, 255,
                          RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  request.target_slot = 1;
  request.target_slot_version = 2;
  request.target_buffer = Buffer::NORM;
  request.target_bank = 1;
  request.weight.layer = 255;
  return request;
}

} // namespace

int main(int argc, char** argv) {
  assert(argc == 2);
  std::ifstream stream(argv[1], std::ios::binary);
  std::vector<uint8_t> oracle((std::istreambuf_iterator<char>(stream)), {});
  assert(oracle.size() == action::kRequestBytes);
  const action::Request mapping = oracle_request();
  const action::RequestPacket encoded = action::encode(mapping);
  assert(std::equal(encoded.begin(), encoded.end(), oracle.begin()));
  action::Request decoded;
  assert(action::decode(encoded, decoded));
  assert(decoded.ordinal == mapping.ordinal &&
         decoded.source.version == mapping.source.version &&
         decoded.source.owner.ref == mapping.source.owner.ref &&
         decoded.target_slot_version == mapping.target_slot_version);

  static full::FullRuntime rt;
  rt.inputs.identity = identity();
  rt.request_valid = true;
  rt.model_header_valid = true;
  full::FullMemory ports = memory();
  const full::FullOwnerSpec source{
      {Buffer::HIDDEN, 0, 1}, 0, 2, 0, 255, RowSpace::TOKEN,
      0, 64, 1024, Content::F32};
  fill_owner(rt, source);

  program::State program_state;
  assert(program::begin(program_state, rt.inputs.identity));
  assert(program::seed_slot(program_state, 0, source, source.ref.epoch));
  action::Request request;
  assert(program::prepare_norm(program_state, 0, 1, Op::LN_ATTN, 2, 1,
                               Buffer::NORM, 0, 0, 0, request));

  Streams streams;
  action::Completion completion;
  std::atomic<bool> completed{false};
  Check result = ok();
  std::thread executor([&] {
    result = lifecycle::execute(rt, ports, request, completion,
                                streams.transaction_request,
                                streams.transaction_completion);
    completed.store(true, std::memory_order_release);
  });

  std::vector<provenance::Request> provenance_requests;
  std::vector<producer::Request> producer_requests;
  bool cancel = false;
  for (unsigned cycle = 0; cycle < 4000000 &&
       !completed.load(std::memory_order_acquire); ++cycle) {
    laya_command_provenance_adapter(
        cancel, streams.transaction_request, streams.transaction_completion,
        streams.compute_command, streams.compute_response,
        streams.provenance_command, streams.provenance_response,
        streams.producer_request, streams.producer_completion);
    if (streams.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request item;
      assert(provenance::decode(
          dequeue<provenance::kRequestBytes>(streams.provenance_command),
          item));
      provenance_requests.push_back(item);
      enqueue(streams.provenance_response,
              provenance::encode(provenance_response(item)));
    }
    if (streams.producer_request.size() >= producer::kRequestBeats) {
      producer::Request item;
      assert(producer::decode(
          dequeue<producer::kRequestBytes>(streams.producer_request), item));
      producer_requests.push_back(item);
      enqueue(streams.producer_completion,
              producer::encode(producer_success(item)));
    }
    std::this_thread::yield();
  }
  assert(completed.load(std::memory_order_acquire));
  executor.join();
  if (!result || producer_requests.size() != 4 ||
      provenance_requests.size() != 10 || rt.tasks_retired != 4 ||
      rt.last_task_id != 4) {
    std::cerr << "lifecycle debug code=" << unsigned(result.code)
              << " detail=" << result.detail
              << " bad=" << result.bad_element
              << " producer=" << producer_requests.size()
              << " provenance=" << provenance_requests.size()
              << " retired=" << rt.tasks_retired
              << " last=" << rt.last_task_id
              << " tracker=" << rt.generated_store.active
              << " flags=" << completion.flags << "\n";
  }
  assert(result && producer_requests.size() == 4 &&
         provenance_requests.size() == 10 &&
         provenance_requests.front().action == provenance::Action::CLAIM &&
         provenance_requests.back().action == provenance::Action::PUBLISH &&
         rt.tasks_retired == 4 && rt.last_task_id == 4 &&
         rt.op_calls[uint8_t(Op::LN_ATTN)] == 4 &&
         completion.retired_tasks == 4 &&
         (completion.flags & action::SLOT_UPDATE_VALID));

  const action::CompletionPacket completion_packet = action::encode(completion);
  action::Completion decoded_completion;
  assert(action::decode(completion_packet, decoded_completion) &&
         action::same_key(request, decoded_completion) &&
         decoded_completion.slot_delta.version ==
             completion.slot_delta.version);
  action::CompletionPacket bad_completion_packet = completion_packet;
  bad_completion_packet[0] ^= 1;
  decoded_completion = completion;
  assert(!action::decode(bad_completion_packet, decoded_completion) &&
         decoded_completion.ordinal == 0 && decoded_completion.flags == 0);

  action::Completion wrong = completion;
  ++wrong.ordinal;
  assert(!program::accept_completion(program_state, wrong));
  assert(program_state.action_active);
  assert(program::accept_completion(program_state, completion));
  assert(!program_state.action_active && program_state.pc == 1 &&
         program_state.slot[1].valid &&
         program_state.slot[1].owner.ref.id == Buffer::NORM);

  full::FullOwnerRecord output_record;
  full::SourceProvenanceRecord output_proof;
  assert(full::full_owner_snapshot(
      rt, completion.slot_delta.owner.ref,
      completion.slot_delta.owner.region, output_record));
  assert(full::full_source_snapshot(rt, completion.slot_delta.owner,
                                    output_proof));
  assert(output_record.state == CacheState::READY && output_record.valid &&
         output_proof.published && !output_proof.invalid);
  for (unsigned window = 0; window < 4; ++window)
    assert(output_proof.window[window].close_valid);

  const uint64_t event_high_water = rt.provenance_event_high_water;
  const uint64_t producer_high_water = rt.producer_request_high_water;
  action::Request unsupported = request;
  unsupported.kind = action::Kind::LINEAR;
  unsupported.op = Op::LIN_WO;
  unsupported.ordinal = 2;
  action::Completion rejected;
  assert(!lifecycle::execute(rt, ports, unsupported, rejected,
                             streams.transaction_request,
                             streams.transaction_completion));
  assert((rejected.flags & action::LOCAL_REJECT) &&
         rt.provenance_event_high_water == event_high_water &&
         rt.producer_request_high_water == producer_high_water &&
         rt.tasks_retired == 4 && streams.transaction_request.empty() &&
         streams.transaction_completion.empty());

  action::Request stale = request;
  stale.ordinal = 3;
  ++stale.source.version;
  action::Completion stale_completion;
  assert(!lifecycle::execute(rt, ports, stale, stale_completion,
                             streams.transaction_request,
                             streams.transaction_completion));
  assert((stale_completion.flags & action::LOCAL_REJECT) &&
         rt.provenance_event_high_water == event_high_water &&
         rt.tasks_retired == 4);

  std::cout << "FULL_CURRENT_GRAPH_LIFECYCLE_SPLIT_PASS "
            << "schema=LAX1/LAC1 request_beats=8 completion_beats=4 "
            << "python_byte_oracle=1 action_kind_count=17 "
            << "program_key_reject=1 source_version_reject=1 "
            << "unsupported_dynamic=1 unsupported_static_registry=16 "
            << "layernorm_windows=4 "
            << "claim_begin_producer_end_publish=1 typed_retired=4 "
            << "source_windows_closed=4 owner_published=1\n";
  return 0;
}
