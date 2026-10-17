#include "laya_full_runtime.h"
#include "laya_tasks.h"

// D1 probe only. This file does not call the production owner or numeric task
// implementations. Its load, bind, and issue stand-ins expose metadata flow.
namespace {
using namespace laya;
using namespace laya::full;

struct Probe {
  FullOwnerSpec output;
  FullOwnerSpec pair[2];
  VectorTask issued;
  BufferRef second_bound;
  uint8_t second_bound_region = 0;
  uint8_t second_bind_count = 0;
  FullOwnerSpec attention_source;
};

FullOwnerSpec spec(Buffer id, uint8_t bank, uint32_t epoch,
                   uint8_t region, uint8_t stage, uint8_t layer,
                   uint16_t rows, Content content) {
  FullOwnerSpec result;
  result.ref = {id, bank, epoch};
  result.region = region;
  result.stage = stage;
  result.layer = layer;
  result.batch = 255;
  result.row_space = RowSpace::TOKEN;
  result.row0 = 0;
  result.rows = rows;
  result.width = 64;
  result.content = content;
  return result;
}

Check probe_load(uint8_t load_ok) {
  return load_ok ? ok() : Check{Status::E_BUFFER, detail(4, 0, 17)};
}

Check probe_claim(const FullOwnerSpec (&pair)[2]) {
  if (pair[0].ref.id != Buffer::QKV || pair[1].ref.id != Buffer::QKV ||
      pair[0].ref.bank != 0 || pair[1].ref.bank != 1 ||
      pair[0].ref.epoch == 0 || pair[1].ref.epoch == 0)
    return {Status::E_BUFFER, detail(4, 5, 5)};
  return ok();
}

Check probe_publish(const FullOwnerSpec (&pair)[2], Probe& probe) {
  probe.pair[0] = pair[0];
  probe.pair[1] = pair[1];
  return ok();
}

#ifdef EXPLICIT_PRESENCE
Check linear_impl(Op op, const FullOwnerSpec& source, uint8_t stage,
                  uint8_t layer, uint32_t epoch, uint8_t load_ok,
                  FullOwnerSpec& output, bool pair_present,
                  FullOwnerSpec (&pair_output)[2], Probe& probe) {
#else
Check linear_impl(Op op, const FullOwnerSpec& source, uint8_t stage,
                  uint8_t layer, uint32_t epoch, uint8_t load_ok,
                  FullOwnerSpec& output, FullOwnerSpec* pair_output,
                  Probe& probe) {
#endif
#pragma HLS inline off
  Check c = probe_load(load_ok);
  if (!c) return c;
  const bool qkv = op == Op::LIN_QKV;
  output = spec(qkv ? Buffer::QKV : Buffer::TMP, 0, epoch, 0,
                stage, layer, source.rows,
                qkv ? (stage == 4 ? Content::QKV_FINAL : Content::QKV_RAW)
                    : Content::F32);
  probe.output = output;
  FullOwnerSpec pair[2];
  if (qkv) {
#ifdef EXPLICIT_PRESENCE
    if (!pair_present) return {Status::E_INTERNAL, detail(7, 0, 4)};
#else
    if (!pair_output) return {Status::E_INTERNAL, detail(7, 0, 4)};
#endif
    pair[0] = output;
    pair[1] = output;
    pair[1].ref.bank = 1;
    c = probe_claim(pair);
    if (!c) return c;
  }
  if (qkv) {
    c = probe_publish(pair, probe);
    if (!c) return c;
    pair_output[0] = pair[0];
    pair_output[1] = pair[1];
  }
  return c;
}

#ifdef EXPLICIT_PRESENCE
Check linear(Op op, const FullOwnerSpec& source, uint8_t stage,
             uint8_t layer, uint32_t epoch, uint8_t load_ok,
             FullOwnerSpec& output, FullOwnerSpec (&pair_output)[2],
             Probe& probe) {
  return linear_impl(op, source, stage, layer, epoch, load_ok,
                     output, true, pair_output, probe);
}

Check linear(Op op, const FullOwnerSpec& source, uint8_t stage,
             uint8_t layer, uint32_t epoch, uint8_t load_ok,
             FullOwnerSpec& output, Probe& probe) {
  FullOwnerSpec unused_pair[2];
  return linear_impl(op, source, stage, layer, epoch, load_ok,
                     output, false, unused_pair, probe);
}
#else
Check linear(Op op, const FullOwnerSpec& source, uint8_t stage,
             uint8_t layer, uint32_t epoch, uint8_t load_ok,
             FullOwnerSpec& output, Probe& probe,
             FullOwnerSpec* pair_output = nullptr) {
  return linear_impl(op, source, stage, layer, epoch, load_ok,
                     output, pair_output, probe);
}
#endif

Check probe_bind(const FullOwnerSpec& value) {
  return value.ref.id == Buffer::NONE ?
      Check{Status::E_BUFFER, detail(4, 0, 6)} : ok();
}

Check probe_issue_vector(const VectorTask& task) {
  if ((task.ctx.op == Op::ADD_RESIDUAL || task.ctx.op == Op::ADD_TYPE) &&
      task.src1.id == Buffer::NONE)
    return {Status::E_SHAPE, detail(7, 3, 1)};
  return ok();
}

#ifdef EXPLICIT_PRESENCE
Check vector_impl(Op op, const FullOwnerSpec& src0,
                  bool src1_present, const FullOwnerSpec& src1,
                  uint8_t stage, uint8_t layer, Probe& probe) {
#else
Check vector_impl(Op op, const FullOwnerSpec& src0,
                  const FullOwnerSpec* src1,
                  uint8_t stage, uint8_t layer, Probe& probe) {
#endif
#pragma HLS inline off
  VectorTask task;
  task.ctx.op = op;
  task.ctx.stage = stage;
  task.ctx.layer = layer;
  task.src0 = src0.ref;
  task.src0_region = src0.region;
#ifdef EXPLICIT_PRESENCE
  task.src1 = src1_present ? src1.ref : none();
  task.src1_region = src1_present ? src1.region : 0;
#else
  task.src1 = src1 ? src1->ref : none();
  task.src1_region = src1 ? src1->region : 0;
#endif
  task.dst = {Buffer::HIDDEN, 1, src0.ref.epoch + 1};
  task.length = 1024;
  Check c = probe_bind(src0);
#ifdef EXPLICIT_PRESENCE
  if (c && src1_present) {
    c = probe_bind(src1);
    probe.second_bound = src1.ref;
    probe.second_bound_region = src1.region;
    ++probe.second_bind_count;
  }
#else
  if (c && src1) {
    c = probe_bind(*src1);
    probe.second_bound = src1->ref;
    probe.second_bound_region = src1->region;
    ++probe.second_bind_count;
  }
#endif
  probe.issued = task;
  if (c) c = probe_issue_vector(task);
  return c;
}

#ifdef EXPLICIT_PRESENCE
Check vector(Op op, const FullOwnerSpec& src0,
             const FullOwnerSpec& src1, uint8_t stage,
             uint8_t layer, Probe& probe) {
  return vector_impl(op, src0, true, src1, stage, layer, probe);
}
Check vector(Op op, const FullOwnerSpec& src0,
             uint8_t stage, uint8_t layer, Probe& probe) {
  const FullOwnerSpec absent;
  return vector_impl(op, src0, false, absent, stage, layer, probe);
}
#else
Check vector(Op op, const FullOwnerSpec& src0,
             const FullOwnerSpec* src1, uint8_t stage,
             uint8_t layer, Probe& probe) {
  return vector_impl(op, src0, src1, stage, layer, probe);
}
#endif

void select_attention_source(const FullOwnerSpec& hidden,
                             const FullOwnerSpec& normalized,
                             uint8_t layer, Probe& probe) {
#ifdef EXPLICIT_PRESENCE
  FullOwnerSpec att_source = hidden;
  if (layer != 0) att_source = normalized;
  probe.attention_source = att_source;
#else
  const FullOwnerSpec* att_source = &hidden;
  if (layer != 0) att_source = &normalized;
  probe.attention_source = *att_source;
#endif
}
} // namespace

extern "C" void optional_pointer_pilot(uint8_t mode, uint8_t layer,
                                         uint8_t src_bank, uint32_t epoch,
                                         uint8_t second_id,
                                         uint8_t second_bank,
                                         uint32_t second_epoch,
                                         uint8_t second_region,
                                         uint8_t load_ok,
                                         uint32_t out[36]) {
#pragma HLS INTERFACE m_axi port=out offset=slave bundle=gmem depth=36
#pragma HLS INTERFACE s_axilite port=mode bundle=control
#pragma HLS INTERFACE s_axilite port=layer bundle=control
#pragma HLS INTERFACE s_axilite port=src_bank bundle=control
#pragma HLS INTERFACE s_axilite port=epoch bundle=control
#pragma HLS INTERFACE s_axilite port=second_id bundle=control
#pragma HLS INTERFACE s_axilite port=second_bank bundle=control
#pragma HLS INTERFACE s_axilite port=second_epoch bundle=control
#pragma HLS INTERFACE s_axilite port=second_region bundle=control
#pragma HLS INTERFACE s_axilite port=load_ok bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
  Probe probe;
  FullOwnerSpec hidden = spec(Buffer::HIDDEN, src_bank, epoch, 0,
                              2, layer, 128, Content::F32);
  FullOwnerSpec other = spec(Buffer(second_id), second_bank,
                             second_epoch, second_region, 3, layer,
                             3, Content::F32);
  FullOwnerSpec output;
  FullOwnerSpec qkv_pair[2];
  Check c = ok();
  if (mode == 0 || mode == 7) {
#ifdef EXPLICIT_PRESENCE
    c = linear(Op::LIN_QKV, hidden, mode == 7 ? 4 : 2,
               layer, epoch + 1,
               load_ok, output, qkv_pair, probe);
#else
    c = linear(Op::LIN_QKV, hidden, mode == 7 ? 4 : 2,
               layer, epoch + 1,
               load_ok, output, probe, qkv_pair);
#endif
    probe.pair[0] = qkv_pair[0];
    probe.pair[1] = qkv_pair[1];
  } else if (mode == 1) {
#ifdef EXPLICIT_PRESENCE
    c = linear(Op::LIN_QKV, hidden, 2, layer, epoch + 1,
               load_ok, output, probe);
#else
    c = linear(Op::LIN_QKV, hidden, 2, layer, epoch + 1,
               load_ok, output, probe);
#endif
  } else if (mode == 2) {
    c = linear(Op::LIN_WO, hidden, 2, layer, epoch + 1,
               load_ok, output, probe);
  } else if (mode == 3 || mode == 8) {
    const Op op = mode == 8 ? Op::ADD_TYPE : Op::ADD_RESIDUAL;
#ifdef EXPLICIT_PRESENCE
    c = vector(op, hidden, other, 2, layer, probe);
#else
    c = vector(op, hidden, &other, 2, layer, probe);
#endif
  } else if (mode == 4) {
#ifdef EXPLICIT_PRESENCE
    c = vector(Op::ADD_RESIDUAL, hidden, 2, layer, probe);
#else
    c = vector(Op::ADD_RESIDUAL, hidden, nullptr, 2, layer, probe);
#endif
  } else if (mode == 5) {
#ifdef EXPLICIT_PRESENCE
    c = vector(Op::GEGLU, hidden, 2, layer, probe);
#else
    c = vector(Op::GEGLU, hidden, nullptr, 2, layer, probe);
#endif
  } else if (mode == 6) {
    if (layer != 0 && !load_ok)
      c = {Status::E_BUFFER, detail(4, 0, 18)}; // probe-only norm failure
    else
      select_attention_source(hidden, other, layer, probe);
  } else {
    c = {Status::E_SHAPE, detail(7, 7, 7)};
  }
  out[0] = uint32_t(c.code);
  out[1] = c.detail;
  out[2] = uint32_t(probe.pair[0].ref.id);
  out[3] = probe.pair[0].ref.bank;
  out[4] = probe.pair[0].ref.epoch;
  out[5] = uint32_t(probe.pair[1].ref.id);
  out[6] = probe.pair[1].ref.bank;
  out[7] = probe.pair[1].ref.epoch;
  out[8] = uint32_t(probe.issued.src1.id);
  out[9] = probe.issued.src1.bank;
  out[10] = probe.issued.src1.epoch;
  out[11] = probe.issued.src1_region;
  out[12] = probe.second_bind_count;
  out[13] = probe.second_bound.epoch;
  out[14] = uint32_t(probe.attention_source.ref.id);
  out[15] = probe.attention_source.ref.bank;
  out[16] = probe.attention_source.ref.epoch;
  out[17] = probe.attention_source.region;
  out[18] = uint32_t(probe.output.content);
  out[19] = probe.output.ref.epoch;
  out[20] = uint32_t(probe.second_bound.id);
  out[21] = probe.second_bound.bank;
  out[22] = probe.second_bound_region;
  out[23] = uint32_t(probe.pair[0].content);
  out[24] = probe.pair[0].rows;
  out[25] = probe.pair[0].width;
  out[26] = uint32_t(probe.pair[1].content);
  out[27] = probe.pair[1].rows;
  out[28] = probe.pair[1].width;
  out[29] = probe.pair[0].stage;
  out[30] = probe.pair[1].stage;
  out[31] = probe.pair[0].layer;
  out[32] = probe.pair[1].layer;
  out[33] = probe.pair[0].region;
  out[34] = probe.pair[1].region;
  out[35] = uint32_t(probe.issued.ctx.op);
}
