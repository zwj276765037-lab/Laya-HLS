#pragma once

#include "laya_controller_transaction_dispatch.h"
#include "laya_graph_action_protocol.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {

// Execute one already-decoded graph action.  The initial production subset is
// full BxS LayerNorm; every other family is rejected before task/ref tickets,
// owner state, or protocol sequences are consumed.
Check execute(full::FullRuntime&, full::FullMemory&,
              const action::Request&, action::Completion&,
              hls::stream<ap_uint<512>>& transaction_request,
              hls::stream<ap_uint<512>>& transaction_completion);

} // namespace laya::lifecycle
#endif
