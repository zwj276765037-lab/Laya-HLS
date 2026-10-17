# LQ1同口径收束：有限数值/周期PASS，HLS时序估计违例

M004/SM005/E005/R001；A002。回复`measurement-first-LQ0-review-20261013`，沿D-M004-LNQ-MEASUREMENT-01，无新增批准请求。

AT015真实单LN HLS生成PASS；主机g++/HLS类型模型对照PASS（并非Vitis `csim_design`）。AT016同冻结16行LN→真实store→Q/fullA的static、rows1 pilot、rows16 full均guard child0/trigger null，full622.945862s、peak863272KiB。原独立gold的16384 LN F32、16384 Q INT8、512 FP16 scale、真实store/Q重读、末B、END/发布、source lease、fullA和最终零债务全部PASS。原响应策略与三向196608B传输不变。

全TB零债务659334→528307cycles，减少131027（19.8726%）；生成LN run start4441→done653821/522795，即649380→518354，减少131026（20.1771%）；Q接受→实际消费3267→3266，fullA512→512。互斥TB阶段分别和为659334/528307，主要差额位于包含LN读算写及END的phase3。首AW45430→37242，末B653813→522787；END消费655441→524415，Q消费658765→527738。接口valid&&!ready非互斥，未加总为可消除等待。此为局部16行冷样本、原TB profile周期，非完整S64/生产请求。

HLS最终循环目标II1、实际II2、报告类别`Resource Limitation`；调度警告明确F32减与F32乘不能满足目标周期/II1。同一State3关键路径row读1.200ns→F32减30.745ns→F32乘20.420ns→检查/控制，估计53.626ns；top估计slack0.00→−48.76ns。BRAM18 29→29、DSP13→18、FF19765→19804、LUT47775→48104均是单top HLS估计，物理及联合资源UNKNOWN；不能按150MHz换算部署收益。报告未唯一指明II2的存储端口/共享算子竞争项，本轮不据此盲改算术或扫参数。LQ1保留为局部周期候选，时序与继承错误窗口待后续阶段取舍；未启动OOC/P&R或另一候选。

完整[工程比较报告](LQ1_pipeline_comparison_20261013.md)、[AT015原收据](../attempts/AT015_LQ1_LN_hls_01/receipt.json)、[AT016原收据](../attempts/AT016_LQ1_RTL_01/receipt.json)、[AT016 full原log](../attempts/AT016_LQ1_RTL_01/full_sim.log)和E005三摘要已更新。A002已报告本阶段completed、无重工具在跑。KB1保持；KB2/CT0本轮收束；整体executor/冷INIT/恢复停排，M003/M004未完成。请主控据实测周期与时序风险集中选择下一阶段，普通新工具当前未排队。
