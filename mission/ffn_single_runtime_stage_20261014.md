# FFN0：正常四行 FFN 同 runtime 与真实末残差

D-M004-FFN-SINGLE-RUNTIME-01；2026-10-14；M004/SM005/E005/R001。依据 [FFR1 审核](../results/measurement_first_FFR1_review_20261014.md)及 [AT049/AT054 接点核查](../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_AT054_FFN_chain_connection_readonly_20261014.md)。A002 唯一实现/工具，A001 集中验收。工程按本合同连续实施、冻结、static、短回归、pilot 和有据成本准入；普通步骤不再请求批准。新结果 NOT_RUN。

## 目标与不变输入

选择测量优先工作线的一个有限连接候选：声明的外部 attention residual → LN_FFN → 唯一 Q → Wi → 真实存储/reader → G → 同一 Q → Down → 双源真实重读/ADD_RESIDUAL → 另一 HIDDEN bank。正常链同一 runtime，仅初始 reset；所有中间结果由真实 DUT 产生，不复制中间存储、不预装 LN/Wi/GATE/A/Down/最终输出，不跳过前缀。

固定 request3/generation1、B1/S128、batch0/row0/rows4，原 canonical model/NumericIdentity 和 AT038/AT050 独立来源。LN 参数及 AT049 的所有 LN/Q/Wi/G/Down gold 保持；最终 ADD_RESIDUAL gold 为 AT050 的 `enc0_enc0_out_rows4.f32.bin`，16384B，SHA `c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a`。skip 为 LN 前 HIDDEN，SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`；Down 检查值 SHA `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0`。后两份文件只用于输入身份或后置比较；Down 不作为本 full 的预装源。

复用 AT049 单套 LN producer/monitor/hub、quant_task/dualA、resident/strict W/KB1 writer，保留 QAR0 的 G 优先选择、不抢占和响应归属；增加 AT054 的一个原生成残差 FADD 叶子及单返回槽/搬运包装。叶子与槽 SHA 分别保持 `d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474`、`5d49ba59917d4bbfa452e55a19e316970486ae63b3f3bc57a155ad69da135c9f`。不复制第二量化器/矩阵引擎，不新增 tensor 缓存、算术候选或通用 owner/READY 表。矩阵原有算术实例与新增残差叶子分别计费；新增控制/数据状态报告实际逻辑位宽，物理资源仍 UNKNOWN。

## 唯一存储与合法映射

保留原五模型 BO 的实际绑定、所有容量及 STATE0=16920576B、STATE1=16919104B。B/S 或四行窗口不能缩小 BO、原 TOKEN batch stride 或逻辑 region。

| 内容 | 物理地址/容量 | 本次连接 |
| --- | --- | --- |
| 外部 skip/HIDDEN bank0 | STATE0 `0x300000000` +0 | LN 和 residual 从同一份只初始化一次的 source_mem 读取 |
| LN NORM | STATE0 +8MiB=`0x300800000` | 原 LN 实写、原 Q 从同一 destination_mem 重读 |
| Down TMP | STATE1 `0x310000000` +8MiB=`0x310800000` | matrix writer 实写，residual 从这些刚写字节读取 |
| 新 HIDDEN bank1 | STATE1 +0=`0x310000000` | residual 实际 AW/W/WSTRB/B 写入 |
| Wi/GATE | 原诊断 DDR `0x100000000` +`0x1000`/`0x20000` | 保持原写、读和保护规则 |

1. AT049 的 `source_mem[0:16383]` 是 **16384 个 32bit word，即64KiB**，不是16384B。原 LN 只消费其中前16384B。增加一个地址/长度/边界检查完整的 AXI512 skip AR/R 响应口，直接读取同一数组；不得复制/再次加载为残差专用源。LN 与 residual 分时，原 source_mem 全程只读，邻接原值/哨兵不变。现有 `shared_read_*` 仍服务 NORM，不能把它冒作 skip。
2. Down 实际 cfg 改为 `bo_base=0x310000000, bo_span=16919104, region_base=0x310800000, region_span=8388608`，原 row/batch stride=4096/4194304 不变。writer 原算地址、BO/region 检查保持。修改真实 AW/W 解码和 B 路由，在同一 STATE1 地址空间保存 TMP written；残差 down AR/R 读取该物理存储并检查每个字节已由 Down 写过。不能保留旧 `ddr[aw_addr-DDR_BASE]` 对新地址索引，也不能 TB 搬运或从 gold 填充 TMP。
3. STATE1 TMP 与新 HIDDEN 共用一个按地址寻址的存储模型；可稀疏分配两个不相交窗口，地址解析必须唯一。每个写口核地址、WSTRB、范围/溢出、实际写集合、重复/越界与响应身份；每个读口核真实地址、返回保持/数量及债务。Down cfg/ledger 所存 binding、writer AW 和残差读 descriptor 必须一致。Wi/G、AUX、W q0/q1/scale、embedding、NORM 均不得被本迁移覆盖。
4. 正常终检保留原393216B诊断DDR扫描；现在仅 Wi83968B+G41984B=125952B 为有效输出，其余267264B保持哨兵/未写，包含原 Down `+0x40000` 的废止位置。另扫描 skip/NORM/TMP/新HIDDEN 各64KiB，共计655360B本地窗口：各前16KiB按来源/独立gold核对，后48KiB核原值/哨兵及未写。skip 整窗不能有写。完整 STATE0/STATE1 未分配区依 BO/region/写集合界限检查，不能称已逐字节扫描全部 BO 或13BO。

## Ref 与任务身份

生产 `check_ref` 只允许 TMP **逻辑 bank0**；它物理映射到 STATE1+8MiB。AT049 Down 实际 `cfg_dst_ref=0x0000000300000001` 为 TMP/bank0/epoch1。AT054 本地 src0 的 TMP/bank1/epoch2 属旧诊断取值；本合同明确允许且要求将残差 src0 校验/fixture 改成实际 TMP/bank0/epoch1，并重验受影响正/负例。不要将逻辑 bank 改成物理 BO 编号。AT054 旧冻结记录保持原范围。

skip 固定 HIDDEN/bank0/epoch1；输出固定 HIDDEN/bank1/epoch2，region0。这是本冷样本显式预约的一张新目的 ticket：入口须证明本 runtime 目的未被占用、未发布、无未退休读写，预约后不得重复领取或覆写，成功后重放同 ticket 被拒绝。此本地一次性新鲜性不代签全局 FullRuntime 分配器或所有 owner 高水位。原 request/session、portal generation、BO generation 和 A/W/Ref epoch 分开保留。

有限适配器在 Down 实际 cfg 与 ledger claim 同一次接受时，保存并校验来自同一命令的完整 NumericIdentity/canonical L13M、Down Context、P/Q/L 与 Ref/窗口关系、GATE source、A/W/PS/目标 Ref、实际 BO binding、K2624/N1024/rows4/row_block0、A/W epoch2 与 weight key4。canonical 来源沿 AT049 的 `ln_query_command` 和已受理后继绑定；strict W 继续独立 Q8S2 方言及其实际 BO/lease，不把两个416B编码互换。只检查四tag或按 task_id 算式推导身份不成立。

ADD_RESIDUAL 生成自己的真实 task Context：task_id 从本有限诊断计划显式分配且晚于已执行 Down（不与旧任务冲突），op0x62/stage2/layer0/batch0/TOKEN/row0/rows4、length1024、bias65535。必须列出原 schema 字段到残差标量端口及416bit局部回显端口的逐字段映射，接受边沿同受控完整记录核对。**416bit局部回显不是416B L13M，也不是完整生产Task包**；不得沿用无类型魔数或把 Down op0x33 Context 直接传成残差 Context。响应必须对应已接受残差任务，稳定至少7拍后实际消费一次。

## DUT 侧退休门控

必须有可综合的有限适配器/互锁，不能只让 TB 等到 Down done 后再发 cfg。resident done 不返回完整 Context/Ref，故以本次真实 Down cfg/claim 保存的完整键和单 outstanding 状态关联其终态，Wi 或旧事务完成不能触发残差。

残差实际 cfg valid 只能在以下事实全部成立后产生一次：匹配 Down 接受；真实完整写覆盖与最后 B 成功；owner 成功退休且目标 READY；矩阵/AXI读写、A/W/PS及返回债务归零；**Down 的 done_valid&&done_ready 已实际消费且status=OK**。七拍 done 保持期间不得启动残差。退休所需事实须来自真实 DUT handshake/ledger/store monitor 或由这些事件维护的有界计数/绑定，不接受 TB 填的 `down_ready=1`、无键空闲位或层次 force 作为功能控制。必要观察端口可以外露，但唯一权威保留在原模块。

Down cfg 受理时建立 TMP 本地保留权，在残差两源真实读债/返回均退休前阻止另一个矩阵 claim 或对 TMP/skip 的覆写；源锁不能因 cfg 被拒或响应仅有效就释放。原外部 skip 冻结只读，新增本地预留与残差 source_locked 分别记录。新 HIDDEN 只有其最后 B成功、全部写覆盖、双源债务和加法返回退休后才能局部发布；响应消费后才能释放适配器命令槽。错误状态不得成功发布，已实际写过的字节不能抹成零副作用。

这些是本有限同runtime链的物理退休/本地预留证明；外部 skip 不是已运行 Attention producer，残差的双源保留不是生产 hub 的完整双 query/grant/lease。不得为本阶段恢复通用生产控制、扩展整个 owner 表或声称普通Q/L已闭合。

## 受影响验证与计量

先做短适配器/映射验证：匹配合法键的唯一触发；Wi/旧完成或错身份不触发；未最后B/未READY/有债/未消费done时残差零AXI；失败done不触发；7拍反压保持；正确TMP bank0/epoch1通过、旧bank1/epoch2拒绝；错BO/错目标或重复ticket拒绝。短单元驱动的退休事件只签适配器逻辑，正常full必须改由真实前段驱动。忙时未接受命令保持稳定、不抢占、不取新预留；显式拒绝一次响应，不能把ready低当作已经拒绝或无限重报。完整上下文错配和局部状态沿原枚举/首错语义；原数值6/协议7/内部8保持。

AT052同SHA52例、AT054未变加法槽/数值错误路径按依赖身份复用；受影响 descriptor/context/地址/互锁测试须新跑，不为未变叶子重复HLS或52例。保留正常所有独立gold、原QAR0竞争/lease/最后B断言，不能为了迁移地址删除实质检查。

full 必须同时取得：LN4096F32和原4AR/256R、4AW/256W/4B；第一次Q4096INT8/128scale；Wi20992F32/671744PS与1312写/重读beat；G10496F32、656写/重读beat和328量化组；Down4096F32/335872PS与256写beat；残差每源256单拍AR/R、4096真实加法/返回消费、256 AW/W/B及最终4096F32。实际burst数与beat分开，不把256beat写成256个burst。每阶段真实接受/首末AR/R/AW/W/B、发布/响应消费、lease和本地锁起止分别打印；最后W→B及7拍响应保持的原策略保持。

新增边界记录 Down cfg/claim/最后B/READY/零债/done首次与实际消费、适配器授权/残差cfg、源保留获得/释放及新HIDDEN发布。记录新全冷TB和正常链区间；用互斥阶段计数核总和，重叠stall另列。沿AT054方法测4096项接受→返回直方图及槽消费，不能预填22拍。旧AT049/AT054周期和墙钟不能相加为新结果，也不据绝对周期差或假定150MHz声称优化/部署性能。

## 运行准备、成本与停止

冻结完整实现/生成叶子、ROM、两种模型身份及实际BO、输入/gold、Tcl/runner/guard和短测闭包；每次spawn前核真实cwd、全部fixture引用/plusargs、7份原LN ROM实际部署及SHA。缺失/错SHA须在spawn前拒绝；保存正例及缺失/损坏反例，不能事后修旧attempt目录。保留原源/generated物身份，路径引起的生成IP文件差异须单列实际新身份和参数比较。

复用并适配AT054真实计数guard：SIM_START只能从编译进入模拟一次，重复SIM_START不能刷新时钟；补一项逻辑时间host反例。模拟中只有实际握手/返回或有因且单调的生成LN迭代退休推进续120s保护；周期心跳、重复计数、状态快照、普通completed文本不续命，倒退/未知事务失败。跨模块/事务计数需累计或显式绑定真实受理，不能更换字符串重置保护。

一个连接候选，最多两轮有明确原因的受影响修正；不加算术备选。每版先static与受影响短回归，再一个≤120s新组合真实前缀pilot。前缀可仅到真实LN源AR/R及有限迭代，但不能用旧墙钟替代；依本次速度/工作量、固定开销、后段未见阶段的保守预算，分别估墙钟/RSS/cycles并在full启动前保存准入决定。无法有据落入3600s/8GiB/40Mcycles即COST_NOT_ADMITTED交付，不能把硬超时当估计、预装中间数据缩工作量或承诺必然跑得完。

**本阶段至多一次冷四行full**；两轮有因修正限full之前的准备/static/短回归/pilot，full语义失败或成本停止即集中交付，不追加第二full。达到修正上界也交付，不能换AT编号继续第三修正。保存每次真实命令、原始日志、Fatal与child/guard分层状态、policy/RSS、冻结diff和成本记录；旧AT047 FAIL、AT048 COST_STOP、AT049/AT054限定PASS不回写。

资源帽不变：A002唯一工具owner，全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；host≤8GiB/120s，static≤24GiB/1800s，RTL≤8GiB/3600s/40Mcycles，pilot/真实语义停滞≤120s。代码仅E002/experiment，证据E005/R001新AT，工程更新模块design/results、三摘要及A002真实状态。无新agent/HLS/OOC/P&R/上板；G2338.224019s只为原OOC余额，5172s组合不重启。

普通Q/L多窗口、多贡献Attention/QKV/旧epoch、生产双源门户、上游Attention/WO、完整28+2层/122矩阵/13BO请求与恢复、联合资源及物理时序继续开放。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup保持停排。本正常四行有限链即使通过，也不关闭M003/M004。
