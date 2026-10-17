#pragma once

#include "laya_compute_portal_client.h"
#include "laya_controller_transaction_hls.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::transaction {

Check exchange_compute(hls::stream<ap_uint<512>>& request_stream,
                       hls::stream<ap_uint<512>>& completion_stream,
                       const portal::Command&, portal::Response&,
                       uint32_t* completion_flags = nullptr);
Check exchange_provenance(hls::stream<ap_uint<512>>& request_stream,
                          hls::stream<ap_uint<512>>& completion_stream,
                          const provenance::Request&, provenance::Response&,
                          uint32_t* completion_flags = nullptr);
Check exchange_producer(hls::stream<ap_uint<512>>& request_stream,
                        hls::stream<ap_uint<512>>& completion_stream,
                        const producer::Request&, producer::Completion&,
                        uint32_t* completion_flags = nullptr);

Check dispatch_load(hls::stream<ap_uint<512>>& request_stream,
                    hls::stream<ap_uint<512>>& completion_stream,
                    const NumericIdentity&, const full::FullMemory&,
                    const portal::ModelBinding&,
                    const full::FullWeightDescriptor&, const LoadTask&,
                    uint64_t generation, TaskDone&);
Check dispatch_quant(hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream,
                     const NumericIdentity&, const full::FullMemory&,
                     const portal::ModelBinding&, const portal::TaskBinding&,
                     uint64_t generation, TaskDone&);
Check dispatch_geglu(hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream,
                     const NumericIdentity&, const full::FullMemory&,
                     const portal::ModelBinding&, const VectorTask&,
                     const portal::TaskBinding&, uint64_t generation,
                     TaskDone&);
Check dispatch_matrix(hls::stream<ap_uint<512>>& request_stream,
                      hls::stream<ap_uint<512>>& completion_stream,
                      const NumericIdentity&, const full::FullMemory&,
                      const portal::ModelBinding&, const portal::TaskBinding&,
                      const full::ViewTicket* views, uint8_t view_count,
                      TaskDone&);

} // namespace laya::transaction
#endif
