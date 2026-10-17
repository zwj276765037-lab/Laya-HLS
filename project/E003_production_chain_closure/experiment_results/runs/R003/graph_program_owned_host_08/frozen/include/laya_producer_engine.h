#pragma once

#include "laya_compute_portal.h"
#include <array>

namespace laya::producer {

// Private caller/producer boundary.  It is internal to the production RTL
// hierarchy and does not change the Host ABI or the four compute/provenance
// FIFOs.  Every field is encoded explicitly; C++ object layout is not a wire
// format.
constexpr unsigned kRequestBytes = 1024, kCompletionBytes = 512;
constexpr unsigned kRequestBeats = 16, kCompletionBeats = 8;
constexpr uint32_t kRequestMagic = 0x3145504cu;    // "LPE1"
constexpr uint32_t kCompletionMagic = 0x3143504cu; // "LPC1"
constexpr uint16_t kVersion = 1;

enum class Family : uint16_t { LAYERNORM = 1 };

struct Request {
  Family family = Family::LAYERNORM;
  uint64_t request_seq = 0;
  uint64_t provenance_origin_seq = 0;
  NumericIdentity identity;
  TaskContext context = portal::zero_context();
  std::array<uint8_t, 416> model_identity{};
  BufferRef source;
  BufferRef destination;
  uint16_t D = 1024;
  uint8_t gamma = 0, source_region = 0, destination_region = 0;
  Bo source_role = Bo::STATE0, destination_role = Bo::STATE0;
  uint32_t eps_bits = 0x3727c5acu;
  uint32_t row_bytes = 4096;
  uint64_t source_first_offset = 0, destination_first_offset = 0;
  uint64_t source_row_step = 4096, destination_row_step = 4096;
  uint64_t source_bo_span = 0, destination_bo_span = 0;
  uint32_t expected_elements = 0;
  OutputUnit expected_unit = OutputUnit::F32;
};

struct Completion {
  Family family = Family::LAYERNORM;
  uint64_t request_seq = 0;
  uint64_t provenance_origin_seq = 0;
  Status status = Status::E_INTERNAL;
  OutputUnit unit = OutputUnit::NONE;
  bool finished = false;
  uint32_t error_detail = 0;
  uint64_t bad_element = UINT64_MAX;
  uint32_t output_elements = 0;
  uint64_t issued_store_bytes = 0, consumed_source_bytes = 0;
  NumericIdentity identity;
  TaskContext context = portal::zero_context();
  BufferRef source;
  BufferRef destination;
  uint16_t D = 1024;
  uint8_t gamma = 0, source_region = 0, destination_region = 0;
  Bo source_role = Bo::STATE0, destination_role = Bo::STATE0;
  uint32_t eps_bits = 0x3727c5acu;
  uint32_t row_bytes = 4096;
  uint64_t source_first_offset = 0, destination_first_offset = 0;
  uint64_t source_row_step = 4096, destination_row_step = 4096;
};

using RequestPacket = std::array<uint8_t, kRequestBytes>;
using CompletionPacket = std::array<uint8_t, kCompletionBytes>;

RequestPacket encode(const Request&);
bool request_fields_valid(const Request&);
Check decode(const RequestPacket&, Request&);
CompletionPacket encode(const Completion&);
Check decode(const CompletionPacket&, const Request&, Completion&);

bool same_request_binding(const Request&, const Completion&);

} // namespace laya::producer
