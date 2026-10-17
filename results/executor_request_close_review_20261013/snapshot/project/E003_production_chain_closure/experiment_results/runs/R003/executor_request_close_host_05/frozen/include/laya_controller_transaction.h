#pragma once

#include "laya_generated_provenance.h"
#include "laya_producer_engine.h"
#include <array>

namespace laya::transaction {

// Private sequencer/adapter schema.  It carries normalized semantic fields;
// it is deliberately not any of the three external protocol frames.  The
// adapter alone turns one decoded descriptor into one compute, provenance, or
// producer frame.
constexpr unsigned kRequestBytes = 1536, kCompletionBytes = 1024;
constexpr unsigned kRequestBeats = 24, kCompletionBeats = 16;
constexpr uint32_t kRequestMagic = 0x3158544cu;    // "LTX1"
constexpr uint32_t kCompletionMagic = 0x3143544cu; // "LTC1"
constexpr uint16_t kVersion = 1;

enum class Kind : uint16_t {
  COMPUTE_TRANSACTION = 1,
  PROVENANCE_TRANSACTION = 2,
  PRODUCER_TRANSACTION = 3,
};

enum Flag : uint32_t {
  CANCEL_CLEANUP = 1u << 0,
};

enum CompletionFlag : uint32_t {
  FRAME_COMPLETE = 1u << 0,
  BINDING_OK = 1u << 1,
  REMOTE_DRAINED = 1u << 2,
  REMOTE_SCOPE_ACTIVE = 1u << 3,
  REMOTE_TERMINAL = 1u << 4,
  REMOTE_PUBLISHED = 1u << 5,
  LOCAL_REJECT = 1u << 6,
};

struct Request {
  Kind kind = Kind::COMPUTE_TRANSACTION;
  uint32_t flags = 0;
  portal::Command compute;
  provenance::Request provenance;
  producer::Request producer;
};

struct Completion {
  Kind kind = Kind::COMPUTE_TRANSACTION;
  uint32_t flags = 0;
  portal::Response compute;
  provenance::Response provenance;
  producer::Completion producer;
};

using RequestPacket = std::array<uint8_t, kRequestBytes>;
using CompletionPacket = std::array<uint8_t, kCompletionBytes>;

Request make_request(const portal::Command&, uint32_t flags = 0);
Request make_request(const provenance::Request&, uint32_t flags = 0);
Request make_request(const producer::Request&, uint32_t flags = 0);

RequestPacket encode(const Request&);
Check decode(const RequestPacket&, Request&);

Completion make_completion(const Request&, const portal::Response&,
                           bool binding_ok);
Completion make_completion(const Request&, const provenance::Response&,
                           bool binding_ok);
Completion make_completion(const Request&, const producer::Completion&,
                           bool binding_ok);
Completion make_local_reject(const Request&, Check);

CompletionPacket encode(const Completion&);
Check decode(const CompletionPacket&, const Request&, Completion&);

bool completion_frame_complete(const Completion&);
bool completion_binding_ok(const Completion&);
bool completion_safe_terminal(const Completion&);

} // namespace laya::transaction
