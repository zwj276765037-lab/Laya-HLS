#include "laya_graph_program_protocol.h"
#include "laya_graph_program_sequencer.h"

namespace laya::program_wire {
namespace {

constexpr unsigned kIdentity = 64;
constexpr unsigned kSource = 160;
constexpr unsigned kResultStatus = 148;
constexpr unsigned kResultSlot = 176;

Check protocol(unsigned reason = 14) {
  return {Status::E_PROTOCOL, detail(7, 0, uint16_t(reason))};
}

bool zeros(const uint8_t* p, unsigned first, unsigned after) {
  for (unsigned i = first; i < after; ++i)
    if (p[i]) return false;
  return true;
}

void put_owner(uint8_t* p, const full::FullOwnerSpec& owner) {
  portal::put_ref(p, 0, owner.ref, owner.region);
  p[8] = owner.stage;
  p[9] = owner.layer;
  p[10] = owner.batch;
  p[11] = uint8_t(owner.row_space);
  portal::put(p, 12, owner.row0, 2);
  portal::put(p, 14, owner.rows, 2);
  portal::put(p, 16, owner.width, 2);
  p[18] = uint8_t(owner.content);
}

full::FullOwnerSpec get_owner(const uint8_t* p) {
  full::FullOwnerSpec owner;
  owner.ref = portal::get_ref(p, 0);
  owner.region = p[6];
  owner.stage = p[8];
  owner.layer = p[9];
  owner.batch = p[10];
  owner.row_space = RowSpace(p[11]);
  owner.row0 = uint16_t(portal::get(p, 12, 2));
  owner.rows = uint16_t(portal::get(p, 14, 2));
  owner.width = uint16_t(portal::get(p, 16, 2));
  owner.content = Content(p[18]);
  return owner;
}

bool entrypoint_valid(Entrypoint entrypoint) {
  return entrypoint == Entrypoint::NORM_LAYER1_ATTN;
}

} // namespace

Check validate(const Command& command) {
  const full::FullOwnerSpec& source = command.source.owner;
  if (!entrypoint_valid(command.entrypoint) ||
      command.flags != SOURCE_READY_PROOF ||
      !numeric_identity_valid(command.identity) || command.source.slot != 0 ||
      !command.source.version || command.source.version != source.ref.epoch ||
      !check_ref(source.ref, source.region) || source.ref.id != Buffer::HIDDEN ||
      source.ref.bank != 0 || source.region != 0 || source.batch != 255 ||
      source.row_space != RowSpace::TOKEN || source.row0 != 0 ||
      source.rows != command.identity.S || source.width != 1024 ||
      source.content != Content::F32)
    return protocol(9);
  return ok();
}

Check validate(const Result& result) {
  constexpr uint32_t all = FRAME_COMPLETE | BINDING_OK | SAFE_TERMINAL |
      REQUEST_COMPLETE | SLOT_UPDATE_VALID | LOCAL_REJECT;
  if (!entrypoint_valid(result.entrypoint) || result.flags & ~all)
    return protocol(9);
  if (uint16_t(result.result.code) > uint16_t(Status::E_INTERNAL) ||
      ((result.flags & LOCAL_REJECT) && result.result))
    return protocol(9);
  if (result.flags & BINDING_OK) {
    if (!numeric_identity_valid(result.identity)) return protocol(9);
  } else if ((result.flags & SLOT_UPDATE_VALID) ||
             ((result.flags & REQUEST_COMPLETE) &&
              !(result.flags & LOCAL_REJECT))) {
    return protocol(14);
  }
  if (result.flags & LOCAL_REJECT) {
    if (!(result.flags & SAFE_TERMINAL) ||
        !(result.flags & REQUEST_COMPLETE) ||
        (result.flags & SLOT_UPDATE_VALID))
      return protocol(14);
  }
  if (result.flags & REQUEST_COMPLETE) {
    if (!(result.flags & SAFE_TERMINAL) ||
        (!(result.flags & LOCAL_REJECT) && !result.action_ordinal))
      return protocol(14);
  }
  if (result.flags & SLOT_UPDATE_VALID) {
    if (!(result.flags & REQUEST_COMPLETE) || !result.result ||
        result.slot_delta.slot >= program::kGraphSlots ||
        !result.slot_delta.version ||
        !check_ref(result.slot_delta.owner.ref,
                   result.slot_delta.owner.region) ||
        result.slot_delta.owner.ref.id == Buffer::NONE)
      return protocol(14);
  }
  return ok();
}

CommandPacket encode(const Command& command) {
  CommandPacket packet{};
  portal::put(packet.data(), 0, kCommandMagic, 4);
  portal::put(packet.data(), 4, kVersion, 2);
  portal::put(packet.data(), 6, kCommandBeats, 2);
  packet[8] = uint8_t(command.entrypoint);
  packet[9] = command.source.slot;
  portal::put(packet.data(), 16, command.flags, 4);
  portal::put_identity(packet.data(), kIdentity, command.identity);
  portal::put(packet.data(), kSource, command.source.version, 8);
  put_owner(packet.data() + kSource + 8, command.source.owner);
  return packet;
}

Check decode(const CommandPacket& packet, Command& command) {
  command = Command{};
  const uint8_t* p = packet.data();
  if (portal::get(p, 0, 4) != kCommandMagic ||
      portal::get(p, 4, 2) != kVersion ||
      portal::get(p, 6, 2) != kCommandBeats ||
      !zeros(p, 10, 16) || !zeros(p, 20, kIdentity) ||
      !zeros(p, 148, kSource) || !zeros(p, kSource + 27, kCommandBytes) ||
      p[kSource + 15])
    return protocol();
  Command decoded;
  decoded.entrypoint = Entrypoint(p[8]);
  decoded.source.slot = p[9];
  decoded.flags = uint32_t(portal::get(p, 16, 4));
  decoded.identity = portal::get_identity(p, kIdentity);
  decoded.source.version = portal::get(p, kSource, 8);
  decoded.source.owner = get_owner(p + kSource + 8);
  Check valid = validate(decoded);
  if (!valid) return valid;
  command = decoded;
  return ok();
}

ResultPacket encode(const Result& result) {
  ResultPacket packet{};
  portal::put(packet.data(), 0, kResultMagic, 4);
  portal::put(packet.data(), 4, kVersion, 2);
  portal::put(packet.data(), 6, kResultBeats, 2);
  packet[8] = uint8_t(result.entrypoint);
  packet[9] = result.pc;
  portal::put(packet.data(), 16, result.flags, 4);
  portal::put(packet.data(), 24, result.action_ordinal, 8);
  portal::put_identity(packet.data(), kIdentity, result.identity);
  portal::put(packet.data(), kResultStatus, uint16_t(result.result.code), 2);
  portal::put(packet.data(), kResultStatus + 4, result.result.detail, 4);
  portal::put(packet.data(), kResultStatus + 8, result.result.bad_element, 8);
  packet[kResultSlot] = result.slot_delta.slot;
  portal::put(packet.data(), kResultSlot + 8, result.slot_delta.version, 8);
  put_owner(packet.data() + kResultSlot + 16, result.slot_delta.owner);
  return packet;
}

Check decode(const ResultPacket& packet, Result& result) {
  result = Result{};
  const uint8_t* p = packet.data();
  if (portal::get(p, 0, 4) != kResultMagic ||
      portal::get(p, 4, 2) != kVersion ||
      portal::get(p, 6, 2) != kResultBeats ||
      !zeros(p, 10, 16) || !zeros(p, 20, 24) ||
      !zeros(p, 32, kIdentity) || !zeros(p, kResultStatus + 2,
                                        kResultStatus + 4) ||
      !zeros(p, 164, kResultSlot) || !zeros(p, kResultSlot + 1,
                                            kResultSlot + 8) ||
      p[kResultSlot + 23] || !zeros(p, kResultSlot + 35, kResultBytes))
    return protocol();
  Result decoded;
  decoded.entrypoint = Entrypoint(p[8]);
  decoded.pc = p[9];
  decoded.flags = uint32_t(portal::get(p, 16, 4));
  decoded.action_ordinal = portal::get(p, 24, 8);
  decoded.identity = portal::get_identity(p, kIdentity);
  decoded.result.code = Status(portal::get(p, kResultStatus, 2));
  decoded.result.detail = uint32_t(portal::get(p, kResultStatus + 4, 4));
  decoded.result.bad_element = portal::get(p, kResultStatus + 8, 8);
  decoded.slot_delta.slot = p[kResultSlot];
  decoded.slot_delta.version = portal::get(p, kResultSlot + 8, 8);
  decoded.slot_delta.owner = get_owner(p + kResultSlot + 16);
  Check valid = validate(decoded);
  if (!valid) return valid;
  result = decoded;
  return ok();
}

} // namespace laya::program_wire
