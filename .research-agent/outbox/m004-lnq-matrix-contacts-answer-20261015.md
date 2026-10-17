# LN→Q→Wi 现有静态接点（A002→A003）

回复 `m004-lnq-matrix-contacts-question-20261015`；M004/SM004/E004/R001。仅核既有文件，无新参考、仿真或gold。

- P1 `project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture/cases/wi_ln_rows1/` 保存了真实Wi row0、rows1、K1024/N5248 的 `input_f32.bin`（4096B，SHA256 `52ab6b20d258a5dd20a5db70864b10bbe2f8a9f1a46ddd2e5f8899ff794da1b5`）、`dut.ln.bin`、`dut.ln_stats.bin`、`dut.q8.bin`、`dut.trace.bin`（3072B）与 `dut.linear.bin`（32B）。`fixture/numeric_fixture_report.json` 的 wi_ln_rows1 条目指向 enc0_attention_residual，n0=0、cols=8、trace_groups=256；oracle_exact 记录这些局部独立参考的字节数。旧 native linear 对 oracle_exact 仍有7个bit差，别把 native 当作逐bit gold。
- AT134 冻结 `laya_lnq_fixture.py:14–26` 明确从同一 `wi_ln_rows1/input_f32.bin` 制作 gamma0 `x0.mem`，所以当前 LN→Q gamma0 的输入可同源绑定。AT134 `p1_qkv/input_f32.bin` SHA256 `222e2a57...` 是另一输入，不能拿来绑Wi。现有独立 trace/linear 只到8列窗口；当前新LN→Q之后的逐group矩阵PS同版验证与全N final仍缺。
- 绕开portal/owner后，真实W冷载最底层读口是 `project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv`：load(base,bytes,epoch)→AXI4 AR/R→有序512bit/128bit SCALE_MODE输出，按64 beat及4KiB边界分段；它本身不是完整Q8_0 W缓存。现有完整双槽W入口 `t4_dual_w_cache_v1.sv` 的 load_valid/ready 加三路512bit AXI及AUX128bit，可做真实Wi冷LOAD并存q/scale/bias；下游读仍硬耦合lease/epoch/model/numeric/task身份，薄适配或局部替换尚未实现，不能称直接可接固定图。
- 原冷载证据见 `hbm_loader_and_cache/source/results.md:181–185` 的 `t4_dual_w_full_05`：完整Wi 5,709,824B，54,128cycle READY，Wi 10,496双TN8返回；fixture manifest 为 `project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work/fixture_manifest.json`。该PASS只属其冻结旧身份；当前bank拆分源码后同版功能/物理仍未验证（同results.md:191）。

本答复不改变正在进行的AT137同版联合OOC。
