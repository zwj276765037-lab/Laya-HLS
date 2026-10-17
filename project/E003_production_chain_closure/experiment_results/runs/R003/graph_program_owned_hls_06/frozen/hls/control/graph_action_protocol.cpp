#include "laya_graph_action_protocol.h"

namespace laya::action {
namespace {

constexpr unsigned kIdentity = 64;
constexpr unsigned kSource = 160;
constexpr unsigned kTarget = 224;
constexpr unsigned kParameters = 256;

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

bool same_identity(const NumericIdentity& a, const NumericIdentity& b) {
  return numeric_identity_equal(a, b);
}

void put_key(uint8_t* p, Kind kind, uint8_t pc, Op op, uint8_t stage,
             uint8_t layer, uint32_t flags, uint64_t ordinal,
             const NumericIdentity& identity, uint32_t magic,
             unsigned beats) {
  portal::put(p, 0, magic, 4);
  portal::put(p, 4, kVersion, 2);
  portal::put(p, 6, beats, 2);
  p[8] = uint8_t(kind);
  p[9] = pc;
  p[10] = uint8_t(op);
  p[11] = stage;
  p[12] = layer;
  portal::put(p, 16, flags, 4);
  portal::put(p, 24, ordinal, 8);
  portal::put_identity(p, kIdentity, identity);
}

bool key_header(const uint8_t* p, uint32_t magic, unsigned beats) {
  return portal::get(p, 0, 4) == magic &&
         portal::get(p, 4, 2) == kVersion &&
         portal::get(p, 6, 2) == beats && p[13] == 0 && p[14] == 0 &&
         p[15] == 0 && zeros(p, 20, 24) && zeros(p, 32, kIdentity);
}

void get_key(const uint8_t* p, Kind& kind, uint8_t& pc, Op& op,
             uint8_t& stage, uint8_t& layer, uint32_t& flags,
             uint64_t& ordinal, NumericIdentity& identity) {
  kind = Kind(p[8]);
  pc = p[9];
  op = Op(p[10]);
  stage = p[11];
  layer = p[12];
  flags = uint32_t(portal::get(p, 16, 4));
  ordinal = portal::get(p, 24, 8);
  identity = portal::get_identity(p, kIdentity);
}

} // namespace

bool kind_valid(Kind kind) {
  return uint8_t(kind) <= uint8_t(Kind::ACT_CONCAT);
}

bool same_key(const Request& request, const Completion& completion) {
  return request.kind == completion.kind && request.pc == completion.pc &&
         request.op == completion.op && request.stage == completion.stage &&
         request.layer == completion.layer &&
         request.ordinal == completion.ordinal &&
         same_identity(request.identity, completion.identity);
}

Check validate(const Request& request) {
  if (!kind_valid(request.kind) || !request.ordinal ||
      !numeric_identity_valid(request.identity) || request.source.slot >= 22 ||
      request.target_slot >= 22 || !request.source.version ||
      !check_ref(request.source.owner.ref, request.source.owner.region) ||
      request.source.owner.ref.id == Buffer::NONE ||
      !request.target_slot_version || request.target_buffer == Buffer::NONE ||
      request.target_bank > 1 || request.flags & ~(CANCEL_CLEANUP | QKV_PAIR | INPLACE))
    return protocol(9);
  if (request.kind == Kind::NORM) {
    if ((request.op != Op::LN_ATTN && request.op != Op::LN_FFN) ||
        (request.stage != 2 && request.stage != 4) || request.layer > 27 ||
        request.source.owner.content != Content::F32 ||
        request.source.owner.width != 1024 ||
        request.source.owner.row_space != RowSpace::TOKEN ||
        request.target_buffer != Buffer::NORM || request.target_region ||
        request.gamma != 0 || request.length || request.K || request.N ||
        request.weight.family || request.weight.layer != 255 || request.bias ||
        request.flags)
      return protocol(5);
  }
  return ok();
}

Check validate(const Completion& completion) {
  constexpr uint32_t all = FRAME_COMPLETE | BINDING_OK | SAFE_TERMINAL |
      REMOTE_DRAINED | SLOT_UPDATE_VALID | TYPED_RETIRED | LOCAL_REJECT;
  if (!kind_valid(completion.kind) || !completion.ordinal ||
      uint16_t(completion.result.code) > uint16_t(Status::E_INTERNAL) ||
      !numeric_identity_valid(completion.identity) || completion.flags & ~all)
    return protocol(9);
  if ((completion.flags & LOCAL_REJECT) && completion.result)
    return protocol(14);
  if (completion.flags & SLOT_UPDATE_VALID) {
    if (completion.slot_delta.slot >= 22 || !completion.slot_delta.version ||
        !check_ref(completion.slot_delta.owner.ref,
                   completion.slot_delta.owner.region) ||
        completion.slot_delta.owner.ref.id == Buffer::NONE)
      return protocol(9);
  }
  if (completion.result &&
      (completion.flags & (FRAME_COMPLETE | BINDING_OK | SAFE_TERMINAL |
                           REMOTE_DRAINED)) !=
          (FRAME_COMPLETE | BINDING_OK | SAFE_TERMINAL | REMOTE_DRAINED))
    return protocol(14);
  return ok();
}

RequestPacket encode(const Request& request) {
  RequestPacket packet{};
  put_key(packet.data(), request.kind, request.pc, request.op, request.stage,
          request.layer, request.flags, request.ordinal, request.identity,
          kRequestMagic, kRequestBeats);
  packet[kSource] = request.source.slot;
  portal::put(packet.data(), kSource + 8, request.source.version, 8);
  put_owner(packet.data() + kSource + 16, request.source.owner);
  packet[kTarget] = request.target_slot;
  packet[kTarget + 1] = uint8_t(request.target_buffer);
  packet[kTarget + 2] = request.target_bank;
  packet[kTarget + 3] = request.target_region;
  portal::put(packet.data(), kTarget + 8, request.target_slot_version, 8);
  packet[kParameters] = request.weight.family;
  packet[kParameters + 1] = request.weight.layer;
  packet[kParameters + 2] = request.gamma;
  packet[kParameters + 3] = request.bias;
  portal::put(packet.data(), kParameters + 4, request.length, 2);
  portal::put(packet.data(), kParameters + 6, request.K, 2);
  portal::put(packet.data(), kParameters + 8, request.N, 2);
  return packet;
}

Check decode(const RequestPacket& packet, Request& request) {
  request = Request{};
  const uint8_t* p = packet.data();
  if (!key_header(p, kRequestMagic, kRequestBeats) ||
      !zeros(p, 148, kSource) || !zeros(p, kSource + 35, kTarget) ||
      !zeros(p, kTarget + 16, kParameters) ||
      !zeros(p, kParameters + 10, kRequestBytes) ||
      p[kSource + 1] || !zeros(p, kSource + 2, kSource + 8) ||
      p[kSource + 23] || !zeros(p, kSource + 35, kTarget) ||
      !zeros(p, kTarget + 4, kTarget + 8) ||
      !zeros(p, kTarget + 16, kParameters))
    return protocol();
  get_key(p, request.kind, request.pc, request.op, request.stage,
          request.layer, request.flags, request.ordinal, request.identity);
  request.source.slot = p[kSource];
  request.source.version = portal::get(p, kSource + 8, 8);
  request.source.owner = get_owner(p + kSource + 16);
  request.target_slot = p[kTarget];
  request.target_buffer = Buffer(p[kTarget + 1]);
  request.target_bank = p[kTarget + 2];
  request.target_region = p[kTarget + 3];
  request.target_slot_version = portal::get(p, kTarget + 8, 8);
  request.weight.family = p[kParameters];
  request.weight.layer = p[kParameters + 1];
  request.gamma = p[kParameters + 2];
  request.bias = p[kParameters + 3];
  request.length = uint16_t(portal::get(p, kParameters + 4, 2));
  request.K = uint16_t(portal::get(p, kParameters + 6, 2));
  request.N = uint16_t(portal::get(p, kParameters + 8, 2));
  return validate(request);
}

CompletionPacket encode(const Completion& completion) {
  CompletionPacket packet{};
  put_key(packet.data(), completion.kind, completion.pc, completion.op,
          completion.stage, completion.layer, completion.flags,
          completion.ordinal, completion.identity, kCompletionMagic,
          kCompletionBeats);
  portal::put(packet.data(), 148, uint16_t(completion.result.code), 2);
  portal::put(packet.data(), 152, completion.result.detail, 4);
  portal::put(packet.data(), 156, completion.result.bad_element, 8);
  portal::put(packet.data(), 164, completion.first_task_id, 4);
  portal::put(packet.data(), 168, completion.last_task_id, 4);
  portal::put(packet.data(), 172, completion.retired_tasks, 2);
  packet[176] = completion.slot_delta.slot;
  portal::put(packet.data(), 184, completion.slot_delta.version, 8);
  put_owner(packet.data() + 192, completion.slot_delta.owner);
  return packet;
}

Check decode(const CompletionPacket& packet, Completion& completion) {
  completion = Completion{};
  const uint8_t* p = packet.data();
  if (!key_header(p, kCompletionMagic, kCompletionBeats) ||
      !zeros(p, 148 + 2, 152) || !zeros(p, 174, 176) ||
      !zeros(p, 177, 184) || p[199] || !zeros(p, 211, kCompletionBytes))
    return protocol();
  Completion decoded;
  get_key(p, decoded.kind, decoded.pc, decoded.op, decoded.stage,
          decoded.layer, decoded.flags, decoded.ordinal, decoded.identity);
  decoded.result.code = Status(portal::get(p, 148, 2));
  decoded.result.detail = uint32_t(portal::get(p, 152, 4));
  decoded.result.bad_element = portal::get(p, 156, 8);
  decoded.first_task_id = uint32_t(portal::get(p, 164, 4));
  decoded.last_task_id = uint32_t(portal::get(p, 168, 4));
  decoded.retired_tasks = uint16_t(portal::get(p, 172, 2));
  decoded.slot_delta.slot = p[176];
  decoded.slot_delta.version = portal::get(p, 184, 8);
  decoded.slot_delta.owner = get_owner(p + 192);
  Check valid = validate(decoded);
  if (!valid) return valid;
  completion = decoded;
  return ok();
}

} // namespace laya::action
