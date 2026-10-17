// Separate arithmetic verification top; excluded from stream OOC resources.
#include "tanh_libm_stream_bits.cpp"
void tanh_libm_stream_helper(uint32_t op,uint32_t a,uint32_t b,uint32_t &result) {
#pragma HLS interface ap_ctrl_hs port=return
#pragma HLS interface ap_none port=op
#pragma HLS interface ap_none port=a
#pragma HLS interface ap_none port=b
#pragma HLS interface ap_vld port=result
#pragma HLS pipeline II=1
    uint32_t sum=stream_fp_add_bits(op==0?a:0,op==0?b:0);
    uint32_t product=stream_fp_mul_bits(op==1?a:0,op==1?b:0);
    uint32_t quotient=stream_fp_div_bits(op==2?a:0,op==2?b:0x3f800000);
    result=op==0?sum:(op==1?product:quotient);
}
