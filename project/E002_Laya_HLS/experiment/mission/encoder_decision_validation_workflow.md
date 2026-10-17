# Encoder→Decision 完整生产连接验证阶段

状态：AUTHORIZED / READY_TO_EXECUTE。2026-10-09，GPT-6 Astra / xhigh 制定；GPT-6 Sol / xhigh 连续执行。

## 授权、入口和范围

用户明确授权：“可以更新结果 按要求继续执行下一阶段的完整 Encoder→Decision 推理、完整模块连接的验证”。本阶段在 `Laya-baseline` 原活动工程继续，独立结果根为 `results/encoder_decision_validation_20261009`；唯一动态结果表为其中 `stage_results.md`，JSON 为其机器投影。此前四项离线阶段已完成，其结果、失败、制品及验收冻结，不复用旧 M002/A002 阶段身份。

本合同一次替代历史 D3 中普通修改逐项“源码审查→编译放行→运行放行”的流程；不替代实质数值、接口、独立参考、覆盖、身份和资源约束。Sol 可连续编译、运行、定位、修复实现/TB/脚本错误及受影响回归，无须逐步签字。Astra 负责架构、接口、数值规则、验收覆盖的实质变更和阶段最终集中验收。总控登记/投影是管理交接，不是工程启动门。

目标是当前真实模型的完整生产图：token embedding/LN → 28 Encoder → final LN/Type → 2 Decision → marker gather/scorer → candidate softmax/stats → ACT → committed result。主整图形状为 B2/S128 和两份独立重基 B1/S128，hidden1024、16 heads×64、Encoder FFN5248/2624、Decision FFN4096、每题16候选和2 ACT。完整层数、K/N、物理 S、任务和独立结果不得缩小后声称完整推理通过。

本阶段分开报告完整软件/CSim、完整 HLS 生成及静态连接、有限真实 RTL 链、完整整网 RTL。任何层级不能替代其他层级。无板卡，P&R/Fmax、平台 shell、XRT link/上板和50 ms不因本阶段成功而通过。C1 或全新的宽总线/算术架构不隐含纳入。

## 固定身份及可复用证据

- 官方包：`build/model-attention-rtl-repair-20261008/manifest.json`，SHA256 `128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa`。
- model=`6eb6ef58bc4f99bd9db40381604108af`，numeric=`aeb13e7937d29fe6a2c68c407249f294`，layout=`f927881686d9d11c91b7f11ac59e2cc7`，build=`fe067c8aa0627ad770096f9721394645`。
- 真实 GGUF 位于 `Workspace/Laya/model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf`，455179648 B，SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。
- 已验完整 CPU：`results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json`，当前身份3正常整图请求/141检查点，另1次故障恢复，四请求持久会话；补充S64/256/512/1024不是完整模型运行。
- 已验真实13口 B2/S128标准libm CSim：`results/attention_rtl_repair_20261008/reviewer_d2_c_full_top_csim_review.json`，47检查点、9047192 F32、37158 tasks、28+2层，111.151109 s/1738980 KiB。当前 Controller、wrapper及模型包与该运行一致，复用，不为新阶段名称重复跑不变B2。
- 前阶段局部RTL仅按 `results/offline_validation_20261009/type_resumption_final_acceptance.md` 的边界复用；外部预置Attention与Scorer输入不构成生产QKV或整图运行。
- 唯一历史完整HLS/RTL属于 `04934c15b3f83e842ec2e92ac2a81bf2`，当前fe067完整RTL尚未生成。旧产物及其已知QK/AV E_SHAPE缺陷不嫁接为当前硬件。C++ synthesis-branch shadow不等于生成RTL。

## 立即执行：当前完整 HLS

直接从已验 `build/full-top-d2-csim-official-20261008/full_top.cfg` 的25生产TU配置建立新 `build/full-top-encoder-decision-20261009/`，显式绑定官方fe067 include/manifest。top固定 `laya_typed_q8_forward`、器件 `xcu55c-fsvh2892-2L-e`、请求150MHz；保留 `syn.compile.pipeline_loops=0`、`syn.array_partition.throughput_driven=off`、`syn.array_partition.complete_threshold=0`、严格浮点flags。使用实际 Vitis2025.2 `v++ --compile --mode hls --config <new cfg> --work_dir <new attempt>`。新目录独立保存日志、配置、输入身份和生成结果；不得覆盖B2 CSim或04934冻结产物。

开始前只做轻量身份/依赖/资源核对，已有CPU/CSim复用与完整预算长报告不再形成额外门。HLS exit0、正式生成报告及RTL/IP齐全仅计 `HLS_GENERATION_PASS`，随后连续审计：

1. 真实13个BO端口及读写方向、实际数据/地址位宽、控制寄存器与顶层调用；512 widening directive不是实际512-bit总线证据。
2. 28 Encoder、2 Decision及scorer/ACT在真实Controller调用图中全部可达；QK/AV合法形状成功路径不被折叠成常量E_SHAPE；生成模块/IR/RTL证据追到真实条件与握手，而非只列模块名。
3. producer→owner publication→consumer的BO、byte offset、shape/stride、layer/epoch/lease一致；重点覆盖双QKV shard、RoPE前后owner、KV/score/probability、两个residual src1、GEGLU/RELU、Type、scorer→ACT及结果commit。
4. 实际persistent metadata初始化/硬件reset语义、payload写路径、缓存绑定、outstanding与首次done前任务/写响应债务要求；不能把冷启动证据改写为暖复位通过。
5. 生成的资源/频率/loop latency与实际工作量。未知top latency保持未知；HLS估计与OOC/P&R/实板分栏。

普通HLS编译/实现错误可修复并重跑受影响项；若改变生产源，记录新的source closure及对既有CPU/CSim复用的影响。改变外显数值/接口/结构目标须先集中修订本合同，不能只沿用fe067标签隐藏实现变化。

## 持续执行的连接验证矩阵

| 项目 | 固定完成要求 | 当前起点 |
| --- | --- | --- |
| 全图CPU | 三个S128正常请求的47×3独立检查点，四请求持久会话含原故障恢复，完整图计数和commit | 同身份已验，复用 |
| 全图13口CSim | 复用原B2；扩展真实顶层harness为两份重基B1与同一static runtime持久会话，执行原已接受故障/恢复序列；各正常请求全部47检查点、独立final18/commit和完整层数；没有桩计算、DUT生成gold或中间值注入 | B2已验；B1/真实顶层持久恢复待执行 |
| 当前完整HLS/静态连接 | 25生产TU整核生成，13口、全图可达性、上述实际所有权/地址/两输入/提交路径核查，已知旧QK/AV缺陷针对性检查 | 首个执行任务 |
| 有限生产RTL子链 | 从实际生成连接和成本选取真实生产调用：前端EMB_TOKEN→LN_EMB；final LN→Type→Decision LN；或Decision输出→gather/scorer/softmax/stats→ACT/result等边界。每条完整运行其声明的范围，至少跨真实producer→publication→consumer，保留生产维度/算术/owner；实际覆盖和独立输入/gold在启动manifest中固定 | 计划；根据新产物选择可合理完成的链，不能只作预算调查 |
| Encoder QKV→RoPE→Attention与完整层 | 必须有真实QKV生产，不以预置QKV代替；完整K/N、head/rows、双shard、RoPE和全部实际选定任务。若只能有限tile或外部边界输入，准确报告局部范围及缺口 | 待当前HLS成本核定；既有预置Attention不能关闭此项 |
| 完整整网RTL | 真实top处理至少一个完整独立B1/S128请求，由原始请求/权重到所有输出及commit；完整28+2层，全部实际端口、owner、AXI/响应债务/哨兵/状态/身份检查通过；要宣称B2覆盖还须完整B2 | NOT_RUN；必须先满足下述有限成本条件 |

后继链的选择由Sol按真实产物/可完成性执行，Astra在同一设计文档集中明确其覆盖边界；这不是普通源码/编译/运行签字门。若必须增加测试入口，可使用同一生产Controller/算子/owner例程的薄封装，不能复制重写算术或替换关键producer。薄封装结果仅属相应子链，不是完整top运行。允许独立参考边界作为子链输入，但必须标明被截断的上游，不能在该链内部预装其应由DUT生产的中间tensor。若现有代码必须实质重构才能暴露连接，则由Astra修订职责/接口规则，独立HLS审计和CSim继续。

持久CSim的固定顺序为同一真实top static runtime/同一组13 BO中的 `B2_S128` request_id1 → `accepted_gamma_failure` id2 → `B1_from_b0_S128` id3 → `B1_from_b1_S128` id4，无中途reset或runtime预置。请求来自 `results/attention_rtl_repair_20261008/d2_cpu_full_official/dut/inputs/`，独立期望来自该正式根下 `oracle/{B2_S128,B1_from_b0_S128,B1_from_b1_S128}`，不能使用dut输出作gold。为形成新真实top持久序列，B2需作为序列首请求执行，这是新增会话覆盖；原B2独立验收仍可复用而无须单独再建一轮。故障仅在内存AUX的真实 `emb_norm_w` 首F32注入+Inf，通过真实top产生E_NUMERICAL/LOAD_LN_PARAMS首因，17任务退休、flags9、zero logits和cleanup；随后整AUX精确恢复，继续两份B1并验证恢复与状态连续性。原模型文件不写。每正常请求47独立检查点，B2为37158 tasks/1924 QUANT tiles/1924 Q8 tiles，每B1为18895 tasks/962 QUANT tiles/962 Q8 tiles；28+2层不可缩减。

CSim独立期望沿用CPU正式门的冻结请求/reference资产和现有严格标准libm数值合同；按名称/shape/长度逐字节检查47检查点与最终结果。实际RTL算术按原R0/有限域及对应算子独立gold规则，不把stdmath CSim通过外推为FP IP等价。遇到已有33/119 FP例外的相关值域必须如实失败/定位，不降低容差、不修改gold、不删assert/跳过失败请求。每个链记录实际reset范围；尚无完整top暖reset通过。

## 一次确定的工具与成本上限

全Laya树同时最多一个重工具；CPU0–3、nice19、idle I/O；owned aggregate RSS每0.2秒采样；`MemAvailable`始终严格大于192GiB；只停止/管理本任务拥有的进程。下列均为单次尝试硬帽，不代表成功或可任意重试。

| 工作 | owned RSS | 墙钟/周期上限 | 依据 |
| --- | --- | --- | --- |
| 轻量身份/材料化/报告分析 | 4GiB | 120s | 分批定向处理，不扫大库/展开整模型日志 |
| 当前完整HLS | 24GiB | 3600s | 历史04934安全配置995.08s、峰值9.0684GiB；不沿用旧900s编译帽 |
| CPU/13口完整CSim编译与多请求运行 | 16GiB | 每进程1800s | 原B2 111.15s/1.66GiB，完整持久多请求留有限余量 |
| RTL静态编译/elaboration | 24GiB | 1800s | 完整top规模未测；超帽保留结果，不自动增加 |
| RTL pilot | 8GiB | 120s | 必须记录功能进度和实际周期，不能只看clock自增 |
| 有限RTL链/有依据的整图运行 | 8GiB | 3600s且40000000 clocks | 需实际pilot支持可在帽内完成，不沿用Type7200s |

RTL首120s可在同一个受控长进程中观察后继续；之后每60s记录阶段/已完成任务或实际AXI/loop进度/RSS，按当前阶段工作量更新成本。连续120s无语义进度则停止保留现场；连续两个间隔至少60s的有效样本显示剩余工作超现有墙钟或周期帽，则按成本停止。纯算术窗口以真实循环/退休进度识别。保护触发后不得仅扩大预算原样重跑，需可检验的新修复或更小且诚实标注的独立覆盖。

现有完整B2工作量为94321509376 Q8 MAC，按旧179–199 cycles/GS32组条件估计527610943072–586561886432 cycles；不是当前新top已测latency。旧Type仿真速率不能当作新top保证。该量级已足以禁止无界整网XSim试跑，不要求先耗时重建整条精确FSM预算。新HLS后用实际关键loop调度与有限真实进度确认；若完整整网明显无法落入帽内，表中标记 `NOT_RUN_COST`，给出完整CSim/完整生成结构/有限真实RTL链的分层结果，以及明确未证明的端到端RTL数值和时序，通知主控。继续可以完成的连接验证，不把成本阻塞伪写成整网PASS。

## 证据、失败保留与终态

每次真实尝试在同一结果根的attempts保存src/input/tool/config完整身份、命令、开始/结束时间、退出码、原始日志、guard/实际进度和制品。可引用已核验不可变manifest；改动内容重新绑定。生成RTL/IP/DAT与实际编译快照/运行入口须可追溯；若新snapshot存在，记录其实际生成后/运行前哈希，未做的binary seal写明缺口，不追溯伪造。严格分开源包tag、源文件closure、HLS产物和XSim编译runtime。

Sol只维护本阶段动态结果、映射与运行事实；Astra维护合同实质设计/最终验收。`source/results.md`仅作预算/证据索引并指向唯一阶段表，不并行维护第二张进度表。总控唯一维护顶层mission/index/注册；本阶段不改顶层记录。阶段集中验收检查身份、参考、全连接/数值/协议证据及实际覆盖，输出PASS/FAIL/NOT_RUN/NOT_RUN_COST或资源中止。完整连接证据部分成立时报告部分结果与具体阻塞，整个离线工程不宣称完成。

## 完整前端生产链薄封装补充（2026-10-09，Astra / xhigh）

完整fe067 HLS及静态展开已完成，完整top的B2前链pilot仍在EMB_TOKEN阶段即按成本停止，LN输出0字节。其总AXI accepted速率含不同通道与阶段，不能把约33 accepted/s直接作为后续LN写吞吐的严格下界；7800s仅是维持该事务速率的条件外推。实际COST_STOP/周期/进度原样保留，不为修正措辞重跑整核。由新HLS compute_one调度证实的整网Q8周期量级与40M周期帽差距仍足以支持整网NOT_RUN_COST。

现已只读核实：`hls/control/full_forward_controller.cpp` 匿名Controller包含真实 `embed_tokens`、`load_gamma`、`norm`、`issue`，但没有可共享的完整frontend helper；`graph` 开头578–594行（抽取前SHA256 `23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`）包含目标连接。为降低无关电路的仿真成本，本补充一次批准下述验证入口和最小等价抽取；不引入宽总线/C1/并行算术或新的存储架构，不形成源码/编译/运行逐步门。

**唯一实现与截断范围。** 将 `graph` 开头从 `embed_tokens(hidden)` 到 `checkpoint("embedding_norm", hidden)` 的原语句、顺序及错误返回原样移入 `Controller::frontend(FullOwnerSpec& hidden)`，末尾返回ok；`graph` 声明hidden后调用同一个frontend，检查返回，然后从原28层Encoder循环继续。不得复制另一套glue、改16-row任务切分、发布/释放位置、输入ref/gamma或算子。新增可综合 `full_execute_frontend(FullRuntime&, FullMemory&, FullOwnerSpec&)` 测试入口位于同一生产TU，使用真实 `full_parse_request` 和同一Controller::frontend；保留真实失败首因/accepted cleanup逻辑，成功返回的是该前段状态，不调用完整 `full_write_result`，不伪造最终candidate/ACT或LYRS整网成功帧。入口签名声明可放独立测试头或现有runtime头；不改原完整核外部ABI。共享helper是完整核实际执行路径，新增入口仅用于验证，不能以测试端手动调用重写出的顺序替代共享helper。

**首个正式输入固定为完整 B1_from_b0_S128。** 原独立请求id3/generation1、全部128个token、hidden1024、8个EMB_TOKEN、1个LOAD_LN_PARAMS、8个LN_EMB，合计17退休，Encoder/Decision完成计数均0。没有S64降级、16行截断或中间tensor预载。输入是原始token/ABI请求和真实Q8 embedding/AUX gamma，STATE0/STATE1以sentinel初始化；所有131072个embedding_raw F32必须由DUT生产，再由真实LN_EMB读取，所有131072个embedding_norm F32由DUT写出。只在embedding_norm owner已发布并旧hidden owner已释放后终止；下游Encoder layer0 QKV、28+2层、scorer/ACT/result明确不在该薄封装范围。第二个B1或B2只能单独报告其实际范围，不能改变首例形状以获取PASS。

**薄封装外部接口。** 新测试top为 `laya_frontend_chain(const uint8_t* embedding, uint8_t* io, const uint8_t* aux, uint8_t* state0, uint8_t* state1, uint32_t* observed)`；分别独立m_axi bundle和AXI-Lite指针/return控制。前5口是现有生产BO子集，沿用full_kernel_wrapper的max_widen_bitwidth=512及单read/write outstanding设置；实际生成位宽仍需记录，不能声称512位。observed是独立诊断输出口，32-bit数据、单write outstanding，不与IO/result共享地址或状态。FullMemory仍为原生产类型，使用原模型常量embedding/AUX容量、IO32768、STATE0=16920576、STATE1=16919104；缺省不用BO为null/0，任何意外访问须由full_span/端点拒绝，不能连假数据应答。保留同一FullRuntime/缓存类型和真实full_cache_gamma；编译器可按可达性删除未使用矩阵/attention存储，不允许把可达producer、loader或owner分支替换为stub。可直接使用25生产TU清单由新top裁剪；不用另造算子实现。

**地址、owner与数值。** 沿用 `full_f32_address` 和 `byte_address`：HIDDEN bank0/1分别STATE0/STATE1 base0，hidden地址为 `4*((batch*1024+row)*1024+col)`，不是把生产batch stride改成S。B1的每块有效范围524288B，完整映射页/邻接尾页/sentinel必须检查，原模型与IO输入不写。冷启动期望三个真实claim（HIDDEN0、LN_GAMMA0、HIDDEN1）；全部8个embedding task完成且coverage完整才publish HIDDEN0，gamma由真实LOAD_LN_PARAMS填1024个F32并publish，norm通过原bind/acquire/read/release读取producer输出，最终HIDDEN1 READY/valid/128行coverage、HIDDEN0 FREE/invalid且payload保留、gamma0 READY/readers0。末态所有readers为0，无未结束FILL/EXCLUSIVE_RW，epochs/spec/identity正确；精确owner_claims/leases在helper CSim与原代码逐项核对后写入固定期望（原流程预计3 claims/16 read leases，若不同须查真实来源，不能迎合RTL改期望）。

独立gold仍为原CPU正式根 `oracle/B1_from_b0_S128/embedding_raw.f32.bin` 和 `embedding_norm.f32.bin`，不得从DUT dump或新CSim捕获生成。raw embedding要求全部位型精确；CPU/标准libm CSim两检查点全部逐位一致。RTL LN沿用已冻结非线性算子误差线 `abs(actual-ref) <= 1e-4 + 1e-4*abs(ref)`，完整131072项逐一有限性/误差比较，并同时报告逐位相同数、max_abs/max_rel/首差；这不放宽mean/variance固定相邻二叉归约、独立F32运算、eps=0x3727c5ac或gamma乘法规则，不允许FMA/重结合/FTZ补偿。若显式基本算术或原精确条件失败，按真实FAIL定位，不能仅凭最终容差遮盖。状态、输入保护、地址与owner永远精确比较。

**冷启动/reset与观察。** 每正式例用新仿真进程，static FullRuntime的实际HLS冷初值及pin-reset语义保持原样，不增加runtime全清零/metadata强制初值/reset pragma或TB层次force。只初始化外部输入/工作区sentinel；不得把hidden、gamma cache、owner/coverage先置READY。生成后记录真正有reset的控制/metadata字段及未覆盖暖reset；此次只验cold。observed在真实前段返回后被动序列化状态/身份、task/op计数、输出ref/spec及3个owner的state/valid/readers/epoch/coverage；字段偏移在TB manifest中一次冻结，错误状态也输出，禁止以期望值覆盖实际字段。该口只读runtime，不参与producer或owner决策。未完成整网时不写LYRS成功帧。

实际RTL验收必须在首次ap_done检查所有5个生产物理口与observed的AR/R、AW/W/B和adapter债务清零，而非等TB额外排空后补称首done通过。监控STATE0真实生产写→LN实际读，输出范围全部写入，DUT状态确认17任务完成；分别完整比较raw、norm和全映射页/输入只读/sentinel。原AXI稳定/last/size/strb/边界断言保持；可按已验证端点方法对STATE0最后一笔LN输入R和STATE1最后输出B施加有限hold，选择器必须来自真实地址/事务身份，并验证实际命中、保持和随后退休。不能凭ap_done或observed单字段宣布PASS。

**新源码与模型包身份。** 抽取前Controller/header及新阶段完整HLS/CSim/XSim所有manifest与runtime冻结。原包build_preimage确实纳入Controller源码哈希，因此生产抽取后不能继续把fe067当新源码完整build身份。Sol在 `build/model-encoder-decision-front-20261009/` 新建匹配当前source_manifest的模型包及新build tag，保留原GGUF/model/numeric/layout不变；使用既有export与strict-current-source包检查。所有权重payload应逐字节等于旧包，AUX仅允许规范build身份头变化；生成头、build_preimage和差异精确绑定。新请求从冻结原请求生成独立identity重绑定副本，只改build身份字段及规范所需校验字段，B/S/token/mask/marker/qtype/request_id/generation均不变；旧输入不写，原F32 gold不变。新薄封装和生产helper均绑定该新包/source closure；原full_hls_01/13口CSim结果继续只代表抽取前fe067，不能写成新helper完整硬件已重生成。

**受影响回归和连续执行。** 完成实现/新包后，运行新helper严格CPU/标准libm CSim的完整B1前链，核两检查点及精确owner/17任务；同时运行原真实13口生产top的四请求持久CSim（新build请求身份，原141个F32独立检查点/18094384值、3正常28+2层+原故障恢复），证明完整graph确实使用同一helper且行为保持。原CPU整图结论保留旧源码身份，不假称新CPU重跑。然后新top HLS→静态审计→真实XSim薄封装，Sol连续修复受影响失败；各尝试自动绑定身份，无需再交逐步审核。无需为了等价抽取立即再综合整个生产top，最终报告其新版完整HLS尚未生成，旧完整HLS与新薄封装不得拼接成同一硬件制品。

沿用阶段单重工具/CPU/RSS/MemAvailable/采样规则。新包导出和strict检查可使用16GiB/1800s帽；helper/完整持久CSim为16GiB/1800s，薄封装HLS24GiB/3600s、elaboration24GiB/1800s、RTL8GiB/3600s且40M clocks、首120s pilot与后续60s语义进度/成本条件均不增加。成本估计按实际EMB完成行/W事务与LN自身调度/实测速率分段，不跨阶段把聚合accepted速率当严格界。若完整B1/S128前链仍超帽，按真实NOT_RUN_COST保留，不自动缩S/rows或扩大帽；继续独立可完成证据，并提交具体阻塞供一次集中结论。
