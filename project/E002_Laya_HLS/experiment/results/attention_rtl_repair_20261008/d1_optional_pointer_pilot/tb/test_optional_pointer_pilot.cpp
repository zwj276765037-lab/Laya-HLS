#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

extern "C" void optional_pointer_pilot(uint8_t mode, uint8_t layer,
                                         uint8_t src_bank, uint32_t epoch,
                                         uint8_t second_id,
                                         uint8_t second_bank,
                                         uint32_t second_epoch,
                                         uint8_t second_region,
                                         uint8_t load_ok,
                                         uint32_t out[36]);

namespace {
using Result = std::array<uint32_t, 36>;
unsigned checks = 0;

Result run(uint8_t mode, uint8_t layer = 0, uint8_t src_bank = 0,
           uint32_t epoch = 7, uint8_t second_id = 1,
           uint8_t second_bank = 0,
           uint32_t second_epoch = 23, uint8_t second_region = 2,
           uint8_t load_ok = 1) {
  Result result{};
  result.fill(0xdeadbeef);
  optional_pointer_pilot(mode, layer, src_bank, epoch, second_id, second_bank,
                         second_epoch, second_region, load_ok, result.data());
  return result;
}

void eq(const char* label, const Result& result,
        unsigned index, uint32_t expected) {
  ++checks;
  if (result[index] != expected) {
    std::fprintf(stderr, "FAIL %s out[%u]: got %u (0x%08x), expected %u (0x%08x)\n",
                 label, index, result[index], result[index], expected, expected);
    std::exit(1);
  }
}

void check_qkv(const char* label, uint32_t epoch) {
  const Result r = run(0, 2, 1, epoch);
  eq(label, r, 0, 0);
  eq(label, r, 1, 0);
  eq(label, r, 2, 5); // QKV shard 0
  eq(label, r, 3, 0);
  eq(label, r, 4, epoch + 1);
  eq(label, r, 5, 5); // QKV shard 1
  eq(label, r, 6, 1);
  eq(label, r, 7, epoch + 1);
  eq(label, r, 18, 2); // QKV_RAW
  eq(label, r, 19, epoch + 1);
  eq(label, r, 23, 2);
  eq(label, r, 24, 128);
  eq(label, r, 25, 64);
  eq(label, r, 26, 2);
  eq(label, r, 27, 128);
  eq(label, r, 28, 64);
  eq(label, r, 29, 2);
  eq(label, r, 30, 2);
  eq(label, r, 31, 2);
  eq(label, r, 32, 2);
}
} // namespace

int main() {
  check_qkv("qkv_first", 7);
  check_qkv("qkv_epoch_change", 19);

  const Result final_qkv = run(7, 3, 1, 19);
  eq("qkv_stage4", final_qkv, 0, 0);
  eq("qkv_stage4", final_qkv, 4, 20);
  eq("qkv_stage4", final_qkv, 7, 20);
  eq("qkv_stage4", final_qkv, 18, 3); // QKV_FINAL
  eq("qkv_stage4", final_qkv, 23, 3);
  eq("qkv_stage4", final_qkv, 26, 3);
  eq("qkv_stage4", final_qkv, 24, 128);
  eq("qkv_stage4", final_qkv, 27, 128);
  eq("qkv_stage4", final_qkv, 25, 64);
  eq("qkv_stage4", final_qkv, 28, 64);
  eq("qkv_stage4", final_qkv, 29, 4);
  eq("qkv_stage4", final_qkv, 30, 4);
  eq("qkv_stage4", final_qkv, 31, 3);
  eq("qkv_stage4", final_qkv, 32, 3);

  const Result absent_qkv = run(1);
  eq("absent_qkv", absent_qkv, 0, 8);
  eq("absent_qkv", absent_qkv, 1, 0x07000004);
  eq("absent_qkv", absent_qkv, 2, 0);
  eq("absent_qkv", absent_qkv, 18, 2);

  const Result load_failure = run(1, 0, 0, 7, 1, 0, 23, 2, 0);
  eq("load_before_pair_guard", load_failure, 0, 5);
  eq("load_before_pair_guard", load_failure, 1, 0x04000011);

  const Result ordinary = run(2);
  eq("ordinary_linear", ordinary, 0, 0);
  eq("ordinary_linear", ordinary, 2, 0);
  eq("ordinary_linear", ordinary, 18, 1); // F32
  eq("ordinary_linear", ordinary, 19, 8);

  const Result binary = run(3, 2, 0, 7, 1, 1, 23, 2);
  eq("binary_vector", binary, 0, 0);
  eq("binary_vector", binary, 8, 1); // HIDDEN
  eq("binary_vector", binary, 9, 1);
  eq("binary_vector", binary, 10, 23);
  eq("binary_vector", binary, 11, 2);
  eq("binary_vector", binary, 12, 1); // second bind
  eq("binary_vector", binary, 13, 23);
  eq("binary_vector", binary, 20, 1);
  eq("binary_vector", binary, 21, 1);
  eq("binary_vector", binary, 22, 2);
  eq("binary_vector", binary, 35, 0x62); // ADD_RESIDUAL

  const Result binary_changed = run(3, 2, 0, 7, 11, 0, 47, 5);
  eq("binary_changed", binary_changed, 0, 0);
  eq("binary_changed", binary_changed, 8, 11);
  eq("binary_changed", binary_changed, 9, 0);
  eq("binary_changed", binary_changed, 10, 47);
  eq("binary_changed", binary_changed, 11, 5);
  eq("binary_changed", binary_changed, 12, 1);
  eq("binary_changed", binary_changed, 13, 47);
  eq("binary_changed", binary_changed, 20, 11);
  eq("binary_changed", binary_changed, 21, 0);
  eq("binary_changed", binary_changed, 22, 5);

  const Result type_add = run(8, 0, 0, 7, 11, 1, 43, 3);
  eq("type_add", type_add, 0, 0);
  eq("type_add", type_add, 8, 11);
  eq("type_add", type_add, 9, 1);
  eq("type_add", type_add, 10, 43);
  eq("type_add", type_add, 11, 3);
  eq("type_add", type_add, 12, 1);
  eq("type_add", type_add, 13, 43);
  eq("type_add", type_add, 20, 11);
  eq("type_add", type_add, 21, 1);
  eq("type_add", type_add, 22, 3);
  eq("type_add", type_add, 35, 0x63); // ADD_TYPE

  const Result binary_absent = run(4);
  eq("binary_absent", binary_absent, 0, 3);
  eq("binary_absent", binary_absent, 1, 0x07030001);
  eq("binary_absent", binary_absent, 8, 0);
  eq("binary_absent", binary_absent, 12, 0);

  const Result unary = run(5);
  eq("unary_vector", unary, 0, 0);
  eq("unary_vector", unary, 8, 0);
  eq("unary_vector", unary, 11, 0);
  eq("unary_vector", unary, 12, 0);

  const Result selected0 = run(6, 0, 1, 31, 11, 0, 59, 4);
  eq("attention_layer0", selected0, 0, 0);
  eq("attention_layer0", selected0, 14, 1); // HIDDEN
  eq("attention_layer0", selected0, 15, 1);
  eq("attention_layer0", selected0, 16, 31);
  eq("attention_layer0", selected0, 17, 0);

  const Result selected1 = run(6, 3, 1, 31, 11, 0, 59, 4);
  eq("attention_layer3", selected1, 0, 0);
  eq("attention_layer3", selected1, 14, 11); // TYPE_ROWS
  eq("attention_layer3", selected1, 15, 0);
  eq("attention_layer3", selected1, 16, 59);
  eq("attention_layer3", selected1, 17, 4);

  const Result norm_failure = run(6, 3, 1, 31, 11, 0, 59, 4, 0);
  eq("attention_norm_failure", norm_failure, 0, 5);
  eq("attention_norm_failure", norm_failure, 1, 0x04000012);
  eq("attention_norm_failure", norm_failure, 14, 0);
  eq("attention_norm_failure", norm_failure, 16, 0);

  const Result invalid = run(9);
  eq("invalid_mode", invalid, 0, 3);
  eq("invalid_mode", invalid, 1, 0x07070007);
  std::printf("D1_OPTIONAL_POINTER_PILOT_PASS checks=%u\n", checks);
  return 0;
}
