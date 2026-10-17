#include "laya_full_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

using namespace laya;

static void require(bool ok, const char* what) {
  if (!ok) { std::cerr << "FULL_ROPE_FAIL " << what << '\n'; std::exit(1); }
}

int main() {
  unsigned cases = 0;
  float x[64], cosine[64], sine[64], y[64];
  for (unsigned i = 0; i < 64; ++i) {
    x[i] = float(int(i) - 20); cosine[i] = 1.0f; sine[i] = 0.0f;
  }
  require(bool(full::rope_head(x, cosine, sine, y)), "identity rotation");
  for (unsigned i = 0; i < 64; ++i)
    require(y[i] == x[i], "identity result");
  ++cases;
  for (unsigned i = 0; i < 64; ++i) { cosine[i] = 0.0f; sine[i] = 1.0f; }
  require(bool(full::rope_head(x, cosine, sine, y)), "quarter rotation");
  for (unsigned i = 0; i < 32; ++i) {
    require(y[i] == -x[i + 32], "half split first half");
    require(y[i + 32] == x[i], "half split second half");
  }
  ++cases;
  require(bool(full::rope_head(x, cosine, sine, x)), "allowed in place");
  for (unsigned i = 0; i < 64; ++i)
    require(x[i] == y[i], "in-place source snapshot");
  ++cases;
  x[63] = std::numeric_limits<float>::infinity();
  require(full::rope_head(x, cosine, sine, y).code == Status::E_NUMERICAL,
          "reject last input Inf");
  ++cases;
  std::cout << "FULL_ROPE_PASS cases=" << cases << '\n';
}
