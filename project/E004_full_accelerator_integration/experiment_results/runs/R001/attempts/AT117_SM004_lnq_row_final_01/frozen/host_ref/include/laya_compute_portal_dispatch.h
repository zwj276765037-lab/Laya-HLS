#pragma once

#include "laya_compute_portal_hls.h"

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
namespace laya::portal {

Check dispatch_load(hls::stream<ap_uint<512>>& command_stream,
                    hls::stream<ap_uint<512>>& response_stream,
                    const NumericIdentity&, const full::FullMemory&,
                    const ModelBinding&, const full::FullWeightDescriptor&,
                    const LoadTask&, uint64_t generation, TaskDone&);
Check dispatch_quant(hls::stream<ap_uint<512>>& command_stream,
                     hls::stream<ap_uint<512>>& response_stream,
                     const NumericIdentity&, const full::FullMemory&,
                     const ModelBinding&, const TaskBinding&,
                     uint64_t generation, TaskDone&);
Check dispatch_geglu(hls::stream<ap_uint<512>>& command_stream,
                     hls::stream<ap_uint<512>>& response_stream,
                     const NumericIdentity&, const full::FullMemory&,
                     const ModelBinding&, const VectorTask&,
                     const TaskBinding&, uint64_t generation, TaskDone&);
Check dispatch_matrix(hls::stream<ap_uint<512>>& command_stream,
                      hls::stream<ap_uint<512>>& response_stream,
                      const NumericIdentity&, const full::FullMemory&,
                      const ModelBinding&, const TaskBinding&,
                      const full::ViewTicket* views, uint8_t view_count,
                      TaskDone&);

} // namespace laya::portal
#endif

