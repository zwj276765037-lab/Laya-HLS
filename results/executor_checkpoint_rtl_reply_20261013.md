# 真实v2检查点交接与捕获导入审核

回复：`executor-checkpoint-rtl-milestone-20261013`  
审核：**R-SM003-EXECUTOR-CHECKPOINT-RTL-20261013**  
范围M003/SM003/E003/R003，沿D-M003-EXECUTOR-CHECKPOINT-HIGH-WATER-01。

**接纳executor_checkpoint_rtl_06为PASS_SCOPED_RTL_CHECKPOINT_HANDOFF，rtl_decode_02为PASS_SCOPED_HOST_REAL_CAPTURE_IMPORT；四项兼容各按原fixture范围接纳。** 未发现本次有限诊断新增功能阻塞。发现汇总漏计两个冻结合同，须补计数更正记录；这不撤销功能证据，也不要求重跑。真实executor导入确认、accepted-request生命周期、完整source保护与生产整链仍未验收，C009保持部分实施。

## 独立证据与计数更正

主控独立核对六项manifest/receipt、原始日志、七段guard/policy、冻结hub/portal/transport/TB/fixture及C++捕获导入。两个交付聚合SHA匹配，聚合绑定的12个manifest/receipt SHA逐项匹配；冻结输入无额外漂移。

**完整口径是183/183 frozen/声明pair，当前174/183 current，612/621递归SHA引用匹配。** 九处live差异逐项匹配两个catalog的最终登记。工程181/172的分母与匹配数各漏2项：generated_source_lease_06有11份files，另有`generated_provenance_channel_contract_20261012.md`及`ordinary_linear_provenance_contract_20261012.md`两组原件/冻结合同；两组均匹配，且原621引用已包含它们。按同口径，登记前应为179/183，原617/621引用不变。请另写补充计数更正并同步当前摘要，不回写已交付聚合、delta或旧attempt。主控更正依据已存`results/executor_checkpoint_rtl_review_20261013/verification.json`。

七段child0/trigger null、起止串行，114条实际policy符合CPU0–3/nice19/idle I/O。RTL8GiB/120s/120s、host24GiB/1800s/120s及MemAvailable门符合。host短run0.198118s无owned-RSS/child-policy观测，保留launcher/wrapper配置限定；-MM只有timeout/RLIMIT_AS，不扩写为观测guard。

_06原始结束时间797850ns和冻结TB的10ns时钟对应79785周期，低于100000帽；marker未打印cycles，记录为推导值，不用于性能结论。工具61.468907s/peak1653460KiB，host build15.499440s/233828KiB。

## 接纳的真实RTL范围

唯一portal把原transport `last_event_seq`直接接到hub，typed/Ref下界来自原数组及历史域，连续前序witness只随真实BEGIN/成功终态END更新，跳号或错误终态使其失效。witness不是新增退休器，也不证明隐藏的CPU/compute任务或未发送预约不存在。单STATE0历史扫描不等于全部13BO物理alias证明。

每个复位分隔诊断的正常前序经同monitor实际112 AW/7168 W/112 B形成七个成功终态和458752B写入，目标旧epoch7与完整source均由正常事件建立。可信坏descriptor_count的event177由transport耗号，hub accepted_events仍18，确证序号不能用事件计数替代。payload为地址pattern，不签encoder/LN数值。

查询在旧第四source窗口最后B及旧END返回未消费时不取得派发权，旧任务继续进展；之后未发布返回完整绑定E_BUFFER。活动目标CLAIM178/epoch8、INVALIDATE179、重复旧键、错base与坏保留位按测试拒绝。query4/handoff4的完整1024B返回逐字匹配独立literal gold（预期seq/handoff固定为4），得到task7/source1/INACTIVE target8/LPV179；source descriptor前88B与v2扩展隔离符合find_exact语义。

真实两个depth2 FIFO执行16/16拍。返回尾2/尾1各持12周期时，两个LPV入口持续valid均不能准入，数据及hub状态稳定；hub整体response保持到第16次实际consumer读取。成功末拍后唯一handoff_pulse切换LPV派发口，原入口继续关闭，后继同transport的CLAIM180/epoch9通过，hub terminal仍7，无新增退休/TaskDone。

snapshot epoch改变、cancel、task跳号、真实monitored_bo_base改变均有复位分隔负例。当前真实base比较直接进入authority准入；稳定成功字节在撤销后不能开放executor入口。五例是一次/真实复位的有限诊断，不是新accepted-request或跨request恢复证明。

## 主机捕获导入与兼容边界

rtl_decode_02冻结的实际捕获与_06原文件SHA一致，现C++ codec完整roundtrip和17个语义拒绝/清输出通过。真实LYRQ/LYMP主机准入后，现helper导入真实返回，退休/claim/lease统计不增加，基线7、LPV179、target历史8成立，下一预约task8/epoch9。该host准入发生在离线捕获导入runtime中，fence受控；未执行后继四窗口，更不能代签生成executor与前序的同硬件runtime。

snapshot_06、guard_09、lease_06、monitor_15使用同一hub SHA，各保留原fixture范围；monitor_15另核最终portal默认禁用兼容。旧F15/F16、source lease及monitor结论不扩大。_01入口错误未启工具，_02重复TB task编译FAIL、_03 PUBLISH flags期待FAIL、_04/_05中间PASS均保留。历史比较为27份files加1份合同，共28对；_05→06的portal、TB、runner措辞和两catalog变更已逐项定位。

## 继续实施的连接要求

按原授权继续executor top及实际准入/导入确认，无新增逐项审批：

1. 真实LYRQ/LYMP准入须先于同request受控前序，并保持同一FullRuntime及所有高水位；16拍实际消费只是必要条件，生产派发还须绑定实际codec完整校验和helper原子导入成功确认。不能把本轮受控consumer的handoff_pulse单独当成生产准入成功。
2. 新accepted-request的phase复位须保留sequence/handoff/producer/program权威下界；cancel/base变化与旧返回不得重开入口。当前复位分隔五例不能代签该路径。
3. 当前portal在`checkpoint_dispatch_held`期间屏蔽`source_query_valid`，而成功交接后该held仍为1；因此默认禁用的lease_06不证明交接后QUANT能取得lease。接Q时须按派发权接通正确query来源及对应valid/ready/granted，核实际合法lease、读债与释放，不只复用默认禁用兼容。
4. 继续真实8/4 action consumer、F10实际24/16 LTC1消费端，接生成LN/monitor/唯一hub、实际END/唯一软件退休及Q/fullA；完整source AR/F9/写入口/13BO和错误恢复义务保留。先满足原合同的受影响有界证据，再按原帽串行生成。

C009部分实施/awaiting_implementation，C008/C010整体待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。原单重工具/资源帽、G余2338.224019s保持，5172s组合不重启；无新增agent/OOC/P&R/上板/预算。主控仅静态/证据核查，未运行编译、仿真或HLS。
