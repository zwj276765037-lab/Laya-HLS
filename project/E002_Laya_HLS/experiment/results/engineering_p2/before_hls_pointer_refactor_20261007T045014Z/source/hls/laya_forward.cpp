#include "laya_forward.h"
#include <algorithm>

namespace laya {
const std::array<ModuleStatus,15> kModules{{
  {"top",false,"contract_only"},{"common",false,"contract_only"},{"kernel_wrapper",false,"contract_only"},
  {"forward_controller",false,"contract_only"},{"memory_map",false,"contract_only"},{"hbm_loader_and_cache",false,"contract_only"},
  {"embedding_engine",false,"contract_only"},{"layernorm_engine",false,"contract_only"},{"activation_quantizer",false,"contract_only"},
  {"q8_linear_and_restore",false,"contract_only"},{"rope_and_mask",false,"contract_only"},{"attention_and_fp_engine",false,"contract_only"},
  {"vector_and_ffn",false,"contract_only"},{"decision_scorer_act",false,"contract_only"},{"result_status",false,"contract_only"}
}};
bool all_numerical_implemented(){return std::all_of(kModules.begin(),kModules.end(),[](const ModuleStatus& m){return m.numerical_implemented;});}
bool forward_available(){return all_numerical_implemented();}
}
