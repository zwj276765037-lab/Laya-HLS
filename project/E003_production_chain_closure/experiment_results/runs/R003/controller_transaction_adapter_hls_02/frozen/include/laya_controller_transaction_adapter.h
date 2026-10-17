#pragma once

#include "laya_controller_transaction_hls.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
extern "C" void laya_command_provenance_adapter(
    bool cancel,
    hls::stream<ap_uint<512>>& transaction_request,
    hls::stream<ap_uint<512>>& transaction_completion,
    hls::stream<ap_uint<512>>& compute_command,
    hls::stream<ap_uint<512>>& compute_response,
    hls::stream<ap_uint<512>>& provenance_command,
    hls::stream<ap_uint<512>>& provenance_response,
    hls::stream<ap_uint<512>>& producer_request,
    hls::stream<ap_uint<512>>& producer_completion);
#endif
