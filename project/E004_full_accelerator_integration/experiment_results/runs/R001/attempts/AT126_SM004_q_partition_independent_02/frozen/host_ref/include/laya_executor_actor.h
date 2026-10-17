#pragma once

#include "laya_executor_checkpoint.h"
#include "laya_admission_owner.h"
#include "laya_executor_handoff_protocol.h"
#include "laya_program_pending_protocol.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::executor {

enum class Phase : uint8_t {
  IDLE, WAIT_CHECKPOINT, WAIT_HELD, WRITE_CHECKPOINT, READ_CHECKPOINT,
  VALIDATE_CHECKPOINT, IMPORT_CHECKPOINT, WAIT_IMPORT_CONFIRMATION,
  WRITE_COMMAND, RUN_ACTION, WRITE_RESULT, WAIT_RESULT_CONSUMED, WAIT_ABORT, ISOLATED,
  WAIT_CLOSE, WAIT_NEW_ADMISSION,
};

// Local controls from the unique shell. No Host proof field authorizes these
// fences. The top wrapper serializes the bound import confirmation separately.
struct Inputs {
  bool request_valid = false, checkpoint_valid = false, cancel = false;
  uint64_t session = 0, accepted_request = 0;
  bootstrap::AdmissionFence admission;
  BufferRef source;
  // Actual locked BO configuration, independent of caller proof flags.
  admission_owner::PhysicalMap physical_map;
  checkpoint::Fence fence;
  bool action_completion_consumed = false;
  bool control_request_consumed = false, control_response_valid = false;
  handoff::Message control_response;
  bool result_consumed = false;
  // The owned hardware program installs the actual complete GRANTED record
  // before any LGP1 beat. Legacy actor fixtures use their existing binding.
  bool program_owner_confirmed = true;
  // Internal managed lifecycle; latched at real admission. The consumer
  // presents the full decoded Host result, not an untagged last-read pulse.
  bool managed_close = false, host_result_valid = false;
  program_wire::ResultPacket host_result{};
  // Full record from the bound program, presented only on the shell's
  // revoked old-command route. An untagged permission cannot drain an action.
  bool cancel_drain_valid = false;
  program_pending::Packet cancel_drain_record{};
};

enum class CancelPhase : uint8_t {
  IDLE, READ_ACTION, VALIDATE_ACTION, WRITE_COMPLETION,
  WAIT_COMPLETION_CONSUMED, DONE,
};
struct CancelConsumer {
  CancelPhase phase = CancelPhase::IDLE;
  program_pending::Record owner;
  action::RequestPacket packet{};
  action::Completion completion;
  action::CompletionPacket completion_packet{};
  unsigned beat = 0;
  bool consumed_pending = false;
};

struct State {
  State() = default;
  explicit State(full::ColdInitTag tag) : runtime(tag) {}
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
  // Managed consumption is established only by the complete bound record.
  // Keep it separate from the legacy untagged last-read notification.
  bool managed_result_consumed = false;
  bool import_pending = false, program_result_consumed = false;
  bool control_pending = false, control_sent = false, revoked = false;
  bool managed_close = false, request_committed = false, closed_consumed = false;
  handoff::Message closed_record;
  uint64_t closed_requests = 0;
  handoff::Message control_request;
  uint64_t session = 0, accepted_request_high_water = 0, control_rejections = 0;
  // The actual actor validator owns this semantic receipt count. A complete
  // transport read by itself cannot acknowledge GRANTED or release CLOSED.
  uint64_t control_responses_consumed = 0;
  uint64_t admissions = 0, imports = 0, results = 0;
  uint64_t action_floor_at_command = 0;
  bootstrap::BaseBinding admitted_base;
  admission_owner::Record admitted_owner;
  bool admitted_owner_valid = false;
  CancelConsumer cancel_consumer;
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
