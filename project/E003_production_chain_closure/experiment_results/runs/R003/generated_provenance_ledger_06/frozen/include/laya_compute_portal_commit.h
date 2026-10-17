#pragma once

#include "laya_full_runtime.h"

namespace laya::portal {

// Apply a trusted, fully drained portal response to the generated
// controller's shadow owner/coverage state. These functions do not perform
// numerical arithmetic or access service payloads.
Check commit_load(full::FullRuntime&, const full::FullWeightDescriptor&,
                  const LoadTask&, TaskDone&);
Check commit_quant(full::FullRuntime&, const full::FullOwnerSpec& source,
                   const QuantTask&, TaskDone&);
Check commit_geglu(full::FullRuntime&, const full::FullOwnerSpec& source,
                   const full::FullOwnerSpec& output,
                   const VectorTask&, TaskDone&);
Check commit_matrix(full::FullRuntime&, const full::FullOwnerSpec& output,
                    const full::FullOwnerSpec* qkv_pair,
                    const LinearTask&, TaskDone&);

} // namespace laya::portal

