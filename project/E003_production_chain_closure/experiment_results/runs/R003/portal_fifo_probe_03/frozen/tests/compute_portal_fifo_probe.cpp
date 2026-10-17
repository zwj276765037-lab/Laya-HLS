#include "ap_int.h"
#include "hls_stream.h"
#include <cstdint>

// Tool-interface probe only. The production controller uses the same names,
// directions, width, pragmas, and fixed 16-write/8-read transaction shape.
extern "C" uint32_t laya_compute_portal_fifo_probe(
    hls::stream<ap_uint<512>>& compute_cmd,
    hls::stream<ap_uint<512>>& compute_rsp) {
#pragma HLS INTERFACE ap_fifo port=compute_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=compute_rsp depth=2
#pragma HLS INTERFACE s_axilite port=return bundle=control
  ap_uint<512> word = 0;
  for (unsigned beat = 0; beat < 16; ++beat) {
    word.range(31, 0) = beat;
    compute_cmd.write(word);
  }
  uint32_t checksum = 0;
  for (unsigned beat = 0; beat < 8; ++beat) {
    const ap_uint<512> response = compute_rsp.read();
    checksum ^= uint32_t(response.range(31, 0));
  }
  return checksum;
}
