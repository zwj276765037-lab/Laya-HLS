#pragma once
#include "laya_tasks.h"
namespace laya::attention_and_fp_engine {
Check validate(const QKTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
Check validate(const SoftmaxTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
Check validate(const AVTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
Check validate(const FPLinearTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
}
