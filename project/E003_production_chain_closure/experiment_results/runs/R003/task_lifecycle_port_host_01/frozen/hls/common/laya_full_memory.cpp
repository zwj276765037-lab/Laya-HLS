#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

namespace laya::full {
namespace {
Check bad_bo(Bo bo, uint16_t reason = 9) {
  return {Status::E_BUFFER, detail(4, uint8_t(bo), reason)};
}
Check bad_model() {
  return {Status::E_MODEL, detail(4, 0, 4)};
}
bool same_bytes(const uint8_t* a, const uint8_t* b, unsigned count) {
  for (unsigned i = 0; i < count; ++i)
    if (a[i] != b[i]) return false;
  return true;
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
bool mutable_present(const FullMemory& m, Bo bo) {
#ifdef __SYNTHESIS__
  (void)m;
  switch (bo) {
    case Bo::IO: case Bo::STATE0: case Bo::STATE1: case Bo::QKV0:
    case Bo::QKV1: case Bo::FF0: case Bo::FF1: case Bo::ATT_OUT:
      return true;
    default: return false;
  }
#else
  switch (bo) {
    case Bo::IO: return m.io != nullptr;
    case Bo::STATE0: return m.state0 != nullptr;
    case Bo::STATE1: return m.state1 != nullptr;
    case Bo::QKV0: return m.qkv0 != nullptr;
    case Bo::QKV1: return m.qkv1 != nullptr;
    case Bo::FF0: return m.ff0 != nullptr;
    case Bo::FF1: return m.ff1 != nullptr;
    case Bo::ATT_OUT: return m.att_out != nullptr;
    default: return false;
  }
#endif
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
uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
} // namespace

uint64_t full_bo_capacity(const FullMemory& memory, Bo bo) {
  return capacity(memory, bo);
}

bool full_equal_weight(const FullWeightDescriptor& a,
                       const FullWeightDescriptor& b) {
  if (a.key.family != b.key.family || a.key.layer != b.key.layer ||
      a.K != b.K || a.N != b.N || a.dtype != b.dtype ||
      a.bias_kind != b.bias_kind || a.scale_base != b.scale_base ||
      a.scale_span != b.scale_span || a.aux_base != b.aux_base ||
      a.aux_span != b.aux_span || a.bias_base != b.bias_base ||
      a.bias_span != b.bias_span ||
      !same_bytes(a.source_sha256, b.source_sha256, 32) ||
      !same_bytes(a.bias_sha256, b.bias_sha256, 32)) return false;
  for (unsigned i = 0; i < 2; ++i)
    if (a.q_base[i] != b.q_base[i] || a.q_span[i] != b.q_span[i]) return false;
  for (unsigned i = 0; i < 48; ++i)
    if (a.name[i] != b.name[i]) return false;
  return true;
}

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

Check full_write(FullMemory& m, Bo bo, uint64_t offset,
                 const uint8_t* src, uint32_t bytes) {
  if ((src == nullptr && bytes) || !mutable_present(m, bo))
    return bad_bo(bo, 4);
  Check c = full_span(m, bo, offset, bytes);
  if (!c) return c;
  for (uint32_t i = 0; i < bytes; ++i) {
    const uint32_t at = uint32_t(offset) + i;
    switch (bo) {
      case Bo::IO: m.io[at] = src[i]; break;
      case Bo::STATE0: m.state0[at] = src[i]; break;
      case Bo::STATE1: m.state1[at] = src[i]; break;
      case Bo::QKV0: m.qkv0[at] = src[i]; break;
      case Bo::QKV1: m.qkv1[at] = src[i]; break;
      case Bo::FF0: m.ff0[at] = src[i]; break;
      case Bo::FF1: m.ff1[at] = src[i]; break;
      case Bo::ATT_OUT: m.att_out[at] = src[i]; break;
      default: return bad_bo(bo, 4);
    }
  }
  return ok();
}

Check full_next_segment(Bo src_bo, uint64_t src_offset,
                        Bo dst_bo, uint64_t dst_offset, uint32_t remaining,
                        FullSegment& segment) {
  if (!remaining || src_offset > UINT32_MAX || dst_offset > UINT32_MAX)
    return bad_bo(src_bo);
  const uint32_t src_room = 4096u - uint32_t(src_offset & 4095u);
  const uint32_t dst_room = 4096u - uint32_t(dst_offset & 4095u);
  uint32_t length = remaining < 4096u ? remaining : 4096u;
  if (length > src_room) length = src_room;
  if (length > dst_room) length = dst_room;
  segment = {src_bo, dst_bo, uint32_t(src_offset), uint32_t(dst_offset), length};
  return ok();
}

Check full_copy(FullMemory& m, Bo src_bo, uint64_t src_offset,
                Bo dst_bo, uint64_t dst_offset, uint32_t bytes,
                uint32_t& segment_count) {
  segment_count = 0;
  if (!mutable_present(m, dst_bo)) return bad_bo(dst_bo, 4);
  Check c = full_span(m, src_bo, src_offset, bytes);
  if (!c) return c;
  c = full_span(m, dst_bo, dst_offset, bytes);
  if (!c) return c;
  if (src_bo == dst_bo && bytes &&
      src_offset < dst_offset + bytes && dst_offset < src_offset + bytes)
    return bad_bo(dst_bo, 4);
  uint32_t remaining = bytes;
  while (remaining) {
    FullSegment s;
    c = full_next_segment(src_bo, src_offset, dst_bo, dst_offset, remaining, s);
    if (!c) return c;
    uint8_t local[4096];
    c = full_read(m, src_bo, s.src_offset, local, s.bytes);
    if (c) c = full_write(m, dst_bo, s.dst_offset, local, s.bytes);
    if (!c) return c;
    src_offset += s.bytes;
    dst_offset += s.bytes;
    remaining -= s.bytes;
    ++segment_count;
  }
  return ok();
}

Check full_check_model_header(const FullMemory& m, const NumericIdentity& id) {
  if (!numeric_identity_valid(id)) return bad_model();
  Check c = full_span(m, Bo::AUX, 0, 128);
  if (!c) return c;
  const uint8_t* h = m.aux;
  if (h[0] != 'L' || h[1] != 'Y' || h[2] != 'M' || h[3] != 'P' ||
      le16(h + 4) != 1 || le16(h + 6) != 0 ||
      le32(h + 8) != 128 || le32(h + 12) != 13 || le32(h + 16) != 1)
    return bad_model();
  for (unsigned i = 20; i < 32; ++i)
    if (h[i] != 0) return bad_model();
  if (!same_bytes(h + 32, kFullModelTag, 16) ||
      !same_bytes(h + 48, kFullNumericTag, 16) ||
      !same_bytes(h + 64, kFullLayoutTag, 16) ||
      !same_bytes(h + 80, kFullBuildTag, 16) ||
      !same_bytes(h + 96, kFullSourceSha256, 32) ||
      !same_bytes(id.model_tag, kFullModelTag, 16) ||
      !same_bytes(id.numeric_tag, kFullNumericTag, 16) ||
      !same_bytes(id.layout_tag, kFullLayoutTag, 16) ||
      !same_bytes(id.build_tag, kFullBuildTag, 16))
    return bad_model();
  return ok();
}

Check full_lookup_weight(WeightKey key, FullWeightDescriptor& result) {
  for (unsigned i = 0; i < 124; ++i) {
    const FullWeightDescriptor& d = kFullWeights[i];
    if (d.key.family == key.family && d.key.layer == key.layer) {
      result = d;
      return ok();
    }
  }
  return bad_model();
}

Check full_tensor_descriptor(uint16_t index, FullTensorDescriptor& result) {
  if (index >= 153) return bad_model();
  result = kFullTensors[index];
  return ok();
}

Check full_lookup_tensor_indexed(const char* name, FullTensorDescriptor& result,
                                 uint16_t& index) {
  if (!name) return bad_model();
  for (unsigned i = 0; i < 153; ++i) {
    bool same = true;
    for (unsigned j = 0; j < 48; ++j) {
      if (kFullTensors[i].name[j] != name[j]) { same = false; break; }
      if (!name[j]) break;
    }
    if (same) {
      result = kFullTensors[i];
      index = uint16_t(i);
      return ok();
    }
  }
  return bad_model();
}

Check full_lookup_tensor(const char* name, FullTensorDescriptor& result,
                         uint16_t* index) {
  uint16_t found_index = 0;
  Check c = full_lookup_tensor_indexed(name, result, found_index);
  if (c && index) *index = found_index;
  return c;
}

Check full_f32_address(const FullRuntime& rt, const FullMemory& memory, BufferRef ref, uint8_t region,
                       uint8_t batch, uint16_t row, uint16_t col,
                       Address& result) {
  const NumericIdentity& id = rt.inputs.identity;
  Check c;
  uint64_t index = 0;
  if (ref.id == Buffer::MARKER) {
    if (batch >= id.B || row >= 16 || col >= 1024)
      return bad_bo(Bo::STATE0, 5);
    index = (uint64_t(batch) * 16 + row) * 1024 + col;
    c = byte_address(ref, region, index * 4, 4, result);
  } else if (ref.id == Buffer::TYPE_ROWS) {
    // The table is shared by batches; row denotes the type ID.
    if (batch != 0 || row >= 3 || col >= 1024)
      return bad_bo(Bo::STATE0, 5);
    index = uint64_t(row) * 1024 + col;
    c = byte_address(ref, region, index * 4, 4, result);
  } else if (ref.id == Buffer::HEAD_WORK) {
    if (batch >= id.B || region > 7)
      return bad_bo(Bo::STATE1, 5);
    switch (Region(region)) {
      case Region::SCORER_ACT:
        if (row >= 16 || col >= 1024) return bad_bo(Bo::STATE1, 5);
        index = (uint64_t(batch) * 16 + row) * 1024 + col;
        break;
      case Region::ACT_INPUT:
        if (row != 0 || col >= 1028) return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 1028 + col;
        break;
      case Region::ACT_HIDDEN:
        if (row != 0 || col >= 256) return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 256 + col;
        break;
      case Region::CAND_RAW:
        // FC2 writes a scalar per marker row.  Batch-vector readers use
        // row=0,col=c for the same sixteen physical values.
        if (!((row < 16 && col == 0) || (row == 0 && col < 16)))
          return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 16 + (row ? row : col);
        break;
      case Region::CAND_MASKED:
      case Region::CAND_PROB:
        if (row != 0 || col >= 16) return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 16 + col;
        break;
      case Region::ACT_LOGITS:
        if (row != 0 || col >= 2) return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 2 + col;
        break;
      case Region::STATS:
        if (row != 0 || col >= 4) return bad_bo(Bo::STATE1, 5);
        index = uint64_t(batch) * 4 + col;
        break;
    }
    c = byte_address(ref, region, index * 4, 4, result);
  } else {
    c = f32_address(ref, region, batch, row, col, id.B, id.S, result);
  }
  if (!c) return c;
  return full_span(memory, result.bo, result.offset, 4);
}

Check full_q8_address(const FullRuntime& rt, const FullMemory& memory,
                      const FullWeightDescriptor& descriptor,
                      uint16_t n, uint16_t k,
                      Address& q, Address& scale) {
  (void)rt;
  FullWeightDescriptor expected;
  Check c = full_lookup_weight(descriptor.key, expected);
  if (!c || !full_equal_weight(descriptor, expected) || descriptor.dtype != 8)
    return bad_model();
  Q8Descriptor d;
  d.q_base = {descriptor.q_base[0], descriptor.q_base[1]};
  d.q_span = {descriptor.q_span[0], descriptor.q_span[1]};
  d.scale_base = descriptor.scale_base;
  d.scale_span = descriptor.scale_span;
  d.K = descriptor.K;
  d.N = descriptor.N;
  c = q8_weight_addresses(d, n, k, q, scale);
  if (!c) return c;
  c = full_span(memory, q.bo, q.offset, 1);
  if (!c) return c;
  return full_span(memory, scale.bo, scale.offset, 2);
}

} // namespace laya::full
