#include "full_task_common.h"
#include "laya_full_cache_storage.h"

namespace laya::full {
namespace {

bool name_is(const char* actual, const char* wanted) {
  for (unsigned i = 0; i < 48; ++i) {
    if (actual[i] != wanted[i]) return false;
    if (!wanted[i]) return true;
  }
  return false;
}
Check embedding_table(bool types, FullTensorDescriptor& descriptor) {
  const char* name = types ? "type_emb.weight" : "tok_emb.weight";
  for (unsigned i = 0; i < 153; ++i) {
    Check c = full_tensor_descriptor(uint16_t(i), descriptor);
    if (!c) return c;
    if (name_is(descriptor.name, name)) {
      const uint32_t rows = types ? 3 : kVocab;
      if (descriptor.bo != uint8_t(Bo::EMBEDDING) ||
          descriptor.ggml_type_id != 8 || descriptor.ne[0] != 1024 ||
          descriptor.ne[1] != rows || descriptor.span != rows * 1088u)
        return {Status::E_MODEL, detail(4, 0, 4)};
      return ok();
    }
  }
  return {Status::E_MODEL, detail(4, 0, 4)};
}
bool layernorm_shape(const LayerNormTask& t) {
  if (t.D != 1024 || t.eps_bits != 0x3727c5acu ||
      !check_ref(t.src) || !check_ref(t.dst) ||
      (t.src.id == t.dst.id && t.src.bank == t.dst.bank)) return false;
  switch (t.ctx.op) {
    case Op::LN_EMB:
      return t.ctx.stage == 1 && t.ctx.row_space == RowSpace::TOKEN &&
             t.gamma == 1 && t.src.id == Buffer::HIDDEN &&
             (t.dst.id == Buffer::NORM ||
              (t.dst.id == Buffer::HIDDEN && t.dst.bank != t.src.bank));
    case Op::LN_ATTN:
      return (t.ctx.stage == 2 || t.ctx.stage == 4) &&
             !(t.ctx.stage == 2 && t.ctx.layer == 0) &&
             t.ctx.row_space == RowSpace::TOKEN && t.gamma == 0 &&
             t.src.id == Buffer::HIDDEN && t.dst.id == Buffer::NORM;
    case Op::LN_FFN:
      return (t.ctx.stage == 2 || t.ctx.stage == 4) &&
             t.ctx.row_space == RowSpace::TOKEN && t.gamma == 0 &&
             t.src.id == Buffer::HIDDEN && t.dst.id == Buffer::NORM;
    case Op::LN_FINAL:
      return t.ctx.stage == 3 && t.ctx.row_space == RowSpace::TOKEN &&
             t.gamma == 2 && t.src.id == Buffer::HIDDEN &&
             (t.dst.id == Buffer::NORM ||
              (t.dst.id == Buffer::HIDDEN && t.dst.bank != t.src.bank));
    case Op::LN_MARKER:
      return t.ctx.stage == 5 && t.ctx.row_space == RowSpace::MARKER &&
             t.gamma == 0 && t.src.id == Buffer::MARKER &&
             t.dst.id == Buffer::HEAD_WORK;
    default: return false;
  }
}

} // namespace

Check full_run_task(FullRuntime& rt, FullMemory& memory, const EmbeddingTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const bool token = t.ctx.op == Op::EMB_TOKEN && t.table == 0 &&
                     t.type_id == 255 && t.ctx.stage == 1 &&
                     t.ctx.row_space == RowSpace::TOKEN &&
                     t.dst.id == Buffer::HIDDEN;
  const bool type = t.ctx.op == Op::EMB_TYPE && t.table == 1 &&
                    t.type_id < 3 && t.ctx.stage == 3 &&
                    t.ctx.row_space == RowSpace::BATCH &&
                    t.ctx.batch == 0 && t.dst.id == Buffer::TYPE_ROWS;
  if ((!token && !type) || !check_ref(t.dst))
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  FullTensorDescriptor table;
  c = embedding_table(type, table);
  if (c) c = full_span(memory, Bo::EMBEDDING, table.base, table.span);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec dst = token ?
      task::spec(t.dst, 0, 1, 255, RowSpace::TOKEN,
                 rt.inputs.identity.S, 1024) :
      FullOwnerSpec{t.dst, 0, 3, 255, 0, RowSpace::BATCH,
                    0, 3, 1024, Content::F32};
  if (token) c = full_check_uncovered_owner(rt, dst, t.ctx.batch,
                                            t.ctx.row0, t.ctx.rows);
  else {
    FullOwnerRecord owner;
    c = full_owner_snapshot(rt, t.dst, 0, owner);
    if (c && (owner.stage != 3 || owner.layer != 255 ||
              owner.row_space != RowSpace::BATCH || owner.rows != 3 ||
              owner.width != 1024 || owner.content != Content::F32 ||
              (owner.state != CacheState::FILL &&
               owner.state != CacheState::READY) ||
              rt.owners.type_valid[t.type_id])) c = task::buffer(t.dst.id);
  }
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    const int32_t index = type ? t.type_id :
                          rt.inputs.token_ids[t.ctx.batch][row];
    if (index < 0 || uint32_t(index) >= (type ? 3u : kVocab)) {
      c = {Status::E_INDEX, detail(3, 1, 4), row};
      break;
    }
    uint8_t raw[1088];
    float value[1024];
    c = full_read(memory, Bo::EMBEDDING,
                  uint64_t(table.base) + uint32_t(index) * 1088u,
                  raw, sizeof(raw));
    if (c) c = embedding_row(raw, value);
    if (!c) break;
    for (unsigned k = 0; k < 1024; ++k) {
      c = task::write(rt, memory, t.dst, 0, type ? 0 : t.ctx.batch,
                      type ? t.type_id : row, uint16_t(k), value[k]);
      if (!c) break;
    }
  }
  if (c) c = full_cover_owner(rt, dst, type ? 0 : t.ctx.batch,
                              type ? t.type_id : t.ctx.row0,
                              type ? 1 : t.ctx.rows);
  if (c && type) c = full_publish_owner(rt, dst);
  if (!c) full_invalidate_owner(rt, t.dst, 0);
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(type ? 1 : t.ctx.rows) * 1024u, done);
}

Check full_run_task(FullRuntime& rt, FullMemory& memory, const LayerNormTask& t,
                    TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (!layernorm_shape(t))
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec src;
  c = task::source(rt, t.src, 0, t.ctx, 1024, src);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t region = t.ctx.op == Op::LN_MARKER ?
                         uint8_t(Region::SCORER_ACT) : 0;
  const FullOwnerSpec dst = task::spec(t.dst, region, t.ctx.stage,
                                      t.ctx.layer, t.ctx.row_space,
                                      task::extent(rt, t.ctx.row_space), 1024);
  c = full_check_uncovered_owner(rt, dst, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  FullOwnerSpec gamma;
  if (t.gamma) {
    gamma = {rt.loaded_gamma_ref[t.gamma - 1],
             0, t.gamma == 1 ? uint8_t(1) : uint8_t(3), 255, 0,
             RowSpace::BATCH, 0, 1, 1024, Content::F32};
    if (gamma.ref.id != Buffer::LN_GAMMA ||
        gamma.ref.bank != t.gamma - 1)
      c = task::buffer(Buffer::LN_GAMMA);
    if (c) c = full_acquire_owner(rt, gamma, 0, 0, 1);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  float input[16][1024];
  float output[16][1024];
  c = task::read_tile(rt, memory, src, t.ctx, 1024, input);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    float mean = 0.0f, variance = 0.0f, inverse = 0.0f;
    c = layernorm_row_arithmetic(t.ctx.op, r, input[r],
                                  full_cache_gamma(rt)[t.gamma ? t.gamma - 1 : 0],
                                  t.gamma, output[r], mean, variance,
                                  inverse);
  }
  if (t.gamma) {
    Check release = full_release_read_owner(rt, gamma);
    if (c) c = release;
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r)
    for (unsigned k = 0; k < 1024; ++k) {
      c = task::write(rt, memory, t.dst, region, t.ctx.batch,
                      uint16_t(t.ctx.row0 + r), uint16_t(k), output[r][k]);
      if (!c) break;
    }
  if (c) c = full_cover_owner(rt, dst, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (!c) full_invalidate_owner(rt, t.dst, region);
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * 1024u, done);
}

} // namespace laya::full
