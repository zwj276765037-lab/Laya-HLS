#pragma once
#include "laya_io.h"

namespace laya::result_status {
Check encode_contract(const Result&,std::array<uint8_t,kResultBytes>&);
}
