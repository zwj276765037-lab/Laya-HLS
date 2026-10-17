# Laya U55C / Typed Decisions Q8_0

用户已明确当前没有板卡，先完成离线验证。按唯一活动入口[mission/task.md](mission/task.md)持续推进仿真、功能修复、同源综合及性能原型表征；平台/Host可先做离线准备，上板、实际频率和端到端性能留待硬件条件具备。当前没有50ms达标或与A6000同口径加速比的证据。

当前离线状态（2026-10-09）：

| 路径 | 已取得的证据 | 下一步 |
| --- | --- | --- |
| 联合 Q8 原型 | v3 局部综合与元数据复位结构通过，继承 v2 严格 CPU/双 CSim；HLS 估计仍 21.308 ns | 固定数组 AXI 环境验证后，执行真实 ACT 数值、负例恢复与暖复位 |
| 外部预置 Attention | v4 CPU/CSim 通过；综合进入报告函数的两项指针检查错误，未生成 RTL | v5 仅改报告存在标记与固定存储读取；AXI 环境优先 |
| AXI 诊断 | v5 原失败保留；共享固定数组通道设计与有界条件执行已放行 | 32/512 位独立协议刺激、读回、排空及同快照内存观察 |
| D2-I Linear/Vector | CPU/CSim、局部综合及真实数值路径结构通过 | 有限窗口数值 RTL，尚未运行 |
| Host / 完整新核 | portable Host 核心准备已授权；新完整核 CPU/B2 CSim 通过 | 离线协议验证；完整数值 RTL、同源资源、平台和板测仍待完成 |

当前按[Attention v5 条件合同](results/attention_rtl_repair_20261008/reviewer_attention_v5_report_presence_conditional_release.json)和[固定数组 AXI 条件合同](results/attention_rtl_repair_20261008/reviewer_axi_bounded_static_v1_conditional_release.json)串行推进。后者先验证独立端口，再准备真实 Q8 绑定；新环境尚无运行结论。

Attention v4 的[完整独立审核](results/attention_rtl_repair_20261008/reviewer_attention_v4_cpu_csim_synthesis_failure_review.json)接受精确源改动与 3 合法/17 负例软件结果；单次综合 230.266 s、峰 2819952 KiB，失败在 report 的未知大小 pair 数组及可空指针 select。v5 保留可见性与清理顺序，只用 bool 标记读取固定 pending.pair；尚无 v5 运行结论。

详细证据与各次失败的范围如下。

截至2026-10-09，**旧04934制品的完整CPU与标准libm CSim已通过，但生成RTL的完整成功路径存在确定缺陷。D1局部RTL修复通过后，P1/P2/P3已同步正式源码；新官方fe067制品的完整CPU门禁与真实13口B2标准libm CSim已执行通过；Attention切片三次RTL尝试均因仿真进程内存上限停止，尚无数值RTL结论。功能与性能均未达到最终验收要求。** 旧04934已生成HLS RTL/IP并完成Vivado OOC综合（exit0、blackboxes0），这些结果只证明该旧缺陷制品能被综合。新fe067的完整生成RTL、28层Encoder/2层Decision/Scorer/ACT请求数值与同源资源仍未验收。

旧04934缺陷制品的Vivado映射占用 **345,505 CLB LUT（26.50%）、287,466 FF（11.03%）、437 DSP（4.84%）、690 BRAM tiles（34.23%）及 179 URAM（18.65%）**，所列主要资源未超裸器件总量。6.667 ns 时钟请求下综合 WNS +0.894 ns/TNS 0；该报告缺少平台外部 I/O delay 和实际时钟网络，**完整 RTL 联合仿真、布局布线、平台链接及 U55C 上板仍未执行**。HLS 的 LUT 139.1% 保留为先前估算，不代表当前映射占用。最新依据为[完整 OOC 综合结果](vivado/project/source/results.md)与[独立综合审核](vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)。

## 当前接口、算力与性能核查

[集中报告](vivado/project/source/performance_and_interfaces.md)列出13个实际32-bit AXI端口、15模块输入/输出与算量、任务依赖和可复算预算。若完整执行C++成功图并保留当前Q8 leaf调度，仅Q8组体约需B1/S128 **29.31–32.59分钟**、B2/S128 **58.62–65.17分钟**（150MHz假设，其他成本另加），并非上板时延。

**功能根因已追到上游控制表示：QKV Linear的合法pair指针在reflow/LTO后被当成不存在，固定E_INTERNAL；Residual/Type向量操作的第二来源也丢失，随后QK/AV路径被裁剪并固定报错。** 显式presence与reference的隔离小top等价修复已通过D1，生产补丁已获独立审核并应用；新完整生成RTL的真实数值链尚未验收，见[新修复合同](results/attention_rtl_repair_20261008/repair_contract.md)和[独立D0证据](results/attention_rtl_repair_20261008/reviewer_root_cause_d0.json)。上述分钟数是完整成功源码图的条件外推，不是当前提前报错RTL的请求时延下界；已有OOC报告也不证明完整功能或修复后资源。

**D1局部结果已复现并修正控制语义错误：** 同输入下，原nullable写法的CPU/CSim通过120项检查，但生成RTL的15条事务中6条错误；显式presence写法的真实Verilog/XSim通过全部120项检查，15条输出逐字匹配独立期望。[D1独立审核](results/attention_rtl_repair_20261008/reviewer_d1_review.json)已放行生产补丁。此处使用明确标注的控制probe，真实数值/owner链、完整top RTL和性能仍未验收，不能把局部通过扩大为整网修复完成。

[已有A6000测量](../../results/laya_gpu_inference_benchmark_20261005.md)的常驻SDK调用P50约24–25ms（B2/S94两题为25.047ms），但其英文模型、BF16 autocast、动态S和候选数与本工程冻结Q8/F32 R0、S128/16候选不同。50ms保留为用户对照目标；公平速度比较须统一模型、请求、B/S/精度及计时边界，不能将不同场景直接称为加速比。[联合Q8原型规格§4.4–4.7/7.15](results/attention_rtl_repair_20261008/repair_contract.md)已映射至既有模块design/results，并通过[隔离实现与首批CPU准备门](results/attention_rtl_repair_20261008/reviewer_joint_q8_tm4tn8_implementation_cpu_release.json)。首版TM4/TN8、512bit读/32bit写的真实ACT K256/N2/rows1已通过[冻结源码与严格CPU独立验收](results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_source_cpu_csim_release.json)：完整输出/A8、两次选中列组trace、同W复用、首错与恢复均在该范围内通过；跨列块错误屏蔽缺陷已修正。两种实际[标准libm CSim已独立接受](results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_csim_pair_review.json)：legal/fault_load均完整通过，分别15.184/15.097s、采样树峰1308292/1302144KiB；124个唯一文件与真实编译依赖闭合。随后一次局部综合已获[失败事实审核](results/attention_rtl_repair_20261008/reviewer_q8_joint_first_local_csynth_failure_review.json)：35.096s、峰1696392KiB、exit1无保护触发，两处局部标签指针表触发HLS214-134，没有调度/资源/RTL。隔离tag_direct_v2只把两处标签指针表改为四组常量直接访问，其[严格CPU已独立接受](results/attention_rtl_repair_20261008/reviewer_q8_tag_direct_v2_cpu_csim_release.json)；随后[两种实际标准libm CSim及精确综合配置已通过审核](results/attention_rtl_repair_20261008/reviewer_q8_tag_direct_v2_csim_csynth_release.json)，372绑定及每mode实际30项非系统依赖闭合，legal/fault_load分别15.168/15.110s、峰1306656/1306888KiB。其[实际综合生成与结构审核](results/attention_rtl_repair_20261008/reviewer_q8_tag_direct_v2_synthesis_structure_review.json)核3959绑定/3577work，生成345 Verilog/236 VHDL，HLS估计341 BRAM18、40 DSP、117593 FF、156171 LUT、256 URAM；21.308ns超过6.67ns目标，顶层latency未知。v2的st_bound等元数据仅上电初值、普通复位不清零。隔离metadata_reset_v3只增加synthesis-only State reset指令，继承相同软件证据；其[实际综合与复位结构已独立通过](results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)：3893绑定、3581work/241真实依赖闭合，277.474s/峰3995644KiB，21项持久标量具同步复位、64标签通过清零written标记恢复默认值，写而不读的dst_epoch被优化移除，50个payload RAM实例无清零。新HLS估计FF117625/LUT156176，其他资源及21.308ns不变；尚无暖复位/数值RTL验收。32个dot归约模块保留stride循环，amax/量化循环实际II分别4/7而非请求1；1024逻辑MAC/group不是实际每拍吞吐。FP次正规/FTZ、其他矩阵、RTL功能/OOC与性能仍未验收；不要求先跑完旧F0漫长完整RTL，最终加速核完整请求RTL仍必须验收。

新官方源码的[完整CPU、综合存储宏路径、真实13口top CSim及首个Attention切片CSim](results/attention_rtl_repair_20261008/d2_attention_slice/source/results.md)已取得软件通过记录。新top CSim覆盖B2/S128的47检查点、9047192个F32、37158任务，已获[独立运行审核接受](results/attention_rtl_repair_20261008/reviewer_d2_c_full_top_csim_review.json)，仅覆盖本次B2/S128软件路径。

**七口VIP仍有idle内存增长；v3已实测wait在谓词为假时返回，traffic尚无有效对照。** v2 idle100000时钟零交易/零队列、构造28和全内存检查通过，10k→100k增长16.1876KiB/clock；v2首B失败未见采样标记，不能据此认定物理响应为X。[queue_exists_v1独立idle审核](results/attention_rtl_repair_20261008/reviewer_d2_axi_queue_exists_v1_idle_review.json)接受全部检查，但相同区间增长16.6251KiB/clock，四处exists不足以去除增长。其2292ms窗口约39267cycle/s、v2的2362ms窗口约38103cycle/s只代表各自诊断环境推进率；v2含启动总平均约7995cycle/s与理论1Mcycle/s均不能替代该实测或预测DUT吞吐。

独立[wait_trace_v3失败审核](results/attention_rtl_repair_20261008/reviewer_d2_axi_wait_trace_v3_failure_review.json)确认首个W wait前后同为66719880ps、count0、predicate0，随后DIAG_WAIT_FALSE停止；没有实际首B/R或读回完成。sampled_wait_v4仅把五个计数等待改为posedge+1ps轮询，保留1024真实事务、断言、延迟与完整内存检查；[源码及静态快照已独立接受](results/attention_rtl_repair_20261008/reviewer_d2_axi_sampled_wait_v4_snapshot_runtime_release.json)，35个SV与20个快照文件绑定闭合，构建81.63s、峰847544KiB。两次运行已获[独立终态审核](results/attention_rtl_repair_20261008/reviewer_d2_axi_sampled_wait_v4_runtime_review.json)：idle100000时钟与全内存检查通过，10k→100k自身RSS仍增长16.1876KiB/clock；traffic在首W的while前后同刻保持count0/predicate0并触发断言，仍无有效流量对照。仅改wait语法不足以解决该上下文异常，不重跑或自动加预算。queue_exists与wait修正不叠加，未修改生产VIP。[guard_trace_v5实际静态及一次traffic已独立审核](results/attention_rtl_repair_20261008/reviewer_d2_axi_guard_trace_v5_runtime_failure_review.json)：新增完整条件为fullguard1/relation0/count0/threshold1，却无首次body-entry记录；同66719880ps退出并触发原Fatal。138绑定/20原snapshot+4运行文件闭合，guard无触发且exit0不覆盖失败。该观察聚焦原automatic/nestedfork的控制继续路径，尚未证明根因，不再改写wait或原样重跑；无新idle/RSS配对。最小32-worker四模式各20000周期的[RSS平坦观测](results/attention_rtl_repair_20261008/reviewer_d2_clock_wait_v2_four_mode_review.json)仍只适用无UVM/无traffic环境，不能给完整DUT内存上界。

外部预置QKV的v2直接cleanup已通过[严格CPU/标准libm CSim审核](results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_v2_csim_synthesis_release.json)，3合法17负例、85输入与26实际编译规则闭合；其后[真实综合仍失败](results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_v2_synthesis_failure_review.json)：173.81s、峰2638804KiB、50项pointer-to-pointer源码错误，无调度/RTL。移除fail边界不足以解决问题，四个run_task实际已内联。[后期IR对照](results/attention_rtl_repair_20261008/reviewer_attention_v2_ir_comparison_advice.json)支持隔离测试FullMemory构造的早期拆分差异；[v3源码门](results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_v3_aggregate_init_source_release.json)只允许26字段完整聚合初始化，保持Controller位置和全部流程。v3源码与严格CPU已[独立接受](results/attention_rtl_repair_20261008/reviewer_attention_v3_cpu_frontend_env_retry_release.json)，26字段值/顺序等价，85输入及3合法17负例保持。前端首启动态库失败被保留；局部环境修正后的[实际IR已接受](results/attention_rtl_repair_20261008/reviewer_attention_v3_frontend_csim_release.json)，171依赖闭合、26字段写入保留且top局部构造调用消失。其[实际标准libm CSim已接受](results/attention_rtl_repair_20261008/reviewer_attention_v3_csim_synthesis_release.json)：3合法17负例、26编译规则/42非系统依赖，30.446s、峰1285492KiB；随后[单次局部综合再次失败](results/attention_rtl_repair_20261008/reviewer_attention_v3_local_csynth_failure_review.json)，172.832s、峰2849184KiB、无guard，38项214-134，只有partial design-size/无调度RTL。聚合初始化因子不足，4run_task仍已实际内联；下一步须比较剩余控制/FullMemory逃逸边界，不原样重跑或等价语法猜测。生产fe067不变，数值RTL未放行。完整记录见[模块结果](results/attention_rtl_repair_20261008/d2_attention_preloaded/source/results.md)。

**Attention切片尚无RTL数值结果；唯一§7.9诊断窗口已结束并接受其观测事实。** 七口完整TV初始化在sim time 0完成，真实kernel已启动并至少执行220000个reset后时钟；own RSS由589772增至4372956KiB，实际AXI传输持续完成，采样队列长度均≤1。运行因180s时限停止，末次队列批次部分缺行，五份输出TV均为空；这定位了内存增长阶段，尚未证明具体分配/对象或事件保留根因。见[独立诊断审核](results/attention_rtl_repair_20261008/reviewer_d2_phase_probe_v5_observation_review.json)及[最终制品绑定补充](results/attention_rtl_repair_20261008/reviewer_d2_phase_probe_v5_observation_addendum.json)。此前v2两次8/16GiB、v3一次16GiB运行均无数值RTL结果；[三次原运行终态](results/attention_rtl_repair_20261008/reviewer_d2_r_depth_v3_final_review.json)、[小模型12项内存诊断](results/attention_rtl_repair_20261008/reviewer_d2_xsim_small_memory_review.json)及[稀疏进度打印修正](results/attention_rtl_repair_20261008/reviewer_d2_r_progress_phase_correction.json)保留各自边界。完整top HLS仍未放行。

D2-I v2向量CPU末例因测试台误读ACT_LOGITS地址失败；v3仅改为权威CAND_MASKED地址，生产/gold/断言未改。[独立CPU审核](results/attention_rtl_repair_20261008/reviewer_d2_i_v3_cpu_review.json)接受I-L 589824个F32与I-V 196624个F32比较；两路[standard-libm CSim](results/attention_rtl_repair_20261008/reviewer_d2_i_v3_csim_review.json)及[局部综合/生产IR与RTL可达路径](results/attention_rtl_repair_20261008/reviewer_d2_i_v3_synthesis_ir_review.json)也已独立接受，确认pair与src1的真实数值/owner路径保留。两路尚无数值RTL执行，HLS均报告−0.31ns估算slack，不能称150MHz时序闭合。

## CPU、FPGA 和 HBM 的分工

部署结构是外部服务器 CPU 通过 PCIe 驱动 U55C。U55C 是 FPGA 加速卡，没有负责本项目应用流程的片上 CPU；XRT Host 在服务器 CPU 上运行。

| 部分 | 本工程中的职责 | 当前状态 |
| --- | --- | --- |
| CPU 应用与 [XRT Host](host/laya_host.cpp) | Host 读取预编码请求、校验模型包与 xclbin 身份、上传五个模型 BO、分配工作区、启动一次完整 forward、回读/校验/保存结果；分词、请求编码和业务解码由 CPU 应用层负责 | Host 源码已实现，应用层尚未完整接入；真实 XRT 构建、设备运行未验证 |
| PCIe / XRT / 平台 shell | 连接 Host 与 FPGA，完成数据传输、kernel 启动和设备管理 | 实际 `.xpfm` 平台尚未提供，未完成链接 |
| FPGA kernel `laya_typed_q8_forward` | C++实现/部署合同：请求与模型身份检查、整图调度、全部数值运算、缓存状态管理、错误恢复和结果提交 | fe067完整CPU/B2 CSim通过；旧04934的HLS RTL/IP/OOC有QK/AV固定E_SHAPE缺陷。fe067完整数值RTL与同源资源尚未验收 |
| HBM 与片内缓存 | HBM 保存模型权重和主要中间张量；片内缓存保存当前权重、激活 tile、部分和及控制元数据 | 裸 OOC 存储映射已取得；平台 HBM 连接与布局布线尚未验证 |

CPU 上运行的独立 oracle 和 DUT 验证程序用于检查功能。部署接口只提交一次完整 kernel 调用，28/2 层循环由 FPGA 内部 controller 执行。Host 目前是处理预编码 ABI 请求的工程入口，尚未集成完整分词、服务和业务解码流程。代码见 [Host](host/laya_host.cpp)、[完整顶层](hls/platform/full_kernel_wrapper.cpp)和[整图 controller](hls/control/full_forward_controller.cpp)。

## 一次推理的完整流程：CPU 与 FPGA 各做什么

以下是**C++/CPU/CSim已验证的完整执行图与预期部署合同**。旧04934生成RTL因上述控制缺陷不能成功完成这条流程；修复后fe067的完整请求RTL尚未验收，尚无上板实测。合同规定一次kernel处理整段输入，输出每题候选分数和ACT分数，没有逐token自回归生成循环；CPU功能仿真代执行算术不等于这些步骤已在FPGA成功运行。

```text
离线 CPU：冻结 GGUF → 导出五个模型文件、manifest 和编译用描述表
                              ↓
CPU 应用：文本/业务输入 → 分词、候选位置等 → 预编码请求文件（应用层待接入）
                              ↓
CPU Host：校验文件 → 加载 xclbin → 分配 13 个 BO
          → 经 PCIe 上传模型、初始化工作区和 io 请求 → 启动一次 kernel
                              ↓
FPGA：读请求 → Embedding → 28 层 Encoder → Type Embedding
       → 2 层 Decision → 候选 Scorer → ACT → 把结果帧写回 io
         ↕ 各阶段由 FPGA 自行读写 HBM，按需使用片内缓存
                              ↓
CPU Host：等待完成 → 经 PCIe 回读 384 B 结果 → 保存并校验结果帧
                              ↓
CPU 应用：把候选/ACT 分数转换成业务答案或动作（应用层待接入）
```

### 从模型文件到启动 FPGA

| 顺序 | 谁执行 | 具体工作与数据去向 |
| --- | --- | --- |
| 1. 离线模型准备 | CPU 上的[模型导出器](tools/export_gguf.py) | 读取冻结 GGUF，整理 Q8 权重、scale、Embedding 和辅助参数，生成 `embedding.bin`、`w_q0.bin`、`w_q1.bin`、`w_scale.bin`、`aux.bin`，以及 manifest 和编译用描述表。构建时 FPGA 使用固定描述表，运行时不解析 GGUF/JSON；这一步不在每次 kernel 内执行 |
| 2. 准备本次输入 | CPU 应用层；当前 Host 读取准备好的文件 | 应用层应完成分词、padding、候选位置/有效性和题型编码，形成带 model/numeric/layout/build 四个 tag、request_id、generation 和 B/S 的 ABI 请求。**现有 Host 不执行分词，也不自动从文本打包请求**；它读取 `--request` 指定的预编码二进制文件并校验 |
| 3. 初始化设备和内存 | CPU 上的 [Host](host/laya_host.cpp) 调用 XRT | 校验 xclbin SHA、模型 manifest 和请求身份，打开设备、加载 xclbin，按 `kernel.group_id(0…12)` 分配 13 个 BO（设备内存缓冲区）。`group_id` 表示 kernel 参数的连接组；实际 HBM bank 连接仍需平台链接确认 |
| 4. 上传与启动 | CPU Host / XRT，经 PCIe 传输 | 校验并上传五个模型 BO；将七个工作区清零并整区上传；清零 32 KiB 的 `io`、放入请求，再同步整个 `io`。随后用 13 个 BO 参数启动一次 `laya_typed_q8_forward`，Host 等待完成 |

当前 Host 是一次进程运行、一次 kernel 调用的入口。**每次启动 Host 都会重新分配 BO、上传模型和初始化工作区**，尚未实现“模型上传一次、Host 服务连续处理多个请求”的部署模式。已有同一 Runtime 连续请求/故障恢复证据属于功能验证范围。

无板卡阶段已[放行Host协议核心的离线准备](results/attention_rtl_repair_20261008/reviewer_host_session_offline_v1_design_cpu_preparation_release.json)，设计包含身份顺序、单个在途请求、精确384B结果与超时后所有权；保留每请求184MiB workspace和32KiB IO同步。测试backend的分配/上传事件只验证协议逻辑，真实XRT适配、常驻服务和设备性能尚未验收。

本次请求实际包含以下五组输入，见[请求解析](hls/common/laya_full_io.cpp)和[输入结构](include/laya_full_runtime.h)：

| 输入 | CPU 提供的数据 | FPGA 用途 |
| --- | --- | --- |
| `token_ids[B,S]` | INT32 token 编号 | 查 Token Embedding 表 |
| `attention_mask[B,S]` | U8 有效 token 标记 | Attention 屏蔽 padding 等无效位置 |
| `marker_positions[B,16]` | INT32 候选位置，采用 ABI 规定的展平索引 | 从最终 hidden 中提取每个候选对应的向量 |
| `marker_mask[B,16]` | U8 有效候选标记 | 候选分数屏蔽和有效候选统计 |
| `qtype[B]` | 每题一个类型值 0…2；请求中为 INT32，解析后保存为 U8 | 在 Encoder 结束后选择该题的 Type Embedding；不是每个 token 一份 type_id |

### FPGA 启动后，整网计算都在卡内完成

以下步骤由 [FPGA controller](hls/control/full_forward_controller.cpp)顺序发起。**CPU 不逐层调用算子，也不逐层取回中间张量。** 28 个 Encoder 和 2 个 Decision 是 controller 内部的层循环；层数不表示复制了相同数量的完整并行电路。

1. **读取和检查请求。** FPGA 从 `io` 读取五组输入及请求头，检查形状、索引、mask、四个 tag 和请求序号，再读取 `aux` 中的模型头核对身份；完成请求状态回收/初始化后才进入数值计算。

2. **把 token 编号变成向量。** FPGA 根据 `token_ids` 从 HBM 的 `embedding` 中读取 Q8_0 行，每个 token 的 1,088 B 数据反量化为 1,024 维 FP32 向量；然后执行 Embedding LayerNorm，把 hidden 写入 HBM 工作区。Embedding 查表、反量化和 LayerNorm 都由 FPGA 做。

3. **循环完成 28 层 Encoder。** 第一层直接使用前一步归一化的 hidden，后续层先做 Attention LayerNorm。每层依次计算 QKV，写入 QKV 工作区；对 Q/K 做 RoPE 后，按 head 装入 K/V，执行 `QK → mask → Softmax → AV`。Encoder 每三层有一层全局 attention，其余使用滑动范围 mask。Attention 结果经 `Wo` 投影，与旧 hidden 相加；再执行 `LayerNorm → Wi → GEGLU → Down → 残差相加`。新的 hidden 留在 HBM，供下一层继续使用。

4. **加入题型信息，再完成 2 层 Decision。** FPGA 先做 Final LayerNorm，根据每题 `qtype` 查 Type Embedding 表，并把该向量加到这题各 token 的 hidden 上。随后循环两层 `LayerNorm → QKV → QK/mask/Softmax/AV → Wo → 残差`，以及 `LayerNorm → FC1 → ReLU → FC2 → 残差`。**Decision 阶段不执行 RoPE**，使用全局 attention 的 mask 路径。结果仍保留在 HBM hidden 工作区。

5. **为 16 个候选位置计算分数。** FPGA 按 `marker_positions` 从最终 hidden 提取候选向量，做 LayerNorm、Scorer FC1、bias/GELU 和 Scorer FC2，得到每题 16 个原始候选 logits；再按 `marker_mask` 屏蔽无效候选。接着在 FPGA 内对这些分数做 Softmax，并计算最大概率、最大概率与近似次大概率之差、归一化熵、归一化有效候选数量这四项统计，供 ACT 使用。

6. **计算 ACT 分数。** FPGA 读取本题的 CLS 向量（本题第 0 个 token 的最终 hidden），与上一步四项统计拼成 1,028 维输入，执行 ACT FC1、bias/GELU、ACT FC2，得到每题 2 个 act logits。候选概率和四项统计是这一步的内部输入，不作为最终结果单独传给 Host。

7. **提交结果。** [结果模块](hls/control/full_result.cpp)从工作区读取每题 **16 个已应用候选 mask 的 logits 和 2 个 act logits**，连同身份、状态和诊断计数封装为固定 **384 B 的整个请求结果帧**，写到 `io` 的偏移 16,384 B；有效输出数随 B 为 18 或 36 个 F32。先写 payload/诊断，再写作为提交标记的头部，随后 kernel 返回。

### 算子之间的数据放在哪里

Host 分配的 13 个 BO 分成五个模型区、一个请求/结果区和七个工作区；FPGA 通过对应 AXI 端口访问。主要张量存放如下，具体偏移由[内存映射](hls/common/laya_full_memory.cpp)确定：

| 位置 | 保存什么 | 谁在推理期间读写 |
| --- | --- | --- |
| `embedding / w_q0 / w_q1 / w_scale / aux`，共五个模型 BO | Embedding、Q8 矩阵的两个分片、scale、bias、RoPE/LN 参数和其他辅助权重 | Host 启动前上传，FPGA 按当前算子读取 |
| `io` | 请求头和五组输入；完成后的 384 B 结果帧 | Host 写请求，FPGA 读请求/写结果，Host 回读结果 |
| `state0 / state1` | hidden、归一化/临时数据，以及 marker、type、head 等固定子区域 | FPGA 在各阶段间自行读写 |
| `qkv0 / qkv1` | Q/K/V 张量分片 | FPGA 的 QKV、RoPE、attention 路径读写 |
| `ff0 / ff1` | FFN 宽向量和 GEGLU 等中间值；部分区域按阶段复用 | FPGA 的 FFN 路径读写 |
| `att_out` | 各 attention head 合并后的输出 | FPGA 写入，随后由 Wo 路径读取 |
| FPGA 片内缓存 | 当前权重、激活块、部分和、当前 head 的 K/V、score/prob 等 | FPGA 内部加载器和算子使用，不经 PCIe 逐步回传 |

对一个 Q8 Linear，[加载器](hls/memory/full_loader.cpp)先从 HBM 装入**当前整张 Q8 权重矩阵**（含物理尾部、group scale 和所需 bias）到片内缓存，再处理各激活块；它不是把整个模型同时装入片内，也不是只缓存一个权重 tile。激活每次最多 16 行，输出按最多 8 列窗口计算；部分和在片内积累后写入对应 HBM 张量，完整任务达到 READY 后才交给下一任务。这是当前 F0 的分块、串行执行方式，未实现全流式跨层运算或双缓冲重叠。

Q8 Linear 的输入原本是 FP32，[量化器](hls/operators/activation_quantizer_compute.cpp)会动态计算每 32 个元素的激活 scale 并转成 INT8。[乘加路径](hls/operators/q8_linear_compute.cpp)先做 INT8×INT8、INT32 组内点积，再把保存为 F16 的激活/权重 scale 转成 FP32，缩放并跨组累加，输出 FP32。LayerNorm、RoPE、QK/AV、Softmax、非线性和残差等仍用 FP32；Scorer FC2 是浮点路径，ACT FC1 使用 F16 权重转 FP32 运算。因此权重量化不等于整个推理过程都用 INT8。

### CPU 怎样拿到最终答案

Host 等待 kernel 完成后，通过 XRT 将 `io` 中 **384 B 结果帧**同步回 CPU，写入 `--result` 指定的二进制文件，并检查 ABI/tag、request_id/generation、B/S、成功状态及输出是否为有限数。Host 返回的是这份分数与状态记录，不会回读全部 hidden、QKV、attention 概率或 FFN 中间张量。

根据候选 logits 选取业务候选、解释 ACT 分数、应用业务阈值并组织用户可读答案，属于 CPU 应用层后续接入；当前 Host 没有实现这些业务规则。因而当前完整边界是：**CPU 提供预编码输入并启动，FPGA 完成整段输入的全部前向数值计算，CPU 取回候选/ACT 分数；文本输入与业务答案两端的应用集成仍待完成。**

形状备注：B=1 或 2，S=64/128/256/512/1024，hidden=1024，16 个 attention head、每头 64。完整网络已测 S128，其他四档为任务/地址补充验证；早期并行阵列、64 路 FP 和 25–50 ms 性能目标尚未实现或验收。

## 工程位置、模型身份与工具

**正式工程为本目录 `Laya-baseline`；当前修复源码回归须显式使用 [build/model-attention-rtl-repair-20261008](build/model-attention-rtl-repair-20261008/manifest.json)。** 脚本尚保留的默认`build/model-repair`对应旧04934，不能与新源码/新请求混用。P1/P2/P3只改变controller的metadata表示，正式与隔离源码SHA均为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，见[生产代码审核](results/attention_rtl_repair_20261008/reviewer_production_patch_review.json)及[正式同步审核](results/attention_rtl_repair_20261008/reviewer_official_sync_review.json)。

| 制品/路径 | build tag | 当前证明范围 |
| --- | --- | --- |
| 正式`Laya-baseline/build/model-attention-rtl-repair-20261008` | `fe067c8aa0627ad770096f9721394645` | 当前正式源码；完整CPU门禁141检查点及恢复通过；新B2 top CSim执行通过，RTL待验证 |
| 隔离`Laya-repair-20261007/build/model-attention-rtl-repair-20261008` | `18366c267ae0a7ca0c3afb8c2174b890` | 已执行该身份CPU回归；不是正式工程身份 |
| 历史`Laya-baseline/build/model-repair` | `04934c15b3f83e842ec2e92ac2a81bf2` | 以下既有CSim、HLS RTL/IP和Vivado OOC的缺陷制品 |

两个新包的model/numeric/layout tag不变。正式源码多出纳入身份生成的`tools/collect_performance_facts.py`，故正式build tag不同于隔离副本；未修改冻结前像政策来合并tag。正式新manifest SHA256为`128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa`。新包没有对应已验收的完整RTL/IP或xclbin，不能与旧04934硬件制品配套。

下表保留旧04934制品身份和当时工具配置，来源为[旧回写收据](results/synthesis_memory_fix_20261007/promotion_receipt_04934.json)；归档绝对路径按真实运行现场保留。

| 项目 | 旧04934身份或当时配置 |
| --- | --- |
| build tag | `04934c15b3f83e842ec2e92ac2a81bf2` |
| model tag | `6eb6ef58bc4f99bd9db40381604108af` |
| numeric tag | `aeb13e7937d29fe6a2c68c407249f294` |
| layout tag | `f927881686d9d11c91b7f11ac59e2cc7` |
| 模型包清单 SHA-256 | `26dfb25f876ea6bfbf2d41e4defb7090bbdbcc0ba5c1d17a3ff4e826982f889b` |
| 模型清点 | 153 条 tensor 记录、152 个保留 payload、122 个 Q8 矩阵、124 个 WeightKey |
| 模型大小 | 原 GGUF 455,179,648 B（约 434.1 MiB）；保留 payload 448,921,352 B。权重是外部存储数据，不是逐参数硬化的电路 |
| 构建身份 | 103 项源码/配置输入；实际完整 HLS 清单为 25 份生产 C++ 源 |
| 实测工具 | Vitis HLS 2025.2 / Build 6295257；GCC 13.3.0；CMake 3.31.8；Python 3.12.3、NumPy 1.26.4、glibc 2.39 |
| 实验器件与时钟请求 | `xcu55c-fsvh2892-2L-e`，150 MHz；尚未绑定实际 U55C `.xpfm` 平台 |

旧身份依据为[模型 manifest](build/model-repair/manifest.json)、[严格包验证](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/package_verify/full_model_package_report.json)及[回写后复核](results/synthesis_memory_fix_20261007/post_promotion_review_04934.json)。生产源码、配置或数值合同变化后，需要重新导出身份并验证受影响阶段；历史 `model-p2-final` 和旧 build tag 不代表当前包。

### 15 个模块与源码

手写硬件实现主要在 `hls/`，公共类型和接口在 `include/`；它们由 HLS 转换成 RTL。下表是功能责任划分，目录数不等于独立物理实例数。完整编译范围以[生产源清单](config/full_sources.cmake)为准，[模块登记](config/full_module_registry.json)只记录源码映射，其静态 `unverified` 字段不替代分阶段运行报告。

| 分组 | 模块与详细设计 | 主要源码 |
| --- | --- | --- |
| 集成与控制 | [top](vivado/module_design/top/source/design.md) | [laya_forward_full.cpp](hls/laya_forward_full.cpp) |
| 集成与控制 | [common](vivado/module_design/common/source/design.md) | [include/](include/)、[laya_numeric.cpp](hls/common/laya_numeric.cpp)、[laya_tasks.cpp](hls/common/laya_tasks.cpp) |
| 集成与控制 | [kernel_wrapper](vivado/module_design/kernel_wrapper/source/design.md) | [full_kernel_wrapper.cpp](hls/platform/full_kernel_wrapper.cpp)、[full_cache_storage.cpp](hls/platform/full_cache_storage.cpp)、[full_io](hls/common/laya_full_io.cpp) |
| 集成与控制 | [forward_controller](vivado/module_design/forward_controller/source/design.md) | [full_forward_controller.cpp](hls/control/full_forward_controller.cpp) |
| 存储 | [memory_map](vivado/module_design/memory_map/source/design.md) | [laya_memory_map.cpp](hls/common/laya_memory_map.cpp)、[laya_full_memory.cpp](hls/common/laya_full_memory.cpp) |
| 存储 | [hbm_loader_and_cache](vivado/module_design/hbm_loader_and_cache/source/design.md) | [full_loader.cpp](hls/memory/full_loader.cpp)、[laya_full_owner.cpp](hls/common/laya_full_owner.cpp) |
| 数值运算 | [embedding_engine](vivado/module_design/embedding_engine/source/design.md) | [embedding_full_compute.cpp](hls/operators/embedding_full_compute.cpp) |
| 数值运算 | [layernorm_engine](vivado/module_design/layernorm_engine/source/design.md) | [layernorm_compute.cpp](hls/operators/layernorm_compute.cpp) |
| 数值运算 | [activation_quantizer](vivado/module_design/activation_quantizer/source/design.md) | [activation_quantizer_compute.cpp](hls/operators/activation_quantizer_compute.cpp) |
| 数值运算 | [q8_linear_and_restore](vivado/module_design/q8_linear_and_restore/source/design.md) | [q8_linear_compute.cpp](hls/operators/q8_linear_compute.cpp) |
| 数值运算 | [rope_and_mask](vivado/module_design/rope_and_mask/source/design.md) | [rope_full_compute.cpp](hls/operators/rope_full_compute.cpp) |
| 数值运算 | [attention_and_fp_engine](vivado/module_design/attention_and_fp_engine/source/design.md) | [attention_full_compute.cpp](hls/operators/attention_full_compute.cpp) |
| 数值运算 | [vector_and_ffn](vivado/module_design/vector_and_ffn/source/design.md) | [vector_full_compute.cpp](hls/operators/vector_full_compute.cpp) |
| 决策与结果 | [decision_scorer_act](vivado/module_design/decision_scorer_act/source/design.md) | [decision_full_compute.cpp](hls/operators/decision_full_compute.cpp) |
| 决策与结果 | [result_status](vivado/module_design/result_status/source/design.md) | [full_result.cpp](hls/control/full_result.cpp) |

各算子通过 `hls/operators/full_tasks*.cpp` 接入真实 loader、owner、地址与结果检查。模块的 `source/design.md` / `source/results.md` 分别维护设计和证据，`rtl/` 用于需手工维护的 RTL，`tb/` 存放测试入口。当前生成 RTL 已归档在[完整 HLS 工件目录](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/)，不是把各模块 `rtl/` 目录当成 HLS 输出目录。

[模块目录页](vivado/module_design/README.md)和[历史实施合同](hardware_agent/task.md)可用于导航、理解原约束与阶段演进；其中旧阶段摘要保留原时间范围。当前验收按身份区分：本页与[top结果](vivado/module_design/top/source/results.md)所链旧 `04934…` HLS/OOC保留历史制品事实；新 `fe067…` CPU/CSim及D1/D2以本页最新独立审核为准，不能互相拼接成完整RTL验收。

## 分阶段功能与工程验证

新官方CPU门禁见[本次结果](results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)：build `fe067c8aa0627ad770096f9721394645`，141检查点及故障恢复通过；该CPU报告生成时CSim/csynth/RTL/platform仍为未验证，后续独立13口CSim运行见[新日志](results/attention_rtl_repair_20261008/d2_full_top_csim_official_v1/csim.log)。运行审核与D2其余边界分别记录。

下列历史完整验证均对应 build tag `04934c15b3f83e842ec2e92ac2a81bf2`。**逐位比较的对象是读取冻结 GGUF、按当前硬件数值合同独立重算的 oracle，不是 GPU/native 全图逐位一致或业务质量验收。** 历史局部 RTL 证据单独列出。

| 阶段 | 已得到的结果 | 证据与验证边界 |
| --- | --- | --- |
| CPU 总门禁与数值叶函数 | **PASS**：27/27 CTest；75 个数值正例逐位通过，另 1 个既有预期拒绝符合预期 | [CPU 门禁](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/full_final_gate_report.json)、[数值用例](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/numeric_fixture/full_fixture_report.json) |
| CPU 完整前向 | **PASS**：B2/S128 和两题各自重基后的 B1/S128，合计 141 个检查点、18,094,384 个 F32 逐位一致；每个成功请求完成 28+2 层 | [独立逐点比较](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/compare/full_forward_dut_compare_report.json) |
| 同一 Runtime 的故障恢复 | **PASS**：4 个连续请求，3 次成功、1 次已接受的预期故障；故障后恢复。成功退休任务数为 37,158 / 18,895 / 18,895 | [持久运行报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/dut/full_forward_dut_run_report.json)；故障在第 17 个任务发生，错误帧与零输出按合同检查 |
| 真实直接任务 | **PASS**：front 比较 527,360 个 F32；10 种矩阵任务比较 329,730 个 F32；attention full/slide 各 1,622,016 次比较 | [front](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/front_dut/full_front_dut_report.json)、[matrix](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/matrix_dut/full_matrix_dut_report.json)、[attention](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/attention_dut/full_attention_dut_report.json) |
| S64/256/512/1024 补充 | **PASS**：真实任务、末行末列、地址边界、覆盖发布与 guard 检查 | [shape 报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/shape_dut/full_shape_dut_report.json)；四档未执行完整网络，部分 attention 输入使用明确标记的 fixture |
| `__SYNTHESIS__` 分支 shadow | **PASS**：25 份生产源、真实 13 口顶层，同进程 4 次调用，3 次成功和 1 次预期故障；72 个有效结果 F32 与 oracle 一致 | [shadow 报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/shadow_r2/shadow_report.json)；这是综合分支的 CPU 执行，仅比较结果帧，不是 RTL 仿真或整图 141 点比较 |
| 完整顶层 Vitis HLS CSim | **PASS**：B2/S128，47 个检查点、9,047,192 个 F32、37,158 个任务，工具报告 0 errors | [CSim 日志](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csim_full/csim.log)；使用 `csim.stdmath=true`、`-O2 -fno-fast-math -ffp-contract=off` |
| 完整顶层 HLS 综合与 IP 导出 | **完成，退出 0**：25 份生产源完成调度/绑定与全部 RTL 模型生成，已导出顶层 Verilog、VHDL、报告和 Vivado IP | [完整综合结果](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)；生成成功不等于完整 RTL 功能或物理适配已验收 |
| 完整顶层 Vivado OOC 综合 | **完成，退出 0、blackboxes=0**：201 DAT 实际 PRE 核验，完整映射资源/综合时序/DCP 已生成；主要资源未超裸器件总量 | [OOC 结果与原报告](vivado/project/source/results.md)、[独立审核](vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)；综合 WNS +0.894 ns，不能替代 P&R/平台时序 |
| 历史局部 RTL | RoPE leaf 三例 cosim PASS；修后 read helper 在 base 0 / 0x100 两例 XSim PASS | [RoPE 日志](results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log)、[read helper 审核](results/p2_environment_20261007/axi_base_zero_source_review.json)；仅证明各自范围，后者不覆盖完整外部 AXI4 adapter |
| 完整 RTL / 物理实现 | **未执行**完整 RTL cosim、布局布线及布线后时序 | 当前 callback testbench 仅用于 CSim；`run_full_hls.sh --cosim` 在入口明确拒绝；OOC 综合不是功能 RTL 仿真 |
| XRT / 平台 / 上板 | **未执行**真实 XRT 编译链接、平台 compile/link、xo/xclbin 生成、上板质量/稳定性/性能验证 | [XRT 依赖检查](results/engineering_p2/xrt_host_dependency_probe_20261007/configure.log)显示缺头文件和库；[历史语法检查](results/p2_environment_20261007/host_syntax_only_evidence/report.json)使用旧包和本地声明替身，只是语法证据 |

每次成功前向的 46 个中间检查点来自实际已发布 BO 对象，`final18` 来自真正提交的 384 B ABI 帧。独立 oracle 不向 DUT 注入 native 中间值。原 native 第二题 ACT CLS 的旧 stride 偏差已有[独立核查](results/p2_environment_20261007/native_act_cls_stride_check.json)；当前 DUT 遵守“本题 CLS”合同。两题功能通过不能外推为 400 例业务质量或板上 action 一致性通过，A6000 对照与 FPGA 速度目标也尚未完成本轮实测。

标准 libm 的 CPU/CSim 逐位一致不证明 HLS 非线性算子生成的 RTL 与 libm 一致，完整 RTL 数值误差仍待验证。[功能链汇总](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)和 CPU 门禁只记录各自生成时的阶段状态；其后的同 tag 完整综合，以完整综合结果和回写审核为依据。

## 资源、接口与性能边界

完整顶层的当前 [Vivado 资源报告](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization.rpt)与先前 [HLS 估算](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/laya_typed_q8_forward_csynth.rpt)对照如下。百分比使用当前映射数/整颗器件容量，尚未扣除平台 shell 预留：

| 资源 | HLS 估算 | 当前 Vivado 映射 | 整颗器件容量 | 映射占比 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT 总量 | 1,813,717 | 345,505 | 1,303,680 | 26.50% |
| FF | 477,288 | 287,466 | 2,607,360 | 11.03% |
| DSP | 485 | 437 | 9,024 | 4.84% |
| BRAM，18K 等效 | 570 | 1,380 | 4,032 | 34.23% |
| URAM | 44 | 179 | 960 | 18.65% |

CLB LUT 为 339,874 logic＋5,631 memory；BRAM 为 530 RAMB36＋320 RAMB18，即 690 个 36K tiles，等效 1,380 个 18K。两种 BRAM 单位不可相加。HLS 的 `Utilization Estimates` 与 Vivado 对冻结 RTL 的优化/映射属于不同阶段：当前 LUT 比 HLS 估算低约 80.95%，而实际 BRAM/URAM 比 HLS 估算高。本轮未改变计算源码或架构，不能把差异解释为额外算法优化、全部算子自动共享或性能提升。当前资源总量未超裸器件容量，但放置、拥塞、平台预留与布线后时序仍未验证。

历史 [HLS 独立资源复核](results/synthesis_memory_fix_20261007/full_resource_review_04934.json)中的四个 `linear` 合计 618,806 LUT、`graph` mux 64,914 LUT 均是 HLS 阶段估算，当前映射分布应查 [Vivado 层次报告](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt)。加载、量化、检查、调度与算术都属于计算子树；父模块总量包含子模块，不能重复相加。映射结果仍保留 Q8/FP 数值电路，不以资源下降代替完整 RTL 功能验证。

13 个持久数值数组的声明容量为 8,641,536 B（8.2412 MiB），不含控制元数据、局部数组和存储碎片。历史独立 RAM OOC 对两个 packed 权重缓存得到 **164+11=175 URAM**；完整 HLS 估算为 44，本次完整 Vivado 映射为 179。三者范围/阶段不同，不能相加或互相替代；实际放置仍待 P&R，详见 [OOC 资源口径](vivado/project/source/results.md)。

真实生成接口包含 **13 个 `m_axi` bundle**，以及 `s_axi_control`、`s_axi_control_r` 两组 AXI-Lite 控制接口。当前生成 master 默认数据宽度 32 bit、地址宽度 64 bit；[顶层 C++](hls/platform/full_kernel_wrapper.cpp)中的 512 bit 是最大 widen 请求，不是已实现吞吐；[候选 HBM 连接配置](config/u55c_link.cfg)尚未经实际平台链接验证。完整顶层 latency/interval 在 HLS 报告中未定义。当前 [综合时序](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/timing_summary.rpt)在 6.667 ns 请求下 WNS +0.894 ns、TNS 0、WHS +0.046 ns，但 550 输入/1,781 输出未设外部 delay，且缺少 `HD.CLK_SRC` 无法估计真实 clock delay/skew。约 150 MHz 仍是约束请求，综合结果与历史 HLS Fmax 都不是布线后或板上频率实测。

### 已解决的综合主机内存问题

旧完整 HLS 综合因工具主机内存增长终止。修复拆分了数值 cache 的全零静态存储与控制初值，保留元素类型、逻辑尺寸、owner/epoch 和数值语义；随后修复实际综合路径中的指针比较问题。最终 HLS 运行的受控进程树 RSS 采样峰值为 **9.068 GiB**，旧失败 HLS 运行采样值为 **361.572 GiB**，见[修复报告](results/synthesis_memory_fix_20261007/report.md)。本次完整 Vivado OOC 是另一工具流程，整个 synth phase 用时 **104.47 分钟**，任务树 RSS 采样峰值 **38.8910 GiB**、最低主机 MemAvailable **383.4557 GiB**，64 GiB/4 小时保护未触发。以上均为服务器观测，不是 FPGA 片内存储；采样值也不是生命周期绝对峰值，不同工具/统计范围不能混作同一次测量。

## 复现入口

以下命令在正式工程根目录执行，显式使用新的fe067模型包；不要省略该环境变量回退到旧04934默认包。CPU 验证还需要冻结 GGUF、`reference/` 中的冻结请求、Python/NumPy 和编译工具；脚本默认使用随工程保存的 CMake 3.31.8，可通过 `CMAKE_BIN` / `CTEST_BIN` 指定实际安装。

```sh
export LAYA_FULL_MODEL_DIR="$PWD/build/model-attention-rtl-repair-20261008"
export LAYA_REPRO_ID="$(date -u +%Y%m%dT%H%M%SZ)"
export LAYA_FULL_BUILD_DIR="$PWD/build/full-local-$LAYA_REPRO_ID"
export LAYA_FULL_TEST_RESULTS="$PWD/results/local-full-$LAYA_REPRO_ID/cpu"
./scripts/run_full_tests.sh
```

[CPU 脚本](scripts/run_full_tests.sh)自动启用 `LAYA_ENABLE_FULL_NUMERIC` 和 `LAYA_ENABLE_FULL_FORWARD`，构建后执行 CTest、严格包校验、源闭合、独立 oracle、直接任务、四 shape、完整前向和最终门禁。`LAYA_FULL_BUILD_JOBS` 支持 1–4，默认 4；正常终点为 `FULL_FORWARD_CPU_PASS`。

同一终端继续使用本次 CPU 生成的当前 tag 请求和独立 oracle，执行真实顶层 CSim：

```sh
LAYA_FULL_REQUEST="$LAYA_FULL_TEST_RESULTS/dut/inputs/B2_S128.request.bin" \
LAYA_FULL_ORACLE="$LAYA_FULL_TEST_RESULTS/oracle/B2_S128" \
LAYA_FULL_HLS_BUILD="$PWD/build/full-local-csim-$LAYA_REPRO_ID" \
LAYA_FULL_HLS_RESULTS="$PWD/results/local-full-$LAYA_REPRO_ID/csim" \
  ./scripts/run_full_hls.sh --csim
```

[HLS 脚本](scripts/run_full_hls.sh)默认使用本机 Vitis 2025.2 路径，支持 `VITIS_RUN_BIN` / `VPP_BIN` 覆盖。其他模式如下；列出入口不表示这些阶段都已完成。当前新源码完整top HLS尚须D2证据通过后的内部技术放行；不能因入口存在就直接重跑完整综合。

| 模式 | 实际作用与前提 |
| --- | --- |
| `--check` | 打印模型、工具、part/platform 配置，仅检查 Vitis 可执行文件与生成头存在；不是严格模型包验证 |
| `--csynth` | 对 `LAYA_FULL_PART`（默认 U55C part）运行完整 HLS 综合，生成 RTL/IP；无需 `.xpfm`。可用 `LAYA_FULL_HLS_BUILD` / `LAYA_FULL_HLS_RESULTS` 指定独立输出目录 |
| `--cosim` | 当前入口明确失败，提示尚需可供 RTL 使用的结果帧 testbench |
| `--compile` | 需要真实 `LAYA_PLATFORM=/path/to/platform.xpfm`，以 Vitis flow 生成 `.xo` |
| `--link` | 需要真实 `LAYA_PLATFORM` 和 `LAYA_FULL_XO`，使用 `config/u55c_link.cfg` 链接 `.xclbin` |
| `--deploy` | 调用真实 XRT Host；需要已构建 Host、实际 xclbin、当前请求和设备环境 |

F0 综合配置禁用自动 loop pipeline、吞吐驱动 array partition 和自动 complete partition；两个权重缓存请求 URAM 绑定及存储字 reshape。这些配置不代表算术并行度或物理映射已达标。已归档的完整综合使用了额外资源守护；通用 `run_full_hls.sh` 入口本身不包含该次守护器。

如需在源码/配置变化后重新导出模型包，可使用[导出器](tools/export_gguf.py)的 `--gguf` 与 `--out`，例如导出到独立 `build/model-local`，再将 `LAYA_FULL_MODEL_DIR` 指向它。导出器默认输出仍是 `build/model-p2`，不同于测试/HLS 的默认 `build/model-repair`，因此应显式给出输出目录。新包、新请求与验证证据必须使用匹配的身份，不能直接复用旧 tag 请求。

`run_full_numeric_tests.sh` / `run_full_numeric_hls.sh` 保留数值叶函数入口。P0/P1 脚本用于各自历史回归；`run_hls.sh` 与 `hls/laya_forward.cpp` 的 `contract_only` 属于历史 P0 目标，完整当前目标应使用上述 `run_full_*` 入口。

旧04934完整 HLS RTL 的[独立 Vivado OOC 工程](vivado/project/README.md)已完成创建、配置验证和完整顶层综合，可从该页进入实际 `.xpr`、显式复现入口、本次日志、资源/时序报告及 DCP；该工程尚未执行 P&R 或平台链接。

## XRT Host 构建与运行

当前环境缺真实 XRT 头文件和库；以下是依赖齐备后的实际入口，不是已完成部署的记录。安装匹配的 XRT 与 OpenSSL Crypto 后，用 `XILINX_XRT` 或 `CMAKE_PREFIX_PATH` 指向 XRT 安装：

```sh
cmake -S . -B build/full-xrt-host \
  -DLAYA_ENABLE_XRT_HOST=ON \
  -DLAYA_FULL_MODEL_DIR="$PWD/build/model-attention-rtl-repair-20261008"
cmake --build build/full-xrt-host --target laya_host
```

Host CLI：

```text
laya_host --xclbin FILE --xclbin-sha256 HEX --package DIR \
          --request FRAME --result RESULT --timeout-ms N [--device INDEX]
```

Host 按 `kernel.group_id(0…12)` 分配 BO，核验并上传模型，启动一次 `laya_typed_q8_forward`，等待后读取并检查结果身份。`FRAME` 须匹配包内四个 tag。`run_full_hls.sh --deploy` 使用 `LAYA_XRT_HOST_BIN`、`LAYA_FULL_XCLBIN`、`LAYA_FULL_XCLBIN_SHA256`、`LAYA_FULL_REQUEST`、`LAYA_FULL_RESULT`、`LAYA_FULL_TIMEOUT_MS` 和可选 `LAYA_FULL_DEVICE_INDEX` 调用同一 Host；缺依赖时会明确失败。

## 当前证据导航

- [正式回写审核](results/synthesis_memory_fix_20261007/post_promotion_review_04934.json)：正式工程、当前模型包、103 项身份输入和 25 份 HLS 源与已验证现场的一致性。
- [修复与完整综合总报告](results/synthesis_memory_fix_20261007/report.md)：内存问题修复、数值语义、各阶段验证及未完成事项。
- [功能链汇总](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)：CPU、综合分支 shadow 与标准 libm CSim。
- [完整综合结果](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)、[原始日志](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/csynth.log)、[工件清单](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。
- [顶层 Verilog](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward.v)、[顶层 VHDL](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_vhdl/laya_typed_q8_forward.vhd)、[顶层综合摘要](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/csynth.rpt)、[Vivado IP 包](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/ip/xilinx_com_hls_laya_typed_q8_forward_1_0.zip)。
- [Vivado OOC 工程与本次日志](vivado/project/README.md)、[当前综合结果](vivado/project/source/results.md)、[独立综合审核](vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)：实际 `.xpr`、完整顶层映射、资源/综合时序、DCP 与运行保护证据。
- [独立资源复核](results/synthesis_memory_fix_20261007/full_resource_review_04934.json)与[top 模块当前结果](vivado/module_design/top/source/results.md)：资源层级、存储估算差异、时序和后续验证边界。

后续尚需完成完整 RTL 数值/接口验证、平台适配与布局布线、真实 Host/设备运行，以及业务质量、稳定性和端到端速度测量。当前 README 仅汇总已完成的 CPU/CSim/HLS/OOC 综合证据，不把综合资源或约束内时序写成部署与性能达标。
