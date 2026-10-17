#pragma once

#include "laya_compute_portal_dispatch.h"

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
namespace laya::full {

// Bounded production-path entry used to validate the generated Controller's
// split G -> LOAD -> Q -> parent MATRIX sequence before whole-graph wiring.
Check full_execute_g_down_portal(
    FullRuntime&, FullMemory&, const FullOwnerSpec& wide, uint8_t layer,
    hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream,
    FullOwnerSpec& down);

} // namespace laya::full
#endif

