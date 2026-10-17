#pragma once
#include <chrono>
#include <string>
#include "xrt_bo.h"
#include <ert.h>
namespace xrt {
class run {
 public:
  ert_cmd_state wait(const std::chrono::milliseconds& =
                         std::chrono::milliseconds{0}) const {
    return ERT_CMD_STATE_COMPLETED;
  }
  ert_cmd_state abort() { return ERT_CMD_STATE_ABORT; }
};
class kernel {
 public:
  kernel(device&, const std::string&, const char*) {}
  int group_id(unsigned) { return 0; }
  template<class... T> run operator()(T&&...) { return {}; }
};
}  // namespace xrt
