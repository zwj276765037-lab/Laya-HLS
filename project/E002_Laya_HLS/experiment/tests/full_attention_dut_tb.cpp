#include "laya_full_runtime.h"

#include <array>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

using namespace laya;

namespace {
constexpr unsigned B = 2, S = 128, HEADS = 16, D = 64;
unsigned f32_compared = 0, negative_checks = 0;

void fail(const std::string& message) {
  std::cerr << "FULL_ATTENTION_DUT_FAIL " << message << '\n';
  std::exit(1);
}
void require(bool condition, const std::string& message) {
  if (!condition) fail(message);
}
void expect(Check check, const std::string& message) {
  if (!check)
    fail(message + " status=" + std::to_string(unsigned(check.code)) +
         " detail=" + std::to_string(check.detail));
}
void reject(Check check, Status status, const TaskDone& done, unsigned id,
            const std::string& message) {
  require(check.code == status && done.status == status &&
          done.task_id == id && done.drained && done.output_elements == 0,
          message + " status=" + std::to_string(unsigned(check.code)) +
          " detail=" + std::to_string(check.detail));
  ++negative_checks;
}
void done_ok(const TaskDone& done, unsigned id, unsigned elements,
             OutputUnit unit, const std::string& message) {
  require(done.task_id == id && done.status == Status::OK &&
          done.drained && done.output_elements == elements &&
          done.output_unit == unit, message + " TaskDone");
}
std::vector<uint8_t> read_file(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  require(bool(input), "open " + path);
  return {std::istreambuf_iterator<char>(input),
          std::istreambuf_iterator<char>()};
}
uint32_t bits(const uint8_t* data) {
  return uint32_t(data[0]) | uint32_t(data[1]) << 8 |
         uint32_t(data[2]) << 16 | uint32_t(data[3]) << 24;
}
uint32_t bits(float value) {
  uint32_t out;
  std::memcpy(&out, &value, sizeof(out));
  return out;
}
void compare_f32(const float* actual, const uint8_t* expected,
                 unsigned count, const std::string& message) {
  for (unsigned i = 0; i < count; ++i) {
    const uint32_t got = bits(actual[i]), want = bits(expected + 4 * i);
    if (got != want)
      fail(message + " index=" + std::to_string(i) +
           " expected_bits=" + std::to_string(want) +
           " actual_bits=" + std::to_string(got));
  }
  f32_compared += count;
}
void compare_f32_bytes(const uint8_t* actual, const uint8_t* expected,
                       unsigned count, const std::string& message) {
  for (unsigned i = 0; i < count; ++i) {
    const uint32_t got = bits(actual + 4 * i),
                   want = bits(expected + 4 * i);
    if (got != want)
      fail(message + " index=" + std::to_string(i) +
           " expected_bits=" + std::to_string(want) +
           " actual_bits=" + std::to_string(got));
  }
  f32_compared += count;
}
size_t raw_offset(unsigned batch, unsigned row, unsigned plane,
                  unsigned head) {
  return ((((size_t(batch) * S + row) * 3 + plane) * HEADS + head) * D) * 4;
}
size_t case_offset(unsigned head, unsigned batch, unsigned tile,
                   unsigned row, unsigned width) {
  return (((((size_t(head) * B + batch) * 2 + tile) * 16 + row) * width) * 4);
}
void write_qkv(full::FullRuntime& rt, const std::vector<uint8_t>& raw,
               unsigned plane, unsigned head, unsigned batch, unsigned row) {
  Address address;
  expect(qkv_address(uint8_t(plane), uint8_t(batch), uint8_t(head),
                     uint16_t(row), 0, B, S, address), "QKV address");
  expect(full::full_write(rt.memory, address.bo, address.offset,
                          raw.data() + raw_offset(batch, row, plane, head),
                          4 * D), "QKV physical write");
}
void compare_qkv(full::FullRuntime& rt, const std::vector<uint8_t>& expected,
                 const std::string& label) {
  std::array<uint8_t, 4 * D> observed{};
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < HEADS; ++head)
      for (unsigned batch = 0; batch < B; ++batch)
        for (unsigned row = 0; row < S; ++row) {
          Address address;
          expect(qkv_address(uint8_t(plane), uint8_t(batch), uint8_t(head),
                             uint16_t(row), 0, B, S, address),
                 "QKV compare address");
          expect(full::full_read(rt.memory, address.bo, address.offset,
                                 observed.data(), observed.size()),
                 "QKV physical read");
          compare_f32_bytes(
              observed.data(),
              expected.data() + raw_offset(batch, row, plane, head), D,
              label + " plane=" + std::to_string(plane) +
              " head=" + std::to_string(head) +
              " batch=" + std::to_string(batch) +
              " row=" + std::to_string(row));
        }
}
full::FullOwnerSpec qkv_spec(BufferRef ref, Content content, unsigned layer) {
  return {ref, 0, 2, uint8_t(layer), 255, RowSpace::TOKEN,
          0, S, D, content};
}
void same_owner(const full::FullOwnerRecord& before,
                const full::FullOwnerRecord& after,
                const std::string& message) {
  require(before.ref == after.ref &&
          before.max_claimed_epoch == after.max_claimed_epoch &&
          before.state == after.state && before.valid == after.valid &&
          before.content == after.content && before.readers == after.readers &&
          std::memcmp(before.covered_rows, after.covered_rows,
                      sizeof(before.covered_rows)) == 0,
          message);
}
}  // namespace

int main(int argc, char** argv) {
  require(argc == 6,
          "usage: full_attention_dut_tb PACKAGE REQUEST FIXTURE_DIR "
          "MODE(full|slide) OUTPUT_HINT");
  const std::string package = argv[1], fixture = argv[3], mode = argv[4];
  require(mode == "full" || mode == "slide", "attention mode");
  const unsigned layer = mode == "full" ? 0 : 1;
  const unsigned rope_mode = layer % 3 == 0 ? 0 : 1;
  auto aux = read_file(package + "/aux.bin");
  auto request = read_file(argv[2]);
  const auto raw = read_file(fixture + "/raw_qkv.f32.bin");
  const auto final = read_file(fixture + "/" + mode + "_final_qkv.f32.bin");
  const auto mask = read_file(fixture + "/attention_mask.u8.bin");
  const auto scores = read_file(fixture + "/" + mode + "_score.f32.bin");
  const auto probs = read_file(fixture + "/" + mode + "_probability.f32.bin");
  const auto av = read_file(fixture + "/" + mode + "_av.f32.bin");
  require(request.size() == 1856 && aux.size() >= 128 &&
          raw.size() == B * S * 3072 * 4 && final.size() == raw.size() &&
          mask.size() == B * S &&
          scores.size() == 2 * B * 2 * 16 * S * 4 &&
          probs.size() == scores.size() &&
          av.size() == 2 * B * 2 * 16 * D * 4,
          "exact full-shape attention fixture spans");
  std::memcpy(request.data() + 40, aux.data() + 32, 64);
  std::vector<uint8_t> io(32768, 0), qkv0(12u << 20, 0),
      qkv1(12u << 20, 0), att(8u << 20, 0);
  std::memcpy(io.data(), request.data(), request.size());
  static full::FullRuntime rt;
  rt.memory.io = io.data(); rt.memory.io_bytes = io.size();
  rt.memory.aux = aux.data(); rt.memory.aux_bytes = aux.size();
  rt.memory.qkv0 = qkv0.data(); rt.memory.qkv0_bytes = qkv0.size();
  rt.memory.qkv1 = qkv1.data(); rt.memory.qkv1_bytes = qkv1.size();
  rt.memory.att_out = att.data(); rt.memory.att_out_bytes = att.size();
  expect(full::full_parse_request(rt), "real B2 request parse");
  require(rt.inputs.identity.B == B && rt.inputs.identity.S == S,
          "B2/S128 request identity");
  for (unsigned batch = 0; batch < B; ++batch)
    for (unsigned key = 0; key < S; ++key)
      require(rt.inputs.attention_mask[batch][key] == mask[batch * S + key],
              "independent ABI mask matches parsed request");

  unsigned task_id = 0;
  TaskDone done;
  LoadTask rope{};
  rope.ctx = {++task_id, Op::LOAD_ROPE, 2, uint8_t(layer), 0,
              RowSpace::BATCH, 0, 1};
  rope.kind = 3;
  rope.dst = {Buffer::ROPE_TABLE, uint8_t(rope_mode), 1};
  rope.byte_count = 2u * 1025u * 64u * 4u;
  expect(full::full_run_task(rt, rope, done), "real GGUF RoPE table load");
  done_ok(done, task_id, rope.byte_count, OutputUnit::BYTES, "RoPE load");

  const full::FullOwnerSpec raw_spec[2] = {
      qkv_spec({Buffer::QKV, 0, 1}, Content::QKV_RAW, layer),
      qkv_spec({Buffer::QKV, 1, 1}, Content::QKV_RAW, layer)};
  full::FullOwnerSpec final_spec[2] = {
      qkv_spec({Buffer::QKV, 0, 2}, Content::QKV_FINAL, layer),
      qkv_spec({Buffer::QKV, 1, 2}, Content::QKV_FINAL, layer)};
  expect(full::full_claim_qkv_pair(rt, raw_spec), "claim B2 raw QKV pair");
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < HEADS; ++head)
      for (unsigned batch = 0; batch < B; ++batch) {
        for (unsigned row = 0; row < S; ++row)
          write_qkv(rt, raw, plane, head, batch, row);
        expect(full::full_cover_qkv(rt, raw_spec, uint8_t(plane),
                                    uint8_t(head), uint8_t(batch), 0, S),
               "cover physically written raw QKV");
      }
  expect(full::full_publish_qkv_pair(rt, raw_spec),
         "publish complete B2 raw QKV");
  compare_qkv(rt, raw, "raw_qkv");
  expect(full::full_begin_qkv_rope_pair(rt, raw_spec, final_spec),
         "begin RAW to FINAL pair lease");

  for (unsigned head = 0; head < HEADS; ++head)
    for (unsigned batch = 0; batch < B; ++batch)
      for (unsigned row0 = 0; row0 < S; row0 += 16) {
        RopeTask task{};
        task.ctx = {++task_id, Op::ROPE, 2, uint8_t(layer),
                    uint8_t(batch), RowSpace::TOKEN, uint16_t(row0), 16};
        task.src_qkv_ref = {raw_spec[0].ref, raw_spec[1].ref};
        task.dst_qkv_ref = {final_spec[0].ref, final_spec[1].ref};
        task.head = uint8_t(head);
        task.mode = uint8_t(rope_mode);
        task.table_set = uint8_t(rope_mode);
        expect(full::full_run_task(rt, task, done), "typed RoPE tile");
        done_ok(done, task_id, 16 * 128, OutputUnit::F32, "RoPE tile");
        if (head == 0 && batch == 0 && row0 == 0) {
          // The same task may not rotate an already covered Q/K position.
          std::array<uint8_t, 4 * D> before_q{}, before_k{}, after{};
          Address address_q, address_k;
          expect(qkv_address(0, 0, 0, 0, 0, B, S, address_q),
                 "duplicate probe Q address");
          expect(qkv_address(1, 0, 0, 0, 0, B, S, address_k),
                 "duplicate probe K address");
          expect(full::full_read(rt.memory, address_q.bo, address_q.offset,
                                 before_q.data(), before_q.size()),
                 "duplicate probe Q read");
          expect(full::full_read(rt.memory, address_k.bo, address_k.offset,
                                 before_k.data(), before_k.size()),
                 "duplicate probe K read");
          task.ctx.task_id = ++task_id;
          reject(full::full_run_task(rt, task, done), Status::E_BUFFER,
                 done, task_id, "duplicate RoPE rejected before rewrite");
          expect(full::full_read(rt.memory, address_q.bo, address_q.offset,
                                 after.data(), after.size()),
                 "duplicate probe Q reread");
          require(after == before_q, "duplicate RoPE preserved Q bytes");
          expect(full::full_read(rt.memory, address_k.bo, address_k.offset,
                                 after.data(), after.size()),
                 "duplicate probe K reread");
          require(after == before_k, "duplicate RoPE preserved K bytes");
        }
      }
  expect(full::full_commit_qkv_rope_pair(rt, final_spec),
         "publish full B2 final QKV pair");
  compare_qkv(rt, final, "final_qkv");

  const full::FullOwnerSpec attention_output{
      {Buffer::ATT_OUT, 0, 1}, 0, 2, uint8_t(layer), 255,
      RowSpace::TOKEN, 0, S, 1024, Content::F32};
  expect(full::full_claim_owner(rt, attention_output),
         "claim attention output for all heads");
  unsigned score_epoch = 1, partial_epoch = 1;
  for (unsigned head = 0; head < 2; ++head) {
    LoadTask kv{};
    kv.ctx = {++task_id, Op::LOAD_KV, 2, uint8_t(layer), 0,
              RowSpace::BATCH, 0, 1};
    kv.kind = 1;
    kv.dst = {Buffer::KV, 0, head + 1};
    kv.head = uint8_t(head);
    kv.planes = 3;
    kv.byte_count = 2u * B * S * D * 4u;
    expect(full::full_run_task(rt, kv, done), "load typed KV head");
    done_ok(done, task_id, kv.byte_count, OutputUnit::BYTES, "KV load");
    for (unsigned batch = 0; batch < B; ++batch)
      for (unsigned tile = 0; tile < 2; ++tile) {
        const unsigned row0 = tile ? 112 : 0;
        QKTask qk{};
        qk.ctx = {++task_id, Op::QK, 2, uint8_t(layer), uint8_t(batch),
                  RowSpace::TOKEN, uint16_t(row0), 16};
        qk.qkv_ref = {final_spec[0].ref, final_spec[1].ref};
        qk.kv = kv.dst;
        qk.score = {Buffer::SCORE_PROB, 0, score_epoch};
        qk.head = uint8_t(head);
        qk.mask_mode = uint8_t(rope_mode);
        qk.S = S;
        if (head == 0 && batch == 0 && tile == 0) {
          QKTask duplicate_bank = qk;
          duplicate_bank.qkv_ref[1] = duplicate_bank.qkv_ref[0];
          reject(full::full_run_task(rt, duplicate_bank, done),
                 Status::E_BUFFER, done, task_id,
                 "duplicate-bank QK refs rejected at task entry");
          require(!rt.score_valid, "rejected QK did not publish score");
          qk.ctx.task_id = ++task_id;
        }
        expect(full::full_run_task(rt, qk, done), "typed QK tile");
        done_ok(done, task_id, 16 * S, OutputUnit::F32, "QK tile");
        for (unsigned row = 0; row < 16; ++row)
          compare_f32(rt.cache.score[batch][row],
                      scores.data() + case_offset(head, batch, tile, row, S),
                      S, "score head=" + std::to_string(head) +
                      " batch=" + std::to_string(batch) +
                      " row=" + std::to_string(row0 + row));

        if (head == 0 && batch == 0 && tile == 0) {
          full::FullOwnerRecord before_owner, after_owner;
          expect(full::full_owner_snapshot(rt, kv.dst, 0, before_owner),
                 "snapshot live KV owner");
          const auto before_kv = std::vector<uint8_t>(
              reinterpret_cast<const uint8_t*>(rt.cache.kv),
              reinterpret_cast<const uint8_t*>(rt.cache.kv) +
                  sizeof(rt.cache.kv));
          const auto before_score = std::vector<uint8_t>(
              reinterpret_cast<const uint8_t*>(rt.cache.score[batch]),
              reinterpret_cast<const uint8_t*>(rt.cache.score[batch]) +
                  sizeof(rt.cache.score[batch]));
          LoadTask replace = kv;
          replace.ctx.task_id = ++task_id;
          replace.dst.epoch = kv.dst.epoch + 1;
          replace.head = 1;
          reject(full::full_run_task(rt, replace, done), Status::E_BUFFER,
                 done, task_id, "live SCORE blocks head-1 KV replacement");
          expect(full::full_owner_snapshot(rt, kv.dst, 0, after_owner),
                 "snapshot unchanged KV owner");
          same_owner(before_owner, after_owner,
                     "rejected KV replacement preserved owner and epoch");
          require(rt.loaded_kv_ref == kv.dst && rt.loaded_kv_head == 0 &&
                  rt.score_valid && rt.score_head == 0 &&
                  std::memcmp(rt.cache.kv, before_kv.data(),
                              before_kv.size()) == 0 &&
                  std::memcmp(rt.cache.score[batch], before_score.data(),
                              before_score.size()) == 0,
                  "rejected KV replacement preserved caches and producer");
        }

        const BufferRef prob_ref{Buffer::SCORE_PROB, 0, score_epoch + 1};
        const full::FullOwnerSpec score_owner{
            qk.score, 0, 2, uint8_t(layer), uint8_t(batch),
            RowSpace::TOKEN, uint16_t(row0), 16, S, Content::SCORE};
        auto prob_owner = score_owner;
        prob_owner.ref = prob_ref;
        prob_owner.content = Content::PROB;
        expect(full::full_begin_inplace_owner(rt, score_owner, prob_owner),
               "begin SCORE to PROB exclusive lease");
        SoftmaxTask softmax{};
        softmax.ctx = {++task_id, Op::SOFTMAX_ATT, 2, uint8_t(layer),
                       uint8_t(batch), RowSpace::TOKEN, uint16_t(row0), 16};
        softmax.src = qk.score;
        softmax.dst = prob_ref;
        softmax.length = S;
        if (head == 0 && batch == 0 && tile == 0) {
          const uint8_t saved_head = rt.loaded_kv_head;
          rt.loaded_kv_head = 1;
          reject(full::full_run_task(rt, softmax, done), Status::E_SHAPE,
                 done, task_id,
                 "softmax rejects changed KV head against SCORE ledger");
          rt.loaded_kv_head = saved_head;
          require(rt.score_valid && rt.score_ref == qk.score,
                  "rejected softmax preserved score producer");
          softmax.ctx.task_id = ++task_id;
        }
        expect(full::full_run_task(rt, softmax, done), "typed softmax tile");
        done_ok(done, task_id, 16 * S, OutputUnit::F32, "softmax tile");
        for (unsigned row = 0; row < 16; ++row)
          compare_f32(rt.cache.score[batch][row],
                      probs.data() + case_offset(head, batch, tile, row, S),
                      S, "probability head=" + std::to_string(head) +
                      " batch=" + std::to_string(batch) +
                      " row=" + std::to_string(row0 + row));

        AVTask av_task{};
        av_task.ctx = {++task_id, Op::AV, 2, uint8_t(layer), uint8_t(batch),
                       RowSpace::TOKEN, uint16_t(row0), 16};
        av_task.prob = prob_ref;
        av_task.kv = kv.dst;
        av_task.partial = {Buffer::AV_PARTIAL, 0, partial_epoch++};
        av_task.dst = attention_output.ref;
        av_task.head = uint8_t(head);
        av_task.S = S;
        if (head == 0 && batch == 0 && tile == 0) {
          AVTask wrong_head = av_task;
          wrong_head.head = 1;
          reject(full::full_run_task(rt, wrong_head, done),
                 Status::E_SHAPE, done, task_id,
                 "AV rejects head different from SCORE producer");
          require(rt.score_valid && rt.score_ref == prob_ref,
                  "rejected AV preserved probability producer");
          av_task.ctx.task_id = ++task_id;
        }
        expect(full::full_run_task(rt, av_task, done), "typed AV tile");
        done_ok(done, task_id, 16 * D, OutputUnit::F32, "AV tile");
        for (unsigned row = 0; row < 16; ++row) {
          const uint8_t* wanted =
              av.data() + case_offset(head, batch, tile, row, D);
          compare_f32(rt.cache.av_partial[row], wanted, D,
                      "AV cache head=" + std::to_string(head) +
                      " batch=" + std::to_string(batch) +
                      " row=" + std::to_string(row0 + row));
          Address address;
          expect(full::full_f32_address(rt, attention_output.ref, 0,
                                        uint8_t(batch), uint16_t(row0 + row),
                                        uint16_t(head * D), address),
                 "ATT_OUT address");
          std::array<uint8_t, 4 * D> observed{};
          expect(full::full_read(rt.memory, address.bo, address.offset,
                                 observed.data(), observed.size()),
                 "ATT_OUT read");
          compare_f32_bytes(observed.data(), wanted, D,
                            "ATT_OUT physical bytes");
        }
        score_epoch += 2;
      }
  }
  require(!rt.score_valid, "all tested score/prob pairs consumed by AV");
  std::cout << "FULL_ATTENTION_DUT_PASS mode=" << mode
            << " B=2 S=128 full_qkv_f32=786432 comparisons="
            << f32_compared << " negative_checks=" << negative_checks
            << " tasks=" << task_id << " result_hint=" << argv[5] << '\n';
  return 0;
}
