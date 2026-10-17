# QWIGQD0：原LN_FFN浮点输入经同一量化器接入连续链

D-M004-QWIGQD-INTEGRATION-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合及重工具owner，A001集中审核。承接[WIGQD1正常链验收](../results/measurement_first_WIGQD1_review_20261013.md)，在已有用户授权内继续，不新增普通运行审批。

## 目标与明确的外部边界

以AT032已通过的四行连续链为基础，去掉Wi入口的TB预量化A填充。新的外部数据边界是**原enc0 LN_FFN的四行F32输出**：实际AXI读入→原量化器产生q/scale→同一dualA epoch1→Wi→真实DDR/reader→G→同一量化器再次处理GATE→同一dualA epoch2→同一矩阵引擎Down。只有初始reset，整个过程同runtime，原四行工作量/独立gold/响应约束不变。

本阶段不包含LN_FFN producer或FFN末尾residual，不称完整FFN层，也不把LQ0的LN_ATTN换名作为上游。LN_FFN生成核接入留到本次确定输入、量化和复用边界之后。不是缩减完整模型目标；B1/S128、batch0/row0四行仍是有限集成窗口。

主控已核本项目复制树中`compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin`的16384B，SHA256 `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`。它等于`.../t2_widown_av_capture_run_01/work/capture/t2_enc0_ln_ffn_source.f32.bin`的前四行；完整524288B源SHA `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`。

原独立q/scale二进制分别4096B/256B，SHA `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`与`4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`；AT032的wi_a/q.mem按每组32B little-endian、scale.mem按2B解码与它们一致。这些仅作比较，不再驱动Wi A填充；后续Wi/G/Down原gold不重新生成或改写。历史manifest绝对路径映射到本项目并重新冻结，禁止写回旧baseline。

## 唯一量化器与缓存复用

现有`quant_task_to_dual_a_v1`的真实source校验已支持encoder、NORM类2、K1024，G桥当前将其配置固定为GATE/K2624。允许对该**同一实例**增加有界外部QUANT命令/响应与source AXI透传，或等价外提原实例加有限选择器，先接LN_FFN、后接GATE。优先保持量化算术/源reader/dualA内部不变；旧独立桥默认连接行为保留。不实例化第二套量化器、dualA、dualW或resident，也不绕过原完整键、source发布和validate-before-commit。

外部QUANT与G桥内部QUANT二选一，选择从真实命令接受保持到本次响应实际消费、source/量化/存储全部债务归零。非选中入口ready必须隔离，返回和completion只归实际接纳入口；不能以ready或done的OR产生伪接受。原publisher/lease/缓存拥有唯一状态权威，选择器不新增通用owner或软件退休表。

第一轮：K1024/rows4/source NORM类2、A slot0/epoch1，量化4×32=128组、4096 INT8、128 FP16 scale、256个half commit，经原fill/finish实际发布后Wi才acquire。检查产生的q/scale逐项与原独立期望一致；保留原量化数值顺序与错误规则。Wi完成及真实A/W/AXI债务归零后，沿AT032进行G、第二轮K2624量化及A epoch2/Down W epoch2。每任务重新建立的计数按原模块语义取阶段差值，不为计量清DUT状态或回退epoch。

冻结一张P/Q/L Context、全部Ref、slot/epoch、identity及route表。第一轮使用原encoder0 LN_FFN producer语义，QUANT和Wi消费者任务顺序满足原完整键规则；必要诊断任务号变更须一致映射整条链，不弱化校验。真实source数据同源不等于生产控制已实现，有限driver不签13BO请求。

## 真实存储和验证

将这16384B声明外部F32输入初始化在与Wi/GATE/Down输出互不重叠、按512bit对齐的明确只读输入区域。由原source reader实际AR/R送入量化器，预计256个512bit R；AR数按实际4KiB拆分观察，不预签。保持有界非零延迟和真实READY/反压，响应profile在启动前冻结。可以沿用AT032量化读peer的既定规则；不能用TB直接喂量化q/scale替代运算。

存储模型明确区分初始只读输入、由DUT实际写入的三段输出及其余哨兵；输入区不得被writer修改，不能沿用旧“所有非输出都是0xA5”的定义误判新输入区。初始化只读F32是本轮合法外部输入，不预装Wi、GATE、下游A或Down结果。结束后独立全字节检查只读源保持、三段实际输出gold/written覆盖、其余保护字节未改，保留原未写先读、地址/4KiB/WSTRB/唯一覆盖/末B断言。

同时保留AT032全部Wi 20992F32/671744 PS、Wi真实1312R、GATE 10496F32/656 AW-W-B及656R、G后328量化组、Down335872 PS/4096F32/256 AW-W-B，真实末B、lease、局部发布与两次done真实消费、7拍保持、链间无reset。新增共享QUANT入口按真实反压核payload稳定、唯一消费/返回和切换债务；原未改叶子的错误证据按SHA复用，本轮不扩整请求恢复矩阵。

## 计量、成本与停止条件

完整移植AT032真实进度观察，覆盖新增源AR/R、量化提交/发布与两轮复用；状态快照仍不匹配guard正则，不以时间心跳续命。修正派生观察的语义标签：记录Wi前A发布与G后A发布各自真实边沿，初始输入fill、被拒探针、ready-by观察分开。不回写AT032原日志或收据。

本轮新基线独立命名QWIGQD0，记录首个合法源Q接受、实际读入/发布/Wi接受、整链最终消费与全TB，同时保留各段边沿与实际字节。AT032全TB205314只作原范围参考；新增量化、绝对周期门相位和任务调度会改变边界，不宣称新链是同口径优化或相加旧周期预测收益。

一个接入实现，最多两轮有具体原因的受影响修复；同点无新证据重复停止即收束，不扫结构/参数。先static→≤120s真实前缀pilot（优先观察新增量化是否到达，若未到则如实报告）→有成本依据full。完整成本以AT032 full1750.811857s、本轮pilot和新增量化/选择开销保守估计；不能落入原3600s则不启动，交COST_STOP，不减行数/数据/自检或提高帽。共享DUT若变化，明确最小受影响验证范围；未变叶子不重跑全量。

交付实际接点/单实例表、完整manifest、源到原q/scale的独立比对、原全链数值/存储/事务、复用债务/唯一响应、冷周期和新增逻辑状态账。物理资源/时序UNKNOWN；本轮只核现有相关报告身份与同一实例资源归属，不运行新综合来补数，不把模块估计相加成联合通过。

## 不变约束

A002在E002/experiment唯一实现，E005/R001保存新attempt；其他人在工作，保留并适配他人修改，不回滚共享文件，不新增agent。全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static24GiB/1800s、RTL8GiB/3600s/40Mcycles、pilot≤120s、真实语义停滞120s。主控不运行DUT工具。

无新HLS/OOC/P&R/上板或预算；G2338.224019s仅原OOC余额，5172s不重启。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排。完整28+2层/122矩阵、生产请求/13BO/恢复、联合资源/物理时序以及M003/M004最终义务保留。
