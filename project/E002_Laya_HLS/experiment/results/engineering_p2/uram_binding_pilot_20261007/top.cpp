#include <stdint.h>
struct Cache { int8_t weight_q[4096]; uint16_t weight_scale[128]; };
struct Runtime { Cache cache; };
static Runtime runtime;
extern "C" void top(const uint8_t* in, uint8_t* out, uint16_t offset) {
#pragma HLS INTERFACE m_axi port=in bundle=in
#pragma HLS INTERFACE m_axi port=out bundle=out
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS BIND_STORAGE variable=runtime.cache.weight_q type=ram_1p impl=uram
#pragma HLS BIND_STORAGE variable=runtime.cache.weight_scale type=ram_1p impl=uram
  for (unsigned i=0; i<4096; ++i) runtime.cache.weight_q[i] = in[i];
  for (unsigned i=0; i<128; ++i) runtime.cache.weight_scale[i] = in[4096 + i];
  for (unsigned i=0; i<128; ++i) out[i] = runtime.cache.weight_q[offset+i] + runtime.cache.weight_scale[i];
}
