#pragma once

#include "laya_controller_transaction.h"

namespace laya::transaction::mapping {

// A positive entry is one LTX1 source-byte offset; a negative entry is a
// constant byte.  The three immutable maps describe existing wire fields,
// never an owner, identity allocator, or publication authority.
using Map = std::array<int16_t, portal::kCommandBytes>;

constexpr Map blank() {
  Map m{};
  for (unsigned i = 0; i < m.size(); ++i) m[i] = -1;
  return m;
}

constexpr void copy(Map& m, unsigned dst, unsigned src, unsigned size) {
  for (unsigned i = 0; i < size; ++i) m[dst + i] = int16_t(src + i);
}

constexpr void constant(Map& m, unsigned dst, uint64_t value, unsigned size) {
  for (unsigned i = 0; i < size; ++i)
    m[dst + i] = int16_t(-1 - int((value >> (8 * i)) & 255u));
}

constexpr Map compute() {
  Map m = blank();
  constant(m, 0, portal::kCommandMagic, 4);
  constant(m, 4, portal::kVersion, 2);
  copy(m, 6, 10, 2); copy(m, 8, 16, 8); copy(m, 16, 148, 4);
  constant(m, 24, portal::kCommandBeats, 2);
  constant(m, 26, portal::kResponseBeats, 2);
  copy(m, 64, 64, 96);
  for (unsigned i = 0; i < 5; ++i) copy(m, 160 + 8 * i, 612 + 8 * i, 6);
  copy(m, 166, 660, 1); copy(m, 198, 661, 1);
  copy(m, 200, 160, 416);
  copy(m, 616, 676, 4); copy(m, 620, 682, 4);
  copy(m, 624, 668, 8); copy(m, 632, 680, 2);
  copy(m, 634, 686, 1); copy(m, 635, 663, 3);
  copy(m, 640, 688, 48); copy(m, 688, 736, 16);
  copy(m, 704, 752, 48); copy(m, 752, 800, 128);
  copy(m, 880, 928, 16); copy(m, 896, 944, 4);
  copy(m, 904, 952, 24); copy(m, 928, 576, 36);
  copy(m, 964, 652, 6); copy(m, 970, 662, 1);
  return m;
}

constexpr Map provenance() {
  Map m = blank();
  constant(m, 0, provenance::kRequestMagic, 4);
  constant(m, 4, provenance::kVersion, 2);
  copy(m, 6, 10, 2); copy(m, 8, 16, 8); copy(m, 16, 148, 4);
  constant(m, 24, provenance::kRequestBeats, 2);
  constant(m, 26, provenance::kResponseBeats, 2);
  copy(m, 32, 24, 8); copy(m, 40, 576, 3);
  copy(m, 44, 584, 8); copy(m, 56, 592, 8);
  copy(m, 64, 64, 512);
  copy(m, 576, 579, 1); copy(m, 578, 580, 1);
  copy(m, 580, 600, 4); copy(m, 584, 608, 16);
  for (unsigned i = 0; i < 2; ++i) {
    const unsigned dst = 608 + 128 * i, src = 624 + 128 * i;
    copy(m, dst, src, 6); copy(m, dst + 8, src + 8, 6);
    copy(m, dst + 6, src + 16, 1); copy(m, dst + 14, src + 17, 1);
    copy(m, dst + 16, src + 18, 13); copy(m, dst + 32, src + 32, 56);
    copy(m, 864 + 64 * i, 880 + 64 * i, 43);
  }
  return m;
}

constexpr Map producer() {
  Map m = blank();
  constant(m, 0, producer::kRequestMagic, 4);
  constant(m, 4, producer::kVersion, 2);
  constant(m, 6, producer::kRequestBeats, 2);
  copy(m, 8, 10, 2);
  constant(m, 12, producer::kCompletionBeats, 2);
  copy(m, 16, 16, 16); copy(m, 64, 64, 512);
  copy(m, 576, 576, 6); copy(m, 584, 584, 6);
  copy(m, 582, 592, 1); copy(m, 590, 593, 1);
  copy(m, 592, 600, 2); copy(m, 594, 596, 1);
  copy(m, 595, 592, 4); copy(m, 600, 608, 8);
  copy(m, 608, 616, 48); copy(m, 656, 604, 4);
  copy(m, 660, 597, 1);
  return m;
}

inline constexpr Map kCompute = compute();
inline constexpr Map kProvenance = provenance();
inline constexpr Map kProducer = producer();

} // namespace laya::transaction::mapping
