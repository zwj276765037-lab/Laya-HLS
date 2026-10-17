#include "q8_session_encoder_v2.h"

#include <algorithm>
#include <cstring>
#include <limits>
#include <stdexcept>

namespace laya::q8_session_v2 {
namespace {

void require(bool value, const char* reason) {
  if (!value) throw std::invalid_argument(reason);
}

void word(Descriptor& bytes, unsigned index, uint32_t value) {
  for (unsigned b = 0; b < 4; ++b)
    bytes[4 * index + b] = uint8_t(value >> (8 * b));
}
void wide(Descriptor& bytes, unsigned index, uint64_t value) {
  word(bytes, index, uint32_t(value));
  word(bytes, index + 1, uint32_t(value >> 32));
}
void fixed(Descriptor& bytes, unsigned index, const uint8_t* input,
           size_t count) {
  std::memcpy(bytes.data() + 4 * index, input, count);
}
bool nonzero(const uint8_t* data, size_t size) {
  for (size_t i = 0; i < size; ++i) if (data[i]) return true;
  return false;
}
bool empty_operator(const Operator& op) {
  for (uint32_t value : op.request_and_task_words) if (value) return false;
  return op.flags == 0 && op.activation_base == 0 && op.out0_base == 0 &&
         op.out1_base == 0 && op.activation_span == 0 && op.out0_span == 0 &&
         op.out1_span == 0 && op.trace_row_local == 0 && op.trace_column == 0;
}
void check_session(const Session& session) {
  using namespace q8_tm1tn8_v2;
  require(session.model_generation != 0, "zero model generation");
  require(session.profile == STRICT ||
              session.profile == VALIDATED_STATIC_MODEL_V1,
          "invalid profile");
  require(nonzero(session.context_cookie.data(), session.context_cookie.size()),
          "zero context cookie");
  require(nonzero(session.validation_record_sha256.data(), 32) &&
              nonzero(session.manifest_sha256.data(), 32) &&
              nonzero(session.candidate_build_sha256.data(), 32) &&
              nonzero(session.source_gguf_sha256.data(), 32),
          "missing full identity digest");
  for (const auto& tag : session.tags)
    require(nonzero(tag.data(), tag.size()), "zero package tag");
  require(std::equal(session.candidate_build_sha256.begin(),
                     session.candidate_build_sha256.begin() + 16,
                     session.tags[3].begin()), "build tag/digest mismatch");
  require(std::equal(session.source_gguf_sha256.begin(),
                     session.source_gguf_sha256.begin() + 16,
                     session.tags[0].begin()), "model tag/source mismatch");
  for (size_t i = 0; i < session.model.size(); ++i) {
    const auto& bo = session.model[i];
    require(bo.readonly && bo.device_base != 0 &&
                (bo.device_base & 63) == 0 && bo.bytes != 0 &&
                bo.allocation_cookie != 0 &&
                bo.bytes <= std::numeric_limits<uint64_t>::max() - bo.device_base,
            "invalid live model BO");
    for (size_t j = 0; j < i; ++j) {
      const auto& prior = session.model[j];
      require(bo.allocation_cookie != prior.allocation_cookie,
              "reused model allocation cookie");
      require(bo.device_base >= prior.device_base + prior.bytes ||
                  prior.device_base >= bo.device_base + bo.bytes,
              "overlapping model BO addresses");
    }
  }
}
}  // namespace

Descriptor encode(const Session& session, q8_tm1tn8_v2::Command command,
                  const Operator& op, size_t descriptor_bo_bytes,
                  size_t observed_bo_bytes) {
  using namespace q8_tm1tn8_v2;
  require(descriptor_bo_bytes >= kDescriptorBytes,
          "descriptor BO shorter than 1024 bytes");
  require(observed_bo_bytes >= kObservedWords * sizeof(uint32_t),
          "observed BO shorter than 131072 bytes");
  check_session(session);
  require(command <= REVOKE_MODEL, "invalid v2 command");
  const bool management = command == REGISTER_MODEL || command == REVOKE_MODEL;
  require(!management || empty_operator(op), "management command has task data");
  require(management || (op.flags & ~1u) == 0,
          "operator flags outside trace bit");
  Descriptor bytes{};
  word(bytes, 0, kDescriptorMagic);
  word(bytes, 1, kDescriptorVersion);
  word(bytes, 2, command);
  word(bytes, 3, op.flags);
  if (!management) {
    for (size_t i = 0; i < op.request_and_task_words.size(); ++i)
      word(bytes, 4 + i, op.request_and_task_words[i]);
    wide(bytes, 48, op.activation_base);
    wide(bytes, 50, op.out0_base);
    wide(bytes, 52, op.out1_base);
    wide(bytes, 54, op.activation_span);
    wide(bytes, 56, op.out0_span);
    wide(bytes, 58, op.out1_span);
    word(bytes, 60, op.trace_row_local);
    word(bytes, 61, op.trace_column);
  }
  for (size_t i = 0; i < 4; ++i)
    fixed(bytes, 32 + 4 * i, session.tags[i].data(), 16);
  word(bytes, 62, kObservedWords);
  word(bytes, D_DESCRIPTOR_BYTES, kDescriptorBytes);
  word(bytes, D_PROFILE, session.profile);
  wide(bytes, D_MODEL_SESSION_GENERATION_LO, session.model_generation);
  fixed(bytes, D_CONTEXT_COOKIE_0, session.context_cookie.data(), 16);
  fixed(bytes, D_VALIDATION_RECORD_SHA256_0,
        session.validation_record_sha256.data(), 32);
  fixed(bytes, D_MANIFEST_SHA256_0, session.manifest_sha256.data(), 32);
  fixed(bytes, D_CANDIDATE_BUILD_SHA256_0,
        session.candidate_build_sha256.data(), 32);
  fixed(bytes, D_SOURCE_GGUF_SHA256_0,
        session.source_gguf_sha256.data(), 32);
  word(bytes, D_MODEL_BO_COUNT, kBoCount);
  word(bytes, D_BO_ENTRY_BYTES, kBoEntryBytes);
  word(bytes, D_BINDING_WORDS, kBindingWords);
  for (size_t i = 0; i < kBoCount; ++i) {
    const unsigned base = kBoTableFirst + i * kBoEntryWords;
    word(bytes, base, kBoRoles[i]);
    word(bytes, base + 1, 1);  // Read-only model allocation.
    wide(bytes, base + 2, session.model[i].device_base);
    wide(bytes, base + 4, session.model[i].bytes);
    wide(bytes, base + 6, session.model[i].allocation_cookie);
  }
  return bytes;
}

Binding binding_from_live_bos(const Session& session) {
  using namespace q8_tm1tn8_v2;
  check_session(session);
  Binding beats{};
  for (unsigned i = 0; i < 8; ++i) {
    beats[0] |= uint64_t(session.context_cookie[i]) << (8 * i);
    beats[1] |= uint64_t(session.context_cookie[8 + i]) << (8 * i);
  }
  beats[2] = session.model_generation;
  for (size_t i = 0; i < kBoCount; ++i) {
    beats[binding_base_beat(i)] = session.model[i].device_base;
    beats[binding_bytes_beat(i)] = session.model[i].bytes;
    beats[binding_cookie_beat(i)] = session.model[i].allocation_cookie;
  }
  return beats;
}

}  // namespace laya::q8_session_v2
