#include "q8_tm1tn8_session_dma_v2.h"
#include "q8_tm1tn8_session_abi_v2.h"
#include "laya_model_layout_generated.h"
#include "hls_stream.h"

#include <cmath>
#include <cstdint>
#include <cstring>

#pragma STDC FP_CONTRACT OFF

namespace {
using namespace q8_tm1tn8;
namespace v2 = q8_tm1tn8_v2;
using laya::CacheState;
using laya::Status;
using laya::full::FullWeightDescriptor;

constexpr unsigned kWDepth = 12288;
constexpr unsigned kA8Depth = 32;
constexpr unsigned kFpDepth = 128;
constexpr unsigned kPsDepth = 384;

struct State {
  bool bound = false, w_valid = false;
  uint32_t session_state = v2::EMPTY, profile = v2::STRICT;
  uint64_t session_generation = 0, generation_high_water = 0;
  uint64_t context_cookie[2] = {};
  uint64_t bo_base[v2::kBoCount] = {};
  uint64_t bo_bytes[v2::kBoCount] = {};
  uint64_t bo_cookie[v2::kBoCount] = {};
  uint32_t record_digest[8] = {}, manifest_digest[8] = {};
  uint32_t build_digest[8] = {}, source_digest[8] = {};
  uint64_t w_session_generation = 0;
  uint32_t w_profile = 0;
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
  uint32_t trace_physical_words = 0;
  bool trace_bias_valid = false;
  uint64_t scale_checks = 0;
};

struct SessionFields {
  uint32_t profile = 0;
  uint64_t generation = 0, context_cookie[2] = {};
  uint64_t bo_base[v2::kBoCount] = {};
  uint64_t bo_bytes[v2::kBoCount] = {};
  uint64_t bo_cookie[v2::kBoCount] = {};
  uint32_t record_digest[8] = {}, manifest_digest[8] = {};
  uint32_t build_digest[8] = {}, source_digest[8] = {};
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

SessionFields session_fields(const uint32_t* words) {
  SessionFields s;
  s.profile = words[v2::D_PROFILE];
  s.generation = join_u64(words[v2::D_MODEL_SESSION_GENERATION_LO],
                          words[v2::D_MODEL_SESSION_GENERATION_HI]);
  for (unsigned i = 0; i < 2; ++i)
    s.context_cookie[i] =
        join_u64(words[v2::D_CONTEXT_COOKIE_0 + 2 * i],
                 words[v2::D_CONTEXT_COOKIE_0 + 2 * i + 1]);
  for (unsigned i = 0; i < 8; ++i) {
    s.record_digest[i] = words[v2::D_VALIDATION_RECORD_SHA256_0 + i];
    s.manifest_digest[i] = words[v2::D_MANIFEST_SHA256_0 + i];
    s.build_digest[i] = words[v2::D_CANDIDATE_BUILD_SHA256_0 + i];
    s.source_digest[i] = words[v2::D_SOURCE_GGUF_SHA256_0 + i];
  }
  for (unsigned i = 0; i < v2::kBoCount; ++i) {
    s.bo_base[i] = join_u64(words[v2::bo_word(i, v2::B_BASE_LO)],
                            words[v2::bo_word(i, v2::B_BASE_HI)]);
    s.bo_bytes[i] = join_u64(words[v2::bo_word(i, v2::B_BYTES_LO)],
                             words[v2::bo_word(i, v2::B_BYTES_HI)]);
    s.bo_cookie[i] = join_u64(words[v2::bo_word(i, v2::B_COOKIE_LO)],
                              words[v2::bo_word(i, v2::B_COOKIE_HI)]);
  }
  return s;
}

bool digest_nonzero(const uint32_t* digest) {
  uint32_t any = 0;
  for (unsigned i = 0; i < 8; ++i) any |= digest[i];
  return any != 0;
}

bool compiled_sha_matches(const uint32_t* digest, const uint8_t* expected) {
  for (unsigned i = 0; i < 32; ++i)
    if (tag_byte(digest[i / 4], i % 4) != expected[i]) return false;
  return true;
}

bool session_format(const uint32_t* words, const SessionFields& s) {
  if (words[v2::D_SESSION_FLAGS] || words[v2::D_MODEL_BO_COUNT] != v2::kBoCount ||
      words[v2::D_BO_ENTRY_BYTES] != v2::kBoEntryBytes ||
      words[v2::D_BINDING_WORDS] != v2::kBindingWords ||
      words[v2::D_ZERO_107] || s.profile > v2::VALIDATED_STATIC_MODEL_V1 ||
      !s.generation || (!s.context_cookie[0] && !s.context_cookie[1]) ||
      !digest_nonzero(s.record_digest) || !digest_nonzero(s.manifest_digest))
    return false;
  for (unsigned i = v2::D_RESERVED_108; i < v2::kBoTableFirst; ++i)
    if (words[i]) return false;
  for (unsigned i = v2::D_RESERVED_152; i < v2::kDescriptorWords; ++i)
    if (words[i]) return false;
  if (!compiled_sha_matches(s.build_digest, laya::full::kFullBuildSha256) ||
      !compiled_sha_matches(s.source_digest, laya::full::kFullSourceSha256))
    return false;
  for (unsigned i = 0; i < v2::kBoCount; ++i) {
    if (words[v2::bo_word(i, v2::B_ROLE)] != v2::kBoRoles[i] ||
        words[v2::bo_word(i, v2::B_FLAGS)] != 1 ||
        s.bo_base[i] % 64 || !s.bo_cookie[i] ||
        s.bo_bytes[i] != laya::full::kFullModelBoSizes[i] ||
        s.bo_base[i] > UINT64_MAX - s.bo_bytes[i])
      return false;
    for (unsigned j = 0; j < i; ++j)
      if (s.bo_base[i] < s.bo_base[j] + s.bo_bytes[j] &&
          s.bo_base[j] < s.bo_base[i] + s.bo_bytes[i])
        return false;
  }
  return true;
}

bool management_fields_zero(const uint32_t* words) {
  if (words[D_FLAGS]) return false;
  for (unsigned i = D_REQUEST_LO; i <= D_QUANT_TASK_ID; ++i)
    if (words[i]) return false;
  for (unsigned i = D_ACT_BASE_LO; i <= D_TRACE_COLUMN; ++i)
    if (words[i]) return false;
  return true;
}

bool aux_header_matches(const uint32_t* aux, Counts& c) {
  uint32_t header[32];
  for (unsigned i = 0; i < 32; ++i) header[i] = aux[i];
  bytes(c, P_AUX, 128);
  bool okay = header[0] == 0x504d594cu && header[1] == 1 &&
      header[2] == 128 && header[3] == 13 && header[4] == 1;
  for (unsigned i = 5; i < 8; ++i) if (header[i]) okay = false;
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned j = 0; j < 16; ++j) {
      uint8_t expected_byte = 0;
      switch (t) {
        case 0: expected_byte = laya::full::kFullModelTag[j]; break;
        case 1: expected_byte = laya::full::kFullNumericTag[j]; break;
        case 2: expected_byte = laya::full::kFullLayoutTag[j]; break;
        default: expected_byte = laya::full::kFullBuildTag[j]; break;
      }
      if (tag_byte(header[8 + 4*t + j/4], j%4) != expected_byte)
        okay = false;
    }
  for (unsigned j = 0; j < 32; ++j)
    if (tag_byte(header[24 + j/4], j%4) !=
        laya::full::kFullSourceSha256[j]) okay = false;
  return okay;
}

bool binding_matches(const SessionFields& s, const uint64_t* actual) {
  if (actual[0] != s.context_cookie[0] ||
      actual[1] != s.context_cookie[1] || actual[2] != s.generation)
    return false;
  for (unsigned i = 0; i < v2::kBoCount; ++i)
    if (actual[v2::binding_base_beat(i)] != s.bo_base[i] ||
        actual[v2::binding_bytes_beat(i)] != s.bo_bytes[i] ||
        actual[v2::binding_cookie_beat(i)] != s.bo_cookie[i])
      return false;
  return true;
}

bool active_session_matches(const State& st, const SessionFields& s) {
  if (st.session_state != v2::ACTIVE ||
      st.profile != s.profile ||
      st.session_generation != s.generation ||
      st.context_cookie[0] != s.context_cookie[0] ||
      st.context_cookie[1] != s.context_cookie[1])
    return false;
  for (unsigned i = 0; i < v2::kBoCount; ++i)
    if (st.bo_base[i] != s.bo_base[i] ||
        st.bo_bytes[i] != s.bo_bytes[i] ||
        st.bo_cookie[i] != s.bo_cookie[i]) return false;
  for (unsigned i = 0; i < 8; ++i)
    if (st.record_digest[i] != s.record_digest[i] ||
        st.manifest_digest[i] != s.manifest_digest[i] ||
        st.build_digest[i] != s.build_digest[i] ||
        st.source_digest[i] != s.source_digest[i]) return false;
  return true;
}

uint32_t active_binding_reject(const State& st, const uint64_t* actual) {
  if (st.session_state != v2::ACTIVE) return v2::SESSION_OK;
  if (actual[0] != st.context_cookie[0] ||
      actual[1] != st.context_cookie[1]) return v2::CONTEXT;
  if (actual[2] != st.session_generation) return v2::GENERATION;
  for (unsigned i = 0; i < v2::kBoCount; ++i)
    if (actual[v2::binding_base_beat(i)] != st.bo_base[i] ||
        actual[v2::binding_bytes_beat(i)] != st.bo_bytes[i] ||
        actual[v2::binding_cookie_beat(i)] != st.bo_cookie[i])
      return v2::BO_BINDING;
  return v2::SESSION_OK;
}

uint32_t active_session_reject(const State& st, const SessionFields& s) {
  if (st.session_state != v2::ACTIVE) return v2::NO_ACTIVE;
  if (st.profile != s.profile) return v2::PROFILE_MISMATCH;
  if (st.session_generation != s.generation) return v2::GENERATION;
  if (st.context_cookie[0] != s.context_cookie[0] ||
      st.context_cookie[1] != s.context_cookie[1]) return v2::CONTEXT;
  for (unsigned i = 0; i < v2::kBoCount; ++i)
    if (st.bo_base[i] != s.bo_base[i] ||
        st.bo_bytes[i] != s.bo_bytes[i] ||
        st.bo_cookie[i] != s.bo_cookie[i]) return v2::BO_BINDING;
  return v2::DIGEST_OR_BUILD;
}

void invalidate_owned_caches(State& st) {
  st.bound = false; st.w_valid = false; st.w_session_generation = 0;
  st.w_epoch = 0; st.ps_epoch = 0; st.dst_epoch = 0;
  st.a_state = uint32_t(CacheState::INVALID);
  st.ps_state = uint32_t(CacheState::INVALID);
  st.dst_state = uint32_t(CacheState::INVALID);
}

void register_session(State& st, const SessionFields& s) {
  st.session_generation = s.generation;
  st.generation_high_water = s.generation;
  st.profile = s.profile;
  for (unsigned i = 0; i < 2; ++i) st.context_cookie[i] = s.context_cookie[i];
  for (unsigned i = 0; i < v2::kBoCount; ++i) {
    st.bo_base[i] = s.bo_base[i];
    st.bo_bytes[i] = s.bo_bytes[i];
    st.bo_cookie[i] = s.bo_cookie[i];
  }
  for (unsigned i = 0; i < 8; ++i) {
    st.record_digest[i] = s.record_digest[i];
    st.manifest_digest[i] = s.manifest_digest[i];
    st.build_digest[i] = s.build_digest[i];
    st.source_digest[i] = s.source_digest[i];
  }
  invalidate_owned_caches(st);
  st.last_task = 0;
  st.w_max = 0; st.a8_max = 0; st.ps_max = 0; st.dst_max = 0;
  st.w_loads = 0; st.w_uses = 0; st.w_reuses = 0;
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
  for (unsigned j = 0; j < 16; ++j)
    if (tag_byte(d.tags[0][j / 4], j % 4) != laya::full::kFullModelTag[j]) return false;
  for (unsigned j = 0; j < 16; ++j)
    if (tag_byte(d.tags[1][j / 4], j % 4) != laya::full::kFullNumericTag[j]) return false;
  for (unsigned j = 0; j < 16; ++j)
    if (tag_byte(d.tags[2][j / 4], j % 4) != laya::full::kFullLayoutTag[j]) return false;
  for (unsigned j = 0; j < 16; ++j)
    if (tag_byte(d.tags[3][j / 4], j % 4) != laya::full::kFullBuildTag[j]) return false;
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
    return d.K == 256 && d.N == 2 && d.op == 0x37 &&
           d.family == 12 && d.weight_layer == 255 && d.layer == 255 &&
           d.batch == 0 && d.row0 == 0 && d.rows == 1 &&
           d.src.id == 10 && d.src.bank == 0 &&
           d.src.region == 2 && d.src.epoch == 1;
  if (d.stage == 2)
    return d.K == 1024 && d.N == 3072 && d.op == 0x30 &&
           d.family == 1 && d.weight_layer == 0 && d.layer == 0 &&
           d.batch == 0 && d.row0 == 0 &&
           (d.rows == 1 || d.rows == 4) &&
           d.src.id == 1 && d.src.bank == 1 &&
           d.src.region == 0 && d.src.epoch == 1;
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

void report(uint32_t* observed, const Descriptor& d, const State& st,
            Counts& c, uint32_t status, uint32_t error_detail,
            uint64_t bad_element, uint32_t done_task, uint32_t done_elements,
            uint32_t done_unit, uint32_t quant_done, uint32_t quant_status,
            uint32_t linear_started, uint32_t load_started,
            uint32_t error_phase, uint32_t admission, bool binding_match,
            uint32_t session_reject, uint32_t first_error_owner) {
  bytes(c, P_OBSERVED,
        uint64_t(O_HEADER_WORDS + c.trace_words +
                 c.trace_physical_words) * 4);
  uint32_t h[O_HEADER_WORDS] = {};
  h[O_MAGIC] = v2::kObservedMagic; h[O_VERSION] = v2::kObservedVersion;
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
  h[v2::O_PROFILE] = d.command <= v2::REVOKE_MODEL ? st.profile : 0;
  h[v2::O_MODEL_SESSION_STATE] = st.session_state;
  const uint64_t active_generation =
      st.session_state == v2::ACTIVE ? st.session_generation : 0;
  h[v2::O_ACTIVE_GENERATION_LO] = lo32(active_generation);
  h[v2::O_ACTIVE_GENERATION_HI] = hi32(active_generation);
  h[v2::O_COMMAND_ADMISSION] = admission;
  h[v2::O_BINDING_MATCH] = binding_match ? 1 : 0;
  if (st.session_state == v2::ACTIVE) {
    for (unsigned i = 0; i < 2; ++i) {
      h[v2::O_CONTEXT_COOKIE_0 + 2 * i] = lo32(st.context_cookie[i]);
      h[v2::O_CONTEXT_COOKIE_0 + 2 * i + 1] = hi32(st.context_cookie[i]);
    }
    for (unsigned i = 0; i < 8; ++i)
      h[v2::O_REGISTERED_RECORD_SHA256_0 + i] = st.record_digest[i];
  }
  for (unsigned i = 0; i < 8; ++i)
    h[v2::O_CANDIDATE_BUILD_SHA256_0 + i] =
        uint32_t(laya::full::kFullBuildSha256[4*i]) |
        (uint32_t(laya::full::kFullBuildSha256[4*i+1]) << 8) |
        (uint32_t(laya::full::kFullBuildSha256[4*i+2]) << 16) |
        (uint32_t(laya::full::kFullBuildSha256[4*i+3]) << 24);
  h[v2::O_SCALE_CHECKS_LO] = lo32(c.scale_checks);
  h[v2::O_SCALE_CHECKS_HI] = hi32(c.scale_checks);
  h[v2::O_GENERATION_HIGH_WATER_LO] = lo32(st.generation_high_water);
  h[v2::O_GENERATION_HIGH_WATER_HI] = hi32(st.generation_high_water);
  h[v2::O_W_SESSION_GENERATION_LO] =
      st.w_valid ? lo32(st.w_session_generation) : 0;
  h[v2::O_W_SESSION_GENERATION_HI] =
      st.w_valid ? hi32(st.w_session_generation) : 0;
  h[v2::O_W_PROFILE] = st.w_valid ? st.w_profile : 0;
  h[v2::O_FIRST_ERROR_OWNER] = first_error_owner;
  h[v2::O_SESSION_REJECT] = session_reject;
  h[v2::O_DESCRIPTOR_BYTES] = v2::kDescriptorBytes;
  h[v2::O_BINDING_WORDS] = v2::kBindingWords;
  for (unsigned i = 0; i < O_HEADER_WORDS; ++i) observed[i] = h[i];
}
}  // namespace

extern "C" void q8_tm1tn8_session_dma_v2(
    const uint32_t* descriptor, const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1, const ap_uint<512>* w_scale,
    const uint32_t* aux, const ap_uint<512>* activation,
    hls::stream<ap_uint<64>>& binding_context,
    hls::stream<ap_uint<256>>& writer_config,
    hls::stream<ap_uint<256>>& compute_config,
    hls::stream<ap_uint<288>>& bias_tiles,
    hls::stream<ap_uint<2816>>& group_issues,
    hls::stream<ap_uint<1>>& finish,
    hls::stream<ap_uint<512>>& writer_completion,
    uint32_t* observed) {
#pragma HLS INTERFACE m_axi port=descriptor offset=slave bundle=gmem_descriptor max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q0 offset=slave bundle=gmem_w_q0 max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_q1 offset=slave bundle=gmem_w_q1 max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=w_scale offset=slave bundle=gmem_w_scale max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=gmem_aux max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=activation offset=slave bundle=gmem_activation max_read_burst_length=16 num_read_outstanding=1
#pragma HLS INTERFACE axis port=binding_context
#pragma HLS INTERFACE axis port=writer_config
#pragma HLS INTERFACE axis port=compute_config
#pragma HLS INTERFACE axis port=bias_tiles
#pragma HLS INTERFACE axis port=group_issues
#pragma HLS INTERFACE axis port=finish
#pragma HLS INTERFACE axis port=writer_completion
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=gmem_observed max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control

  static State st;
#ifdef __SYNTHESIS__
#pragma HLS reset variable=st
#endif
  static ap_uint<256> wq[8][kWDepth];
  static uint16_t ws[8][kWDepth];
  static uint32_t bias_bits[8][kPsDepth];
  static uint32_t fp[8][kFpDepth];
  static ap_uint<256> aq[4][kA8Depth];
  static uint16_t as[4][kA8Depth];
#pragma HLS ARRAY_PARTITION variable=wq complete dim=1
#pragma HLS ARRAY_PARTITION variable=ws complete dim=1
#pragma HLS ARRAY_PARTITION variable=bias_bits complete dim=1
#pragma HLS ARRAY_PARTITION variable=fp complete dim=1
#pragma HLS ARRAY_PARTITION variable=aq complete dim=1
#pragma HLS ARRAY_PARTITION variable=as complete dim=1
#pragma HLS bind_storage variable=wq type=ram_2p impl=uram
#pragma HLS bind_storage variable=ws type=ram_2p impl=bram
#pragma HLS bind_storage variable=fp type=ram_2p impl=bram
#pragma HLS bind_storage variable=aq type=ram_2p impl=bram
#pragma HLS bind_storage variable=as type=ram_2p impl=bram
#pragma HLS bind_storage variable=bias_bits type=ram_2p impl=bram

  Counts c;
  uint32_t words[v2::kDescriptorWords];
  for (unsigned i = 0; i < v2::kDescriptorWords; ++i) words[i] = descriptor[i];
  bytes(c, P_DESCRIPTOR, v2::kDescriptorBytes);
  uint64_t actual_binding[v2::kBindingWords];
  for (unsigned i = 0; i < v2::kBindingWords; ++i)
    actual_binding[i] = uint64_t(binding_context.read());
  const SessionFields sf = session_fields(words);
  const bool actual_matches_descriptor = binding_matches(sf, actual_binding);
  const bool was_active = st.session_state == v2::ACTIVE;
  const uint32_t live_binding_reject =
      active_binding_reject(st, actual_binding);
  // A changed live BO/context invalidates the registered slot even when the
  // accompanying descriptor is malformed. A descriptor-only typo leaves the
  // unchanged live slot intact.
  if (live_binding_reject != v2::SESSION_OK) {
    st.session_state = v2::INVALID;
    invalidate_owned_caches(st);
  }
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
  ap_uint<256> writer_cfg = 0;
  writer_cfg.range(63, 0) = d.out0_base;
  writer_cfg.range(127, 64) = d.out0_span;
  writer_cfg.range(191, 128) = d.out1_base;
  writer_cfg.range(255, 192) = d.out1_span;
  ap_uint<256> compute_cfg = 0;
  compute_cfg.range(31, 0) = d.K;
  compute_cfg.range(63, 32) = d.N;
  compute_cfg.range(95, 64) = d.rows;
  compute_cfg.range(127, 96) = d.row0;
  compute_cfg.range(159, 128) = d.batch;
  compute_cfg.range(191, 160) = d.op;
  compute_cfg.range(223, 192) = d.task_id;
  bool cfg_sent = false;

  uint32_t status = uint32_t(Status::OK), error_detail = 0;
  uint64_t bad_element = UINT64_MAX;
  uint32_t done_task = 0, done_elements = 0, done_unit = 0;
  uint32_t quant_done = 0, quant_status = 0;
  uint32_t linear_started = 0, load_started = 0, error_phase = 0;
  FullWeightDescriptor wd;
  unsigned G = 0, T = 0;
  uint32_t admission = v2::NOT_ADMITTED;
  uint32_t session_reject = v2::SESSION_OK;
  uint32_t first_error_owner = v2::NO_ERROR;
  const bool operator_command = d.command <= v2::RUN_TILE;

  // All preflight rejections are before any task or epoch claim.
  bool abi_ok = words[D_MAGIC] == v2::kDescriptorMagic &&
                words[D_VERSION] == v2::kDescriptorVersion &&
                d.command <= v2::REVOKE_MODEL &&
                (d.command == v2::RUN_TILE ? (d.flags & ~1u) == 0 :
                                                   d.flags == 0) &&
                words[D_OBSERVED_WORDS] == v2::kObservedWords &&
                words[v2::D_DESCRIPTOR_BYTES] == v2::kDescriptorBytes;
  if (!abi_ok) {
    status = uint32_t(Status::E_ABI); error_detail = make_detail(0, 0, 4);
    first_error_owner = v2::DESCRIPTOR_ERROR;
  } else if (!tag_matches(d)) {
    status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
    first_error_owner = v2::DESCRIPTOR_ERROR;
  } else if (!session_format(words, sf)) {
    status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
    session_reject = v2::DIGEST_OR_BUILD;
    first_error_owner = v2::DESCRIPTOR_ERROR;
  } else if (!actual_matches_descriptor) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
    session_reject = actual_binding[0] != sf.context_cookie[0] ||
                     actual_binding[1] != sf.context_cookie[1] ?
                     v2::CONTEXT :
                     actual_binding[2] != sf.generation ?
                     v2::GENERATION : v2::BO_BINDING;
    first_error_owner = v2::MODEL_SESSION_ERROR;
  }
  if (status == 0 && !operator_command) {
    if (!management_fields_zero(words)) {
      status = uint32_t(Status::E_ABI); error_detail = make_detail(0, 0, 4);
      first_error_owner = v2::DESCRIPTOR_ERROR;
    } else if (d.command == v2::REGISTER_MODEL) {
      if (was_active ||
          sf.generation <= st.generation_high_water ||
          st.generation_high_water == UINT64_MAX) {
        status = uint32_t(Status::E_PROTOCOL);
        error_detail = make_detail(7, 0, 4);
        session_reject = v2::REGISTER_STATE;
        first_error_owner = v2::MODEL_SESSION_ERROR;
      } else {
        register_session(st, sf);
        st.session_state = v2::INVALID;
        admission = v2::SESSION_COMMAND;
        if (aux_header_matches(aux, c)) st.session_state = v2::ACTIVE;
        else {
          status = uint32_t(Status::E_MODEL);
          error_detail = make_detail(4, 0, 4);
          first_error_owner = v2::MODEL_SESSION_ERROR;
        }
      }
    } else if (!active_session_matches(st, sf)) {
      status = uint32_t(Status::E_PROTOCOL);
      error_detail = make_detail(7, 0, 4);
      session_reject = live_binding_reject != v2::SESSION_OK ?
                       live_binding_reject : active_session_reject(st, sf);
      first_error_owner = v2::MODEL_SESSION_ERROR;
    } else {
      admission = v2::SESSION_COMMAND;
      st.session_state = v2::EMPTY;
      invalidate_owned_caches(st);
    }
  }
  if (status == 0 && operator_command &&
      !active_session_matches(st, sf)) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
    session_reject = live_binding_reject != v2::SESSION_OK ?
                     live_binding_reject : active_session_reject(st, sf);
    first_error_owner = v2::MODEL_SESSION_ERROR;
  }
  if (status == 0 && operator_command &&
      (d.op > 255 || d.stage > 7 || d.layer > 255 ||
             d.B < 1 || d.B > 2 || d.S != 128 ||
             d.batch >= d.B || d.row0 > 1023 || d.rows < 1 || d.rows > 4 ||
             d.K > 1024 || d.N > 3072 || d.family > 255 ||
             d.weight_layer > 255 ||
             d.src.id > 255 || d.src.bank > 255 || d.src.region > 255 ||
             d.dst.id > 255 || d.dst.bank > 255 || d.dst.region > 255 ||
             d.trace_row_local > 255 || d.trace_column > 65535 ||
             d.task_id == 0 || d.task_id > kMaximumEpoch ||
             d.w_epoch > kMaximumEpoch || d.ps_epoch > kMaximumEpoch ||
             d.quant_task_id > kMaximumEpoch)) {
    status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
  } else if (status == 0 && operator_command &&
             (!lookup_weight(d, wd) || wd.dtype != 8)) {
    status = uint32_t(Status::E_MODEL); error_detail = make_detail(4, 0, 4);
  } else if (status == 0 && operator_command &&
             (d.K != wd.K || d.N != wd.N || !d.K || (d.K % 32) ||
             d.stage != stage_for(d.family) || d.layer != d.weight_layer ||
             d.op != (d.command == LOAD_W ? 0x80u : linear_op(d.family)) ||
             !((d.family == 12 && d.weight_layer == 255 &&
                d.K == 256 && d.N == 2 && d.rows == 1) ||
               (d.family == 1 && d.weight_layer == 0 &&
                d.K == 1024 && d.N == 3072 &&
                (d.rows == 1 || d.rows == 4))))) {
    status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
  }
  if (status == 0 && operator_command) { G = d.K / 32; T = (d.N + 7) / 8; }
  if (status == 0 && operator_command && (d.B != 1 || d.S != 128)) {
    status = uint32_t(Status::E_SHAPE); error_detail = make_detail(7, uint8_t(d.op), 5);
  }
  if (status == 0 && operator_command &&
      (!d.request_id || !d.generation)) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }
  if (status == 0 && operator_command && st.bound && !same_session(st, d)) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }
  if (status == 0 && operator_command && !st.bound &&
      d.command != LOAD_W) {
    status = uint32_t(Status::E_PROTOCOL); error_detail = make_detail(7, 0, 4);
  }
  if (status == 0 && operator_command &&
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
    } else if (st.w_max >= kMaximumEpoch || d.w_epoch != st.w_max + 1u) {
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
               st.w_session_generation != st.session_generation ||
               st.w_profile != st.profile ||
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

  if (status == 0 && operator_command) admission = v2::OPERATOR_COMMAND;

  if (status == 0 && d.command == LOAD_W) {
    // Claim/retire LOAD before any model I/O. An error consumes this epoch.
    if (!st.bound) bind_session(st, d);
    st.last_task = d.task_id; st.w_max = d.w_epoch; st.w_epoch = d.w_epoch;
    st.w_valid = false; st.w_family = d.family; st.w_layer = d.weight_layer;
    st.w_uses = 0; load_started = 1; done_task = d.task_id; error_phase = 1;
    if (!aux_header_matches(aux, c)) {
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
      for (unsigned n = 0;
           n < T * 8 && status == 0 && sf.profile == v2::STRICT; ++n)
        for (unsigned g = 0; g < G; ++g) {
          ++c.scale_checks;
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
      st.w_session_generation = st.session_generation;
      st.w_profile = st.profile;
      done_elements = T * G * 8 * 34; done_unit = 3; error_phase = 0;
    }
  }

  if (status == 0 && d.command == RUN_TILE) {
    // A8's private epoch is claimed independently of source and PS epochs.
    st.a8_max++; st.a_state = uint32_t(CacheState::FILL);
    st.last_task = d.quant_task_id;
    quant_done = d.quant_task_id; error_phase = 2;
    for (unsigned r = 0; r < d.rows && status == 0; ++r) {
      for (unsigned b = 0; b < d.K / 16; ++b) {
        const ap_uint<512> beat = activation[d.activation_base / 64 + r * (d.K / 16) + b];
        bytes(c, P_ACTIVATION, 64);
        for (unsigned half = 0; half < 2; ++half) {
#pragma HLS PIPELINE II=1
          for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
            fp[lane][2 * b + half] =
                uint32_t(beat.range(32 * (8 * half + lane) + 31,
                                    32 * (8 * half + lane)));
          }
        }
      }
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
            group[i] = f32(fp[lane][k / 8]);
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
        aq[r][g] = packed;
        as[r][g] = saved;
        ++c.quant_groups; c.quant_inputs += 32;
      }
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
            const ap_uint<256> packed = aq[r][g];
            for (unsigned j = 0; j < 8; ++j) {
              const ap_uint<32> word = packed >> (j * 32u);
              observed[kTraceQWord + (r * G + g) * 8 + j] =
                  word.to_uint();
              ++c.trace_words;
            }
          }
        for (unsigned idx = 0; idx < d.rows * G; idx += 2) {
          const unsigned r0 = idx / G, g0 = idx % G;
          const uint32_t lo = as[r0][g0];
          uint32_t hi = 0;
          if (idx + 1 < d.rows * G) {
            const unsigned r1 = (idx + 1) / G, g1 = (idx + 1) % G;
            hi = as[r1][g1];
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
      compute_cfg[224] = d.flags != 0;
      compute_cfg[225] = 1;
      writer_config.write(writer_cfg);
      compute_config.write(compute_cfg);
      cfg_sent = true;
      // Bias and every W/A group are emitted from this invocation's validated
      // caches. The clocked RTL service alone owns dot, FP, PS, bias and tile
      // output; this HLS front must never precompute oldPS or final values.
      for (unsigned tile = 0; tile < T; ++tile) {
        ap_uint<288> packet = 0;
        const unsigned lanes = tile == T - 1 ? d.N - tile * 8 : 8;
        for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
          packet.range(lane * 32 + 31, lane * 32) =
              bias_bits[lane][tile];
        }
        packet.range(264, 256) = tile;
        packet.range(272, 265) = (1u << lanes) - 1u;
        packet[273] = wd.bias_kind != 0;
        bias_tiles.write(packet);
      }
      for (unsigned r = 0; r < d.rows; ++r)
        for (unsigned g = 0; g < G; ++g)
          for (unsigned tile = 0; tile < T; ++tile) {
#pragma HLS PIPELINE II=1
            ap_uint<2816> packet = 0;
            packet.range(255, 0) = aq[r][g];
            packet.range(2335, 2304) = bits(half_to_f32(as[r][g]));
            for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
              packet.range(256 + lane * 256 + 255, 256 + lane * 256) =
                  wq[lane][tile * G + g];
              packet.range(2336 + lane * 32 + 31, 2336 + lane * 32) =
                  bits(half_to_f32(ws[lane][tile * G + g]));
            }
            const unsigned lanes = tile == T - 1 ? d.N - tile * 8 : 8;
            packet.range(2600, 2592) = tile;
            packet.range(2606, 2601) = g;
            packet.range(2608, 2607) = r;
            packet.range(2616, 2609) = (1u << lanes) - 1u;
            packet[2617] = d.flags && r == d.trace_row_local &&
                d.trace_column / 8 == tile;
            packet.range(2620, 2618) = d.trace_column % 8;
            packet[2621] = g == G - 1;
            packet.range(2653, 2622) = d.task_id;
            packet.range(2685, 2654) = d.ps_epoch;
            packet.range(2717, 2686) = d.dst.epoch;
            packet.range(2781, 2718) = d.request_id;
            group_issues.write(packet);
          }

    }
  }
  if (load_started && status != uint32_t(Status::OK) &&
      (status == uint32_t(Status::E_MODEL) ||
       status == uint32_t(Status::E_NUMERICAL))) {
    st.session_state = v2::INVALID;
    invalidate_owned_caches(st);
    first_error_owner = v2::MODEL_SESSION_ERROR;
  }
  // LOAD and rejected RUN commands have no group stream. Frame a zero-work
  // downstream command so finish can retire without an expected-group debt.
  if (!cfg_sent) {
    compute_cfg[224] = 0;
    compute_cfg[225] = 0;
    writer_config.write(writer_cfg);
    compute_config.write(compute_cfg);
  }
  // This end marker makes writer drain part of the same invocation. The
  // feedback is produced only after both output ports' physical B handshakes.
  finish.write(ap_uint<1>(1));
  const ap_uint<512> completion = writer_completion.read();
  c.total[P_OUT0] = uint64_t(completion.range(64, 1));
  c.total[P_OUT1] = uint64_t(completion.range(128, 65));
  c.retired = uint32_t(completion.range(257, 226));
  c.writes = uint32_t(completion.range(289, 258));
  c.macs = uint64_t(completion.range(353, 290));
  c.issued = uint32_t(completion.range(385, 354));
  c.trace_groups = uint32_t(completion.range(449, 418));
  c.trace_physical_words = uint32_t(completion.range(417, 386));
  if (status == uint32_t(Status::OK) && completion[129]) {
    status = uint32_t(Status::E_NUMERICAL);
    error_detail = uint32_t(completion.range(161, 130));
    bad_element = uint64_t(completion.range(225, 162));
    st.ps_state = uint32_t(CacheState::INVALID);
    st.dst_state = uint32_t(CacheState::INVALID);
  } else if (completion[0] && status == uint32_t(Status::OK)) {
    status = uint32_t(Status::E_PROTOCOL);
    error_detail = make_detail(7, uint8_t(d.op), 4);
    done_elements = 0;
    st.ps_state = uint32_t(CacheState::INVALID);
    st.dst_state = uint32_t(CacheState::INVALID);
    if (error_phase == 0) error_phase = 4;
  }
  if (linear_started && status == uint32_t(Status::OK)) {
    st.ps_state = uint32_t(CacheState::READY);
    st.dst_state = uint32_t(CacheState::READY);
    done_elements = d.rows * d.N;
    done_unit = 1;
    error_phase = 0;
    if (d.op == 0x30) {
      c.useful[P_OUT0] = uint64_t(d.rows) * d.N * 2u;
      c.useful[P_OUT1] = uint64_t(d.rows) * d.N * 2u;
    } else c.useful[P_OUT0] = uint64_t(d.rows) * d.N * 4u;
  }
  if (status != uint32_t(Status::OK) &&
      first_error_owner == v2::NO_ERROR)
    first_error_owner = admission == v2::OPERATOR_COMMAND ?
                        v2::OPERATOR_TASK_ERROR :
                        v2::DESCRIPTOR_ERROR;
  report(observed, d, st, c, status, error_detail, bad_element,
         done_task, done_elements, done_unit, quant_done, quant_status,
         linear_started, load_started, error_phase, admission,
         actual_matches_descriptor, session_reject, first_error_owner);
}
