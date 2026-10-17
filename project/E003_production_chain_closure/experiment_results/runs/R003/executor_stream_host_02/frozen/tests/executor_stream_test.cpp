#include "laya_executor_stream.h"
#include "laya_graph_program_state.h"
#include "lifecycle_fixture_helpers.h"
#include <algorithm>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

using namespace laya;
using namespace lifecycle_fixture;
namespace {
std::vector<uint8_t> bytes(const std::string& path) {
  std::ifstream input(path, std::ios::binary); assert(input);
  return {std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
}
template<std::size_t Bytes>
std::array<uint8_t, Bytes> literal(const std::string& path) {
  const auto data = bytes(path); assert(data.size() == Bytes);
  std::array<uint8_t, Bytes> packet{};
  std::copy(data.begin(), data.end(), packet.begin()); return packet;
}
template<std::size_t Bytes> struct Consumer {
  std::array<uint8_t, Bytes> packet{};
  unsigned reads = 0;
  void read(hls::stream<ap_uint<512>>& stream) {
    assert(reads < Bytes / 64 && !stream.empty());
    const auto word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[reads * 64 + byte] = uint8_t(word.range(byte * 8 + 7, byte * 8));
    ++reads;
  }
};

// Software consumers really pop every beat, decode the complete record, and
// echo that record. Remote shell fences and producer terminals are controlled
// host fixtures; this harness makes no physical or finite-depth claim.
struct Harness {
  std::unique_ptr<executor::State> state = std::make_unique<executor::State>();
  executor_stream::Transport transport;
  executor::Inputs in;
  full::FullMemory ports;
  std::vector<uint8_t> io, aux;
  program_hls::State program;
  Streams tx;
  hls::stream<ap_uint<512>> control_request, control_request_receipt;
  hls::stream<ap_uint<512>> control_response, host_result_receipt;
  hls::stream<ap_uint<512>> query, proof, commands, program_results;
  hls::stream<ap_uint<512>> results, actions, completions;
  hls::stream<ap_uint<512>> action_completion_receipt;
  bool action_consumed = false;
  action::CompletionPacket completion_echo{};
  unsigned completion_echo_beats = 0, completion_echo_wait = 0;
  bool completion_echo_valid = false;
  uint64_t producer_frames = 0, provenance_frames = 0;
  uint64_t shell_closed_releases = 0, shell_grants_consumed = 0;
  unsigned request_tail_waits = 0, response_tail_waits = 0;
  const std::string fixture;

  explicit Harness(const std::string& directory): fixture(directory) {
    io = bytes(fixture + "/v2/v1/request.bin");
    aux = bytes(fixture + "/v2/v1/aux_header.bin");
    ports = memory(); ports.io = io.data(); ports.io_bytes = io.size(); ports.aux = aux.data();
    in.request_valid = true; in.session = 29; in.accepted_request = 101;
    in.admission = {true, true}; in.source = {Buffer::HIDDEN, 0, 1};
    in.fence.base = {7, 0x1200000000ull, 16920576}; in.fence.handoff_epoch = 19;
  }
  void call(bool receipt_ready = false) {
    in.action_completion_consumed = action_consumed;
    executor_stream::step(*state, transport, ports, in, receipt_ready,
      control_request, control_request_receipt, control_response, host_result_receipt,
      query, proof, commands, program_results, results, actions, completions,
      tx.transaction_request, tx.transaction_completion, action_completion_receipt);
  }
  void program_call() {
    call();
    laya_command_provenance_adapter(in.cancel || state->revoked,
      tx.transaction_request, tx.transaction_completion, tx.compute_command,
      tx.compute_response, tx.provenance_command, tx.provenance_response,
      tx.producer_request, tx.producer_completion);
    if (tx.provenance_command.size() >= provenance::kRequestBeats) {
      provenance::Request request;
      assert(provenance::decode(dequeue<provenance::kRequestBytes>(tx.provenance_command), request));
      ++provenance_frames;
      enqueue(tx.provenance_response, provenance::encode(provenance_response(request)));
    }
    if (tx.producer_request.size() >= producer::kRequestBeats) {
      producer::Request request;
      assert(producer::decode(dequeue<producer::kRequestBytes>(tx.producer_request), request));
      ++producer_frames; enqueue(tx.producer_completion, producer::encode(producer_success(request)));
    }
    const bool validates_completion = program.phase == program_hls::Phase::ACCEPT_COMPLETION;
    const program_pending::Key key{state->session, state->accepted_request_high_water,
      state->checkpoint.pending.source.sequence, state->checkpoint.pending.handoff_epoch};
    program_hls::step(program, in.cancel || state->revoked,
      state->program_result_consumed, &key, commands, program_results, actions, completions);
    if (validates_completion && !program.graph.action_active &&
        program.phase == program_hls::Phase::WRITE_RESULT) {
      action::Completion decoded;
      assert(action::decode(program.completion_packet, decoded));
      assert(numeric_identity_equal(decoded.identity, state->runtime.inputs.identity));
      assert(!completion_echo_valid && !action_consumed);
      completion_echo = program.completion_packet;
      completion_echo_valid = true;
      action_consumed = true; // Legacy bool remains asserted to test the bridge's clearing.
    }
    if (completion_echo_valid) {
      if (completion_echo_wait) {
        --completion_echo_wait;
        assert(state->port.phase == lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED && results.empty());
      } else {
        action_completion_receipt.write(pack(completion_echo, completion_echo_beats));
        if (++completion_echo_beats == 4) completion_echo_valid = false;
        else if (completion_echo_beats == 2 || completion_echo_beats == 3) completion_echo_wait = 12;
      }
    }
  }
  void idle(unsigned cycles = 12) { for (unsigned i = 0; i < cycles; ++i) call(); }
  void no_start() {
    assert(commands.empty() && actions.empty() && tx.transaction_request.empty() &&
      !state->runtime.tasks_retired && !state->runtime.owner_claims && !state->runtime.owner_leases);
  }
  void start_hold() {
    // All legacy facts are deliberately asserted. The production bridge must
    // clear them before invoking the actor, even on final-write transitions.
    in.control_request_consumed = true; in.control_response_valid = true;
    in.result_consumed = true; in.host_result_valid = true;
    call();
    assert(state->admissions == 1 && transport.first_admitted && state->admitted_owner_valid &&
      state->phase == executor::Phase::WAIT_CHECKPOINT && state->managed_close &&
      admission_owner::encode(state->admitted_owner) == literal<1024>(fixture + "/admission_owner.bin"));
    in.request_valid = false; in.checkpoint_valid = true; call();
    assert(state->phase == executor::Phase::WAIT_HELD && state->control_pending &&
      !state->control_sent && state->checkpoint.hold_reserved && state->checkpoint.sequence_high_water == 1);
    assert(transport.control_packet == literal<1024>(fixture + "/control_1.bin"));
    idle(); assert(query.empty() && state->control_pending); no_start();
  }
  handoff::Packet read_control(handoff::Kind kind, bool stall = true) {
    Consumer<handoff::kBytes> consumer;
    for (unsigned beat = 0; beat < handoff::kBeats; ++beat) {
      for (unsigned wait = 0; control_request.empty() && wait < 40; ++wait) call();
      consumer.read(control_request); call();
      if (stall && (consumer.reads == 14 || consumer.reads == 15)) {
        const auto accepted = transport.control_receipts;
        idle(); request_tail_waits += 12;
        assert(transport.control_receipts == accepted && state->control_pending);
      }
    }
    handoff::Message decoded;
    assert(handoff::decode(consumer.packet, decoded) && decoded.kind == kind &&
      handoff::encode(decoded) == consumer.packet && control_request.empty());
    assert(consumer.packet == handoff::encode(state->control_request));
    return consumer.packet;
  }
  void echo_control(const handoff::Packet& packet, bool stall = true) {
    const auto before = transport.control_receipts;
    for (unsigned beat = 0; beat < 16; ++beat) {
      control_request_receipt.write(pack(packet, beat)); call();
      if (stall && (beat == 13 || beat == 14)) {
        idle(); request_tail_waits += 12;
        assert(transport.control_receipts == before);
      }
    }
    assert(transport.control_receipts == before); call();
  }
  void send_response(const handoff::Packet& packet, bool stall = true) {
    assert(!transport.response.complete && !transport.response_receipt_valid);
    const auto accepted = state->control_responses_consumed;
    for (unsigned beat = 0; beat < 16; ++beat) {
      control_response.write(pack(packet, beat)); call();
      if (stall && (beat == 13 || beat == 14)) {
        idle(); response_tail_waits += 12;
        assert(state->control_responses_consumed == accepted && !transport.response_receipt_valid);
      }
    }
    assert(state->control_responses_consumed == accepted && !transport.response_receipt_valid);
    call();
  }
  void take_response_receipt(const handoff::Packet& packet, bool accepted,
                             bool stall = true, bool decodable = true) {
    assert(transport.response_receipt_valid && transport.response_receipt == packet &&
      transport.response_receipt_accepted == accepted);
    const auto releases = shell_closed_releases;
    if (stall) for (unsigned i = 0; i < 12; ++i) {
      call();
      assert(transport.response_receipt_valid && transport.response_receipt == packet &&
        transport.response_receipt_accepted == accepted && shell_closed_releases == releases);
    }
    // This is a complete-record shell consumer. Rejected notifications are
    // read without releasing any lock or granting authority.
    handoff::Message decoded;
    const bool valid = bool(handoff::decode(packet, decoded));
    assert(valid == decodable && (!accepted || valid));
    if (accepted && decoded.kind == handoff::Kind::CLOSED) ++shell_closed_releases;
    if (accepted && decoded.kind == handoff::Kind::GRANTED) ++shell_grants_consumed;
    call(true); assert(!transport.response_receipt_valid);
  }
  void held(bool response_first = false) {
    const auto request = read_control(handoff::Kind::HOLD);
    assert(request == literal<1024>(fixture + "/control_1.bin"));
    const auto response = literal<1024>(fixture + "/control_2.bin");
    in.fence.physical_quiescent = in.fence.predecessor_dispatch_held =
      in.fence.source_held = in.fence.target_held = true;
    if (response_first) {
      send_response(response);
      idle();
      assert(transport.response.complete && !transport.response_receipt_valid &&
        !state->control_responses_consumed && state->phase == executor::Phase::WAIT_HELD && query.empty());
      echo_control(request);
    } else { echo_control(request); send_response(response); }
    assert(transport.control_receipts == 1 && state->control_responses_consumed == 1 &&
      state->phase == executor::Phase::WRITE_CHECKPOINT);
    take_response_receipt(response, true);
  }
  void checkpoint() {
    Consumer<checkpoint::kBytes> consumer;
    for (unsigned beat = 0; beat < 16; ++beat) {
      for (unsigned wait = 0; query.empty() && wait < 40; ++wait) call();
      consumer.read(query); call();
      if (beat == 13 || beat == 14) { idle(); assert(!state->imports); no_start(); }
    }
    checkpoint::Request request;
    assert(checkpoint::decode(consumer.packet, request) &&
      consumer.packet == literal<1024>(fixture + "/v2/checkpoint_request.bin"));
    const auto response = literal<1024>(fixture + "/v2/checkpoint_response.bin");
    checkpoint::Response decoded; assert(checkpoint::decode(response, request, decoded));
    for (unsigned beat = 0; beat < 16; ++beat) {
      proof.write(pack(response, beat)); call();
      if (beat == 13 || beat == 14) {
        idle(); assert(!state->imports && !state->runtime.checkpoint_baseline.valid); no_start();
      }
    }
    assert(state->phase == executor::Phase::VALIDATE_CHECKPOINT && !state->imports); no_start();
    call(); assert(state->phase == executor::Phase::IMPORT_CHECKPOINT && !state->imports);
    call();
    assert(state->phase == executor::Phase::WAIT_IMPORT_CONFIRMATION && state->imports == 1 &&
      state->runtime.checkpoint_baseline.valid && state->runtime.last_task_id == decoded.task_floor &&
      state->runtime.provenance_event_high_water == decoded.lpv_floor && state->request_committed);
    no_start();
    assert(handoff::encode(state->control_request) == literal<1024>(fixture + "/control_3.bin"));
  }
  void grant(bool negatives = false, bool stall_receipt = true) {
    const auto request = read_control(handoff::Kind::IMPORT_OK);
    echo_control(request);
    const auto response = literal<1024>(fixture + "/control_4.bin");
    if (negatives) for (unsigned which = 0; which < 5; ++which) {
      handoff::Message wrong; assert(handoff::decode(response, wrong));
      if (which == 0) ++wrong.session;
      if (which == 1) --wrong.accepted_request;
      if (which == 2) ++wrong.binding.source.sequence;
      if (which == 3) ++wrong.binding.handoff_epoch;
      if (which == 4) ++wrong.binding.source.identity.request_id;
      const auto packet = handoff::encode(wrong); send_response(packet, false);
      assert(state->phase == executor::Phase::WAIT_IMPORT_CONFIRMATION && state->imports == 1);
      no_start(); take_response_receipt(packet, false);
    }
    const auto before = state->control_responses_consumed;
    send_response(response);
    assert(state->phase == executor::Phase::WRITE_COMMAND &&
      state->control_responses_consumed == before + 1);
    take_response_receipt(response, true, stall_receipt);
  }
  void complete_program(bool canceled = false) {
    for (unsigned cycle = 0; cycle < 10000 &&
         state->phase != executor::Phase::WAIT_RESULT_CONSUMED; ++cycle) program_call();
    assert(state->phase == executor::Phase::WAIT_RESULT_CONSUMED && results.size() == 4 &&
      state->program_result_consumed && !state->managed_result_consumed && !state->control_pending);
    assert(commands.empty() && program_results.empty() && actions.empty() && completions.empty());
    if (canceled) assert(!state->result.result && !state->runtime.tasks_retired && !producer_frames &&
      (state->result.flags & program_wire::LOCAL_REJECT));
    else assert(state->result.result && state->runtime.tasks_retired == 4 &&
      state->runtime.last_task_id == 8 && producer_frames == 4 && action_consumed &&
      transport.action_receipts == 1 && transport.action_receipt_reads == 4 &&
      completion_echo_beats == 4 && !completion_echo_valid);
  }
  void send_host_receipt(const program_wire::ResultPacket& packet, bool stall = true) {
    const auto accepted = transport.host_receipts;
    for (unsigned beat = 0; beat < 4; ++beat) {
      host_result_receipt.write(pack(packet, beat)); call();
      if (stall && (beat == 1 || beat == 2)) {
        idle(); assert(transport.host_receipts == accepted && !state->managed_result_consumed);
      }
    }
    assert(transport.host_receipts == accepted); call();
  }
  handoff::Packet host_consume() {
    const auto expected = state->result_packet;
    // A complete echo while the Host has not read the result is early.
    send_host_receipt(expected, false);
    assert(transport.rejected_host_receipts == 1 && !transport.host_receipts && !state->control_pending);
    Consumer<program_wire::kResultBytes> consumer;
    for (unsigned beat = 0; beat < 4; ++beat) {
      consumer.read(results); call();
      if (beat == 1 || beat == 2) {
        idle(); assert(state->phase == executor::Phase::WAIT_RESULT_CONSUMED &&
          !state->control_pending && !transport.control_active && control_request.empty());
      }
    }
    program_wire::Result decoded;
    assert(program_wire::decode(consumer.packet, decoded) && consumer.packet == expected);
    idle(); assert(!state->managed_result_consumed && !state->control_pending);
    auto wrong = decoded; ++wrong.identity.request_id;
    send_host_receipt(program_wire::encode(wrong), false);
    assert(transport.rejected_host_receipts == 2 && !transport.host_receipts && !state->control_pending);
    send_host_receipt(consumer.packet);
    assert(transport.host_receipts == 1 && state->managed_result_consumed &&
      state->phase == executor::Phase::WAIT_CLOSE && state->control_pending);
    send_host_receipt(consumer.packet, false);
    assert(transport.host_receipts == 1 && transport.rejected_host_receipts == 3);
    const auto close = read_control(handoff::Kind::CLOSE);
    assert(close == literal<1024>(fixture + (decoded.result ? "/close_ok_c1.bin" : "/close_error_c1.bin")));
    return close;
  }
  void close(const handoff::Packet& request, bool failed) {
    const auto good = literal<1024>(fixture + (failed ? "/closed_error_c1.bin" : "/closed_ok_c1.bin"));
    // Response transport and request receipt can be backpressured separately.
    handoff::Message wrong; assert(handoff::decode(good, wrong)); --wrong.accepted_request;
    const auto early_wrong = handoff::encode(wrong); send_response(early_wrong);
    idle(); assert(!transport.response_receipt_valid && !state->closed_consumed && !shell_closed_releases);
    echo_control(request);
    assert(state->phase == executor::Phase::WAIT_CLOSE && !state->closed_consumed);
    take_response_receipt(early_wrong, false);
    const auto control_receipts = transport.control_receipts;
    const auto rejected_receipts = transport.rejected_control_receipts;
    echo_control(request, false);
    assert(transport.control_receipts == control_receipts &&
      transport.rejected_control_receipts == rejected_receipts + 1 && !state->closed_consumed);
    for (unsigned which = 0; which < 10; ++which) {
      assert(handoff::decode(good, wrong));
      if (which == 0) ++wrong.session;
      if (which == 1) --wrong.accepted_request;
      if (which == 2) ++wrong.binding.source.sequence;
      if (which == 3) ++wrong.binding.handoff_epoch;
      if (which == 4) ++wrong.binding.source.identity.request_id;
      if (which == 5) wrong.local_committed = false;
      if (which == 6) wrong.result = failed ? ok() : Check{Status::E_BUFFER, laya::detail(7, 0, 14)};
      if (which == 7) wrong.result = {Status::E_PROTOCOL, laya::detail(7, 0, 15)};
      if (which == 8) wrong.result = {Status::E_PROTOCOL, laya::detail(7, 0, 14), 99};
      if (which == 9) { wrong.kind = handoff::Kind::GRANTED; wrong.result = ok(); }
      assert(handoff::validate(wrong));
      const auto packet = handoff::encode(wrong);
      const auto accepted = state->control_responses_consumed;
      send_response(packet, false);
      assert(state->control_responses_consumed == accepted && state->closed_requests == 0 &&
        state->phase == executor::Phase::WAIT_CLOSE && !shell_closed_releases);
      take_response_receipt(packet, false);
    }
    const auto runtime_before = std::vector<uint8_t>(
      reinterpret_cast<const uint8_t*>(&state->runtime),
      reinterpret_cast<const uint8_t*>(&state->runtime) + sizeof(state->runtime));
    // Persistent revocation and candidate input changes cannot rename old K.
    in.cancel = true; ++in.session; ++in.accepted_request; ++in.fence.base.epoch;
    send_response(good);
    assert(state->closed_consumed && state->closed_requests == 1 &&
      state->phase == executor::Phase::WAIT_NEW_ADMISSION && !shell_closed_releases &&
      handoff::encode(state->closed_record) == good);
    take_response_receipt(good, true);
    assert(shell_closed_releases == 1);
    send_response(good, false); take_response_receipt(good, false);
    assert(shell_closed_releases == 1 && state->closed_requests == 1);
    in.cancel = false; in.request_valid = true; in.managed_close = false;
    portal::put(io.data(), 24, 1102, 8); idle(24);
    assert(state->admissions == 1 && state->imports == 1 && state->closed_requests == 1 &&
      state->phase == executor::Phase::WAIT_NEW_ADMISSION && commands.empty() && results.empty() &&
      std::equal(runtime_before.begin(), runtime_before.end(),
        reinterpret_cast<const uint8_t*>(&state->runtime)));
  }
};

void literal_codecs(const std::string& fixture) {
  for (unsigned kind = 1; kind <= 7; ++kind) {
    const auto packet = literal<1024>(fixture + "/control_" + std::to_string(kind) + ".bin");
    handoff::Message decoded;
    assert(handoff::decode(packet, decoded) && unsigned(decoded.kind) == kind && handoff::encode(decoded) == packet);
  }
  for (const std::string kind: {"close", "closed"})
    for (const std::string status: {"ok", "error"}) for (unsigned commit = 0; commit < 2; ++commit) {
      const auto packet = literal<1024>(fixture + "/" + kind + "_" + status + "_c" + std::to_string(commit) + ".bin");
      handoff::Message decoded; assert(handoff::decode(packet, decoded) && handoff::encode(decoded) == packet);
    }
  admission_owner::Record owner;
  const auto packet = literal<1024>(fixture + "/admission_owner.bin");
  assert(admission_owner::decode(packet, owner) && admission_owner::encode(owner) == packet);
}

void request_receipt_negatives(const std::string& fixture) {
  Harness h(fixture); h.start_hold();
  const auto packet = literal<1024>(fixture + "/control_1.bin");
  // No real downstream pop has occurred, so even a matching echo is early.
  h.echo_control(packet, false);
  assert(h.transport.rejected_control_receipts == 1 && !h.transport.control_receipts && h.query.empty());
  h.in.control_response = handoff::Message{};
  assert(handoff::decode(literal<1024>(fixture + "/control_2.bin"), h.in.control_response));
  h.idle(); assert(h.state->phase == executor::Phase::WAIT_HELD && !h.state->control_sent); h.no_start();
  const auto actual = h.read_control(handoff::Kind::HOLD);
  handoff::Message foreign; assert(handoff::decode(actual, foreign)); ++foreign.accepted_request;
  h.echo_control(handoff::encode(foreign), false);
  assert(h.transport.rejected_control_receipts == 2 && !h.transport.control_receipts);
  h.echo_control(actual);
  assert(h.transport.control_receipts == 1 && h.state->control_sent);
  h.echo_control(actual, false);
  assert(h.transport.control_receipts == 1 && h.transport.rejected_control_receipts == 3);
  h.in.fence.physical_quiescent = h.in.fence.predecessor_dispatch_held =
    h.in.fence.source_held = h.in.fence.target_held = true;
  const auto response = literal<1024>(fixture + "/control_2.bin");
  h.send_response(response); h.take_response_receipt(response, true);
  assert(h.state->control_responses_consumed == 1 && !h.transport.transport_error);
}

void revoked_bound_grant(const std::string& fixture) {
  Harness h(fixture); h.start_hold(); h.held(); h.checkpoint();
  const auto request = h.read_control(handoff::Kind::IMPORT_OK);
  const auto response = literal<1024>(fixture + "/control_4.bin");
  h.send_response(response); h.idle();
  assert(h.transport.response.complete && !h.transport.response_receipt_valid); h.no_start();
  h.in.cancel = true; ++h.in.session; ++h.in.fence.base.epoch;
  h.echo_control(request);
  assert(h.state->control_responses_consumed == 2 && h.transport.response_receipt_accepted &&
    h.state->phase == executor::Phase::WAIT_ABORT && h.state->control_request.local_committed &&
    h.state->revoked && h.state->imports == 1);
  h.take_response_receipt(response, true); h.no_start();
  const auto abort = h.read_control(handoff::Kind::ABORT);
  h.echo_control(abort);
  auto rejected = h.state->control_request; rejected.kind = handoff::Kind::ABORT_CLOSED;
  rejected.local_committed = false; assert(handoff::validate(rejected));
  const auto packet = handoff::encode(rejected);
  h.send_response(packet); h.take_response_receipt(packet, false);
  assert(h.state->control_responses_consumed == 2 && !h.shell_closed_releases && h.state->revoked);
  h.no_start();
}

void late_revoked_bound_grant(const std::string& fixture) {
  Harness h(fixture); h.start_hold(); h.held(); h.checkpoint();
  const auto request = h.read_control(handoff::Kind::IMPORT_OK);
  h.echo_control(request);
  assert(h.state->phase == executor::Phase::WAIT_IMPORT_CONFIRMATION && h.state->control_sent &&
    h.transport.last_consumed_control_valid &&
    handoff::encode(h.transport.last_consumed_control) == request);
  h.in.cancel = true; h.call();
  assert(h.state->phase == executor::Phase::WAIT_ABORT && h.state->control_pending &&
    !h.state->control_sent && h.state->revoked && h.state->control_request.local_committed);
  const auto count = h.state->control_responses_consumed;
  const auto response = literal<1024>(fixture + "/control_4.bin");
  handoff::Message wrong; assert(handoff::decode(response, wrong)); ++wrong.accepted_request;
  const auto foreign = handoff::encode(wrong);
  h.send_response(foreign);
  assert(!h.transport.response_receipt_accepted && !h.transport.revoked_grant_receipts &&
    h.state->control_responses_consumed == count);
  h.take_response_receipt(foreign, false); h.no_start();
  // The complete old GRANT is bound by the previously validated actual IMPORT
  // receipt. Its late acknowledgement only unblocks old shell cleanup.
  h.send_response(response);
  assert(h.transport.response_receipt_valid && h.transport.response_receipt_accepted &&
    h.transport.revoked_grant_receipts == 1 && h.state->control_responses_consumed == count &&
    h.state->phase == executor::Phase::WAIT_ABORT && h.state->control_request.local_committed);
  h.take_response_receipt(response, true); h.no_start();
  h.send_response(response, false); h.take_response_receipt(response, false);
  assert(h.transport.revoked_grant_receipts == 1 && h.state->control_responses_consumed == count);
  assert(!h.shell_closed_releases && h.state->imports == 1 && h.state->revoked &&
    !h.transport.transport_error);
}

void malformed_response(const std::string& fixture) {
  for (unsigned which = 0; which < 4; ++which) {
    Harness h(fixture); h.start_hold(); h.held(); h.checkpoint();
    const auto request = h.read_control(handoff::Kind::IMPORT_OK); h.echo_control(request);
    auto packet = literal<1024>(fixture + "/control_4.bin");
    if (which == 0) packet[1023] = 1;
    if (which == 1) packet[0] ^= 1;
    if (which == 2) packet[8] = 10;
    if (which == 3) packet[792] = 0; // GRANTED cannot claim commit0.
    h.send_response(packet, false);
    assert(h.transport.transport_error && h.transport.rejected_responses == 1 &&
      h.transport.response_receipt_valid && !h.transport.response_receipt_accepted &&
      h.state->control_responses_consumed == 1 &&
      h.state->imports == 1 && h.state->runtime.checkpoint_baseline.valid);
    h.take_response_receipt(packet, false, true, false);
    h.idle(); h.no_start();
  }
}

void successful_request(const std::string& fixture) {
  Harness h(fixture); h.start_hold(); h.held(true); h.checkpoint(); h.grant(true);
  // A replayed full GRANT is decoded but rejected by the actor, then consumed
  // as a false sideband notification without conferring another permission.
  const auto grant = literal<1024>(fixture + "/control_4.bin");
  h.send_response(grant, false); h.take_response_receipt(grant, false);
  assert(h.shell_grants_consumed == 1 && h.state->control_responses_consumed == 2);
  h.complete_program(); const auto close = h.host_consume(); h.close(close, false);
  assert(h.transport.host_receipts == 1 && h.transport.control_receipts == 3 &&
    h.shell_closed_releases == 1 && h.state->control_responses_consumed == 3 &&
    h.state->runtime.tasks_retired == 4 && h.request_tail_waits >= 72 && h.response_tail_waits >= 72);
}

void canceled_partial_command(const std::string& fixture) {
  Harness h(fixture); h.start_hold(); h.held(); h.checkpoint(); h.grant(false, false);
  // Receipt acceptance wrote the real LGP1 first beat. Continue that old
  // bound command after revoke; the actual program emits LOCAL_REJECT.
  assert(h.state->phase == executor::Phase::WRITE_COMMAND && h.state->beat == 1 && h.commands.size() == 1);
  h.in.cancel = true; h.complete_program(true);
  const auto close = h.host_consume(); h.close(close, true);
  assert(h.state->runtime.tasks_retired == 0 && h.state->closed_requests == 1 &&
    h.shell_closed_releases == 1 && !h.producer_frames && !h.provenance_frames);
}
} // namespace

int main(int argc, char** argv) {
  assert(argc == 2); const std::string fixture = argv[1];
  literal_codecs(fixture);
  request_receipt_negatives(fixture);
  revoked_bound_grant(fixture);
  late_revoked_bound_grant(fixture);
  malformed_response(fixture);
  successful_request(fixture);
  canceled_partial_command(fixture);
  std::cout << "FULL_CURRENT_EXECUTOR_STREAM_HOST_PASS actual_FIRST_LYRQ_LYMP_A=1 "
    << "actual_control_read_codec_echo=1 response_first_independent_receipts=1 "
    << "request_tail2_tail1_waits12=1 response_tail2_tail1_waits12=1 LBR2_tail2_tail1_waits12=1 "
    << "actual_checkpoint_helper_IMPORT_GRANT=1 early_foreign_duplicate_request_receipts=3 "
    << "foreign_GRANT_rejections=5 duplicate_GRANT_rejection=1 malformed_response_rejections=4 "
    << "accepted_actor_or_actual_old_IMPORT_revoked_GRANT=1 CLOSED_only_actor_validator=1 "
    << "whole_receipt_bytes_accepted_stable=1 revoked_bound_GRANT_consumed_zero_start_cases=2 "
    << "late_revoked_GRANT_wrongK_duplicate_false=1 late_revoked_GRANT_receipts=1 real_success_windows=4 "
    << "real_program_LAC1_codec_echo4_tail2_tail1_waits12=1 "
    << "real_partial_command_LOCAL_REJECT=1 Host_read_tail2_tail1_waits12=1 "
    << "Host_full_echo_required=1 legacy_bools_blocked=1 CLOSED_semantic_rejections=22 "
    << "CLOSED_once_second_request_blocked=2 host_unbounded_streams=1 "
    << "shell_fences_producer_terminals_controlled=1 physical_RTL_HLS_NOT_RUN=1 "
    << "no_LGP_error_complete_rearm_NOT_RUN=1\n";
}
