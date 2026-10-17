#pragma once

#include "laya_controller_transaction_adapter.h"
#include "laya_model_layout_generated.h"
#include <cassert>

namespace lifecycle_fixture {
using namespace laya;
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

inline NumericIdentity identity() {
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

inline full::FullMemory memory() {
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

inline void fill_owner(full::FullRuntime& rt, const full::FullOwnerSpec& owner) {
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

inline provenance::Response provenance_response(const provenance::Request& request) {
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

inline producer::Completion producer_success(const producer::Request& request) {
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


} // namespace lifecycle_fixture
