#pragma once
#include "laya_graph_program_protocol.h"

namespace laya::program_pending {
// LAP1 is an internal record from the sole program. The four-word key refers
// to the shell's retained full B; the command and allocated pending action are
// copied completely, never reconstructed from an incoming action prefix.
constexpr unsigned kBytes = 1024, kBeats = 16;
constexpr uint32_t kMagic = 0x3150414cu;
constexpr uint16_t kVersion = 1;
constexpr unsigned kCommand = 256, kAction = 512;
struct Key {
  uint64_t session = 0, accepted_request = 0, sequence = 0, handoff = 0;
};
struct Record {
  Key key;
  program_wire::Command command;
  action::Request action;
};
using Packet = std::array<uint8_t, kBytes>;
bool same_key(const Key&, const Key&);
Check validate(const Record&);
Packet encode(const Record&);
Check decode(const Packet&, Record&);
} // namespace laya::program_pending
