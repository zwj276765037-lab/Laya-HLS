#include "laya_full_runtime.h"

#include <array>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

extern "C" void linear_controller_slice(const uint8_t*, uint8_t*,
                                         const uint8_t*, const uint8_t*,
                                         const uint8_t*, const uint8_t*,
                                         uint8_t*, uint8_t*, uint8_t*,
                                         uint32_t, uint32_t*);

namespace {

void require(bool condition, const char* message) {
  if (!condition) {
    std::fprintf(stderr, "D2_I_LINEAR_FAIL %s\n", message);
    std::exit(1);
  }
}

std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  require(bool(in), "open model, fixture or gold");
  return {std::istreambuf_iterator<char>(in),
          std::istreambuf_iterator<char>()};
}

void store64(uint8_t* p, uint64_t value) {
  for (unsigned byte = 0; byte < 8; ++byte)
    p[byte] = uint8_t(value >> (8 * byte));
}

struct Package {
  std::vector<uint8_t> q0, q1, scale, aux;
};

void run_case(const std::string& fixture, const std::vector<uint8_t>& request,
              const Package& package, const char* input_name,
              const char* gold_name, uint64_t request_id,
              bool pair_present, bool bad_scale = false,
              bool bad_header = false) {
  auto norm = read_file(fixture + "/" + input_name);
  require(norm.size() == 64u * 1024u * 4u, "complete NORM source");
  std::vector<uint8_t> io(32768, 0), state0(16920576u, 0xa5),
                       qkv0(12u << 20, 0xa5), qkv1(12u << 20, 0xa5);
  std::memcpy(io.data(), request.data(), request.size());
  store64(io.data() + 24, request_id);
  std::vector<uint8_t> modified_scale, modified_aux;
  const uint8_t* scale = package.scale.data();
  const uint8_t* aux = package.aux.data();
  if (bad_scale) {
    laya::full::FullWeightDescriptor descriptor;
    require(bool(laya::full::full_lookup_weight({5, 0}, descriptor)),
            "official Decision0 QKV descriptor");
    require(descriptor.scale_base + 1 < package.scale.size(),
            "QKV first scale inside model BO");
    modified_scale = package.scale;
    modified_scale[descriptor.scale_base] = 0x00;
    modified_scale[descriptor.scale_base + 1] = 0x7e;
    scale = modified_scale.data();
  }
  if (bad_header) {
    modified_aux = package.aux;
    modified_aux[0] ^= 1;
    aux = modified_aux.data();
  }
  std::array<uint32_t, 32> observed;
  observed.fill(0xdeadbeefu);
  linear_controller_slice(norm.data(), io.data(), package.q0.data(),
                          package.q1.data(), scale, aux, state0.data(),
                          qkv0.data(), qkv1.data(), pair_present ? 1 : 0,
                          observed.data());
  if (bad_header) {
    require(observed[0] == uint32_t(laya::Status::E_MODEL) &&
            observed[2] == 1,
            "bad model header rejected before producer or weight access");
    require(qkv0[0] == 0xa5 && qkv1[0] == 0xa5,
            "bad model header produces no QKV bytes");
    return;
  }
  require(observed[14] == request_id && observed[15] != 0,
          "real B1/S64 request parsed");
  if (bad_scale) {
    require(observed[0] == uint32_t(laya::Status::E_NUMERICAL) &&
            observed[1] == laya::detail(7, uint8_t(laya::Op::LOAD_W), 15) &&
            observed[2] == 4 && observed[3] == 1 &&
            observed[5] == 1 && observed[6] == 0 && observed[7] == 0 &&
            observed[9] == uint32_t(laya::Status::OK),
            "bad scale fails real weight loader before numerical tasks");
    require(qkv0[0] == 0xa5 && qkv1[0] == 0xa5,
            "bad scale publishes no QKV bytes");
    return;
  }
  if (!pair_present) {
    require(observed[0] == uint32_t(laya::Status::E_INTERNAL) &&
            observed[1] == laya::detail(7, 0, 4) &&
            observed[2] == 4 && observed[3] == 1 &&
            observed[5] == 1 && observed[6] == 0 && observed[7] == 0 &&
            observed[9] == uint32_t(laya::Status::OK),
            "missing pair reaches original post-load Controller failure");
    require(qkv0[0] == 0xa5 && qkv1[0] == 0xa5,
            "missing pair publishes no QKV bytes");
    return;
  }
  require(observed[0] == uint32_t(laya::Status::OK) &&
          observed[1] == 0 && observed[2] == 5 &&
          observed[3] == 9 && observed[4] == 9 &&
          observed[5] == 1 && observed[6] == 4 && observed[7] == 4,
          "real load, four quant and four full QKV tasks completed");
  require(observed[10] == uint32_t(laya::Buffer::QKV) &&
          observed[12] == uint32_t(laya::Buffer::QKV) &&
          observed[11] != 0 && observed[13] != 0 &&
          observed[16] == uint32_t(laya::Buffer::QKV) &&
          observed[17] == 0 && observed[18] == observed[11] &&
          observed[21] == uint32_t(laya::Buffer::QKV) &&
          observed[22] == 1 && observed[23] == observed[13] &&
          observed[19] == uint32_t(laya::Status::OK) &&
          observed[24] == uint32_t(laya::Status::OK) &&
          observed[20] == uint32_t(laya::CacheState::READY) &&
          observed[25] == uint32_t(laya::CacheState::READY) &&
          observed[26] == 64 &&
          observed[27] == uint32_t(laya::Content::QKV_FINAL) &&
          observed[28] == uint32_t(laya::Content::QKV_FINAL) &&
          observed[29] == uint32_t(laya::Content::QKV_FINAL) &&
          observed[30] == 64 && observed[31] == 64,
          "both produced and returned QKV shards are READY FINAL");
  const auto gold = read_file(fixture + "/" + gold_name);
  require(gold.size() == 64u * 3072u * 4u, "complete independent R0 gold");
  unsigned compared = 0;
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned row = 0; row < 64; ++row) {
        laya::Address at;
        require(bool(laya::qkv_address(uint8_t(plane), 0, uint8_t(head),
                                      uint16_t(row), 0, 1, 64, at)),
                "official QKV physical address");
        const uint8_t* bank = at.bo == laya::Bo::QKV0 ?
                              qkv0.data() : qkv1.data();
        const unsigned logical = (row * 3072u + plane * 1024u +
                                  head * 64u) * 4u;
        require(std::memcmp(bank + at.offset,
                            gold.data() + logical, 256) == 0,
                "bit-exact independent R0 QKV output");
        compared += 256;
      }
  require(compared == gold.size(), "all QKV values compared");
  for (unsigned byte = 10240000u; byte < 10240064u; ++byte)
    require(qkv0[byte] == 0xa5 && qkv1[byte] == 0xa5,
            "both QKV bank tail sentinels untouched");
}

}  // namespace

int main(int argc, char** argv) {
  const char* package_arg = argc == 3 ? argv[1] :
                            std::getenv("LAYA_D2_I_PACKAGE");
  const char* fixture_arg = argc == 3 ? argv[2] :
                            std::getenv("LAYA_D2_I_FIXTURE");
  require(package_arg && fixture_arg, "package and fixture paths");
  require(std::fegetround() == FE_TONEAREST,
          "round-to-nearest-even host mode");
  const std::string package = package_arg, fixture = fixture_arg;
  const auto request = read_file(fixture + "/request.bin");
  Package model{read_file(package + "/w_q0.bin"),
                read_file(package + "/w_q1.bin"),
                read_file(package + "/w_scale.bin"),
                read_file(package + "/aux.bin")};
  require(request.size() == 832 &&
          model.q0.size() == 184682496 &&
          model.q1.size() == 184680448 &&
          model.scale.size() == 23085184 &&
          model.aux.size() == 1671872,
          "complete official model BO capacities");
  run_case(fixture, request, model, "norm.f32.bin",
           "qkv_gold.f32.bin", 301, true);
  run_case(fixture, request, model, "norm_changed.f32.bin",
           "qkv_changed_gold.f32.bin", 302, true);
  run_case(fixture, request, model, "norm.f32.bin", nullptr,
           303, false);
  run_case(fixture, request, model, "norm.f32.bin", nullptr,
           304, true, true);
  run_case(fixture, request, model, "norm.f32.bin", nullptr,
           305, false, true);
  run_case(fixture, request, model, "norm.f32.bin", nullptr,
           306, true, false, true);
  run_case(fixture, request, model, "norm.f32.bin", nullptr,
           307, false, false, true);
  run_case(fixture, request, model, "norm.f32.bin",
           "qkv_gold.f32.bin", 308, true);
  std::printf("D2_I_LINEAR_PASS qkv_values=%u success=3 no_pair=1 bad_scale=2 bad_header=2\n",
              3u * 64u * 3072u);
}
