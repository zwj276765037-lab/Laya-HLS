#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

extern "C" uint16_t full_rope_cosim_top(const float x[64],
                                         const float cosine[64],
                                         const float sine[64], float y[64]);

namespace {
void require(bool condition, const char* message) {
  if (!condition) {
    std::cerr << "FULL_ROPE_COSIM_FAIL " << message << '\n';
    std::exit(1);
  }
}
}  // namespace

int main() {
  // Public Status ABI: OK=0, E_NUMERICAL=6. Expected outputs below are
  // fixed independently of the production rope_head implementation.
  constexpr uint16_t kOk = 0;
  constexpr uint16_t kNumerical = 6;
  float x[64] = {};
  float cosine[64] = {};
  float sine[64] = {};
  float y[64];
  for (unsigned i = 0; i < 64; ++i) {
    sine[i] = 1.0f;
    y[i] = 99.0f;
  }
  x[0] = 3.0f;
  x[31] = -5.0f;
  x[32] = 4.0f;
  x[63] = 7.0f;

  require(full_rope_cosim_top(x, cosine, sine, y) == kOk,
          "quarter-turn status");
  for (unsigned i = 0; i < 64; ++i) {
    float expected = 0.0f;
    if (i == 0) expected = -4.0f;
    if (i == 31) expected = -7.0f;
    if (i == 32) expected = 3.0f;
    if (i == 63) expected = -5.0f;
    require(y[i] == expected, "quarter-turn output");
  }

  for (unsigned i = 0; i < 64; ++i) {
    cosine[i] = i < 32 ? 2.0f : 3.0f;
    sine[i] = i < 32 ? 4.0f : 5.0f;
  }
  require(full_rope_cosim_top(x, cosine, sine, y) == kOk,
          "asymmetric-table status");
  for (unsigned i = 0; i < 64; ++i) {
    float expected = 0.0f;
    if (i == 0) expected = -10.0f;
    if (i == 31) expected = -38.0f;
    if (i == 32) expected = 27.0f;
    if (i == 63) expected = -4.0f;
    require(y[i] == expected, "asymmetric-table output");
  }

  x[63] = std::numeric_limits<float>::infinity();
  for (float& element : y) element = 99.0f;
  require(full_rope_cosim_top(x, cosine, sine, y) == kNumerical,
          "nonfinite input status");
  for (float element : y)
    require(element == 99.0f, "invalid input must not write output");

  std::cout << "FULL_ROPE_COSIM_PASS cases=3\n";
}
