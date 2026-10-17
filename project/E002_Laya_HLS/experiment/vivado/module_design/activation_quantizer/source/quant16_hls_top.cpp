#include "quant16_hls_top.h"

extern "C" void laya_quant16_functional(
    const laya::quant16::Task* task,
    const laya::F32TileMeta* source,
    const laya::quant16::Beat beats[4096],
    laya::quant16::AStore* output,
    laya::Check* result) {
  *result = laya::quant16::run(*task, *source, beats, *output);
}
