#include "laya_full_runtime.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

extern "C" void type_producer_binary_slice(const uint8_t*, const uint8_t*,
                                            uint8_t*, const uint8_t*,
                                            uint8_t*, uint8_t*, uint32_t*);

namespace {

void require(bool condition, const char* message) {
  if (!condition) {
    std::fprintf(stderr, "D2_TYPE_PRODUCER_FAIL %s\n", message);
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "open frozen input or independent reference");
  return {std::istreambuf_iterator<char>(in),
          std::istreambuf_iterator<char>()};
}

uint64_t le64(const uint8_t* bytes) {
  uint64_t value = 0;
  for (unsigned i = 0; i < 8; ++i)
    value |= uint64_t(bytes[i]) << (8 * i);
  return value;
}

void compare_all(const std::vector<uint8_t>& actual,
                 const std::vector<uint8_t>& expected, const char* message) {
  require(actual.size() == expected.size(), message);
  require(std::memcmp(actual.data(), expected.data(), actual.size()) == 0,
          message);
}

} // namespace

// Run each case in a separate process. No warm session is claimed.
int main(int argc, char** argv) {
  const char* package_arg = argc == 5 ? argv[1] :
                            std::getenv("LAYA_D2_TYPE_PACKAGE");
  const char* fixture_arg = argc == 5 ? argv[2] :
                            std::getenv("LAYA_D2_TYPE_FIXTURE");
  const char* qtype1_arg = argc == 5 ? argv[3] :
                            std::getenv("LAYA_D2_TYPE_QTYPE1_DIR");
  const char* which_arg = argc == 5 ? argv[4] :
                           std::getenv("LAYA_D2_TYPE_CASE");
  require(package_arg && fixture_arg && qtype1_arg && which_arg,
          "PACKAGE FIXTURE QTYPE1_DIR qtype2|qtype1 arguments or environment");
  const std::string package = package_arg, fixture = fixture_arg,
                    qtype1_dir = qtype1_arg, which = which_arg;
  require(which == "qtype2" || which == "qtype1", "cold case name");
  const unsigned type_id = which == "qtype2" ? 2u : 1u;
  const auto hidden_input = read_file(fixture + "/type_src0.f32.bin");
  const auto embedding = read_file(package + "/embedding.bin");
  const auto aux = read_file(package + "/aux.bin");
  const auto request = read_file(which == "qtype2" ?
      fixture + "/request.bin" : qtype1_dir + "/qtype1_request.bin");
  const auto gold = read_file(which == "qtype2" ?
      fixture + "/type_gold.f32.bin" : qtype1_dir + "/qtype1_gold.f32.bin");
  std::vector<uint8_t> selected_row;
  if (which == "qtype2") {
    const auto all_reference_rows =
        read_file(fixture + "/type_rows.f32.bin");
    require(all_reference_rows.size() == 12288, "frozen reference rows");
    selected_row.assign(all_reference_rows.begin() + 8192,
                        all_reference_rows.begin() + 12288);
  } else {
    selected_row = read_file(qtype1_dir + "/qtype1_row_reference.f32.bin");
  }
  require(hidden_input.size() == 262144 && gold.size() == 262144 &&
          selected_row.size() == 4096, "64 by 1024 reference spans");
  require(embedding.size() == 54803648 && aux.size() == 1671872 &&
          request.size() == 832, "bound package and request spans");
  require(request[20] == 1 && request[21] == 0 &&
          request[22] == 64 && request[23] == 0 &&
          request[768] == type_id && request[769] == 0 &&
          request[770] == 0 && request[771] == 0,
          "B1/S64 request with selected qtype");
  require(le64(request.data() + 24) != 0 &&
          le64(request.data() + 32) != 0, "cold identity fields");

  std::vector<uint8_t> io(32768, 0);
  std::memcpy(io.data(), request.data(), request.size());
  const auto original_io = io;
  std::vector<uint8_t> state0(16920576, 0xa5),
                       state1(16919104, 0xa5);
  std::array<uint32_t, 32> observed;
  observed.fill(0xdeadbeefu);
  type_producer_binary_slice(hidden_input.data(), embedding.data(),
                             io.data(), aux.data(), state0.data(),
                             state1.data(), observed.data());

  require(observed[0] == uint32_t(laya::Status::OK) &&
          observed[1] == 0 && observed[2] == 5 && observed[9] == 0,
          "successful original Controller method and cleanup");
  require(observed[3] == 5 && observed[4] == 5 && observed[5] == 3 &&
          observed[11] == 1 && observed[12] == 4,
          "one EMB_TYPE, four binary ADD_TYPE, three owner claims");
  require(observed[6] == uint32_t(laya::Buffer::HIDDEN) &&
          observed[7] == 1 && observed[8] == 1 &&
          observed[13] == type_id &&
          observed[14] == uint32_t(le64(request.data() + 24)) &&
          observed[15] == uint32_t(le64(request.data() + 32)),
          "actual type, request and fresh opposite HIDDEN ref");
  require(observed[16] == 0 &&
          observed[17] == uint32_t(laya::CacheState::READY) &&
          observed[18] == 1 && observed[19] == 0xffffffffu &&
          observed[20] == 0xffffffffu,
          "all 64 output rows published");
  require(observed[10] == 0 && observed[21] == 0 &&
          observed[22] == uint32_t(laya::CacheState::FREE) &&
          observed[23] == 0 && observed[24] == 0,
          "selected TYPE_ROWS owner released after binary consumers");
  require(observed[25] == 0 &&
          observed[26] == uint32_t(laya::CacheState::FREE) &&
          observed[27] == 0 && observed[28] == 0 &&
          observed[29] == uint32_t(laya::Buffer::HIDDEN) &&
          observed[30] == 0 && observed[31] == 1,
          "external ingress owner released after binary consumers");

  std::vector<uint8_t> expected0(state0.size(), 0xa5),
                       expected1(state1.size(), 0xa5);
  std::memcpy(expected0.data(), hidden_input.data(), hidden_input.size());
  std::memcpy(expected0.data() + 16908288u + type_id * 4096u,
              selected_row.data(), selected_row.size());
  std::memcpy(expected1.data(), gold.data(), gold.size());
  compare_all(state0, expected0,
              "ingress, exact produced type row and both unused row sentinels");
  compare_all(state1, expected1,
              "all 65536 binary32 outputs and untouched destination bytes");
  compare_all(io, original_io, "input request and IO tail untouched");
  std::printf("D2_TYPE_PRODUCER_CPU_PASS qtype=%u tasks=5 words=65536\n",
              type_id);
  return 0;
}
