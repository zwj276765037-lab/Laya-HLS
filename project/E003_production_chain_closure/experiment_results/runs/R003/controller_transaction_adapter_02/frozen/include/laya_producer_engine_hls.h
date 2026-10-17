#pragma once

#include "laya_producer_engine.h"

#if __has_include("ap_int.h") && __has_include("hls_stream.h")
#include "ap_int.h"
#include "hls_stream.h"
#define LAYA_PRODUCER_ENGINE_HAS_HLS_STREAM 1

namespace laya::producer {

Request read_request(hls::stream<ap_uint<512>>&, Check&);
void write_request(hls::stream<ap_uint<512>>&, const Request&);
Completion read_completion(hls::stream<ap_uint<512>>&, const Request&, Check&);
void write_completion(hls::stream<ap_uint<512>>&, const Completion&);

Check exchange(hls::stream<ap_uint<512>>& request_stream,
               hls::stream<ap_uint<512>>& completion_stream,
               const Request&, Completion&);

} // namespace laya::producer
#endif
