#include "laya_full_runtime.h"

namespace laya::full {
namespace {

struct Controller {
  FullRuntime& rt;
  FullMemory& memory;
  uint8_t error_stage = 0, error_op = 0;
  uint32_t error_task_id = 0;
  uint8_t current_stage = 0, current_op = 0;

  void phase(uint8_t stage, Op op) {
    current_stage = stage;
    current_op = uint8_t(op);
  }

  bool physical(const FullOwnerRecord& r, Buffer id,
                uint8_t bank, uint8_t region) const {
    if (r.ref.id == Buffer::NONE || r.region != region) return false;
    if (id == Buffer::ROPE_TABLE && r.ref.id == id) return true;
    if (r.ref.bank != bank) return false;
    if (r.ref.id == id) return true;
    return (id == Buffer::WI && r.ref.id == Buffer::DEC_FF) ||
           (id == Buffer::DEC_FF && r.ref.id == Buffer::WI);
  }
  BufferRef fresh(Buffer id, uint8_t bank = 0, uint8_t region = 0) const {
    for (unsigned i = 0; i < 32; ++i) {
      const FullOwnerRecord& record = rt.owners.record[i];
      if (physical(record, id, bank, region))
        return {id, bank, record.max_claimed_epoch < kMaxEpoch ?
                          record.max_claimed_epoch + 1 : 0};
    }
    return {id, bank, 1};
  }
  TaskContext context(Op op, uint8_t stage, uint8_t layer,
                      uint8_t batch, RowSpace space,
                      uint16_t row0, uint8_t rows) const {
    return {rt.last_task_id + 1, op, stage, layer, batch,
            space, row0, rows};
  }
  template<class T>
  Check issue(const T& task, uint32_t elements,
              OutputUnit unit = OutputUnit::F32) {
    phase(task.ctx.stage, task.ctx.op);
    TaskDone done;
    Check c = full_run_task(rt, memory, task, done);
    Check completion = check_done(done, task.ctx.task_id, elements, unit);
    if (completion && done.status != c.code)
      completion = {Status::E_INTERNAL,
                    detail(7, uint8_t(task.ctx.op), 14)};
    if (!completion || !c) {
      error_stage = task.ctx.stage;
      error_op = uint8_t(task.ctx.op);
      error_task_id = task.ctx.task_id;
    }
    return completion ? c : completion;
  }
  FullOwnerSpec matrix(BufferRef ref, uint8_t region, uint8_t stage,
                       uint8_t layer, RowSpace space, uint16_t width,
                       Content content = Content::F32) const {
    return {ref, region, stage, layer, 255, space, 0,
            space == RowSpace::TOKEN ? rt.inputs.identity.S :
            space == RowSpace::MARKER ? uint16_t(16) : uint16_t(1),
            width, content};
  }
  Check bind(const FullOwnerSpec& source) {
    return full_bind_task_source(rt, source);
  }
  void checkpoint(const char* name, const FullOwnerSpec& object) {
#ifndef __SYNTHESIS__
    if (rt.checkpoint)
      rt.checkpoint(name, rt, object.ref, object.region,
                    object.row_space, object.width, rt.checkpoint_user);
#else
    (void)name; (void)object;
#endif
  }
  void checkpoint_name(const char* prefix, uint8_t layer,
                       const FullOwnerSpec& object) {
#ifndef __SYNTHESIS__
    char name[24] = {};
    unsigned i = 0;
    while (prefix[i]) { name[i] = prefix[i]; ++i; }
    name[i++] = char('0' + layer / 10);
    name[i++] = char('0' + layer % 10);
    name[i++] = '_'; name[i++] = 'o'; name[i++] = 'u';
    name[i++] = 't'; name[i] = 0;
    checkpoint(name, object);
#else
    (void)prefix; (void)layer; (void)object;
#endif
  }
  Check load_gamma(uint8_t kind) {
    phase(kind == 1 ? 1 : 3, Op::LOAD_LN_PARAMS);
    LoadTask t;
    t.ctx = context(Op::LOAD_LN_PARAMS, kind == 1 ? 1 : 3,
                    255, 0, RowSpace::BATCH, 0, 1);
    t.kind = 2;
    t.dst = fresh(Buffer::LN_GAMMA, kind - 1);
    t.weight = {0, 255};
    t.head = 255;
    t.byte_count = 4096;
    return issue(t, t.byte_count, OutputUnit::BYTES);
  }
  Check load_weight(WeightKey key, uint8_t stage, uint8_t layer,
                    FullWeightDescriptor& descriptor) {
    phase(stage, Op::LOAD_W);
    Check c = full_lookup_weight(key, descriptor);
    if (!c) return c;
    LoadTask t;
    t.ctx = context(Op::LOAD_W, stage, layer, 0,
                    RowSpace::BATCH, 0, 1);
    t.kind = 0;
    t.dst = fresh(Buffer::WEIGHT);
    t.weight = key;
    t.head = 255;
    t.byte_count = ((uint32_t(descriptor.N) + 7u) & ~7u) *
                   (descriptor.K / 32u) * 34u;
    return issue(t, t.byte_count, OutputUnit::BYTES);
  }
  Check embed_tokens(FullOwnerSpec& output) {
    phase(1, Op::EMB_TOKEN);
    output = matrix(fresh(Buffer::HIDDEN, 0), 0, 1, 255,
                    RowSpace::TOKEN, 1024);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
        EmbeddingTask t;
        t.ctx = context(Op::EMB_TOKEN, 1, 255, uint8_t(b),
                        RowSpace::TOKEN, uint16_t(row), 16);
        t.table = 0; t.type_id = 255; t.dst = output.ref;
        c = issue(t, 16u * 1024u);
        if (!c) break;
      }
    if (c) c = full_publish_owner(rt, output);
    if (c) checkpoint("embedding_raw", output);
    return c;
  }
  Check norm(Op op, const FullOwnerSpec& source, uint8_t stage,
             uint8_t layer, BufferRef dst_ref, uint8_t dst_region,
             uint8_t gamma, FullOwnerSpec& output) {
    phase(stage, op);
    output = matrix(dst_ref, dst_region, stage, layer,
                    source.row_space, 1024);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    const unsigned rows = output.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        LayerNormTask t;
        t.ctx = context(op, stage, layer, uint8_t(b),
                        output.row_space, uint16_t(row),
                        uint8_t(rows - row < 16 ? rows - row : 16));
        t.src = source.ref; t.dst = output.ref; t.gamma = gamma;
        c = bind(source);
        if (c) c = issue(t, uint32_t(t.ctx.rows) * 1024u);
        if (!c) break;
      }
    if (c) c = full_publish_owner(rt, output);
    return c;
  }
  Check vector(Op op, const FullOwnerSpec& src0,
               const FullOwnerSpec* src1, uint8_t stage, uint8_t layer,
               BufferRef dst_ref, uint8_t dst_region,
               uint16_t length, FullOwnerSpec& output) {
    phase(stage, op);
    output = matrix(dst_ref, dst_region, stage, layer,
                    op == Op::APPLY_CAND_MASK ? RowSpace::BATCH :
                    src0.row_space, length);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    const unsigned rows = output.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        VectorTask t;
        t.ctx = context(op, stage, layer, uint8_t(b),
                        output.row_space, uint16_t(row),
                        uint8_t(rows - row < 16 ? rows - row : 16));
        t.src0 = src0.ref; t.src0_region = src0.region;
        t.src1 = src1 ? src1->ref : none();
        t.src1_region = src1 ? src1->region : 0;
        t.dst = output.ref; t.dst_region = dst_region;
        t.length = length;
        c = bind(src0);
        if (c && src1) c = bind(*src1);
        if (c) c = issue(t, uint32_t(t.ctx.rows) * length);
        if (!c) break;
      }
    if (c) c = full_publish_owner(rt, output);
    return c;
  }
  Check linear(Op op, WeightKey key, const FullOwnerSpec& source,
               uint8_t stage, uint8_t layer, BufferRef dst_ref,
               uint8_t dst_region, FullOwnerSpec& output,
               FullOwnerSpec* qkv_pair = nullptr) {
    phase(stage, op);
    FullWeightDescriptor descriptor;
    Check c = load_weight(key, stage, layer, descriptor);
    if (!c) return c;
    phase(stage, op);
    const bool qkv = op == Op::LIN_QKV;
    output = matrix(dst_ref, dst_region, stage, layer,
                    source.row_space, qkv ? 64 : descriptor.N,
                    qkv ? (stage == 4 ? Content::QKV_FINAL :
                           Content::QKV_RAW) : Content::F32);
    FullOwnerSpec pair[2];
    const bool scorer_lease = op == Op::LIN_SCORER_FC1;
    if (qkv) {
      if (!qkv_pair) return {Status::E_INTERNAL, detail(7, 0, 4)};
      pair[0] = output;
      pair[1] = output;
      pair[1].ref = fresh(Buffer::QKV, 1);
      c = full_claim_qkv_pair(rt, pair);
    } else if (!scorer_lease) c = full_claim_owner(rt, output);
    if (!c) return c;
    const unsigned rows = source.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        const uint8_t count = uint8_t(rows - row < 16 ? rows - row : 16);
        QuantTask quant;
        quant.ctx = context(Op::QUANT, stage, layer, uint8_t(b),
                            source.row_space, uint16_t(row), count);
        quant.src = source.ref;
        quant.src_region = source.region;
        quant.a_dst = fresh(Buffer::A8);
        quant.K = descriptor.K;
        c = full_bind_quant_source(rt, source);
        if (c) c = issue(quant, uint32_t(count) * descriptor.K / 32u,
                         OutputUnit::Q8_GROUP);
        if (!c) break;
        LinearTask t;
        t.ctx = context(op, stage, layer, uint8_t(b), source.row_space,
                        uint16_t(row), count);
        t.a = quant.a_dst;
        t.w = rt.current_weight_ref;
        t.ps = fresh(Buffer::PS);
        t.dst = output.ref;
        t.weight = key;
        t.K = descriptor.K; t.N = descriptor.N;
        t.dst_region = dst_region;
        t.bias_kind = descriptor.bias_kind;
        c = issue(t, uint32_t(count) * descriptor.N);
        if (!c) break;
      }
    if (c && qkv) c = full_publish_qkv_pair(rt, pair);
    else if (c && !scorer_lease) c = full_publish_owner(rt, output);
    if (c && qkv) {
      qkv_pair[0] = pair[0];
      qkv_pair[1] = pair[1];
    }
    return c;
  }
  Check attention(uint8_t stage, uint8_t layer,
                  const FullOwnerSpec (&produced)[2],
                  FullOwnerSpec& output) {
    phase(stage, stage == 2 ? Op::ROPE : Op::QK);
    FullOwnerSpec final[2] = {produced[0], produced[1]};
    Check c = ok();
    if (stage == 2) {
      const uint8_t mode = layer % 3 == 0 ? 0 : 1;
      LoadTask load;
      load.ctx = context(Op::LOAD_ROPE, 2, layer, 0,
                         RowSpace::BATCH, 0, 1);
      load.kind = 3; load.dst = fresh(Buffer::ROPE_TABLE, mode);
      load.weight = {0, 255}; load.head = 255;
      load.byte_count = 2u * 1025u * 64u * 4u;
      c = issue(load, load.byte_count, OutputUnit::BYTES);
      if (!c) return c;
      phase(stage, Op::ROPE);
      for (unsigned shard = 0; shard < 2; ++shard) {
        final[shard].ref.epoch = produced[shard].ref.epoch + 1;
        final[shard].content = Content::QKV_FINAL;
      }
      c = full_begin_qkv_rope_pair(rt, produced, final);
      if (!c) return c;
      for (unsigned head = 0; head < 16 && c; ++head)
        for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
          for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
            RopeTask t;
            t.ctx = context(Op::ROPE, 2, layer, uint8_t(b),
                            RowSpace::TOKEN, uint16_t(row), 16);
            t.src_qkv_ref = {produced[0].ref, produced[1].ref};
            t.dst_qkv_ref = {final[0].ref, final[1].ref};
            t.head = uint8_t(head); t.mode = mode; t.table_set = mode;
            c = issue(t, 16u * 128u);
            if (!c) break;
          }
      if (c) c = full_commit_qkv_rope_pair(rt, final);
      if (!c) return c;
    }
    output = matrix(fresh(Buffer::ATT_OUT), 0, stage, layer,
                    RowSpace::TOKEN, 1024);
    phase(stage, Op::AV);
    c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned head = 0; head < 16 && c; ++head) {
      LoadTask load;
      load.ctx = context(Op::LOAD_KV, stage, layer, 0,
                         RowSpace::BATCH, 0, 1);
      load.kind = 1; load.dst = fresh(Buffer::KV);
      load.weight = {0, 255}; load.head = uint8_t(head);
      load.planes = 3;
      load.byte_count = 2u * rt.inputs.identity.B *
                        rt.inputs.identity.S * 64u * 4u;
      c = issue(load, load.byte_count, OutputUnit::BYTES);
      if (!c) break;
      phase(stage, Op::QK);
      for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
        for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
          QKTask qk;
          qk.ctx = context(Op::QK, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          qk.qkv_ref = {final[0].ref, final[1].ref};
          qk.kv = load.dst;
          qk.score = fresh(Buffer::SCORE_PROB);
          qk.head = uint8_t(head);
          qk.mask_mode = stage == 2 && layer % 3 != 0 ? 1 : 0;
          qk.S = rt.inputs.identity.S;
          c = issue(qk, 16u * qk.S);
          if (!c) break;
          const FullOwnerSpec raw{qk.score, 0, stage, layer, uint8_t(b),
                                   RowSpace::TOKEN, uint16_t(row), 16,
                                   qk.S, Content::SCORE};
          FullOwnerSpec prob = raw;
          prob.ref.epoch += 1;
          prob.content = Content::PROB;
          c = full_begin_inplace_owner(rt, raw, prob);
          if (!c) break;
          SoftmaxTask sm;
          sm.ctx = context(Op::SOFTMAX_ATT, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          sm.src = raw.ref; sm.dst = prob.ref;
          sm.length = qk.S; sm.mode = 0;
          c = issue(sm, 16u * sm.length);
          if (!c) break;
          AVTask av;
          av.ctx = context(Op::AV, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          av.prob = prob.ref; av.kv = load.dst;
          av.partial = fresh(Buffer::AV_PARTIAL);
          av.dst = output.ref; av.head = uint8_t(head); av.S = qk.S;
          c = issue(av, 16u * 64u);
          if (!c) break;
        }
    }
    if (c) c = full_publish_att(rt, output);
    if (c) {
      c = full_release_owner(rt, final[0]);
      if (c) c = full_release_owner(rt, final[1]);
    }
    return c;
  }

  Check residual(uint8_t stage, uint8_t layer,
                 const FullOwnerSpec& tmp, FullOwnerSpec& hidden) {
    phase(stage, Op::ADD_RESIDUAL);
    FullOwnerSpec next;
    Check c = vector(Op::ADD_RESIDUAL, tmp, &hidden, stage, layer,
                     fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
                     0, 1024, next);
    if (c) c = full_release_owner(rt, tmp);
    if (c) c = full_release_owner(rt, hidden);
    if (c) hidden = next;
    return c;
  }

  Check transform(Op op, const FullOwnerSpec& old, uint16_t length,
                  uint16_t bias_id, FullOwnerSpec& next) {
    phase(old.stage, op);
    next = old;
    next.ref.epoch = old.ref.epoch + 1;
    Check c = full_begin_inplace_owner(rt, old, next);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < old.rows; row += 16) {
        VectorTask t;
        t.ctx = context(op, old.stage, old.layer, uint8_t(b),
                        old.row_space, uint16_t(row),
                        uint8_t(old.rows - row < 16 ? old.rows - row : 16));
        t.src0 = old.ref; t.src0_region = old.region;
        t.src1 = none();
        t.dst = next.ref; t.dst_region = next.region;
        t.length = length; t.bias_id = bias_id;
        c = issue(t, uint32_t(t.ctx.rows) * length);
        if (!c) break;
      }
    if (c) c = full_commit_inplace_owner(rt, next);
    if (!c) full_invalidate_owner(rt, next.ref, next.region);
    return c;
  }

  Check type_add(FullOwnerSpec& hidden) {
    phase(3, Op::EMB_TYPE);
    const FullOwnerSpec types{fresh(Buffer::TYPE_ROWS), 0, 3, 255, 0,
                              RowSpace::BATCH, 0, 3, 1024, Content::F32};
    Check c = full_claim_owner(rt, types);
    if (!c) return c;
    for (uint8_t type = 0; type < 3 && c; ++type) {
      bool used = false;
      for (unsigned b = 0; b < rt.inputs.identity.B; ++b)
        if (rt.inputs.qtype[b] == type) used = true;
      if (!used) continue;
      EmbeddingTask t;
      t.ctx = context(Op::EMB_TYPE, 3, 255, 0, RowSpace::BATCH, 0, 1);
      t.table = 1; t.dst = types.ref; t.type_id = type;
      c = issue(t, 1024);
    }
    if (!c) return c;
    FullOwnerSpec next;
    c = vector(Op::ADD_TYPE, hidden, &types, 3, 255,
               fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
               0, 1024, next);
    if (c) c = full_release_owner(rt, types);
    if (c) c = full_release_owner(rt, hidden);
    if (c) {
      hidden = next;
      checkpoint("type_add", hidden);
    }
    return c;
  }

  Check fp_linear(Op op, WeightKey key, const FullOwnerSpec& source,
                  uint8_t stage, uint8_t src_region,
                  uint8_t dst_region, uint16_t K, uint16_t N,
                  FullOwnerSpec& output) {
    phase(stage, op);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, dst_region),
                    dst_region, stage, 255, source.row_space, N);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      FPLinearTask t;
      t.ctx = context(op, stage, 255, uint8_t(b), source.row_space,
                      0, uint8_t(source.rows));
      t.src = source.ref; t.src_region = src_region;
      t.dst = output.ref; t.dst_region = dst_region;
      t.weight = key; t.K = K; t.N = N;
      c = bind(source);
      if (c) c = issue(t, uint32_t(t.ctx.rows) * N);
    }
    if (c) c = full_publish_owner(rt, output);
    return c;
  }

  Check gather(const FullOwnerSpec& hidden, FullOwnerSpec& output) {
    phase(5, Op::GATHER_MARKER);
    output = matrix(fresh(Buffer::MARKER), 0, 5, 255,
                    RowSpace::MARKER, 1024);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      GatherTask t;
      t.ctx = context(Op::GATHER_MARKER, 5, 255, uint8_t(b),
                      RowSpace::MARKER, 0, 16);
      t.hidden = hidden.ref; t.markers = output.ref;
      c = bind(hidden);
      if (c) c = issue(t, 16u * 1024u);
    }
    if (c) c = full_publish_owner(rt, output);
    if (c) checkpoint("marker_gather", output);
    return c;
  }

  Check candidate_masked(const FullOwnerSpec& raw,
                         FullOwnerSpec& output) {
    Check c = vector(Op::APPLY_CAND_MASK, raw, nullptr, 5, 255,
                     fresh(Buffer::HEAD_WORK, 0,
                           uint8_t(Region::CAND_MASKED)),
                     uint8_t(Region::CAND_MASKED), 16, output);
    if (c) checkpoint("candidate_masked", output);
    return c;
  }

  Check candidate_probability(const FullOwnerSpec& masked,
                              FullOwnerSpec& output) {
    phase(6, Op::SOFTMAX_CAND);
    const uint8_t region = uint8_t(Region::CAND_PROB);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 16);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      SoftmaxTask t;
      t.ctx = context(Op::SOFTMAX_CAND, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.src = masked.ref; t.src_region = masked.region;
      t.dst = output.ref; t.dst_region = region;
      t.length = 16; t.mode = 1;
      c = bind(masked);
      if (c) c = issue(t, 16);
    }
    if (c) c = full_publish_owner(rt, output);
    if (c) checkpoint("candidate_prob", output);
    return c;
  }

  Check candidate_statistics(const FullOwnerSpec& prob,
                             FullOwnerSpec& output) {
    phase(6, Op::CAND_STATS);
    const uint8_t region = uint8_t(Region::STATS);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 4);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      StatsTask t;
      t.ctx = context(Op::CAND_STATS, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.probs = prob.ref; t.prob_region = prob.region;
      t.stats = output.ref; t.stats_region = region;
      for (unsigned i = 0; i < 16; ++i)
        t.valid_options += rt.inputs.marker_mask[b][i];
      c = bind(prob);
      if (c) c = issue(t, 4);
    }
    if (c) c = full_publish_owner(rt, output);
    if (c) checkpoint("stats", output);
    return c;
  }

  Check act_concat(const FullOwnerSpec& hidden,
                   const FullOwnerSpec& stats,
                   FullOwnerSpec& output) {
    phase(6, Op::CONCAT_ACT);
    const uint8_t region = uint8_t(Region::ACT_INPUT);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 1028);
    Check c = full_claim_owner(rt, output);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      ConcatActTask t;
      t.ctx = context(Op::CONCAT_ACT, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.hidden = hidden.ref; t.stats = stats.ref;
      t.stats_region = stats.region;
      t.dst = output.ref; t.dst_region = region;
      c = bind(hidden);
      if (c) c = bind(stats);
      if (c) c = issue(t, 1028);
    }
    if (c) c = full_publish_owner(rt, output);
    if (c) checkpoint("act_input", output);
    return c;
  }

  Check graph(FullOwnerSpec& candidate, FullOwnerSpec& act) {
    FullOwnerSpec hidden;
    Check c = embed_tokens(hidden);
    if (!c) return c;
    c = load_gamma(1);
    if (!c) return c;
    FullOwnerSpec normed;
    c = norm(Op::LN_EMB, hidden, 1, 255,
             fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
             0, 1, normed);
    if (!c) return c;
    c = full_release_owner(rt, hidden);
    if (!c) return c;
    hidden = normed;
    checkpoint("embedding_norm", hidden);

    for (uint8_t layer = 0; layer < 28; ++layer) {
      const FullOwnerSpec* att_source = &hidden;
      FullOwnerSpec normalized;
      if (layer) {
        c = norm(Op::LN_ATTN, hidden, 2, layer,
                 fresh(Buffer::NORM), 0, 0, normalized);
        if (!c) return c;
        att_source = &normalized;
      }
      FullOwnerSpec qkv[2];
      FullOwnerSpec qkv_primary;
      c = linear(Op::LIN_QKV, {1, layer}, *att_source,
                 2, layer, fresh(Buffer::QKV, 0), 0,
                 qkv_primary, qkv);
      if (!c) return c;
      if (layer) {
        c = full_release_owner(rt, normalized);
        if (!c) return c;
      }
      FullOwnerSpec attended;
      c = attention(2, layer, qkv, attended);
      if (!c) return c;
      FullOwnerSpec projected;
      c = linear(Op::LIN_WO, {2, layer}, attended, 2, layer,
                 fresh(Buffer::TMP), 0, projected);
      if (!c) return c;
      c = full_release_owner(rt, attended);
      if (!c) return c;
      c = residual(2, layer, projected, hidden);
      if (!c) return c;

      c = norm(Op::LN_FFN, hidden, 2, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec wide;
      c = linear(Op::LIN_WI, {3, layer}, normalized, 2, layer,
                 fresh(Buffer::WI), 0, wide);
      if (!c) return c;
      c = full_release_owner(rt, normalized);
      if (!c) return c;
      FullOwnerSpec gated;
      c = vector(Op::GEGLU, wide, nullptr, 2, layer,
                 fresh(Buffer::GATE), 0, 2624, gated);
      if (!c) return c;
      c = full_release_owner(rt, wide);
      if (!c) return c;
      FullOwnerSpec down;
      c = linear(Op::LIN_DOWN, {4, layer}, gated, 2, layer,
                 fresh(Buffer::TMP), 0, down);
      if (!c) return c;
      c = full_release_owner(rt, gated);
      if (!c) return c;
      c = residual(2, layer, down, hidden);
      if (!c) return c;
      ++rt.encoder_layers_completed;
      checkpoint_name("encoder_", layer, hidden);
    }

    c = load_gamma(2);
    if (!c) return c;
    FullOwnerSpec final_norm;
    c = norm(Op::LN_FINAL, hidden, 3, 255,
             fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
             0, 2, final_norm);
    if (!c) return c;
    c = full_release_owner(rt, hidden);
    if (!c) return c;
    hidden = final_norm;
    checkpoint("final_norm", hidden);
    c = type_add(hidden);
    if (!c) return c;

    for (uint8_t layer = 0; layer < 2; ++layer) {
      FullOwnerSpec normalized;
      c = norm(Op::LN_ATTN, hidden, 4, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec qkv[2];
      FullOwnerSpec qkv_primary;
      c = linear(Op::LIN_QKV, {5, layer}, normalized,
                 4, layer, fresh(Buffer::QKV, 0), 0,
                 qkv_primary, qkv);
      if (!c) return c;
      c = full_release_owner(rt, normalized);
      if (!c) return c;
      FullOwnerSpec attended;
      c = attention(4, layer, qkv, attended);
      if (!c) return c;
      FullOwnerSpec projected;
      c = linear(Op::LIN_WO, {6, layer}, attended, 4, layer,
                 fresh(Buffer::TMP), 0, projected);
      if (!c) return c;
      c = full_release_owner(rt, attended);
      if (!c) return c;
      c = residual(4, layer, projected, hidden);
      if (!c) return c;

      c = norm(Op::LN_FFN, hidden, 4, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec fc1;
      c = linear(Op::LIN_DEC_FC1, {7, layer}, normalized,
                 4, layer, fresh(Buffer::DEC_FF), 0, fc1);
      if (!c) return c;
      c = full_release_owner(rt, normalized);
      if (!c) return c;
      FullOwnerSpec relu;
      c = transform(Op::RELU, fc1, 4096, 65535, relu);
      if (!c) return c;
      FullOwnerSpec fc2;
      c = linear(Op::LIN_DEC_FC2, {8, layer}, relu,
                 4, layer, fresh(Buffer::TMP), 0, fc2);
      if (!c) return c;
      c = full_release_owner(rt, relu);
      if (!c) return c;
      c = residual(4, layer, fc2, hidden);
      if (!c) return c;
      ++rt.decision_layers_completed;
      checkpoint_name("decision_", layer, hidden);
    }

    FullOwnerSpec markers;
    c = gather(hidden, markers);
    if (!c) return c;
    FullOwnerSpec marker_norm;
    c = norm(Op::LN_MARKER, markers, 5, 255,
             fresh(Buffer::HEAD_WORK, 0,
                   uint8_t(Region::SCORER_ACT)),
             uint8_t(Region::SCORER_ACT), 0, marker_norm);
    if (!c) return c;
    c = full_release_owner(rt, markers);
    if (!c) return c;
    checkpoint("marker_norm", marker_norm);

    FullOwnerSpec scorer_baked = marker_norm;
    scorer_baked.ref.epoch += 1;
    phase(5, Op::LIN_SCORER_FC1);
    c = full_begin_inplace_owner(rt, marker_norm, scorer_baked);
    if (!c) return c;
    c = linear(Op::LIN_SCORER_FC1, {9, 255}, marker_norm,
               5, 255, scorer_baked.ref,
               uint8_t(Region::SCORER_ACT), scorer_baked);
    if (c) c = full_commit_inplace_owner(rt, scorer_baked);
    if (!c) {
      full_invalidate_owner(rt, scorer_baked.ref, scorer_baked.region);
      return c;
    }
    checkpoint("scorer_fc1_baked", scorer_baked);
    FullTensorDescriptor scorer_bias;
    uint16_t scorer_bias_id = 65535;
    c = full_lookup_tensor_indexed("scorer_fc1.bias", scorer_bias,
                                   scorer_bias_id);
    if (!c) return c;
    FullOwnerSpec scorer_hidden;
    c = transform(Op::BIAS_GELU_SCORER, scorer_baked, 1024,
                  scorer_bias_id, scorer_hidden);
    if (!c) return c;
    checkpoint("scorer_post_bias_gelu", scorer_hidden);

    FullOwnerSpec raw;
    c = fp_linear(Op::FP_SCORER_FC2, {10, 255}, scorer_hidden,
                  5, scorer_hidden.region, uint8_t(Region::CAND_RAW),
                  1024, 1, raw);
    if (!c) return c;
    checkpoint("candidate_raw", raw);
    c = candidate_masked(raw, candidate);
    if (!c) return c;
    FullOwnerSpec prob;
    c = candidate_probability(candidate, prob);
    if (!c) return c;
    FullOwnerSpec stats;
    c = candidate_statistics(prob, stats);
    if (!c) return c;
    FullOwnerSpec act_input;
    c = act_concat(hidden, stats, act_input);
    if (!c) return c;
    FullOwnerSpec act_dot;
    c = fp_linear(Op::FP_ACT_FC1, {11, 255}, act_input,
                  6, act_input.region, uint8_t(Region::ACT_HIDDEN),
                  1028, 256, act_dot);
    if (!c) return c;
    checkpoint("act_dot", act_dot);
    FullTensorDescriptor act_bias;
    uint16_t act_bias_id = 65535;
    c = full_lookup_tensor_indexed("act_fc1.bias", act_bias, act_bias_id);
    if (!c) return c;
    FullOwnerSpec act_hidden;
    c = transform(Op::BIAS_GELU_ACT, act_dot, 256,
                  act_bias_id, act_hidden);
    if (!c) return c;
    checkpoint("act_hidden", act_hidden);
    c = linear(Op::LIN_ACT_FC2, {12, 255}, act_hidden,
               6, 255,
               fresh(Buffer::HEAD_WORK, 0,
                     uint8_t(Region::ACT_LOGITS)),
               uint8_t(Region::ACT_LOGITS), act);
    if (c) checkpoint("act_logits", act);
    return c;
  }

  Check invalidate_incomplete() {
    for (unsigned i = 0; i < 32; ++i) {
      FullOwnerRecord& owner = rt.owners.record[i];
      if (owner.ref.id == Buffer::NONE) continue;
      if (owner.state == CacheState::READ || owner.readers)
        return {Status::E_INTERNAL, detail(7, 0, 14)};
      if (owner.state == CacheState::FILL ||
          owner.state == CacheState::EXCLUSIVE_RW) {
        Check c = full_invalidate_owner(rt, owner.ref, owner.region);
        if (!c) return c;
      }
    }
    return ok();
  }
};

} // namespace

Check full_execute_request(FullRuntime& rt, FullMemory& memory) {
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  Check result = full_parse_request(rt, memory);
  const bool accepted = bool(result);
  FullOwnerSpec candidate, act;
  if (result) result = controller.graph(candidate, act);
  rt.last_execution_error = result;
  if (!result && accepted && controller.error_task_id == 0) {
    controller.error_stage = controller.current_stage;
    controller.error_op = controller.current_op;
  }
  if (!result && accepted) {
    Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
    if (!cleanup) return result;
  }
  Check committed = full_write_result(rt, memory, result, accepted,
                                      controller.error_stage,
                                      controller.error_op,
                                      controller.error_task_id,
                                      candidate.ref, act.ref);
  if (result && !committed) rt.last_execution_error = committed;
  return committed;
}

} // namespace laya::full
