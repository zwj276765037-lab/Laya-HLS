#pragma once

#ifndef AP_INT_MAX_W
#define AP_INT_MAX_W 8192
#endif
#include <ap_int.h>
#include <hls_stream.h>

namespace laya::owner_ct0 {

// Diagnostic-only ports. Packed records carry all 5009 semantic bits from
// source/design.md, including both 2048-bit row maps.
using Record = ap_uint<5009>;
using Identity = ap_uint<672>;
using Spec = ap_uint<144>;

enum Opcode : unsigned {
  LOAD = 0, CONTEXT = 1, READ = 2, REQUIRE = 3, ACQUIRE = 4,
  RELEASE_READ = 5
};

struct Command {
  ap_uint<3> op;
  ap_uint<5> index;
  Record record;
  Identity identity;
  Spec spec;
  ap_uint<1> request_valid;
  ap_uint<1> model_header_valid;
  ap_uint<3> type_valid;
  ap_uint<8> batch;
  ap_uint<16> row0;
  ap_uint<16> rows;
};

struct Response {
  ap_uint<16> status;
  ap_uint<32> detail;
  ap_uint<64> bad_element;
  ap_uint<5> index;
  ap_uint<32> commit_count;
  Record record;
};

} // namespace laya::owner_ct0

extern "C" void laya_owner_ct0(
    hls::stream<laya::owner_ct0::Command>& request,
    hls::stream<laya::owner_ct0::Response>& response);
