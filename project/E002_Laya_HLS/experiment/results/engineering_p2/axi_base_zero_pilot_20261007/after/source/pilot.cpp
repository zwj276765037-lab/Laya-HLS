#include "laya_full_runtime.h"

namespace laya::full {
namespace {
Check bad_bo(Bo bo, uint16_t reason = 9) {
  return {Status::E_BUFFER, detail(4, uint8_t(bo), reason)};
}

bool present(const FullMemory& m, Bo bo) {
#ifdef __SYNTHESIS__
  // An AXI base address of zero is legal. The host supplies every kernel BO;
  // validity here is the named port, not the numerical AXI base address.
  (void)m;
  switch (bo) {
    case Bo::EMBEDDING: case Bo::IO: case Bo::W_Q0: case Bo::W_Q1:
    case Bo::W_SCALE: case Bo::AUX: case Bo::STATE0: case Bo::STATE1:
    case Bo::QKV0: case Bo::QKV1: case Bo::FF0: case Bo::FF1:
    case Bo::ATT_OUT: return true;
  }
#else
  switch (bo) {
    case Bo::EMBEDDING: return m.embedding != nullptr;
    case Bo::IO: return m.io != nullptr;
    case Bo::W_Q0: return m.w_q0 != nullptr;
    case Bo::W_Q1: return m.w_q1 != nullptr;
    case Bo::W_SCALE: return m.w_scale != nullptr;
    case Bo::AUX: return m.aux != nullptr;
    case Bo::STATE0: return m.state0 != nullptr;
    case Bo::STATE1: return m.state1 != nullptr;
    case Bo::QKV0: return m.qkv0 != nullptr;
    case Bo::QKV1: return m.qkv1 != nullptr;
    case Bo::FF0: return m.ff0 != nullptr;
    case Bo::FF1: return m.ff1 != nullptr;
    case Bo::ATT_OUT: return m.att_out != nullptr;
  }
#endif
  return false;
}

uint64_t capacity(const FullMemory& m, Bo bo) {
  switch (bo) {
    case Bo::EMBEDDING: return m.embedding_bytes;
    case Bo::IO: return m.io_bytes;
    case Bo::W_Q0: return m.w_q0_bytes;
    case Bo::W_Q1: return m.w_q1_bytes;
    case Bo::W_SCALE: return m.w_scale_bytes;
    case Bo::AUX: return m.aux_bytes;
    case Bo::STATE0: return m.state0_bytes;
    case Bo::STATE1: return m.state1_bytes;
    case Bo::QKV0: return m.qkv0_bytes;
    case Bo::QKV1: return m.qkv1_bytes;
    case Bo::FF0: return m.ff0_bytes;
    case Bo::FF1: return m.ff1_bytes;
    case Bo::ATT_OUT: return m.att_out_bytes;
  }
  return 0;
}

} // namespace

Check full_span(const FullMemory& m, Bo bo, uint64_t offset, uint64_t bytes) {
  const uint64_t limit = capacity(m, bo);
  if (!present(m, bo) || offset > UINT32_MAX || bytes > UINT32_MAX ||
      offset > limit || bytes > limit - offset ||
      offset + bytes > uint64_t(UINT32_MAX) + 1)
    return bad_bo(bo);
  return ok();
}

Check full_read(const FullMemory& m, Bo bo, uint64_t offset, uint8_t* dst,
                uint32_t bytes) {
  if (dst == nullptr && bytes) return bad_bo(bo);
  Check c = full_span(m, bo, offset, bytes);
  if (!c) return c;
  for (uint32_t i = 0; i < bytes; ++i) {
    const uint32_t at = uint32_t(offset) + i;
    switch (bo) {
      case Bo::EMBEDDING: dst[i] = m.embedding[at]; break;
      case Bo::IO: dst[i] = m.io[at]; break;
      case Bo::W_Q0: dst[i] = m.w_q0[at]; break;
      case Bo::W_Q1: dst[i] = m.w_q1[at]; break;
      case Bo::W_SCALE: dst[i] = m.w_scale[at]; break;
      case Bo::AUX: dst[i] = m.aux[at]; break;
      case Bo::STATE0: dst[i] = m.state0[at]; break;
      case Bo::STATE1: dst[i] = m.state1[at]; break;
      case Bo::QKV0: dst[i] = m.qkv0[at]; break;
      case Bo::QKV1: dst[i] = m.qkv1[at]; break;
      case Bo::FF0: dst[i] = m.ff0[at]; break;
      case Bo::FF1: dst[i] = m.ff1[at]; break;
      case Bo::ATT_OUT: dst[i] = m.att_out[at]; break;
    }
  }
  return ok();
}

} // namespace laya::full

extern "C" void axi_base_zero_pilot(
    const uint8_t* embedding,
    uint8_t* io,
    const uint8_t* w_q0,
    const uint8_t* w_q1,
    const uint8_t* w_scale,
    const uint8_t* aux,
    uint8_t* state0,
    uint8_t* state1,
    uint8_t* qkv0,
    uint8_t* qkv1,
    uint8_t* ff0,
    uint8_t* ff1,
    uint8_t* att_out) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=w_q0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=w_q1 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=w_scale max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff0 offset=slave bundle=ff0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=ff1 offset=slave bundle=ff1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  laya::full::FullMemory memory{};
  memory.embedding = embedding;
  memory.embedding_bytes = 4096;
  memory.io = io;
  memory.io_bytes = 4096;
  memory.w_q0 = w_q0;
  memory.w_q0_bytes = 4096;
  memory.w_q1 = w_q1;
  memory.w_q1_bytes = 4096;
  memory.w_scale = w_scale;
  memory.w_scale_bytes = 4096;
  memory.aux = aux;
  memory.aux_bytes = 4096;
  memory.state0 = state0;
  memory.state0_bytes = 4096;
  memory.state1 = state1;
  memory.state1_bytes = 4096;
  memory.qkv0 = qkv0;
  memory.qkv0_bytes = 4096;
  memory.qkv1 = qkv1;
  memory.qkv1_bytes = 4096;
  memory.ff0 = ff0;
  memory.ff0_bytes = 4096;
  memory.ff1 = ff1;
  memory.ff1_bytes = 4096;
  memory.att_out = att_out;
  memory.att_out_bytes = 4096;
  uint8_t observed[13] = {};
  uint16_t status[13] = {};
  status[0] = uint16_t(laya::full::full_read(memory, laya::Bo::EMBEDDING, 0, &observed[0], 1).code);
  status[1] = uint16_t(laya::full::full_read(memory, laya::Bo::IO, 0, &observed[1], 1).code);
  status[2] = uint16_t(laya::full::full_read(memory, laya::Bo::W_Q0, 0, &observed[2], 1).code);
  status[3] = uint16_t(laya::full::full_read(memory, laya::Bo::W_Q1, 0, &observed[3], 1).code);
  status[4] = uint16_t(laya::full::full_read(memory, laya::Bo::W_SCALE, 0, &observed[4], 1).code);
  status[5] = uint16_t(laya::full::full_read(memory, laya::Bo::AUX, 0, &observed[5], 1).code);
  status[6] = uint16_t(laya::full::full_read(memory, laya::Bo::STATE0, 0, &observed[6], 1).code);
  status[7] = uint16_t(laya::full::full_read(memory, laya::Bo::STATE1, 0, &observed[7], 1).code);
  status[8] = uint16_t(laya::full::full_read(memory, laya::Bo::QKV0, 0, &observed[8], 1).code);
  status[9] = uint16_t(laya::full::full_read(memory, laya::Bo::QKV1, 0, &observed[9], 1).code);
  status[10] = uint16_t(laya::full::full_read(memory, laya::Bo::FF0, 0, &observed[10], 1).code);
  status[11] = uint16_t(laya::full::full_read(memory, laya::Bo::FF1, 0, &observed[11], 1).code);
  status[12] = uint16_t(laya::full::full_read(memory, laya::Bo::ATT_OUT, 0, &observed[12], 1).code);
  for (unsigned i = 0; i < 13; ++i) {
    const unsigned at = 2048 + 4 * i;
    io[at] = uint8_t(status[i]);
    io[at + 1] = uint8_t(status[i] >> 8);
    io[at + 2] = observed[i];
    io[at + 3] = 0xa5;
  }
}
