#pragma once
#include <string>
namespace xrt { class device { public: explicit device(unsigned) {} std::string load_xclbin(const std::string&) { return {}; } }; }
