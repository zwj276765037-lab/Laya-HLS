#pragma once

#include "laya_task_lifecycle_fsm.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {

// Private action transport around the shared lifecycle machine.  The runtime
// passed here belongs to the executor; it is never an inter-partition port.
enum class PortPhase : uint8_t {
  READ_ACTION, VALIDATE_ACTION, EXECUTE, WRITE_COMPLETION,
  WAIT_COMPLETION_CONSUMED, ISOLATED,
};

struct Port {
  PortPhase phase = PortPhase::READ_ACTION;
  Machine machine;
  action::RequestPacket request_packet{};
  action::CompletionPacket completion_packet{};
  unsigned beat = 0;
  bool consumed_pending = false;
  Check transport_error = ok();
};

void port_step(Port&, full::FullRuntime&, const full::FullMemory&,
               bool cancel, bool completion_consumed,
               hls::stream<ap_uint<512>>& action_request,
               hls::stream<ap_uint<512>>& action_completion,
               hls::stream<ap_uint<512>>& transaction_request,
               hls::stream<ap_uint<512>>& transaction_completion);

} // namespace laya::lifecycle
#endif
