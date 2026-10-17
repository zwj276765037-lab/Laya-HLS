#pragma once
#include "laya_numeric_tasks.h"

namespace laya {

// Explicit wire packing avoids host struct padding. Every request tag,
// context field and buffer reference survives the complete RTL invocation.
inline void numeric_service_put(uint64_t words[16], unsigned byte,
                                uint64_t value, unsigned size) {
  for (unsigned i = 0; i < size; ++i)
    words[(byte + i) / 8] |= ((value >> (i * 8)) & 255u)
                              << (((byte + i) % 8) * 8);
}

inline void numeric_service_identity(uint64_t words[16],
                                     const NumericIdentity& id,
                                     const TaskContext& ctx) {
  for (unsigned i = 0; i < 16; ++i) words[i] = 0;
  numeric_service_put(words, 0, id.request_id, 8);
  numeric_service_put(words, 8, id.generation, 8);
  numeric_service_put(words, 16, id.B, 2);
  numeric_service_put(words, 18, id.S, 2);
  for (unsigned i = 0; i < 16; ++i) {
    numeric_service_put(words, 20 + i, id.model_tag[i], 1);
    numeric_service_put(words, 36 + i, id.numeric_tag[i], 1);
    numeric_service_put(words, 52 + i, id.layout_tag[i], 1);
    numeric_service_put(words, 68 + i, id.build_tag[i], 1);
  }
  numeric_service_put(words, 84, ctx.task_id, 4);
  numeric_service_put(words, 88, uint8_t(ctx.op), 1);
  numeric_service_put(words, 89, ctx.stage, 1);
  numeric_service_put(words, 90, ctx.layer, 1);
  numeric_service_put(words, 91, ctx.batch, 1);
  numeric_service_put(words, 92, uint8_t(ctx.row_space), 1);
  numeric_service_put(words, 93, ctx.row0, 2);
  numeric_service_put(words, 95, ctx.rows, 1);
}

inline void numeric_service_ref(uint64_t words[16], unsigned byte,
                                BufferRef ref, uint8_t region = 0) {
  numeric_service_put(words, byte, ref.epoch, 4);
  numeric_service_put(words, byte + 4, uint8_t(ref.id), 1);
  numeric_service_put(words, byte + 5, ref.bank, 1);
  numeric_service_put(words, byte + 6, region, 1);
}

} // namespace laya
