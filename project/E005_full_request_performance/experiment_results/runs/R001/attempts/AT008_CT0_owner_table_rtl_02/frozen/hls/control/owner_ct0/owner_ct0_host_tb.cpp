#include "owner_ct0.h"
#include "laya_full_runtime.h"

#include <array>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <utility>

using namespace laya;
using namespace laya::owner_ct0;

namespace {
unsigned checks = 0;
unsigned trace_transactions = 0;
std::ofstream command_trace, response_trace;
void require(bool yes, const char* what) {
  ++checks;
  if (!yes) { std::cerr << "CT0_HOST_FAIL " << what << '\n'; std::exit(1); }
}

Identity pack_identity(const NumericIdentity& id) {
  Identity bits = 0;
  bits.range(63, 0) = id.request_id;
  bits.range(127, 64) = id.generation;
  bits.range(143, 128) = id.B;
  bits.range(159, 144) = id.S;
  for (unsigned i = 0; i < 16; ++i) {
    bits.range(160 + i * 8 + 7, 160 + i * 8) = id.model_tag[i];
    bits.range(288 + i * 8 + 7, 288 + i * 8) = id.numeric_tag[i];
    bits.range(416 + i * 8 + 7, 416 + i * 8) = id.layout_tag[i];
    bits.range(544 + i * 8 + 7, 544 + i * 8) = id.build_tag[i];
  }
  return bits;
}

ap_uint<48> pack_ref(BufferRef ref) {
  ap_uint<48> bits = 0;
  bits.range(7, 0) = uint8_t(ref.id);
  bits.range(15, 8) = ref.bank;
  bits.range(47, 16) = ref.epoch;
  return bits;
}

Spec pack_spec(const full::FullOwnerSpec& s) {
  Spec bits = 0;
  bits.range(47, 0) = pack_ref(s.ref);
  bits.range(55, 48) = s.region;
  bits.range(63, 56) = s.stage;
  bits.range(71, 64) = s.layer;
  bits.range(79, 72) = s.batch;
  bits.range(87, 80) = uint8_t(s.row_space);
  bits.range(103, 88) = s.row0;
  bits.range(119, 104) = s.rows;
  bits.range(135, 120) = s.width;
  bits.range(143, 136) = uint8_t(s.content);
  return bits;
}

Record pack_record(const full::FullOwnerRecord& r) {
  Record bits = 0;
  bits.range(671, 0) = pack_identity(r.identity);
  bits.range(719, 672) = pack_ref(r.ref);
  bits.range(767, 720) = pack_ref(r.lease_old_ref);
  bits.range(799, 768) = r.max_claimed_epoch;
  bits.range(807, 800) = r.region;
  bits.range(815, 808) = r.stage;
  bits.range(823, 816) = r.layer;
  bits.range(831, 824) = r.batch;
  bits.range(839, 832) = uint8_t(r.row_space);
  bits.range(855, 840) = r.row0;
  bits.range(871, 856) = r.rows;
  bits.range(887, 872) = r.width;
  bits.range(895, 888) = uint8_t(r.content);
  bits.range(903, 896) = uint8_t(r.state);
  bits.range(911, 904) = r.readers;
  for (unsigned i = 0; i < 64; ++i) {
    bits.range(912 + i * 32 + 31, 912 + i * 32) = r.covered_rows[i];
    bits.range(2960 + i * 32 + 31, 2960 + i * 32) =
        r.old_consumed_rows[i];
  }
  bits[5008] = r.valid;
  return bits;
}

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 77;
  id.generation = 9;
  id.B = 2;
  id.S = 128;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x11 + i);
    id.numeric_tag[i] = uint8_t(0x31 + i);
    id.layout_tag[i] = uint8_t(0x51 + i);
    id.build_tag[i] = uint8_t(0x71 + i);
  }
  return id;
}

full::FullOwnerSpec make_spec(Buffer id, uint8_t bank = 0,
                              uint8_t region = 0) {
  full::FullOwnerSpec s;
  s.ref = {id, bank, 1};
  s.region = region;
  s.stage = 2;
  s.layer = 0;
  s.batch = 0;
  s.row_space = RowSpace::TOKEN;
  s.row0 = 0;
  s.rows = 2;
  s.width = 1024;
  s.content = Content::F32;
  if (id == Buffer::WI) s.width = 5248;
  if (id == Buffer::GATE) s.width = 2624;
  if (id == Buffer::QKV || id == Buffer::KV || id == Buffer::Q_TILE ||
      id == Buffer::AV_PARTIAL || id == Buffer::ROPE_HEAD ||
      id == Buffer::ROPE_TABLE) s.width = 64;
  if (id == Buffer::TYPE_ROWS) {
    s.batch = 0; s.row_space = RowSpace::BATCH;
    s.rows = 3; s.width = 1024;
  }
  if (id == Buffer::SCORE_PROB) s.width = 128;
  return s;
}

full::FullOwnerRecord make_record(const full::FullOwnerSpec& s,
                                   const NumericIdentity& id) {
  full::FullOwnerRecord r;
  r.identity = id;
  r.ref = s.ref;
  r.lease_old_ref = {Buffer::PS, 1, 123};
  r.max_claimed_epoch = 123;
  r.region = s.region; r.stage = s.stage; r.layer = s.layer;
  r.batch = s.batch; r.row_space = s.row_space;
  r.row0 = s.row0; r.rows = s.rows; r.width = s.width;
  r.content = s.content; r.state = CacheState::READY;
  r.valid = true;
  for (unsigned row = 0; row < s.rows; ++row)
    r.covered_rows[row / 32] |= uint32_t(1) << (row % 32);
  for (unsigned i = 0; i < 64; ++i)
    r.old_consumed_rows[i] = 0xa5000000u | i;
  return r;
}

using Input = hls::stream<ap_uint<512>>;
using Output = hls::stream<ap_uint<512>>;
CommandPacket pack_command(const Command& c) {
  CommandPacket p = 0;
  p.range(2, 0) = c.op;
  p.range(7, 3) = c.index;
  p.range(5016, 8) = c.record;
  p.range(5688, 5017) = c.identity;
  p.range(5832, 5689) = c.spec;
  p[5833] = c.request_valid;
  p[5834] = c.model_header_valid;
  p.range(5837, 5835) = c.type_valid;
  p.range(5845, 5838) = c.batch;
  p.range(5861, 5846) = c.row0;
  p.range(5877, 5862) = c.rows;
  return p;
}

Response unpack_response(const ResponsePacket& p) {
  Response r{};
  r.status = p.range(15, 0);
  r.detail = p.range(47, 16);
  r.bad_element = p.range(111, 48);
  r.index = p.range(116, 112);
  r.commit_count = p.range(148, 117);
  r.record = p.range(5157, 149);
  return r;
}

Response transact(Input& input, Output& output, const Command& cmd) {
  const CommandPacket packed = pack_command(cmd);
  for (unsigned beat = 0; beat < 12; ++beat)
    input.write(packed.range(beat * 512 + 511, beat * 512));
  ResponsePacket result = 0;
  unsigned beat = 0;
  for (unsigned tick = 0; tick < 20000; ++tick) {
    laya_owner_ct0(input, output);
    ap_uint<512> word;
    if (output.read_nb(word)) {
      result.range(beat * 512 + 511, beat * 512) = word;
      if (++beat == 11) {
        if (command_trace.is_open()) {
          for (unsigned i = 0; i < 12; ++i) {
            const ap_uint<512> part = packed.range(i * 512 + 511, i * 512);
            std::string hex = part.to_string(16);
            if (hex.rfind("0x", 0) == 0) hex.erase(0, 2);
            command_trace << std::string(128 - hex.size(), '0') << hex << '\n';
          }
          for (unsigned i = 0; i < 11; ++i) {
            const ap_uint<512> part = result.range(i * 512 + 511, i * 512);
            std::string hex = part.to_string(16);
            if (hex.rfind("0x", 0) == 0) hex.erase(0, 2);
            response_trace << std::string(128 - hex.size(), '0') << hex << '\n';
          }
          ++trace_transactions;
        }
        return unpack_response(result);
      }
    }
  }
  require(false, "transaction timeout");
  return {};
}

Command command(Opcode op, unsigned index = 0) {
  Command c{};
  c.op = op;
  c.index = index;
  return c;
}

void compare(Response out, Check expected, const Record& record,
             unsigned commits, unsigned index, const char* what) {
  require(out.status == unsigned(expected.code), what);
  require(out.detail == expected.detail, "detail");
  require(out.bad_element == expected.bad_element, "bad_element");
  require(out.record == record, "all record fields / both bitmaps");
  require(out.commit_count == commits, "exactly one commit");
  require(out.index == index, "found table index");
}
} // namespace

int main() {
  if (const char* trace_dir = std::getenv("CT0_TRACE_DIR")) {
    command_trace.open(std::string(trace_dir) + "/commands.mem");
    response_trace.open(std::string(trace_dir) + "/responses.mem");
    require(command_trace.is_open() && response_trace.is_open(),
            "open RTL trace outputs");
  }
  static full::FullRuntime ref;
  Input input("ct0_requests");
  Output output("ct0_responses");
  for (unsigned i = 0; i < 32; ++i)
    compare(transact(input, output, command(READ, i)), ok(),
            pack_record(ref.owners.record[i]), 0, i, "cold defaults");

  const auto id = identity();
  ref.inputs.identity = id;
  ref.request_valid = true;
  ref.model_header_valid = true;
  ref.owners.type_valid[0] = true;
  ref.owners.type_valid[1] = true;
  Command context = command(CONTEXT);
  context.identity = pack_identity(id);
  context.request_valid = 1;
  context.model_header_valid = 1;
  context.type_valid = 3;
  compare(transact(input, output, context), ok(), 0, 0, 0, "context");

  // The 32 storage positions all receive full records. Index 31 exercises
  // the final table entry; index 0 is used for same-address operations.
  const std::array<std::pair<Buffer, uint8_t>, 31> refs = {{
    {Buffer::HIDDEN,0}, {Buffer::NORM,0}, {Buffer::TMP,0},
    {Buffer::MARKER,0}, {Buffer::QKV,0}, {Buffer::QKV,1},
    {Buffer::WI,0}, {Buffer::GATE,0}, {Buffer::ATT_OUT,0},
    {Buffer::HEAD_WORK,0}, {Buffer::HEAD_WORK,1},
    {Buffer::LN_ROW,0}, {Buffer::QUANT_INPUT,0},
    {Buffer::QUANT_INPUT,1}, {Buffer::A8,0}, {Buffer::A8,1},
    {Buffer::WEIGHT,0}, {Buffer::WEIGHT,1}, {Buffer::PS,0},
    {Buffer::PS,1}, {Buffer::KV,0}, {Buffer::KV,1},
    {Buffer::SCORE_PROB,0}, {Buffer::SCORE_PROB,1},
    {Buffer::Q_TILE,0}, {Buffer::Q_TILE,1},
    {Buffer::AV_PARTIAL,0}, {Buffer::AV_PARTIAL,1},
    {Buffer::ROPE_HEAD,0}, {Buffer::ROPE_HEAD,1},
    {Buffer::LN_GAMMA,0}
  }};
  std::array<full::FullOwnerSpec, 32> specs{};
  for (unsigned i = 0; i < 32; ++i) {
    specs[i] = i == 31 ? make_spec(Buffer::TYPE_ROWS) :
                            make_spec(refs[i].first, refs[i].second);
    if (i == 9) specs[i].region = 1;
    if (i == 10) specs[i].region = 2;
    ref.owners.record[i] = make_record(specs[i], id);
    if (i == 1) { // Saturated lease has no further room.
      ref.owners.record[i].state = CacheState::READ;
      ref.owners.record[i].readers = 255;
    }
    if (i == 12) ++ref.owners.record[i].identity.request_id;
    Command load = command(LOAD, i);
    load.record = pack_record(ref.owners.record[i]);
    compare(transact(input, output, load), ok(), load.record, 0, i,
            "full fixture load");
  }
  for (unsigned i = 0; i < 32; ++i)
    compare(transact(input, output, command(READ, i)), ok(),
            pack_record(ref.owners.record[i]), 0, i, "full capacity readback");

  unsigned commits = 0;
  auto test = [&](Opcode opcode, const full::FullOwnerSpec& spec,
                  uint8_t batch, uint16_t row0, uint16_t rows,
                  unsigned owner_index, const char* label) {
    Command c = command(opcode);
    c.spec = pack_spec(spec); c.batch = batch; c.row0 = row0; c.rows = rows;
    Check expected = opcode == REQUIRE ?
        full::full_require_owner(ref, spec, batch, row0, rows) :
        opcode == ACQUIRE ?
        full::full_acquire_owner(ref, spec, batch, row0, rows) :
        full::full_release_read_owner(ref, spec);
    if (expected && opcode != REQUIRE) ++commits;
    compare(transact(input, output, c), expected,
            pack_record(ref.owners.record[owner_index]), commits,
            owner_index, label);
    compare(transact(input, output, command(READ, owner_index)), ok(),
            pack_record(ref.owners.record[owner_index]), commits,
            owner_index, "post-operation full readback");
  };

  test(REQUIRE, specs[0], 0, 0, 2, 0, "require covered range");
  test(REQUIRE, specs[0], 0, 1, 2, 0, "out of scope reject");
  test(ACQUIRE, specs[0], 0, 0, 1, 0, "first acquire");
  test(ACQUIRE, specs[31], 0, 0, 1, 31, "other address acquire");
  test(ACQUIRE, specs[0], 0, 1, 1, 0, "second acquire same address");
  test(RELEASE_READ, specs[0], 0, 0, 0, 0, "first release keeps READ");
  test(RELEASE_READ, specs[31], 0, 0, 0, 31, "other release READY");
  test(RELEASE_READ, specs[0], 0, 0, 0, 0, "last release READY");
  test(RELEASE_READ, specs[0], 0, 0, 0, 0, "readers zero reject");
  test(ACQUIRE, specs[1], 0, 0, 1, 1, "readers 255 reject");
  test(REQUIRE, specs[12], 0, 0, 1, 12, "wrong identity reject");
  test(REQUIRE, specs[31], 0, 2, 1, 31, "type bit absent reject");
  test(REQUIRE, specs[31], 0, 0, 1, 31, "type bit present");
  auto epoch = specs[0]; ++epoch.ref.epoch;
  test(ACQUIRE, epoch, 0, 0, 1, 0, "wrong epoch reject no write");
  auto width = specs[0]; ++width.width;
  test(REQUIRE, width, 0, 0, 1, 0, "wrong spec reject no write");
  auto alias = specs[6]; alias.ref.id = Buffer::DEC_FF;
  test(REQUIRE, alias, 0, 0, 1, 6, "WI/DEC_FF physical alias then spec reject");

  // Once operations begin, fixture writes and context replacement are
  // rejected; the full table and commit count remain intact.
  Command illegal = command(LOAD, 0);
  illegal.record = 0;
  Response rejected = transact(input, output, illegal);
  require(rejected.status == unsigned(Status::E_PROTOCOL) &&
          rejected.commit_count == commits, "load locked after operation");
  compare(transact(input, output, command(READ, 0)), ok(),
          pack_record(ref.owners.record[0]), commits, 0,
          "locked fixture cannot alter record");
  std::cout << "CT0_HOST_PASS checks=" << checks
            << " operations=16 records=32 commits=" << commits
            << " trace_transactions=" << trace_transactions << '\n';
}
