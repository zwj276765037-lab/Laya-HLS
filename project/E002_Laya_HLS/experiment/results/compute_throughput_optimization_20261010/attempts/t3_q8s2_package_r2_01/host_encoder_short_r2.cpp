#include "laya_model_layout_generated.h"
#include "q8_session_encoder_v2.h"

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <stdexcept>

namespace {
uint32_t word(const laya::q8_session_v2::Descriptor& bytes, unsigned index) {
  uint32_t result = 0;
  for (unsigned i = 0; i < 4; ++i)
    result |= uint32_t(bytes[4 * index + i]) << (8 * i);
  return result;
}

template <typename F> void expect_rejected(F action) {
  bool rejected = false;
  try {
    action();
  } catch (const std::invalid_argument&) {
    rejected = true;
  }
  assert(rejected);
}
}  // namespace

int main() {
  using namespace laya::q8_session_v2;
  namespace wire = q8_tm1tn8_v2;
  Session session;
  const uint8_t* tags[] = {laya::full::kFullModelTag,
                           laya::full::kFullNumericTag,
                           laya::full::kFullLayoutTag,
                           laya::full::kFullBuildTag};
  for (unsigned i = 0; i < 4; ++i)
    std::copy_n(tags[i], 16, session.tags[i].begin());
  std::copy_n(laya::full::kFullBuildSha256, 32,
              session.candidate_build_sha256.begin());
  std::copy_n(laya::full::kFullSourceSha256, 32,
              session.source_gguf_sha256.begin());
  session.validation_record_sha256[0] = 1;
  session.manifest_sha256[0] = 2;
  session.context_cookie[0] = 3;
  session.model_generation = 2;
  session.profile = wire::VALIDATED_STATIC_MODEL_V1;
  for (unsigned i = 0; i < 5; ++i)
    session.model[i] = {0x20000000ull * (i + 1),
                        laya::full::kFullModelBoSizes[i], i + 1, true};

  Operator empty;
  constexpr size_t descriptor_bytes = wire::kDescriptorBytes;
  constexpr size_t observed_bytes = wire::kObservedWords * sizeof(uint32_t);
  auto bytes = encode(session, wire::REGISTER_MODEL, empty,
                      descriptor_bytes, observed_bytes);
  assert(word(bytes, wire::D_MODEL_SESSION_GENERATION_LO) == 2);
  assert(word(bytes, wire::D_MODEL_SESSION_GENERATION_LO + 1) == 0);
  assert(word(bytes, wire::D_PROFILE) == wire::VALIDATED_STATIC_MODEL_V1);
  assert(std::equal(laya::full::kFullBuildSha256,
                    laya::full::kFullBuildSha256 + 32,
                    bytes.begin() + 4 * wire::D_CANDIDATE_BUILD_SHA256_0));
  assert(std::equal(laya::full::kFullBuildTag,
                    laya::full::kFullBuildTag + 16,
                    bytes.begin() + 4 * 44));
  assert(std::equal(laya::full::kFullSourceSha256,
                    laya::full::kFullSourceSha256 + 32,
                    bytes.begin() + 4 * wire::D_SOURCE_GGUF_SHA256_0));
  auto binding = binding_from_live_bos(session);
  assert(binding[2] == 2);
  for (unsigned i = 0; i < 5; ++i)
    assert(binding[wire::binding_bytes_beat(i)] ==
           laya::full::kFullModelBoSizes[i]);

  expect_rejected([&] {
    encode(session, wire::REGISTER_MODEL, empty,
           descriptor_bytes - 1, observed_bytes);
  });
  expect_rejected([&] {
    encode(session, wire::REGISTER_MODEL, empty,
           descriptor_bytes, observed_bytes - 1);
  });
  std::cout << "PASS r2_header_build_sha32_generation2_binding18_short_descriptor_observed\n";
}
