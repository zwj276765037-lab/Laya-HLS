include(${CMAKE_CURRENT_LIST_DIR}/executor_actor_sources.cmake)
set(LAYA_EXECUTOR_HLS_SOURCES
  ${LAYA_EXECUTOR_ACTOR_SOURCES}
  hls/control/executor_hls.cpp
)
