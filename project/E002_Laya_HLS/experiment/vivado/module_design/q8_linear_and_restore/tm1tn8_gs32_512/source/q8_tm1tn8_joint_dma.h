#pragma once

#include <cstdint>
#include "ap_int.h"
#include "hls_stream.h"

// Active joint front: model/activation LOAD and two-pass quant are in HLS.
// Clocked RTL owns dot/restore/PS/bias/output/B retirement.
//
// group_issues[2815:0]: A8[255:0], 8 W8[2303:256], sa[2335:2304],
// 8 sw[2591:2336], tile[2600:2592], g[2606:2601], row[2608:2607],
// lane mask[2616:2609], trace[2617], trace lane[2620:2618],
// last_g[2621], task[2653:2622], PS epoch[2685:2654],
// destination epoch[2717:2686], request id[2781:2718].
// Bias tiles contain 8 F32 bits[255:0], tile[264:256], mask[272:265],
// bias kind[273]. No oracle PS/term/nextPS enters these streams.
// Completion[0] physical writer/protocol fault; [64:1],[128:65] physical
// output bytes; [129] numerical fault; [161:130] detail;
// [225:162] bad element; [257:226] retired groups;
// [289:258] committed valid F32 output writes; [353:290] valid MACs;
// [385:354] accepted issues; [449:418] selected trace group count.
extern "C" void q8_tm1tn8_joint_dma(
    const uint32_t* descriptor,
    const ap_uint<512>* w_q0,
    const ap_uint<512>* w_q1,
    const ap_uint<512>* w_scale,
    const uint32_t* aux,
    const ap_uint<512>* activation,
    hls::stream<ap_uint<256>>& writer_config,
    hls::stream<ap_uint<256>>& compute_config,
    hls::stream<ap_uint<288>>& bias_tiles,
    hls::stream<ap_uint<2816>>& group_issues,
    hls::stream<ap_uint<1>>& finish,
    hls::stream<ap_uint<512>>& writer_completion,
    uint32_t* observed);
