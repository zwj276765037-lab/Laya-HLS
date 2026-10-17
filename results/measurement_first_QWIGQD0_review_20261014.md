# QWIGQD0正常数值出口限定接纳，先修共享入口仲裁

R-SM005-QWIGQD0-20261014；M004/SM005/E005/R001。回复`measurement-first-QWIGQD0-scoped-result-20261014`；合并LN上游只读答复与主控共享入口静态核查。

**AT034四行顺序normal的真实量化/单套硬件连续链/最终存储检查限定PASS；不签一般共享入口活性或真实生产P/Q身份。主控发现IDLE双valid互相屏蔽ready的静态反例，以及诊断opcode沿用0x60/0x61的语义不符。下一D-M004-SHARED-QUANT-ADMISSION-01先做G优先的有限仲裁修复和schema一致性回放，LN_FFN producer接入随后再选，不恢复通用控制。** 工程按既有授权直接推进，无需新用户批准。

## 本次实际通过范围

声明外部源为原enc0 LN_FFN四行16384B F32，经同一个quant_task实际读取256个512bit R，生成独立gold的4096 INT8、128 FP16 scale及256 half commit，dualA slot0/epoch1实际发布。Wi20992 F32/671744 PS及1312 AW/W/B→真实DDR Wi reader1312R→G10496 F32/656 AW/W/B→同量化器GATE656R/328组、dualA epoch2→同resident Down335872 PS/4096F32/256 AW/W/B全部原gold通过。无链间reset、无预量化A注入，第一轮Q响应先真实消费、第二轮供Down前债务已闭合。

Wi/Down最后B、A/W lease/读债、7拍响应保持与各一次实际消费通过。最终393216B DDR全扫在CHAIN_PASS之前：16384B只读源保持，142336B三段输出逐字节gold及written覆盖，其余234496B哨兵且未写。原外部源等于完整LN_FFN capture前四行；q/scale按正确字节序与原独立二进制一致。

源Q接受23→A实际发布1101为1078cycles；Wi cfg55236→first done102146=46910、→消费102153=46917；Wi完成102154，G接受102158，G后A发布162862。Down cfg189939→first done206125=16186、→消费206132=16193；全TB206133。G接受→最终消费103974与AT032的相同区间一致，但全TB比AT032多819属于外部输入边界变化，不是单核量化延迟或部署收益。

源AR burst数/首末AR/R未打印，不能虚构；source_AR_beats=256为AR所请求的beat总数，实际R也是256。total_quant_groups=328是第二轮值，非两次总和；G_COUNTERS的gate_R=912是TB累计256+656；feeder/dualA per-task计数必须按真实清零语义解释。Down观察A_fill_accept102156为拒绝探针，A实际发布162862和ready观察162874分开；held_B28225跨Wi/Down累计，不当Down独立延迟。

## 失败、冻结与资源核验

AT033 full在162864因TB错误把两任务feeder/dualA计数相加而FAIL；原模块每任务/每fill清零，第二轮应为starts4/input656/half656/scale328/source_R656。AT034只修TB断言/诊断及runner，两版桥DUT和其余102个冻结路径相同，原失败保留。主控再次核实清零源码和完成条件，没有删除原数值/债务自检来获得PASS。

两attempt共443引用/327路径，不可变SHA/bytes零差异；两条旧live TB/runner差异对应已保存修复，不污染冻结证据。AT034为106manifest行、104不同冻结路径；两次共6guard/94policy串行合规，AT034自身3guard/49policy且child0/trigger null。静态82.810202、pilot28.706722、full1778.416778s，峰1510892KiB；准入2683.631229s<3600s。pilot已经实际完成新增源Q和发布，再到Wi W前缀，后续完整数值依据full。主控未运行DUT工具。

## 两个不能由normal PASS覆盖的问题

AT034冻结bridge的ext_quant_ready要求!cfg_valid，cfg_ready又要求!ext_quant_valid。IDLE、ext_quant_active=0、其余端就绪且两个valid同时保持时，两边ready均0，无法发生首次接受。因此正常先Q后G的实测不能签两入口的一般活性。已接受请求的ext_quant_active保持逻辑和正常顺序返回有证据，仍不能消除这个未接受竞争反例。

AT034 TB的source_producer_context opcode=0x60、source_quant_context=0x61；原laya_tasks.h中它们是GEGLU/RELU，而LN_FFN/QUANT为0x12/0x20。现有量化路径把这些Context字段作不透明键保持，没有证明真实producer/操作语义。数值和本地键比较PASS保留，但不能声称这一样本验证了生产LN_FFN来源身份。后续GATE QUANT也应使用0x20；校正诊断调用字段不等于实现完整opcode权限验证。

[QAR0合同](../mission/shared_quant_admission_stage_20261014.md)已决定G入口固定优先、已受理任务不抢占，所有ready/valid/payload路由基于同一选择；有限定向RTL覆盖双valid、活动/响应反压时另一入口等待、原拒绝后释放和唯一响应。可在原四行数值链插入已知零工作拒绝探针，不为每个用例重跑整链。一个包装修复及至多一次有因修正，原工具帽、独立gold和单实例保持；新结果NOT_RUN。

## LN后继事实与边界

工程已只读核到旧capture的LN_FFN之前是enc0 WO加hidden residual；目前没有该LN前输入的冻结二进制，需以后在原request3独立reference的真实residual后新增捕获并验证LN输出等于现有capture，不能反求或用LN_ATTN数据代替。原LQ0 baseline生成核支持LN_FFN/rows1–16，但其外层16行fixture及STATE0 NORM偏移8MiB与AT034地址不同，完整身份、真实写存储/最后B/发布和成本均须新核。LQ1/R不启用，捕获或LN工具本轮不启动。

LN只读消息内完整capture的长SHA有笔误：主控重新读取本项目524288B文件，正确值为`6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`，与已保存AT032/AT034源核对一致。请工程更正派生报告，历史消息/原证据不改，不因文案笔误重跑数值。

完整LN_FFN producer、FFN residual、28+2层/122矩阵、生产13BO/请求/恢复、联合资源/物理时序/上板及M003/M004仍未完成。G2338.224019s仅OOC余额、5172s不重启，无新HLS/OOC/P&R/上板或预算。现工作继续局部算术和真实连接，整体executor/冷INIT/CLOSE-rearm/cleanup停排。

证据：[主控核验](measurement_first_QWIGQD0_review_20261014/verification.json)、[桥差异](measurement_first_QWIGQD0_review_20261014/bridge_diff.txt)、[原工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md)、[AT034收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json)、[AT034日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/raw_full.log)。
