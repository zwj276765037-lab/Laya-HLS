#include "laya_producer_engine.h"
#include "laya_model_layout_generated.h"

#include <cassert>
#include <cstdint>
#include <iostream>

namespace {

using namespace laya;

void copy(uint8_t* dst, const uint8_t* src, unsigned count) {
  for (unsigned i = 0; i < count; ++i) dst[i] = src[i];
}

producer::Request request() {
  producer::Request r;
  r.request_seq = 17;
  r.provenance_origin_seq = 91;
  r.identity.request_id = 8;
  r.identity.generation = 3;
  r.identity.B = 1;
  r.identity.S = 64;
  copy(r.identity.model_tag, full::kFullModelTag, 16);
  copy(r.identity.numeric_tag, full::kFullNumericTag, 16);
  copy(r.identity.layout_tag, full::kFullLayoutTag, 16);
  copy(r.identity.build_tag, full::kFullBuildTag, 16);
  r.context = {7, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  uint8_t* model = r.model_identity.data();
  copy(model, full::kFullModelTag, 16);
  copy(model + 16, full::kFullNumericTag, 16);
  copy(model + 32, full::kFullLayoutTag, 16);
  copy(model + 48, full::kFullBuildTag, 16);
  portal::put(model, 64, 0x4d33314cu, 4);
  portal::put(model, 68, 1, 2);
  portal::put(model, 70, 416, 2);
  portal::put(model, 72, 0, 4);
  portal::put(model, 76, 1, 4);
  copy(model + 80, full::kFullSourceSha256, 32);
  portal::put(model, 112, 5, 4);
  portal::put(model, 116, 16, 4);
  portal::put(model, 120, 128, 4);
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    portal::put(model, 128 + 16 * i, roles[i], 4);
    portal::put(model, 132 + 16 * i, 1, 4);
    portal::put(model, 136 + 16 * i, full::kFullModelBoSizes[i], 8);
  }
  r.source = {Buffer::HIDDEN, 0, 2};
  r.destination = {Buffer::NORM, 0, 4};
  r.source_role = Bo::STATE0;
  r.destination_role = Bo::STATE0;
  r.source_first_offset = 16u * 4096u;
  r.destination_first_offset = 8u * 1024u * 1024u + 16u * 4096u;
  r.source_bo_span = 16920576u;
  r.destination_bo_span = 16920576u;
  r.expected_elements = 16u * 1024u;
  return r;
}

producer::Completion success(const producer::Request& r) {
  producer::Completion c;
  c.family = r.family;
  c.request_seq = r.request_seq;
  c.provenance_origin_seq = r.provenance_origin_seq;
  c.status = Status::OK;
  c.unit = OutputUnit::F32;
  c.finished = true;
  c.bad_element = UINT64_MAX;
  c.output_elements = r.expected_elements;
  c.issued_store_bytes = uint64_t(r.expected_elements) * 4u;
  c.consumed_source_bytes = uint64_t(r.expected_elements) * 4u;
  c.identity = r.identity;
  c.context = r.context;
  c.source = r.source;
  c.destination = r.destination;
  c.D = r.D;
  c.gamma = r.gamma;
  c.source_region = r.source_region;
  c.destination_region = r.destination_region;
  c.source_role = r.source_role;
  c.destination_role = r.destination_role;
  c.eps_bits = r.eps_bits;
  c.row_bytes = r.row_bytes;
  c.source_first_offset = r.source_first_offset;
  c.destination_first_offset = r.destination_first_offset;
  c.source_row_step = r.source_row_step;
  c.destination_row_step = r.destination_row_step;
  return c;
}

} // namespace

int main() {
  using namespace laya;
  producer::Request original = request(), decoded;
  producer::RequestPacket packet = producer::encode(original);
  assert(producer::decode(packet, decoded));

  producer::Completion good = success(original), got;
  producer::CompletionPacket response = producer::encode(good);
  assert(producer::decode(response, original, got));
  assert(producer::same_request_binding(original, got));

  auto bad = packet;
  bad[700] = 1;
  assert(!producer::decode(bad, decoded));
  bad = packet;
  bad[582] = 1;
  assert(!producer::decode(bad, decoded));
  bad = packet;
  bad[368] = 1; // L13M reserved byte 208 relative to identity.
  assert(!producer::decode(bad, decoded));
  bad = packet;
  bad[597] = uint8_t(Bo::ATT_OUT) + 1;
  assert(!producer::decode(bad, decoded));

  auto bad_response = response;
  bad_response[149] ^= 1;
  assert(!producer::decode(bad_response, original, got));
  bad_response = response;
  bad_response[50] = 0;
  assert(!producer::decode(bad_response, original, got));

  producer::Completion failed = success(original);
  failed.status = Status::E_NUMERICAL;
  failed.unit = OutputUnit::NONE;
  failed.output_elements = 0;
  failed.error_detail = detail(7, uint8_t(Op::LN_ATTN), 15);
  failed.bad_element = 2049;
  failed.issued_store_bytes = 4096;
  failed.consumed_source_bytes = 8192;
  Check failure = producer::decode(producer::encode(failed), original, got);
  assert(!failure && failure.code == Status::E_NUMERICAL);
  assert(got.issued_store_bytes == 4096 && got.consumed_source_bytes == 8192);

  failed.finished = false;
  assert(!producer::decode(producer::encode(failed), original, got));

  std::cout << "FULL_CURRENT_PRODUCER_ENGINE_CODEC_PASS checks=10\n";
  return 0;
}
