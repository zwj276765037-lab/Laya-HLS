// Host-only binary bridge for P2 leaf functions. Expected values are computed
// solely by tests/full_reference.py; this file does not make expected outputs.
#include "laya_full_numeric.h"

#include <cfenv>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <limits>
#include <string>
#include <vector>
#if defined(__SSE__)
#include <xmmintrin.h>
#endif

namespace {
static float x1024[1024], y1024[1024], z1024[1024];
static float x4096[4096], y4096[4096], x5248[5248], y2624[2624];
static float q[64], keys[1024][64], values[1024][64];
static float cosine[64], sine[64], y64[64];
static float x1028[1028], y256[256], x16[16], y16[16], stats[4];
static uint16_t half_weights[256][1028];
static uint8_t mask1024[1024], raw1088[1088];

[[noreturn]] void fail(const std::string& message) {
  std::cerr << "FULL_CLI_FAIL " << message << '\n';
  std::exit(1);
}

unsigned number(const char* text, unsigned maximum) {
  try {
    size_t used = 0;
    const unsigned long value = std::stoul(text, &used, 0);
    if (text[used] || value > maximum) fail("invalid integer argument");
    return static_cast<unsigned>(value);
  } catch (...) { fail("invalid integer argument"); }
}

std::vector<uint8_t> read_file(const char* path, size_t expected) {
  std::ifstream stream(path, std::ios::binary);
  if (!stream) fail(std::string("open ") + path);
  std::vector<uint8_t> bytes((std::istreambuf_iterator<char>(stream)),
                             std::istreambuf_iterator<char>());
  if (bytes.size() != expected) fail("input size");
  return bytes;
}

void write_file(const char* path, const float* data, size_t count) {
  std::ofstream stream(path, std::ios::binary);
  if (!stream) fail(std::string("write ") + path);
  stream.write(reinterpret_cast<const char*>(data), std::streamsize(count * 4));
  if (!stream) fail("output write");
}

void copy_at(void* target, const std::vector<uint8_t>& bytes,
             size_t offset, size_t count) {
  if (offset > bytes.size() || count > bytes.size() - offset) fail("input slice");
  std::memcpy(target, bytes.data() + offset, count);
}

void checked(laya::Check status) {
  if (!status) {
    std::cerr << "FULL_CLI_CHECK code=" << unsigned(status.code)
              << " detail=" << status.detail
              << " element=" << status.bad_element << '\n';
    std::exit(2);
  }
}
}  // namespace

int main(int argc, char** argv) {
  if (argc < 4) fail("usage: full_cli op input_blob output_blob [parameters]");
  const uint16_t endian = 1;
  if (*reinterpret_cast<const uint8_t*>(&endian) != 1 || sizeof(float) != 4)
    fail("host must be little-endian IEEE F32");
  if (std::fegetround() != FE_TONEAREST) fail("host is not RNE");
#if defined(__SSE__)
  if (_mm_getcsr() & ((1u << 15) | (1u << 6))) fail("FTZ/DAZ enabled");
#endif

  const std::string op = argv[1];
  size_t output_count = 0;
  const float* output = nullptr;
  if (op == "embedding") {
    if (argc != 4) fail("embedding arguments");
    auto bytes = read_file(argv[2], 1088);
    copy_at(raw1088, bytes, 0, 1088);
    checked(laya::full::embedding_row(raw1088, y1024));
    output = y1024; output_count = 1024;
  } else if (op == "rope") {
    if (argc != 4) fail("rope arguments");
    auto bytes = read_file(argv[2], 3 * 64 * 4);
    copy_at(q, bytes, 0, 64 * 4);
    copy_at(cosine, bytes, 64 * 4, 64 * 4);
    copy_at(sine, bytes, 2 * 64 * 4, 64 * 4);
    checked(laya::full::rope_head(q, cosine, sine, y64));
    output = y64; output_count = 64;
  } else if (op == "qk") {
    if (argc != 7) fail("qk arguments: S query sliding");
    const unsigned S = number(argv[4], 1024);
    const unsigned query = number(argv[5], 1023);
    const unsigned sliding = number(argv[6], 1);
    auto bytes = read_file(argv[2], 64 * 4 + S * 64 * 4 + S);
    copy_at(q, bytes, 0, 64 * 4);
    copy_at(keys, bytes, 64 * 4, S * 64 * 4);
    copy_at(mask1024, bytes, 64 * 4 + S * 64 * 4, S);
    checked(laya::full::qk_row(q, keys, mask1024,
                               uint16_t(S), uint16_t(query), sliding != 0, z1024));
    output = z1024; output_count = S;
  } else if (op == "softmax") {
    if (argc != 5) fail("softmax arguments: length");
    const unsigned length = number(argv[4], 1024);
    auto bytes = read_file(argv[2], length * 4);
    copy_at(x1024, bytes, 0, length * 4);
    checked(laya::full::softmax_row(x1024, uint16_t(length), z1024));
    output = z1024; output_count = length;
  } else if (op == "av") {
    if (argc != 5) fail("av arguments: S");
    const unsigned S = number(argv[4], 1024);
    auto bytes = read_file(argv[2], S * 4 + S * 64 * 4);
    copy_at(x1024, bytes, 0, S * 4);
    copy_at(values, bytes, S * 4, S * 64 * 4);
    checked(laya::full::av_row(x1024, values, uint16_t(S), y64));
    output = y64; output_count = 64;
  } else if (op == "fp_scorer") {
    if (argc != 4) fail("fp_scorer arguments");
    auto bytes = read_file(argv[2], (1024 + 1024 + 1) * 4);
    copy_at(x1024, bytes, 0, 1024 * 4);
    copy_at(y1024, bytes, 1024 * 4, 1024 * 4);
    float bias;
    copy_at(&bias, bytes, 2048 * 4, 4);
    checked(laya::full::fp_scorer_row(x1024, y1024, bias, z1024[0]));
    output = z1024; output_count = 1;
  } else if (op == "fp_act") {
    if (argc != 4) fail("fp_act arguments");
    auto bytes = read_file(argv[2], 1028 * 4 + 256 * 1028 * 2);
    copy_at(x1028, bytes, 0, 1028 * 4);
    copy_at(half_weights, bytes, 1028 * 4, 256 * 1028 * 2);
    checked(laya::full::fp_act_row(x1028, half_weights, y256));
    output = y256; output_count = 256;
  } else if (op == "gelu") {
    if (argc != 4) fail("gelu arguments");
    auto bytes = read_file(argv[2], 4);
    copy_at(x1024, bytes, 0, 4);
    checked(laya::full::gelu_scalar(x1024[0], y1024[0]));
    output = y1024; output_count = 1;
  } else if (op == "geglu") {
    if (argc != 4) fail("geglu arguments");
    auto bytes = read_file(argv[2], 5248 * 4);
    copy_at(x5248, bytes, 0, 5248 * 4);
    checked(laya::full::geglu_row(x5248, y2624));
    output = y2624; output_count = 2624;
  } else if (op == "relu") {
    if (argc != 4) fail("relu arguments");
    auto bytes = read_file(argv[2], 4096 * 4);
    copy_at(x4096, bytes, 0, 4096 * 4);
    checked(laya::full::relu_row(x4096, y4096));
    output = y4096; output_count = 4096;
  } else if (op == "add") {
    if (argc != 4) fail("add arguments");
    auto bytes = read_file(argv[2], 2048 * 4);
    copy_at(x1024, bytes, 0, 1024 * 4);
    copy_at(y1024, bytes, 1024 * 4, 1024 * 4);
    checked(laya::full::add_row(x1024, y1024, z1024));
    output = z1024; output_count = 1024;
  } else if (op == "bias_gelu") {
    if (argc != 5) fail("bias_gelu arguments: length");
    const unsigned length = number(argv[4], 1024);
    auto bytes = read_file(argv[2], length * 8);
    copy_at(x1024, bytes, 0, length * 4);
    copy_at(y1024, bytes, length * 4, length * 4);
    checked(laya::full::bias_gelu_row(x1024, y1024,
                                      uint16_t(length), z1024));
    output = z1024; output_count = length;
  } else if (op == "candidate_mask") {
    if (argc != 4) fail("candidate_mask arguments");
    auto bytes = read_file(argv[2], 16 * 4 + 16);
    copy_at(x16, bytes, 0, 16 * 4);
    copy_at(mask1024, bytes, 16 * 4, 16);
    checked(laya::full::candidate_mask(x16, mask1024, y16));
    output = y16; output_count = 16;
  } else if (op == "candidate_stats") {
    if (argc != 5) fail("candidate_stats arguments: valid_options");
    const unsigned valid = number(argv[4], 16);
    auto bytes = read_file(argv[2], 16 * 4);
    copy_at(x16, bytes, 0, 16 * 4);
    checked(laya::full::candidate_stats(x16, uint8_t(valid), stats));
    output = stats; output_count = 4;
  } else if (op == "concat") {
    if (argc != 4) fail("concat arguments");
    auto bytes = read_file(argv[2], (1024 + 4) * 4);
    copy_at(x1024, bytes, 0, 1024 * 4);
    copy_at(stats, bytes, 1024 * 4, 4 * 4);
    checked(laya::full::concat_act_row(x1024, stats, x1028));
    output = x1028; output_count = 1028;
  } else fail("unknown op");
  write_file(argv[3], output, output_count);
  std::cout << "FULL_CLI_PASS op=" << op << " floats=" << output_count << '\n';
  return 0;
}
