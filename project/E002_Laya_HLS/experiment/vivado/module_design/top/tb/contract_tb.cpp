#include "contract_test.h"
#include "laya_forward.h"
#include <set>
#include <string>
int main(){using namespace laya;std::set<std::string> names;test::require(kModules.size()==15,"15 modules");for(const auto& m:kModules){test::require(names.insert(m.name).second,"unique module");test::require(!m.numerical_implemented&&std::string(m.level)=="contract_only","P0 status");}test::require(!forward_available(),"no false full forward");}
