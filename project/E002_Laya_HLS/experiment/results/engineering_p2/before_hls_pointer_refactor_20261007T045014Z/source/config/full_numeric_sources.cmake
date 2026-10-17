# P2 A-batch blocking arithmetic leaves.  P0 host-only containers and P1
# compute sources are deliberately absent from this isolated source list.
set(LAYA_FULL_NUMERIC_SOURCES
  hls/common/laya_numeric.cpp
  hls/operators/embedding_full_compute.cpp
  hls/operators/rope_full_compute.cpp
  hls/operators/attention_full_compute.cpp
  hls/operators/vector_full_compute.cpp
  hls/operators/decision_full_compute.cpp
)
