#pragma once
#include "laya_executor_checkpoint.h"

namespace laya::handoff {
// LHC1: independent control channel, full immutable B echoed in each frame.
// It retains the byte mapping of B, not the LBS2/LBR2 wire header or meaning.
constexpr unsigned kBytes = 1024, kBeats = 16;
constexpr uint32_t kMagic = 0x3143484cu;
constexpr uint16_t kVersion = 1;
constexpr unsigned kSession = 776, kAcceptedRequest = 784, kCommitted = 792;
enum class Kind : uint8_t {
  HOLD = 1, HELD = 2, IMPORT_OK = 3, GRANTED = 4,
  ABORT = 5, ABORT_CLOSED = 6, REJECT = 7,
  CLOSE = 8, CLOSED = 9,
};
struct Message {
  Kind kind = Kind::HOLD;
  uint64_t session = 0, accepted_request = 0;
  checkpoint::Request binding;
  Check result = ok();
  bool local_committed = false;
};
using Packet = std::array<uint8_t, kBytes>;
Check validate(const Message&);
bool same_key(const Message&, const Message&);
Packet encode(const Message&);
Check decode(const Packet&, Message&);
} // namespace laya::handoff
