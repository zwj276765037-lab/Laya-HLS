#include "front16.h"
#include "laya_numeric.h"

namespace {
constexpr unsigned kRows = 16;
constexpr unsigned kCols = 1024;
constexpr unsigned kGammaBase = 128;

uint32_t crc_byte(uint32_t crc, uint8_t byte) {
  crc ^= byte;
  for (unsigned bit = 0; bit < 8; ++bit)
    crc = (crc >> 1) ^ ((crc & 1u) ? 0x82f63b78u : 0u);
  return crc;
}

bool finite(uint32_t bits) { return (bits & 0x7f800000u) != 0x7f800000u; }

uint32_t byte_f32(const uint8_t* p, unsigned offset) {
  uint32_t bits = 0;
  for (unsigned b = 0; b < 4; ++b)
    bits |= uint32_t(p[offset + b]) << (8u * b);
  return bits;
}

void byte_store(uint8_t* p, unsigned offset, uint32_t bits) {
  for (unsigned b = 0; b < 4; ++b)
    p[offset + b] = uint8_t(bits >> (8u * b));
}

uint32_t wide_f32(ap_uint<512> beat, unsigned lane) {
  return static_cast<uint32_t>(beat.range(lane * 32 + 31, lane * 32));
}

void finish(uint32_t* observed, uint32_t status, uint32_t row,
            uint32_t col, uint32_t crc, uint64_t raw_bytes,
            uint64_t read_bytes, uint64_t gamma_bytes,
            uint64_t output_bytes) {
  uint32_t words[64] = {};
  words[0] = 0x31423146u;
  words[1] = 1;
  words[2] = status;
  words[3] = row;
  words[4] = col;
  words[5] = crc;
  words[6] = kRows;
  words[7] = kCols;
  const uint64_t counts[4] = {raw_bytes, read_bytes, gamma_bytes, output_bytes};
  for (unsigned i = 0; i < 4; ++i) {
    words[8 + i * 2] = uint32_t(counts[i]);
    words[9 + i * 2] = uint32_t(counts[i] >> 32);
  }
  for (unsigned i = 0; i < 64; ++i) observed[i] = words[i];
}

void run_byte(const uint8_t* state0, const uint8_t* aux,
              uint8_t* state1, uint32_t* observed) {
  uint32_t crc = 0xffffffffu;
  uint64_t raw_bytes = 0, read_bytes = 0, gamma_bytes = 0, output_bytes = 0;
  uint32_t status = 0, bad_row = 0xffffffffu, bad_col = 0xffffffffu;
  for (unsigned row = 0; row < kRows && !status; ++row) {
    for (unsigned col = 0; col < kCols; ++col) {
      const unsigned offset = (row * kCols + col) * 4;
      uint32_t bits = 0;
      for (unsigned b = 0; b < 4; ++b) {
        const uint8_t value = state0[offset + b];
        bits |= uint32_t(value) << (8u * b);
        crc = crc_byte(crc, value);
        ++raw_bytes;
      }
      if (!finite(bits)) {
        status = 1; bad_row = row; bad_col = col;
        break;
      }
    }
  }
  crc ^= 0xffffffffu;
  float gamma[kCols];
  for (unsigned col = 0; col < kCols && !status; ++col) {
    const uint32_t bits = byte_f32(aux, kGammaBase + col * 4);
    gamma_bytes += 4;
    if (!finite(bits)) {
      status = 2; bad_row = 0xffffffffu; bad_col = col;
      break;
    }
    gamma[col] = laya::numeric_bits_f32(bits);
  }
  float x[kCols], y[kCols];
  for (unsigned row = 0; row < kRows && !status; ++row) {
    for (unsigned col = 0; col < kCols; ++col) {
      x[col] = laya::numeric_bits_f32(byte_f32(state0, (row * kCols + col) * 4));
      read_bytes += 4;
    }
    float mean = 0, variance = 0, inverse = 0;
    const laya::Check check = laya::layernorm_row_arithmetic(
        laya::Op::LN_EMB, row, x, gamma, 1, y, mean, variance, inverse);
    if (!check) {
      status = 3; bad_row = row;
      bad_col = check.bad_element == UINT64_MAX ? 0xffffffffu :
                uint32_t(check.bad_element % kCols);
      break;
    }
    for (unsigned col = 0; col < kCols; ++col) {
      byte_store(state1, (row * kCols + col) * 4,
                 laya::numeric_f32_bits(y[col]));
      output_bytes += 4;
    }
  }
  finish(observed, status, bad_row, bad_col, crc, raw_bytes,
         read_bytes, gamma_bytes, output_bytes);
}

void run_wide(const ap_uint<512>* state0, const ap_uint<512>* aux,
              ap_uint<512>* state1, uint32_t* observed) {
  uint32_t crc = 0xffffffffu;
  uint64_t raw_bytes = 0, read_bytes = 0, gamma_bytes = 0, output_bytes = 0;
  uint32_t status = 0, bad_row = 0xffffffffu, bad_col = 0xffffffffu;
  // Each row is one 4 KiB page, so every explicit 64-beat run stays in-page.
  for (unsigned row = 0; row < kRows && !status; ++row) {
    for (unsigned beat_index = 0; beat_index < 64 && !status; ++beat_index) {
      const ap_uint<512> beat = state0[row * 64 + beat_index];
      for (unsigned lane = 0; lane < 16; ++lane) {
        const uint32_t bits = wide_f32(beat, lane);
        for (unsigned b = 0; b < 4; ++b) {
          crc = crc_byte(crc, uint8_t(bits >> (b * 8)));
          ++raw_bytes;
        }
        if (!finite(bits)) {
          status = 1; bad_row = row; bad_col = beat_index * 16 + lane;
          break;
        }
      }
    }
  }
  crc ^= 0xffffffffu;
  float gamma[kCols];
  for (unsigned beat_index = 0; beat_index < 64 && !status; ++beat_index) {
    const ap_uint<512> beat = aux[2 + beat_index];
    for (unsigned lane = 0; lane < 16; ++lane) {
      const uint32_t bits = wide_f32(beat, lane);
      gamma_bytes += 4;
      if (!finite(bits)) {
        status = 2; bad_col = beat_index * 16 + lane;
        break;
      }
      gamma[beat_index * 16 + lane] = laya::numeric_bits_f32(bits);
    }
  }
  float x[kCols], y[kCols];
  for (unsigned row = 0; row < kRows && !status; ++row) {
    for (unsigned beat_index = 0; beat_index < 64; ++beat_index) {
      const ap_uint<512> beat = state0[row * 64 + beat_index];
      for (unsigned lane = 0; lane < 16; ++lane) {
        x[beat_index * 16 + lane] =
            laya::numeric_bits_f32(wide_f32(beat, lane));
        read_bytes += 4;
      }
    }
    float mean = 0, variance = 0, inverse = 0;
    const laya::Check check = laya::layernorm_row_arithmetic(
        laya::Op::LN_EMB, row, x, gamma, 1, y, mean, variance, inverse);
    if (!check) {
      status = 3; bad_row = row;
      bad_col = check.bad_element == UINT64_MAX ? 0xffffffffu :
                uint32_t(check.bad_element % kCols);
      break;
    }
    for (unsigned beat_index = 0; beat_index < 64; ++beat_index) {
      ap_uint<512> beat = 0;
      for (unsigned lane = 0; lane < 16; ++lane) {
        const uint32_t bits = laya::numeric_f32_bits(y[beat_index * 16 + lane]);
        beat.range(lane * 32 + 31, lane * 32) = bits;
      }
      state1[row * 64 + beat_index] = beat;
      output_bytes += 64;
    }
  }
  finish(observed, status, bad_row, bad_col, crc, raw_bytes,
         read_bytes, gamma_bytes, output_bytes);
}
} // namespace

extern "C" void laya_front16_byte(const uint8_t* state0,
                                   const uint8_t* aux, uint8_t* state1,
                                   uint32_t* observed) {
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=gmem_state0 max_widen_bitwidth=32 max_read_burst_length=64 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=gmem_aux max_widen_bitwidth=32 max_read_burst_length=64 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=gmem_state1 max_widen_bitwidth=32 max_write_burst_length=64 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=gmem_observed max_write_burst_length=64 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
  run_byte(state0, aux, state1, observed);
}

extern "C" void laya_front16_wide(const ap_uint<512>* state0,
                                   const ap_uint<512>* aux,
                                   ap_uint<512>* state1, uint32_t* observed) {
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=gmem_state0 max_read_burst_length=64 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=gmem_aux max_read_burst_length=64 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=gmem_state1 max_write_burst_length=64 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=gmem_observed max_write_burst_length=64 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
  run_wide(state0, aux, state1, observed);
}
