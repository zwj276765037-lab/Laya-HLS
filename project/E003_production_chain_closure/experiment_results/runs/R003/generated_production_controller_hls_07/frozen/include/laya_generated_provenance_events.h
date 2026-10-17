#pragma once

#include "laya_compute_portal_client.h"
#include "laya_generated_provenance_hls.h"

namespace laya::provenance {

Check build_owner_event(full::FullRuntime&, const full::FullMemory&,
                        const portal::ModelBinding&, Action,
                        const full::FullOwnerSpec*,
                        const full::FullOwnerSpec* old_owner,
                        uint8_t descriptor_count, Request&);

template<class Task>
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const Task&,
                            uint32_t, OutputUnit, Request&, bool& protected_task) {
  protected_task = false;
  return ok();
}

Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const EmbeddingTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const LayerNormTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const RopeTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const AVTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const FPLinearTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const VectorTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const GatherTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const SoftmaxTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const StatsTask&,
                            uint32_t, OutputUnit, Request&, bool&);
Check build_generated_begin(full::FullRuntime&, const full::FullMemory&,
                            const portal::ModelBinding&, const ConcatActTask&,
                            uint32_t, OutputUnit, Request&, bool&);

Check arm_generated_store_tracker(full::FullRuntime&, const Request&);
Check build_generated_end(full::FullRuntime&, const Request& begin,
                          const TaskDone&, Request& end);
void clear_generated_store_tracker(full::FullRuntime&);

} // namespace laya::provenance
