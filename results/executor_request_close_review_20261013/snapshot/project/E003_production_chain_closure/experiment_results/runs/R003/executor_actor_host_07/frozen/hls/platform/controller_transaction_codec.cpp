#include "laya_controller_transaction.h"

namespace laya::transaction {
namespace {

constexpr unsigned COMMON_IDENTITY = 64;
constexpr unsigned COMMON_CONTEXT = 148;
constexpr unsigned COMMON_MODEL = 160;
constexpr unsigned PAYLOAD = 576;

Check protocol_error(uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, 0, reason)};
}

Check completion_protocol_error(Completion& completion,
                                uint16_t reason = 14) {
  completion = Completion{};
  return protocol_error(reason);
}

bool zeros(const uint8_t* p, unsigned first, unsigned after) {
  for (unsigned i = first; i < after; ++i)
    if (p[i]) return false;
  return true;
}

bool valid_kind(uint64_t value) {
  return value >= uint16_t(Kind::COMPUTE_TRANSACTION) &&
         value <= uint16_t(Kind::PRODUCER_TRANSACTION);
}

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
      a.layer == b.layer && a.batch == b.batch &&
      a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

// The graph sequencer must not pull the three external wire codecs into its
// HLS closure merely to validate the adapter's already-decoded completion.
// Keep the fixed semantic binding comparison here so the sequencer build can
// use only the normalized transaction schema.  The adapter build still runs
// the complete external encode/decode validators below.
bool same_producer_binding(const producer::Request& r,
                           const producer::Completion& c) {
  return c.family == r.family && c.request_seq == r.request_seq &&
      c.provenance_origin_seq == r.provenance_origin_seq &&
      numeric_identity_equal(c.identity, r.identity) &&
      same_context(c.context, r.context) && c.source == r.source &&
      c.destination == r.destination &&
      c.source_region == r.source_region &&
      c.destination_region == r.destination_region &&
      c.source_role == r.source_role &&
      c.destination_role == r.destination_role && c.D == r.D &&
      c.gamma == r.gamma && c.eps_bits == r.eps_bits &&
      c.row_bytes == r.row_bytes &&
      c.source_first_offset == r.source_first_offset &&
      c.destination_first_offset == r.destination_first_offset &&
      c.source_row_step == r.source_row_step &&
      c.destination_row_step == r.destination_row_step;
}

uint16_t protocol_of(const Request& r) {
  switch (r.kind) {
    case Kind::COMPUTE_TRANSACTION: return uint16_t(r.compute.service);
    case Kind::PROVENANCE_TRANSACTION: return uint16_t(r.provenance.action);
    case Kind::PRODUCER_TRANSACTION: return uint16_t(r.producer.family);
  }
  return 0;
}

uint16_t protocol_of(const Completion& c) {
  switch (c.kind) {
    case Kind::COMPUTE_TRANSACTION: return uint16_t(c.compute.service);
    case Kind::PROVENANCE_TRANSACTION: return uint16_t(c.provenance.action);
    case Kind::PRODUCER_TRANSACTION: return uint16_t(c.producer.family);
  }
  return 0;
}

uint64_t seq_of(const Request& r) {
  switch (r.kind) {
    case Kind::COMPUTE_TRANSACTION: return r.compute.generation;
    case Kind::PROVENANCE_TRANSACTION: return r.provenance.event_seq;
    case Kind::PRODUCER_TRANSACTION: return r.producer.request_seq;
  }
  return 0;
}

uint64_t origin_of(const Request& r) {
  switch (r.kind) {
    case Kind::COMPUTE_TRANSACTION: return 0;
    case Kind::PROVENANCE_TRANSACTION: return r.provenance.origin_seq;
    case Kind::PRODUCER_TRANSACTION: return r.producer.provenance_origin_seq;
  }
  return 0;
}

const NumericIdentity& identity_of(const Request& r) {
  if (r.kind == Kind::COMPUTE_TRANSACTION) return r.compute.identity;
  if (r.kind == Kind::PROVENANCE_TRANSACTION) return r.provenance.identity;
  return r.producer.identity;
}

const TaskContext& context_of(const Request& r) {
  if (r.kind == Kind::COMPUTE_TRANSACTION) return r.compute.context;
  if (r.kind == Kind::PROVENANCE_TRANSACTION) return r.provenance.context;
  return r.producer.context;
}

const std::array<uint8_t, 416>& model_of(const Request& r) {
  if (r.kind == Kind::COMPUTE_TRANSACTION) return r.compute.model_identity;
  if (r.kind == Kind::PROVENANCE_TRANSACTION)
    return r.provenance.model_identity;
  return r.producer.model_identity;
}

void put_descriptor(uint8_t* p, const provenance::OwnerDescriptor& d) {
  portal::put_ref(p, 0, d.target_ref);
  portal::put_ref(p, 8, d.old_ref);
  p[16] = d.target_region; p[17] = d.old_region;
  p[18] = d.stage; p[19] = d.layer; p[20] = d.batch;
  p[21] = uint8_t(d.row_space);
  portal::put(p, 22, d.row0, 2); portal::put(p, 24, d.rows, 2);
  portal::put(p, 26, d.width, 2); p[28] = uint8_t(d.content);
  p[29] = d.layout; p[30] = uint8_t(d.role);
  portal::put(p, 32, d.bo_span, 8);
  portal::put(p, 40, d.owner_base_offset, 8);
  portal::put(p, 48, d.row_stride, 8);
  portal::put(p, 56, d.batch_stride, 8);
  portal::put(p, 64, d.owner_extent_span, 8);
  portal::put(p, 72, d.head_stride, 8);
  portal::put(p, 80, d.plane_stride, 8);
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
provenance::OwnerDescriptor get_descriptor(const uint8_t* p) {
  provenance::OwnerDescriptor d;
  d.target_ref = portal::get_ref(p, 0); d.old_ref = portal::get_ref(p, 8);
  d.target_region = p[16]; d.old_region = p[17];
  d.stage = p[18]; d.layer = p[19]; d.batch = p[20];
  d.row_space = RowSpace(p[21]); d.row0 = uint16_t(portal::get(p, 22, 2));
  d.rows = uint16_t(portal::get(p, 24, 2));
  d.width = uint16_t(portal::get(p, 26, 2));
  d.content = Content(p[28]); d.layout = p[29]; d.role = Bo(p[30]);
  d.bo_span = portal::get(p, 32, 8);
  d.owner_base_offset = portal::get(p, 40, 8);
  d.row_stride = portal::get(p, 48, 8);
  d.batch_stride = portal::get(p, 56, 8);
  d.owner_extent_span = portal::get(p, 64, 8);
  d.head_stride = portal::get(p, 72, 8);
  d.plane_stride = portal::get(p, 80, 8);
  return d;
}
#endif

void put_geometry(uint8_t* p, const provenance::WriteGeometry& g) {
  portal::put(p, 0, g.first_offset, 8);
  portal::put(p, 8, g.segment_bytes, 4);
  portal::put(p, 12, g.row_count, 2);
  portal::put(p, 14, g.repeat_count, 2);
  portal::put(p, 16, g.row_step, 8);
  portal::put(p, 24, g.repeat_step, 8);
  portal::put(p, 32, g.total_write_bytes, 8);
  p[40] = uint8_t(g.component); p[41] = g.head; p[42] = g.plane_mask;
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
provenance::WriteGeometry get_geometry(const uint8_t* p) {
  provenance::WriteGeometry g;
  g.first_offset = portal::get(p, 0, 8);
  g.segment_bytes = uint32_t(portal::get(p, 8, 4));
  g.row_count = uint16_t(portal::get(p, 12, 2));
  g.repeat_count = uint16_t(portal::get(p, 14, 2));
  g.row_step = portal::get(p, 16, 8);
  g.repeat_step = portal::get(p, 24, 8);
  g.total_write_bytes = portal::get(p, 32, 8);
  g.component = provenance::Component(p[40]); g.head = p[41];
  g.plane_mask = p[42];
  return g;
}
#endif

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
Check validate_compute(portal::Command& command) {
  return portal::command_fields_valid(command) ? ok() : protocol_error();
}

Check validate_provenance(provenance::Request& request) {
  return provenance::request_fields_valid(request) ? ok() : protocol_error();
}

Check validate_producer(producer::Request& request) {
  return producer::request_fields_valid(request) ? ok() : protocol_error();
}
#endif

void put_common(RequestPacket& p, const Request& r) {
  portal::put(p.data(), 0, kRequestMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kRequestBeats, 2);
  portal::put(p.data(), 8, uint16_t(r.kind), 2);
  portal::put(p.data(), 10, protocol_of(r), 2);
  portal::put(p.data(), 16, seq_of(r), 8);
  portal::put(p.data(), 24, origin_of(r), 8);
  portal::put(p.data(), 32, r.flags, 4);
  portal::put_identity(p.data(), COMMON_IDENTITY, identity_of(r));
  portal::put_context(p.data(), COMMON_CONTEXT, context_of(r));
  const auto& model = model_of(r);
  for (unsigned i = 0; i < model.size(); ++i) p[COMMON_MODEL + i] = model[i];
}

void put_compute(RequestPacket& p, const portal::Command& c) {
  portal::put_context(p.data(), 576, c.producer_context);
  portal::put_context(p.data(), 588, c.quant_context);
  portal::put_context(p.data(), 600, c.linear_context);
  portal::put_ref(p.data(), 612, c.source);
  portal::put_ref(p.data(), 620, c.a);
  portal::put_ref(p.data(), 628, c.w);
  portal::put_ref(p.data(), 636, c.ps);
  portal::put_ref(p.data(), 644, c.dst);
  portal::put_ref(p.data(), 652, c.future_dst);
  p[660] = c.source_region; p[661] = c.dst_region;
  p[662] = c.future_dst_region; p[663] = uint8_t(c.output_role[0]);
  p[664] = uint8_t(c.output_role[1]); p[665] = uint8_t(c.source_role);
  portal::put(p.data(), 668, c.a_epoch, 4);
  portal::put(p.data(), 672, c.w_epoch, 4);
  portal::put(p.data(), 676, c.K, 2); portal::put(p.data(), 678, c.N, 2);
  portal::put(p.data(), 680, c.weight_key, 2);
  p[682] = c.rows; p[683] = c.row_block; p[684] = c.a_slot;
  p[685] = c.w_slot; p[686] = c.bias_kind;
  for (unsigned i = 0; i < 2; ++i) {
    const unsigned off = 688 + 24 * i;
    portal::put(p.data(), off, c.output[i].bo_span, 8);
    portal::put(p.data(), off + 8, c.output[i].offset, 8);
    portal::put(p.data(), off + 16, c.output[i].span, 8);
  }
  portal::put(p.data(), 736, c.row_stride, 8);
  portal::put(p.data(), 744, c.batch_stride, 8);
  for (unsigned i = 0; i < 3; ++i) {
    portal::put(p.data(), 752 + 16 * i, c.weight[i].offset, 8);
    portal::put(p.data(), 760 + 16 * i, c.weight[i].span, 8);
  }
  for (unsigned i = 0; i < c.expected_aux_header.size(); ++i)
    p[800 + i] = c.expected_aux_header[i];
  portal::put(p.data(), 928, c.aux_offset, 8);
  portal::put(p.data(), 936, c.bias_offset, 8);
  portal::put(p.data(), 944, c.bias_bytes, 4);
  portal::put(p.data(), 952, c.source_range.offset, 8);
  portal::put(p.data(), 960, c.source_range.span, 8);
  portal::put(p.data(), 968, c.source_stride, 8);
}

void put_provenance(RequestPacket& p, const provenance::Request& r) {
  portal::put(p.data(), 576, uint16_t(r.reported_status), 2);
  p[578] = uint8_t(r.reported_unit); p[579] = r.descriptor_count;
  p[580] = uint8_t(r.expected_unit);
  portal::put(p.data(), 584, r.reported_elements, 4);
  portal::put(p.data(), 588, r.reported_error_detail, 4);
  portal::put(p.data(), 592, r.reported_bad_element, 8);
  portal::put(p.data(), 600, r.expected_elements, 4);
  portal::put(p.data(), 608, r.issued_store_bytes[0], 8);
  if (r.descriptor_count > 1)
    portal::put(p.data(), 616, r.issued_store_bytes[1], 8);
  if (r.descriptor_count > 0) {
    put_descriptor(p.data() + 624, r.descriptor[0]);
    put_geometry(p.data() + 880, r.geometry[0]);
  }
  if (r.descriptor_count > 1) {
    put_descriptor(p.data() + 752, r.descriptor[1]);
    put_geometry(p.data() + 944, r.geometry[1]);
  }
}

void put_producer(RequestPacket& p, const producer::Request& r) {
  portal::put_ref(p.data(), 576, r.source);
  portal::put_ref(p.data(), 584, r.destination);
  p[592] = r.source_region; p[593] = r.destination_region;
  p[594] = uint8_t(r.source_role); p[595] = uint8_t(r.destination_role);
  p[596] = r.gamma; p[597] = uint8_t(r.expected_unit);
  portal::put(p.data(), 600, r.D, 2);
  portal::put(p.data(), 604, r.expected_elements, 4);
  portal::put(p.data(), 608, r.eps_bits, 4);
  portal::put(p.data(), 612, r.row_bytes, 4);
  portal::put(p.data(), 616, r.source_first_offset, 8);
  portal::put(p.data(), 624, r.destination_first_offset, 8);
  portal::put(p.data(), 632, r.source_row_step, 8);
  portal::put(p.data(), 640, r.destination_row_step, 8);
  portal::put(p.data(), 648, r.source_bo_span, 8);
  portal::put(p.data(), 656, r.destination_bo_span, 8);
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
Check get_compute(const RequestPacket& p, Request& r) {
  if (!zeros(p.data(), 666, 668) || p[687] ||
      !zeros(p.data(), 948, 952) || !zeros(p.data(), 976, kRequestBytes))
    return protocol_error();
  for (unsigned off = 612; off <= 652; off += 8)
    if (p[off + 6] || p[off + 7]) return protocol_error();
  auto& c = r.compute;
  c.service = portal::Service(portal::get(p.data(), 10, 2));
  c.generation = portal::get(p.data(), 16, 8);
  c.identity = portal::get_identity(p.data(), COMMON_IDENTITY);
  c.context = portal::get_context(p.data(), COMMON_CONTEXT);
  for (unsigned i = 0; i < c.model_identity.size(); ++i)
    c.model_identity[i] = p[COMMON_MODEL + i];
  c.producer_context = portal::get_context(p.data(), 576);
  c.quant_context = portal::get_context(p.data(), 588);
  c.linear_context = portal::get_context(p.data(), 600);
  c.source = portal::get_ref(p.data(), 612); c.a = portal::get_ref(p.data(), 620);
  c.w = portal::get_ref(p.data(), 628); c.ps = portal::get_ref(p.data(), 636);
  c.dst = portal::get_ref(p.data(), 644);
  c.future_dst = portal::get_ref(p.data(), 652);
  c.source_region = p[660]; c.dst_region = p[661];
  c.future_dst_region = p[662]; c.output_role[0] = Bo(p[663]);
  c.output_role[1] = Bo(p[664]); c.source_role = Bo(p[665]);
  c.a_epoch = uint32_t(portal::get(p.data(), 668, 4));
  c.w_epoch = uint32_t(portal::get(p.data(), 672, 4));
  c.K = uint16_t(portal::get(p.data(), 676, 2));
  c.N = uint16_t(portal::get(p.data(), 678, 2));
  c.weight_key = uint16_t(portal::get(p.data(), 680, 2));
  c.rows = p[682]; c.row_block = p[683]; c.a_slot = p[684];
  c.w_slot = p[685]; c.bias_kind = p[686];
  for (unsigned i = 0; i < 2; ++i) {
    const unsigned off = 688 + 24 * i;
    c.output[i].bo_span = portal::get(p.data(), off, 8);
    c.output[i].offset = portal::get(p.data(), off + 8, 8);
    c.output[i].span = portal::get(p.data(), off + 16, 8);
  }
  c.row_stride = portal::get(p.data(), 736, 8);
  c.batch_stride = portal::get(p.data(), 744, 8);
  for (unsigned i = 0; i < 3; ++i) {
    c.weight[i].offset = portal::get(p.data(), 752 + 16 * i, 8);
    c.weight[i].span = portal::get(p.data(), 760 + 16 * i, 8);
  }
  for (unsigned i = 0; i < c.expected_aux_header.size(); ++i)
    c.expected_aux_header[i] = p[800 + i];
  c.aux_offset = portal::get(p.data(), 928, 8);
  c.bias_offset = portal::get(p.data(), 936, 8);
  c.bias_bytes = uint32_t(portal::get(p.data(), 944, 4));
  c.source_range.offset = portal::get(p.data(), 952, 8);
  c.source_range.span = portal::get(p.data(), 960, 8);
  c.source_stride = portal::get(p.data(), 968, 8);
  return validate_compute(c);
}

Check get_provenance(const RequestPacket& p, Request& r) {
  if (!zeros(p.data(), 581, 584) || !zeros(p.data(), 604, 608) ||
      !zeros(p.data(), 624 + 88, 752) ||
      !zeros(p.data(), 752 + 88, 880) ||
      !zeros(p.data(), 880 + 43, 944) ||
      !zeros(p.data(), 944 + 43, 1008) ||
      !zeros(p.data(), 1008, kRequestBytes)) return protocol_error();
  for (unsigned base : {624u, 752u})
    if (p[base + 6] || p[base + 7] ||
        p[base + 14] || p[base + 15]) return protocol_error();
  auto& q = r.provenance;
  q.action = provenance::Action(portal::get(p.data(), 10, 2));
  q.event_seq = portal::get(p.data(), 16, 8);
  q.origin_seq = portal::get(p.data(), 24, 8);
  q.identity = portal::get_identity(p.data(), COMMON_IDENTITY);
  q.context = portal::get_context(p.data(), COMMON_CONTEXT);
  for (unsigned i = 0; i < q.model_identity.size(); ++i)
    q.model_identity[i] = p[COMMON_MODEL + i];
  q.reported_status = Status(portal::get(p.data(), 576, 2));
  q.reported_unit = OutputUnit(p[578]); q.descriptor_count = p[579];
  q.expected_unit = OutputUnit(p[580]);
  q.reported_elements = uint32_t(portal::get(p.data(), 584, 4));
  q.reported_error_detail = uint32_t(portal::get(p.data(), 588, 4));
  q.reported_bad_element = portal::get(p.data(), 592, 8);
  q.expected_elements = uint32_t(portal::get(p.data(), 600, 4));
  q.issued_store_bytes[0] = portal::get(p.data(), 608, 8);
  q.issued_store_bytes[1] = portal::get(p.data(), 616, 8);
  q.descriptor[0] = get_descriptor(p.data() + 624);
  q.descriptor[1] = get_descriptor(p.data() + 752);
  q.geometry[0] = get_geometry(p.data() + 880);
  q.geometry[1] = get_geometry(p.data() + 944);
  return validate_provenance(q);
}

Check get_producer(const RequestPacket& p, Request& r) {
  if (!zeros(p.data(), 598, 600) || !zeros(p.data(), 602, 604) ||
      !zeros(p.data(), 664, kRequestBytes)) return protocol_error();
  if (p[582] || p[583] || p[590] || p[591]) return protocol_error();
  auto& q = r.producer;
  q.family = producer::Family(portal::get(p.data(), 10, 2));
  q.request_seq = portal::get(p.data(), 16, 8);
  q.provenance_origin_seq = portal::get(p.data(), 24, 8);
  q.identity = portal::get_identity(p.data(), COMMON_IDENTITY);
  q.context = portal::get_context(p.data(), COMMON_CONTEXT);
  for (unsigned i = 0; i < q.model_identity.size(); ++i)
    q.model_identity[i] = p[COMMON_MODEL + i];
  q.source = portal::get_ref(p.data(), 576);
  q.destination = portal::get_ref(p.data(), 584);
  q.source_region = p[592]; q.destination_region = p[593];
  q.source_role = Bo(p[594]); q.destination_role = Bo(p[595]);
  q.gamma = p[596]; q.expected_unit = OutputUnit(p[597]);
  q.D = uint16_t(portal::get(p.data(), 600, 2));
  q.expected_elements = uint32_t(portal::get(p.data(), 604, 4));
  q.eps_bits = uint32_t(portal::get(p.data(), 608, 4));
  q.row_bytes = uint32_t(portal::get(p.data(), 612, 4));
  q.source_first_offset = portal::get(p.data(), 616, 8);
  q.destination_first_offset = portal::get(p.data(), 624, 8);
  q.source_row_step = portal::get(p.data(), 632, 8);
  q.destination_row_step = portal::get(p.data(), 640, 8);
  q.source_bo_span = portal::get(p.data(), 648, 8);
  q.destination_bo_span = portal::get(p.data(), 656, 8);
  return validate_producer(q);
}
#endif

void put_completion_common(CompletionPacket& p, const Completion& c,
                           uint64_t seq, uint64_t origin, Status status,
                           OutputUnit unit, uint8_t descriptor_count,
                           uint32_t error_detail, uint64_t bad_element,
                           uint32_t output_elements, uint64_t metric0,
                           uint64_t metric1, const NumericIdentity& identity,
                           const TaskContext& context) {
  portal::put(p.data(), 0, kCompletionMagic, 4);
  portal::put(p.data(), 4, kVersion, 2);
  portal::put(p.data(), 6, kCompletionBeats, 2);
  portal::put(p.data(), 8, uint16_t(c.kind), 2);
  portal::put(p.data(), 10, protocol_of(c), 2);
  portal::put(p.data(), 12, c.flags, 4);
  portal::put(p.data(), 16, seq, 8); portal::put(p.data(), 24, origin, 8);
  portal::put(p.data(), 32, uint16_t(status), 2); p[34] = uint8_t(unit);
  p[35] = descriptor_count; portal::put(p.data(), 36, error_detail, 4);
  portal::put(p.data(), 40, bad_element, 8);
  portal::put(p.data(), 48, output_elements, 4);
  portal::put(p.data(), 56, metric0, 8); portal::put(p.data(), 64, metric1, 8);
  portal::put_identity(p.data(), 72, identity);
  portal::put_context(p.data(), 156, context);
}

void put_compute_completion(CompletionPacket& p, const portal::Response& r) {
  portal::put_context(p.data(), 168, r.producer_context);
  portal::put_context(p.data(), 180, r.quant_context);
  portal::put_context(p.data(), 192, r.linear_context);
  portal::put_ref(p.data(), 204, r.source);
  portal::put_ref(p.data(), 212, r.a); portal::put_ref(p.data(), 220, r.w);
  portal::put_ref(p.data(), 228, r.ps);
  portal::put_ref(p.data(), 236, r.dst);
  portal::put_ref(p.data(), 244, r.future_dst);
  p[252] = r.source_region; p[253] = r.dst_region;
  p[254] = r.future_dst_region; p[255] = r.rows; p[256] = r.row_block;
  portal::put(p.data(), 260, r.a_epoch, 4);
  portal::put(p.data(), 264, r.w_epoch, 4);
  portal::put(p.data(), 268, r.task_id, 4);
  portal::put(p.data(), 272, r.first_error_rank, 8);
  portal::put(p.data(), 280, r.cycles, 8);
  for (unsigned i = 0; i < r.counters.size(); ++i)
    portal::put(p.data(), 288 + 4 * i, r.counters[i], 4);
}

void put_provenance_completion(CompletionPacket& p,
                               const provenance::Response& r) {
  portal::put_ref(p.data(), 168, r.target_ref[0]);
  portal::put_ref(p.data(), 176, r.old_ref[0]);
  portal::put_ref(p.data(), 184, r.target_ref[1]);
  portal::put_ref(p.data(), 192, r.old_ref[1]);
  p[200] = r.target_region[0]; p[201] = r.old_region[0];
  p[202] = r.target_region[1]; p[203] = r.old_region[1];
}

void put_producer_completion(CompletionPacket& p,
                             const producer::Completion& r) {
  portal::put_ref(p.data(), 168, r.source);
  portal::put_ref(p.data(), 176, r.destination);
  p[184] = r.source_region; p[185] = r.destination_region;
  p[186] = uint8_t(r.source_role); p[187] = uint8_t(r.destination_role);
  p[188] = r.gamma; p[189] = r.finished ? 1 : 0;
  portal::put(p.data(), 192, r.D, 2);
  portal::put(p.data(), 196, r.eps_bits, 4);
  portal::put(p.data(), 200, r.row_bytes, 4);
  portal::put(p.data(), 204, r.source_first_offset, 8);
  portal::put(p.data(), 212, r.destination_first_offset, 8);
  portal::put(p.data(), 220, r.source_row_step, 8);
  portal::put(p.data(), 228, r.destination_row_step, 8);
}

} // namespace

Request make_request(const portal::Command& command, uint32_t flags) {
  Request request; request.kind = Kind::COMPUTE_TRANSACTION;
  request.flags = flags; request.compute = command; return request;
}

Request make_request(const provenance::Request& provenance, uint32_t flags) {
  Request request; request.kind = Kind::PROVENANCE_TRANSACTION;
  request.flags = flags; request.provenance = provenance; return request;
}

Request make_request(const producer::Request& producer, uint32_t flags) {
  Request request; request.kind = Kind::PRODUCER_TRANSACTION;
  request.flags = flags; request.producer = producer; return request;
}

RequestPacket encode(const Request& request) {
  RequestPacket packet{}; put_common(packet, request);
  if (request.kind == Kind::COMPUTE_TRANSACTION)
    put_compute(packet, request.compute);
  else if (request.kind == Kind::PROVENANCE_TRANSACTION)
    put_provenance(packet, request.provenance);
  else if (request.kind == Kind::PRODUCER_TRANSACTION)
    put_producer(packet, request.producer);
  return packet;
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
Check decode(const RequestPacket& packet, Request& request) {
  if (portal::get(packet.data(), 0, 4) != kRequestMagic ||
      portal::get(packet.data(), 4, 2) != kVersion ||
      portal::get(packet.data(), 6, 2) != kRequestBeats ||
      !valid_kind(portal::get(packet.data(), 8, 2)) ||
      (portal::get(packet.data(), 32, 4) & ~uint32_t(CANCEL_CLEANUP)) ||
      !zeros(packet.data(), 12, 16) || !zeros(packet.data(), 36, 64))
    return protocol_error();
  request = Request{};
  request.kind = Kind(portal::get(packet.data(), 8, 2));
  request.flags = uint32_t(portal::get(packet.data(), 32, 4));
  Check result = request.kind == Kind::COMPUTE_TRANSACTION ?
      get_compute(packet, request) :
      request.kind == Kind::PROVENANCE_TRANSACTION ?
          get_provenance(packet, request) : get_producer(packet, request);
  if (!result || protocol_of(request) != portal::get(packet.data(), 10, 2) ||
      seq_of(request) != portal::get(packet.data(), 16, 8) ||
      origin_of(request) != portal::get(packet.data(), 24, 8))
    return protocol_error();
  return ok();
}
#endif

Completion make_completion(const Request& request,
                           const portal::Response& response,
                           bool binding_ok) {
  Completion c; c.kind = Kind::COMPUTE_TRANSACTION; c.compute = response;
  c.flags = uint32_t(FRAME_COMPLETE) |
      (binding_ok ? uint32_t(BINDING_OK) : 0u) |
      (response.drained ? uint32_t(REMOTE_DRAINED | REMOTE_TERMINAL) : 0u) |
      (response.published ? uint32_t(REMOTE_PUBLISHED) : 0u);
  (void)request; return c;
}

Completion make_completion(const Request& request,
                           const provenance::Response& response,
                           bool binding_ok) {
  Completion c; c.kind = Kind::PROVENANCE_TRANSACTION;
  c.provenance = response;
  c.flags = uint32_t(FRAME_COMPLETE) |
      (binding_ok ? uint32_t(BINDING_OK) : 0u) |
      (response.drained ? uint32_t(REMOTE_DRAINED) : 0u) |
      (response.scope_active ? uint32_t(REMOTE_SCOPE_ACTIVE) : 0u) |
      (response.drained && !response.scope_active ?
          uint32_t(REMOTE_TERMINAL) : 0u) |
      (response.owner_published ? uint32_t(REMOTE_PUBLISHED) : 0u);
  (void)request; return c;
}

Completion make_completion(const Request& request,
                           const producer::Completion& response,
                           bool binding_ok) {
  Completion c; c.kind = Kind::PRODUCER_TRANSACTION; c.producer = response;
  c.flags = uint32_t(FRAME_COMPLETE) |
      (binding_ok ? uint32_t(BINDING_OK) : 0u) |
      (response.finished ? uint32_t(REMOTE_TERMINAL) : 0u);
  (void)request; return c;
}

Completion make_local_reject(const Request& request, Check failure) {
  Completion c; c.kind = request.kind; c.flags = FRAME_COMPLETE | LOCAL_REJECT;
  if (request.kind == Kind::COMPUTE_TRANSACTION) {
    c.compute.service = request.compute.service;
    c.compute.generation = request.compute.generation;
    c.compute.identity = request.compute.identity;
    c.compute.context = request.compute.context;
    c.compute.task_id = request.compute.context.task_id;
    c.compute.source = request.compute.source; c.compute.a = request.compute.a;
    c.compute.w = request.compute.w; c.compute.ps = request.compute.ps;
    c.compute.dst = request.compute.dst;
    c.compute.source_region = request.compute.source_region;
    c.compute.dst_region = request.compute.dst_region;
    c.compute.a_epoch = request.compute.a_epoch;
    c.compute.w_epoch = request.compute.w_epoch;
    c.compute.producer_context = request.compute.producer_context;
    c.compute.quant_context = request.compute.quant_context;
    c.compute.linear_context = request.compute.linear_context;
    c.compute.future_dst = request.compute.future_dst;
    c.compute.future_dst_region = request.compute.future_dst_region;
    c.compute.rows = request.compute.rows;
    c.compute.row_block = request.compute.row_block;
    c.compute.status = failure.code; c.compute.error_detail = failure.detail;
    c.compute.bad_element = failure.bad_element;
  } else if (request.kind == Kind::PROVENANCE_TRANSACTION) {
    c.provenance.action = request.provenance.action;
    c.provenance.event_seq = request.provenance.event_seq;
    c.provenance.origin_seq = request.provenance.origin_seq;
    c.provenance.identity = request.provenance.identity;
    c.provenance.context = request.provenance.context;
    c.provenance.status = failure.code;
    c.provenance.error_detail = failure.detail;
    c.provenance.bad_element = failure.bad_element;
    c.provenance.descriptor_count = request.provenance.descriptor_count;
    for (unsigned i = 0; i < 2; ++i) {
      c.provenance.target_ref[i] = request.provenance.descriptor[i].target_ref;
      c.provenance.target_region[i] = request.provenance.descriptor[i].target_region;
      c.provenance.old_ref[i] = request.provenance.descriptor[i].old_ref;
      c.provenance.old_region[i] = request.provenance.descriptor[i].old_region;
    }
  } else {
    c.producer.family = request.producer.family;
    c.producer.request_seq = request.producer.request_seq;
    c.producer.provenance_origin_seq = request.producer.provenance_origin_seq;
    c.producer.identity = request.producer.identity;
    c.producer.context = request.producer.context;
    c.producer.source = request.producer.source;
    c.producer.destination = request.producer.destination;
    c.producer.source_region = request.producer.source_region;
    c.producer.destination_region = request.producer.destination_region;
    c.producer.source_role = request.producer.source_role;
    c.producer.destination_role = request.producer.destination_role;
    c.producer.D = request.producer.D; c.producer.gamma = request.producer.gamma;
    c.producer.eps_bits = request.producer.eps_bits;
    c.producer.row_bytes = request.producer.row_bytes;
    c.producer.source_first_offset = request.producer.source_first_offset;
    c.producer.destination_first_offset = request.producer.destination_first_offset;
    c.producer.source_row_step = request.producer.source_row_step;
    c.producer.destination_row_step = request.producer.destination_row_step;
    c.producer.status = failure.code; c.producer.error_detail = failure.detail;
    c.producer.bad_element = failure.bad_element;
  }
  return c;
}

bool local_reject_binding_ok(const Request& expected, const Completion& c) {
  if (c.kind != expected.kind) return false;
  if (c.kind == Kind::COMPUTE_TRANSACTION) {
    const auto& a = expected.compute; const auto& b = c.compute;
    return b.service == a.service && b.generation == a.generation &&
        b.task_id == a.context.task_id &&
        numeric_identity_equal(b.identity, a.identity) &&
        same_context(b.context, a.context) && b.source == a.source &&
        b.a == a.a && b.w == a.w && b.ps == a.ps && b.dst == a.dst &&
        b.source_region == a.source_region && b.dst_region == a.dst_region &&
        b.a_epoch == a.a_epoch && b.w_epoch == a.w_epoch &&
        same_context(b.producer_context, a.producer_context) &&
        same_context(b.quant_context, a.quant_context) &&
        same_context(b.linear_context, a.linear_context) &&
        b.future_dst == a.future_dst &&
        b.future_dst_region == a.future_dst_region && b.rows == a.rows &&
        b.row_block == a.row_block;
  }
  if (c.kind == Kind::PROVENANCE_TRANSACTION) {
    const auto& a = expected.provenance; const auto& b = c.provenance;
    if (b.action != a.action || b.event_seq != a.event_seq ||
        b.origin_seq != a.origin_seq ||
        !numeric_identity_equal(b.identity, a.identity) ||
        !same_context(b.context, a.context) ||
        b.descriptor_count != a.descriptor_count) return false;
    for (unsigned i = 0; i < 2; ++i) {
      const bool used = i < a.descriptor_count;
      if ((used && (b.target_ref[i] != a.descriptor[i].target_ref ||
                    b.target_region[i] != a.descriptor[i].target_region ||
                    b.old_ref[i] != a.descriptor[i].old_ref ||
                    b.old_region[i] != a.descriptor[i].old_region)) ||
          (!used && (b.target_ref[i].id != Buffer::NONE ||
                     b.old_ref[i].id != Buffer::NONE ||
                     b.target_region[i] || b.old_region[i]))) return false;
    }
    return true;
  }
  return same_producer_binding(expected.producer, c.producer);
}

CompletionPacket encode(const Completion& completion) {
  CompletionPacket packet{};
  if (completion.kind == Kind::COMPUTE_TRANSACTION) {
    const auto& r = completion.compute;
    put_completion_common(packet, completion, r.generation, 0, r.status,
        r.unit, 0, r.error_detail, r.bad_element, r.output_elements, 0, 0,
        r.identity, r.context);
    put_compute_completion(packet, r);
  } else if (completion.kind == Kind::PROVENANCE_TRANSACTION) {
    const auto& r = completion.provenance;
    put_completion_common(packet, completion, r.event_seq, r.origin_seq,
        r.status, r.unit, r.descriptor_count, r.error_detail, r.bad_element,
        r.output_elements, r.observed_store_bytes[0],
        r.observed_store_bytes[1], r.identity, r.context);
    put_provenance_completion(packet, r);
  } else {
    const auto& r = completion.producer;
    put_completion_common(packet, completion, r.request_seq,
        r.provenance_origin_seq, r.status, r.unit, 0, r.error_detail,
        r.bad_element, r.output_elements, r.issued_store_bytes,
        r.consumed_source_bytes, r.identity, r.context);
    put_producer_completion(packet, r);
  }
  return packet;
}

Check decode(const CompletionPacket& p, const Request& expected,
             Completion& completion) {
  // A rejected frame must never leave trust flags or binding fields from a
  // previously decoded completion visible to a caller that reuses storage.
  // Do this before even the fixed header is considered trustworthy.
  completion = Completion{};
  constexpr uint32_t kAllFlags = FRAME_COMPLETE | BINDING_OK |
      REMOTE_DRAINED | REMOTE_SCOPE_ACTIVE | REMOTE_TERMINAL |
      REMOTE_PUBLISHED | LOCAL_REJECT;
  if (portal::get(p.data(), 0, 4) != kCompletionMagic ||
      portal::get(p.data(), 4, 2) != kVersion ||
      portal::get(p.data(), 6, 2) != kCompletionBeats ||
      !valid_kind(portal::get(p.data(), 8, 2)) || p[34] > 3 ||
      portal::get(p.data(), 32, 2) > uint16_t(Status::E_INTERNAL) ||
      (portal::get(p.data(), 12, 4) & ~kAllFlags) ||
      !zeros(p.data(), 52, 56)) return protocol_error();
  completion.kind = Kind(portal::get(p.data(), 8, 2));
  completion.flags = uint32_t(portal::get(p.data(), 12, 4));
  const Status status = Status(portal::get(p.data(), 32, 2));
  const OutputUnit unit = OutputUnit(p[34]);
  const uint32_t error_detail = uint32_t(portal::get(p.data(), 36, 4));
  const uint64_t bad_element = portal::get(p.data(), 40, 8);
  const uint32_t output_elements = uint32_t(portal::get(p.data(), 48, 4));
  const uint64_t metric0 = portal::get(p.data(), 56, 8);
  const uint64_t metric1 = portal::get(p.data(), 64, 8);
  const NumericIdentity identity = portal::get_identity(p.data(), 72);
  const TaskContext context = portal::get_context(p.data(), 156);
  const uint64_t seq = portal::get(p.data(), 16, 8);
  const uint64_t origin = portal::get(p.data(), 24, 8);

  if (completion.kind == Kind::COMPUTE_TRANSACTION) {
    if (!zeros(p.data(), 257, 260) || !zeros(p.data(), 344, kCompletionBytes))
      return completion_protocol_error(completion);
    for (unsigned off = 204; off <= 244; off += 8)
      if (p[off + 6] || p[off + 7])
        return completion_protocol_error(completion);
    auto& r = completion.compute;
    r.service = portal::Service(portal::get(p.data(), 10, 2));
    r.generation = seq; r.status = status; r.unit = unit;
    r.error_detail = error_detail; r.bad_element = bad_element;
    r.output_elements = output_elements; r.identity = identity;
    r.context = context; r.producer_context = portal::get_context(p.data(),168);
    r.quant_context = portal::get_context(p.data(),180);
    r.linear_context = portal::get_context(p.data(),192);
    r.source = portal::get_ref(p.data(),204); r.a = portal::get_ref(p.data(),212);
    r.w = portal::get_ref(p.data(),220); r.ps = portal::get_ref(p.data(),228);
    r.dst = portal::get_ref(p.data(),236); r.future_dst = portal::get_ref(p.data(),244);
    r.source_region=p[252]; r.dst_region=p[253]; r.future_dst_region=p[254];
    r.rows=p[255]; r.row_block=p[256];
    r.a_epoch=uint32_t(portal::get(p.data(),260,4));
    r.w_epoch=uint32_t(portal::get(p.data(),264,4));
    r.task_id=uint32_t(portal::get(p.data(),268,4));
    r.first_error_rank=portal::get(p.data(),272,8);
    r.cycles=portal::get(p.data(),280,8);
    for(unsigned i=0;i<r.counters.size();++i)
      r.counters[i]=uint32_t(portal::get(p.data(),288+4*i,4));
    r.drained = completion.flags & REMOTE_DRAINED;
    r.published = completion.flags & REMOTE_PUBLISHED;
  } else if (completion.kind == Kind::PROVENANCE_TRANSACTION) {
    if (!zeros(p.data(), 204, kCompletionBytes))
      return completion_protocol_error(completion);
    for (unsigned off = 168; off <= 192; off += 8)
      if (p[off + 6] || p[off + 7])
        return completion_protocol_error(completion);
    auto& r = completion.provenance;
    r.action=provenance::Action(portal::get(p.data(),10,2));
    r.event_seq=seq; r.origin_seq=origin; r.status=status; r.unit=unit;
    r.error_detail=error_detail; r.bad_element=bad_element;
    r.output_elements=output_elements; r.descriptor_count=p[35];
    r.observed_store_bytes[0]=metric0; r.observed_store_bytes[1]=metric1;
    r.identity=identity; r.context=context;
    r.target_ref[0]=portal::get_ref(p.data(),168);
    r.old_ref[0]=portal::get_ref(p.data(),176);
    r.target_ref[1]=portal::get_ref(p.data(),184);
    r.old_ref[1]=portal::get_ref(p.data(),192);
    r.target_region[0]=p[200]; r.old_region[0]=p[201];
    r.target_region[1]=p[202]; r.old_region[1]=p[203];
    r.drained=completion.flags&REMOTE_DRAINED;
    r.scope_active=completion.flags&REMOTE_SCOPE_ACTIVE;
    r.owner_published=completion.flags&REMOTE_PUBLISHED;
  } else {
    if (!zeros(p.data(), 190, 192) || !zeros(p.data(), 194, 196) ||
        !zeros(p.data(), 236, kCompletionBytes))
      return completion_protocol_error(completion);
    if (p[174] || p[175] || p[182] || p[183])
      return completion_protocol_error(completion);
    auto& r = completion.producer;
    r.family=producer::Family(portal::get(p.data(),10,2));
    r.request_seq=seq; r.provenance_origin_seq=origin; r.status=status;
    r.unit=unit; r.error_detail=error_detail; r.bad_element=bad_element;
    r.output_elements=output_elements; r.issued_store_bytes=metric0;
    r.consumed_source_bytes=metric1; r.identity=identity; r.context=context;
    r.source=portal::get_ref(p.data(),168);
    r.destination=portal::get_ref(p.data(),176);
    r.source_region=p[184]; r.destination_region=p[185];
    r.source_role=Bo(p[186]); r.destination_role=Bo(p[187]);
    r.gamma=p[188]; r.finished=p[189]!=0;
    r.D=uint16_t(portal::get(p.data(),192,2));
    r.eps_bits=uint32_t(portal::get(p.data(),196,4));
    r.row_bytes=uint32_t(portal::get(p.data(),200,4));
    r.source_first_offset=portal::get(p.data(),204,8);
    r.destination_first_offset=portal::get(p.data(),212,8);
    r.source_row_step=portal::get(p.data(),220,8);
    r.destination_row_step=portal::get(p.data(),228,8);
  }

  if (completion.kind != expected.kind ||
      portal::get(p.data(), 10, 2) != protocol_of(completion) ||
      !(completion.flags & FRAME_COMPLETE))
    return completion_protocol_error(completion);
  const bool local_reject = completion.flags & LOCAL_REJECT;
  if (local_reject &&
      ((completion.flags & (BINDING_OK | REMOTE_DRAINED |
                            REMOTE_SCOPE_ACTIVE | REMOTE_TERMINAL |
                            REMOTE_PUBLISHED)) ||
       status == Status::OK ||
       !local_reject_binding_ok(expected, completion)))
    return completion_protocol_error(completion);
  if (completion.kind == Kind::COMPUTE_TRANSACTION &&
      (((completion.flags & REMOTE_TERMINAL) != 0) !=
       ((completion.flags & REMOTE_DRAINED) != 0) ||
       (completion.flags & REMOTE_SCOPE_ACTIVE)))
    return completion_protocol_error(completion);
  if (completion.kind == Kind::PROVENANCE_TRANSACTION &&
      (((completion.flags & REMOTE_TERMINAL) != 0) !=
       ((completion.flags & REMOTE_DRAINED) &&
        !(completion.flags & REMOTE_SCOPE_ACTIVE))))
    return completion_protocol_error(completion);
  if (completion.kind == Kind::PRODUCER_TRANSACTION &&
      ((completion.flags & (REMOTE_DRAINED | REMOTE_SCOPE_ACTIVE |
                            REMOTE_PUBLISHED)) ||
       (((completion.flags & REMOTE_TERMINAL) != 0) !=
        completion.producer.finished)))
    return completion_protocol_error(completion);
  if (local_reject)
    return {status, error_detail, bad_element};
  if (!(completion.flags & BINDING_OK))
    return completion_protocol_error(completion);

#ifdef LAYA_TRANSACTION_SEQUENCER_CODEC
  // The adapter asserted BINDING_OK only after a complete external frame was
  // parsed and validated.  The sequencer still compares every normalized
  // binding field against its immutable request snapshot before accepting it.
  if (!local_reject_binding_ok(expected, completion))
    return completion_protocol_error(completion);
#else
  if (completion.kind == Kind::COMPUTE_TRANSACTION) {
    portal::Response checked;
    Check result = portal::decode(portal::encode(completion.compute),
                                  expected.compute, checked);
    if (!result) return result;
  } else if (completion.kind == Kind::PROVENANCE_TRANSACTION) {
    provenance::Response checked;
    Check result = provenance::decode(provenance::encode(completion.provenance),
                                      expected.provenance, checked);
    if (!result) return result;
  } else {
    producer::Completion checked;
    Check result = producer::decode(producer::encode(completion.producer),
                                    expected.producer, checked);
    if (!result) return result;
  }
#endif
  return {status, error_detail, bad_element};
}

bool completion_frame_complete(const Completion& c) {
  return c.flags & FRAME_COMPLETE;
}
bool completion_binding_ok(const Completion& c) {
  return c.flags & BINDING_OK;
}
bool completion_safe_terminal(const Completion& c) {
  return c.flags & REMOTE_TERMINAL;
}

} // namespace laya::transaction
