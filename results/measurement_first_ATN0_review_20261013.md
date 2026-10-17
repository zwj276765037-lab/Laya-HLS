# ATN0集中审核与ATN1继续执行

2026-10-13；R-SM005-ATN0-20261013；M004/SM005/E005/R001。回复`measurement-first-ATN0-result-ATN1-plan-20261013`，沿D-M004-ATTENTION-MEASUREMENT-01。主控本轮只读核验；A002继续唯一实现、整合与重工具owner。

**接纳AT020为限定完整head正常数值与计量基线。继续原合同内唯一ATN1：同一行ASUB输入准备与当前EXP重叠。** 工程已自主冻结AT021并报告静态构建启动；本审核不要求等待新审批，也不预签其正确性或收益。阶段范围及资源帽不变。

## 已核事实与计时口径

AT020完整enc0/head0/B1/S128、K128/D64、128query、八个16row tile连续完成。原中间和最终逐位gold、M/A/D实际2129920/2146176/16384、EXP16384、QK products1048576/trees1032192、AV steps1048576及accepted=retired191088、cancelled0均核对。正常PROTOCOL=0仅签此范围。

| 边界（8次命令之和） | 首次done | 实际consume |
| --- | ---: | ---: |
| QK cmd19 | 250888 | 250912 |
| SM cmd20 | 287173 | 287197 |
| AV cmd21 | 66256 | 66280 |

每次首次done至消费3拍，三类各累计24拍；本normal无CE暂停，wall与enabled相同。正常计算到首次done总和604317、全TB1608896、load140288是不同边界，不能互相替代。SM互斥MAX2176+EXP270525+TREE8576+DIV5888+接受/报告8=287173；EXP占SM约94.20%。

四worker各自的input/core/commit/idle之和均为270525；总input147456、core898680、commit17143、idle18821是worker-slot edges。每worker的实际launch/done/commit配平，原1/78/89/97的服务直方图加权和与core-busy一致。input147456=16384×9，支持检查准备阶段与在算EXP的重叠。四worker条件服务下界ceil(898680/4)=224670，当前EXP差45855仅为乐观空隙，不能承诺节省45855，亦不能把多worker等待直接加成延迟。保持原worker分配时才可用max-worker225172作为更紧条件；候选重分配时应重新计量。

ASUB实际16000请求/16000退休为可变lane事务数；固定工作量由原逐lane数值和EXP16384等检查保证。TREE1408/1408、D4096请求/16384返回lane已独立复核。A/TREE/D credit为0只覆盖观察器定义的阻塞资格，不等于全部供数时间为0。

## 身份、失败与工具证据

AT019/AT020各93份冻结源及本项目历史映射源已核；相对原v10仅观察TB/runner变化，DUT未变。35项fixture产品、3个Q/K/V上游plane、5项trace与历史声明一致；AT019 pilot、AT020 pilot/full各47个snapshot文件与实际静态构建副本一致，相关dat/ini亦核。共535个唯一引用SHA/bytes匹配。5段guard起止串行、63条实际policy均符合CPU0–3/nice19/idle I/O；原内存、墙钟、MemAvailable门与120s语义保护保持。

AT020 static/pilot/full分别42.483280/67.855530/499.307597s，full peak1109036KiB，child0/trigger null；这些是工具成本。AT019 pilot的观察断言失败仍为FAIL_OBSERVER_ASSERT，无full，不回写PASS。

文案精确化：AT019→AT020仅TB变化，但修改了新增观察器的整条组合断言——去除固定ASUB/TREE/D请求数假设，改为真实issue/retire配平，并新增计数输出；不宜简写成“只改ASUB比较项”。原数值/gold/覆盖断言保持，实际TREE/D总量已核正确，无需为此重跑ATN0。后续报告准确描述即可，冻结旧收据不改。

## ATN1实现与验收边界

原代码在worker空闲时才发ASUB，并持有当前worker key至EXP结果提交；测量与源码共同支持这一候选。AT021所示一批最多4项同row私有准备值可以在原阶段内继续：4×(32bit值+11bit key)+count/cursor/pending的179bit持久逻辑状态需如实列账，组合选择/仲裁另述。它包含数据寄存器，不能全称为metadata或当成物理FF估计。原32项A队列、RAM/bank容量、M16/A16/D4/EXP4与算子内部流水保持；不增加query上下文或第二批预取队列。

本候选按以下不变量集中验收，不逐项另设审批：

- 当前EXP的x/key/结果归属保持到原单次提交；准备项与当前项独立。若worker映射延后到真正launch，准备项必须保留真实A队列返回的完整key，并仅分配给可接受worker；不得按完成先后重建当前结果身份。row/epoch由原持有上下文保证且换行/换epoch前完整排空。
- 一批准备槽从ASUB真实接受起预留，到真实返回、分发和EXP提交均有唯一归属；pending、未分发值与所有原队列债务共同约束行完成。`exp_written==S`不能掩盖遗留准备项；reset清理与原错误排空/首错rank语义保持。
- 新调度下worker_state的input_wait含义已变。保留ATN0相同外部端点、EXP真实launch/done/commit和互斥SM账，同时显式观察准备pending/ready/分发/排空。不要仅把原worker等待下降称为等量节省；ASUB事务数可因4lane打包而变化，原lane工作量、完整gold和原加减/EXP/除法图必须不变。
- 拟保留前，在同一候选冻结身份上回放原tile16_03的PROTOCOL=1首错、CE/reset、合法重载、chain/ledger。新增全部持久准备字段进入真实状态快照；实际命中新pending在途及ready未分发状态下的CE保持/reset清理，原六类首错和M/A/D/EXP活动覆盖保持。normal head不能代签该回放。

上述是原候选范围的具体核验要求。若目前normal专用runner固定PROTOCOL=0，协议入口需明确绑定候选并真实传PROTOCOL=1，不能仅复制旧PASS或把normal终态改名。按原static→≤120s pilot→有据full顺序与至多两次有据受影响修复额度连续执行；无有效收益或同点无依据停止均可有据收束。

KB1保留；KB2/CT0本轮收束；LQ1仅保留限定周期证据，LQ1R两版no-go保持。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排。无新HLS/OOC/P&R/上板/预算，G2338.224019s仅OOC余额，5172s组合不重启。ATN1完整数值/周期/协议结果仍待交；Attention无AXI master，不签13BO、全模型请求或物理时序，M003/M004未完成。

证据：[主控可复算核验](measurement_first_ATN0_review_20261013/verification.json)、[只读审核程序](measurement_first_ATN0_review_20261013/audit.py)、[ATN0工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md)、[AT020原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/receipt.json)、[原阶段合同](../mission/attention_softmax_measurement_stage_20261013.md)。
