#include "c1_write_response.h"

// Independent source-level HLS service for the three sole AXI write owners.
// A later generated RTL binding must connect three 618-bit command and
// three 37-bit acknowledgment channels to the clocked controller shell.
// This file is not the arithmetic return path and has not been synthesized.
extern "C" void c1_writer_service(
    hls::burst_maxi<uint32_t> out0,
    hls::burst_maxi<uint32_t> out1,
    hls::burst_maxi<uint32_t> observed,
    c1_write::CommandStream& out0_commands,
    c1_write::CommandStream& out1_commands,
    c1_write::CommandStream& observed_commands,
    c1_write::AckStream& out0_acks,
    c1_write::AckStream& out1_acks,
    c1_write::AckStream& observed_acks) {
#pragma HLS INTERFACE m_axi port=out0 offset=slave bundle=gmem_out0 max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=out1 offset=slave bundle=gmem_out1 max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=gmem_observed max_write_burst_length=16 num_write_outstanding=1
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS STREAM variable=out0_commands depth=1
#pragma HLS STREAM variable=out1_commands depth=1
#pragma HLS STREAM variable=observed_commands depth=1
#pragma HLS STREAM variable=out0_acks depth=1
#pragma HLS STREAM variable=out1_acks depth=1
#pragma HLS STREAM variable=observed_acks depth=1
#pragma HLS DATAFLOW
  c1_write::write_out0(out0,out0_commands,out0_acks);
  c1_write::write_out1(out1,out1_commands,out1_acks);
  c1_write::write_observed(observed,observed_commands,observed_acks);
}
