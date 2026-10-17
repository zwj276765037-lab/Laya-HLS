#pragma once

#include <array>
#include <cstddef>
#include <cstdint>

#include "../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/q8_tm1tn8_session_abi_v2.h"

namespace laya::q8_session_v2 {

using Digest = std::array<uint8_t, 32>;
using Tag = std::array<uint8_t, 16>;

struct ModelBo {
  uint64_t device_base = 0;
  uint64_t bytes = 0;
  uint64_t allocation_cookie = 0;
  bool readonly = false;
};

// Filled from a freshly prepared session and the five live BO objects. A
// validation record alone is insufficient to construct a device session.
struct Session {
  std::array<Tag, 4> tags{};
  Digest validation_record_sha256{};
  Digest manifest_sha256{};
  Digest candidate_build_sha256{};
  Digest source_gguf_sha256{};
  std::array<uint8_t, 16> context_cookie{};
  uint64_t model_generation = 0;
  uint32_t profile = q8_tm1tn8_v2::STRICT;
  std::array<ModelBo, 5> model{};
};

struct Operator {
  // The unmodified v1 word positions 4..31, populated from the live request
  // and task scheduler. Management commands always serialize these as zero.
  std::array<uint32_t, 28> request_and_task_words{};
  uint32_t flags = 0;
  uint64_t activation_base = 0, out0_base = 0, out1_base = 0;
  uint64_t activation_span = 0, out0_span = 0, out1_span = 0;
  uint32_t trace_row_local = 0, trace_column = 0;
};

using Descriptor = std::array<uint8_t, q8_tm1tn8_v2::kDescriptorBytes>;
using Binding = std::array<uint64_t, q8_tm1tn8_v2::kBindingWords>;

// Throws std::invalid_argument before hardware submission for a short BO or
// malformed live binding. REGISTER/REVOKE use an empty Operator.
Descriptor encode(const Session& session, q8_tm1tn8_v2::Command command,
                  const Operator& op, size_t descriptor_bo_bytes,
                  size_t observed_bo_bytes);
Binding binding_from_live_bos(const Session& session);

}  // namespace laya::q8_session_v2
