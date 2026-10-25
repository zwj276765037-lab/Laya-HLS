# M007 D33 compiled RTL runner

Owned by A012. Reads production/frozen RTL, original TB and original independent fixtures without copying or rewriting mathematical leaves. Evidence belongs to `project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001`.

Run from the Laya-HLS project root:

```text
python3 project/E002_Laya_HLS/experiment/tools/m007_verilator/run.py prepare ATnnn_name --case add
python3 project/E002_Laya_HLS/experiment/tools/m007_verilator/run.py translate ATnnn_name
python3 project/E002_Laya_HLS/experiment/tools/m007_verilator/run.py build ATnnn_name
python3 project/E002_Laya_HLS/experiment/tools/m007_verilator/run.py rtl ATnnn_name
```

`--case` also accepts `mul`, `div`, `shared4`; parent tests use an explicit JSON `--config`. Each stage holds the single M007 heavy-tool lock through resource guard cleanup. Unknown stages are capped at 120 seconds. Reference/OOC are not implemented. The only tool environment override is the isolated `VERILATOR_ROOT`.

Translation preserves `--timing --assert`; all warnings remain in the raw driver log. Build receipts record the actual compiler flags and completed objects. A build with `--targets ...` validates only those requested compile targets; a null `executable` is not a complete build. Failed translations and interrupted objects do not establish a valid compiled closure.

Parent configs must require nonempty full M007 event comparison and use the original owner-frozen XSim baseline. The raw semantic lines remain in the receipt. A configured `baseline_export` permits mapping only the registered `M007_ACTUAL_PUBLIC_CAPTURE prefix` artifact directory; cycles, checked counts, handshakes and all other fields are compared unchanged. All numerical checkers execute in the original TB.

Original runner bytes used by completed attempts are archived under the E021 run's `runner_versions` with SHA bindings. New attempts also capture `frozen_runner.py`. Actual model/effort remain UNKNOWN unless separately verified. Two-state Verilator cannot replace original XSim four-state/X-propagation or uninitialized-state evidence.
