#pragma once

#include "laya_executor_bootstrap.h"

namespace laya::checkpoint {
// LBS2/LBR2 is a distinct diagnostic protocol. Bytes 0..663 retain the
// source binding mapping; v1 reserved bytes never gain v2 meaning.
constexpr unsigned kBytes = 1024, kBeats = 16;
constexpr uint32_t kRequestMagic = 0x3253424cu, kResponseMagic = 0x3252424cu;
constexpr uint16_t kVersion = 2, kMode = 1;
constexpr unsigned kModeOffset = 672, kTarget = 674, kTargetState = 678;
constexpr unsigned kHandoff = 680, kTargetBase = 688, kKnown = 744;
constexpr unsigned kComplete = 748, kTask = 752, kSourceEpoch = 756;
constexpr unsigned kTargetEpoch = 760, kLpv = 768;
enum Domain : uint32_t { TASK = 1, LPV = 2, SOURCE = 4, TARGET = 8 };
constexpr uint32_t kDomains = TASK | LPV | SOURCE | TARGET;
enum Flag : uint32_t { FRONTIER_COMPLETE = 64, DISPATCH_HELD = 128 };
constexpr uint32_t kSuccessFlags = bootstrap::kSuccessFlags |
    FRONTIER_COMPLETE | DISPATCH_HELD;
enum class TargetState : uint8_t { UNKNOWN = 0, UNUSED = 1, INACTIVE = 2, ACTIVE = 3 };
struct TargetDomain {
  Buffer buffer = Buffer::NONE;
  uint8_t bank = 0, region = 0;
  Bo role = Bo::IO;
  uint64_t base_epoch = 0, base_address = 0, capacity = 0;
  uint64_t offset = 0, extent = 0, row_stride = 0, batch_stride = 0;
};
struct Request {
  bootstrap::Request source;
  uint16_t mode = kMode;
  uint64_t handoff_epoch = 0;
  TargetDomain target;
};
struct Response {
  Request binding;
  Check result = {Status::E_INTERNAL, 0, UINT64_MAX};
  uint32_t flags = 0, known = 0, complete = 0;
  uint32_t task_floor = 0, source_epoch_floor = 0, target_epoch_floor = 0;
  uint64_t lpv_floor = 0;
  TargetState target_state = TargetState::UNKNOWN;
};
using Packet = std::array<uint8_t, kBytes>;
Check validate(const Request&);
// Immutable B before the shell allocates H; it grants no authority.
Check validate_description(const Request&);
Check validate(const Response&);
bool same_binding(const Request&, const Request&);
Packet encode(const Request&);
Packet encode(const Response&);
Check decode(const Packet&, Request&);
Check decode(const Packet&, const Request&, Response&);

struct State {
  bootstrap::Phase phase = bootstrap::Phase::IDLE;
  uint64_t sequence_high_water = 0, handoff_high_water = 0;
  Request pending;
  bool hold_reserved = false;
};
// Facts from the unique shell. Source and target are held across the snapshot
// and first CLAIM; old cleanup must drain before predecessor dispatch is held.
struct Fence {
  bootstrap::BaseBinding base;
  uint64_t handoff_epoch = 0;
  bool physical_quiescent = false, predecessor_dispatch_held = false;
  bool source_held = false, target_held = false, cancel = false;
};
Check prepare(State&, const lifecycle::Port&, const full::FullRuntime&,
              const full::FullMemory&, BufferRef source, const Fence&, Request&);
Check reserve_hold(State&, const lifecycle::Port&, const full::FullRuntime&,
                   const full::FullMemory&, BufferRef source,
                   const bootstrap::BaseBinding&, Request&);
Check prepare_held(State&, const lifecycle::Port&, const full::FullRuntime&,
                   const full::FullMemory&, const Request& held,
                   const Fence&, Request&);
// Validates all fields, capacity and allocator increments before committing.
// No retirement or owner publication is performed by this diagnostic import.
Check accept(State&, const lifecycle::Port&, full::FullRuntime&,
             const Response&, const Fence&, program_wire::Command&);
} // namespace laya::checkpoint
