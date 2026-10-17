#include "laya_full_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

using namespace laya;

static void require(bool ok, const char* what) {
  if (!ok) { std::cerr << "FULL_DECISION_FAIL " << what << '\n'; std::exit(1); }
}

int main() {
  unsigned cases = 0;
  float logits[16], masked[16], p[16], stats[4];
  uint8_t marker[16];
  for (unsigned i = 0; i < 16; ++i) {
    logits[i] = i == 0 ? 0.5f : -1.0f;
    marker[i] = i < 3 ? 1 : 0;
  }
  require(bool(full::candidate_mask(logits, marker, masked)), "candidate mask");
  require(masked[0] == 0.5f && masked[2] == -1.0f &&
          masked[3] == -10001.0f && masked[15] == -10001.0f,
          "mask adds bias to all sixteen computed logits");
  ++cases;
  marker[15] = 2; masked[15] = 777.0f;
  require(!full::candidate_mask(logits, marker, masked) &&
          masked[15] == 777.0f, "invalid mask precheck");
  ++cases;

  for (float& item : p) item = 1.0f / 16.0f;
  require(bool(full::candidate_stats(p, 16, stats)), "uniform candidate p");
  require(stats[0] == 0.0625f && stats[1] == 0.0625f &&
          stats[2] == 1.0f && stats[3] == 16.0f / 255.0f,
          "top2 is approximate chain, entropy and k/255");
  ++cases;
  p[15] = 1.125f;
  require(full::candidate_stats(p, 16, stats).code == Status::E_NUMERICAL ||
          full::candidate_stats(p, 16, stats).code == Status::E_SHAPE,
          "probability domain");
  ++cases;

  float cls[1024], joined[1028];
  for (unsigned i = 0; i < 1024; ++i) cls[i] = float(i);
  const float input_stats[4] = {0.25f, 0.5f, 0.75f, 1.0f};
  require(bool(full::concat_act_row(cls, input_stats, joined)), "concat CLS/stat");
  require(joined[0] == 0.0f && joined[1023] == 1023.0f &&
          joined[1024] == 0.25f && joined[1027] == 1.0f,
          "act 1028 boundary and field order");
  ++cases;
  std::cout << "FULL_DECISION_PASS cases=" << cases << '\n';
}
