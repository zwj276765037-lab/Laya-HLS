#pragma once
#include "laya_tasks.h"
namespace laya::decision_scorer_act {
Check validate(const GatherTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
Check validate(const StatsTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
Check validate(const ConcatActTask&,uint16_t B,uint16_t S,uint32_t& output_elements);
}
