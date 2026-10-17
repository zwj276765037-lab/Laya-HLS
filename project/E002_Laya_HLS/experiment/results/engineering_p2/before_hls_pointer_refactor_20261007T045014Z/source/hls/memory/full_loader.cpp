#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

namespace laya::full {
namespace {
Check bad(Buffer id, uint16_t reason = 4) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), reason)};
}
TaskDone failed(uint32_t task_id, Check c) {
  TaskDone d;
  d.task_id = task_id;
  d.status = c.code;
  d.error_detail = c.detail;
  d.bad_element = c.bad_element;
  d.drained = true;
  return d;
}
FullOwnerSpec weight_spec(const FullOwnerRecord& r) {
  FullOwnerSpec s;
  s.ref = r.ref; s.region = r.region; s.stage = r.stage;
  s.layer = r.layer; s.batch = r.batch; s.row_space = r.row_space;
  s.row0 = r.row0; s.rows = r.rows; s.width = r.width;
  s.content = r.content;
  return s;
}
bool same_weight(WeightKey a, WeightKey b) {
  return a.family == b.family && a.layer == b.layer;
}
} // namespace

Check full_load_weight(FullRuntime& rt, WeightKey key, BufferRef next_ref,
                       TaskDone& done) {
  const uint32_t task_id = rt.last_task_id + 1;
  done = TaskDone{};
  if (!task_id || task_id > kMaxEpoch || !rt.request_valid ||
      !rt.model_header_valid || next_ref.id != Buffer::WEIGHT ||
      next_ref.bank != 0 ||
      !check_ref(next_ref)) {
    Check c = bad(Buffer::WEIGHT);
    done = failed(task_id, c);
    return c;
  }
  FullWeightDescriptor d;
  Check c = full_lookup_weight(key, d);
  if (!c || d.dtype != 8 || d.K == 0 || d.N == 0 || d.K % 32) {
    c = {Status::E_MODEL, detail(4, 0, 4)};
    done = failed(task_id, c);
    return c;
  }
  const uint32_t groups = d.K / 32;
  const uint32_t padded_n = (uint32_t(d.N) + 7u) & ~7u;
  const uint32_t entries = padded_n * groups;
  if (entries > 167936 || d.q_span[0] + d.q_span[1] != entries * 32 ||
      d.scale_span != entries * 2 ||
      (d.bias_kind && d.bias_span != uint32_t(d.N) * 4)) {
    c = {Status::E_MODEL, detail(4, 0, 4)};
    done = failed(task_id, c);
    return c;
  }
  c = full_span(rt.memory, Bo::W_Q0, d.q_base[0], d.q_span[0]);
  if (c) c = full_span(rt.memory, Bo::W_Q1, d.q_base[1], d.q_span[1]);
  if (c) c = full_span(rt.memory, Bo::W_SCALE, d.scale_base, d.scale_span);
  if (c && d.bias_kind)
    c = full_span(rt.memory, Bo::AUX, d.bias_base, d.bias_span);
  if (!c) {
    done = failed(task_id, c);
    return c;
  }
  const uint8_t stage = key.family <= 4 ? 2 : key.family <= 8 ? 4 :
                        key.family == 9 ? 5 : 6;
  FullOwnerSpec next{next_ref, 0, stage, key.layer, 0,
                     RowSpace::BATCH, 0, 1, d.N, Content::Q8_WEIGHT};
  if (rt.current_weight_ref.id != Buffer::NONE) {
    FullOwnerRecord old;
    c = full_owner_snapshot(rt, rt.current_weight_ref, 0, old);
    if (!c || !old.valid || old.state != CacheState::READY ||
        next_ref.epoch != old.max_claimed_epoch + 1) {
      c = bad(Buffer::WEIGHT);
      done = failed(task_id, c);
      return c;
    }
    if (same_weight(d.key, rt.current_weight.key)) {
      c = bad(Buffer::WEIGHT);
      done = failed(task_id, c);
      return c;
    }
    c = full_release_owner(rt, weight_spec(old));
    if (!c) {
      done = failed(task_id, c);
      return c;
    }
  }
  c = full_claim_owner(rt, next);
  if (!c) {
    done = failed(task_id, c);
    return c;
  }

  // The complete physical N tail is copied.  Only n<N may be calculated.
  for (uint32_t n = 0; n < padded_n; ++n) {
    const uint32_t tile = n / 8, lane = n % 8;
    const uint32_t shard = tile % 2, local_tile = tile / 2;
    for (uint32_t g = 0; g < groups; ++g) {
      const uint32_t q_relative = ((local_tile * groups + g) * 8 + lane) * 32;
      const uint32_t s_relative = ((tile * groups + g) * 8 + lane) * 2;
      const uint32_t index = n * groups + g;
      if (q_relative + 32 > d.q_span[shard] ||
          s_relative + 2 > d.scale_span) {
        c = bad(Buffer::WEIGHT, 8);
        goto failed_after_claim;
      }
      c = full_read(rt.memory, shard ? Bo::W_Q1 : Bo::W_Q0,
                    uint64_t(d.q_base[shard]) + q_relative,
                    reinterpret_cast<uint8_t*>(&rt.cache.weight_q[index * 32]),
                    32);
      if (!c) goto failed_after_claim;
      uint8_t scale[2];
      c = full_read(rt.memory, Bo::W_SCALE,
                    uint64_t(d.scale_base) + s_relative, scale, 2);
      if (!c) goto failed_after_claim;
      rt.cache.weight_scale[index] =
          uint16_t(scale[0]) | uint16_t(uint16_t(scale[1]) << 8);
      const float d_scale = numeric_half_to_f32(rt.cache.weight_scale[index]);
      if ((numeric_f32_bits(d_scale) & 0x7f800000u) == 0x7f800000u ||
          d_scale < 0.0f) {
        c = {Status::E_NUMERICAL, detail(7, uint8_t(Op::LOAD_W), 15), index};
        goto failed_after_claim;
      }
    }
  }
  for (uint32_t n = 0; n < d.N; ++n) {
    if (d.bias_kind) {
      uint8_t raw[4];
      c = full_read(rt.memory, Bo::AUX,
                    uint64_t(d.bias_base) + n * 4, raw, 4);
      if (!c) goto failed_after_claim;
      const uint32_t bits = uint32_t(raw[0]) | (uint32_t(raw[1]) << 8) |
                            (uint32_t(raw[2]) << 16) |
                            (uint32_t(raw[3]) << 24);
      rt.cache.weight_bias[n] = numeric_bits_f32(bits);
      if ((bits & 0x7f800000u) == 0x7f800000u) {
        c = {Status::E_NUMERICAL, detail(7, uint8_t(Op::LOAD_W), 15), n};
        goto failed_after_claim;
      }
    } else {
      rt.cache.weight_bias[n] = 0.0f;
    }
  }
  c = full_cover_owner(rt, next, 0, 0, 1);
  if (!c) goto failed_after_claim;
  c = full_publish_owner(rt, next);
  if (!c) goto failed_after_claim;
  rt.current_weight = d;
  rt.current_weight_ref = next_ref;
  rt.last_task_id = task_id;
  ++rt.tasks_retired;
  ++rt.op_calls[uint8_t(Op::LOAD_W)];
  done.task_id = task_id;
  done.status = Status::OK;
  done.output_elements = entries * 34;
  done.output_unit = OutputUnit::BYTES;
  done.drained = true;
  return ok();

failed_after_claim:
  full_invalidate_owner(rt, next_ref, 0);
  rt.current_weight = FullWeightDescriptor{};
  rt.current_weight_ref = none();
  rt.last_task_id = task_id;
  ++rt.tasks_retired;
  ++rt.op_calls[uint8_t(Op::LOAD_W)];
  done = failed(task_id, c);
  return c;
}

namespace {
bool name_is(const char* actual, const char* expected) {
  for (unsigned i = 0; i < 48; ++i) {
    if (actual[i] != expected[i]) return false;
    if (!expected[i]) return true;
  }
  return false;
}
Check tensor_named(const char* name, FullTensorDescriptor& out) {
  for (unsigned i = 0; i < 153; ++i)
    if (name_is(kFullTensors[i].name, name)) {
      out = kFullTensors[i];
      return ok();
    }
  return {Status::E_MODEL, detail(4, 0, 4)};
}
Check read_aux_f32(const FullRuntime& rt, uint32_t offset, Op op,
                   float& output) {
  uint8_t raw[4];
  Check c = full_read(rt.memory, Bo::AUX, offset, raw, 4);
  if (!c) return c;
  const uint32_t bits = uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                        uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24;
  if ((bits & 0x7f800000u) == 0x7f800000u)
    return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15)};
  output = numeric_bits_f32(bits);
  return ok();
}
Check read_qkv_f32(const FullRuntime& rt, uint8_t plane, uint8_t batch,
                   uint8_t head, uint16_t row, uint8_t d, float& output) {
  Address a;
  Check c = qkv_address(plane, batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(rt.memory, a.bo, a.offset, raw, 4);
  if (!c) return c;
  const uint32_t bits = uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                        uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24;
  if ((bits & 0x7f800000u) == 0x7f800000u)
    return {Status::E_NUMERICAL, detail(7, uint8_t(Op::LOAD_KV), 15)};
  output = numeric_bits_f32(bits);
  return ok();
}
Check finish_load(FullRuntime& rt, const LoadTask& t, Check c,
                  TaskDone& done) {
  done = failed(t.ctx.task_id, c);
  if (c) {
    done.output_unit = OutputUnit::BYTES;
    done.output_elements = t.byte_count;
  }
  if (t.ctx.task_id == rt.last_task_id + 1 &&
      t.ctx.task_id <= kMaxEpoch) {
    rt.last_task_id = t.ctx.task_id;
    ++rt.tasks_retired;
    ++rt.op_calls[uint8_t(t.ctx.op)];
  }
  rt.expected_task_source_count = 0;
  return c;
}
bool next_load(const FullRuntime& rt, const LoadTask& t) {
  return rt.request_valid && rt.model_header_valid &&
         t.ctx.task_id == rt.last_task_id + 1 &&
         t.ctx.task_id <= kMaxEpoch;
}
} // namespace

Check full_run_task(FullRuntime& rt, const LoadTask& t, TaskDone& done) {
  Check c = next_load(rt, t) ?
            check_context(t.ctx, rt.inputs.identity.B, rt.inputs.identity.S) :
            bad(Buffer::NONE);
  if (!c || t.kind > 3 ||
      uint8_t(t.ctx.op) != uint8_t(Op::LOAD_W) + t.kind ||
      t.ctx.row_space != RowSpace::BATCH || t.ctx.batch != 0 ||
      t.ctx.row0 || t.ctx.rows != 1 || !check_ref(t.dst)) {
    if (c) c = bad(t.dst.id, 5);
    return finish_load(rt, t, c, done);
  }
  if (t.kind == 0) {
    FullWeightDescriptor d;
    c = full_lookup_weight(t.weight, d);
    if (!c || d.dtype != 8 || t.dst.id != Buffer::WEIGHT ||
        t.dst.bank != 0 || t.head != 255 || t.planes != 0 ||
        t.byte_count != ((uint32_t(d.N) + 7u) & ~7u) *
                        (d.K / 32u) * 34u ||
        !check_weight(t.weight, t.ctx.stage, t.ctx.layer,
                      d.K, d.N)) {
      c = bad(Buffer::WEIGHT, 5);
      return finish_load(rt, t, c, done);
    }
    return full_load_weight(rt, t.weight, t.dst, done);
  }
  if (t.weight.family || t.weight.layer != 255) {
    c = bad(t.dst.id, 5);
    return finish_load(rt, t, c, done);
  }
  if (t.kind == 2) {
    const uint8_t bank = t.ctx.stage == 1 ? 0 : 1;
    if ((t.ctx.stage != 1 && t.ctx.stage != 3) ||
        t.dst.id != Buffer::LN_GAMMA || t.dst.bank != bank ||
        t.head != 255 || t.planes || t.byte_count != 4096) {
      c = bad(Buffer::LN_GAMMA, 5);
      return finish_load(rt, t, c, done);
    }
    FullTensorDescriptor d;
    c = tensor_named(bank ? "final_norm_w" : "emb_norm_w", d);
    if (c && (d.bo != uint8_t(Bo::AUX) || d.span != 4096 ||
              d.ggml_type_id != 0)) c = {Status::E_MODEL, detail(4, 0, 4)};
    if (c) c = full_span(rt.memory, Bo::AUX, d.base, d.span);
    if (!c) return finish_load(rt, t, c, done);
    const FullOwnerSpec spec{t.dst, 0, t.ctx.stage, 255, 0,
                             RowSpace::BATCH, 0, 1, 1024, Content::F32};
    c = full_claim_owner(rt, spec);
    if (!c) return finish_load(rt, t, c, done);
    for (unsigned i = 0; i < 1024; ++i) {
      c = read_aux_f32(rt, d.base + i * 4, Op::LOAD_LN_PARAMS,
                       rt.cache.gamma[bank][i]);
      if (!c) break;
    }
    if (c) c = full_cover_owner(rt, spec, 0, 0, 1);
    if (c) c = full_publish_owner(rt, spec);
    if (!c) full_invalidate_owner(rt, t.dst, 0);
    else rt.loaded_gamma_ref[bank] = t.dst;
    return finish_load(rt, t, c, done);
  }
  if (t.kind == 3) {
    const uint8_t mode = t.ctx.layer % 3 == 0 ? 0 : 1;
    if (t.ctx.stage != 2 || t.ctx.layer > 27 ||
        t.dst.id != Buffer::ROPE_TABLE || t.dst.bank != mode ||
        t.head != 255 || t.planes || t.byte_count != 2u * 1025u * 64u * 4u) {
      c = bad(Buffer::ROPE_TABLE, 5);
      return finish_load(rt, t, c, done);
    }
    FullTensorDescriptor d[2];
    c = tensor_named(mode ? "cos_slide" : "cos_full", d[0]);
    if (c) c = tensor_named(mode ? "sin_slide" : "sin_full", d[1]);
    for (unsigned i = 0; c && i < 2; ++i) {
      if (d[i].bo != uint8_t(Bo::AUX) || d[i].span != 262400 ||
          d[i].ggml_type_id != 0)
        c = {Status::E_MODEL, detail(4, 0, 4)};
      else c = full_span(rt.memory, Bo::AUX, d[i].base, d[i].span);
    }
    if (!c) return finish_load(rt, t, c, done);
    if (rt.loaded_rope_ref.id != Buffer::NONE) {
      FullOwnerRecord old;
      c = full_owner_snapshot(rt, rt.loaded_rope_ref, 0, old);
      if (!c || !old.valid || old.state != CacheState::READY ||
          t.dst.epoch != old.max_claimed_epoch + 1) {
        c = bad(Buffer::ROPE_TABLE);
        return finish_load(rt, t, c, done);
      }
      c = full_release_owner(rt, weight_spec(old));
      if (!c) return finish_load(rt, t, c, done);
    }
    const FullOwnerSpec spec{t.dst, 0, 2, t.ctx.layer, 0,
                             RowSpace::BATCH, 0, 1, 64, Content::F32};
    c = full_claim_owner(rt, spec);
    if (!c) return finish_load(rt, t, c, done);
    for (unsigned table = 0; table < 2 && c; ++table)
      for (unsigned pos = 0; pos < 1025 && c; ++pos)
        for (unsigned j = 0; j < 64; ++j) {
          c = read_aux_f32(rt, d[table].base + (pos * 64 + j) * 4,
                           Op::LOAD_ROPE,
                           rt.cache.rope_table[table][pos][j]);
          if (!c) break;
        }
    if (c) c = full_cover_owner(rt, spec, 0, 0, 1);
    if (c) c = full_publish_owner(rt, spec);
    if (!c) {
      full_invalidate_owner(rt, t.dst, 0);
      rt.loaded_rope_ref = none(); rt.loaded_rope_mode = 255;
    } else {
      rt.loaded_rope_ref = t.dst; rt.loaded_rope_mode = mode;
    }
    return finish_load(rt, t, c, done);
  }
  // LOAD_KV: the current fully published pair supplies both K and V planes.
  if ((t.ctx.stage != 2 && t.ctx.stage != 4) ||
      t.dst.id != Buffer::KV || t.dst.bank != 0 ||
      t.head >= 16 || t.planes != 3 ||
      t.byte_count != 2u * rt.inputs.identity.B *
                      rt.inputs.identity.S * 64u * 4u ||
      rt.final_qkv_ref[0].id != Buffer::QKV ||
      rt.final_qkv_ref[1].id != Buffer::QKV) {
    c = bad(Buffer::KV, 5);
    return finish_load(rt, t, c, done);
  }
  if (rt.score_valid) {
    c = bad(Buffer::SCORE_PROB);
    return finish_load(rt, t, c, done);
  }
  FullOwnerSpec qkv[2];
  for (unsigned shard = 0; shard < 2; ++shard)
    qkv[shard] = {rt.final_qkv_ref[shard], 0, t.ctx.stage, t.ctx.layer,
                  255, RowSpace::TOKEN, 0, rt.inputs.identity.S,
                  64, Content::QKV_FINAL};
  for (unsigned shard = 0; shard < 2 && c; ++shard)
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      c = full_require_owner(rt, qkv[shard], uint8_t(b), 0,
                             rt.inputs.identity.S);
  if (!c) return finish_load(rt, t, c, done);
  if (rt.loaded_kv_ref.id != Buffer::NONE) {
    FullOwnerRecord old;
    c = full_owner_snapshot(rt, rt.loaded_kv_ref, 0, old);
    if (!c || !old.valid || old.state != CacheState::READY ||
        t.dst.epoch != old.max_claimed_epoch + 1) {
      c = bad(Buffer::KV);
      return finish_load(rt, t, c, done);
    }
    c = full_release_owner(rt, weight_spec(old));
    if (!c) return finish_load(rt, t, c, done);
  }
  const FullOwnerSpec kv{t.dst, 0, t.ctx.stage, t.ctx.layer, 255,
                         RowSpace::TOKEN, 0, rt.inputs.identity.S,
                         64, Content::F32};
  c = full_claim_owner(rt, kv);
  if (!c) return finish_load(rt, t, c, done);
  bool read0 = false, read1 = false;
  c = full_acquire_owner(rt, qkv[0], 0, 0, rt.inputs.identity.S);
  if (c) {
    read0 = true;
    c = full_acquire_owner(rt, qkv[1], 0, 0, rt.inputs.identity.S);
    if (c) read1 = true;
  }
  if (!c) goto kv_fail;
  for (unsigned plane = 0; plane < 2 && c; ++plane)
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rt.inputs.identity.S && c; ++row)
        for (unsigned j = 0; j < 64; ++j) {
          c = read_qkv_f32(rt, uint8_t(plane + 1), uint8_t(b), t.head,
                           uint16_t(row), uint8_t(j),
                           rt.cache.kv[plane][b][row][j]);
          if (!c) break;
        }
  if (read1) { full_release_read_owner(rt, qkv[1]); read1 = false; }
  if (read0) { full_release_read_owner(rt, qkv[0]); read0 = false; }
  if (c)
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      c = full_cover_owner(rt, kv, uint8_t(b), 0, rt.inputs.identity.S);
  if (c) c = full_publish_owner(rt, kv);
  if (c) {
    rt.loaded_kv_ref = t.dst;
    rt.loaded_kv_head = t.head;
    return finish_load(rt, t, ok(), done);
  }
kv_fail:
  if (read1) full_release_read_owner(rt, qkv[1]);
  if (read0) full_release_read_owner(rt, qkv[0]);
  full_invalidate_owner(rt, t.dst, 0);
  rt.loaded_kv_ref = none(); rt.loaded_kv_head = 255;
  return finish_load(rt, t, c, done);
}

} // namespace laya::full
