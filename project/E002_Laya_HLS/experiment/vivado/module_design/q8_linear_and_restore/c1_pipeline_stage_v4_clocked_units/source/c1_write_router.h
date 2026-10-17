#pragma once

#include "c1_write_response.h"

namespace c1_write {
// The core owns exactly one expected token and one debt bit per physical port.
// It never accesses a burst_maxi object. The three writers are the sole owners.
enum Port : uint8_t { OUT0 = 0, OUT1 = 1, OBSERVED = 2 };

struct Router {
  CommandStream& out0_commands;
  CommandStream& out1_commands;
  CommandStream& observed_commands;
  AckStream& out0_acks;
  AckStream& out1_acks;
  AckStream& observed_acks;
  Credit out0;
  Credit out1;
  Credit observed;
  bool invalid;

  Router(CommandStream& o0c, CommandStream& o1c, CommandStream& obc,
         AckStream& o0a, AckStream& o1a, AckStream& oba)
      : out0_commands(o0c), out1_commands(o1c), observed_commands(obc),
        out0_acks(o0a), out1_acks(o1a), observed_acks(oba), invalid(false) {
    out0.reset_quiescent();
    out1.reset_quiescent();
    observed.reset_quiescent();
  }
  Credit& credit(Port port) {
    return port == OUT0 ? out0 : port == OUT1 ? out1 : observed;
  }
  CommandStream& commands(Port port) {
    return port == OUT0 ? out0_commands :
           port == OUT1 ? out1_commands : observed_commands;
  }
  // One logical edge. All admission snapshots precede any acknowledgment.
  bool edge(bool& observed_got, Ack& observed_ack) {
    out0.start_edge(); out1.start_edge(); observed.start_edge();
    bool got = false; Ack ignored = {};
    if (!out0.poll(out0_acks, got, ignored) ||
        !out1.poll(out1_acks, got, ignored) ||
        !observed.poll(observed_acks, observed_got, observed_ack))
      invalid = true;
    return !invalid;
  }
  bool submit(Port port, Command command) {
    return !invalid && credit(port).submit(commands(port), command,
                                            port == OBSERVED);
  }
  bool drained() const {
    return !invalid && out0.drained() && out1.drained() &&
           observed.drained();
  }
  // Used only outside the fixed-return interval: quant trace, final output,
  // report and EOS. The live result interval uses edge/submit without wait.
  bool send_and_wait(Port port, Command command) {
    bool submitted = false;
    while (true) {
      bool got = false; Ack ack = {};
      if (!edge(got, ack)) return false;
      if (!submitted) submitted = submit(port, command);
      else if (credit(port).drained()) return true;
    }
  }
};
}  // namespace c1_write
