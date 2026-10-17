#include <stdint.h>

#ifndef N
#error N must be set by the experiment configuration
#endif
#ifndef INITIAL_FLAG
#error INITIAL_FLAG must be set by the experiment configuration
#endif

struct State {
  uint8_t flag;
  uint8_t data[N];
};

static State state = {INITIAL_FLAG, {}};

extern "C" uint16_t init_probe_top(unsigned index, uint8_t value) {
#pragma HLS INTERFACE s_axilite port=index bundle=control
#pragma HLS INTERFACE s_axilite port=value bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS BIND_STORAGE variable=state.data type=ram_1p impl=uram
  const unsigned i = index & (N - 1);
  const uint8_t old = state.data[i];
  const uint8_t oldflag = state.flag;
  state.data[i] = value;
  state.flag = static_cast<uint8_t>(state.flag ^ value);
  return static_cast<uint16_t>(old) |
         (static_cast<uint16_t>(oldflag) << 8);
}
