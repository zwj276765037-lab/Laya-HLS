#include "laya_types.h"

#include <cstdint>
#include <cstdlib>
#include <iostream>

extern "C" void full_owner_index_pilot(
    uint8_t, uint32_t*, uint32_t*, uint32_t*, uint32_t*, uint32_t*,
    uint32_t*, uint32_t*, uint32_t*, uint32_t*, uint32_t*);

namespace {
struct State {
  uint32_t status, slot0, slot1, slot2, numeric, claims, coverage;
  uint32_t slot2_id, request_high, generation;
};
unsigned checks = 0;
void require(bool okay, const char* reason) {
  ++checks;
  if (!okay) {
    std::cerr << "OWNER_INDEX_PILOT_FAIL step=" << checks << ' '
              << reason << '\n';
    std::exit(1);
  }
}
State run(uint8_t operation, laya::Status expected) {
  State s{};
  full_owner_index_pilot(operation, &s.status, &s.slot0, &s.slot1,
                         &s.slot2, &s.numeric, &s.claims, &s.coverage,
                         &s.slot2_id, &s.request_high, &s.generation);
  require(s.status == uint32_t(expected), "status");
  return s;
}
} // namespace

int main() {
  using laya::Status;
  auto s = run(0, Status::OK);
  require(s.generation == 1 && s.request_high == 10, "request init");
  s = run(1, Status::OK);
  require(s.slot0 == 1 && s.slot1 == 1 && s.claims == 2,
          "QKV first empty slots are distinct");
  run(2, Status::OK);
  s = run(3, Status::E_BUFFER);
  require(s.slot0 == 1 && s.slot1 == 1 && s.claims == 2,
          "failed second QKV claim leaves first eligible slot untouched");
  s = run(4, Status::E_PROTOCOL);
  require(s.slot0 == 1 && s.slot1 == 1 && s.claims == 2,
          "busy recycle rejects before mutation");
  run(5, Status::OK);
  s = run(6, Status::OK);
  require(s.slot0 == 1 && s.slot1 == 1 && s.claims == 0 &&
          s.request_high == 10, "recycle retains epochs and request high");
  s = run(7, Status::E_PROTOCOL);
  require(s.slot2_id == uint32_t(laya::Buffer::HIDDEN) && s.slot2 == 1 &&
          s.numeric == 3 && s.claims == 7 && s.coverage == 0x55,
          "exhausted numeric-only A8 recycle is atomic");
  s = run(8, Status::OK);
  require(s.slot2_id == uint32_t(laya::Buffer::A8) && s.slot2 == 3 &&
          s.numeric == 3 && s.claims == 0 && s.coverage == 0,
          "numeric-only A8 creates slot and clears coverage");
  s = run(9, Status::OK);
  require(s.slot2 == 4 && s.claims == 1,
          "owner-only A8 advances full watermark");
  s = run(10, Status::OK);
  require(s.slot2 == 4 && s.numeric == 4 && s.claims == 0,
          "owner-only A8 recycle synchronizes numeric watermark");
  s = run(11, Status::OK);
  require(s.slot2 == 4 && s.numeric == 4,
          "higher owner A8 watermark wins");
  s = run(12, Status::OK);
  require(s.slot2 == 6 && s.numeric == 6,
          "higher numeric A8 watermark wins");
  s = run(13, Status::OK);
  require(s.slot2 == 6 && s.numeric == 6 && s.request_high == 0 &&
          s.generation == 2, "soft reset preserves epoch and advances generation");
  std::cout << "OWNER_INDEX_PILOT_PASS checks=" << checks << '\n';
}
