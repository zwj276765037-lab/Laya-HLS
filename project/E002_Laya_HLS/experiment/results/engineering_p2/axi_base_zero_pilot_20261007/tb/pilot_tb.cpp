#include <array>
#include <cstdint>
#include <cstdio>

extern "C" void axi_base_zero_pilot(
    const uint8_t* embedding, uint8_t* io,
    const uint8_t* w_q0, const uint8_t* w_q1,
    const uint8_t* w_scale, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1,
    uint8_t* qkv0, uint8_t* qkv1,
    uint8_t* ff0, uint8_t* ff1, uint8_t* att_out);

int main() {
  std::array<std::array<uint8_t, 4096>, 13> memory{};
  for (unsigned i = 0; i < memory.size(); ++i)
    memory[i][0] = uint8_t(0x31 + i);
  axi_base_zero_pilot(
      memory[0].data(), memory[1].data(), memory[2].data(),
      memory[3].data(), memory[4].data(), memory[5].data(),
      memory[6].data(), memory[7].data(), memory[8].data(),
      memory[9].data(), memory[10].data(), memory[11].data(),
      memory[12].data());
  for (unsigned i = 0; i < memory.size(); ++i) {
    const unsigned at = 2048 + 4 * i;
    if (memory[1][at] || memory[1][at + 1] ||
        memory[1][at + 2] != uint8_t(0x31 + i) ||
        memory[1][at + 3] != 0xa5) {
      std::fprintf(stderr, "PILOT_CSIM_FAIL bo=%u status=%u data=%u\n",
                   i, unsigned(memory[1][at]), unsigned(memory[1][at + 2]));
      return 1;
    }
  }
  std::puts("PILOT_CSIM_PASS ports=13 reads=13");
  return 0;
}
