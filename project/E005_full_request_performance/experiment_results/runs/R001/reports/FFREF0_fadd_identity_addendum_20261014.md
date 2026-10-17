# FFREF0 F32 加法核身份只读补证

2026-10-14；回应 `measurement-first-FFREF0-fadd-identity-query-20261014`；A002。只读比较既有文件和日志；没有启动 IP 生成、HLS 或 RTL。本补证澄清 FFREF0 方案所选的旧 XCI 与 AT049 实际仿真生成物的区别，AT050 原始记录不改。

| 身份 | 本项目绝对路径 | bytes / SHA-256 / 来源 |
| --- | --- | --- |
| FFREF0 方案引用的旧 FADD XCI | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_tm4_generated_rtl_02/work/vivado/tm4_generated.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci` | 26305B / `de95586f7d41fb4832329bf22952bc8321743629543d7b353a2ae05fcc16f92c`；E002 TM4 generated 项目的旧 Vivado work。原冻结 `create_fp_ip.tcl` SHA `fcfc6f83a488ea57ddf3e02d36876074734e296948f4d699edb467ea0ee407e5`。 |
| AT049 同 runtime 实际 FADD XCI | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT049_LNQ2_runtime_01/work_static/vivado/lnq0_chain_tb_v1.srcs/sources_1/ip/tm1tn8_fadd_ip/tm1tn8_fadd_ip.xci` | 26311B / `244d6ab50960499221348b32698d57613d5934b9643188baf4b88e1c93e8f430`；AT049 新 project 的实际 `work_static`。冻结 runner 第40行调用 AT035 `down_frozen/.../tb/create_fp_ip.tcl`，其 SHA 也是 `fcfc6f83a488ea57ddf3e02d36876074734e296948f4d699edb467ea0ee407e5`；AT049 source manifest 第332行记录该脚本。实际 xsim `xvhdl.log` 第15–16行编译本项目 `lnq0_chain_tb_v1.gen/.../tm1tn8_fadd_ip.vhd`，elaborate.log 第236行编译该实体架构。 |

两份 XCI 均为 JSON；逐键比较只发现 `/ip_inst/gen_directory`、`/ip_inst/parameters/runtime_parameters/OUTPUTDIR` 与顶层 `/checksum` 三处差异。`component_parameters` 和 `model_parameters` 全部相等；两份都为 `floating_point:7.1` revision21、Single/Add、32bit（8位指数/24位有效数）、`C_LATENCY=11`、`C_RATE=1`、NonBlocking、`Has_RESULT_TREADY=false`、`Has_ACLKEN=true`、`Has_ARESETn=true`。无任何可见算术/流水参数差异，但 SHA 和文件身份**不相同**。AT049 冻结矩阵 `tm4tn8_fp_restore_v1.sv:109` 的既有 `add_ps` 将 `aclken` 接常量1；它没有验证新残差 add lane 的 CE 冻结或背压保持。

数值规则与已有验证分层：原完整图 `full_reference.py:32–33` 使用 `np.add(..., dtype=np.float32)`，末 FFN 加法是 `add(hidden, down)`，AT050 的四行/完整参考据此生成。生产 `vector_full_compute.cpp:54–67` 对有限输入逐元素调用 `fp_add_bits` 并拒绝非有限输出；定义在本项目 `project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/source/tanh_libm_bits.cpp:45–113`，当前 SHA `c470b4c566ec714388ef84c4b68057c1802be650973b876390dbb6deb066350a`。`add_unpack` 规格化次正规数，`add_jam` 保留右移粘滞位，`add_pack` 用 guard/round/sticky 按 ties-to-even 舍入并可打包次正规结果；零输入分支保留 `-0 + -0 = -0`，非零反号精确抵消显式返回 `+0`。这是 C 实现的规则，不是所选 Xilinx IP 的已测数值证明。

历史 `tanh_libm_round1_01` 曾在精确抵消零符号出错；`round1_02` 冻结修正源码 SHA `0bcf7bf377ca191c4aa4612439e39bae2c03e6eb842acc0dadfe8b9e1ba5aab1` 与当前生产文件整体 SHA 不同，但保留相同的有限数/次正规/零/RNE目标。旧修正的 52 个定向原生 binary32/RNE 样本覆盖四种有符号零、等幅抵消与次正规/正规边界；原 `round1_02/rtl_run/xsim.log:28` 打印同次 HLS `fp_add_bits` 子模块 `RNE_ZERO_DIRECTED_RTL_PASS count=52`，另有 3270 项两 profile 回归。此证据属于**另一 HLS 实现**，不能继承为 Xilinx `tm1tn8_fadd_ip` 的算术或 CE 测试。

XCI 没有显式舍入模式/次正规行为字段；`C_Has_UNDERFLOW=false` 仅是不导出 underflow 状态口，不能证明 FTZ、次正规处理或全 IEEE 语义。下一阶段应使用 AT049 身份或明确重新冻结的同配置核，先对四行4096项真实 RTL 输出逐位比较 AT050 独立 gold，另做 CE/在途/输出保持的定向验证。现阶段对新残差 RTL 数值、一般 IEEE 行为和 CE 保持的结论均为 NOT_RUN。
