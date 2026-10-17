#pragma once

#include "laya_compute_portal.h"
#include "laya_full_runtime.h"
#include <array>

namespace laya::action {

// Private program-sequencer/lifecycle-executor boundary.  The packet is a
// semantic action description, not a C object image and not one of the three
// external service protocols.
constexpr unsigned kRequestBytes = 512;
constexpr unsigned kCompletionBytes = 256;
constexpr unsigned kRequestBeats = kRequestBytes / 64;
constexpr unsigned kCompletionBeats = kCompletionBytes / 64;
constexpr uint32_t kRequestMagic = 0x3158414cu;    // "LAX1"
constexpr uint32_t kCompletionMagic = 0x3143414cu; // "LAC1"
constexpr uint16_t kVersion = 1;

enum class Kind : uint8_t {
  EMBED = 0,
  LOAD_GAMMA = 1,
  NORM = 2,
  RELEASE = 3,
  LINEAR = 4,
  ATTENTION = 5,
  RESIDUAL = 6,
  GEGLU_DOWN = 7,
  TYPE_ADD = 8,
  TRANSFORM = 9,
  GATHER = 10,
  LOOKUP_BIAS = 11,
  FP_LINEAR = 12,
  CANDIDATE_MASKED = 13,
  CANDIDATE_PROBABILITY = 14,
  CANDIDATE_STATISTICS = 15,
  ACT_CONCAT = 16,
};

enum RequestFlag : uint32_t {
  CANCEL_CLEANUP = 1u << 0,
  QKV_PAIR = 1u << 1,
  INPLACE = 1u << 2,
};

enum CompletionFlag : uint32_t {
  FRAME_COMPLETE = 1u << 0,
  BINDING_OK = 1u << 1,
  SAFE_TERMINAL = 1u << 2,
  REMOTE_DRAINED = 1u << 3,
  SLOT_UPDATE_VALID = 1u << 4,
  TYPED_RETIRED = 1u << 5,
  LOCAL_REJECT = 1u << 6,
};

struct SlotHandle {
  uint8_t slot = 0;
  uint64_t version = 0;
  full::FullOwnerSpec owner;
};

struct Request {
  Kind kind = Kind::EMBED;
  uint8_t pc = 0;
  Op op = Op::IO_VALIDATE;
  uint8_t stage = 0;
  uint8_t layer = 255;
  uint32_t flags = 0;
  uint64_t ordinal = 0;
  NumericIdentity identity;
  SlotHandle source;
  uint8_t target_slot = 0;
  uint64_t target_slot_version = 0;
  Buffer target_buffer = Buffer::NONE;
  uint8_t target_bank = 0;
  uint8_t target_region = 0;
  WeightKey weight;
  uint8_t gamma = 0;
  uint8_t bias = 0;
  uint16_t length = 0;
  uint16_t K = 0;
  uint16_t N = 0;
};

struct SlotDelta {
  uint8_t slot = 0;
  uint64_t version = 0;
  full::FullOwnerSpec owner;
};

struct Completion {
  Kind kind = Kind::EMBED;
  uint8_t pc = 0;
  Op op = Op::IO_VALIDATE;
  uint8_t stage = 0;
  uint8_t layer = 255;
  uint32_t flags = 0;
  uint64_t ordinal = 0;
  NumericIdentity identity;
  Check result = ok();
  uint32_t first_task_id = 0;
  uint32_t last_task_id = 0;
  uint16_t retired_tasks = 0;
  SlotDelta slot_delta;
};

using RequestPacket = std::array<uint8_t, kRequestBytes>;
using CompletionPacket = std::array<uint8_t, kCompletionBytes>;

bool kind_valid(Kind);
bool same_key(const Request&, const Completion&);
Check validate(const Request&);
Check validate(const Completion&);
RequestPacket encode(const Request&);
Check decode(const RequestPacket&, Request&);
CompletionPacket encode(const Completion&);
Check decode(const CompletionPacket&, Completion&);

} // namespace laya::action
