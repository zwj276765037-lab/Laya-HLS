#include "laya_graph_program_hls.h"
#include "laya_graph_program_sequencer.h"
#include "laya_model_layout_generated.h"

#include <algorithm>
#include <cassert>
#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>

using namespace laya;

namespace {

template<std::size_t Bytes>
ap_uint<512> pack(const std::array<uint8_t, Bytes>& packet, unsigned beat) {
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  return word;
}

template<std::size_t Bytes>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat)
    stream.write(pack(packet, beat));
}

template<std::size_t Bytes>
std::array<uint8_t, Bytes> dequeue(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

template<std::size_t Bytes>
void dequeue_beat(hls::stream<ap_uint<512>>& stream,
                  std::array<uint8_t, Bytes>& packet, unsigned beat) {
  const ap_uint<512> word = stream.read();
  for (unsigned byte = 0; byte < 64; ++byte)
    packet[beat * 64 + byte] =
        uint8_t(word.range(byte * 8 + 7, byte * 8));
}

NumericIdentity patterned_identity() {
  NumericIdentity id;
  id.request_id = 0x1111222233334444ull;
  id.generation = 0x5555666677778888ull;
  id.B = 1;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x10 + i);
    id.numeric_tag[i] = uint8_t(0x20 + i);
    id.layout_tag[i] = uint8_t(0x30 + i);
    id.build_tag[i] = uint8_t(0x40 + i);
  }
  return id;
}

NumericIdentity current_identity(uint64_t request_id) {
  NumericIdentity id;
  id.request_id = request_id;
  id.generation = request_id + 1;
  id.B = 1;
  id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = full::kFullModelTag[i];
    id.numeric_tag[i] = full::kFullNumericTag[i];
    id.layout_tag[i] = full::kFullLayoutTag[i];
    id.build_tag[i] = full::kFullBuildTag[i];
  }
  return id;
}

program_wire::Command patterned_command() {
  program_wire::Command command;
  command.flags = program_wire::SOURCE_READY_PROOF;
  command.identity = patterned_identity();
  command.source.slot = 3;
  command.source.version = 0x1112131415161718ull;
  command.source.owner = {{Buffer::HIDDEN, 0, 9}, 0, 2, 2, 255,
                          RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  return command;
}

program_wire::Result patterned_result() {
  program_wire::Result result;
  result.pc = 8;
  result.flags = program_wire::FRAME_COMPLETE | program_wire::BINDING_OK |
      program_wire::SAFE_TERMINAL | program_wire::REQUEST_COMPLETE |
      program_wire::SLOT_UPDATE_VALID;
  result.action_ordinal = 0x0102030405060708ull;
  result.identity = patterned_identity();
  result.slot_delta.slot = 1;
  result.slot_delta.version = 2;
  result.slot_delta.owner = {{Buffer::NORM, 1, 10}, 0, 2, 3, 255,
                             RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  return result;
}

program_wire::Command current_command(uint64_t request_id,
                                      uint32_t source_epoch) {
  program_wire::Command command;
  command.flags = program_wire::SOURCE_READY_PROOF;
  command.identity = current_identity(request_id);
  command.source.slot = 0;
  command.source.version = source_epoch;
  command.source.owner = {{Buffer::HIDDEN, 0, source_epoch}, 0, 2, 0, 255,
                          RowSpace::TOKEN, 0, 64, 1024, Content::F32};
  return command;
}

action::Completion success(const action::Request& request) {
  action::Completion completion;
  completion.kind = request.kind;
  completion.pc = request.pc;
  completion.op = request.op;
  completion.stage = request.stage;
  completion.layer = request.layer;
  completion.flags = action::FRAME_COMPLETE | action::BINDING_OK |
      action::SAFE_TERMINAL | action::REMOTE_DRAINED |
      action::SLOT_UPDATE_VALID | action::TYPED_RETIRED;
  completion.ordinal = request.ordinal;
  completion.identity = request.identity;
  completion.first_task_id = 1;
  completion.last_task_id = 4;
  completion.retired_tasks = 4;
  completion.slot_delta.slot = request.target_slot;
  completion.slot_delta.version = request.target_slot_version;
  completion.slot_delta.owner = {
      {Buffer::NORM, 0, 1}, 0, request.stage, request.layer, 255,
      RowSpace::TOKEN, 0, request.identity.S, 1024, Content::F32};
  return completion;
}

void tick(bool cancel, bool result_consumed,
          hls::stream<ap_uint<512>>& command,
          hls::stream<ap_uint<512>>& result,
          hls::stream<ap_uint<512>>& action_request,
          hls::stream<ap_uint<512>>& action_completion) {
  laya_graph_program_sequencer(cancel, result_consumed, command, result,
                               action_request, action_completion);
}

} // namespace

int main(int argc, char** argv) {
  assert(argc == 2);
  std::ifstream stream(argv[1], std::ios::binary);
  const std::vector<uint8_t> oracle((std::istreambuf_iterator<char>(stream)), {});
  assert(oracle.size() == 512);
  const auto command_oracle = program_wire::encode(patterned_command());
  const auto result_oracle = program_wire::encode(patterned_result());
  assert(std::equal(command_oracle.begin(), command_oracle.end(), oracle.begin()));
  assert(std::equal(result_oracle.begin(), result_oracle.end(),
                    oracle.begin() + 256));

  program_wire::Result stale = patterned_result();
  auto bad_result = result_oracle;
  bad_result[176] = uint8_t(program::kGraphSlots);
  assert(!program_wire::decode(bad_result, stale));
  assert(stale.flags == 0 && stale.action_ordinal == 0);

  hls::stream<ap_uint<512>> command{"accepted_command"};
  hls::stream<ap_uint<512>> result{"request_result"};
  hls::stream<ap_uint<512>> action_request{"action_request"};
  hls::stream<ap_uint<512>> action_completion{"action_completion"};

  const program_wire::Command first = current_command(901, 1);
  enqueue(command, program_wire::encode(first));
  for (unsigned cycle = 0; cycle < 200 &&
       action_request.size() < action::kRequestBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(action_request.size() == action::kRequestBeats);
  action::Request first_action;
  assert(action::decode(dequeue<action::kRequestBytes>(action_request),
                        first_action));
  assert(first_action.kind == action::Kind::NORM &&
         first_action.op == Op::LN_ATTN && first_action.stage == 2 &&
         first_action.layer == 1 && first_action.ordinal == 1);

  enqueue(action_completion, action::encode(success(first_action)));
  for (unsigned cycle = 0; cycle < 200 &&
       result.size() < program_wire::kResultBeats - 1; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(result.size() == program_wire::kResultBeats - 1);

  const program_wire::Command second = current_command(902, 1);
  enqueue(command, program_wire::encode(second));
  program_wire::ResultPacket first_result_packet{};
  for (unsigned beat = 0; beat < program_wire::kResultBeats - 1; ++beat)
    dequeue_beat(result, first_result_packet, beat);
  // The consumer's final-beat notification is adjacent to the producer's
  // transition into WAIT_RESULT_CONSUMED.  It must be retained rather than
  // lost as a one-cycle pulse, and it belongs only to this result.
  tick(false, true, command, result, action_request, action_completion);
  assert(result.size() == 1 && command.size() == program_wire::kCommandBeats);
  dequeue_beat(result, first_result_packet, program_wire::kResultBeats - 1);
  program_wire::Result first_result;
  assert(program_wire::decode(first_result_packet, first_result));
  assert((first_result.flags & program_wire::REQUEST_COMPLETE) &&
         (first_result.flags & program_wire::SLOT_UPDATE_VALID) &&
         first_result.action_ordinal == 1 && first_result.pc == 1);

  tick(false, false, command, result, action_request, action_completion);
  for (unsigned cycle = 0; cycle < 200 &&
       action_request.size() < action::kRequestBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(action_request.size() == action::kRequestBeats);
  action::Request second_action;
  assert(action::decode(dequeue<action::kRequestBytes>(action_request),
                        second_action));
  assert(second_action.ordinal == 2 && second_action.identity.request_id == 902);

  action::Completion failure = success(second_action);
  failure.flags &= ~(action::SLOT_UPDATE_VALID | action::TYPED_RETIRED);
  failure.result = {Status::E_BUFFER,
                    laya::detail(4, uint8_t(Buffer::NORM), 9)};
  failure.first_task_id = 0;
  failure.last_task_id = 0;
  failure.retired_tasks = 0;
  failure.slot_delta = action::SlotDelta{};
  enqueue(action_completion, action::encode(failure));
  // A notification from an earlier result, before this result's final beat,
  // must not open the next command boundary.
  tick(false, true, command, result, action_request, action_completion);
  for (unsigned cycle = 0; cycle < 200 &&
       result.size() < program_wire::kResultBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(result.size() == program_wire::kResultBeats);

  auto bad_command = program_wire::encode(current_command(903, 1));
  bad_command[0] ^= 0x80;
  enqueue(command, bad_command);
  for (unsigned cycle = 0; cycle < 24; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(command.size() == program_wire::kCommandBeats &&
         action_request.empty());

  program_wire::Result second_result;
  assert(program_wire::decode(
      dequeue<program_wire::kResultBytes>(result), second_result));
  assert(!second_result.result &&
         second_result.result.code == Status::E_BUFFER &&
         (second_result.flags & program_wire::REQUEST_COMPLETE) &&
         !(second_result.flags & program_wire::SLOT_UPDATE_VALID) &&
         second_result.action_ordinal == 2);

  // A rejected accepted-request frame has no action ordinal yet.  Its LGR1
  // result must still be self-consistent and must retain the same consumer
  // boundary before a later valid request may enter the program.
  tick(false, true, command, result, action_request, action_completion);
  for (unsigned cycle = 0; cycle < 200 &&
       result.size() < program_wire::kResultBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(result.size() == program_wire::kResultBeats);

  const program_wire::Command third = current_command(904, 1);
  enqueue(command, program_wire::encode(third));
  for (unsigned cycle = 0; cycle < 24; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(command.size() == program_wire::kCommandBeats &&
         action_request.empty());

  program_wire::Result rejected_result;
  assert(program_wire::decode(
      dequeue<program_wire::kResultBytes>(result), rejected_result));
  assert(!rejected_result.result &&
         rejected_result.result.code == Status::E_PROTOCOL &&
         (rejected_result.flags & program_wire::LOCAL_REJECT) &&
         (rejected_result.flags & program_wire::REQUEST_COMPLETE) &&
         !(rejected_result.flags & program_wire::BINDING_OK) &&
         rejected_result.action_ordinal == 0);

  tick(false, true, command, result, action_request, action_completion);
  for (unsigned cycle = 0; cycle < 200 &&
       action_request.size() < action::kRequestBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  assert(action_request.size() == action::kRequestBeats);
  action::Request third_action;
  assert(action::decode(dequeue<action::kRequestBytes>(action_request),
                        third_action));
  assert(third_action.ordinal == 3 && third_action.identity.request_id == 904);

  enqueue(action_completion, action::encode(success(third_action)));
  for (unsigned cycle = 0; cycle < 200 &&
       result.size() < program_wire::kResultBeats; ++cycle)
    tick(false, false, command, result, action_request, action_completion);
  program_wire::Result third_result;
  assert(program_wire::decode(
      dequeue<program_wire::kResultBytes>(result), third_result));
  assert(third_result.result && third_result.action_ordinal == 3 &&
         (third_result.flags & program_wire::REQUEST_COMPLETE) &&
         (third_result.flags & program_wire::SLOT_UPDATE_VALID));
  tick(false, true, command, result, action_request, action_completion);
  assert(command.empty() && result.empty() && action_request.empty() &&
         action_completion.empty());

  std::cout << "FULL_CURRENT_GRAPH_PROGRAM_TOP_PASS "
            << "schema=LGP1/LGR1 command_beats=4 result_beats=4 "
            << "python_byte_oracle=1 action_beats=8/4 "
            << "result_consumer_gate=1 adjacent_consume_latched=1 "
            << "delayed_consume_gate=1 ordinal_recovery=1 "
            << "early_stale_consume_ignored=1 completed_requests=3 "
            << "completed_local_rejects=1 final_streams_empty=1 "
            << "success_slot_commit=1 safe_error_request_complete=1 "
            << "bad_command_local_reject=1 reject_gate_recovery=1\n";
  return 0;
}
