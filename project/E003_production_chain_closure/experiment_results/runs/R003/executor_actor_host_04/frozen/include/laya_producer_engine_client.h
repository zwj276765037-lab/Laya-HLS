#pragma once

#include "laya_compute_portal_client.h"
#include "laya_generated_provenance_events.h"
#include "laya_producer_engine.h"

namespace laya::producer {

// Validate and acquire the exact source window consumed by the first
// partitioned LayerNorm engine.  The destination must already have been
// claimed by the Controller, but no output coverage is added here.
Check prepare_layernorm(full::FullRuntime&, const full::FullMemory&,
                        const LayerNormTask&, full::FullOwnerSpec& source,
                        full::FullOwnerSpec& destination);

// Build the byte-exact engine command from the already-authorized provenance
// BEGIN.  This allocates one persistent producer request sequence.
Check build_layernorm_request(full::FullRuntime&, const full::FullMemory&,
                              const portal::ModelBinding&,
                              const LayerNormTask&,
                              const provenance::Request& begin, Request&);

// Import one fully decoded engine completion.  This is the only path that
// transfers actual store-helper bytes into the physical END accounting.  It
// also releases the source read lease, applies logical coverage on success,
// and constructs the deferred TaskDone without retiring it.
Check accept_layernorm_completion(full::FullRuntime&,
                                  const LayerNormTask&,
                                  const full::FullOwnerSpec& source,
                                  const full::FullOwnerSpec& destination,
                                  const provenance::Request& begin,
                                  const Completion&, TaskDone&);

// Settle a fully bound adapter-local rejection.  LOCAL_REJECT proves that the
// external producer request was not emitted, so physical store commitment must
// still be exactly zero.  The already-acquired source lease is released once,
// the destination remains unpublished, and the existing BEGIN is left active
// for its matching END/fence.
Check accept_layernorm_local_reject(full::FullRuntime&,
                                    const LayerNormTask&,
                                    const full::FullOwnerSpec& source,
                                    const full::FullOwnerSpec& destination,
                                    const provenance::Request& begin,
                                    Check rejection, TaskDone&);

} // namespace laya::producer
