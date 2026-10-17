# 平台、资源与证据入口

本文件保留预算依据；真实动态状态只维护[阶段表](../stage_results.md)，不要另建进度表。

2026-10-10[一次集中验收](../final_acceptance.md)：新71532身份四请求完整13口CSim、前链helper CSim、六口薄封装HLS和XSim静态展开通过；fe067完整HLS只按原身份通过。真实B1/S128薄封装RTL在1584.281s、18,882,560 clocks时成本停止，raw全量写出、AUX gamma全量读取、STATE0前三块LN输入读取、34/128行算术及STATE1前两块norm写出。原3686.181s及验收期复算的3663.279s/3678.996s均为超3600s墙钟帽的条件外推，不是严格下界。首次done、完整raw/norm数值、owner/spec末态、末端hold及AXI/adapter债务未验；新版71532完整HLS、整网RTL、P&R/上板/50ms均未验。旧run_03测试台缺少部分末态字段断言，工作源码已补齐但尚未XSim重编译或运行，不能扩大旧运行覆盖。

目标器件xcu55c-fsvh2892-2L-e，请求150MHz，50ms为未达用户目标。无板卡/平台证据，P&R/Fmax、上板与50ms均NOT_RUN。新fe067完整HLS已生成当前RTL/IP，未完成物理实现或完整RTL仿真。

历史04934整核HLS为995.08s、owned RSS9.0684GiB、LUT估计1813717（目标器件139%）；有QK/AV E_SHAPE缺陷，只作工具成本依据，不能当作fe067功能/资源。现阶段HLS单次24GiB/3600s；其它工具上限与停止规则见[合同](../../../mission/encoder_decision_validation_workflow.md)。

匹配fe067完整CPU141点/3正常+1故障恢复请求，B2/S128真实13口标准libm CSim47点/9047192 F32/37158 tasks/28+2层按原身份复用；CSim原111.151109s/1738980KiB。全B2 Q8工作量94321509376 MAC及旧调度527.6–586.6G cycles为条件预算，不是当前top latency或硬件性能实测。

当前完整 [HLS](../attempts/full_hls_01)：`v++ 2025.2`，25生产TU，exit0，1193.18s，owned RSS峰值10435308KiB，最低MemAvailable435130124KiB。[顶层报告](../attempts/full_hls_01/work/hls/syn/report/laya_typed_q8_forward_csynth.rpt)中13个m_axi数据口实际都是32-bit，顶层latency未知`?`。LUT1810065/138%、FF466070/17%、DSP456/5%、BRAM18 537/13%、URAM45/4%；HLS估计4.936ns、uncertainty1.80ns，顶层slack -0.07ns，输出Estimated Fmax 202.58MHz。以上仅HLS估算，LUT已超器件总量，不是P&R/Fmax通过。[当前Q8 GS32调度](../attempts/full_hls_01/work/hls/syn/report/p_anonymous_namespace_compute_one_csynth.rpt)仍是179–199 cycles；B2的2947547168组仅该算子需527610943072–586561886432 cycles，远超本阶段40000000-clock帽，完整整网RTL记`NOT_RUN_COST`。

新增[持久CSim](../attempts/persistent_csim_01)使用真实13口、同一个static runtime/BO，B2→gamma故障→两份重基B1顺序exit0；3次正常请求141点、18094384 F32逐字节等于冻结oracle，故障17 tasks、flags9、E_NUMERICAL/LOAD_LN_PARAMS、零logits，AUX整体精确恢复。守护197.22s、峰值1738524KiB。编译后`csim.exe` SHA256 `d50cc94a5b50aed5e261e222e3d4d36af74a2f6195bb87630867d35badb95a1d`为运行后封存；没有事前binary seal，不追溯声称已有。输入与TB的运行前身份见[manifest](../attempts/persistent_csim_01/input_manifest.json)。

新HLS loop调度/端口宽度/缓存与资源估计、连接审计、RTL实际速率/耗时/峰值已在阶段表及机器证据登记。HLS估计、OOC、布局布线、实板结果始终分开。任何超限/数值失败与未覆盖端到端范围保留原样。

真实完整top的B2/S128前链XSim静态展开已通过，[编译guard](../attempts/front_chain_compile_03/guard/guard_result.json)记录931.50s/峰值14588352KiB，二次展开前的DPI库名错误保留在compile_02。首次真正运行的[guard](../attempts/front_chain_run_02/guard/guard_result.json)于235.82s按合同成本停止，172032 clocks、7426个AXI总握手、LN输出0B；相隔93s的总握手样本为3214→6308，约33/s。B2 LN输出1MiB至少需要262144次32-bit写握手；若后续LN写维持本阶段总事务服务速率，条件估计>7800s，超过3600s墙钟帽。此估计不是LN写阶段实测吞吐下界；本次未完成producer→consumer链或独立数值比较，细节及下一步统一见[阶段表](../stage_results.md)。
