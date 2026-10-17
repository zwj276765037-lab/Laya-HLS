#include "laya_producer_engine.h"

namespace laya::producer {
namespace {

Check wire_error(unsigned byte) {
  return {Status::E_ABI, detail(4, 0, 24), byte};
}
Check protocol_error(unsigned byte = 0) {
  return {Status::E_PROTOCOL, detail(7, 0, 24), byte};
}
bool zeros(const uint8_t* p, unsigned first, unsigned end) {
  for (unsigned i = first; i < end; ++i)
    if (p[i]) return false;
  return true;
}
bool same_bytes(const uint8_t* a, const uint8_t* b, unsigned count) {
  for (unsigned i = 0; i < count; ++i)
    if (a[i] != b[i]) return false;
  return true;
}
bool same_identity(const NumericIdentity& a, const NumericIdentity& b) {
  return a.request_id == b.request_id && a.generation == b.generation &&
         a.B == b.B && a.S == b.S &&
         same_bytes(a.model_tag, b.model_tag, 16) &&
         same_bytes(a.numeric_tag, b.numeric_tag, 16) &&
         same_bytes(a.layout_tag, b.layout_tag, 16) &&
         same_bytes(a.build_tag, b.build_tag, 16);
}
bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}
bool l13m_shape(const std::array<uint8_t, 416>& model) {
  const uint8_t* p = model.data();
  if (portal::get(p, 64, 4) != 0x4d33314cu ||
      portal::get(p, 68, 2) != 1 || portal::get(p, 70, 2) != 416 ||
      portal::get(p, 72, 4) != 0 || portal::get(p, 76, 4) != 1 ||
      portal::get(p, 112, 4) != 5 || portal::get(p, 116, 4) != 16 ||
      portal::get(p, 120, 4) != 128 || !zeros(p, 124, 128) ||
      !zeros(p, 208, 416)) return false;
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned off = 128 + 16 * i;
    if (portal::get(p, off, 4) != roles[i] ||
        portal::get(p, off + 4, 4) != 1 ||
        !portal::get(p, off + 8, 8)) return false;
  }
  return true;
}
bool request_ok(const Request& r) {
  if (r.family != Family::LAYERNORM || !r.request_seq ||
      !r.provenance_origin_seq || !numeric_identity_valid(r.identity) ||
      !check_context(r.context, r.identity.B, r.identity.S) ||
      !r.context.task_id || !check_ref(r.source, r.source_region) ||
      !check_ref(r.destination, r.destination_region) ||
      r.D != 1024 || r.gamma > 2 || r.eps_bits != 0x3727c5acu ||
      r.row_bytes != 4096 || !r.context.rows || r.context.rows > 16 ||
      r.expected_elements != uint32_t(r.context.rows) * 1024u ||
      r.expected_unit != OutputUnit::F32 ||
      uint8_t(r.source_role) > uint8_t(Bo::ATT_OUT) ||
      uint8_t(r.destination_role) > uint8_t(Bo::ATT_OUT) ||
      !r.source_bo_span || !r.destination_bo_span ||
      r.source_row_step != 4096 || r.destination_row_step != 4096 ||
      (r.source_first_offset & 63u) || (r.destination_first_offset & 63u) ||
      r.source_first_offset > r.source_bo_span ||
      r.destination_first_offset > r.destination_bo_span ||
      uint64_t(r.row_bytes) > r.source_bo_span - r.source_first_offset ||
      uint64_t(r.row_bytes) >
          r.destination_bo_span - r.destination_first_offset ||
      !l13m_shape(r.model_identity)) return false;
  const uint64_t source_last = r.source_first_offset +
      uint64_t(r.context.rows - 1) * r.source_row_step + r.row_bytes;
  const uint64_t destination_last = r.destination_first_offset +
      uint64_t(r.context.rows - 1) * r.destination_row_step + r.row_bytes;
  return source_last >= r.source_first_offset &&
         destination_last >= r.destination_first_offset &&
         source_last <= r.source_bo_span &&
         destination_last <= r.destination_bo_span;
}

} // namespace

bool request_fields_valid(const Request& r) { return request_ok(r); }

bool same_request_binding(const Request& r, const Completion& c) {
  return c.family == r.family && c.request_seq == r.request_seq &&
         c.provenance_origin_seq == r.provenance_origin_seq &&
         same_identity(c.identity, r.identity) &&
         same_context(c.context, r.context) && c.source == r.source &&
         c.destination == r.destination && c.D == r.D &&
         c.gamma == r.gamma && c.source_region == r.source_region &&
         c.destination_region == r.destination_region &&
         c.source_role == r.source_role &&
         c.destination_role == r.destination_role &&
         c.eps_bits == r.eps_bits && c.row_bytes == r.row_bytes &&
         c.source_first_offset == r.source_first_offset &&
         c.destination_first_offset == r.destination_first_offset &&
         c.source_row_step == r.source_row_step &&
         c.destination_row_step == r.destination_row_step;
}

RequestPacket encode(const Request& r) {
  RequestPacket p{};
  portal::put(p.data(), 0, kRequestMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kRequestBeats, 2);
  portal::put(p.data(), 8, uint16_t(r.family), 2);
  portal::put(p.data(), 12, kCompletionBeats, 2);
  portal::put(p.data(), 16, r.request_seq, 8);
  portal::put(p.data(), 24, r.provenance_origin_seq, 8);
  portal::put_identity(p.data(), 64, r.identity);
  portal::put_context(p.data(), 148, r.context);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    p[160 + i] = r.model_identity[i];
  portal::put_ref(p.data(), 576, r.source, r.source_region);
  portal::put_ref(p.data(), 584, r.destination, r.destination_region);
  portal::put(p.data(), 592, r.D, 2);
  p[594] = r.gamma; p[595] = r.source_region;
  p[596] = r.destination_region; p[597] = uint8_t(r.source_role);
  p[598] = uint8_t(r.destination_role);
  portal::put(p.data(), 600, r.eps_bits, 4);
  portal::put(p.data(), 604, r.row_bytes, 4);
  portal::put(p.data(), 608, r.source_first_offset, 8);
  portal::put(p.data(), 616, r.destination_first_offset, 8);
  portal::put(p.data(), 624, r.source_row_step, 8);
  portal::put(p.data(), 632, r.destination_row_step, 8);
  portal::put(p.data(), 640, r.source_bo_span, 8);
  portal::put(p.data(), 648, r.destination_bo_span, 8);
  portal::put(p.data(), 656, r.expected_elements, 4);
  p[660] = uint8_t(r.expected_unit);
  return p;
}

Check decode(const RequestPacket& p, Request& r) {
  if (portal::get(p.data(), 0, 4) != kRequestMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      portal::get(p.data(), 6, 2) != kRequestBeats ||
      portal::get(p.data(), 8, 2) != uint16_t(Family::LAYERNORM) ||
      portal::get(p.data(), 12, 2) != kCompletionBeats ||
      !zeros(p.data(), 10, 12) || !zeros(p.data(), 14, 16) ||
      !zeros(p.data(), 32, 64) || p[583] || p[591] || p[599] ||
      p[582] != p[595] || p[590] != p[596] ||
      !zeros(p.data(), 661, kRequestBytes)) return wire_error(0);
  r = Request{};
  r.family = Family(portal::get(p.data(), 8, 2));
  r.request_seq = portal::get(p.data(), 16, 8);
  r.provenance_origin_seq = portal::get(p.data(), 24, 8);
  r.identity = portal::get_identity(p.data(), 64);
  r.context = portal::get_context(p.data(), 148);
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    r.model_identity[i] = p[160 + i];
  r.source = portal::get_ref(p.data(), 576);
  r.destination = portal::get_ref(p.data(), 584);
  r.D = uint16_t(portal::get(p.data(), 592, 2));
  r.gamma = p[594]; r.source_region = p[595];
  r.destination_region = p[596]; r.source_role = Bo(p[597]);
  r.destination_role = Bo(p[598]);
  r.eps_bits = uint32_t(portal::get(p.data(), 600, 4));
  r.row_bytes = uint32_t(portal::get(p.data(), 604, 4));
  r.source_first_offset = portal::get(p.data(), 608, 8);
  r.destination_first_offset = portal::get(p.data(), 616, 8);
  r.source_row_step = portal::get(p.data(), 624, 8);
  r.destination_row_step = portal::get(p.data(), 632, 8);
  r.source_bo_span = portal::get(p.data(), 640, 8);
  r.destination_bo_span = portal::get(p.data(), 648, 8);
  r.expected_elements = uint32_t(portal::get(p.data(), 656, 4));
  r.expected_unit = OutputUnit(p[660]);
  return request_fields_valid(r) ? ok() : protocol_error();
}

CompletionPacket encode(const Completion& c) {
  CompletionPacket p{};
  portal::put(p.data(), 0, kCompletionMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kCompletionBeats, 2);
  portal::put(p.data(), 8, uint16_t(c.family), 2);
  portal::put(p.data(), 10, uint16_t(c.status), 2);
  p[12] = uint8_t(c.unit); p[13] = c.finished ? 1 : 0;
  portal::put(p.data(), 16, c.request_seq, 8);
  portal::put(p.data(), 24, c.provenance_origin_seq, 8);
  portal::put(p.data(), 32, c.error_detail, 4);
  portal::put(p.data(), 36, c.output_elements, 4);
  portal::put(p.data(), 40, c.bad_element, 8);
  portal::put(p.data(), 48, c.issued_store_bytes, 8);
  portal::put(p.data(), 56, c.consumed_source_bytes, 8);
  portal::put_identity(p.data(), 64, c.identity);
  portal::put_context(p.data(), 148, c.context);
  portal::put_ref(p.data(), 160, c.source, c.source_region);
  portal::put_ref(p.data(), 168, c.destination, c.destination_region);
  p[176] = uint8_t(c.source_role); p[177] = uint8_t(c.destination_role);
  p[178] = c.source_region; p[179] = c.destination_region;
  portal::put(p.data(), 180, c.D, 2); p[182] = c.gamma;
  portal::put(p.data(), 184, c.eps_bits, 4);
  portal::put(p.data(), 188, c.row_bytes, 4);
  portal::put(p.data(), 192, c.source_first_offset, 8);
  portal::put(p.data(), 200, c.destination_first_offset, 8);
  portal::put(p.data(), 208, c.source_row_step, 8);
  portal::put(p.data(), 216, c.destination_row_step, 8);
  return p;
}

Check decode(const CompletionPacket& p, const Request& expected,
             Completion& c) {
  if (portal::get(p.data(), 0, 4) != kCompletionMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      portal::get(p.data(), 6, 2) != kCompletionBeats ||
      portal::get(p.data(), 8, 2) != uint16_t(Family::LAYERNORM) ||
      portal::get(p.data(), 10, 2) > uint16_t(Status::E_INTERNAL) ||
      p[12] > uint8_t(OutputUnit::BYTES) || p[13] > 1 ||
      !zeros(p.data(), 14, 16) || p[167] || p[175] || p[183] ||
      p[166] != p[178] || p[174] != p[179] ||
      !zeros(p.data(), 224, kCompletionBytes)) return wire_error(0);
  c = Completion{};
  c.family = Family(portal::get(p.data(), 8, 2));
  c.status = Status(portal::get(p.data(), 10, 2));
  c.unit = OutputUnit(p[12]); c.finished = p[13] != 0;
  c.request_seq = portal::get(p.data(), 16, 8);
  c.provenance_origin_seq = portal::get(p.data(), 24, 8);
  c.error_detail = uint32_t(portal::get(p.data(), 32, 4));
  c.output_elements = uint32_t(portal::get(p.data(), 36, 4));
  c.bad_element = portal::get(p.data(), 40, 8);
  c.issued_store_bytes = portal::get(p.data(), 48, 8);
  c.consumed_source_bytes = portal::get(p.data(), 56, 8);
  c.identity = portal::get_identity(p.data(), 64);
  c.context = portal::get_context(p.data(), 148);
  c.source = portal::get_ref(p.data(), 160);
  c.destination = portal::get_ref(p.data(), 168);
  c.source_role = Bo(p[176]); c.destination_role = Bo(p[177]);
  c.source_region = p[178]; c.destination_region = p[179];
  c.D = uint16_t(portal::get(p.data(), 180, 2)); c.gamma = p[182];
  c.eps_bits = uint32_t(portal::get(p.data(), 184, 4));
  c.row_bytes = uint32_t(portal::get(p.data(), 188, 4));
  c.source_first_offset = portal::get(p.data(), 192, 8);
  c.destination_first_offset = portal::get(p.data(), 200, 8);
  c.source_row_step = portal::get(p.data(), 208, 8);
  c.destination_row_step = portal::get(p.data(), 216, 8);
  if (!same_request_binding(expected, c) || !c.finished ||
      c.issued_store_bytes > uint64_t(expected.expected_elements) * 4u ||
      c.consumed_source_bytes > uint64_t(expected.expected_elements) * 4u)
    return protocol_error();
  if (c.status == Status::OK) {
    if (c.unit != expected.expected_unit ||
        c.output_elements != expected.expected_elements ||
        c.error_detail || c.bad_element != UINT64_MAX ||
        c.issued_store_bytes != uint64_t(expected.expected_elements) * 4u ||
        c.consumed_source_bytes != uint64_t(expected.expected_elements) * 4u)
      return protocol_error();
  } else if (c.unit != OutputUnit::NONE || c.output_elements) {
    return protocol_error();
  }
  return {c.status, c.error_detail, c.bad_element};
}

} // namespace laya::producer
