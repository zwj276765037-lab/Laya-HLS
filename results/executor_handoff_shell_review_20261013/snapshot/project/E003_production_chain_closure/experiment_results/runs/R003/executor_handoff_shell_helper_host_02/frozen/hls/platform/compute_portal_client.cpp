#include "laya_compute_portal_client.h"
#include "laya_model_layout_generated.h"

namespace laya::portal {
namespace {

Check bad(Service service, uint16_t reason = 4) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(service), reason)};
}

Check identity_abi_error(unsigned byte) {
  return {Status::E_ABI, detail(4, 0, 20), byte};
}

Check identity_model_error(unsigned byte) {
  return {Status::E_MODEL, detail(4, 0, 4), byte};
}

bool same_bytes(const uint8_t* a, const uint8_t* b, unsigned count) {
  for (unsigned i = 0; i < count; ++i)
    if (a[i] != b[i]) return false;
  return true;
}

bool zero_bytes(const uint8_t* p, unsigned first, unsigned end) {
  for (unsigned i = first; i < end; ++i)
    if (p[i]) return false;
  return true;
}

void copy_bytes(uint8_t* dst, const uint8_t* src, unsigned count) {
  for (unsigned i = 0; i < count; ++i) dst[i] = src[i];
}

bool same_extent(const TaskContext& a, const TaskContext& b) {
  return a.batch == b.batch && a.row_space == b.row_space &&
         a.row0 == b.row0 && a.rows == b.rows;
}

bool same_window(const TaskContext& a, const TaskContext& b) {
  return a.stage == b.stage && a.layer == b.layer && same_extent(a, b);
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
      !same_extent(binding.producer, binding.quant.ctx) ||
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
#ifdef LAYA_TRANSACTION_SEQUENCER_CODEC
  (void)command;
  return ok();
#else
  Command decoded;
  return decode(encode(command), decoded);
#endif
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

Check build_l13m_model_binding(ModelBinding& model) {
  model = ModelBinding{};
  copy_bytes(model.identity.data(), full::kFullModelTag, 16);
  copy_bytes(model.identity.data() + 16, full::kFullNumericTag, 16);
  copy_bytes(model.identity.data() + 32, full::kFullLayoutTag, 16);
  copy_bytes(model.identity.data() + 48, full::kFullBuildTag, 16);
  put(model.identity.data(), 64, 0x4d33314cu, 4);
  put(model.identity.data(), 68, 1, 2);
  put(model.identity.data(), 70, model.identity.size(), 2);
  put(model.identity.data(), 72, 0, 4);
  put(model.identity.data(), 76, 1, 4);
  copy_bytes(model.identity.data() + 80, full::kFullSourceSha256, 32);
  put(model.identity.data(), 112, 5, 4);
  put(model.identity.data(), 116, 16, 4);
  put(model.identity.data(), 120, 128, 4);
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned entry = 128 + 16 * i;
    put(model.identity.data(), entry, roles[i], 4);
    put(model.identity.data(), entry + 4, 1, 4);
    put(model.identity.data(), entry + 8, full::kFullModelBoSizes[i], 8);
  }

  uint8_t* aux = model.expected_aux_header.data();
  aux[0] = 'L'; aux[1] = 'Y'; aux[2] = 'M'; aux[3] = 'P';
  put(aux, 4, 1, 2); put(aux, 6, 0, 2);
  put(aux, 8, model.expected_aux_header.size(), 4);
  put(aux, 12, 13, 4); put(aux, 16, 1, 4);
  copy_bytes(aux + 32, full::kFullModelTag, 16);
  copy_bytes(aux + 48, full::kFullNumericTag, 16);
  copy_bytes(aux + 64, full::kFullLayoutTag, 16);
  copy_bytes(aux + 80, full::kFullBuildTag, 16);
  copy_bytes(aux + 96, full::kFullSourceSha256, 32);
  return ok();
}

Check validate_l13m_model_binding(const NumericIdentity& id,
                                  const ModelBinding& model) {
  const uint8_t* p = model.identity.data();
  if (get(p, 64, 4) != 0x4d33314cu || get(p, 68, 2) != 1 ||
      get(p, 70, 2) != model.identity.size() || get(p, 72, 4) != 0 ||
      get(p, 76, 4) != 1 || get(p, 112, 4) != 5 ||
      get(p, 116, 4) != 16 || get(p, 120, 4) != 128 ||
      !zero_bytes(p, 124, 128) || !zero_bytes(p, 208, model.identity.size()))
    return identity_abi_error(64);
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned entry = 128 + 16 * i;
    if (get(p, entry, 4) != roles[i] || get(p, entry + 4, 4) != 1)
      return identity_abi_error(entry);
    if (get(p, entry + 8, 8) != full::kFullModelBoSizes[i])
      return identity_model_error(entry + 8);
  }
  if (!numeric_identity_valid(id) ||
      !same_bytes(p, full::kFullModelTag, 16) ||
      !same_bytes(p + 16, full::kFullNumericTag, 16) ||
      !same_bytes(p + 32, full::kFullLayoutTag, 16) ||
      !same_bytes(p + 48, full::kFullBuildTag, 16) ||
      !same_bytes(p + 80, full::kFullSourceSha256, 32) ||
      !same_bytes(id.model_tag, full::kFullModelTag, 16) ||
      !same_bytes(id.numeric_tag, full::kFullNumericTag, 16) ||
      !same_bytes(id.layout_tag, full::kFullLayoutTag, 16) ||
      !same_bytes(id.build_tag, full::kFullBuildTag, 16))
    return identity_model_error(0);

  const uint8_t* aux = model.expected_aux_header.data();
  if (aux[0] != 'L' || aux[1] != 'Y' || aux[2] != 'M' || aux[3] != 'P' ||
      get(aux, 4, 2) != 1 || get(aux, 6, 2) != 0 ||
      get(aux, 8, 4) != model.expected_aux_header.size() ||
      get(aux, 12, 4) != 13 || get(aux, 16, 4) != 1 ||
      !zero_bytes(aux, 20, 32))
    return identity_abi_error(EXPECTED_AUX_HEADER);
  if (!same_bytes(aux + 32, full::kFullModelTag, 16) ||
      !same_bytes(aux + 48, full::kFullNumericTag, 16) ||
      !same_bytes(aux + 64, full::kFullLayoutTag, 16) ||
      !same_bytes(aux + 80, full::kFullBuildTag, 16) ||
      !same_bytes(aux + 96, full::kFullSourceSha256, 32))
    return identity_model_error(EXPECTED_AUX_HEADER + 32);
  return ok();
}

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
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
#endif

Check build_load_command(const NumericIdentity& identity,
                         const full::FullMemory& memory,
                         const ModelBinding& model,
                         const full::FullWeightDescriptor& descriptor,
                         const LoadTask& task, uint64_t generation,
                         Command& command) {
  Check model_check = validate_l13m_model_binding(identity, model);
  if (!model_check) return model_check;
  if (!generation ||
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
  Check c = validate_l13m_model_binding(identity, model);
  if (!c) return c;
  c = binding_ok(identity, binding, Service::QUANT);
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
  Check c = validate_l13m_model_binding(identity, model);
  if (!c) return c;
  c = binding_ok(identity, binding, Service::MATRIX);
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
  Check c = validate_l13m_model_binding(identity, model);
  if (!c) return c;
  c = binding_ok(identity, binding, Service::GEGLU);
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
