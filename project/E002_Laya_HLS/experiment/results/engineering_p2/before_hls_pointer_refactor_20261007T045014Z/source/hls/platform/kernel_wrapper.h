#pragma once
#include "laya_io.h"
#include <array>

namespace laya::kernel_wrapper {
struct Port {const char* name;Bo bo;uint8_t candidate_hbm;};
extern const std::array<Port,kBoCount> ports;
Check validate_offline(const std::vector<uint8_t>&,Request&);
Check validate_strict(const std::vector<uint8_t>&,const Identity&,Request&);
}
