#include "laya_frontend_observed.h"
#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

#include <array>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

extern "C" void laya_frontend_chain(const uint8_t*, uint8_t*,
                                     const uint8_t*, uint8_t*, uint8_t*,
                                     uint32_t*);

namespace {
using namespace laya;
using namespace laya::full::front_observed;

[[noreturn]] void fail(const std::string& what) {
  std::cerr << "FRONTEND_CHAIN_CSIM_FAIL " << what << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& what) {
  if (!condition) fail(what);
}
std::string env(const char* name) {
  const char* value = std::getenv(name);
  require(value && *value, std::string("missing ") + name);
  return value;
}
std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "open " + path);
  return {std::istreambuf_iterator<char>(stream),
          std::istreambuf_iterator<char>()};
}
uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
void equals(uint32_t actual, uint32_t expected, const std::string& name) {
  if (actual != expected)
    fail(name + " expected=" + std::to_string(expected) +
         " actual=" + std::to_string(actual));
}
void compare_payload(const std::vector<uint8_t>& state,
                     const std::vector<uint8_t>& gold,
                     const char* name) {
  require(gold.size() == 128u * 1024u * 4u,
          std::string(name) + " independent oracle length");
  for (unsigned row = 0; row < 128; ++row)
    for (unsigned col = 0; col < 1024; ++col) {
      const size_t offset = (size_t(row) * 1024 + col) * 4;
      const uint32_t actual = le32(state.data() + offset);
      const uint32_t expected = le32(gold.data() + offset);
      if (actual != expected)
        fail(std::string(name) + " row=" + std::to_string(row) +
             " col=" + std::to_string(col) + " expected_bits=" +
             std::to_string(expected) + " actual_bits=" +
             std::to_string(actual));
    }
  for (size_t offset = gold.size(); offset < state.size(); ++offset)
    if (state[offset] != 0xa5)
      fail(std::string(name) + " write outside B1 physical row extent byte=" +
           std::to_string(offset));
}
void check_owner(const std::array<uint32_t, kWords>& obs,
                 unsigned ordinal, Buffer id, unsigned bank,
                 CacheState state, bool valid, unsigned rows,
                 unsigned batch, const std::vector<uint8_t>& request) {
  const unsigned base = kGlobalWords + ordinal * kOwnerWords;
  auto field = [&](unsigned offset) { return obs[base + offset]; };
  equals(field(FOUND), 1, "owner found " + std::to_string(ordinal));
  equals(field(REF_ID), uint8_t(id), "owner id");
  equals(field(REF_BANK), bank, "owner bank");
  equals(field(REF_EPOCH), 1, "owner epoch");
  equals(field(MAX_CLAIMED_EPOCH), 1, "owner max epoch");
  equals(field(REGION), 0, "owner region");
  equals(field(STAGE), 1, "owner stage");
  equals(field(LAYER), 255, "owner layer");
  equals(field(BATCH), batch, "owner batch");
  equals(field(ROW_SPACE), id == Buffer::LN_GAMMA ?
         uint8_t(RowSpace::BATCH) : uint8_t(RowSpace::TOKEN),
         "owner row space");
  equals(field(ROW0), 0, "owner row0");
  equals(field(ROWS), rows, "owner rows");
  equals(field(WIDTH), 1024, "owner width");
  equals(field(CONTENT), uint8_t(Content::F32), "owner content");
  equals(field(STATE), uint8_t(state), "owner state");
  equals(field(READERS), 0, "owner readers");
  equals(field(VALID), valid, "owner valid");
  equals(field(IDENTITY_B), 1, "owner identity B");
  equals(field(IDENTITY_S), 128, "owner identity S");
  equals(field(IDENTITY_REQUEST_LO), 3, "owner request id");
  equals(field(IDENTITY_REQUEST_HI), 0, "owner request id high");
  equals(field(IDENTITY_GENERATION_LO), 1, "owner generation");
  equals(field(IDENTITY_GENERATION_HI), 0, "owner generation high");
  for (unsigned word = 0; word < 4; ++word) {
    equals(field(MODEL_TAG0 + word), le32(request.data() + 40 + 4 * word),
           "owner model tag");
    equals(field(NUMERIC_TAG0 + word), le32(request.data() + 56 + 4 * word),
           "owner numeric tag");
    equals(field(LAYOUT_TAG0 + word), le32(request.data() + 72 + 4 * word),
           "owner layout tag");
    equals(field(BUILD_TAG0 + word), le32(request.data() + 88 + 4 * word),
           "owner build tag");
  }
  for (unsigned word = 0; word < 64; ++word) {
    const uint32_t expected = id == Buffer::HIDDEN && bank == 1 ?
        (word < 4 ? UINT32_MAX : 0) :
        id == Buffer::LN_GAMMA && word == 0 ? 1 : 0;
    equals(field(COVERAGE0 + word), expected, "owner coverage word=" +
           std::to_string(word));
  }
}
} // namespace

int main() {
  const std::string package = env("LAYA_FRONT_PACKAGE");
  const std::string request_path = env("LAYA_FRONT_REQUEST");
  const std::string oracle = env("LAYA_FRONT_ORACLE");
  const auto embedding = read_file(package + "/embedding.bin");
  const auto aux = read_file(package + "/aux.bin");
  const auto request = read_file(request_path);
  const auto raw_gold = read_file(oracle + "/embedding_raw.f32.bin");
  const auto norm_gold = read_file(oracle + "/embedding_norm.f32.bin");
  require(embedding.size() == laya::full::kFullModelBoSizes[0] &&
          aux.size() == laya::full::kFullModelBoSizes[4] &&
          request.size() == 1152 &&
          std::memcmp(request.data(), "LYRQ", 4) == 0 &&
          request[20] == 1 && request[22] == 128 &&
          request[24] == 3 && request[32] == 1,
          "frozen B1_from_b0_S128 request and production model");
  std::vector<uint8_t> io(32768, 0xa5);
  std::memcpy(io.data(), request.data(), request.size());
  const auto original_io = io;
  std::vector<uint8_t> state0(16920576u, 0xa5),
      state1(16919104u, 0xa5);
  std::array<uint32_t, kWords> obs;
  obs.fill(0xa5a5a5a5);
  laya_frontend_chain(embedding.data(), io.data(), aux.data(),
                      state0.data(), state1.data(), obs.data());
  require(io == original_io, "IO/request unchanged; no LYRS success frame");
  equals(obs[MAGIC], kMagic, "observation magic");
  equals(obs[VERSION], kVersion, "observation version");
  equals(obs[WORDS], kWords, "observation word count");
  equals(obs[STATUS], 0, "execution status");
  equals(obs[DETAIL], 0, "execution detail");
  equals(obs[LAST_EXEC_STATUS], 0, "last execution status");
  equals(obs[LAST_CLEANUP_STATUS], 0, "cleanup status");
  equals(obs[REQUEST_VALID], 1, "request valid");
  equals(obs[MODEL_HEADER_VALID], 1, "model header valid");
  equals(obs[DIAGNOSTIC_IDENTITY_VALID], 1, "diagnostic identity valid");
  equals(obs[DIAGNOSTIC_SHAPE_VALID], 1, "diagnostic shape valid");
  equals(obs[DIAGNOSTIC_REQUEST_LO], 3, "diagnostic request");
  equals(obs[DIAGNOSTIC_GENERATION_LO], 1, "diagnostic generation");
  equals(obs[DIAGNOSTIC_B], 1, "diagnostic B");
  equals(obs[DIAGNOSTIC_S], 128, "diagnostic S");
  equals(obs[INPUT_REQUEST_LO], 3, "input request");
  equals(obs[INPUT_GENERATION_LO], 1, "input generation");
  equals(obs[INPUT_B], 1, "input B");
  equals(obs[INPUT_S], 128, "input S");
  equals(obs[SESSION_GENERATION_LO], 1, "session generation");
  equals(obs[LAST_ACCEPTED_REQUEST_LO], 3, "accepted request");
  equals(obs[TASKS_RETIRED], 17, "tasks retired");
  equals(obs[LAST_TASK_ID], 17, "last task id");
  equals(obs[OWNER_CLAIMS], 3, "owner claims");
  // Production owner_leases counts exclusive in-place leases. The eight
  // LayerNorm tasks also acquire/release 16 transient read leases, which
  // leave this counter at zero and all final reader counts at zero.
  equals(obs[OWNER_LEASES], 0, "exclusive owner leases");
  equals(obs[EMB_TOKEN_CALLS], 8, "embedding calls");
  equals(obs[LOAD_LN_PARAMS_CALLS], 1, "gamma load calls");
  equals(obs[LN_EMB_CALLS], 8, "norm calls");
  equals(obs[ENCODER_LAYERS], 0, "encoder count");
  equals(obs[DECISION_LAYERS], 0, "decision count");
  equals(obs[OUTPUT_ID], uint8_t(Buffer::HIDDEN), "output id");
  equals(obs[OUTPUT_BANK], 1, "output bank");
  equals(obs[OUTPUT_EPOCH], 1, "output epoch");
  equals(obs[OUTPUT_REGION], 0, "output region");
  equals(obs[OUTPUT_STAGE], 1, "output stage");
  equals(obs[OUTPUT_LAYER], 255, "output layer");
  equals(obs[OUTPUT_BATCH], 255, "output batch");
  equals(obs[OUTPUT_ROW_SPACE], uint8_t(RowSpace::TOKEN), "output row space");
  equals(obs[OUTPUT_ROW0], 0, "output row0");
  equals(obs[OUTPUT_ROWS], 128, "output rows");
  equals(obs[OUTPUT_WIDTH], 1024, "output width");
  equals(obs[OUTPUT_CONTENT], uint8_t(Content::F32), "output content");
  equals(obs[LIVE_READERS], 0, "live readers");
  equals(obs[INCOMPLETE_OWNERS], 0, "incomplete owners");
  check_owner(obs, 0, Buffer::HIDDEN, 0, CacheState::FREE, false,
              128, 255, request);
  check_owner(obs, 1, Buffer::LN_GAMMA, 0, CacheState::READY, true,
              1, 0, request);
  check_owner(obs, 2, Buffer::HIDDEN, 1, CacheState::READY, true,
              128, 255, request);
  compare_payload(state0, raw_gold, "embedding_raw");
  compare_payload(state1, norm_gold, "embedding_norm");
  std::cout << "FRONTEND_CHAIN_CSIM_PASS B=1 S=128 tasks=17 "
               "raw_f32=131072 norm_f32=131072 claims=3 "
               "exclusive_leases=0 source_expected_read_pairs=16\n";
}
