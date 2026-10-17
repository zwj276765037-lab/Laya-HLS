#pragma once

#include "laya_compute_portal_dispatch.h"
#include "laya_generated_provenance_hls.h"

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
namespace laya::full {

// Production generated-controller entry. The ordinary full_execute_request
// remains the CPU/reference path; this entry routes every supported physical
// LOAD/G/QUANT/MATRIX task through the two private ap_fifo streams.
Check full_execute_request_portal(
    FullRuntime&, FullMemory&,
    hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream);

// Bounded production-path entry used to validate the generated Controller's
// split G -> LOAD -> Q -> parent MATRIX sequence before whole-graph wiring.
Check full_execute_g_down_portal(
    FullRuntime&, FullMemory&, const FullOwnerSpec& wide, uint8_t layer,
    hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream,
    FullOwnerSpec& down);

// Bounded ordinary source path used to verify a previously published window
// ledger drives P -> Q -> parent L and all MATRIX views.
Check full_execute_linear_portal(
    FullRuntime&, FullMemory&, const FullOwnerSpec& source, Op op,
    WeightKey weight, uint8_t stage, uint8_t layer, BufferRef dst,
    uint8_t dst_region, hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream, FullOwnerSpec& output);

// Bounded generated-producer entry used to verify BEGIN -> exact task -> END
// ordering, store accounting, deferred retirement, and source completion.
Check full_execute_generated_vector_portal(
    FullRuntime&, FullMemory&, const FullOwnerSpec& source0,
    const FullOwnerSpec& source1, const VectorTask&, uint32_t elements,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream);

// Bounded production-path entry that additionally exercises the generated
// output owner's CLAIM/PUBLISH/RELEASE lifecycle around the exact task.  A
// failed task is invalidated only after its physical scope has drained.
Check full_execute_generated_vector_lifecycle_portal(
    FullRuntime&, FullMemory&, const FullOwnerSpec& source0,
    const FullOwnerSpec& source1, const FullOwnerSpec& output,
    const VectorTask&, uint32_t elements, bool release_output,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream);

} // namespace laya::full
#endif

