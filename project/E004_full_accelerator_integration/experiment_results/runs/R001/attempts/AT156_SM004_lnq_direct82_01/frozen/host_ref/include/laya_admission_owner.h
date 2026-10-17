#pragma once

#include "laya_executor_bootstrap.h"

namespace laya::admission_owner {
// Internal complete A, independent of HOLD/S/H. Unknown physical roles stay
// zero and cannot authorize any access. This is not part of the Host ABI.
constexpr uint32_t kMagic = 0x3144414cu; // LAD1
constexpr unsigned kBytes = 1024, kBeats = 16, kVersion = 1;
constexpr unsigned kIdentity = 64, kModel = 160, kMappings = 576;
constexpr unsigned kRoles = 13, kMappingBytes = 24, kReserved = 888;
constexpr uint32_t kAllRoles = (1u << kRoles) - 1;
constexpr uint32_t kKnownComplete = 3;
struct Mapping {
  uint64_t epoch = 0, address = 0, capacity = 0;
};
struct PhysicalMap {
  uint32_t known_roles = 0;
  Mapping role[kRoles];
};
struct Record {
  uint64_t session = 0, accepted_request = 0;
  NumericIdentity identity;
  std::array<uint8_t,416> model_identity{};
  PhysicalMap physical;
};
using Packet = std::array<uint8_t,kBytes>;
Check validate(const Record&);
Packet encode(const Record&);
Check decode(const Packet&,Record&);
// Must be called on the unique runtime after real LYRQ/LYMP admission. It
// samples complete admitted identity/model plus locked physical configuration;
// it does not begin a request, reserve numbers, publish owners or retire work.
Check capture(const full::FullRuntime&,const full::FullMemory&,
              uint64_t session,uint64_t accepted_request,
              const PhysicalMap&,Record&);
bool same(const Record&,const Record&);
} // namespace laya::admission_owner
