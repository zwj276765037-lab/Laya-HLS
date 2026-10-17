#pragma once

#include "laya_compute_portal_client.h"

#if __has_include("ap_int.h") && __has_include("hls_stream.h")
#include "ap_int.h"
#include "hls_stream.h"
#define LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM 1

namespace laya::portal {

void write_command(hls::stream<ap_uint<512>>& command_stream,
                   const CommandWords& words);
ResponseWords read_response(hls::stream<ap_uint<512>>& response_stream);

// Blocking one-command adapter used by the generated controller. Exactly 16
// command beats precede exactly 8 response beats; no object layout enters the
// FIFO protocol.
Check exchange(hls::stream<ap_uint<512>>& command_stream,
               hls::stream<ap_uint<512>>& response_stream,
               const Command& command, Response& response);

} // namespace laya::portal
#endif

