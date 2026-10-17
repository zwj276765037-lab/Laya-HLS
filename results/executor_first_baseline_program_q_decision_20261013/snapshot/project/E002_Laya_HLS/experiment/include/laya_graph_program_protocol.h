#pragma once

#include "laya_graph_action_protocol.h"
#include <array>

namespace laya::program_wire {

// Accepted-request seed from the unique production shell to the program and
// lifecycle partitions.  This is not a prebuilt graph action: it names one
// bounded program entry point and a versioned source handle; the program owns
// action selection and ordinal allocation.
constexpr unsigned kCommandBytes = 256;
constexpr unsigned kResultBytes = 256;
constexpr unsigned kCommandBeats = kCommandBytes / 64;
constexpr unsigned kResultBeats = kResultBytes / 64;
constexpr uint32_t kCommandMagic = 0x3150474cu; // "LGP1"
constexpr uint32_t kResultMagic = 0x3152474cu;  // "LGR1"
constexpr uint16_t kVersion = 1;

enum class Entrypoint : uint8_t {
  NORM_LAYER1_ATTN = 1,
};

enum CommandFlag : uint32_t {
  SOURCE_READY_PROOF = 1u << 0,
};

enum ResultFlag : uint32_t {
  FRAME_COMPLETE = 1u << 0,
  BINDING_OK = 1u << 1,
  SAFE_TERMINAL = 1u << 2,
  REQUEST_COMPLETE = 1u << 3,
  SLOT_UPDATE_VALID = 1u << 4,
  LOCAL_REJECT = 1u << 5,
};

struct Command {
  Entrypoint entrypoint = Entrypoint::NORM_LAYER1_ATTN;
  uint32_t flags = 0;
  NumericIdentity identity;
  action::SlotHandle source;
};

struct Result {
  Entrypoint entrypoint = Entrypoint::NORM_LAYER1_ATTN;
  uint8_t pc = 0;
  uint32_t flags = 0;
  uint64_t action_ordinal = 0;
  NumericIdentity identity;
  Check result = ok();
  action::SlotDelta slot_delta;
};

using CommandPacket = std::array<uint8_t, kCommandBytes>;
using ResultPacket = std::array<uint8_t, kResultBytes>;

Check validate(const Command&);
Check validate(const Result&);
CommandPacket encode(const Command&);
Check decode(const CommandPacket&, Command&);
ResultPacket encode(const Result&);
Check decode(const ResultPacket&, Result&);

} // namespace laya::program_wire
