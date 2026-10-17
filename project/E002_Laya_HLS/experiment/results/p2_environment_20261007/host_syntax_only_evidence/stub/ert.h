#pragma once
// Syntax-check stand-in only. Values are immaterial and do not emulate XRT.
enum ert_cmd_state {
  ERT_CMD_STATE_COMPLETED = 4,
  ERT_CMD_STATE_ABORT = 5,
  ERT_CMD_STATE_ERROR = 6,
  ERT_CMD_STATE_TIMEOUT = 8,
};
