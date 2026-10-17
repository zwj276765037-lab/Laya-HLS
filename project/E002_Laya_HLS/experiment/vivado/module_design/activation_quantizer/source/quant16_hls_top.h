#pragma once

#include "quant16.h"

// Functional HLS boundary for the independent 16-lane candidate. Physical
// FP latency, II and the eventual AXI/stream adapter remain to be measured.
extern "C" void laya_quant16_functional(
    const laya::quant16::Task* task,
    const laya::F32TileMeta* source,
    const laya::quant16::Beat beats[4096],
    laya::quant16::AStore* output,
    laya::Check* result);
