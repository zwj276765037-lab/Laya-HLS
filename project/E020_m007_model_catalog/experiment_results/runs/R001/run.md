# E020/R001 MODEL-CATALOG-28 final bounded delivery

Execution state: completed. Verdict: supported for Host catalog/original coefficient preparation and independent public reader only. A001 scope review pending. Desired gpt-6.1-sol/xhigh, actual configuration UNKNOWN; runtime /root/m007_host_tail_engineering, A008.

| Attempt | Phase | Result | Actual child wall s |
|---|---|---|---:|
| AT001_host | reference | FAIL retained:1-based tensor ID and exact type tensor name preparation errors | 1.104193551989738 |
| AT002_host_fix | reference | PASS all8 Host/metadata/coefficient/CLI test groups | 1.321733022981789 |
| AT003_reader_build | static | PASS source census and Vivado2025.2 O3 build | 4.197466782992706 |
| AT004_reader_rtl | RTL | PASS public actual AR/R/fault/drain/reset/two-slot peer | 5.2437239199643955 |

Host scans exact120 original WeightKeys/shapes/bias associations and1-based tensor identities. Exact8192B metadata BO/effective7936B/header256/records7680/tail256 verified, full five original SHA identities and independent CRC64 standard-vector/long-division checks. First/last record invalid structures with refreshed checksums, header/identity/CRC/tail errors and bool/float/nonfinite/negative/overflow/minspan/aperture/catalog/DMA overlap rejection passed. SIM placements only; PLATFORM source/aperture required for actual deployment.

Raw10 original coefficient tensors81088B checked against saved SHA, preserving names/offsets/raw bytes. Products bias73728B/gamma4096B/type12288B;3type rows3072F32 match original embedding_row byte-exact.704chunk stream is setup data; no device commit or runtime gold claim. Whole model payload identity inherited, not rehashed/read in this stage.

Reader SHA3490085a799760fda0cdb3f56dcbff7fe7ed43da947c13fccae8b6bc40eb5810; only2bit state,1sequential block, no payload/address/identity/descriptor FF. Actual req132/AR131/R132/responses129/fault3/drain3/TB-slot commits121 (120scan+1recovery),875cycles. ARheld150 total incl targeted17, Rheld34 in two17-cycle intervals,271actual debt bubble cycles,9reset edges.132checked-consume events; bad RID/RRESP/missing RLAST don't commit; nonlast drains3actualbeats with bubbles until true last. Reset uses common TB peer reset; arbitrary late old RID7 is outside this contract. Caller holds catalog_base/req_word to idle and must block same-edge admission when changing ownership.

Archive audit verified16/16/19/19 exact sources per attempt;14original snapshot files unchanged,4runtime additions recorded.761owned policy samples,0I/O corrections; all cleanup empty and PGIDs absent. No active/queued E020 tool. Reference2.425926574971527/120s, static4.197466782992706/300s, RTL5.2437239199643955/300s; OOC0;60s recovery/archive reserve retained. No E014/E015 balances transferred; unused balances not transferred.

Evidence: independent_delivery_v1.json, production_manifest_v1.json, budget_closure_v1.json, per-attempt receipt/stdout/stderr/sources.tar.gz; Host products/type comparison under AT002 work/host; reader census/build under AT003 work; publicRTL report/input_identity/progress/snapshot inventories under AT004 work. Exact commands/tool/host/start/end/RSS/inputs/configuration are in raw receipts/logs.

Production parent/W mux/transport_idle, device setup/model_committed/actual coefficient commits, device SHA, actual platform DMA, full layers/30-layer, OOC/P&R/physical timing/board remain NOT_RUN. A010 and A007 retain their distinct production ownership.
