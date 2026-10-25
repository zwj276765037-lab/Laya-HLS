# M006：CPU–FPGA 协同高性能推理实现

revision: 2 / 2026-10-17
decision: D-M006-RESIDENT-ARCHITECTURE-02
document_state: detailed_plan_ready
review_state: controller_planned_static_reviewed_not_experimentally_validated
execution_state: paused
verdict: unassessed
owner: A001 主控；恢复后复用 A002 工程与 A003 研究角色
implementation_root: project/E002_Laya_HLS/experiment

## 任务与当前授权

**实现完整、数值正确的单 U55C Laya 推理系统，以本地单张 RTX A6000 为主要性能对标。** 交付对象包括生产硬件、兼容 CPU 后端、Host/XRT、完整模型、物理实现与可复现性能证据。延迟与持续吞吐分别验收；只完成局部模块或性能报告不能结束本任务。

本修订响应用户“再次进行架构的完整详细规划写进goal”，详细架构以 [Goal v6](../../goal/goal.md)为准。原[合同修订1](contract_v1_before_a6000_replan_20261017.md)和[用户架构来源](../../design_source/Laya_CPU_FPGA_Codesign_Architecture_20261017.md)保留；其中 CPU 全 LN/residual、90个生产服务段及后期再做驻留的要求已被本修订替代。

**本轮只授权规划和文档同步。工程、GPU/CPU 推理基准、模型执行和 EDA 实验继续暂停。** 用户明确恢复后才启动实施；任务登记、旧额度和内部消息不构成恢复。本次完成静态设计审阅，没有新的功能/物理/性能通过结果，没有唤醒暂停的 A002/A003。

## 1. 生产分工与系统边界

| 路径 | CPU | FPGA | 地位 |
| --- | --- | --- | --- |
| B：驻留主线＋CPU Attention | 输入/Embedding/initial embedding LN、完整 RoPE/Attention、完整 scorer/ACT 尾部 | 权威 hidden/skip、主线 LN、QKV/WO、残差、完整 Encoder/Decision FFN、final LN/type add、紧凑 gather | 首选生产候选 |
| C：驻留主线＋板端 Attention | 输入与尾部同 B | B 的全部主线，加完整 RoPE/QK/mask/softmax/AV | B 的非矩阵成本超过预算时，按完整净收益选择 |
| A：CPU 全 LN/residual 的三服务分工 | 修订1定义 | 修订1定义 | 保留为对照，不是必须先实现的主线 |

B 由一次 BEGIN 和30次粗粒度 Attention 交接推进，CPU不控制 row/group/tile；设备维护权威 hidden。C 复用相同数据边界，在板内完成 Attention。GPU只作比较，不进入单 U55C 生产路径。

主线权重初始化后驻 HBM，FFN宽中间量留板端，热路径激活优先片上。B 有效传输量为60.56640625MiB/请求，C为0.56640625MiB/请求，均包含0.5MiB入口和68KiB紧凑尾部；不含元数据/对齐/初始化，也不是实测加速。只有真实板端 gather 成立，才可使用该尾部账。

完整形状保持 B1/S128、28 Encoder＋2 Decision、全部16 scorer槽、122次Q8矩阵（主线120、CPU尾部2）。Encoder0跳过额外pre-Attention LN；full/sliding、Decision bias/ReLU、Wi上下半配对、scorer两次bias与ACT raw hidden[0]均遵循原图。

## 2. 首批实施的明确数据路径

完整规格、流图和逐项预算见 Goal v6 第4–10节；以下是工程必须落实的边界。

- 基本tile为8×16×32，主候选两个tile按M并联：8192 MAC/cycle、250MHz设计点，300MHz仅候选。两tile纯整数理想下界23.01952ms@250MHz，不能当成系统预测。
- 峰值匹配256 group/cycle：256次I32→F32、512次F32乘和256次F32加；部分和需1024B读和1024B写每拍。256路逻辑银行、同步1R+1W或经证明的等效结构、反馈延迟、tag/credit都要实际实现。
- 循环按Ntile→group→8个M16窗口覆盖S128，W跨全部128行复用。反馈大于8拍则交错独立Ntile并增加工作集；每个输出的group累加顺序保持。
- W按group/Ntile连续重排，当前/下一tile双缓冲；双tile平均W有效流量17GB/s@250MHz是理想需求。通道映射、突发效率、复制和填排必须实测，不能直接借用460GB/s标称值。
- Encoder Wi按前/后2624列配对，G group32完整后量化；至少64KiB配对双缓冲或等效生命周期证明。4条G流水只匹配平均4输出/拍，没有停顿余量；Decision ReLU入口按8输出/拍规划。
- LN/向量接口16–32元素/拍、Q输入16元素/拍均是阶段接口目标，完整多遍LN和group完成率另算。量化用FP32 scale倒数，缓存scale再转F16。
- H0/H1、norm、QKV、context、A0/A1每请求逻辑payload合4.5625MiB；两个上下文9.125MiB。W/PS/G/Attention及物理银行碎片另计，不用容量总和代替端口/布局证明。
- C 的 FP32 Attention 单列资源和周期；复用矩阵恢复单元时，服务时间与矩阵相加。两请求重叠只算持续吞吐收益，不降低所报告的单请求真实延迟。

精确INT8 DSP打包需证明符号与段累加无溢出并验证实际综合映射；不能占满所有DSP后再忽略恢复/非线性。早期联合资源/route检查是数据路径设计的一部分。

## 3. 数值、接口与安全完成

保留group32量化、原舍入、非FMA恢复、每输出group顺序、LN及QK/softmax规定树、AV key顺序与原非线性。独立gold不随DUT修改。不同精度、归约、近似函数或剪枝需要另定数值/质量合同，本轮未采用。

新版本化ABI包含64位request_id、32位generation、model/numeric/layout、方案/层/shape、64位地址/span、mask/position/type/marker和context slot。完成区分QKV_READY、CONTEXT_ACCEPTED、TAIL_READY、ERROR；完整final18还须CPU尾部和同步完成。Check带身份/op/layer及status16/detail32/bad64，错误码/优先级在P0接口中完整冻结。

允许有界未来W预取和独立输出交错，替代旧逐小块排空；首错按原图逻辑顺序提交，不取物理最先返回者。协议缺失与数值错误的适配须显式定义。输出成功位等真实算术返回、R/B及消费者完成；失败真实排债，不force内部状态或强制债零。

验证地址溢出/隔离、4KiB页界、尾拍WSTRB、有限反压、错描述符、错误后恢复、复位及两请求隔离。共同core clock与标准CDC/复位握手明确；隔离周期按新叶子真实最大返回延迟确定，不照抄旧510拍。

## 4. P0–P4实施与阶段验收

全部阶段当前均NOT_RUN。恢复后按依赖并行组织可独立工作；同一实现模块保持单一负责人，重工具按项目限制串行。

| 阶段 | 工程交付 | 阶段出口 |
| --- | --- | --- |
| P0 基线/预算/ABI | 单A6000和兼容CPU完整基线、分项计时、数值差异、版本化接口与权重布局 | 同口径T_GPU与可用矩阵预算；没有板卡的传输项保持UNKNOWN；同时推进可确定的数据路径设计 |
| P1 矩阵与恢复 | 一tile完整服务→两tile；A/W/PS银行、精确打包、预取、恢复、计数器与早期物理 | 完整S128代表QKV/WO/Wi/Down/FC形状，正确性和持续有效吞吐、真实资源/反馈/Fmax |
| P2 驻留主线/FFN | hidden、LN/residual/type add、融合Encoder/Decision FFN、gather | 宽激活不跨Host；全部形状/bias、缓冲生命周期与完整FFN性能 |
| P3 Attention方案 | B兼容CPU桥接；必要时同步推进C完整板端Attention | 同输入/数值对照和系统净收益，确定生产方案；不要求先完整实现已被预算否定的B |
| P4 整模/物理/部署 | 完整图、Host/XRT、联合P&R、重复请求与有界双请求 | final18、可复现工程、联合资源时序、端到端GPU对比；实板结果独立报告 |

P0不是长期可行性研究前置。普通实现/脚本/TB修复在阶段内连续完成，集中审核阶段交付；实质架构/接口/数值/目标变化再修订受影响合同，不增加逐次源码/编译/运行放行。

## 5. 性能口径和转向条件

首要对照为本地**一张**RTX A6000。模型/权重常驻、合理预热、优化后的实际后端；严格数值对照与现有FP16/TF32工程性能参照分开，不能把两张卡或不同精度结果混用，也不能故意采用弱基线。

统一从请求输入就绪至final18可读计时，另列设备执行。冷启动/首请求/热请求、重复数、P50/P95、QPS/排队、CPU核数/并发、平台/频率/功耗状态分别记录。B串行CPU Attention和交接不能从设备时间中消失；实际重叠按关键路径计，不重复相加。

47,143,976,960主线MAC及1,473,249,280组恢复为静态工作量。8192MAC/cycle、250/300MHz、资源余量和流量都属于规划；旧120–220ms及CPU20–80ms不再作为可信预测。没有指定50ms或10倍等硬门槛。

当B非矩阵开销耗尽GPU预算、可验证矩阵下界已过预算、供数/恢复严重失配或联合route无法支持设计点时，必须修改切分/结构并记录差距；不能靠抬高假设利用率或延长仿真帽宣称目标成立。

## 6. 证据、预算与职责

唯一实现根不变：project/E002_Laya_HLS/experiment；不修改原Laya-baseline。复用模块的design/results与三摘要，实际运行登记独立尝试、完整输入/依赖身份、原始日志和guard费用；旧结果只按适用身份引用，不升级为新架构通过。

恢复时为每阶段登记独立CPU/RSS/内存/墙钟预算及成本停止条件，旧M004余额不转。全项目单重工具、CPU0–3、nice19、idle I/O、MemAvailable>192GiB继续有效。长例使用同层次pilot和真实周期计划，超帽记COST_STOP；不得无限延帽或删checker。

A001负责Goal、架构/接口和阶段验收；A002恢复后负责实现、验证及三摘要；A003负责独立方法/来源/瓶颈证据。现有暂停状态不因本次文档完成而改变。

## 7. 完成定义及历史衔接

分别验收functional、physical、latency、throughput、board。完整图数值、同版本联合物理、完整请求性能与复现入口缺一项都不宣称总体完成；未超过A6000的指标明确记为未达竞争目标。当前无U55C板卡，实板项目保留NOT_RUN，不用仿真墙钟或理论峰值替代。

M006不依赖M003/M004/M005全部结束。M004/SM004仍暂停且未完成；AT404待审及AT405–408暂停证据本轮不补签，原FAIL/COST_STOP与费用不改。采用适用资产推进新架构，不先补齐旧串行控制路线。
