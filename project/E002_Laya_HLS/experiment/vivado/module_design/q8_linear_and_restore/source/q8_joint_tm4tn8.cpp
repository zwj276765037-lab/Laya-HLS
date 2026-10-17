#include "q8_joint_tm4tn8.h"
#include "q8_joint_abi.h"
#include "laya_model_layout_generated.h"

#include <cmath>
#include <cstdint>
#include <cstring>

#pragma STDC FP_CONTRACT OFF

namespace {
using namespace q8_joint;
using laya::CacheState;
using laya::Status;
using laya::full::FullWeightDescriptor;

constexpr unsigned kWDepth = 20992;
constexpr unsigned kA8Depth = 512;
constexpr unsigned kFpDepth = 8192;
constexpr unsigned kPsDepth = 656;

struct State {
  bool bound = false, w_valid = false;
  uint64_t request = 0, generation = 0;
  uint32_t B = 0, S = 0;
  uint8_t tags[4][16] = {};
  uint32_t last_task = 0, w_max = 0, a8_max = 0, ps_max = 0, dst_max = 0;
  uint32_t w_epoch = 0, ps_epoch = 0, dst_epoch = 0;
  uint32_t w_family = 0, w_layer = 0, w_loads = 0, w_uses = 0, w_reuses = 0;
  uint32_t a_state = uint32_t(CacheState::INVALID);
  uint32_t ps_state = uint32_t(CacheState::INVALID);
  uint32_t dst_state = uint32_t(CacheState::INVALID);
};

struct Counts {
  uint64_t useful[P_COUNT] = {}, total[P_COUNT] = {};
  uint32_t quant_groups = 0, quant_inputs = 0;
  uint32_t issued = 0, retired = 0, writes = 0;
  uint64_t macs = 0;
  uint32_t trace_words = 0, trace_bias = 0, trace_final = 0;
  uint32_t trace_groups = 0;
  bool trace_bias_valid = false;
};

inline uint32_t bits(float f) {
  uint32_t u;
  std::memcpy(&u, &f, sizeof(u));
  return u;
}
inline float f32(uint32_t u) {
  float f;
  std::memcpy(&f, &u, sizeof(f));
  return f;
}
inline bool finite(float f) { return (bits(f) & 0x7f800000u) != 0x7f800000u; }
inline uint32_t make_detail(uint8_t domain, uint8_t object, uint16_t reason) {
  return (uint32_t(domain) << 24) | (uint32_t(object) << 16) | reason;
}
inline void bytes(Counts& c, Port p, uint64_t count) {
  c.useful[p] += count;
  c.total[p] += count;
}
inline uint8_t tag_byte(uint32_t word, unsigned byte) {
  return uint8_t(word >> (8 * byte));
}

// Matches the production R0 converter, including subnormal preservation.
float half_to_f32(uint16_t h) {
  const uint32_t sign = uint32_t(h & 0x8000u) << 16;
  const uint32_t exp = (h >> 10) & 31u;
  uint32_t mant = h & 1023u, out;
  if (exp == 0) {
    if (!mant) out = sign;
    else {
      int e = -14;
      for (unsigned step = 0; step < 10; ++step) {
        if (mant & 0x400u) break;
        mant <<= 1;
        --e;
      }
      out = sign | (uint32_t(e + 127) << 23) | ((mant & 1023u) << 13);
    }
  } else if (exp == 31) out = sign | 0x7f800000u | (mant << 13);
  else out = sign | ((exp + 112u) << 23) | (mant << 13);
  return f32(out);
}

uint16_t f32_to_half_rne(float f) {
  const uint32_t value = bits(f);
  const uint16_t sign = uint16_t((value >> 16) & 0x8000u);
  const uint32_t exponent = (value >> 23) & 255u;
  uint32_t mantissa = value & 0x7fffffu;
  if (exponent == 255u) return uint16_t(sign | (mantissa ? 0x7e00u : 0x7c00u));
  const int half_exp = int(exponent) - 127 + 15;
  if (half_exp >= 31) return uint16_t(sign | 0x7c00u);
  if (half_exp <= -11) return sign;
  if (half_exp <= 0) {
    mantissa |= 0x800000u;
    const unsigned shift = unsigned(14 - half_exp);
    uint32_t result = mantissa >> shift;
    const uint32_t remainder = mantissa & ((uint32_t(1) << shift) - 1u);
    const uint32_t halfway = uint32_t(1) << (shift - 1);
    if (remainder > halfway || (remainder == halfway && (result & 1u))) ++result;
    return uint16_t(sign | result);
  }
  uint32_t result = (uint32_t(half_exp) << 10) | (mantissa >> 13);
  const uint32_t remainder = mantissa & 0x1fffu;
  if (remainder > 0x1000u || (remainder == 0x1000u && (result & 1u))) ++result;
  return uint16_t(sign | result);
}

bool valid_ref(const Ref& r) {
  if (r.id == 0) return r.bank == 0 && r.epoch == 0 && r.region == 0;
  if (!r.epoch || r.epoch > kMaximumEpoch || r.id > 255 ||
      r.bank > 255 || r.region > 255) return false;
  const bool legal = (r.id >= 1 && r.id <= 11) ||
                     (r.id >= 0x20 && r.id <= 0x2b);
  if (!legal) return false;
  const bool dual = r.id == 1 || r.id == 5 ||
                    (r.id >= 0x20 && r.id <= 0x2b);
  if (r.bank > (dual ? 1u : 0u)) return false;
  return r.id == 10 ? r.region <= 7 : r.region == 0;
}

bool tag_matches(const Descriptor& d) {
  const uint8_t* expected[4] = {
      laya::full::kFullModelTag, laya::full::kFullNumericTag,
      laya::full::kFullLayoutTag, laya::full::kFullBuildTag};
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 16; ++j)
      if (tag_byte(d.tags[t][j / 4], j % 4) != expected[t][j]) return false;
  return true;
}

bool same_session(const State& st, const Descriptor& d) {
  if (!st.bound || st.request != d.request_id ||
      st.generation != d.generation || st.B != d.B || st.S != d.S)
    return false;
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 16; ++j)
      if (st.tags[t][j] != tag_byte(d.tags[t][j / 4], j % 4)) return false;
  return true;
}

void bind_session(State& st, const Descriptor& d) {
  st.bound = true;
  st.request = d.request_id;
  st.generation = d.generation;
  st.B = d.B;
  st.S = d.S;
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 16; ++j)
      st.tags[t][j] = tag_byte(d.tags[t][j / 4], j % 4);
}

bool lookup_weight(const Descriptor& d, FullWeightDescriptor& w) {
  for (unsigned i = 0; i < 124; ++i)
    if (laya::full::kFullWeights[i].key.family == d.family &&
        laya::full::kFullWeights[i].key.layer == d.weight_layer) {
      w = laya::full::kFullWeights[i];
      return true;
    }
  return false;
}

uint32_t linear_op(unsigned family) {
  switch (family) {
    case 1: case 5: return 0x30;
    case 2: case 6: return 0x31;
    case 3: return 0x32;
    case 4: return 0x33;
    case 7: return 0x34;
    case 8: return 0x35;
    case 9: return 0x36;
    case 12: return 0x37;
    default: return 0;
  }
}
unsigned stage_for(unsigned family) {
  return family <= 4 ? 2 : family <= 8 ? 4 : family == 9 ? 5 : 6;
}

bool source_shape(const Descriptor& d) {
  if (d.stage == 6)
    return d.K == 256 && d.src.id == 10 && d.src.region == 2;
  if (d.stage == 5)
    return d.K == 1024 && d.src.id == 10 && d.src.region == 0;
  if (d.stage == 2)
    return d.K == 2624 ? d.src.id == 7 :
           d.K == 1024 && (d.src.id == 1 || d.src.id == 2 || d.src.id == 8);
  if (d.stage == 4)
    return d.K == 4096 ? d.src.id == 9 :
           d.K == 1024 && (d.src.id == 1 || d.src.id == 2 || d.src.id == 8);
  return false;
}

bool destination_shape(const Descriptor& d) {
  switch (d.op) {
    case 0x30: return d.dst.id == 5;
    case 0x31: case 0x33: case 0x35: return d.dst.id == 3;
    case 0x32: return d.dst.id == 6;
    case 0x34: return d.dst.id == 9;
    case 0x36: return d.dst.id == 10 && d.dst.region == 0;
    case 0x37: return d.dst.id == 10 && d.dst.region == 4;
    default: return false;
  }
}

bool valid_span(uint64_t base, uint64_t span, uint64_t need, unsigned align) {
  return base % align == 0 && span >= need && base <= UINT64_MAX - span;
}

int32_t dot32(ap_uint<256> a, ap_uint<256> w) {
#pragma HLS INLINE
  int32_t level[32];
#pragma HLS ARRAY_PARTITION variable=level complete
  for (unsigned k = 0; k < 32; ++k) {
#pragma HLS UNROLL
    const int8_t av = int8_t(uint8_t(a.range(8 * k + 7, 8 * k)));
    const int8_t wv = int8_t(uint8_t(w.range(8 * k + 7, 8 * k)));
    level[k] = int32_t(av) * int32_t(wv);
  }
  for (unsigned stride = 1; stride < 32; stride *= 2)
    for (unsigned k = 0; k < 32; k += 2 * stride) {
#pragma HLS UNROLL
      level[k] += level[k + stride];
    }
  return level[0];
}

void report(uint32_t* observed, const Descriptor& d, const State& st,
            Counts& c, uint32_t status, uint32_t error_detail,
            uint64_t bad_element, uint32_t done_task, uint32_t done_elements,
            uint32_t done_unit, uint32_t quant_done, uint32_t quant_status,
            uint32_t linear_started, uint32_t load_started,
            uint32_t error_phase) {
  bytes(c, P_OBSERVED, uint64_t(kDescriptorWords * 2 + c.trace_words) * 4);
  uint32_t h[O_HEADER_WORDS] = {};
  h[O_MAGIC] = kObservedMagic; h[O_VERSION] = kObservedVersion;
  h[O_COMMAND] = d.command; h[O_STATUS] = status; h[O_DETAIL] = error_detail;
  h[O_BAD_ELEMENT_LO] = lo32(bad_element);
  h[O_BAD_ELEMENT_HI] = hi32(bad_element);
  h[O_COMMAND_TASK] = d.task_id;
  h[O_LAST_TASK] = st.last_task;
  h[O_DONE_TASK] = done_task;
  h[O_DONE_STATUS] = done_task ? status : 0;
  h[O_DONE_DRAINED] = done_task ? 1 : 0;
  h[O_DONE_OUTPUT_ELEMENTS] = done_elements;
  h[O_DONE_OUTPUT_UNIT] = done_unit;
  h[O_REQUEST_LO] = lo32(d.request_id);
  h[O_REQUEST_HI] = hi32(d.request_id);
  h[O_GENERATION_LO] = lo32(d.generation);
  h[O_GENERATION_HI] = hi32(d.generation);
  h[O_B] = d.B; h[O_S] = d.S; h[O_STAGE] = d.stage; h[O_LAYER] = d.layer;
  h[O_BATCH] = d.batch; h[O_ROW0] = d.row0; h[O_ROWS] = d.rows;
  h[O_K] = d.K; h[O_N] = d.N;
  h[O_WEIGHT_FAMILY] = d.family; h[O_WEIGHT_LAYER] = d.weight_layer;
  h[O_W_EPOCH] = st.w_epoch; h[O_A8_EPOCH] = st.a8_max;
  h[O_PS_EPOCH] = st.ps_epoch;
  h[O_SRC_ID] = d.src.id; h[O_SRC_BANK] = d.src.bank;
  h[O_SRC_EPOCH] = d.src.epoch; h[O_SRC_REGION] = d.src.region;
  h[O_DST_ID] = d.dst.id; h[O_DST_BANK] = d.dst.bank;
  h[O_DST_EPOCH] = d.dst.epoch; h[O_DST_REGION] = d.dst.region;
  h[O_W_STATE] = uint32_t(st.w_valid ? CacheState::READY : CacheState::INVALID);
  h[O_A8_STATE] = st.a_state; h[O_PS_STATE] = st.ps_state;
  h[O_DST_STATE] = st.dst_state;
  h[O_W_MAX_CLAIMED] = st.w_max; h[O_A8_MAX_CLAIMED] = st.a8_max;
  h[O_PS_MAX_CLAIMED] = st.ps_max; h[O_DST_MAX_CLAIMED] = st.dst_max;
  h[O_W_LOADS] = st.w_loads; h[O_W_REUSES] = st.w_reuses;
  h[O_QUANT_GROUPS] = c.quant_groups; h[O_QUANT_INPUTS] = c.quant_inputs;
  h[O_ACCEPTED_ISSUES] = c.issued; h[O_INFLIGHT] = 0;
  h[O_RETIRED_GROUPS] = c.retired; h[O_COMMITTED_WRITES] = c.writes;
  h[O_DOT_MACS_LO] = lo32(c.macs); h[O_DOT_MACS_HI] = hi32(c.macs);
  h[O_TRACE_ROW] = d.flags ? d.trace_row_local : 0;
  h[O_TRACE_COLUMN] = d.flags ? d.trace_column : 0;
  h[O_TRACE_BIAS_BITS] = c.trace_bias;
  h[O_TRACE_BIAS_ENABLE] = c.trace_bias_valid ? 1 : 0;
  h[O_TRACE_FINAL_BITS] = c.trace_final;
  h[O_TRACE_GROUP_COUNT] = c.trace_groups;
  for (unsigned p = 0; p < P_COUNT; ++p) {
    const Port port = Port(p);
    h[port_useful_lo(port)] = lo32(c.useful[p]);
    h[port_useful_hi(port)] = hi32(c.useful[p]);
    h[port_total_lo(port)] = lo32(c.total[p]);
    h[port_total_hi(port)] = hi32(c.total[p]);
  }
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 4; ++j)
      h[O_MODEL_TAG_0 + t * 4 + j] = d.tags[t][j];
  h[O_QUANT_DONE_TASK] = quant_done;
  h[O_QUANT_DONE_STATUS] = quant_done ? quant_status : 0;
  h[O_QUANT_DONE_DRAINED] = quant_done ? 1 : 0;
  h[O_LINEAR_STARTED] = linear_started;
  h[O_LOAD_STARTED] = load_started;
  h[O_ERROR_PHASE] = error_phase;
  for (unsigned i = 0; i < O_HEADER_WORDS; ++i) observed[i] = h[i];
}
}  // namespace

extern "C" void q8_joint_tm4tn8(
    const uint32_t* descriptor, const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1, const ap_uint<512>* w_scale,
    const uint32_t* aux, const ap_uint<512>* activation,
    uint32_t* out0, uint32_t* out1, uint32_t* observed) {
#pragma HLS INTERFACE m_axi port=descriptor offset=slave bundle=gmem_descriptor max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=gmem_w_q0 max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=gmem_w_q1 max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=gmem_w_scale max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=gmem_aux max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=activation offset=slave bundle=gmem_activation max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=out0 offset=slave bundle=gmem_out0 max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=out1 offset=slave bundle=gmem_out1 max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=gmem_observed max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control

  static State st;
  static ap_uint<256> wq[8][kWDepth];
  static uint16_t ws[8][kWDepth];
  static uint32_t bias_bits[8][kPsDepth];
  static uint32_t fp[8][kFpDepth];
  static ap_uint<256> aq[4][kA8Depth];
  static uint16_t as[4][kA8Depth];
  static float ps[32][kPsDepth];
#pragma HLS ARRAY_PARTITION variable=wq complete dim=1
#pragma HLS ARRAY_PARTITION variable=ws complete dim=1
#pragma HLS ARRAY_PARTITION variable=bias_bits complete dim=1
#pragma HLS ARRAY_PARTITION variable=fp complete dim=1
#pragma HLS ARRAY_PARTITION variable=aq complete dim=1
#pragma HLS ARRAY_PARTITION variable=as complete dim=1
#pragma HLS ARRAY_PARTITION variable=ps complete dim=1
#pragma HLS bind_storage variable=wq type=ram_2p impl=uram
#pragma HLS bind_storage variable=ws type=ram_2p impl=bram
#pragma HLS bind_storage variable=fp type=ram_2p impl=bram
#pragma HLS bind_storage variable=aq type=ram_2p impl=bram
#pragma HLS bind_storage variable=as type=ram_2p impl=bram
#pragma HLS bind_storage variable=ps type=ram_2p impl=bram
#pragma HLS bind_storage variable=bias_bits type=ram_2p impl=bram

  Counts c;
  uint32_t words[kDescriptorWords];
  for (unsigned i = 0; i < kDescriptorWords; ++i) words[i] = descriptor[i];
  bytes(c, P_DESCRIPTOR, kDescriptorWords * 4);
  Descriptor d;
  d.command = words[D_COMMAND]; d.flags = words[D_FLAGS];
  d.request_id = join_u64(words[D_REQUEST_LO], words[D_REQUEST_HI]);
  d.generation = join_u64(words[D_GENERATION_LO], words[D_GENERATION_HI]);
  d.task_id = words[D_TASK_ID]; d.op = words[D_OP];
  d.stage = words[D_STAGE]; d.layer = words[D_LAYER];
  d.B = words[D_B]; d.S = words[D_S]; d.batch = words[D_BATCH];
  d.row0 = words[D_ROW0]; d.rows = words[D_ROWS];
  d.K = words[D_K]; d.N = words[D_N];
  d.family = words[D_WEIGHT_FAMILY]; d.weight_layer = words[D_WEIGHT_LAYER];
  d.src = {words[D_SRC_ID], words[D_SRC_BANK], words[D_SRC_EPOCH], words[D_SRC_REGION]};
  d.dst = {words[D_DST_ID], words[D_DST_BANK], words[D_DST_EPOCH], words[D_DST_REGION]};
  d.w_epoch = words[D_W_EPOCH]; d.ps_epoch = words[D_PS_EPOCH];
  d.quant_task_id = words[D_QUANT_TASK_ID];
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 4; ++j)
      d.tags[t][j] = words[D_MODEL_TAG_0 + t * 4 + j];
  d.activation_base = join_u64(words[D_ACT_BASE_LO], words[D_ACT_BASE_HI]);
  d.out0_base = join_u64(words[D_OUT0_BASE_LO], words[D_OUT0_BASE_HI]);
  d.out1_base = join_u64(words[D_OUT1_BASE_LO], words[D_OUT1_BASE_HI]);
  d.activation_span = join_u64(words[D_ACT_SPAN_LO], words[D_ACT_SPAN_HI]);
  d.out0_span = join_u64(words[D_OUT0_SPAN_LO], words[D_OUT0_SPAN_HI]);
  d.out1_span = join_u64(words[D_OUT1_SPAN_LO], words[D_OUT1_SPAN_HI]);
  d.trace_row_local = words[D_TRACE_ROW_LOCAL];
  d.trace_column = words[D_TRACE_COLUMN];

  uint32_t status = uint32_t(Status::OK), error_detail = 0;
  uint64_t bad_element = UINT64_MAX;
  uint32_t done_task = 0, done_elements = 0, done_unit = 0;
  uint32_t quant_done = 0, quant_status = 0;
  uint32_t linear_started = 0, load_started = 0, error_phase = 0;
  FullWeightDescriptor wd;
  unsigned G = 0, T = 0;

  // All preflight rejections are before any task or epoch claim.
  bool abi_ok = words[D_MAGIC] == kDescriptorMagic &&
                words[D_VERSION] == kDescriptorVersion &&
                d.command <= RUN_TILE && (d.flags & ~1u) == 0 &&
                words[D_OBSERVED_WORDS] == kObservedWords;
  for (unsigned i = D_ZERO_63; i < kDescriptorWords; ++i)
    if (words[i] != 0) abi_ok = false;
  if (!abi_ok) {
    status = uint32_t(Status::E_ABI); error_detail = make_detail(0, 0, 4);
  } else if (!tag_matches(d) || !d.request_id || !d.generation) {
    status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
  } else if (d.op > 255 || d.stage > 7 || d.layer > 255 ||
             d.B < 1 || d.B > 2 ||
             !(d.S == 64 || d.S == 128 || d.S == 256 || d.S == 512 || d.S == 1024) ||
             d.batch >= d.B || d.row0 > 65535 || d.rows < 1 || d.rows > 16 ||
             d.K > 4096 || d.N > 5248 || d.family > 255 ||
             d.weight_layer > 255 ||
             d.src.id > 255 || d.src.bank > 255 || d.src.region > 255 ||
             d.dst.id > 255 || d.dst.bank > 255 || d.dst.region > 255 ||
             d.trace_row_local > 255 || d.trace_column > 65535 ||
             d.task_id == 0 || d.task_id > kMaximumEpoch ||
             d.w_epoch > kMaximumEpoch || d.ps_epoch > kMaximumEpoch ||
             d.quant_task_id > kMaximumEpoch) {
    status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
  } else if (!lookup_weight(d, wd) || wd.dtype != 8) {
    status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
  } else if (d.K != wd.K || d.N != wd.N || !d.K || (d.K % 32) ||
             d.stage != stage_for(d.family) || d.layer != d.weight_layer ||
             d.op != (d.command == LOAD_W ? 0x80u : linear_op(d.family))) {
    status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
  }
  if (status == 0) { G = d.K / 32; T = (d.N + 7) / 8; }
  if (status == 0 && st.bound && !same_session(st, d)) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }
  if (status == 0 && !st.bound && d.command != LOAD_W) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }
  if (status == 0 &&
      (st.last_task >= kMaximumEpoch ||
       d.task_id != st.last_task + (d.command == LOAD_W ? 1u : 2u) ||
       (d.command == RUN_TILE && d.quant_task_id != st.last_task + 1u))) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }

  if (status == 0 && d.command == LOAD_W) {
    const bool zero_fields = d.flags == 0 && d.batch == 0 && d.row0 == 0 &&
        d.rows == 1 && d.src.id == 0 && d.src.bank == 0 &&
        d.src.epoch == 0 && d.src.region == 0 &&
        d.dst.id == 0x23 && d.dst.bank == 0 &&
        d.dst.region == 0 && d.dst.epoch == d.w_epoch &&
        d.ps_epoch == 0 && d.quant_task_id == 0 &&
        d.activation_base == 0 && d.activation_span == 0 &&
        d.out0_base == 0 && d.out0_span == 0 &&
        d.out1_base == 0 && d.out1_span == 0 &&
        d.trace_row_local == 0 && d.trace_column == 0;
    if (!zero_fields || !valid_ref(d.dst)) {
      status = uint32_t(Status::E_BUFFER); error_detail = make_detail(4, 0x23, 4);
    } else if (st.w_max >= kMaximumEpoch || d.w_epoch != st.w_max + 1u ||
               (st.w_valid && d.family == st.w_family && d.weight_layer == st.w_layer)) {
      status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
    } else if (uint64_t(T) * G > kWDepth ||
               wd.q_span[0] % 64 || wd.q_span[1] % 64 ||
               wd.scale_span % 64 || wd.q_base[0] % 64 ||
               (wd.q_span[1] && wd.q_base[1] % 64) || wd.scale_base % 64 ||
               uint64_t(wd.q_span[0]) + wd.q_span[1] != uint64_t(T) * G * 8 * 32 ||
               wd.scale_span != uint64_t(T) * G * 8 * 2 ||
               (wd.bias_kind && wd.bias_span != d.N * 4u) ||
               uint64_t(wd.q_base[0]) + wd.q_span[0] > laya::full::kFullModelBoSizes[1] ||
               uint64_t(wd.q_base[1]) + wd.q_span[1] > laya::full::kFullModelBoSizes[2] ||
               uint64_t(wd.scale_base) + wd.scale_span > laya::full::kFullModelBoSizes[3] ||
               uint64_t(wd.bias_base) + wd.bias_span > laya::full::kFullModelBoSizes[4]) {
      status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
    }
  }
  if (status == 0 && d.command == RUN_TILE) {
    const bool row_ok = d.stage == 6 ? (d.row0 == 0 && d.rows == 1) :
        d.stage == 5 ? (uint64_t(d.row0) + d.rows <= 16) :
                       (uint64_t(d.row0) + d.rows <= d.S);
    if (!row_ok || !source_shape(d) || !destination_shape(d) ||
        !valid_ref(d.src) || !valid_ref(d.dst)) {
      status = uint32_t(Status::E_BUFFER); error_detail = make_detail(4, uint8_t(d.src.id), 4);
    } else if (!st.w_valid || d.w_epoch != st.w_epoch ||
               d.family != st.w_family || d.weight_layer != st.w_layer ||
               st.a8_max >= kMaximumEpoch || st.ps_max >= kMaximumEpoch ||
               st.dst_max >= kMaximumEpoch ||
               d.ps_epoch != st.ps_max + 1u ||
               d.dst.epoch != st.dst_max + 1u) {
      status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
    } else if ((d.flags && (d.trace_row_local >= d.rows ||
                            d.trace_column >= d.N)) ||
               (!d.flags && (d.trace_row_local || d.trace_column)) ||
               !valid_span(d.activation_base, d.activation_span,
                           uint64_t(d.rows) * d.K * 4u, 64) ||
               !valid_span(d.out0_base, d.out0_span,
                           d.op == 0x30 ?
                             (((((uint64_t(2) * 2 + d.batch) * 8 + 7) * 1024 +
                                 d.row0 + d.rows - 1) * 64 + 63) * 4 + 4) :
                             uint64_t(d.rows) * d.N * 4u, 4) ||
               (d.op == 0x30 ?
                 !valid_span(d.out1_base, d.out1_span,
                             (((((uint64_t(2) * 2 + d.batch) * 8 + 7) * 1024 +
                                 d.row0 + d.rows - 1) * 64 + 63) * 4 + 4), 4) :
                 (d.out1_base != 0 || d.out1_span != 0))) {
      status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
    }
  }

  if (status == 0 && d.command == LOAD_W) {
    // Claim/retire LOAD before any model I/O. An error consumes this epoch.
    if (!st.bound) bind_session(st, d);
    st.last_task = d.task_id; st.w_max = d.w_epoch; st.w_epoch = d.w_epoch;
    st.w_valid = false; st.w_family = d.family; st.w_layer = d.weight_layer;
    st.w_uses = 0; load_started = 1; done_task = d.task_id; error_phase = 1;
    uint32_t header[32];
    for (unsigned i = 0; i < 32; ++i) header[i] = aux[i];
    bytes(c, P_AUX, 128);
    bool header_ok = header[0] == 0x504d594cu && header[1] == 1 &&
        header[2] == 128 && header[3] == 13 && header[4] == 1;
    for (unsigned i = 5; i < 8; ++i) if (header[i]) header_ok = false;
    const uint8_t* expected[4] = {
        laya::full::kFullModelTag, laya::full::kFullNumericTag,
        laya::full::kFullLayoutTag, laya::full::kFullBuildTag};
    for (unsigned t = 0; t < 4; ++t)
      for (unsigned j = 0; j < 16; ++j)
        if (tag_byte(header[8 + t * 4 + j / 4], j % 4) != expected[t][j])
          header_ok = false;
    for (unsigned j = 0; j < 32; ++j)
      if (tag_byte(header[24 + j / 4], j % 4) !=
          laya::full::kFullSourceSha256[j]) header_ok = false;
    if (!header_ok) {
      status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
    }
    if (status == 0) {
      for (unsigned shard = 0; shard < 2; ++shard) {
        const unsigned nbeats = wd.q_span[shard] / 64;
        for (unsigned b = 0; b < nbeats; ++b) {
#pragma HLS PIPELINE II=1
          const ap_uint<512> beat = shard ? w_q1[wd.q_base[1] / 64 + b] :
                                          w_q0[wd.q_base[0] / 64 + b];
          bytes(c, shard ? P_W_Q1 : P_W_Q0, 64);
          const unsigned u = b / 4, pair = b % 4;
          const unsigned tile = 2 * (u / G) + shard;
          const unsigned addr = tile * G + u % G;
          wq[2 * pair][addr] = beat.range(255, 0);
          wq[2 * pair + 1][addr] = beat.range(511, 256);
        }
      }
      for (unsigned b = 0; b < wd.scale_span / 64; ++b) {
        const ap_uint<512> beat = w_scale[wd.scale_base / 64 + b];
        bytes(c, P_W_SCALE, 64);
        for (unsigned j = 0; j < 4; ++j) {
#pragma HLS PIPELINE II=1
          for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
            ws[lane][4 * b + j] = uint16_t(beat.range(16 * (8 * j + lane) + 15,
                                                     16 * (8 * j + lane)));
          }
        }
      }
      for (unsigned n = 0; n < d.N; ++n) {
        uint32_t value = 0;
        if (wd.bias_kind) {
          value = aux[(wd.bias_base / 4) + n];
          bytes(c, P_AUX, 4);
        }
        bias_bits[n % 8][n / 8] = value;
      }
      // Validate in production LOAD order: every padded n/g scale, then bias n.
      for (unsigned n = 0; n < T * 8 && status == 0; ++n)
        for (unsigned g = 0; g < G; ++g) {
          const float scale = half_to_f32(ws[n % 8][(n / 8) * G + g]);
          if (!finite(scale) || scale < 0.0f) {
            status = uint32_t(Status::E_NUMERICAL);
            error_detail = make_detail(7, 0x80, 15);
            bad_element = uint64_t(n) * G + g;
            break;
          }
        }
      for (unsigned n = 0; n < d.N && status == 0; ++n)
        if (wd.bias_kind && !finite(f32(bias_bits[n % 8][n / 8]))) {
          status = uint32_t(Status::E_NUMERICAL);
          error_detail = make_detail(7, 0x80, 15); bad_element = n;
        }
    }
    if (status == 0) {
      st.w_valid = true; ++st.w_loads;
      done_elements = T * G * 8 * 34; done_unit = 3; error_phase = 0;
    }
  }

  if (status == 0 && d.command == RUN_TILE) {
    // A8's private epoch is claimed independently of source and PS epochs.
    st.a8_max++; st.a_state = uint32_t(CacheState::FILL);
    st.last_task = d.quant_task_id;
    quant_done = d.quant_task_id; error_phase = 2;
    for (unsigned r = 0; r < d.rows; ++r) {
      for (unsigned b = 0; b < d.K / 16; ++b) {
        const ap_uint<512> beat = activation[d.activation_base / 64 + r * (d.K / 16) + b];
        bytes(c, P_ACTIVATION, 64);
        for (unsigned half = 0; half < 2; ++half) {
#pragma HLS PIPELINE II=1
          for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
            fp[lane][r * 512 + 2 * b + half] =
                uint32_t(beat.range(32 * (8 * half + lane) + 31,
                                    32 * (8 * half + lane)));
          }
        }
      }
    }
    for (unsigned r = 0; r < d.rows && status == 0; ++r)
      for (unsigned g = 0; g < G && status == 0; ++g) {
        float group[32];
        float amax = 0.0f;
        for (unsigned block = 0; block < 4; ++block) {
#pragma HLS PIPELINE II=1
          unsigned first_bad = 32;
          for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
            const unsigned i = block * 8 + lane;
            const unsigned k = g * 32 + i;
            group[i] = f32(fp[lane][r * 512 + k / 8]);
            if (!finite(group[i])) {
              if (i < first_bad) first_bad = i;
            } else {
              const float mag = ::fabsf(group[i]);
              if (mag > amax) amax = mag;
            }
          }
          if (first_bad < 32) {
            status = uint32_t(Status::E_NUMERICAL);
            bad_element = uint64_t(r) * 4096 + g * 32 + first_bad;
            break;
          }
        }
        if (status) break;
        const float d_full = amax / 127.0f;
        const float reciprocal = d_full == 0.0f ? 0.0f : 1.0f / d_full;
        const uint16_t saved = f32_to_half_rne(d_full);
        if (!finite(d_full) || !finite(reciprocal) ||
            (saved & 0x7c00u) == 0x7c00u) {
          status = uint32_t(Status::E_NUMERICAL);
          bad_element = uint64_t(r) * 4096 + g * 32;
          break;
        }
        ap_uint<256> packed = 0;
        for (unsigned block = 0; block < 4; ++block) {
#pragma HLS PIPELINE II=1
          unsigned first_bad = 32;
          for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
            const unsigned i = block * 8 + lane;
            const float product = group[i] * reciprocal;
            const float rounded = d_full == 0.0f ? 0.0f : ::roundf(product);
            if (!finite(product) || !finite(rounded) ||
                rounded < -127.0f || rounded > 127.0f) {
              if (i < first_bad) first_bad = i;
            } else {
              packed.range(8 * i + 7, 8 * i) = uint8_t(int8_t(rounded));
            }
          }
          if (first_bad < 32) {
            status = uint32_t(Status::E_NUMERICAL);
            bad_element = uint64_t(r) * 4096 + g * 32 + first_bad;
            break;
          }
        }
        if (status) break;
        aq[r % 4][(r / 4) * 128 + g] = packed;
        as[r % 4][(r / 4) * 128 + g] = saved;
        ++c.quant_groups; c.quant_inputs += 32;
      }
    if (status) {
      error_detail = make_detail(7, 0x20, 15);
      quant_status = status;
      st.a_state = uint32_t(CacheState::INVALID);
      done_task = d.quant_task_id;
      done_unit = 2;
    } else {
      st.a_state = uint32_t(CacheState::READY);
      quant_status = 0;
      if (d.flags) {
        for (unsigned r = 0; r < d.rows; ++r)
          for (unsigned g = 0; g < G; ++g) {
            const ap_uint<256> packed = aq[r % 4][(r / 4) * 128 + g];
            for (unsigned j = 0; j < 8; ++j) {
              observed[kTraceQWord + (r * G + g) * 8 + j] =
                  uint32_t(packed.range(j * 32 + 31, j * 32));
              ++c.trace_words;
            }
          }
        for (unsigned idx = 0; idx < d.rows * G; idx += 2) {
          const unsigned r0 = idx / G, g0 = idx % G;
          const uint32_t lo = as[r0 % 4][(r0 / 4) * 128 + g0];
          uint32_t hi = 0;
          if (idx + 1 < d.rows * G) {
            const unsigned r1 = (idx + 1) / G, g1 = (idx + 1) % G;
            hi = as[r1 % 4][(r1 / 4) * 128 + g1];
          }
          observed[kTraceScaleWord + idx / 2] = lo | (hi << 16);
          ++c.trace_words;
        }
      }
      // Linear starts only after successful quant retirement.
      st.last_task = d.task_id;
      st.ps_max = d.ps_epoch; st.ps_epoch = d.ps_epoch;
      st.dst_max = d.dst.epoch; st.dst_epoch = d.dst.epoch;
      st.ps_state = uint32_t(CacheState::FILL);
      st.dst_state = uint32_t(CacheState::FILL);
      if (st.w_uses) ++st.w_reuses;
      ++st.w_uses;
      linear_started = 1; done_task = d.task_id; error_phase = 3;
      uint64_t first_rank = UINT64_MAX;
      for (unsigned m0 = 0; m0 < d.rows; m0 += 4) {
        bool lane_bad[32][kPsDepth];
#pragma HLS ARRAY_PARTITION variable=lane_bad complete dim=1
#pragma HLS bind_storage variable=lane_bad type=ram_2p impl=bram
        for (unsigned tile = 0; tile < T; ++tile)
          for (unsigned bank = 0; bank < 32; ++bank) lane_bad[bank][tile] = false;
        for (unsigned g = 0; g < G; ++g)
          for (unsigned tile = 0; tile < T; ++tile) {
            ++c.issued;
            for (unsigned rr = 0; rr < 4; ++rr) {
#pragma HLS UNROLL
              const unsigned r = m0 + rr;
              if (r >= d.rows) continue;
              const ap_uint<256> av = aq[r % 4][(r / 4) * 128 + g];
              const float sa = half_to_f32(as[r % 4][(r / 4) * 128 + g]);
              for (unsigned cc = 0; cc < 8; ++cc) {
#pragma HLS UNROLL
                const unsigned n = tile * 8 + cc;
                const unsigned bank = rr * 8 + cc;
                if (n >= d.N || lane_bad[bank][tile]) continue;
                const int32_t dot = dot32(av, wq[cc][tile * G + g]);
                c.macs += 32;
                const float sw = half_to_f32(ws[cc][tile * G + g]);
                const float product = sa * sw;
                const float term = float(dot) * product;
                const float old = g == 0 ? 0.0f : ps[bank][tile];
                const float next = old + term;
                unsigned phase = 4;
                if (!finite(sa) || !finite(sw) || sa < 0.0f || sw < 0.0f)
                  phase = 0;
                else if (!finite(product)) phase = 1;
                else if (!finite(term)) phase = 2;
                else if (!finite(next)) phase = 3;
                if (phase != 4) {
                  lane_bad[bank][tile] = true;
                  const uint64_t rank = (((uint64_t(tile) * 16 + r) * 8 + cc) *
                                         (G + 1) + g) * 5 + phase;
                  if (rank < first_rank) {
                    first_rank = rank;
                    bad_element = uint64_t(r) * 5248 * 128 + uint64_t(n) * 128 + g;
                  }
                  continue;
                }
                ps[bank][tile] = next;
                if (d.flags && r == d.trace_row_local && n == d.trace_column) {
                  const unsigned at = kTraceGroupWord + g * kTraceGroupWords;
                  observed[at + T_DOT] = uint32_t(dot);
                  observed[at + T_SA] = bits(sa);
                  observed[at + T_SW] = bits(sw);
                  observed[at + T_PRODUCT] = bits(product);
                  observed[at + T_TERM] = bits(term);
                  observed[at + T_PS] = bits(next);
                  observed[at + T_GROUP] = g;
                  observed[at + T_VALID] = 1;
                  c.trace_words += kTraceGroupWords;
                  ++c.trace_groups;
                }
              }
            }
            ++c.retired;
          }
        for (unsigned tile = 0; tile < T; ++tile)
          for (unsigned rr = 0; rr < 4; ++rr) {
            const unsigned r = m0 + rr;
            if (r >= d.rows) continue;
            for (unsigned cc = 0; cc < 8; ++cc) {
              const unsigned n = tile * 8 + cc;
              if (n >= d.N || lane_bad[rr * 8 + cc][tile]) continue;
              const uint32_t bias_raw = bias_bits[cc][tile];
              const float b = f32(bias_raw);
              const float old = ps[rr * 8 + cc][tile];
              const float value = wd.bias_kind ? old + b : old;
              if (!finite(b) || !finite(value)) {
                lane_bad[rr * 8 + cc][tile] = true;
                const uint64_t rank = (((uint64_t(tile) * 16 + r) * 8 + cc) *
                                       (G + 1) + G) * 5;
                if (rank < first_rank) {
                  first_rank = rank;
                  bad_element = uint64_t(r) * 5248 * 128 + uint64_t(n) * 128 + G;
                }
                continue;
              }
              uint64_t offset = uint64_t(r) * d.N * 4 + uint64_t(n) * 4;
              if (d.op == 0x30) {
                const unsigned plane = n / 1024;
                const unsigned head = (n % 1024) / 64;
                const unsigned dim = n % 64;
                offset = (((((uint64_t(plane) * 2 + d.batch) * 8 + head / 2) *
                            1024 + d.row0 + r) * 64 + dim) * 4);
                if (head % 2) { out1[(d.out1_base + offset) / 4] = bits(value); bytes(c, P_OUT1, 4); }
                else { out0[(d.out0_base + offset) / 4] = bits(value); bytes(c, P_OUT0, 4); }
              } else {
                out0[(d.out0_base + offset) / 4] = bits(value);
                bytes(c, P_OUT0, 4);
              }
              ++c.writes;
              if (d.flags && r == d.trace_row_local && n == d.trace_column) {
                c.trace_bias = bias_raw;
                c.trace_bias_valid = wd.bias_kind != 0;
                c.trace_final = bits(value);
              }
            }
          }
      }
      if (first_rank != UINT64_MAX) {
        status = uint32_t(Status::E_NUMERICAL);
        error_detail = make_detail(7, uint8_t(d.op), 15);
        st.ps_state = uint32_t(CacheState::INVALID);
        st.dst_state = uint32_t(CacheState::INVALID);
      } else {
        st.ps_state = uint32_t(CacheState::READY);
        st.dst_state = uint32_t(CacheState::READY);
        done_elements = d.rows * d.N;
        done_unit = 1; error_phase = 0;
      }
    }
  }
  report(observed, d, st, c, status, error_detail, bad_element,
         done_task, done_elements, done_unit, quant_done, quant_status,
         linear_started, load_started, error_phase);
}
