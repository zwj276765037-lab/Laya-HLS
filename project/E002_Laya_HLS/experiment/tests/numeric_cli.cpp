// Host-only bridge between immutable fixture bytes and the isolated numeric
// top functions.  The Python oracle never imports or calls DUT helpers.
#include "numeric_test_support.h"

#include <cfenv>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iterator>
#include <string>
#include <vector>
#if defined(__SSE__)
#include <xmmintrin.h>
#endif

using namespace laya;

namespace {
static float qinput[16][4096], lninput[16][1024], lnoutput[16][1024];
static int8_t aq[16][128][32], wq[8][128][32];
static uint16_t as[16][128], ws[8][128];
static float output[16][8], gamma[1024], bias[8];
static float mean[16], variance[16], inverse[16];
static NumericGroupTrace trace[128];

void fail(const std::string& reason) {
  std::cerr << "NUMERIC_CLI_FAIL " << reason << '\n';
  std::exit(1);
}
unsigned long long number(const char* s) {
  size_t used = 0;
  const unsigned long long v = std::stoull(s, &used, 0);
  if (s[used]) fail("invalid integer");
  return v;
}
unsigned nibble(char c) {
  if (c >= '0' && c <= '9') return unsigned(c - '0');
  if (c >= 'a' && c <= 'f') return unsigned(c - 'a') + 10;
  if (c >= 'A' && c <= 'F') return unsigned(c - 'A') + 10;
  fail("invalid hex character");
  return 0;
}
void hex_bytes(const char* s, uint8_t* out, unsigned n) {
  if (std::strlen(s) != n * 2) fail("invalid hex length");
  for (unsigned i = 0; i < n; ++i) out[i] = uint8_t((nibble(s[2*i]) << 4) | nibble(s[2*i+1]));
}
std::vector<uint8_t> read_file(const char* name, size_t expected) {
  std::ifstream file(name, std::ios::binary);
  if (!file) fail(std::string("open ") + name);
  std::vector<uint8_t> data((std::istreambuf_iterator<char>(file)),
                            std::istreambuf_iterator<char>());
  if (data.size() != expected) fail(std::string("size ") + name);
  return data;
}
void write_file(const std::string& path, const std::vector<uint8_t>& bytes) {
  std::ofstream file(path, std::ios::binary);
  if (!file) fail(std::string("write ") + path);
  file.write(reinterpret_cast<const char*>(bytes.data()),
             std::streamsize(bytes.size()));
  if (!file) fail(std::string("flush ") + path);
}
void put32(std::vector<uint8_t>& bytes, uint32_t word) {
  for (unsigned i = 0; i < 4; ++i) bytes.push_back(uint8_t(word >> (8*i)));
}
uint32_t get32(const uint8_t* p) {
  return uint32_t(p[0]) | (uint32_t(p[1]) << 8) |
         (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24);
}
void check_status(Check c, const char* stage) {
  if (c) return;
  std::cerr << "NUMERIC_CLI_FAIL " << stage << " status=" << unsigned(c.code)
            << " detail=" << c.detail << " element=" << c.bad_element << '\n';
  std::exit(1);
}
} // namespace

int main(int argc, char** argv) {
  if (argc != 23) fail("usage: mode input weight bias gamma prefix batch row0 rows n0 request generation modeltag numerictag layouttag buildtag weightsha weightoffset weightbytes biassha biasoffset biasbytes");
  if (std::fegetround() != FE_TONEAREST) fail("host rounding mode is not RNE");
#if defined(__SSE__)
  if (_mm_getcsr() & ((1u << 15) | (1u << 6))) fail("host FTZ or DAZ is enabled");
#endif
  const std::string mode = argv[1], prefix = argv[6];
  const unsigned batch = unsigned(number(argv[7]));
  const unsigned row0 = unsigned(number(argv[8]));
  const unsigned rows = unsigned(number(argv[9]));
  const unsigned n0 = unsigned(number(argv[10]));
  if (batch > 1 || rows < 1 || rows > 16 || row0 > 127 || n0 > 5240)
    fail("case shape");
  NumericIdentity id;
  id.request_id = number(argv[11]); id.generation = number(argv[12]);
  id.B = 2; id.S = 128;
  hex_bytes(argv[13], id.model_tag, 16);
  hex_bytes(argv[14], id.numeric_tag, 16);
  hex_bytes(argv[15], id.layout_tag, 16);
  hex_bytes(argv[16], id.build_tag, 16);
  if (!numeric_identity_valid(id)) fail("experimental identity");

  const bool do_ln = mode == "ln_wi" || mode == "ln_qkv";
  const bool do_linear = mode != "quant4096";
  unsigned K = 0, N = 0;
  Op linear_op = Op::LIN_QKV;
  WeightKey key{};
  Buffer source_buffer = Buffer::NORM;
  uint8_t source_region = 0, stage = 2, layer = 0;
  RowSpace space = RowSpace::TOKEN;
  Buffer target_buffer = Buffer::QKV;
  uint8_t target_region = 0;
  if (mode == "ln_wi" || mode == "wi") {
    K = 1024; N = 5248; linear_op = Op::LIN_WI; key = {3, 0};
    target_buffer = Buffer::WI;
  } else if (mode == "ln_qkv" || mode == "qkv") {
    K = 1024; N = 3072; linear_op = Op::LIN_QKV; key = {1, 0};
  } else if (mode == "down") {
    K = 2624; N = 1024; linear_op = Op::LIN_DOWN; key = {4, 0};
    source_buffer = Buffer::GATE; target_buffer = Buffer::TMP;
  } else if (mode == "act") {
    K = 256; N = 2; linear_op = Op::LIN_ACT_FC2; key = {12, 255};
    source_buffer = Buffer::HEAD_WORK;
    source_region = uint8_t(Region::ACT_HIDDEN);
    target_buffer = Buffer::HEAD_WORK;
    target_region = uint8_t(Region::ACT_LOGITS);
    stage = 6; layer = 255; space = RowSpace::BATCH;
  } else if (mode == "quant4096") {
    K = 4096; source_buffer = Buffer::DEC_FF;
    stage = 4; layer = 0;
  } else fail("unknown mode");
  if (space == RowSpace::BATCH ? (row0 != 0 || rows != 1) : row0 + rows > 128)
    fail("row bounds");

  const auto input = read_file(argv[2], size_t(rows) * K * 4);
  TaskContext ctx{10, Op::QUANT, stage, layer, uint8_t(batch), space,
                  uint16_t(row0), uint8_t(rows)};
  BufferRef original_ref{source_buffer, 0, 1};
  F32TileMeta ln_result;
  if (do_ln) {
    original_ref = {Buffer::HIDDEN, 0, 1};
    LayerNormTask ln;
    ln.ctx = {10, mode == "ln_qkv" ? Op::LN_EMB : Op::LN_FFN,
              uint8_t(mode == "ln_qkv" ? 1 : 2),
              uint8_t(mode == "ln_qkv" ? 255 : 0), uint8_t(batch),
              RowSpace::TOKEN, uint16_t(row0), uint8_t(rows)};
    ln.src = original_ref; ln.dst = {Buffer::NORM, 0, 1};
    ln.gamma = uint8_t(mode == "ln_qkv" ? 1 : 0);
    for (unsigned r = 0; r < rows; ++r)
      for (unsigned k = 0; k < 1024; ++k)
        lninput[r][k] = numeric_bits_f32(get32(&input[(r * K + k) * 4]));
    GammaMeta gm;
    if (ln.gamma) {
      const auto gdata = read_file(argv[5], 4096);
      for (unsigned k = 0; k < 1024; ++k)
        gamma[k] = numeric_bits_f32(get32(&gdata[k * 4]));
      for (unsigned i = 0; i < 16; ++i) gm.model_tag[i] = id.model_tag[i];
      gm.ref = {Buffer::LN_GAMMA, 0, 1}; gm.gamma_kind = 1;
      gm.D = 1024; gm.covered_groups = UINT32_MAX;
      gm.state = CacheState::READY; gm.valid = true;
    }
    F32TileMeta ln_source;
    ln_source.identity = id; ln_source.ref = ln.src;
    ln_source.row_space = ln.ctx.row_space; ln_source.batch = ln.ctx.batch;
    ln_source.row0 = ln.ctx.row0; ln_source.rows = ln.ctx.rows;
    ln_source.K = 1024;
    numeric_cover_all(ln_source.covered_groups, rows, 32, 16);
    ln_source.state = CacheState::READY; ln_source.content = Content::F32;
    ln_source.valid = true;
    check_status(layernorm_compute(ln, id, ln_source, gm, lninput, gamma,
                                   lnoutput, mean, variance, inverse,
                                   ln_result), "layernorm");
    // Controller's expected publication is constructed from the accepted
    // task, not copied from the DUT record.  Quant consumes ln_result itself.
    F32TileMeta expected;
    expected.identity = id; expected.ref = ln.dst;
    expected.region = 0; expected.row_space = ln.ctx.row_space;
    expected.batch = ln.ctx.batch; expected.row0 = ln.ctx.row0;
    expected.rows = ln.ctx.rows; expected.K = 1024;
    for (unsigned r = 0; r < rows; ++r)
      expected.covered_groups[r][0] = UINT32_MAX;
    expected.state = CacheState::READY; expected.content = Content::F32;
    expected.valid = true;
    nrequire(ln_result.identity.request_id == expected.identity.request_id &&
             ln_result.identity.generation == expected.identity.generation &&
             ln_result.identity.B == expected.identity.B &&
             ln_result.identity.S == expected.identity.S &&
             std::memcmp(ln_result.identity.model_tag,
                         expected.identity.model_tag, 16) == 0 &&
             std::memcmp(ln_result.identity.numeric_tag,
                         expected.identity.numeric_tag, 16) == 0 &&
             std::memcmp(ln_result.identity.layout_tag,
                         expected.identity.layout_tag, 16) == 0 &&
             std::memcmp(ln_result.identity.build_tag,
                         expected.identity.build_tag, 16) == 0 &&
             ln_result.ref == expected.ref && ln_result.region == expected.region &&
             ln_result.row_space == expected.row_space &&
             ln_result.batch == expected.batch && ln_result.row0 == expected.row0 &&
             ln_result.rows == expected.rows && ln_result.K == expected.K &&
             ln_result.state == CacheState::READY && ln_result.valid &&
             ln_result.content == Content::F32 && ln_result.readers == 0,
             "actual LN publication against controller expectation");
    for (unsigned r = 0; r < 16; ++r)
      for (unsigned word = 0; word < 4; ++word)
        nrequire(ln_result.covered_groups[r][word] ==
                 expected.covered_groups[r][word], "LN coverage publication");
    std::vector<uint8_t> lndata, stats;
    for (unsigned r = 0; r < rows; ++r) {
      put32(stats, numeric_f32_bits(mean[r]));
      put32(stats, numeric_f32_bits(variance[r]));
      put32(stats, numeric_f32_bits(inverse[r]));
      for (unsigned k = 0; k < 1024; ++k) {
        qinput[r][k] = lnoutput[r][k];
        put32(lndata, numeric_f32_bits(lnoutput[r][k]));
      }
    }
    write_file(prefix + ".ln.bin", lndata);
    write_file(prefix + ".ln_stats.bin", stats);
    original_ref = ln_result.ref;
  } else {
    for (unsigned r = 0; r < rows; ++r)
      for (unsigned k = 0; k < K; ++k)
        qinput[r][k] = numeric_bits_f32(get32(&input[(r * K + k) * 4]));
  }

  ctx.task_id = 11;
  QuantTask quant;
  quant.ctx = ctx; quant.src = original_ref;
  quant.a_dst = {Buffer::A8, 0, 1}; quant.K = uint16_t(K);
  quant.src_region = source_region; quant.input_lanes = 8;
  F32TileMeta source;
  if (do_ln) source = ln_result;
  else {
    source.identity = id; source.ref = quant.src; source.region = source_region;
    source.row_space = space; source.batch = uint8_t(batch);
    source.row0 = uint16_t(row0); source.rows = uint8_t(rows);
    source.K = uint16_t(K);
    numeric_cover_all(source.covered_groups, rows, K / 32, 16);
    source.state = CacheState::READY; source.content = Content::F32;
    source.valid = true;
  }
  A8TileMeta activation;
  check_status(activation_quantizer_compute(quant, id, source, qinput,
                                            aq, as, activation), "quant");
  std::vector<uint8_t> qbytes;
  for (unsigned r = 0; r < rows; ++r)
    for (unsigned g = 0; g < K / 32; ++g) {
      qbytes.push_back(uint8_t(as[r][g]));
      qbytes.push_back(uint8_t(as[r][g] >> 8));
      for (unsigned k = 0; k < 32; ++k) qbytes.push_back(uint8_t(aq[r][g][k]));
    }
  write_file(prefix + ".q8.bin", qbytes);
  if (!do_linear) {
    std::cout << "NUMERIC_CLI_PASS mode=" << mode << " rows=" << rows
              << " K=" << K << " groups=" << K / 32 << '\n';
    return 0;
  }

  if (n0 >= N || n0 % 8) fail("window n0");
  const unsigned cols = N - n0 < 8 ? N - n0 : 8;
  const auto weight_bytes = read_file(argv[3], cols * (K / 32) * 34);
  for (unsigned col = 0; col < cols; ++col)
    for (unsigned g = 0; g < K / 32; ++g) {
      const size_t at = (col * (K / 32) + g) * 34;
      ws[col][g] = uint16_t(weight_bytes[at]) |
                   (uint16_t(weight_bytes[at + 1]) << 8);
      for (unsigned k = 0; k < 32; ++k)
        wq[col][g][k] = int8_t(weight_bytes[at + 2 + k]);
    }
  const bool with_bias = mode == "act";
  if (with_bias) {
    const auto bias_bytes = read_file(argv[4], cols * 4);
    for (unsigned col = 0; col < cols; ++col)
      bias[col] = numeric_bits_f32(get32(&bias_bytes[col * 4]));
  }
  WeightBinding binding;
  hex_bytes(argv[17], binding.weight_sha256, 32);
  binding.weight_offset = number(argv[18]);
  binding.weight_bytes = uint32_t(number(argv[19]));
  if (with_bias) {
    hex_bytes(argv[20], binding.bias_sha256, 32);
    binding.bias_offset = number(argv[21]);
    binding.bias_bytes = uint32_t(number(argv[22]));
  } else if (std::string(argv[20]) != "-" || number(argv[21]) || number(argv[22]))
    fail("unexpected bias binding");
  LinearTask linear;
  linear.ctx = {12, linear_op, stage, layer, uint8_t(batch), space,
                uint16_t(row0), uint8_t(rows)};
  linear.a = quant.a_dst;
  linear.w = {Buffer::WEIGHT, 0, uint32_t(n0 / 8 + 1)};
  linear.ps = {Buffer::PS, 0, 1};
  linear.dst = {target_buffer, 0, 1};
  linear.weight = key; linear.K = uint16_t(K); linear.N = uint16_t(N);
  linear.dst_region = target_region; linear.bias_kind = uint8_t(with_bias);
  WeightWindowMeta window;
  window.identity = id; window.ref = linear.w; window.weight = key;
  window.binding = binding; window.K = uint16_t(K); window.N = uint16_t(N);
  window.n0 = uint16_t(n0); window.cols = uint8_t(cols);
  window.bias_kind = uint8_t(with_bias);
  numeric_cover_all(window.covered_groups, cols, K / 32, 8);
  window.state = CacheState::READY; window.content = Content::Q8_WEIGHT;
  window.valid = true;
  NumericWindowResult result;
  check_status(q8_linear_compute(linear, id, source, activation, window,
                                 binding, uint16_t(n0), uint8_t(cols),
                                 aq, as, wq, ws, bias, output, result,
                                 {true, 0, 0}, trace), "linear");
  nrequire(result.valid && result.output_elements == rows * cols &&
           result.output_beats == 0, "slice publication count");
  std::vector<uint8_t> ybytes, tbytes;
  for (unsigned r = 0; r < rows; ++r)
    for (unsigned col = 0; col < cols; ++col)
      put32(ybytes, numeric_f32_bits(output[r][col]));
  for (unsigned r = 0; r < rows; ++r)
    for (unsigned col = 0; col < cols; ++col) {
      NumericGroupTrace replay[128];
      check_status(q8_linear_trace(linear, id, source, activation, window,
                                   binding, uint16_t(n0), uint8_t(cols),
                                   uint8_t(r), uint8_t(col), aq, as, wq, ws,
                                   bias, replay), "trace replay");
      for (unsigned g = 0; g < K / 32; ++g) {
        if (r == 0 && col == 0)
          nrequire(replay[g].dot == trace[g].dot &&
                   replay[g].term_bits == trace[g].term_bits &&
                   replay[g].partial_bits == trace[g].partial_bits,
                   "compute versus replay trace");
        put32(tbytes, uint32_t(replay[g].dot));
        put32(tbytes, replay[g].term_bits);
        put32(tbytes, replay[g].partial_bits);
      }
    }
  write_file(prefix + ".linear.bin", ybytes);
  write_file(prefix + ".trace.bin", tbytes);
  std::cout << "NUMERIC_CLI_PASS mode=" << mode << " rows=" << rows
            << " K=" << K << " N=" << N << " n0=" << n0
            << " cols=" << cols << " groups=" << K / 32 << '\n';
}
