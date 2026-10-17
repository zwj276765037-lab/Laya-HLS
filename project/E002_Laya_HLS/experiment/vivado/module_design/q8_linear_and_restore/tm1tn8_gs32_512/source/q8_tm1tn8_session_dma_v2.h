#pragma once

#include <cstdint>
#include "ap_int.h"
#include "hls_stream.h"

// Q8S2 candidate. The wrapper sends 18 binding_context beats from latched
// live BO inputs before the command may retire. Arithmetic streams and memory
// ports preserve the separate joint-prototype widths and ordering.
extern "C" void q8_tm1tn8_session_dma_v2(
    const uint32_t* descriptor,
    const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1,
    const ap_uint<512>* w_scale,
    const uint32_t* aux,
    const ap_uint<512>* activation,
    hls::stream<ap_uint<64>>& binding_context,
    hls::stream<ap_uint<256>>& writer_config,
    hls::stream<ap_uint<256>>& compute_config,
    hls::stream<ap_uint<288>>& bias_tiles,
    hls::stream<ap_uint<2816>>& group_issues,
    hls::stream<ap_uint<1>>& finish,
    hls::stream<ap_uint<512>>& writer_completion,
    uint32_t* observed);
