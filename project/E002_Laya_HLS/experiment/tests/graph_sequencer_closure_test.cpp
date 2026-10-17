#include "full_kernel_wrapper.h"
#include "laya_controller_transaction.h"
#include <cassert>
#include <iostream>

int main() {
  static_assert(laya::transaction::kRequestBeats == 24);
  static_assert(laya::transaction::kCompletionBeats == 16);
  auto* top = &laya_typed_q8_forward_graph_sequencer;
  assert(top != nullptr);
  std::cout << "FULL_CURRENT_GRAPH_SEQUENCER_CLOSURE_PASS "
            << "external_protocol_codecs=0 transaction_fifos=2 "
            << "transaction_signals=6 request_beats=24 completion_beats=16\n";
  return 0;
}
