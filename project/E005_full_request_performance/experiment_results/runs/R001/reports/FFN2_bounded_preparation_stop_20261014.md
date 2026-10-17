# FFN2 隔离启动包准备有界停止

2026-10-14；D-M004-FFN-DIRECT-XSIM-REPLAY-01；A002；E005/R001。

**COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION。** 没有启动 xsim，没有新的 LN AR/R、FFN 同 runtime 行为或四行 full；旧 AT059 snapshot 和 AT058/059 局部静态/短测证据范围不变。FFN2 一套启动方案及首次 xsim 前的一次有因准备修正已经使用，按合同停止，不以无新 full 为由续开原额度。

AT060 从 AT059 已 elaborated `ffn0_chain_tb_v1_behav` 复制完整运行 cwd 至独立 bundle，没有符号链接；清单记录 262 个文件/130020393B，包含 xsimk、mem、reloc、dbg、xdbg、`xsim.ini` 和七份 LN ROM。来源闭包 AT059 336 引用逐项 SHA/bytes 核查。四个同一 launcher 的 verify-only 例得到：完整包 ACCEPT/exit0；缺 ROM、错 ROM SHA、缺 xsim.reloc 均 REJECT/exit2，`spawned=false`。这些是 host 启动前检查，没有 DUT 动态结果。AT060 清单只列选定 Vivado wrapper/loader/两个 kernel 库，未列 loader 解析出的全部动态库；故它不满足 FFN2 完整运行依赖清单，未发起前缀。

一次有因准备修正另存 AT061，拟将 `xsimk`、Vivado loader 与 unwrapped xsim 的递归 `ldd` 库路径及 bytes/SHA 纳入清单。准备在 `ldd Vivado/bin/loader` 处以退出码 1 停止：该 `loader` 实际是 Bash 脚本，不是 ELF。Python `subprocess.run(..., check=True)` 抛出 `CalledProcessError`；新 `package_manifest.json` 尚未生成。AT061 旧 snapshot 源只读，部分隔离副本和冻结 launcher 保留；无 preflight、`launch_pilot.json`、guard 或 xsim 进程。复现原因是准备脚本把脚本包装器误当作 ELF 去解析，不是 snapshot 或 DUT 数值失败。

后继若另立合同，应只对 ELF（`xsimk`、`bin/unwrapped/lnx64.o/xsim` 及 loader 真正执行的 ELF）做动态库闭包，Bash wrapper/loader/setupEnv 逐文件记录即可；重建运行包后，必须重新执行正负 preflight、在真实隔离 cwd 的启动前核完整清单与实际 plusargs，再取得一条冷 xsim ≤120s 实际 AR/R 前缀。当前未形成新成本速率，full 准入为否；不得相加 AT049/054/057 的旧墙钟或周期。

证据：[AT060 收据](../attempts/AT060_FFN2_direct_xsim_01/receipt.json)、[包清单](../attempts/AT060_FFN2_direct_xsim_01/package_manifest.json)、[四个闸口结果](../attempts/AT060_FFN2_direct_xsim_01/preflight_negatives.json)、[AT061 收据](../attempts/AT061_FFN2_direct_xsim_02/receipt.json)、[准备失败记录](../attempts/AT061_FFN2_direct_xsim_02/prepare_failure.json)、[loader 文件类型](../attempts/AT061_FFN2_direct_xsim_02/loader_file_type.txt)、[ldd 返回码](../attempts/AT061_FFN2_direct_xsim_02/ldd_loader.exit)、[冻结修正版 launcher](../attempts/AT061_FFN2_direct_xsim_02/frozen/run_ffn2_direct_xsim_v1.py)。

外部 attention residual、生产双源授权、普通 Q/L 多窗口、全模型/13BO/恢复、联合资源与物理时序仍未闭合，M003/M004 开放。原单重工具/CPU/内存/墙钟/semantic 帽和整体 executor 停排保持。
