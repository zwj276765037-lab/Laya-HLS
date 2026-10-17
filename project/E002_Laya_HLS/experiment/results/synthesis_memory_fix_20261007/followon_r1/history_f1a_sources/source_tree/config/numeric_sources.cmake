# P1 isolated blocking numeric slice.  None of these sources link the P0
# ForwardController or its host-only containers into a synthesis top.
set(LAYA_NUMERIC_SOURCES
  hls/common/laya_numeric.cpp
  hls/operators/layernorm_compute.cpp
  hls/operators/activation_quantizer_compute.cpp
  hls/operators/q8_linear_compute.cpp
)
