#pragma once

#include "q8_tm1tn8_abi.h"

// Q8S2 is a distinct wire ABI. Reusing the unchanged v1 word offsets below
// does not authorize either entrypoint to accept the other's descriptor.
namespace q8_tm1tn8_v2 {

constexpr uint32_t kDescriptorWords = 256;
constexpr uint32_t kDescriptorBytes = 1024;
constexpr uint32_t kDescriptorMagic = 0x32533851u;  // "Q8S2" LE
constexpr uint32_t kDescriptorVersion = 2;
constexpr uint32_t kObservedWords = q8_tm1tn8::kObservedWords;
constexpr uint32_t kObservedMagic = 0x324f3851u;  // "Q8O2" LE
constexpr uint32_t kObservedVersion = 2;
constexpr uint32_t kBindingWords = 18;            // 64-bit AXIS beats
constexpr uint32_t kBoCount = 5;
constexpr uint32_t kBoEntryWords = 8;
constexpr uint32_t kBoEntryBytes = 32;
constexpr uint32_t kBoTableFirst = 112;
constexpr uint32_t kBoTableEnd = 152;

enum Command : uint32_t {
  LOAD_W = 0, RUN_TILE = 1, REGISTER_MODEL = 2, REVOKE_MODEL = 3
};
enum Profile : uint32_t {
  STRICT = 0, VALIDATED_STATIC_MODEL_V1 = 1
};
enum ModelSessionState : uint32_t { EMPTY = 0, ACTIVE = 1, INVALID = 2 };
enum Admission : uint32_t {
  NOT_ADMITTED = 0, SESSION_COMMAND = 1, OPERATOR_COMMAND = 2
};
enum SessionReject : uint32_t {
  SESSION_OK = 0, NO_ACTIVE = 1, GENERATION = 2, CONTEXT = 3,
  BO_BINDING = 4, DIGEST_OR_BUILD = 5, PROFILE_MISMATCH = 6,
  REGISTER_STATE = 7
};
enum BoRole : uint32_t {
  EMBEDDING = 0, W_Q0 = 2, W_Q1 = 3, W_SCALE = 4, AUX = 5
};
constexpr uint32_t kBoRoles[kBoCount] = {
    EMBEDDING, W_Q0, W_Q1, W_SCALE, AUX};

// Words 0..62 keep the v1 positions. Word 63 is no longer reserved.
enum DescriptorWord : uint32_t {
  D_DESCRIPTOR_BYTES = 63,
  D_PROFILE = 64, D_SESSION_FLAGS = 65,
  D_MODEL_SESSION_GENERATION_LO = 66,
  D_MODEL_SESSION_GENERATION_HI = 67,
  D_CONTEXT_COOKIE_0 = 68, D_CONTEXT_COOKIE_END = 72,
  D_VALIDATION_RECORD_SHA256_0 = 72,
  D_MANIFEST_SHA256_0 = 80,
  D_CANDIDATE_BUILD_SHA256_0 = 88,
  D_SOURCE_GGUF_SHA256_0 = 96,
  D_MODEL_BO_COUNT = 104, D_BO_ENTRY_BYTES = 105,
  D_BINDING_WORDS = 106, D_ZERO_107 = 107,
  D_RESERVED_108 = 108, D_BO_TABLE = kBoTableFirst,
  D_RESERVED_152 = kBoTableEnd
};

enum BoEntryWord : uint32_t {
  B_ROLE = 0, B_FLAGS = 1, B_BASE_LO = 2, B_BASE_HI = 3,
  B_BYTES_LO = 4, B_BYTES_HI = 5, B_COOKIE_LO = 6, B_COOKIE_HI = 7
};
constexpr uint32_t bo_word(uint32_t index, BoEntryWord field) {
  return kBoTableFirst + index * kBoEntryWords + uint32_t(field);
}

enum ObservedWord : uint32_t {
  O_PROFILE = 122, O_MODEL_SESSION_STATE = 123,
  O_ACTIVE_GENERATION_LO = 124, O_ACTIVE_GENERATION_HI = 125,
  O_COMMAND_ADMISSION = 126, O_BINDING_MATCH = 127,
  O_CONTEXT_COOKIE_0 = 128, O_CONTEXT_COOKIE_END = 132,
  O_REGISTERED_RECORD_SHA256_0 = 132,
  O_CANDIDATE_BUILD_SHA256_0 = 140,
  O_SCALE_CHECKS_LO = 148, O_SCALE_CHECKS_HI = 149,
  O_GENERATION_HIGH_WATER_LO = 150,
  O_GENERATION_HIGH_WATER_HI = 151,
  O_W_SESSION_GENERATION_LO = 152,
  O_W_SESSION_GENERATION_HI = 153,
  O_W_PROFILE = 154, O_FIRST_ERROR_OWNER = 155,
  O_SESSION_REJECT = 156, O_DESCRIPTOR_BYTES = 157,
  O_BINDING_WORDS = 158, O_RESERVED_BEGIN = 159
};
enum FirstErrorOwner : uint32_t {
  NO_ERROR = 0, DESCRIPTOR_ERROR = 1, MODEL_SESSION_ERROR = 2,
  OPERATOR_TASK_ERROR = 3
};

// The fixed stream is sampled from the wrapper's latched pointer values.
// Beat 0/1 are the 128-bit context cookie, beat 2 the model generation,
// then five triples of actual base, allocation bytes, allocation cookie.
enum BindingBeat : uint32_t {
  C_CONTEXT_LO = 0, C_CONTEXT_HI = 1, C_GENERATION = 2,
  C_EMBEDDING_BASE = 3
};
constexpr uint32_t binding_base_beat(uint32_t bo_index) {
  return 3 + 3 * bo_index;
}
constexpr uint32_t binding_bytes_beat(uint32_t bo_index) {
  return 4 + 3 * bo_index;
}
constexpr uint32_t binding_cookie_beat(uint32_t bo_index) {
  return 5 + 3 * bo_index;
}

static_assert(q8_tm1tn8::D_OBSERVED_WORDS == 62, "v1 prefix drift");
static_assert(q8_tm1tn8::O_ERROR_PHASE == 121, "observed prefix drift");
static_assert(kBoTableFirst + kBoCount * kBoEntryWords == kBoTableEnd,
              "five binding records must end at word 151");
static_assert(binding_cookie_beat(kBoCount - 1) == kBindingWords - 1,
              "binding stream must contain exactly 18 beats");
static_assert(uint32_t(O_RESERVED_BEGIN) <
                  uint32_t(q8_tm1tn8::O_HEADER_WORDS),
              "v2 fields must fit in observed header");
}  // namespace q8_tm1tn8_v2
