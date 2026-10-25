# E011 / SM010 first supply segment results

execution_state: completed
verdict: supported for byte packing, local functional/service RTL and independent small-module capacity synthesis
applicability: M007-W576-v1 final RTL closure frozen AT015/AT016; complete SM010/M007 remains open

The pure-byte [AT001 packer](runs/R001/attempts/AT001_four_superblock_pack/work/fixtures/packing_report.json) inverts596224B original source bytes and independently compares old TN8 q0/q1/scale BO addresses. Four complete selected superblocks contain1096 distinct544B records. Complete model/tensor SHA identities are inherited from the frozen manifest; selected source/output windows are newly hashed. This is not the complete120tensor package.

[AT016 final RTL log](runs/R001/attempts/AT016_public_read_rate_rtl/guard/driver.log), [receipt](runs/R001/attempts/AT016_public_read_rate_rtl/receipt.json), [source/fixture/version boundary](runs/R001/current_version_evidence.json):

| Original tensor / superblock | Read bytes | Actual cycles / cap | AR per port | R per port |
|---|---:|---:|---:|---:|
|qkv.0 / s0,K1024|73728|735 /1024|18 each|288 each|
|mlp_wi.0 / s81,K1024|73728|735 /1024|18 each|288 each|
|mlp_wo.0 / s0,K2624|188928|1633 /2224|47 each|738 each|
|head_fc2.0 / s0,K4096|294912|2456 /3328|72 each|1152 each|

All four ports reach8 real accepted unfinished bursts. Peer eligibility40+2*(7−ID) cycles and one512bit beat/2cycles/port;280 out-of-order burst completions and21898 interleaved R beats are observed. Finite-stall K1024 case896/1024cycles. These are LOAD→all cache records readable cycles under the stated peer, not actual HBM throughput.

Public synchronous scans/checks:1248 responses=1096 unique source records+16 error-isolation rereads+128 reset-generation rereads+8 peak-rate rereads. The first1240 responses each hold544B/tag across8windows;1024 windows overlap actual alternate-slot prefetch. Final8 measurements accept one record/4cycles and assert response valid exactly1cycle after acceptance. Response consume creates borrowed data; matching ret retires it; release is independently blocked by pending/held/borrowed/same-cycle read debt. Wrong model/key/generation read, wrong lease/return, target overwrite, descriptor overflow/alignment/span/shape/s bound, padding, nonfinite/finite-negative scale, RRESP/earlyRLAST/unknownRID/mixed error and failure isolation are exercised. Missing last R leaves287/288 returned beats and live debt after1000cycles with no completion; common reset then a new generation rebuilds actual coverage.

Return reservation32768B, conservative total reader/register/assembly/metadata storage37128B<49152B. Real cache payload557056B=2×16×512×272bits. No payload reset loop.

[AT013 bank substage](runs/R001/attempts/AT013_bank_reader_leaf_ooc/laya_m007_w_bank_v1_result.json) completes with0blackboxes,4URAM+1BRAM18 per actual512×272bank. Its overall AT remains COST_STOP because subsequent reader timing report hits120s. [AT014 reader capacity OOC](runs/R001/attempts/AT014_reader_capacity_only_ooc/laya_m007_w_reader_v1_result.json) PASS:0blackboxes,311LUT/280FF/7BRAM36+1BRAM18, actual128×512payload RAM. Leaf counts are not joint/top fit. Full OOC AT008/AT012 each COST_STOP120s; no full synthesis/300MHz/route claim. Timing report generation was removed for capacity-only continuation, not a relaxed timing acceptance.

AT003 counter-width numeric-independent implementation FAIL and AT009 TB syntax FAIL remain charged/preserved. Ordinary repairs retain all independent expectations and coverage. AT005/AT007 older TB results stay bound to their original versions; final stronger source closure is AT015/AT016.

Charged seconds: reference0.263572/600; static35.451427/1800; RTL27.545064/1800; OOC425.758240/600. All failures/timeouts included, no transfer. [Budget ledger](runs/R001/budget_ledger.json).

Open: complete120tensor registration, true HBM/platform CDC/quiesce bridge, parent Check, full matrix/restore/array, route/board/full model. Common reset assumes AXI peer debt resets together;3bit RID alone cannot distinguish a platform-surviving stale response that matches a later ID. No method failure is inferred from OOC cost stops.
