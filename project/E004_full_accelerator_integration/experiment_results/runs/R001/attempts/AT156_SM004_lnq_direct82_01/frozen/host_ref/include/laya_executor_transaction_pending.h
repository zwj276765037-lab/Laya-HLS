#pragma once
#include "laya_admission_owner.h"
#include "laya_controller_transaction.h"
#include "laya_graph_action_protocol.h"

namespace laya::transaction_pending {
// LTP1 is a private, complete pending snapshot, not an owner/permission table.
// A remains in the unique wrapper's immutable full LAD1 slot. The two index
// words below reference that slot only while every old reference is retained.
constexpr uint32_t kMagic = 0x3150544cu;
constexpr unsigned kVersion = 1, kBytes = 2112, kBeats = 33;
constexpr unsigned kAction = 64, kTransaction = 576;
constexpr uint8_t HAS_HOLD = 1;
struct Key {
  uint64_t session = 0, accepted_request = 0;
  uint64_t source_sequence = 0, handoff_epoch = 0;
  bool has_hold = false;
};
struct Record {
  uint8_t route = 0; // Actual physical source: predecessor0 / executor1.
  Key key;
  action::RequestPacket action_packet{};
  transaction::RequestPacket transaction_packet{};
};
using Packet = std::array<uint8_t, kBytes>;
static_assert(kAction + action::kRequestBytes == kTransaction, "LTP1 action boundary");
static_assert(kTransaction + transaction::kRequestBytes == kBytes, "LTP1 transaction boundary");
static_assert(kBeats * 64 == kBytes, "LTP1 complete fixed frame");

bool same_key(const Key&, const Key&);
// Metadata structure and exact caller-held K/route only; no body/owner proof.
Check validate_metadata(const Record&, const Key& expected, uint8_t expected_route);
// Copies original validated FSM packet bytes verbatim; does not reconstruct
// an LTX from scope, validate bodies, allocate, publish, permit or retire.
Packet encode(const Record&);

// Full APIs require the real transaction Request decoder and external field
// validators. With LAYA_TRANSACTION_SEQUENCER_CODEC, only the metadata/encode
// definitions exist; a FIRST top must never call these unavailable full APIs.
Check validate(const Record&, const admission_owner::Record&, const Key& expected,
               uint8_t expected_route);
Check capture(const Key&, uint8_t route, const action::RequestPacket&,
              const transaction::RequestPacket&, const admission_owner::Record&, Record&);
Check decode(const Packet&, const admission_owner::Record&, const Key& expected,
             uint8_t expected_route, Record&);
// Also matches both complete bodies against the actual retained FSM snapshot.
Check decode(const Packet&, const admission_owner::Record&, const Record& expected, Record&);
bool same_record(const Record&, const Record&);
// A type predicate only. It never grants a hub operation or proves old scope.
bool managed_cleanup_candidate(const transaction::Request&);
bool managed_cleanup_candidate(const Record&);
} // namespace laya::transaction_pending
