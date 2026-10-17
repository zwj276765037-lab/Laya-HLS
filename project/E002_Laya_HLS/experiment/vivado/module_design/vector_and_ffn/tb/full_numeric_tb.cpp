#include "laya_full_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

using namespace laya;

static void require(bool ok, const char* what) {
  if (!ok) { std::cerr << "FULL_VECTOR_FAIL " << what << '\n'; std::exit(1); }
}

static float wi[5248], gate[2624], x[4096], y[4096];
static float a[1024], b[1024], sum[1024];

int main() {
  unsigned cases = 0;
  float scalar = -1;
  require(bool(full::gelu_scalar(0.0f, scalar)) && scalar == 0.0f,
          "GELU zero exact");
  ++cases;
  require(full::gelu_scalar(std::numeric_limits<float>::quiet_NaN(), scalar)
              .code == Status::E_NUMERICAL, "GELU NaN");
  ++cases;

  for (unsigned i = 0; i < 2624; ++i) {
    wi[i] = 0.0f; wi[2624 + i] = 3.0f;
  }
  require(bool(full::geglu_row(wi, gate)), "GEGLU zero U");
  for (float item : gate) require(item == 0.0f, "GEGLU first/last gate");
  ++cases;

  for (unsigned i = 0; i < 4096; ++i) x[i] = i & 1 ? -2.0f : 3.0f;
  x[4095] = -0.0f;
  require(bool(full::relu_row(x, y)) && y[0] == 3.0f &&
          y[1] == 0.0f && y[4094] == 3.0f &&
          y[4095] == 0.0f && !std::signbit(y[4095]),
          "ReLU order, tail, positive zero");
  ++cases;
  x[4095] = std::numeric_limits<float>::infinity();
  require(full::relu_row(x, y).code == Status::E_NUMERICAL,
          "ReLU rejects last Inf");
  ++cases;

  for (unsigned i = 0; i < 1024; ++i) { a[i] = 1.0f; b[i] = 2.0f; }
  require(bool(full::add_row(a, b, sum)), "residual add");
  for (float item : sum) require(item == 3.0f, "residual every element");
  require(bool(full::add_row(a, b, a)), "allowed add in place");
  for (float item : a) require(item == 3.0f, "add in-place per element");
  ++cases;

  for (unsigned i = 0; i < 1024; ++i) { a[i] = 2.0f; b[i] = -2.0f; }
  require(bool(full::bias_gelu_row(a, b, 1024, sum)), "scorer bias/GELU");
  for (float item : sum) require(item == 0.0f, "GELU after bias");
  require(bool(full::bias_gelu_row(a, b, 256, sum)), "act bias/GELU tail");
  for (unsigned i = 0; i < 256; ++i) require(sum[i] == 0.0f, "act tail value");
  ++cases;
  std::cout << "FULL_VECTOR_PASS cases=" << cases << '\n';
}
