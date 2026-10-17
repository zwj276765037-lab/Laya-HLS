# Three distinct valid Scorer rows from the frozen real request

Status: architecture and source preparation only. No new fixture, independent numerical calculation, CPU build, RTL build or simulator run is released by this document.

The existing three-row tail case uses batch 1 marker rows 13–15. The frozen B2/S128 request marks all three as invalid padding candidates; their marker index is 128 and all three activation rows are identical. That case remains useful for the final marker-row address range and partial TM4 tile extent. It cannot establish different-row data isolation, and its sources and evidence stay frozen.

This isolated successor uses the same accepted B2/S128 request and Scorer checkpoints, selecting batch 1 rows 0–2. The request has marker indices 147, 163 and 174, corresponding to token positions 19, 35 and 46 within batch 1. All three marker-mask bytes are 1. The 1024-F32 activation rows and their 1024-F32 frozen Scorer outputs each have three distinct SHA-256 values. The new source preparation gate records all six row hashes and the exact request/checkpoint identities.

## Exact contract

Use family 9, layer 255, `scorer_fc1.weight`, K=N=1024, G=32, T=128, B=2, S=128, batch=1, row0=0, rows=3. The activation source is bytes [65536,77824) of the frozen `marker_norm.f32.bin`; the corresponding `scorer_fc1_baked.f32.bin` interval supplies an existing independent reference comparison. The oracle and accepted CPU DUT checkpoint files must remain byte-identical to their frozen full-file hashes. Read the original request directory fields, marker indices and mask bytes and assert all three valid candidates before deriving a new fixture.

Retain the full actual packaged Q8 Scorer weight: both 524288-byte Q shards, 65536 scale bytes and 4096 baked-bias bytes at the original BO offsets, bound to the existing manifest/generated header/GGUF tensor identities. Do not synthesize different rows, permute or concatenate unrelated requests, reuse DUT output as gold, reduce K or N, or change numerical tags.

Materialization is a later stage. Its source must independently quantize the exact three selected activation rows under original R0, perform the full-N ordered Q8 restoration, compare all 12288 output bytes to the frozen independent Scorer node, and build raw trace data. Require three distinct input-row hashes and three distinct frozen output-row hashes; these assertions prevent an accidental return to padding-only data.

## Smallest useful execution candidate

Prepare the existing cold LOAD_W, trace-on RUN and same-input trace-off RUN sequence in this new root. Retain legal distinct task/quant/PS epochs and the original retained-W behavior. Trace local row 2 and column 8; all three rows remain numerically checked. This produces one TM4 tile with lanes 0, 1 and 2 active and lane 3 inactive. Expected work is 96 quant groups, 3072 activation elements, 4096 issued/retired tile groups, 3145728 valid integer MACs, and 3072 output F32 words per RUN.

The same 341 sparse 4-KiB physical pages are sufficient. Retain all model original-offset checks, the exact AUX final-page 704-byte prefix and 3392 sentinel bytes, 16 activation pages, 16 out0 pages, all out1 and observed sentinels, and the accepted nine AXI ports/adapters/endpoints. Only the first 12288 activation/output bytes are live; output bytes for the fourth local row and all other mapped neighbors stay sentinel. Reset the entire mapped out0 image between commands, as in the reviewed rows3 source.

Trace-on has 3072 A8 bytes, 192 scale bytes, 1024 group-trace bytes and the 1024-byte report header; trace-off has only the header. Keep the passive observer unchanged and bind its actual generated hierarchy. Its 4096 event count cannot replace the full three-row raw-memory comparison. Record unknown phase intervals without attributing them to a guessed cause.

The fixture materializer, CPU leaf, static build, runtime preparation, snapshot binding, raw audit, cycle ceiling and guards must receive later exact source/identity and execution review. Existing generic adapter delays and first-done debt checks remain mandatory. This successor does not add deliberate terminal hold behavior unless a separate source variant and gate explicitly do so.

## Limits

This case can detect full-row swaps or broadcasts among its three different inputs when all expected outputs are checked. It does not prove arbitrary row independence, a second TM4 tile, a new Encoder producer chain or full-model RTL inference. Existing primitive R0 tiny/subnormal failures and the pending adapter work remain separate. No timing, 150-MHz, 50-ms, implementation or board claim follows from source preparation or future functional acceptance.
