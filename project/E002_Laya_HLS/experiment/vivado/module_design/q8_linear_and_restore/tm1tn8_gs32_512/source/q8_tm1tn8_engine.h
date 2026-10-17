#pragma once

#include <cstdint>
#include "ap_int.h"
#include "hls_stream.h"

// Tile stream [255:0] F32 bits, [267:256] n0, [269:268] row-local,
// [279:270] row0, [280] batch, [284:281] valid lanes, [285] QKV mode.
// Writer completion [0] fault, [64:1] out0 physical bytes,
// [128:65] out1 physical bytes. Completion may be returned only after both
// writers' real B responses and all input/diagnostic AXI debts are retired.
// Writer configuration carries out0 base/span, then out1 base/span, each U64.
extern "C" void q8_tm1tn8_engine(
    const uint32_t* descriptor,
    const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1,
    const ap_uint<512>* w_scale,
    const uint32_t* aux,
    const ap_uint<512>* activation,
    hls::stream<ap_uint<256>>& writer_config,
    hls::stream<ap_uint<288>>& out0_tiles,
    hls::stream<ap_uint<288>>& out1_tiles,
    hls::stream<ap_uint<1>>& finish,
    hls::stream<ap_uint<129>>& writer_completion,
    uint32_t* observed);
