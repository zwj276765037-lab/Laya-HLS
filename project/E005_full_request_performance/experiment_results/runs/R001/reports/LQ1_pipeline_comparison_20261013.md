# LQ1：16行LN流水候选与LQ0同口径比较

2026-10-13；M004/SM005/E005/R001；A002。LQ0为AT014，唯一LQ1源候选的单LN生成是AT015，真实16行连接仿真是AT016。候选只在最终1024元素归一化循环加`#pragma HLS PIPELINE II=1`，原浮点表达式、归约与检查顺序保持；AT016复用LQ0观察TB、原fixture/gold、AXI响应策略、真实LN store→Q重读及其它连接，仅换受影响的生成LN。AT015为主机g++/HLS类型模型对照及HLS生成PASS，不能写作Vitis `csim_design`已运行。

**AT016有限normal样本PASS；LQ1保留为局部周期候选，时序可实现性未证。** static、rows1 pilot、rows16 full三段原guard均child0、trigger null；full为622.945862s、peak owned RSS 863272KiB，pilot不代签full。16,384 LN F32、16,384 Q INT8、512 FP16 scale对原独立gold通过；source AR16/R1024、destination AW16/W1024/B16与65536B、Q实际重读AR16/R1024、fullA 128次4row/512组、末B、真实completion→END/发布、Q实际响应消费、source lease释放和最终零债务均由原TB检查并通过。三向DDR实传196608B，未因候选缩减。

| 同一冷样本边界，cycles | LQ0 AT014 | LQ1 AT016 | LQ1−LQ0 |
| --- | ---: | ---: | ---: |
| 全TB至最终零债务 | 659334 | 528307 | −131027（−19.8726%） |
| LN生成run start→done，含真实读/算/写 | 649380（4441→653821） | 518354（4441→522795） | −131026（−20.1771%） |
| Q命令接受→真实响应消费 | 3267 | 3266 | −1 |
| fullA acquire→第512组核完 | 512 | 512 | 0 |
| 互斥TB阶段0/1/2/3/4/5 | 25/54/72/655290/3838/55 | 25/54/72/524264/3837/55 | 0/0/0/−131026/−1/0 |

互斥阶段各自严格和为全TB。LN run是生成子图的包围区间，不能拆作纯算术时间；第三TB阶段还含受控完成与END。首次source AR均5035，末R 613468→490631；首次destination AW 45430→37242，末B 653813→522787。completion末拍655387→524361，END消费655441→524415，PUBLISH消费655496→524470，Q接受655498→524472、响应消费658765→527738，fullA末组659278→528251，最终零债务659334→528307。首AW前移8188拍、末B前移131026拍，说明输出随行计算较早出现；不把接口时点差额单独相加为额外收益。source AR valid&&!ready 11→1、destination W 12→3、Q AR 6→5，其余等待见原log；这些条件可重叠，也不是全部内部供数等待。全冷19.87%仅适用本样本和响应profile，不与Down局部周期相加，不外推稳态或完整请求。

AT015 HLS生成的最终循环`VITIS_LOOP_107_7`标为pipelined、目标II1、实际II2，报告类别`Resource Limitation`，循环估计10249→2049 cycles；单top估计BRAM18 29→29、DSP 13→18、FF 19765→19804、LUT 47775→48104、URAM 0。这些是HLS估计，非联合资源/物理映射。调度原日志的`HLS 200-886/887`同时明确指出原F32 `delta = row[i] - m`与`norm = delta * inv`无法在目标周期和II1约束内安排；调度详报中，同一State 3路径为row RAM读1.200ns→F32减30.745ns→F32乘20.420ns→非有限检查0.874ns及控制约0.387ns，合计估计53.626ns。对应生成浮点IP Tcl的sub与mul均配置`CONFIG.c_latency 0`，与两级浮点运算留在组合关键路径的观察一致；这不是已验证的修复方案。目标6.667ns、uncertainty1.800ns，top HLS估计slack由0.00降至**−48.76ns**。报告未给出可唯一指认的存储端口或具体共享算子竞争项，因此保留`Resource Limitation`原标签，不把II2的唯一原因断定为RAM冲突。关键路径是HLS调度估计，未经OOC/P&R核验；不能把528307拍按150MHz换成可部署延迟或声称时序通过。

对照原`layernorm_producer_hls_01`同算术体的调度详报，未显式流水版本的最终`delta`浮点减法和`norm`浮点乘法分别以约3.860ns和4.084ns出现在分开的调度状态；候选把两者放进同一零延迟组合状态。该差异支持下一阶段只检验浮点运算寄存器流水这一有界结构假设，不预签具体pragma、实际II或时序修复成功。

本轮没有证据支持在同一数值、接口与原工具帽内作一处确定有效的时序修复；不扫II参数或启动新OOC/P&R。LQ1周期事实可供下一阶段判断，生产采用前仍须解决时序、继承错误窗口及完整M003/M004义务。LQ0、KB1原限定结果保持；不恢复整体executor/冷INIT/恢复工作。

原始证据：[AT014 full log](../attempts/AT014_LQ0_measurement_02/full_sim.log)、[AT016 full log](../attempts/AT016_LQ1_RTL_01/full_sim.log)、[AT016 receipt](../attempts/AT016_LQ1_RTL_01/receipt.json)、[AT016 manifest](../attempts/AT016_LQ1_RTL_01/input_manifest.json)、[AT015 receipt](../attempts/AT015_LQ1_LN_hls_01/receipt.json)、[AT015 HLS report](../attempts/AT015_LQ1_LN_hls_01/work/reports/hls_compile.rpt)、[循环调度明细](../attempts/AT015_LQ1_LN_hls_01/work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt)、[原算术调度明细](../../../../../E003_production_chain_closure/experiment_results/runs/R003/layernorm_producer_hls_01/work/hls/.autopilot/db/layernorm_row_arithmetic.verbose.sched.rpt)、[调度原警告](../attempts/AT015_LQ1_LN_hls_01/work/hls/.autopilot/db/autopilot.flow.log)、[F32减IP配置](../attempts/AT015_LQ1_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fsub_32ns_32ns_32_1_full_dsp_1_ip.tcl)、[F32乘IP配置](../attempts/AT015_LQ1_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fmul_32ns_32ns_32_1_max_dsp_1_ip.tcl)。
