#pragma once
#include <array>

namespace laya {
struct ModuleStatus {const char* name;bool numerical_implemented;const char* level;};
extern const std::array<ModuleStatus,15> kModules;
bool all_numerical_implemented();
}
