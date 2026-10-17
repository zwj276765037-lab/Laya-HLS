#pragma once

#include <array>
#include <cstddef>
#include <cstdint>

namespace laya {

// Compare every byte without the std::array equality lowering to an external
// memcmp. The accumulated difference retains full packet and reserved-byte
// validation and gives HLS a fixed, serializable loop.
template<std::size_t N>
bool packet_equal(const std::array<uint8_t, N>& a,
                  const std::array<uint8_t, N>& b) {
  uint8_t difference = 0;
  for (std::size_t i = 0; i < N; ++i) {
#pragma HLS unroll off
    difference = uint8_t(difference | uint8_t(a[i] ^ b[i]));
  }
  return difference == 0;
}

} // namespace laya
