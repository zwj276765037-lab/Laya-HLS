#include "laya_full_numeric.h"

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <limits>

using namespace laya;

static void require(bool ok, const char* what) {
  if (!ok) { std::cerr << "FULL_ATTENTION_FAIL " << what << '\n'; std::exit(1); }
}

static float q[64], k[1024][64], v[1024][64], p[1024], score[1024];
static float x[1024], w[1024], act_x[1028], act_y[256];
static uint8_t mask[1024];
static uint16_t act_w[256][1028];

int main() {
  unsigned cases = 0;
  for (unsigned i = 0; i < 64; ++i) q[i] = 0.0f;
  for (unsigned i = 0; i < 1024; ++i) {
    mask[i] = 0; score[i] = 333.0f;
    for (unsigned d = 0; d < 64; ++d) { k[i][d] = 0; v[i][d] = 2.0f; }
  }
  mask[0] = 1;
  require(bool(full::qk_row(q, k, mask, 128, 65, true, score)), "sliding QK");
  require(score[0] == -10000.0f && score[1] == -10000.0f &&
          score[128 - 1] == -10000.0f && score[128] == 333.0f,
          "sliding finite bias and tail guard");
  // Key zero is outside query65's window. With padding it receives -20000.
  mask[0] = 0;
  require(bool(full::qk_row(q, k, mask, 128, 65, true, score)) &&
          score[0] == -20000.0f && score[1] == -10000.0f,
          "outside-window padding retains finite -20000");
  ++cases;
  mask[0] = 1;
  require(bool(full::qk_row(q, k, mask, 64, 0, false, score)) &&
          score[0] == 0.0f && score[63] == -10000.0f,
          "full mask and S64 boundary");
  ++cases;
  mask[0] = 0;
  score[1023] = 123.0f;
  require(bool(full::qk_row(q, k, mask, 1024, 1023, true, score)) &&
          score[0] == -20000.0f && score[1023] == -10000.0f,
          "S1024 last query and all-key finite processing");
  ++cases;
  mask[127] = 2; score[127] = 777.0f;
  require(!full::qk_row(q, k, mask, 128, 0, false, score) &&
          score[127] == 777.0f, "bad mask rejected before output write");
  mask[127] = 0; ++cases;

  for (unsigned i = 0; i < 16; ++i) x[i] = -20000.0f;
  for (unsigned i = 16; i < 1024; ++i) p[i] = 777.0f;
  require(bool(full::softmax_row(x, 16, p)), "finite masked softmax");
  for (unsigned i = 0; i < 16; ++i) require(p[i] == 0.0625f, "uniform p");
  require(p[16] == 777.0f, "softmax tail guard");
  ++cases;
  for (unsigned i = 0; i < 64; ++i) p[i] = 1.0f / 64.0f;
  float result[64];
  require(bool(full::av_row(p, v, 64, result)), "AV all keys");
  for (float item : result) require(item == 2.0f, "AV key-order constant sum");
  ++cases;
  p[63] = std::numeric_limits<float>::quiet_NaN();
  require(full::av_row(p, v, 64, result).code == Status::E_NUMERICAL,
          "AV rejects final NaN");
  ++cases;

  for (unsigned i = 0; i < 1024; ++i) { x[i] = 1.0f; w[i] = 0.5f; }
  float scorer = 0;
  require(bool(full::fp_scorer_row(x, w, 0.25f, scorer)) &&
          scorer == 512.25f, "scorer F32 K1024 then bias");
  ++cases;
  for (unsigned i = 0; i < 1028; ++i) act_x[i] = 0.0f;
  for (unsigned n = 0; n < 256; ++n)
    for (unsigned i = 0; i < 1028; ++i) act_w[n][i] = 0;
  act_x[0] = 1.0f; act_x[1027] = 2.0f;
  act_w[0][0] = 0x3c00; act_w[0][1027] = 0x3c00;
  act_w[255][1027] = 0x3c00;
  require(bool(full::fp_act_row(act_x, act_w, act_y)) &&
          act_y[0] == 3.0f && act_y[255] == 2.0f && act_y[254] == 0.0f,
          "act F16 K1028 tail and output255");
  ++cases;
  std::cout << "FULL_ATTENTION_PASS cases=" << cases << '\n';
}
