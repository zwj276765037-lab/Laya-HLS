#pragma once

#include <cstdint>

// D2 diagnostic ABI. Each SHA-256 digest is stored in digest byte order:
// word[first + i] = byte[4*i] | byte[4*i+1]<<8 |
//                   byte[4*i+2]<<16 | byte[4*i+3]<<24.
// This is a little-endian serialization of consecutive digest bytes, not a
// reinterpretation of a host uint32_t array. The build tag uses the same rule.
namespace laya::d2_preload {
constexpr uint32_t kMagic = 0x50514b56u;
constexpr uint32_t kVersion = 1;
constexpr uint32_t kWords = 160;
constexpr uint32_t kBegin = 0;
constexpr uint32_t kRun = 1;
constexpr uint32_t kSourceBytes = 786432;
constexpr uint32_t kPrefixBytes = 10240064;
constexpr uint32_t kHostBytes = 12u << 20;
constexpr uint32_t kDescriptorMasks = 64;
constexpr uint32_t kMaskCount = 48;
constexpr uint32_t kObservedWords = 256;

constexpr uint32_t kObsTicketLo = 224;
constexpr uint32_t kObsTicketHi = 225;
constexpr uint32_t kObsRequestLo = 226;
constexpr uint32_t kObsGenerationLo = 227;
constexpr uint32_t kObsOwner0State = 228;
constexpr uint32_t kObsOwner1State = 229;
constexpr uint32_t kObsCoverageBits = 230;
constexpr uint32_t kObsFinal0Epoch = 231;
constexpr uint32_t kObsFinal1Epoch = 232;
constexpr uint32_t kObsCleanupStatus = 233;
constexpr uint32_t kObsCleanupDetail = 234;
constexpr uint32_t kObsQkElements = 235;
constexpr uint32_t kObsSoftmaxElements = 236;
constexpr uint32_t kObsAvElements = 237;

// detail domain 0xd2, object is command, reason is one of these values.
enum Reason : uint16_t {
  BAD_DESCRIPTOR = 1,
  BAD_SHAPE = 2,
  BAD_IDENTITY = 3,
  BEGIN_PENDING = 4,
  NO_PENDING = 5,
  BAD_TICKET = 6,
  BAD_METADATA = 7,
  BAD_EPOCH = 8,
  TICKET_EXHAUSTED = 9,
  OWNER_INVARIANT = 10,
};
}  // namespace laya::d2_preload
