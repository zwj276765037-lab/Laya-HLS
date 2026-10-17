// Dormant cooperative actor-step model. This is logical/physical-stall test
// source, not a claim that the vendor CPU header models real B timing.
#include "c1_write_response.h"

#include <cstdint>
#include <stdexcept>
#include <iostream>

namespace {
void require(bool good, const char* reason) {
  if (!good) throw std::runtime_error(reason);
}

struct Stalls { bool aw_ready, w_ready, b_valid; };
struct ModelWriter {
  enum Stage { IDLE, AW, W, B, ACK, STOPPED } stage = IDLE;
  c1_write::Command held = {};
  uint64_t registered_base_bytes = 0;
  unsigned sent = 0, beat_left = 0, physical_b = 0;
  unsigned accepted_w = 0, emitted_ack = 0;
  bool eos = false;

  void step(c1_write::CommandStream& commands,
            c1_write::AckStream& acknowledgments, Stalls stalls) {
    switch (stage) {
      case IDLE: {
        c1_write::CommandWord raw;
        if (!commands.read_nb(raw)) break;
        held = c1_write::unpack(raw);
        require(c1_write::valid(held, true), "invalid observed packet");
        sent = 0;
        eos = held.kind == c1_write::EOS;
        stage = eos ? ACK : AW;
        break;
      }
      case AW:
        if (stalls.aw_ready) {
          const uint64_t addr = registered_base_bytes +
                                (uint64_t(held.word_offset) + sent) * 4;
          const unsigned to_boundary = unsigned((4096 - (addr & 4095)) / 4);
          require(to_boundary != 0, "unaligned registered physical base");
          const unsigned unsent = unsigned(held.count) - sent;
          beat_left = unsent < to_boundary ? unsent : to_boundary;
          stage = W;
        }
        break;
      case W:
        if (stalls.w_ready) {
          require(beat_left != 0, "extra W beat");
          ++sent; ++accepted_w; --beat_left;
          if (!beat_left) stage = B;
        }
        break;
      case B:
        if (stalls.b_valid) {
          ++physical_b;
          stage = sent == unsigned(held.count) ? ACK : AW;
        }
        break;
      case ACK:
        require(commands.size() <= 1 && acknowledgments.size() <= 1,
                "model FIFO exceeded depth one");
        if (acknowledgments.size() == 0) {
          acknowledgments.write(c1_write::pack(
              c1_write::Ack{held.kind, held.trace_slot, held.sequence}));
          ++emitted_ack;
          stage = eos ? STOPPED : IDLE;
        }
        break;
      case STOPPED:
        require(commands.size() == 0, "command after EOS");
        break;
    }
  }
};

struct Rig {
  c1_write::CommandStream commands;
  c1_write::AckStream acks;
  c1_write::Credit credit = {};
  ModelWriter writer;
  Rig(uint64_t registered_base = 0) {
    credit.reset_quiescent();
    writer.registered_base_bytes = registered_base;
  }
  c1_write::Command make(unsigned count, c1_write::Kind kind,
                         uint64_t word_offset, unsigned slot = 0) {
    c1_write::Command c = {};
    c.count = count; c.kind = kind; c.word_offset = word_offset;
    c.trace_slot = slot;
    for (unsigned i = 0; i < count; ++i)
      c.payload.range(i * 32 + 31, i * 32) = 0x51000000u | i;
    return c;
  }
  void submit(c1_write::Command c) {
    credit.start_edge();
    require(credit.submit(commands, c, true), "command admission failed");
    require(commands.size() == 1 && credit.unsettled,
            "one command must own exactly one debt");
  }
  bool tick(Stalls stalls, bool poll_core) {
    bool got = false; c1_write::Ack ack = {};
    credit.start_edge();
    if (poll_core) require(credit.poll(acks, got, ack), "unexpected acknowledgment");
    writer.step(commands, acks, stalls);
    require(commands.size() <= 1 && acks.size() <= 1,
            "unbounded CPU stream masked finite channel");
    return got;
  }
  void drain_after_stalls(unsigned expected_physical_b) {
    bool received = false;
    for (unsigned edge = 0; edge < 200; ++edge) {
      // Independent AW/W and B stalls. Final-WLAST B is held for 11 edges.
      const Stalls stalls{edge % 3 != 0, edge % 4 != 0,
                          edge > 15 && edge % 5 != 0};
      received |= tick(stalls, true);
      if (received) break;
      require(credit.unsettled, "credit freed before matched B");
    }
    require(received && writer.physical_b == expected_physical_b &&
            credit.drained(), "all physical B must precede matched ACK");
  }
};

void count_and_boundary_cases() {
  for (unsigned count : {1u, 8u, 16u}) {
    Rig rig;
    const c1_write::Kind kind = count == 8 ? c1_write::GROUP_TRACE :
                                 c1_write::REPORT;
    rig.submit(rig.make(count, kind, 64, count == 8 ? 2 : 0));
    rig.drain_after_stalls(1);
    require(rig.writer.accepted_w == count && rig.writer.emitted_ack == 1,
            "packet count or response mismatch");
  }
  Rig crossing(4092);  // Registered base makes a legal 16-word request split.
  crossing.submit(crossing.make(16, c1_write::REPORT, 0));
  crossing.drain_after_stalls(2);
  require(crossing.writer.accepted_w == 16,
          "4 KiB physical split lost a word");
}

void ack_backpressure_and_credit() {
  Rig rig;
  rig.submit(rig.make(8, c1_write::GROUP_TRACE, 2048, 1));
  for (unsigned edge = 0; edge < 40; ++edge)
    rig.tick({true, true, true}, false); // core deliberately holds ACK_READY low
  require(rig.acks.size() == 1 && rig.credit.unsettled &&
          rig.writer.stage == ModelWriter::IDLE && rig.writer.physical_b == 1,
          "logical acknowledgment must remain pending under core stall");
  rig.credit.start_edge();
  bool got = false; c1_write::Ack ack = {};
  require(rig.credit.poll(rig.acks, got, ack) && got && rig.credit.drained(),
          "matched response was not consumed");
  require(!rig.credit.submit(rig.commands,
          rig.make(1, c1_write::QUANT_Q, 1), true),
          "same-edge acknowledgment credit reused");
  rig.submit(rig.make(1, c1_write::QUANT_Q, 1));
  rig.drain_after_stalls(2);
}

void unmatched_token_and_quiescent_eos() {
  Rig bad;
  bad.submit(bad.make(1, c1_write::REPORT, 0));
  bad.acks.write(c1_write::pack(c1_write::Ack{c1_write::FINAL_OUTPUT, 0, 0}));
  bad.credit.start_edge();
  bool got = false; c1_write::Ack ack = {};
  require(!bad.credit.poll(bad.acks, got, ack) && bad.credit.stopped &&
          bad.credit.unsettled, "unexpected token granted credit");

  Rig clean;
  clean.submit(clean.make(1, c1_write::REPORT, 0));
  clean.drain_after_stalls(1);
  require(clean.credit.drained() && clean.acks.size() == 0,
          "m0 boundary has response debt");
  clean.credit.reset_quiescent(); // warm metadata reset only after drain
  clean.submit(clean.make(0, c1_write::EOS, 0));
  clean.drain_after_stalls(1); // physical count remains prior one; EOS adds none
  require(clean.writer.stage == ModelWriter::STOPPED &&
          clean.writer.physical_b == 1, "EOS had a physical write");
}

void canceled_trace_has_no_command() {
  Rig rig;
  // A failed result marks its reserved trace CANCELED and retires the slot
  // locally; the core must never submit a GROUP_TRACE command for it.
  require(rig.commands.size() == 0 && rig.writer.accepted_w == 0 &&
          rig.writer.physical_b == 0,
          "canceled trace created physical debt");
}
}  // namespace

int main() {
  try {
    count_and_boundary_cases();
    ack_backpressure_and_credit();
    unmatched_token_and_quiescent_eos();
    canceled_trace_has_no_command();
    std::cout << "C1_WRITE_RESPONSE_MODEL_SOURCE_PASS counts=1,8,16"
                 " split4k=2b token_guard=1\n";
    return 0;
  } catch (const std::exception& e) {
    std::cerr << "C1_WRITE_RESPONSE_MODEL_SOURCE_FAIL " << e.what() << '\n';
    return 1;
  }
}
