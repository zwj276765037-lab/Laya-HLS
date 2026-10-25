# E007/R001：完整板端 Attention 首段工程协议

权威合同：[SM007](../../../mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md)、[M006 修订5](../../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md) §3、§7、§10。唯一生产写入根为 `project/E002_Laya_HLS/experiment`。FPGA 执行 QKV/RoPE/QK/softmax/AV/WO；不使用 CPU Attention 或测试台保存输出替算。

## 当前平台、输入和首项风险样本

工程 `create_project.tcl` 指定 `xcu55c-fsvh2892-2L-e`；这是项目配置事实，非板卡实测身份。目标单域 300MHz，约束周期 3.333333333ns。使用服务器现有 Vivado/Vitis 2025.2；具体二进制、命令、版本输出和冻结依赖由 AT 收据记录。无 U55C 板卡，平台 P&R 与 board 仍 NOT_RUN。

首项输入为现有 `attention_exp_bits.cpp/.h` 的 glibc 2.39 expf 位算法、现有 `tanh_libm_canonical.sv`、`laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1.v` 及其实际 IP 依赖。冻结源码按逐文件 SHA 记录；原独立 libm 参考保持原样。单 lane HLS/综合只检验严格语义实现的可映射性、实际 II/延迟、资源和 300MHz 风险，不用单 lane 乘8宣称 8-lane fit；旧四路非流水 EXP 也不是新要求的 II=1。

## 实现与验证顺序

1. 冻结现有 IP/参考和模块入口，做有界单 lane strict EXP/TANH、直接 divider 风险样本。检查实际 pipeline II、延迟、LUT/FF/DSP/BRAM 和综合时序。失败、超时、黑盒和内存保护均保留。
2. 在 Attention 模块生产 RTL 下建立一份 256-lane F32 mul/add 与 phase lease/bank 路由，模式覆盖矩阵恢复、RoPE、QK、softmax 和 AV；逐次生产连接，同源 TB 核固定算术顺序、真实读写回执和 reset/隔离。
3. 完整单 head S128/D64 QK→softmax→AV 与 Encoder RoPE，再至 16head；有限停顿与错误优先级按 M006 §10–11。所有新增数值期望由冻结独立参考生成，记录输入/算法/输出 SHA，禁止观察 DUT 输出生成 gold。
4. 同版模块 OOC 报真实资源、300MHz 时序和关键路径；未达到全宽实例与联合资源时仅签局部范围。

原 M004 冻结工作不改、不重跑。新尝试从 AT001 编号，闭包、guard、命令、退出码、原始日志及证据适用范围在 R001 逐次保留。

AT007–014按同协议续跑：共享FP `laya_shared_fp256_v1.sv` 使用原 `tm1tn8_fmul_ip`/`tm1tn8_fadd_ip`，四路和默认256路分别测试；QKV物理bank固定3plane×64×2048，验同步读写与响应阻塞。所有 xsim 日志同时检查 `$fatal`/`Fatal:`，因为此工具可能在Fatal后仍以child0退出，AT007即为保留的反例。单lane strict EXP 原生成F64 add/mul 各保持全部端口单独OOC≤120s；完整leaf仅在合法子模块checkpoint存在时再按主控D-M006-SM007-AT006-01评估。AT010在新顺序到达后中止，原收据计费，不能当成leaf成功。模块OOC结果仅签综合，报告的WNS不代签布局布线300MHz。

## 预算与停止条件

参考/单测累计900s、单次≤120s/RSS≤16GiB；static累计1800s、单次≤600s/RSS≤24GiB；RTL累计3600s、pilot≤120s、完整单次≤1200s/RSS≤8GiB/40Mcycle；模块 OOC累计3600s、RSS≤24GiB。全部仅用CPU0–3、nice19、idle I/O、启动前MemAvailable>192GiB；全项目重工具串行。真实语义停滞120s。单次还不得超过本类剩余额度；运行及失败费用皆入新账。未知长路径先固定≤120s pilot，不动态延帽。完整平台P&R、整模新gold、CPU/GPU整模基准及上板不在本段。
