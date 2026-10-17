#include "laya_graph_program_owned.h"

#include <algorithm>
#include <array>
#include <cassert>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;

namespace {
template<std::size_t N>
std::array<uint8_t, N> literal(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  assert(input.good());
  const std::vector<uint8_t> bytes((std::istreambuf_iterator<char>(input)), {});
  assert(bytes.size() == N);
  std::array<uint8_t, N> packet{};
  std::copy(bytes.begin(), bytes.end(), packet.begin());
  return packet;
}

template<std::size_t N>
void put(std::array<uint8_t, N>& p, unsigned off, uint64_t value, unsigned count) {
  assert(off + count <= N && count <= 8);
  for (unsigned i = 0; i < count; ++i) p[off + i] = uint8_t(value >> (8 * i));
}

template<std::size_t N>
ap_uint<512> beat(const std::array<uint8_t, N>& p, unsigned index) {
  assert(index < N / 64);
  ap_uint<512> word = 0;
  for (unsigned i = 0; i < 64; ++i)
    word.range(8 * i + 7, 8 * i) = p[64 * index + i];
  return word;
}

template<std::size_t N>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, N>& p, unsigned first = 0,
             unsigned end = N / 64) {
  for (unsigned i = first; i < end; ++i) stream.write(beat(p, i));
}

template<std::size_t N>
void read_beat(hls::stream<ap_uint<512>>& stream,
               std::array<uint8_t, N>& p, unsigned index) {
  assert(!stream.empty());
  const ap_uint<512> word = stream.read();
  for (unsigned i = 0; i < 64; ++i)
    p[64 * index + i] = uint8_t(word.range(8 * i + 7, 8 * i));
}

template<std::size_t N>
std::array<uint8_t, N> dequeue(hls::stream<ap_uint<512>>& stream) {
  assert(stream.size() == N / 64);
  std::array<uint8_t, N> p{};
  for (unsigned i = 0; i < N / 64; ++i) read_beat(stream, p, i);
  return p;
}

ap_uint<8192> whole(const handoff::Packet& p) {
  ap_uint<8192> word = 0;
  for (unsigned i = 0; i < p.size(); ++i)
    word.range(8 * i + 7, 8 * i) = p[i];
  return word;
}

handoff::Packet whole_packet(const ap_uint<8192>& word) {
  handoff::Packet p{};
  for (unsigned i = 0; i < p.size(); ++i)
    p[i] = uint8_t(word.range(8 * i + 7, 8 * i));
  return p;
}

struct Fixtures {
  handoff::Packet owner;
  program_pending::Packet pending;
  program_wire::CommandPacket command{};
  action::RequestPacket action{};
  action::CompletionPacket cancel_completion;
  program_wire::ResultPacket cancel_result;

  explicit Fixtures(const std::string& directory)
      : owner(literal<1024>(directory + "/control_4.bin")),
        pending(literal<1024>(directory + "/pending.bin")),
        cancel_completion(literal<256>(directory + "/cancel_completion.bin")),
        cancel_result(literal<256>(directory + "/cancel_result.bin")) {
    std::copy(pending.begin() + 256, pending.begin() + 512, command.begin());
    std::copy(pending.begin() + 512, pending.end(), action.begin());
    handoff::Message granted;
    program_pending::Record record;
    action::Completion completion;
    assert(handoff::decode(owner, granted));
    assert(granted.kind == handoff::Kind::GRANTED && granted.local_committed);
    assert(program_pending::decode(pending, record));
    assert(record.key.session == granted.session &&
           record.key.accepted_request == granted.accepted_request &&
           record.key.sequence == granted.binding.source.sequence &&
           record.key.handoff == granted.binding.handoff_epoch);
    assert(action::decode(cancel_completion, completion));
    assert(completion.flags == 79 && completion.ordinal == 1 &&
           completion.retired_tasks == 0 && completion.first_task_id == 0 &&
           completion.last_task_id == 0 && !completion.result);
  }
};

struct Harness {
  hls::stream<ap_uint<8192>> owners, owner_receipts, pending;
  hls::stream<ap_uint<512>> commands, results, actions, completions, receipts;
  bool cancel = false, isolated = false;
  unsigned calls = 0;

  void call(bool result_consumed = false) {
    ++calls;
    laya_graph_program_owned_sequencer(cancel, result_consumed, isolated,
        owners, owner_receipts, pending, commands, results, actions,
        completions, receipts);
  }
  void wait(unsigned count = 12) {
    for (unsigned i = 0; i < count; ++i) call();
  }
  void no_action() {
    assert(actions.empty() && pending.empty() && receipts.empty());
  }
  void install(const Fixtures& f) {
    owners.write(whole(f.owner));
    call();
    assert(owners.empty() && owner_receipts.empty() && !isolated);
    no_action();
    assert(results.empty());
    call();
    assert(owner_receipts.size() == 1 && !isolated);
    assert(whole_packet(owner_receipts.read()) == f.owner);
    no_action();
  }
  void await_result() {
    for (unsigned i = 0; i < 64 && results.size() < 4; ++i) call();
    assert(results.size() == 4 && !isolated);
  }
  void replay_is_held(const Fixtures& f) {
    auto next_owner = f.owner;
    put(next_owner, 776, 30, 8);
    put(next_owner, 784, 102, 8);
    put(next_owner, 680, 20, 8);
    handoff::Message decoded;
    assert(handoff::decode(next_owner, decoded));
    owners.write(whole(f.owner));
    owners.write(whole(next_owner));
    enqueue(commands, f.command);
    wait();
    assert(owners.size() == 2 && commands.size() == 4 &&
           owner_receipts.empty() && results.empty());
    no_action();
    call(true); // Only the current result's real consumer may supply this.
    wait(24);
    assert(owners.size() == 2 && commands.size() == 4 &&
           owner_receipts.empty() && results.empty());
    no_action();
  }
};

void command_with_tail_delays(Harness& h, const Fixtures& f) {
  enqueue(h.commands, f.command, 0, 2);
  h.call(); h.call();
  assert(h.commands.empty());
  h.wait(); h.no_action(); assert(h.results.empty());
  enqueue(h.commands, f.command, 2, 3); h.call();
  h.wait(); h.no_action(); assert(h.results.empty());
  enqueue(h.commands, f.command, 3, 4);
}

void await_pending(Harness& h, const Fixtures& f) {
  for (unsigned i = 0; i < 64 && h.pending.empty(); ++i) h.call();
  assert(h.pending.size() == 1 && h.actions.empty() && h.results.empty());
  const auto actual = whole_packet(h.pending.read());
  assert(actual == f.pending);
  program_pending::Record record;
  assert(program_pending::decode(actual, record) && record.action.ordinal == 1);
}

void consume_action_with_tail_delays(Harness& h, const Fixtures& f) {
  for (unsigned i = 0; i < 32 && h.actions.size() < 8; ++i) h.call();
  assert(h.actions.size() == 8 && h.results.empty() && h.receipts.empty());
  action::RequestPacket actual{};
  for (unsigned i = 0; i < 6; ++i) read_beat(h.actions, actual, i);
  h.wait(); assert(h.actions.size() == 2 && h.results.empty());
  read_beat(h.actions, actual, 6);
  h.wait(); assert(h.actions.size() == 1 && h.results.empty());
  read_beat(h.actions, actual, 7);
  assert(actual == f.action);
}

void completion_with_tail_delays(Harness& h,
                                const action::CompletionPacket& completion) {
  enqueue(h.completions, completion, 0, 2);
  h.call(); h.call();
  assert(h.completions.empty());
  h.wait(); assert(h.receipts.empty() && h.results.empty());
  enqueue(h.completions, completion, 2, 3); h.call();
  h.wait(); assert(h.receipts.empty() && h.results.empty());
  enqueue(h.completions, completion, 3, 4); h.call();
  assert(h.receipts.empty() && h.results.empty());
  h.call(); // Complete codec/key acceptance, before the first receipt beat.
  assert(h.receipts.empty() && h.results.empty());
  for (unsigned i = 0; i < 4; ++i) {
    h.call();
    assert(h.receipts.size() == i + 1 && h.results.empty());
  }
  assert(dequeue<256>(h.receipts) == completion);
}

program_wire::ResultPacket consume_result_with_tail_delays(Harness& h) {
  h.await_result();
  program_wire::ResultPacket p{};
  read_beat(h.results, p, 0); read_beat(h.results, p, 1);
  h.wait(); assert(h.results.size() == 2);
  read_beat(h.results, p, 2);
  h.wait(); assert(h.results.size() == 1);
  read_beat(h.results, p, 3);
  return p;
}

action::CompletionPacket success_completion(const Fixtures& f) {
  // Literal protocol fields; no DUT encoder or DUT output builds this gold.
  auto p = f.cancel_completion;
  put(p, 16, 63, 4); put(p, 148, 0, 2); put(p, 152, 0, 4);
  put(p, 164, 1, 4); put(p, 168, 4, 4); put(p, 172, 4, 2);
  p[176] = 1; put(p, 184, 1, 8);
  put(p, 192, 1, 4); p[196] = uint8_t(Buffer::NORM);
  p[197] = 0; p[198] = 0;
  p[200] = 2; p[201] = 1; p[202] = 255; p[203] = 0;
  put(p, 204, 0, 2); put(p, 206, 64, 2); put(p, 208, 1024, 2);
  p[210] = 1;
  return p;
}

program_wire::ResultPacket success_result(const Fixtures& f) {
  auto p = f.cancel_result;
  p[9] = 1; put(p, 16, 31, 4);
  put(p, 148, 0, 2); put(p, 152, 0, 4);
  const auto c = success_completion(f);
  std::copy(c.begin() + 176, c.begin() + 224, p.begin() + 176);
  return p;
}

void local_cancel(Harness& h, const Fixtures& f, bool prefix) {
  h.install(f);
  if (prefix) {
    enqueue(h.commands, f.command, 0, 2); h.call(); h.call();
  }
  h.cancel = true;
  if (prefix) {
    h.wait(); h.no_action(); assert(h.results.empty());
    enqueue(h.commands, f.command, 2, 3); h.call();
    h.wait(); h.no_action(); assert(h.results.empty());
    enqueue(h.commands, f.command, 3, 4);
  } else {
    command_with_tail_delays(h, f);
  }
  h.await_result();
  h.no_action(); assert(h.commands.empty());
  auto expected = f.cancel_result;
  put(expected, 16, 47, 4); put(expected, 24, 0, 8);
  const auto actual = consume_result_with_tail_delays(h);
  assert(actual == expected);
  program_wire::Result result;
  assert(program_wire::decode(actual, result) && !result.result &&
         result.action_ordinal == 0 && (result.flags & program_wire::LOCAL_REJECT));
  h.replay_is_held(f);
}

void allocated(Harness& h, const Fixtures& f, bool canceled, bool stale) {
  h.install(f); command_with_tail_delays(h, f); await_pending(h, f);
  h.cancel = canceled;
  consume_action_with_tail_delays(h, f);
  if (stale) {
    auto foreign = f.cancel_completion;
    put(foreign, 24, 2, 8);
    enqueue(h.completions, foreign);
    h.wait(24);
    assert(h.completions.empty() && h.receipts.empty() && h.results.empty());
  }
  const auto completion = canceled ? f.cancel_completion : success_completion(f);
  completion_with_tail_delays(h, completion);
  const auto actual = consume_result_with_tail_delays(h);
  assert(actual == (canceled ? f.cancel_result : success_result(f)));
  program_wire::Result result;
  assert(program_wire::decode(actual, result) && result.action_ordinal == 1 &&
         (result.flags & program_wire::REQUEST_COMPLETE));
  if (canceled) assert(!result.result && !(result.flags & program_wire::SLOT_UPDATE_VALID));
  else assert(result.result && result.pc == 1 &&
              (result.flags & program_wire::SLOT_UPDATE_VALID));
  h.replay_is_held(f);
}

void wrong_command(Harness& h, const Fixtures& f, bool source) {
  h.install(f);
  auto wrong = f.command;
  if (source) { put(wrong, 160, 2, 8); put(wrong, 168, 2, 4); }
  else wrong[64] ^= 1;
  program_wire::Command decoded;
  assert(program_wire::decode(wrong, decoded)); // Valid syntax, foreign owner.
  enqueue(h.commands, wrong, 0, 2); h.call(); h.call();
  h.wait(); assert(!h.isolated); h.no_action(); assert(h.results.empty());
  enqueue(h.commands, wrong, 2, 3); h.call();
  h.wait(); assert(!h.isolated); h.no_action(); assert(h.results.empty());
  enqueue(h.commands, wrong, 3, 4); h.call(); h.call();
  assert(h.isolated && h.commands.empty()); h.no_action(); assert(h.results.empty());
  h.owners.write(whole(f.owner)); enqueue(h.commands, f.command);
  h.wait(24);
  assert(h.owners.size() == 1 && h.commands.size() == 4 && h.owner_receipts.empty());
  h.no_action(); assert(h.results.empty());
}

void wrong_owner(Harness& h, const Fixtures& f, bool reserved) {
  auto bad = f.owner;
  if (reserved) bad[900] = 1;
  else bad[8] = uint8_t(handoff::Kind::IMPORT_OK); // Valid control, wrong role.
  h.owners.write(whole(bad)); enqueue(h.commands, f.command); h.call();
  assert(h.isolated && h.owners.empty() && h.owner_receipts.empty());
  h.owners.write(whole(f.owner)); h.wait(24);
  assert(h.owners.size() == 1 && h.commands.size() == 4 && h.owner_receipts.empty());
  h.no_action(); assert(h.results.empty());
}

void bootstrap_purpose(const Fixtures& f) {
  handoff::Message owner;
  assert(handoff::decode(f.owner, owner));
  const auto source = owner.binding.source;
  assert(bootstrap::validate(source) && handoff::validate(owner));
  for (uint16_t purpose : {uint16_t(0), uint16_t(2), uint16_t(65535)}) {
    auto invalid = source;
    invalid.purpose = bootstrap::Purpose(purpose);
    assert(!bootstrap::validate(invalid));
    auto nested = owner;
    nested.binding.source = invalid;
    assert(!handoff::validate(nested));
    bootstrap::Request decoded;
    assert(!bootstrap::decode(bootstrap::encode(invalid), decoded));
    assert(decoded.sequence == 0 && decoded.base_epoch == 0);
  }
  for (uint8_t content : {uint8_t(0), uint8_t(2), uint8_t(255)}) {
    auto invalid = source;
    invalid.source.content = Content(content);
    auto nested = owner;
    nested.binding.source = invalid;
    assert(!bootstrap::validate(invalid) && !handoff::validate(nested));
  }
  auto bad_region = owner;
  bad_region.binding.source.source.target_region = 1;
  assert(bad_region.binding.source.source.content == Content::F32);
  assert(!bootstrap::validate(bad_region.binding.source) && !handoff::validate(bad_region));
  // Each block's first source byte retains its full array offset. Mutating
  // any of these bytes must fail the original complete canonical check.
  for (unsigned index : {0u, 64u, 128u, 192u, 256u, 320u, 384u}) {
    auto nested = owner;
    nested.binding.source.model_identity[index] ^= 1;
    assert(!bootstrap::validate(nested.binding.source) && !handoff::validate(nested));
  }
  // A valid purpose never excuses a bad physical span or model binding.
  auto nested = owner;
  --nested.binding.source.source.owner_extent_span;
  assert(!bootstrap::validate(nested.binding.source) && !handoff::validate(nested));
  nested = owner;
  nested.binding.source.model_identity[0] ^= 1;
  assert(!bootstrap::validate(nested.binding.source) && !handoff::validate(nested));
}
} // namespace

int main(int argc, char** argv) {
  assert(argc == 3);
  const Fixtures f(argv[1]);
  const std::string mode(argv[2]);
  Harness h;
  if (mode == "success") allocated(h, f, false, false);
  else if (mode == "bad-owner-kind") wrong_owner(h, f, false);
  else if (mode == "bad-owner-reserved") wrong_owner(h, f, true);
  else if (mode == "cancel-before-command") local_cancel(h, f, false);
  else if (mode == "cancel-command-prefix") local_cancel(h, f, true);
  else if (mode == "cancel-allocated") allocated(h, f, true, false);
  else if (mode == "wrong-command-identity") wrong_command(h, f, false);
  else if (mode == "wrong-command-source") wrong_command(h, f, true);
  else if (mode == "stale-completion") allocated(h, f, true, true);
  else if (mode == "bootstrap-purpose") bootstrap_purpose(f);
  else assert(false);
  std::cout << "FULL_CURRENT_GRAPH_PROGRAM_OWNED_TOP_PASS case=" << mode
            << " calls=" << h.calls
            << " literal_gold=1 FIRST_only=1 software_streams_unbounded=1"
            << " RTL_depth2=NOT_RUN\n";
}
