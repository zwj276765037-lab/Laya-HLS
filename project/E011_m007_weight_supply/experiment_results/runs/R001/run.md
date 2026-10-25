# R001 / E011 / SM010 M007-W576-v1

execution_state: completed
verdict: supported for byte packing and local reader/cache functional/service simulation; qualified independent bank/reader capacity complete; full synthesis unestablished

Authority: SM010 D-M007-SM010-WSUPPLY-01. Sole implementation E002/experiment/vivado/module_design/hbm_loader_and_cache/new M007 files and E002/experiment/tools/m007_weight_pack.py. Exact sources, command argv/cwd/host/Python/tool path and start/end/resource records are frozen per AT. Vivado/XSim2025.2, target xcu55c-fsvh2892-2L-e; OOC clock3.333ns. No P&R/board/GPU/install/full gold.

Reproduce from project root (fresh AT identifiers required):

```
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py reference ATnnn_pack
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py build ATnnn_build
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py rtl ATnnn_rtl --fixture project/E011_m007_weight_supply/experiment_results/runs/R001/attempts/AT001_four_superblock_pack/work/fixtures --build <absolute-or-relative-build-AT>
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py ooc ATnnn_ooc
```

AT001 original GGUF window packing/inverse/independent old q0/q1/scale BO checks PASS,596224B. All4 representative streams and original-source expected files are bound in subsequent fixture identities. Complete model/tensor hashes are inherited from manifest; new selected source/output hashes are in layout.json/packing_report.json.

AT002 static PASS; AT003 functional FAIL retained (3bit phase cannot represent8); AT004 counter4bit repair static PASS; AT005 first combinational-buffer RTL PASS. AT006 synchronous payload RAM/read-output and simultaneous lease/read/release protection static PASS; AT007 same RTL functional PASS. AT008 full OOC COST_STOP timeout120.292s, preliminary RAM mapping only, no final synthesis/timing claim. AT009 strengthened TB compile FAIL(extra end); AT010 syntax repair compile PASS; AT011 strengthened TB RTL PASS. DUT remains same as AT006/007; TB now skews eligible latency40+2*(7-ID) cycles and measures280 reordered burst completions/21898 interleaved R beats. Final marker covers1240 public544B responses:1096 unique four-source records+16 error-isolation rereads+128 reset-generation rereads. Every response holds8 windows.1024 windows overlap actual alternate-slot prefetch. Missing last real R leaves port0 debt live and accepted_R287/288 with no LOAD completion until common reset. AR hold,4KiB split and <=16beat assertions remain active.

AT011 complete superblock LOAD→readable: QKV735/1024; Wi s81 735/1024; Down1633/2224; FC2 2456/3328 cycles. Four ports each peak8 real accepted unfinished bursts. Main per-port AR counts18/18/47/72 and R288/288/738/1152 by these cases. Finite-stall K1024 case896/1024cycles. Peer512bit/2cycles/port, deterministic ID round-robin/skew; these are controlled service-model results, not real HBM.

AT012 capacity OOC no_timing_driven/flatten_hierarchy none still COST_STOP120.301s. AT013 independent bank substage completes0blackbox/4URAM+1BRAM18, then reader timing reporting triggers overall COST_STOP120.256s. AT014 only reader/no timing report completes64.910s,0blackbox/311LUT/280FF/7BRAM36+1BRAM18. No cap extension or full/top frequency claim.

AT015 static PASS; AT016 final RTL PASS adds requested8record public rate check: actual accept interval4cycles/response-valid latency1cycle. Total1248 public responses=1096unique+16isolation+128reset+8rate. Main strong-peer service/reorder/missing-R counts remain those of AT011. Final source/input/budget/qualified results are in current_version_evidence.json; completed here means this first supply segment only.
