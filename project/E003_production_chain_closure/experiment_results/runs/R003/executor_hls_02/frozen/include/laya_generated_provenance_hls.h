#pragma once

#include "laya_generated_provenance_client.h"

#if __has_include("ap_int.h") && __has_include("hls_stream.h")
#include "ap_int.h"
#include "hls_stream.h"
#define LAYA_GENERATED_PROVENANCE_HAS_HLS_STREAM 1

namespace laya::provenance {

void write_request(hls::stream<ap_uint<512>>&, const RequestWords&);
ResponseWords read_response(hls::stream<ap_uint<512>>&);
Check exchange(hls::stream<ap_uint<512>>& command_stream,
               hls::stream<ap_uint<512>>& response_stream,
               const Request&, Response&);

} // namespace laya::provenance
#endif
