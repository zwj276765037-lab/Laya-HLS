#include "ap_int.h"
#include "hls_stream.h"
#include <cstdint>

// Tool-interface probe for the production controller's four private FIFO
// arguments. It validates generated names/directions/polarity only.
extern "C" uint32_t laya_compute_provenance_fifo_probe(
    hls::stream<ap_uint<512>>& compute_cmd,
    hls::stream<ap_uint<512>>& compute_rsp,
    hls::stream<ap_uint<512>>& provenance_cmd,
    hls::stream<ap_uint<512>>& provenance_rsp) {
#pragma HLS INTERFACE ap_fifo port=compute_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=compute_rsp depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_cmd depth=2
#pragma HLS INTERFACE ap_fifo port=provenance_rsp depth=2
#pragma HLS INTERFACE s_axilite port=return bundle=control
  ap_uint<512> word = 0;
  for (unsigned beat = 0; beat < 16; ++beat) {
    word.range(31, 0) = beat;
    compute_cmd.write(word);
  }
  uint32_t checksum = 0;
  for (unsigned beat = 0; beat < 8; ++beat)
    checksum ^= uint32_t(compute_rsp.read().range(31, 0));
  for (unsigned beat = 0; beat < 16; ++beat) {
    word.range(31, 0) = beat + 16;
    provenance_cmd.write(word);
  }
  for (unsigned beat = 0; beat < 8; ++beat)
    checksum ^= uint32_t(provenance_rsp.read().range(31, 0));
  return checksum;
}
