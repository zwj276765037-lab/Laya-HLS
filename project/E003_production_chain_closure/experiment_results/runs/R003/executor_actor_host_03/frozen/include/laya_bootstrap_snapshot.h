#pragma once

#include "laya_generated_provenance.h"
#include "laya_compute_portal_client.h"

namespace laya::bootstrap {

constexpr unsigned kBytes = 768, kBeats = 12;
constexpr uint32_t kRequestMagic = 0x3153424cu;  // LBS1
constexpr uint32_t kResponseMagic = 0x3152424cu; // LBR1
constexpr uint16_t kVersion = 1;
constexpr unsigned kIdentity = 64, kModel = 160, kOwner = 576;
enum class Purpose : uint16_t { NORM_LAYER1_ATTN = 1 };
enum Flag : uint32_t {
  FRAME_COMPLETE = 1, BINDING_OK = 2, SOURCE_MATCH = 4,
  PUBLISHED = 8, COMPLETE = 16, QUIESCENT = 32,
};
constexpr uint32_t kSuccessFlags = FRAME_COMPLETE | BINDING_OK |
    SOURCE_MATCH | PUBLISHED | COMPLETE | QUIESCENT;

struct Request {
  Purpose purpose = Purpose::NORM_LAYER1_ATTN;
  uint64_t sequence = 0, base_epoch = 0, base_address = 0, base_capacity = 0;
  NumericIdentity identity;
  std::array<uint8_t, 416> model_identity{};
  provenance::OwnerDescriptor source;
};

struct Response {
  Request binding;
  Check result = {Status::E_INTERNAL, 0, UINT64_MAX};
  uint32_t flags = 0;
};

using Packet = std::array<uint8_t, kBytes>;
Check validate(const Request&);
bool same_binding(const Request&, const Request&);
Packet encode(const Request&);
Packet encode(const Response&);
Check decode(const Packet&, Request&);
// A valid, bound non-OK response keeps its status/binding but grants no source
// capability.  Any syntax or binding rejection leaves a default output.
Check decode(const Packet&, const Request&, Response&);

} // namespace laya::bootstrap
