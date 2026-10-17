#pragma once

#include "laya_executor_checkpoint.h"
#include "laya_executor_handoff_protocol.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::executor {

enum class Phase : uint8_t {
  IDLE, WAIT_CHECKPOINT, WAIT_HELD, WRITE_CHECKPOINT, READ_CHECKPOINT,
  VALIDATE_CHECKPOINT, IMPORT_CHECKPOINT, WAIT_IMPORT_CONFIRMATION,
  WRITE_COMMAND, RUN_ACTION, WRITE_RESULT, WAIT_RESULT_CONSUMED, WAIT_ABORT, ISOLATED,
};

// Local controls from the unique shell. No Host proof field authorizes these
// fences. The top wrapper serializes the bound import confirmation separately.
struct Inputs {
  bool request_valid = false, checkpoint_valid = false, cancel = false;
  uint64_t session = 0, accepted_request = 0;
  bootstrap::AdmissionFence admission;
  BufferRef source;
  checkpoint::Fence fence;
  bool action_completion_consumed = false;
  bool control_request_consumed = false, control_response_valid = false;
  handoff::Message control_response;
  bool result_consumed = false;
};

struct State {
  // The sole executor runtime survives every request and checkpoint phase.
  full::FullRuntime runtime;
  lifecycle::Port port;
  bootstrap::State admission;
  checkpoint::State checkpoint;
  Phase phase = Phase::IDLE;
  Check error = ok();
  checkpoint::Packet checkpoint_request{}, checkpoint_response{};
  checkpoint::Response proof;
  program_wire::Command command;
  program_wire::CommandPacket command_packet{};
  program_wire::Result result;
  program_wire::ResultPacket result_packet{};
  unsigned beat = 0, result_beat = 0;
  bool request_seen = false, result_consumed_pending = false;
  bool import_pending = false, program_result_consumed = false;
  bool control_pending = false, control_sent = false, revoked = false;
  handoff::Message control_request;
  uint64_t session = 0, accepted_request_high_water = 0, control_rejections = 0;
  uint64_t admissions = 0, imports = 0, results = 0;
  uint64_t action_floor_at_command = 0;
  bootstrap::BaseBinding admitted_base;
};

void step(State&, const full::FullMemory&, const Inputs&,
          hls::stream<ap_uint<512>>& checkpoint_request,
          hls::stream<ap_uint<512>>& checkpoint_response,
          hls::stream<ap_uint<512>>& accepted_command,
          hls::stream<ap_uint<512>>& program_result,
          hls::stream<ap_uint<512>>& request_result,
          hls::stream<ap_uint<512>>& action_request,
          hls::stream<ap_uint<512>>& action_completion,
          hls::stream<ap_uint<512>>& transaction_request,
          hls::stream<ap_uint<512>>& transaction_completion);

} // namespace laya::executor
#endif
