#include "../host/q8_session_encoder_v2.h"

#include <cassert>
#include <stdexcept>

namespace {
uint32_t word(const laya::q8_session_v2::Descriptor& bytes, unsigned index) {
  uint32_t value = 0;
  for (unsigned i = 0; i < 4; ++i) value |= uint32_t(bytes[4 * index + i]) << (8 * i);
  return value;
}
template <typename F> void rejected(F action) {
  bool threw = false;
  try { action(); } catch (const std::invalid_argument&) { threw = true; }
  assert(threw);
}
}  // namespace

int main() {
  using namespace laya::q8_session_v2;
  namespace wire = q8_tm1tn8_v2;
  Session session;
  for (unsigned t = 0; t < 4; ++t)
    for (unsigned b = 0; b < 16; ++b) session.tags[t][b] = uint8_t(1 + 16*t + b);
  session.source_gguf_sha256[0] = session.tags[0][0];
  session.candidate_build_sha256[0] = session.tags[3][0];
  for (unsigned b = 1; b < 16; ++b) {
    session.source_gguf_sha256[b] = session.tags[0][b];
    session.candidate_build_sha256[b] = session.tags[3][b];
  }
  session.validation_record_sha256[0] = 1;
  session.manifest_sha256[0] = 2;
  session.context_cookie[0] = 3;
  session.model_generation = 7;
  session.profile = wire::VALIDATED_STATIC_MODEL_V1;
  for (unsigned i = 0; i < 5; ++i)
    session.model[i] = {0x100000u + i * 0x1000u, 0x800u, 9u + i, true};
  Operator empty;
  auto register_bytes = encode(session, wire::REGISTER_MODEL, empty, 1024, 131072);
  assert(word(register_bytes, 0) == wire::kDescriptorMagic);
  assert(word(register_bytes, 2) == wire::REGISTER_MODEL);
  assert(word(register_bytes, 63) == 1024);
  assert(word(register_bytes, 64) == wire::VALIDATED_STATIC_MODEL_V1);
  assert(word(register_bytes, 66) == 7);
  assert(word(register_bytes, 104) == 5 && word(register_bytes, 106) == 18);
  assert(word(register_bytes, 112) == wire::EMBEDDING);
  assert(word(register_bytes, 120) == wire::W_Q0);
  assert(word(register_bytes, 152) == 0 && word(register_bytes, 255) == 0);
  for (unsigned i = 4; i < 32; ++i) assert(word(register_bytes, i) == 0);
  for (unsigned i = 48; i < 62; ++i) assert(word(register_bytes, i) == 0);
  auto beats = binding_from_live_bos(session);
  assert(beats[2] == 7 && beats[3] == session.model[0].device_base &&
         beats[17] == session.model[4].allocation_cookie);

  Operator run;
  run.request_and_task_words[0] = 0x12345678;
  run.request_and_task_words[4] = 5;
  run.flags = 1;
  run.activation_base = 0x1234000;
  run.activation_span = 1024;
  auto run_bytes = encode(session, wire::RUN_TILE, run, 1024, 131072);
  assert(word(run_bytes, 2) == wire::RUN_TILE && word(run_bytes, 3) == 1);
  assert(word(run_bytes, 4) == 0x12345678 && word(run_bytes, 8) == 5);
  assert(word(run_bytes, 48) == 0x1234000 && word(run_bytes, 54) == 1024);

  rejected([&] { encode(session, wire::RUN_TILE, run, 1023, 131072); });
  rejected([&] { encode(session, wire::RUN_TILE, run, 1024, 131071); });
  rejected([&] { encode(session, wire::REGISTER_MODEL, run, 1024, 131072); });
  session.model[1].device_base = session.model[0].device_base;
  rejected([&] { encode(session, wire::RUN_TILE, run, 1024, 131072); });
  return 0;
}
