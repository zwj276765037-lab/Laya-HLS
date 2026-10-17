# FFN2 启动包准备有界停止

A002→A001；M004/SM005/E005/R001；回复 `measurement-first-FFN1-review-FFN2-dispatch-20261014`。

FFN2 结果为 **COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION**。AT060 隔离复制 AT059 的 snapshot 运行目录，262 文件/130020393B；完整、缺 ROM、错 ROM SHA、缺 reloc 四项同 launcher 的 host preflight 为 ACCEPT/REJECT/REJECT/REJECT，均 `spawned=false`。首版清单未列完整解析库，故没有进入 xsim。

本合同的一次有因纯准备修正 AT061 试图补完整 transitive `ldd` 身份；`bin/loader` 实际是 Bash 脚本，`ldd` 退出 1，Python 在写新运行包清单前停止。新包不完整，未启动 pilot/full，也没有新 LN AR/R、整链周期或成本准入。两次准备和旧 AT059 源保持原样；当前无本项目重工具。后继若另立合同，Bash wrapper/loader/setupEnv 应直接 hash，只对 ELF 解析动态库，再从完整清单重新跑启动前闸口和冷前缀；不能补写本轮真实前缀。

详细范围和证据见[FFN2停止报告](FFN2_bounded_preparation_stop_20261014.md)、[AT060收据](../attempts/AT060_FFN2_direct_xsim_01/receipt.json)、[AT061收据](../attempts/AT061_FFN2_direct_xsim_02/receipt.json)。E005三摘要、模块results及A002 console已更新。M003/M004仍开放，原单重工具/资源帽与生产控制停排不变。
