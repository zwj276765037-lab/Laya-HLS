#include "laya_compute_portal_client.h"

namespace laya::portal {
namespace {

Check bad(Service service, uint16_t reason = 4) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(service), reason)};
}

bool same_window(const TaskContext& a, const TaskContext& b) {
  return a.stage == b.stage && a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

uint16_t weight_key(WeightKey key) {
  return uint16_t(key.family) | uint16_t(uint16_t(key.layer) << 8);
}

uint64_t rows_per_batch(RowSpace space) {
  return space == RowSpace::TOKEN ? 1024 :
         space == RowSpace::MARKER ? 16 : 1;
}

Check checked_span(const full::FullMemory& memory, BufferRef ref,
                   uint8_t region, Bo& role, OutputRange& range) {
  Span mapped;
  Check c = span(ref, region, mapped);
  if (!c) return c;
  c = full::full_span(memory, mapped.bo, mapped.base, mapped.bytes);
  if (!c) return c;
  const uint64_t capacity = full::full_bo_capacity(memory, mapped.bo);
  if (!capacity || uint64_t(mapped.base) + mapped.bytes > capacity)
    return {Status::E_BUFFER, detail(4, uint8_t(ref.id), 8)};
  role = mapped.bo;
  range = {capacity, mapped.base, mapped.bytes};
  return ok();
}

Check binding_ok(const NumericIdentity& identity, const TaskBinding& binding,
                 Service service) {
  if (!numeric_identity_valid(identity) ||
      !check_context(binding.producer, identity.B, identity.S) ||
      !check_context(binding.quant.ctx, identity.B, identity.S) ||
      !check_context(binding.linear.ctx, identity.B, identity.S) ||
      binding.quant.ctx.op != Op::QUANT ||
      uint8_t(binding.linear.ctx.op) < uint8_t(Op::LIN_QKV) ||
      uint8_t(binding.linear.ctx.op) > uint8_t(Op::LIN_ACT_FC2) ||
      !same_window(binding.producer, binding.quant.ctx) ||
      !same_window(binding.quant.ctx, binding.linear.ctx) ||
      binding.producer.task_id >= binding.quant.ctx.task_id ||
      binding.quant.ctx.task_id >= binding.linear.ctx.task_id ||
      binding.quant.a_dst != binding.linear.a ||
      binding.quant.K != binding.linear.K ||
      !check_ref(binding.quant.src, binding.quant.src_region) ||
      !check_ref(binding.quant.a_dst) || !check_ref(binding.linear.w) ||
      !check_ref(binding.linear.ps) ||
      !check_ref(binding.linear.dst, binding.linear.dst_region) ||
      !check_weight(binding.linear.weight, binding.linear.ctx.stage,
                    binding.linear.ctx.layer, binding.linear.K,
                    binding.linear.N)) return bad(service, 9);
  return ok();
}

void fill_binding(Command& command, const NumericIdentity& identity,
                  const ModelBinding& model, const TaskBinding& binding) {
  command.identity = identity;
  command.producer_context = binding.producer;
  command.quant_context = binding.quant.ctx;
  command.linear_context = binding.linear.ctx;
  command.source = binding.quant.src;
  command.source_region = binding.quant.src_region;
  command.a = binding.linear.a;
  command.w = binding.linear.w;
  command.ps = binding.linear.ps;
  command.future_dst = binding.linear.dst;
  command.future_dst_region = binding.linear.dst_region;
  command.model_identity = model.identity;
  command.K = binding.linear.K;
  command.N = binding.linear.N;
  command.a_slot = binding.linear.a.bank;
  command.w_slot = binding.linear.w.bank;
  command.a_epoch = binding.linear.a.epoch;
  command.w_epoch = binding.linear.w.epoch;
  command.weight_key = weight_key(binding.linear.weight);
  command.bias_kind = binding.linear.bias_kind;
}

Check wire_valid(const Command& command) {
  Command decoded;
  return decode(encode(command), decoded);
}

Check fill_output(const full::FullMemory& memory, BufferRef ref,
                  uint8_t region, Command& command) {
  Check c = checked_span(memory, ref, region,
                         command.output_role[0], command.output[0]);
  if (!c) return c;
  if (ref.id == Buffer::QKV) {
    c = checked_span(memory, {Buffer::QKV, 1, ref.epoch}, region,
                     command.output_role[1], command.output[1]);
    if (!c) return c;
  }
  return ok();
}

} // namespace

CommandWords command_words(const CommandPacket& packet) {
  CommandWords words{};
  for (unsigned beat = 0; beat < kCommandBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      words[beat].byte[byte] = packet[beat * 64 + byte];
  return words;
}

ResponseWords response_words(const ResponsePacket& packet) {
  ResponseWords words{};
  for (unsigned beat = 0; beat < kResponseBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      words[beat].byte[byte] = packet[beat * 64 + byte];
  return words;
}

ResponsePacket response_packet(const ResponseWords& words) {
  ResponsePacket packet{};
  for (unsigned beat = 0; beat < kResponseBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] = words[beat].byte[byte];
  return packet;
}

Check verify_response(const ResponseWords& words, const Command& command,
                      Response& response) {
  Check c = decode(response_packet(words), command, response);
  if (!c) return c;
  uint32_t elements = 0;
  OutputUnit unit = OutputUnit::NONE;
  switch (command.service) {
    case Service::LOAD_W:
      elements = ((uint32_t(command.N) + 7u) & ~7u) *
                 (uint32_t(command.K) / 32u) * 34u;
      unit = OutputUnit::BYTES;
      break;
    case Service::QUANT:
      elements = uint32_t(command.rows) * command.K / 32u;
      unit = OutputUnit::Q8_GROUP;
      break;
    case Service::MATRIX:
      elements = uint32_t(command.rows) * command.N;
      unit = OutputUnit::F32;
      break;
    case Service::GEGLU:
      elements = uint32_t(command.rows) * command.K;
      unit = OutputUnit::F32;
      break;
  }
  if (!response.published || response.error_detail ||
      response.bad_element != UINT64_MAX ||
      response.output_elements != elements || response.unit != unit)
    return {Status::E_PROTOCOL, detail(4, 0, 21)};
  return ok();
}

Check build_load_command(const NumericIdentity& identity,
                         const full::FullMemory& memory,
                         const ModelBinding& model,
                         const full::FullWeightDescriptor& descriptor,
                         const LoadTask& task, uint64_t generation,
                         Command& command) {
  if (!generation || !numeric_identity_valid(identity) ||
      !check_context(task.ctx, identity.B, identity.S) ||
      task.ctx.op != Op::LOAD_W || task.kind != 0 ||
      task.dst.id != Buffer::WEIGHT || !check_ref(task.dst) ||
      task.dst.bank > 1 || descriptor.dtype != 8 ||
      descriptor.key.family != task.weight.family ||
      descriptor.key.layer != task.weight.layer ||
      !check_weight(task.weight, task.ctx.stage, task.ctx.layer,
                    descriptor.K, descriptor.N) || descriptor.K % 32)
    return bad(Service::LOAD_W, 9);
  const uint32_t padded_n = (uint32_t(descriptor.N) + 7u) & ~7u;
  const uint32_t entries = padded_n * (descriptor.K / 32u);
  if (task.byte_count != entries * 34u ||
      descriptor.q_span[0] + descriptor.q_span[1] != entries * 32u ||
      descriptor.scale_span != entries * 2u ||
      (descriptor.bias_kind && descriptor.bias_span != uint32_t(descriptor.N) * 4u))
    return bad(Service::LOAD_W, 5);
  Check c = full::full_span(memory, Bo::W_Q0, descriptor.q_base[0], descriptor.q_span[0]);
  if (c) c = full::full_span(memory, Bo::W_Q1, descriptor.q_base[1], descriptor.q_span[1]);
  if (c) c = full::full_span(memory, Bo::W_SCALE, descriptor.scale_base, descriptor.scale_span);
  if (c) c = full::full_span(memory, Bo::AUX, 0, model.expected_aux_header.size());
  if (c && descriptor.bias_kind)
    c = full::full_span(memory, Bo::AUX, descriptor.bias_base, descriptor.bias_span);
  if (!c) return c;
  command = Command{};
  command.service = Service::LOAD_W;
  command.generation = generation;
  command.identity = identity;
  command.context = task.ctx;
  command.w = task.dst;
  command.model_identity = model.identity;
  command.K = descriptor.K;
  command.N = descriptor.N;
  command.w_slot = task.dst.bank;
  command.w_epoch = task.dst.epoch;
  command.weight_key = weight_key(task.weight);
  command.bias_kind = descriptor.bias_kind;
  command.weight[0] = {descriptor.q_base[0], descriptor.q_span[0]};
  command.weight[1] = {descriptor.q_base[1], descriptor.q_span[1]};
  command.weight[2] = {descriptor.scale_base, descriptor.scale_span};
  command.expected_aux_header = model.expected_aux_header;
  command.aux_offset = 0;
  command.bias_offset = descriptor.bias_base;
  command.bias_bytes = descriptor.bias_kind ? descriptor.bias_span : 0;
  return wire_valid(command);
}

Check build_quant_command(const NumericIdentity& identity,
                          const full::FullMemory& memory,
                          const ModelBinding& model,
                          const TaskBinding& binding, uint64_t generation,
                          Command& command) {
  Check c = binding_ok(identity, binding, Service::QUANT);
  if (!c || !generation) return c ? bad(Service::QUANT, 9) : c;
  command = Command{};
  command.service = Service::QUANT;
  command.generation = generation;
  command.context = binding.quant.ctx;
  fill_binding(command, identity, model, binding);
  command.dst = binding.quant.a_dst;
  command.rows = binding.quant.ctx.rows;
  OutputRange source{};
  c = checked_span(memory, binding.quant.src, binding.quant.src_region,
                   command.source_role, source);
  if (!c) return c;
  command.source_range = {source.offset, source.span};
  command.source_stride = uint64_t(binding.quant.K) * 4u;
  command.row_stride = command.source_stride;
  command.batch_stride = command.row_stride * rows_per_batch(binding.quant.ctx.row_space);
  return wire_valid(command);
}

Check build_matrix_command(const NumericIdentity& identity,
                           const full::FullMemory& memory,
                           const ModelBinding& model,
                           const TaskBinding& binding,
                           const full::ViewTicket& view, Command& command) {
  Check c = binding_ok(identity, binding, Service::MATRIX);
  if (!c) return c;
  if (!view.generation || (view.rows != 1 && view.rows != 4) ||
      unsigned(view.row_block) + view.rows > binding.linear.ctx.rows)
    return bad(Service::MATRIX, 9);
  command = Command{};
  command.service = Service::MATRIX;
  command.generation = view.generation;
  command.context = binding.linear.ctx;
  fill_binding(command, identity, model, binding);
  command.dst = binding.linear.dst;
  command.dst_region = binding.linear.dst_region;
  command.rows = view.rows;
  command.row_block = view.row_block;
  c = fill_output(memory, binding.linear.dst, binding.linear.dst_region, command);
  if (!c) return c;
  command.row_stride = uint64_t(binding.linear.N) * 4u;
  command.batch_stride = command.row_stride * rows_per_batch(binding.linear.ctx.row_space);
  return wire_valid(command);
}

Check build_geglu_command(const NumericIdentity& identity,
                          const full::FullMemory& memory,
                          const ModelBinding& model,
                          const VectorTask& producer,
                          const TaskBinding& binding, uint64_t generation,
                          Command& command) {
  Check c = binding_ok(identity, binding, Service::GEGLU);
  if (!c) return c;
  if (!generation || producer.ctx.op != Op::GEGLU ||
      producer.ctx.task_id != binding.producer.task_id ||
      !same_window(producer.ctx, binding.producer) ||
      producer.src0.id != Buffer::WI || producer.dst != binding.quant.src ||
      producer.dst.id != Buffer::GATE || producer.length != 2624 ||
      producer.src0_region || producer.dst_region ||
      binding.linear.ctx.op != Op::LIN_DOWN || binding.linear.K != 2624 ||
      binding.linear.N != 1024)
    return bad(Service::GEGLU, 9);
  command = Command{};
  command.service = Service::GEGLU;
  command.generation = generation;
  command.context = producer.ctx;
  fill_binding(command, identity, model, binding);
  command.source = producer.src0;
  command.source_region = producer.src0_region;
  command.dst = producer.dst;
  command.dst_region = producer.dst_region;
  command.rows = producer.ctx.rows;
  OutputRange source{};
  c = checked_span(memory, producer.src0, producer.src0_region,
                   command.source_role, source);
  if (!c) return c;
  command.source_range = {source.offset, source.span};
  c = fill_output(memory, producer.dst, producer.dst_region, command);
  if (!c) return c;
  command.source_stride = uint64_t(command.K) * 8u;
  command.row_stride = uint64_t(command.K) * 4u;
  command.batch_stride = command.row_stride * 1024u;
  return wire_valid(command);
}

} // namespace laya::portal
