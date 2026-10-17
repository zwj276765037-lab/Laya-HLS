#pragma once

#include "laya_graph_program_protocol.h"

#if __has_include("ap_int.h") && __has_include("hls_stream.h")
#include "ap_int.h"
#include "hls_stream.h"
#define LAYA_GRAPH_PROGRAM_HAS_HLS_STREAM 1

extern "C" void laya_graph_program_sequencer(
    bool cancel, bool result_consumed,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion);
#endif
