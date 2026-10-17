#include "laya_packet_equal.h"
#include "laya_executor_actor.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::executor {
namespace {
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
template<std::size_t Bytes>
void store(std::array<uint8_t, Bytes>& p, unsigned beat, const ap_uint<512>& w) {
#pragma HLS inline off
  for (unsigned i = 0; i < 64; ++i) {
#pragma HLS unroll off
    p[beat * 64 + i] = uint8_t(w.range(i * 8 + 7, i * 8));
  }
}
template<std::size_t Bytes>
ap_uint<512> word(const std::array<uint8_t, Bytes>& p, unsigned beat) {
#pragma HLS inline off
  ap_uint<512> w = 0;
  for (unsigned i = 0; i < 64; ++i) {
#pragma HLS unroll off
    w.range(i * 8 + 7, i * 8) = p[beat * 64 + i];
  }
  return w;
}
bool live(const Inputs& in, const checkpoint::Request& r) {
  return !in.cancel && in.fence.physical_quiescent &&
      in.fence.predecessor_dispatch_held && in.fence.source_held &&
      in.fence.target_held && in.fence.handoff_epoch == r.handoff_epoch &&
      in.fence.base.epoch == r.source.base_epoch &&
      in.fence.base.address == r.source.base_address &&
      in.fence.base.capacity == r.source.base_capacity;
}
void isolate(State& s, Check c) {
  if (s.error) s.error = c;
  s.phase = Phase::ISOLATED;
}
void control(State& s, handoff::Kind kind, Check result, bool committed) {
  s.control_request.kind = kind; s.control_request.session = s.session;
  s.control_request.accepted_request = s.accepted_request_high_water;
  s.control_request.binding = s.checkpoint.pending;
  s.control_request.result = result; s.control_request.local_committed = committed;
  s.control_pending = true; s.control_sent = false;
}
void abort(State& s, Check c, bool committed) {
  if (s.error) s.error = c;
  control(s, handoff::Kind::ABORT, c, committed); s.phase = Phase::WAIT_ABORT;
}
bool response_key(const State& s, const handoff::Message& m) {
  return handoff::validate(m) && handoff::same_key(m, s.control_request);
}
bool result_binding(const State& s, const program_wire::Result& r) {
  constexpr uint32_t required = program_wire::FRAME_COMPLETE |
      program_wire::BINDING_OK | program_wire::SAFE_TERMINAL |
      program_wire::REQUEST_COMPLETE;
  if (s.cancel_consumer.phase == CancelPhase::DONE) {
    const auto& c = s.cancel_consumer.completion;
    program_wire::Result expected;
    expected.identity = c.identity; expected.entrypoint = s.command.entrypoint;
    expected.pc = c.pc; expected.flags = required;
    expected.action_ordinal = c.ordinal; expected.result = c.result;
    return s.revoked && !c.result && !c.retired_tasks &&
        !s.runtime.lifecycle_action.active && !s.runtime.generated_store.active &&
        s.runtime.tasks_retired == s.runtime.checkpoint_baseline.local_retired_at_import &&
        packet_equal(program_wire::encode(expected), s.result_packet);
  }
  if (r.flags & program_wire::LOCAL_REJECT) {
    program_wire::Result expected;
    expected.identity = s.runtime.inputs.identity;
    expected.entrypoint = s.command.entrypoint;
    expected.flags = required | program_wire::LOCAL_REJECT;
    expected.result = protocol();
    return s.revoked && !s.runtime.lifecycle_action.active &&
        !s.runtime.generated_store.active &&
        s.runtime.tasks_retired == s.runtime.checkpoint_baseline.local_retired_at_import &&
        s.port.machine.action_high_water == s.action_floor_at_command &&
        packet_equal(program_wire::encode(expected), s.result_packet);
  }
  if (!((r.flags & required) == required &&
      !(r.flags & program_wire::LOCAL_REJECT) &&
      numeric_identity_equal(r.identity, s.runtime.inputs.identity) &&
      r.entrypoint == s.command.entrypoint &&
      r.action_ordinal == s.port.machine.completion.ordinal &&
      r.result.code == s.port.machine.completion.result.code &&
      r.result.detail == s.port.machine.completion.result.detail &&
      r.result.bad_element == s.port.machine.completion.result.bad_element)) return false;
  program_wire::Result expected;
  const auto& c = s.port.machine.completion;
  expected.entrypoint = s.command.entrypoint;
  expected.pc = c.result ? c.pc + 1 : c.pc;
  expected.flags = required;
  expected.identity = s.runtime.inputs.identity;
  expected.action_ordinal = c.ordinal; expected.result = c.result;
  if (c.result) {
    expected.flags |= program_wire::SLOT_UPDATE_VALID;
    expected.slot_delta = c.slot_delta;
  }
  return packet_equal(program_wire::encode(expected), s.result_packet);
}

void observe_host_result(State& s, const Inputs& in) {
  if (!in.host_result_valid) return;
  program_wire::Result decoded;
  if (program_wire::decode(in.host_result, decoded) &&
      in.host_result == s.result_packet) s.managed_result_consumed = true;
  else ++s.control_rejections;
}

bool begin_cancel_consumer(State& s, const Inputs& in) {
  program_pending::Record record;
  program_pending::Key expected{s.session, s.accepted_request_high_water,
      s.checkpoint.pending.source.sequence, s.checkpoint.pending.handoff_epoch};
  Check decoded = program_pending::decode(in.cancel_drain_record, record);
  if (!decoded || !program_pending::same_key(record.key, expected) ||
      !packet_equal(program_wire::encode(record.command), s.command_packet) ||
      record.action.ordinal <= s.port.machine.action_high_water ||
      s.runtime.lifecycle_action.active || s.runtime.generated_store.active ||
      s.runtime.generated_store.source_lease_active ||
      s.port.machine.phase != lifecycle::Phase::IDLE ||
      s.port.phase != lifecycle::PortPhase::READ_ACTION || s.port.beat != 0) {
    isolate(s, decoded ? protocol() : decoded); return false;
  }
  s.cancel_consumer.owner = record;
  s.cancel_consumer.phase = CancelPhase::READ_ACTION;
  s.cancel_consumer.beat = 0; return true;
}
void cancel_consumer_step(State& s, bool consumed,
    hls::stream<ap_uint<512>>& actions,
    hls::stream<ap_uint<512>>& completions) {
  auto& p = s.cancel_consumer;
  switch (p.phase) {
    case CancelPhase::READ_ACTION: {
      ap_uint<512> w;
      if (!actions.read_nb(w)) return;
      store(p.packet, p.beat, w);
      if (++p.beat == action::kRequestBeats) {
        p.beat = 0; p.phase = CancelPhase::VALIDATE_ACTION;
      }
      return;
    }
    case CancelPhase::VALIDATE_ACTION: {
      action::Request decoded;
      Check c = action::decode(p.packet, decoded);
      if (!c || !packet_equal(p.packet, action::encode(p.owner.action)) ||
          decoded.ordinal <= s.port.machine.action_high_water) {
        isolate(s, c ? protocol() : c); return;
      }
      // This is trusted reception, not lifecycle start. The same high-water
      // used by normal reception prevents replay. No runtime/typed mutation.
      s.port.machine.action_high_water = decoded.ordinal;
      auto& done = p.completion;
      done = action::Completion{};
      done.kind = decoded.kind; done.pc = decoded.pc; done.op = decoded.op;
      done.stage = decoded.stage; done.layer = decoded.layer;
      done.ordinal = decoded.ordinal; done.identity = decoded.identity;
      done.flags = action::FRAME_COMPLETE | action::BINDING_OK |
          action::SAFE_TERMINAL | action::REMOTE_DRAINED | action::LOCAL_REJECT;
      done.result = s.error ? protocol() : s.error;
      p.completion_packet = action::encode(done);
      p.phase = CancelPhase::WRITE_COMPLETION; p.beat = 0;
      return;
    }
    case CancelPhase::WRITE_COMPLETION:
      if (completions.write_nb(word(p.completion_packet, p.beat)) &&
          ++p.beat == action::kCompletionBeats) {
        p.beat = 0; p.consumed_pending = consumed;
        p.phase = CancelPhase::WAIT_COMPLETION_CONSUMED;
      }
      return;
    case CancelPhase::WAIT_COMPLETION_CONSUMED:
      if (p.consumed_pending || consumed) {
        p.consumed_pending = false; p.phase = CancelPhase::DONE;
      }
      return;
    case CancelPhase::IDLE:
    case CancelPhase::DONE:
      return;
  }
}
} // namespace

void step(State& s, const full::FullMemory& memory, const Inputs& in,
          hls::stream<ap_uint<512>>& query,
          hls::stream<ap_uint<512>>& response,
          hls::stream<ap_uint<512>>& commands,
          hls::stream<ap_uint<512>>& program_results,
          hls::stream<ap_uint<512>>& results,
          hls::stream<ap_uint<512>>& actions,
          hls::stream<ap_uint<512>>& completions,
          hls::stream<ap_uint<512>>& transactions,
          hls::stream<ap_uint<512>>& transaction_completions) {
#pragma HLS pipeline off
  if (!in.request_valid) s.request_seen = false;
  // Immutable admission belongs to the actor for its entire lifetime,
  // including partial action frames, active work and result consumption.
  // Physical quiescence is deliberately not part of this check: accepted
  // work creates debt and must still finish its old completion/cleanup path.
  if (s.phase != Phase::IDLE && s.phase != Phase::ISOLATED) {
    const auto& b = s.admitted_base;
    if (in.cancel || in.session != s.session ||
        in.accepted_request != s.accepted_request_high_water ||
        in.fence.base.epoch != b.epoch || in.fence.base.address != b.address ||
        in.fence.base.capacity != b.capacity) s.revoked = true;
  }
  switch (s.phase) {
    case Phase::IDLE: {
      if (!in.request_valid || s.request_seen || in.cancel ||
          !in.admission.physical_quiescent || !in.admission.request_result_consumed)
        return;
      if (!in.session || !in.accepted_request ||
          (s.session && s.session != in.session) ||
          in.accepted_request <= s.accepted_request_high_water) {
        isolate(s, protocol()); return;
      }
      s.request_seen = true;
      Check c = bootstrap::admit_new(s.admission, s.port, s.runtime, memory, in.admission);
      if (!c) { isolate(s, c); return; }
      // Reset only request-local phases after successful authoritative
      // admission. All sequence, handoff, producer and action floors survive.
      s.checkpoint.phase = bootstrap::Phase::IDLE;
      s.checkpoint.pending = checkpoint::Request{};
      s.checkpoint.hold_reserved = false;
      s.beat = s.result_beat = 0; s.import_pending = false;
      s.program_result_consumed = false; s.result_consumed_pending = false;
      s.managed_result_consumed = false;
      s.session = in.session; s.accepted_request_high_water = in.accepted_request;
      s.admitted_base = in.fence.base;
      // A exists before any predecessor LPV or HOLD. The currently connected
      // single STATE0 domain uses the same locked base as the source fence;
      // callers with a complete physical map supply the other known roles.
      auto physical = in.physical_map;
      if (!physical.known_roles) {
        physical.known_roles = uint32_t(1) << unsigned(Bo::STATE0);
        physical.role[unsigned(Bo::STATE0)] =
            {in.fence.base.epoch,in.fence.base.address,in.fence.base.capacity};
      }
      c = admission_owner::capture(s.runtime,memory,in.session,in.accepted_request,
                                  physical,s.admitted_owner);
      s.admitted_owner_valid = bool(c);
      if (!c) { isolate(s,c); return; }

      s.revoked = false; s.control_pending = s.control_sent = false;
      s.managed_close = in.managed_close; s.request_committed = false;
      s.closed_consumed = false;
      s.cancel_consumer = CancelConsumer{};
      s.error = ok(); ++s.admissions; s.phase = Phase::WAIT_CHECKPOINT;
      return;
    }
    case Phase::WAIT_CHECKPOINT: {
      if (s.revoked) { isolate(s, protocol()); return; }
      if (!in.checkpoint_valid) return;
      checkpoint::Request binding;
      Check c = checkpoint::reserve_hold(s.checkpoint, s.port, s.runtime, memory,
                                         in.source, in.fence.base, binding);
      if (!c) return; // Old physical work may still be draining in the shell.
      control(s, handoff::Kind::HOLD, ok(), false);
      s.phase = Phase::WAIT_HELD; return;
    }
    case Phase::WAIT_HELD: {
      if (s.control_pending && in.control_request_consumed) {
        s.control_pending = false; s.control_sent = true;
      }
      if (!in.control_response_valid) return;
      auto expected = s.control_request;
      expected.binding.handoff_epoch = in.control_response.binding.handoff_epoch;
      if (!s.control_sent || !handoff::validate(in.control_response) ||
          !handoff::same_key(expected, in.control_response) ||
          (in.control_response.kind != handoff::Kind::HELD &&
           in.control_response.kind != handoff::Kind::REJECT) ||
          in.control_response.binding.handoff_epoch <= s.checkpoint.handoff_high_water) {
        ++s.control_rejections; return;
      }
      auto fence = in.fence; fence.cancel = fence.cancel || s.revoked;
      ++s.control_responses_consumed;
      checkpoint::Request binding;
      Check c = checkpoint::prepare_held(s.checkpoint, s.port, s.runtime, memory,
          in.control_response.binding, fence, binding);
      if (in.control_response.kind == handoff::Kind::REJECT || !c) {
        abort(s, in.control_response.kind == handoff::Kind::REJECT ?
                 in.control_response.result : c, false); return;
      }
      s.checkpoint_request = checkpoint::encode(binding);
      s.beat = 0; s.phase = Phase::WRITE_CHECKPOINT; return;
    }
    case Phase::WRITE_CHECKPOINT:
      // An already started frame is completed under its old binding even
      // after cancellation; the consumer rejects stale authority separately.
      if (query.write_nb(word(s.checkpoint_request, s.beat)) &&
          ++s.beat == checkpoint::kBeats) {
        s.beat = 0; s.phase = Phase::READ_CHECKPOINT;
      }
      return;
    case Phase::READ_CHECKPOINT: {
      ap_uint<512> w;
      if (!response.read_nb(w)) return;
      store(s.checkpoint_response, s.beat, w);
      if (++s.beat == checkpoint::kBeats) {
        s.beat = 0; s.phase = Phase::VALIDATE_CHECKPOINT;
      }
      return;
    }
    case Phase::VALIDATE_CHECKPOINT: {
      Check c = checkpoint::decode(s.checkpoint_response, s.checkpoint.pending, s.proof);
      if (!c || !s.proof.result) { abort(s, c ? s.proof.result : c, false); return; }
      s.phase = Phase::IMPORT_CHECKPOINT; return;
    }
    case Phase::IMPORT_CHECKPOINT: {
      if (s.revoked || in.cancel) { abort(s, protocol(), false); return; }
      Check c = checkpoint::accept(s.checkpoint, s.port, s.runtime, s.proof,
                                    in.fence, s.command);
      if (!c) { abort(s, c, false); return; }
      ++s.imports; s.import_pending = true; s.request_committed = true;
      s.command_packet = program_wire::encode(s.command);
      control(s, handoff::Kind::IMPORT_OK, ok(), true);
      s.phase = Phase::WAIT_IMPORT_CONFIRMATION; return;
    }
    case Phase::WAIT_IMPORT_CONFIRMATION:
      if (s.control_pending && in.control_request_consumed) {
        s.control_pending = false; s.control_sent = true;
      }
      if (s.revoked && s.control_sent) {
        // A bound old GRANT may already have been completely consumed while
        // revocation closed the start gate. Retire that response, never start.
        if (in.control_response_valid) {
          if (response_key(s, in.control_response) &&
              in.control_response.kind == handoff::Kind::GRANTED)
            ++s.control_responses_consumed;
          else ++s.control_rejections;
        }
        abort(s, protocol(), true); return;
      }
      if (!in.control_response_valid) return;
      if (!s.control_sent || !response_key(s, in.control_response) ||
          in.control_response.kind != handoff::Kind::GRANTED) {
        ++s.control_rejections; return;
      }
      ++s.control_responses_consumed;
      if (!live(in, s.checkpoint.pending)) { abort(s, protocol(), true); return; }
      s.import_pending = false; s.beat = 0;
      s.action_floor_at_command = s.port.machine.action_high_water;
      s.phase = Phase::WRITE_COMMAND; return;
    case Phase::WRITE_COMMAND:
      if ((s.revoked || !live(in, s.checkpoint.pending)) && !s.beat) {
        abort(s, protocol(), true); return;
      }
      if (!s.beat && !in.program_owner_confirmed) return;
      if (commands.write_nb(word(s.command_packet, s.beat)) &&
          ++s.beat == program_wire::kCommandBeats) {
        s.beat = 0; s.phase = Phase::RUN_ACTION;
      }
      return;
    case Phase::RUN_ACTION: {
      // Before an action has started, loss of the held dispatch/source/target
      // fence is also a persistent revocation.  A partially read frame still
      // drains under its original key; the port's cancel path prevents its
      // CLAIM/producer work.  Once active, ownership/fences may transfer and
      // physical debt is normal, so only immutable admission is sampled above.
      if ((s.port.phase == lifecycle::PortPhase::READ_ACTION ||
           s.port.phase == lifecycle::PortPhase::VALIDATE_ACTION) &&
          !live(in, s.checkpoint.pending)) s.revoked = true;
      // Only the original active action advances cleanup. A pending new
      // request never calls begin/admit or re-enters the action start path.
      // Select one consumer before any FIFO read. Once the normal port has
      // accepted a first beat, its original path owns the entire old frame.
      if (s.cancel_consumer.phase == CancelPhase::IDLE && s.revoked &&
          in.cancel_drain_valid && s.port.phase == lifecycle::PortPhase::READ_ACTION &&
          s.port.beat == 0 && s.port.machine.phase == lifecycle::Phase::IDLE) {
        if (!begin_cancel_consumer(s, in)) return;
      }
      if (s.cancel_consumer.phase != CancelPhase::IDLE) {
        cancel_consumer_step(s, in.action_completion_consumed, actions, completions);
        if (s.phase == Phase::ISOLATED) return;
      } else {
        lifecycle::port_step(s.port, s.runtime, memory, in.cancel || s.revoked,
            in.action_completion_consumed, actions, completions,
            transactions, transaction_completions);
      }
      if (s.port.phase == lifecycle::PortPhase::ISOLATED) {
        isolate(s, s.port.transport_error); return;
      }
      if (s.result_beat < program_wire::kResultBeats) {
        ap_uint<512> w;
        if (program_results.read_nb(w)) {
          store(s.result_packet, s.result_beat, w);
          ++s.result_beat;
        }
      }
      if (s.result_beat != program_wire::kResultBeats ||
          s.port.phase != lifecycle::PortPhase::READ_ACTION ||
          s.port.machine.phase != lifecycle::Phase::IDLE ||
          (s.cancel_consumer.phase != CancelPhase::IDLE &&
           s.cancel_consumer.phase != CancelPhase::DONE)) return;
      Check c = program_wire::decode(s.result_packet, s.result);
      if (!c || !result_binding(s, s.result)) {
        isolate(s, c ? protocol() : c); return;
      }
      s.program_result_consumed = true;
      s.beat = 0; s.phase = Phase::WRITE_RESULT; return;
    }
    case Phase::WRITE_RESULT:
      if (results.write_nb(word(s.result_packet, s.beat)) &&
          ++s.beat == program_wire::kResultBeats) {
        s.beat = 0; ++s.results;
        if (s.managed_close) observe_host_result(s, in);
        else s.result_consumed_pending = in.result_consumed;
        s.phase = Phase::WAIT_RESULT_CONSUMED;
      }
      return;
    case Phase::WAIT_RESULT_CONSUMED:
      if (s.managed_close) {
        observe_host_result(s, in);
        // A CLOSE intent does not assert physical drain. Only known local
        // program/port work and complete software queues are checked here;
        // the unique shell must independently retain the old physical owner.
        if (s.managed_result_consumed && !s.runtime.lifecycle_action.active &&
            !s.runtime.generated_store.active && !s.runtime.generated_store.source_lease_active &&
            s.program_result_consumed && commands.empty() && program_results.empty() &&
            actions.empty() && completions.empty() && results.empty() && query.empty() && response.empty() &&
            transactions.empty() && transaction_completions.empty()) {
          control(s, handoff::Kind::CLOSE, s.result.result, s.request_committed);
          s.phase = Phase::WAIT_CLOSE;
        }
        return;
      }
      if (in.result_consumed) s.result_consumed_pending = true;
      // Revoked results retain their consumed fact and all imported floors.
      // A result read alone is not the missing bound CLOSE/physical release
      // protocol. Keep this path closed until that protocol is connected.
      if (s.revoked) return;
      if ((s.result_consumed_pending || in.result_consumed) &&
          in.admission.physical_quiescent && !s.runtime.lifecycle_action.active &&
          !s.runtime.generated_store.active && !s.runtime.generated_store.source_lease_active) {
        s.result_consumed_pending = false; s.phase = Phase::IDLE;
      }
      return;
    case Phase::WAIT_ABORT:
      if (s.control_pending && in.control_request_consumed) {
        s.control_pending = false; s.control_sent = true;
      }
      if (!in.control_response_valid) return;
      if (!s.control_sent || !response_key(s, in.control_response) ||
          in.control_response.kind != handoff::Kind::ABORT_CLOSED ||
          s.control_request.local_committed || !in.admission.physical_quiescent) {
        ++s.control_rejections; return;
      }
      ++s.control_responses_consumed;
      if (s.revoked) { isolate(s, s.error); return; }
      s.checkpoint.phase = bootstrap::Phase::IDLE;
      s.checkpoint.pending = checkpoint::Request{}; s.checkpoint.hold_reserved = false;
      s.error = ok(); s.phase = Phase::WAIT_CHECKPOINT;
      return;
    case Phase::ISOLATED:
      return;
    case Phase::WAIT_CLOSE:
      if (s.control_pending && in.control_request_consumed) {
        s.control_pending = false; s.control_sent = true;
      }
      if (!in.control_response_valid) return;
      if (!s.control_sent || !response_key(s, in.control_response) ||
          in.control_response.kind != handoff::Kind::CLOSED ||
          in.control_response.local_committed != s.control_request.local_committed ||
          in.control_response.result.code != s.control_request.result.code ||
          in.control_response.result.detail != s.control_request.result.detail ||
          in.control_response.result.bad_element != s.control_request.result.bad_element) {
        ++s.control_rejections; return;
      }
      s.closed_record = in.control_response; s.closed_consumed = true;
      ++s.control_responses_consumed;
      ++s.closed_requests; s.phase = Phase::WAIT_NEW_ADMISSION;
      return;
    case Phase::WAIT_NEW_ADMISSION:
      // The bound new-candidate ingress transaction is a separate next step.
      // Neither restored inputs nor an old confirmation reopen this request.
      return;
  }
}
} // namespace laya::executor
#endif
