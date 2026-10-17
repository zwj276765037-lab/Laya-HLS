#pragma once
#ifndef AP_INT_MAX_W
#define AP_INT_MAX_W 8192
#endif
#include "laya_executor_stream.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
// Internal FIRST candidate configuration comes from the actual wrapper's
// locked BO configuration, never from LYRQ proof flags. Each role has
// epoch/address/capacity in low-to-high consecutive 64-bit fields.
extern "C" void laya_task_lifecycle_executor(
    uint8_t* io, const uint8_t* aux,
    bool first_valid, uint64_t hardware_session,
    const ap_uint<2496>& physical_config, bool physical_safe, bool cancel,
    bool checkpoint_valid, uint32_t source_epoch,
    uint64_t handoff_epoch, bool predecessor_held, bool source_held,
    bool target_held,
    bool& first_ready, bool& admission_valid, bool& admission_rejected,
    bool& program_result_consumed,
    hls::stream<ap_uint<8192>>& control_response_receipt,
    hls::stream<ap_uint<8192>>& control_response_rejection,
    hls::stream<ap_uint<512>>& admission_owner,
    hls::stream<ap_uint<512>>& admission_owner_receipt,
    hls::stream<ap_uint<512>>& control_request,
    hls::stream<ap_uint<512>>& control_request_receipt,
    hls::stream<ap_uint<512>>& control_response,
    hls::stream<ap_uint<512>>& host_result_receipt,
    hls::stream<ap_uint<512>>& checkpoint_request,
    hls::stream<ap_uint<512>>& checkpoint_response,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& program_result,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion,
    hls::stream<ap_uint<512>>& transaction_request,
    hls::stream<ap_uint<512>>& transaction_completion,
    hls::stream<ap_uint<512>>& action_completion_receipt);
#endif
