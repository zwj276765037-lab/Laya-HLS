#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>

extern "C" void full_cache_structure_pilot(
    uint8_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, bool,
    uint32_t*, uint32_t*);

namespace {
struct Address { uint32_t i, j, k, l; };
struct ArrayCase { Address last, neighbor; };
constexpr std::array<ArrayCase, 13> cases = {{
    {{5373951, 0, 0, 0}, {5373950, 0, 0, 0}},
    {{167935, 0, 0, 0}, {167934, 0, 0, 0}},
    {{5247, 0, 0, 0}, {5246, 0, 0, 0}},
    {{15, 127, 31, 0}, {15, 127, 30, 0}},
    {{15, 127, 0, 0}, {15, 126, 0, 0}},
    {{15, 4095, 0, 0}, {15, 4094, 0, 0}},
    {{15, 5247, 0, 0}, {15, 5246, 0, 0}},
    {{1, 1023, 0, 0}, {1, 1022, 0, 0}},
    {{1, 1024, 63, 0}, {1, 1024, 62, 0}},
    {{1, 1, 1023, 63}, {1, 1, 1023, 62}},
    {{1, 15, 1023, 0}, {1, 15, 1022, 0}},
    {{15, 63, 0, 0}, {15, 62, 0, 0}},
    {{255, 1027, 0, 0}, {255, 1026, 0, 0}},
}};

void require(bool okay, const char* reason, unsigned target) {
  if (!okay) {
    std::cerr << "CACHE_STRUCTURE_PILOT_FAIL target=" << target << ' '
              << reason << '\n';
    std::exit(1);
  }
}

uint32_t access(unsigned target, Address a, uint32_t value, bool write,
                uint32_t expected_status = 0) {
  uint32_t result = 0xdeadbeef, status = 99;
  full_cache_structure_pilot(static_cast<uint8_t>(target), a.i, a.j, a.k,
                             a.l, value, write, &result, &status);
  require(status == expected_status, "status", target);
  return result;
}
} // namespace

int main() {
  require(access(13, {}, 0, false) == ((255u << 8) | 6u),
          "cold metadata default", 13);
  require(access(13, {31, 0, 0, 0}, 0, false) == ((255u << 8) | 6u),
          "last metadata default", 13);
  access(13, {}, 3, true);
  require(access(13, {}, 0, false) == ((255u << 8) | 3u),
          "metadata state writeback", 13);
  require(access(13, {31, 0, 0, 0}, 0, false) == ((255u << 8) | 6u),
          "metadata neighbor preserved", 13);
  for (unsigned t = 0; t < cases.size(); ++t) {
    require(access(t, {}, 0, false) == 0, "cold first zero", t);
    require(access(t, cases[t].last, 0, false) == 0, "cold last zero", t);
  }
  for (unsigned t = 0; t < cases.size(); ++t) {
    access(t, {}, 11 + t, true);
    access(t, cases[t].last, 41 + t, true);
  }
  for (unsigned t = 0; t < cases.size(); ++t) {
    require(access(t, {}, 0, false) == 11 + t, "first readback", t);
    require(access(t, cases[t].last, 0, false) == 41 + t,
            "last readback", t);
    require(access(t, cases[t].neighbor, 0, false) == 0,
            "adjacent element preserved", t);
    Address invalid = cases[t].last;
    ++invalid.i;
    access(t, invalid, 0, false, 1);
  }
  std::cout << "CACHE_STRUCTURE_PILOT_PASS arrays=13 first_last_neighbor_bounds\n";
}
