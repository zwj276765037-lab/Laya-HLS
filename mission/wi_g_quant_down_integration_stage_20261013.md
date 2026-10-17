# WIGQD0：单矩阵引擎的Wi→真实存储→G→量化→Down连续链

D-M004-WIGQD-INTEGRATION-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合及重工具owner，A001集中审核。承接WI0/GQD0限定结果，在用户既有连续实现授权内直接推进，不增普通运行审批。

## 唯一目标与来源

本阶段只做一条四distinct行连续链：原LN_FFN预量化A→真实Wi resident→实际AXI写存储→真实Wi AXI reader→G→GATE实际写入/重读→量化→同一dualA→同一resident执行KB1 Down→实际最后B/完成消费。单进程、只有初始reset，链间和复用时均不得复位或用层级赋值清状态。正常链完整输出优先，不添加第二算术优化候选。

Wi计算取AT028冻结resident/严格W/KB1 writer，G及Down取AT025冻结闭包；相同组件按SHA合并为单实例。Wi reader使用本项目E003/R003/wi_axi_reader_03冻结的`laya_wi_axi_reader_v1.sv`，SHA `c09248fc14750a8d9fa23e2e0e2343b9bd1c047b81f44279e470105dd047c1f6`，复用其独立端口/排空证据，但新的同runtime存储交接必须实际运行。现有源与冻结身份不符时显式映射，不默默换成live版本。

WI0的输入A仍是明确的外部预量化LN_FFN四行，完整LN producer暂不包含。W及metadata从原物理加载接口输入；Wi、GATE、G后的q/scale、两段PS和最终Down只能由本次DUT产生。原所有独立gold只供比较，不作中间输入、预装内存、文件回灌或TB算术补值。

## 身份、地址与单实例复用决定

统一采用原四行fixture的batch0、row0=0，S128、四行窗口。本次numeric identity的B字段明确用1，整链同一完整请求/模型身份；原WI0把B字段设2、GQD0还使用batch1/row7只是各自诊断配置，本次重新冻结并验证，不继承旧坐标的接线PASS，也不为保留旧周期继续混用坐标。输入数值与原四行工作量不变，完整B1/S128模型目标没有缩小。

Wi使用op0x32、source NORM类2、dst Wi类6、K1024/N5248、weight key3、模型bias_kind0。Wi writer/reader必须使用同一BO/region和20992B行步长、21495808B批步长；G reader的source ref就是该次Wi实际dst ref，不能只匹配类号。G保持op0x60、量化op0x61，Down op0x33/K2624/N1024/weight key4/bias_kind0；所有stage的完整Context及source/A/W/PS/dst ref逐字段列表并冻结，任务编号按原局部ledger的单调规则安排。

硬件实体限为一套resident TM4/PS/bias/KB1 writer、一套原容量dualW、一套原容量dualA、原G/量化和一个Wi reader。保留原双槽物理容量，但本轮不做重叠调度：Wi用A slot0/epoch1及W slot0/epoch1；真实lease/读债释放后，G量化复用A slot0/epoch2，Down权重LOAD复用W slot0/epoch2。不同dst类别按原ledger独立epoch，PS复用按原高水位递增；不得reset、回退epoch、缩容量或新增第二矩阵引擎/缓存来绕过切换。若原接口存在具体无法表达的字段，交付精确缺口，不自行弱化唯一权威或校验。

当前G桥把dualA封装在quant_task内，允许等价外提该唯一存储的既有端口，或显式透传其原fill/commit/row_done/finish与反馈口。Wi外部A入口与G量化producer通过有限、保持到排空的选择接同一组端口；旧独立wrapper可保留，最终新top不能实例化两份astore。共享存储仍独占状态、epoch、覆盖、发布和lease更新；选择器不另建owner/权限/退休表，不代替原validate-before-commit，不把无效分支ready合并成伪接受。

## 实际执行顺序和存储证据

1. 真实fill/commit/finish建立Wi A，严格加载并校验Wi W，接受Wi命令；全部真实PS和writer输出通过。等实际最后B、局部四行发布、A/W lease/返回债清零及一次Wi done消费后，才允许启动本窗口G读取。原局部发布是有限诊断窗口的依据，不宣称全S128 tensor READY或生产软件退休。
2. Wi的1312个实际AW/W/WSTRB事务修改**唯一按字节寻址的测试存储模型**；R返回只从这份已写存储取数。复用现有真实Wi reader发AR/R并提供完整identity/ref/row/index、row_done和read_debt_zero给G。预期1312个512bit R/20992F32；AR数由实际地址和4KiB拆分测量，不预签。保持reader/bridge原行屏障与背压，不能TB直接喂Wi期望值或强置读债为零。
3. G实际产生10496F32，656 GATE AW/W/B及656拍真实重读，量化328组写入同一dualA的新epoch。A ready由实际fill完成产生。Down W按原严格加载/校验切到新epoch，然后同一resident接受Down，完成335872 PS、4096F32、256 AW/W/B、16384有效/物理字节，实际末B/发布/lease及一次Down done消费。

存储模型按实际AW与W握手配对、仅WSTRB选择的字节更新。Wi/GATE/Down地址区域及区间外保护字节明确、不重叠；初始化保护字节可以由TB提供，中间tensor不得预装。动态检查地址/大小/突发/4KiB/WSTRB/唯一覆盖/未写先读/末B，结束后独立读回全部有效输出与保护字节。Wi读回逐词同时关联实际存储和独立gold；保留完整Wi/Down两段PS、中间G/quant及最终输出gold。该新增内存读回关闭本新样本的对应缺口，不追认AT028从未执行的哨兵测试。

切换前保持真实在途计数与完整payload；AW/W已呈现、未回B、未消费R/标量或未归还lease时不得改路由、key、地址或存储归属。观察/断言新增共享端口和reader的背压保持、每阶段唯一消费以及累积计数的阶段差值，不能为计量清DUT累计状态。原未变叶子的错误测试按身份继承；本轮不扩全面取消/活动reset/恢复、双任务重叠或完整生产13BO。

## 计量、响应与有界执行

保留AT028/AT025同类端口的已冻结W加载供数、AW/W周期门、B延迟及7拍done保持；Wi和Down分别保持一次真实消费。共享矩阵输出端口明确沿用物理beat序号的计数规则，不偷偷按阶段重置以缩短延迟。新增Wi R服务采用预先冻结的有限延迟/保持规则，真实READY背压计入；不使用理想即时直连冒充物理重读。新链是独立基线，旧周期不得相加成新结果，也不根据相位变化宣布优化。

同一冻结闭包static→≤120s真实前缀pilot→有成本依据的完整四行full。AT028 full893.130500s、AT025 full747.161240s只作工具成本参考；组合后不能保证相加以内完成。新pilot须说明实际到达A/W/PS/写出/读回/G/Down哪一阶段，再结合冻结组件成本保守准入；120s只到W前缀可以如实报告，不通过预填中间数据缩短pilot。不能证明完整run在原3600s内可承受时有据COST_STOP，不提高帽或减工作量。

最多一个连接实现及两轮有据受影响修复；同点无新证据重复停止即结束本轮，不改保护策略或用时间心跳作为真实进度。新增接线/存储与观察器错误按已有授权修复，改动共享DUT才做必要受影响回归；未变叶子不重复全量重跑。

至少记录全冷TB、reset释放→最终消费、首个合法输入fill接受→最终消费；两次W LOAD/READY、Wi cfg/首末PS/AW/W/B/发布/done消费、Wi reader首末AR/R与每行done/读债清零、GATE首末AW/W/B、量化首末R/真实A发布、Down cfg/首末PS/AW/W/B/首次done/消费、各lease归零。精确事件在真实边沿捕获，晚观察只能标ready-by；互斥区间与重叠stall分开。工具墙钟不作硬件性能，单次冷样本不作稳态吞吐。

完成时交完整连接/实体/身份表、原始全数值与债务证据、独立存储及保护字节读回、周期/计数和新增逻辑存储账。缺项逐项保留，不能用独立WI0+GQD0 PASS代签本链；本阶段完成也不关闭完整M003/M004。

## 不变边界

唯一实现根E002/experiment，新证据E005/R001；A002单owner，复用原helper、不新增agent、不写旧baseline。原全项目单重工具，CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static24GiB/1800s，RTL8GiB/3600s/40Mcycles，pilot≤120s、真实语义停滞120s不变。主控不运行DUT工具。

无新HLS/OOC/P&R/上板或预算；G2338.224019s仅原OOC余额，5172s不重启；整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup停排。完整28+2层/122矩阵、13BO/请求/恢复/联合资源和物理时序最终义务保留。依据：[WI0集中审核](../results/measurement_first_WI0_review_20261013.md)、[GQD0审核](../results/measurement_first_GQD0_review_20261013.md)、[WI0原报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/WI0_resident_producer_20261013.md)、[原Wi reader收据](../project/E003_production_chain_closure/experiment_results/runs/R003/wi_axi_reader_03/receipt.json)。
