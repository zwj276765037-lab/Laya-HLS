# Laya 本轮离线验证阶段合同

2026-10-09。设计与最终验收：GPT-6 Astra / xhigh；实现与执行：GPT-6 Sol / xhigh。依据用户最新授权，本文件优先于旧文档中的逐次“源码→编译→运行”放行、首次失败后必须重新审批及 Sol/max 默认。旧合同的数值、接口、证据和冻结约束继续有效；历史失败和既有验收不改写。

本轮按下表顺序推进。Sol 在范围和资源上限内连续准备、编译、运行、定位、修复普通代码/TB/脚本错误并执行受影响回归；不为每个步骤新增正式审核文档，不等待 Astra 逐步放行。仅架构、接口、数值规则或通过标准的实质变更交 Astra 处理。C1 性能新架构本轮暂停。无 U55C，本轮不会产生板上、完整系统或 50 ms 达标结论。

## 固定范围、通过标准与合同起始状态

下表只固化本合同的范围、通过标准和起始状态，不作为动态结果表。执行者统一维护 [stage_results.md](../results/offline_validation_20261009/stage_results.md) 中唯一的阶段结果表、实际证据入口及剩余未覆盖项；其他文件链接该表，避免重复维护。最终由 Astra 对实际交付集中审核一次。

| 顺序与项目 | 固定通过标准 | 合同起始状态与已有证据 | 固定覆盖边界 |
| --- | --- | --- | --- |
| 1. Attention Head15/query63 | 真实模型独立 gold；BEGIN、重复 BEGIN 拒绝、RUN、replay 拒绝四命令全部完成；QK 64 字精确、probability 原容差、AV 按实际概率的顺序 binary32 运算精确并满足原端到端容差；原选择性 R/B hold、全部端口协议、首次 done 时 debt/adapter 清零、输入/输出完整映射页、尾部 sentinel 和整块 replay 检查均通过 | **上一 runtime 失败（FAIL），新四命令待验证（NOT_RUN），执行优先**。monitor-v3 在 6666 ps、任何命令前 `ATT_R_RECORD_TOP_RESET port=0`；owner 14 路 raw/count 为 0，顶层原值缺失，不能归因模拟器。v4/literal probe 后继见下文 | 此四命令只关闭 B1/S64 head15/query63 外部预置路径；动态 pin reset、其他 shape、生产 QKV/Encoder 整链另验 |
| 2. Ws 实际有效容量 | 同一父 DCP 的 8 bank 全部 20992×16 bit 写入唯一、读出相同存储；含地址 bit14 / 16384–20991 高区，精确 INIT/parity/read mux/cascade/CE/WE 语义；不以配置容量替代有效映射 | **join 失败（FAIL），完整容量未验证（NOT_RUN）**。v6 的 8 份 funcsim、11 张 graph 已接受；v7 join 首错 `n32: ws_U/ce1[0]` 缺切片内常量来源。本合同已给定父层常量绑定修正，可直接实现、join 和映射 | 只证明现有综合 DCP 的有效容量；不能外推布局布线、时序、shell 余量或完整模型适配 |
| 3. Scorer 有效不同三行 | 冻结 B2/S128 batch1 rows0–2，mask=1，markers 147/163/174；同一 DUT LOAD_W→trace ON RUN→复用 W 的 trace OFF RUN。每 RUN 3072 F32 输出、96 量化组、4096 有序 issue/retire、3072 commits、3145728 MAC；trace 32/0；完整报告/数值、协议、debt、sentinel 和权重复用检查不变 | **RTL 未验证（NOT_RUN）；CPU、静态编译及输入序列化已通过（PASS）**。真实三命令 CPU、静态快照、13 memh 已接受并可复用；以 ≤120 s pilot 实测进度决定长运行，不再要求完整成功路径 FSM 正式预算报告 | 4f12 checkpoint 是冻结外部 ingress/gold，当前 DUT 为 fe067；不能声称当前身份新整链或其他矩阵通过 |
| 4. Type 冷 RTL | qtype2、qtype1 分别全新仿真进程；每例真实 Controller 的 1 EMB_TYPE＋4 binary ADD_TYPE、64×1024 输出 words，与各自独立 gold 比较；TYPE_ROWS、状态/身份/3 owner claims、IO、全映射页 sentinel、原 hold/协议/首次 done debt 检查不变 | **RTL 未验证（NOT_RUN），准备未完成；两个冷 CPU 及 HLS 静态结构已通过（PASS）**。两个冷 CPU 及 HLS 静态已接受；现有 352-pin / 206-page、229 Verilog / 88 DAT / 4 FP wrapper 准备必须绑定实际文件后执行 | 10 metadata 标量仅冷初值，无 ordinary reset；不声明暖复位。HLS 5.158 ns、CSim NOT_RUN 原边界保留 |

## 资源、连续修复与长运行

全 Laya 工作流及其全部代理树同一时刻最多一个重工具。每次受控工作使用 CPU 0–3、nice 19、idle I/O，0.2 s 采样 owned RSS，`MemAvailable` 必须严格大于 192 GiB；触及阈值停止本任务拥有的子进程，不处理无关任务。所有预算是单次尝试的上限，不是成功承诺。

| 工作 | owned RSS 上限 | 墙钟上限 |
| --- | --- | --- |
| 小 CPU、材料化、join、映射或最小诊断 | 4 GiB | 120 s |
| 编译 / elaboration | 16 GiB | 900 s |
| Attention 四命令 RTL | 8 GiB | 600 s |
| Scorer RTL pilot | 8 GiB | 120 s |
| Scorer 完整三命令 RTL | 8 GiB | 3600 s，须由 pilot 实测速率合理预计能完成 |
| Type 各必要完整 trace / 独立冷 RTL（按下文成本恢复补充） | 8 GiB | 每进程 7200 s、80000000 clocks；首 ≤120 s 在同进程观察，后续按阶段持续核成本；旧 600 s / 6000000 clocks 作为历史预算保留 |

Scorer 旧单行实测为 1051.984 s、约 5.12M clocks；三行约 2500 s 仅是待 pilot 检验的估计。dot 实际 37 clocks，旧 42 不再用于估算。pilot 记录实际仿真周期、命令/子阶段进度和 RSS；须把已完成 LOAD 与未完成计算区分，不能用启动时的高速度外推整程。可在同一受控进程中于 ≤120 s 做进度检查后继续，总墙钟仍不超过表中完整运行上限；若另起进程，pilot 不算完整数值验收。预期超限时提出具体替代覆盖并在阶段表写明剩余未验范围，不继续无限准备或把截断运行写成 PASS。

编译/运行失败可依据新证据做合同内修复并重跑受影响项，无需重新逐门审批。资源失败不得原样重跑并加额；需要有具体修复或更小且诚实标注的覆盖。保留原失败，不删断言、不改 gold、不降容差、不跳过失败命令。未变且已接受的 CPU、CSim、静态或 fixture 检查按身份复用。

## 两个已决定的具体修正

**Head15 最小诊断。** 使用 [v4 source packet](../results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v4/source/source_packet.json) 的真实同连接结构定位 owning monitor→wrapper→top；记录各层 raw 119-bit record 和 32-bit count。新 sibling [独立 literal 表](../results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v4_probe_literals_v2/source/independent_expected_literals.json) 提供 14 组固定期望；期望端必须直接使用字面值，不能重复 stimulus 公式，另测 reset 零值及指定 bit40 注入 X。原同公式 expected probe 已撤回。X 检测使用显式 reduction XOR 与 case comparison，例如 `(^record) === 1'bx`，已知值再作精确 case 比较；打印原值后判断。该诊断只能支持修复真正四命令 TB，不能替代真实数值运行，也不能凭一次表达式异常宣布模拟器根因。

**Ws 父层常量边界绑定。** 本规则一次定义，Sol 可直接完成后续实现和验证，无逐步技术门。冻结 [v6 export/graph evidence](../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v6/runs/export_graph_v1/evidence/evidence_packet.json) 与 [v7 join 首错](../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v7/runs/property_join_v1/evidence/evidence_packet.json) 保持不变。

1. 保留切片 HDL 原始结构，另建带来源的父层 boundary-environment certificate。仅允许精确 root **input** bit，且 bank/信号/bit、`PRESENT` boundary、真实 pin 的 owner/direction/net 全部一一对应。不存在、未解析、额外或冲突边界立即拒绝。
2. 父 DCP net 必须经原 graph audit 验证：constant 明确为 0 或 1；恰一个活动驱动，分别为真实 `GND/G` / `CONSTANT_ZERO` 或 `VCC/P` / `CONSTANT_ONE`，无其他活动或外部驱动；constant、driver、segment 的可用属性一致，所有来源表和 DCP 身份均绑定。不能仅凭网名 `<const0>` 推断。本例 n32 的实际证据为 constant 0、16 selected pins、1 driver、0 external、`GND/G`、`GROUND`，八 bank 的 ce1/reset 均精确连到该网。
3. 仅给经上述证据绑定的输入连通分量施加父层同值常量环境。多个切片输入原先分离、但确实属于同一父常量网时，可在 contextual graph 中合并，并保存每个分量的 boundary 证据；切片 HDL 不伪造内部 tieoff。原有 HDL literal 必须同值，不能有内部竞争驱动。不同父 DCP nets 仍保持独立身份，不因常量值相同自动合并。
4. 原 primitive/层级/端口/参数双射、精确 glbl EOF capsule 及严校全部保留。未连接边界默认零、UNKNOWN 常量、无真实驱动、不同值或多驱动、只有内部无来源分量的常量要求均拒绝。映射时显式应用经证实的 boundary 环境；不得把切片可独立输入的 ce1/reset 当作实际父 DCP 可切换输入。
5. 用少量有意义的正反例检查本修正：真实父常量、多边界同网合法；缺驱动/边界、错 bit/方向、相反 literal、多活动驱动、内部无依据补零和不同 DCP 网别名必须失败。随后直接运行完整 join 与全容量映射；join PASS 本身不等于容量 PASS。

**Ws 匹配原语的缺省反相参数（2026-10-09 实质规则补充）。** 本条一次替代旧合同对 RAMB36E2 八个反相参数“必须有显式 funcsim override”的要求，仅限 `IS_CLKARDCLK_INVERTED`、`IS_CLKBWRCLK_INVERTED`、`IS_ENARDEN_INVERTED`、`IS_ENBWREN_INVERTED`、`IS_RSTRAMARSTRAM_INVERTED`、`IS_RSTRAMB_INVERTED`、`IS_RSTREGARSTREG_INVERTED`、`IS_RSTREGB_INVERTED`。匹配本机 Vivado 2025.2 的 [RAMB36E2.v](/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/data/verilog/src/unisims/RAMB36E2.v:195) 为 188935 bytes、SHA-256 `de300b57debd3f31771fa1d7a343f12200658cea6317e4da2a8c3d2f8e61519d`，195–202 行各有唯一、无条件的 `parameter [0:0] ... = 1'b0` 正式声明；该身份已在冻结 semantic property contract 中绑定，当前复核一致。八份冻结 funcsim header 与 [实际 exporter 日志](../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v6/runs/export_graph_v1/control/vivado.log) 均为 Vivado 2025.2 build 6299465，checkpoint 同版；八份导出均无上述 override 或 defparam。实际 768 个属性缺口恰为 96 个 RAM × 8 个反相参数。

对于此白名单，实例有 override 时仍要求已知一位值并与可用 DCP 值一致；没有 override 时，可从上述精确绑定模型的正式 literal 声明取得导出 HDL 的有效默认值。必须同时绑定实际 exporter/funcsim、模型源哈希、声明位置和宽度，确认没有局部原语替代定义、defparam 或配置覆写；不得仅凭文件名/安装目录或写死零。若 DCP 有有效值，仍须与有效 HDL 值一致。DCP `MISSING` 的原始空值保留，输出来源标记为 `MATCHED_UNISIM_DECLARATION_DEFAULT`，明确它是 **HDL 语义来源而非恢复出的 DCP 属性**。未知/错误属性状态、非空 MISSING、宽度/值冲突、模型漂移、条件或非 literal 默认均拒绝；其他参数不扩展缺省规则。

Sol 可直接实现、用缺省值/显式值冲突/模型身份漂移的有限正反例检查后继续 join 和全容量映射，不重导出 DCP、不新增逐步审核文档。最终保留 768 个原始 DCP gap，并分别报告结构/有效参数 join 与全容量映射结果；此规则本身不构成 join 或容量 PASS。

## 证据与最终验收

每次尝试自动生成 src/input/tool 身份 manifest（含实际外部 RTL、DAT/IP/library、fixture、命令/配置和工具版本）、开始/结束时间、退出码、原始 stdout/stderr、guard/RSS/进度和实际制品；对复用输入核对哈希。机器证据应足以追溯每次修复前后身份，不要求每步一份手写正式报告。只在新 sibling 或未冻结准备区修改；不覆盖冻结包和旧日志。

数值规则继续引用 [repair contract](../results/attention_rtl_repair_20261008/repair_contract.md)、[Attention cold V2 独立验收](../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)、[Scorer 有效三行 fixture 独立核验](../results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_actual_fixture_independent_check.json)、[三命令 CPU](../results/attention_rtl_repair_20261008/reviewer_q8_scorer_md_v3_actual_three_command_cpu_acceptance.json)和 [Type 两个冷 CPU 验收](../results/attention_rtl_repair_20261008/reviewer_d2_type_producer_md_v2_actual_two_cold_cpu_acceptance.json)。这些引用内的旧执行门由本合同替代，数值与覆盖要求不变。

最终审核核对当前身份、独立 gold、所有必要命令/断言/协议/资源退出和原始结果，集中记录通过项、首个具体阻塞及未覆盖范围。所有四项实际通过才能称本轮范围完成；部分通过仅更新阶段表和 README/mission 的准确状态，整个 Laya 离线工程仍不得被误写为完成。

## Type 成本恢复补充：同范围继续执行（2026-10-09）

用户在看到完整预算与访存整改两条路线后明确回复“支持 可以进行”；本次选择**先修正验证预算，完成 qtype2/qtype1 两个完整冷请求，访存结构优化之后处理**。本补充由 GPT-6 Astra / xhigh 核定，Sol / xhigh 按其连续执行。它更新同一阶段的 Type 成本条件，不新增逐步源码/编译/运行审核门，不启动 C1 或访存架构整改。[先前集中验收](../results/offline_validation_20261009/final_acceptance.md)及原成本中止结果保持历史原状；本次动态状态继续只记入原[阶段结果表](../results/offline_validation_20261009/stage_results.md)，Type 终态后再集中核对一次受影响结果。

**数值与功能范围不变。** 冻结 DUT、HLS 生成 RTL/IP、真实输入和独立 gold 不改；qtype2、qtype1 的正式验收各使用全新冷进程，不拼接进程状态。必须完整经过 ingress→真实 Controller 的 1 EMB_TYPE＋4 ADD_TYPE，比较 65536 F32、TYPE_ROWS 所选/未用行、状态/owner/IO、全部映射页 sentinel，保留原 R/B hold、协议、首次 done debt 和输入保护。Head15、Ws、Scorer 三项 PASS 按已验身份复用。允许改变未冻结 TB 的 watchdog、被动进度观察、运行入口和必要普通修复，不能跳过 ingress、预装 TYPE_ROWS、改 DUT 或降低检查。

**新预算依据与限额。** 已有 qtype2 trace_05 在 372.9698 s 达到 4456448 clocks、STATE0 AW=111734，qtype1 pilot 给出相同 ingress 速率；64×4096 B 逐字节写需要 262144 次 ingress AW，约 10.5M clocks/880–900 s，因此旧 600 s 和 TB 6000000 clocks 均不足。后续还包括 EMB_TYPE 的 1088 B Q8 读与 4096 B F32 写，以及 65536 个 ADD 输出的两次 F32 读、一次加法和一次 F32 写。主要源码有效搬运量合计 1315904 B，另有解析/状态/控制；不能把 ingress 时间当作完整时间。

冻结 HLS 的 `full_run_task_3_Outline_VITIS_LOOP_190_1_csynth.rpt` 中两输入循环每元素名义最多 36/36 clocks、加法 7、输出循环 48，合计 `65536×127=8323072` clocks。该表**不包含任意 AXI 等待，不是完整请求上界**。以已见 ingress 成本、全部 196608 次四字节 F32 访问及算术/控制开销为依据，本轮采用保守执行帽：**每个必要 trace 或 full 进程 80000000 clocks、7200 s、owned RSS 8 GiB**。其量级为 ingress 10.5M，加上述约 8.32M 名义循环，再为每次四字节访问暂留每字节 40 clocks 的等待预算约 31.46M，合计约 50.3M，再留控制、EMB_TYPE、阶段速度变化余量至 80M；40 clocks 是成本规划余量而非对下游的已测保证。按已见约 11.9k clocks/s，80M 约 6723 s，7200 s 留启动/检查余量。后半段的真实速率将在同进程更新，不能声称已证明其必在帽内完成。旧 watchdog 必须实际改为新值并重新绑定编译身份；只改 host timeout 不构成恢复。

全 Laya 同时一个重工具、CPU 0–3、nice 19、idle I/O、0.2 s owned-RSS 采样、MemAvailable 严格高于 192 GiB 均不变；编译仍 16 GiB/900 s，小型准备/审计仍 4 GiB/120 s。7200 s 是服务器仿真预算，不是 U55C 时间或性能结论。此处是用户授权后依据实测与完整工作量的一次成本合同修正，不是资源失败后无证据地反复加额；进程中及后继普通重试不得自行再增加这两个帽。

**必要串行顺序与 hold 选择器。** 当前 `run_cold.sh full` 要求真实 R ordinal、STATE1/observed 末 B ordinal 及末 AW 地址。优先执行 qtype2 一次完整 no-hold trace，取得最后 TYPE_ROWS 读、STATE1 尾写及 observed 最终写的真实地址/ordinal，并与 terminal trace 总数交叉核对；该 trace 仍以 `TYPE_COLD_TRACE_ONLY_NO_ACCEPTANCE` 明确结束，只提供成本、事务和诊断输出，不能算正式 PASS。随后 qtype2 正式 full，及 qtype1 全新冷 full。只有共同控制流、调用次数、总事务数和 TYPE_ID 地址变换已由实际生成 RTL/trace 支持，才可给 qtype1 复用对应数字 ordinal；正式运行仍须实际命中正确行地址、发生原 hold 并核对真实终态。如果证据不足，允许 qtype1 自身一次完整 trace 后 full，全部串行并逐进程受上述帽约束。不为获取成本新建独立 module 仿真平台，也不临时把定向 hold 改成只按地址触发（observed 启动与终态会重用地址）。普通修复及其必要受影响重跑可连续进行，保留所有尝试，不新增放行文件。

**阶段观察与停止。** 首次 ≤120 s 的 pilot 是同一长进程内的实际进度/RSS 检查，之后至少每 60 s 记录/检查进度。复用已有每 131072 clocks 的原始日志，并可增加被动的 ingress 完成、EMB_TYPE 完成、首个及后续 ADD tile/row 完成观察；不要求重建完整 FSM 证明。阶段判定须绑定实际握手/计数或真实子调用/循环值，不能只看顶层 FSM14 不变而误判停滞，也不能把 clock 自增当作功能进展。

**trace_06 选择器来源说明。** [qtype2 实际长 trace 日志](../results/offline_validation_20261009/attempts/type_qtype2_trace_06/work/xsim.log)已到生成 206 页 dump 的路径，2132.746 s、峰值 858680 KiB、无资源触发；末 STATE1 B 实际记录为 ordinal=262144、AW=`000000060003fffc`、len=0，末 observed B 为 ordinal=6、AW=`0000000700000064`、len=6，可直接用作正式 full 选择器。该次 `TYPE_COLD_TYPE_ROW_R`、`TYPE_COLD_TERMINAL_TRACE`、`TYPE_COLD_FIRST_DONE` 均没有实际输出：`first_done_seen` 的 NBA 唤醒先于原 `#1ps` 终态检查完成，trace-only 故意 fatal 提前结束；R 打印又与 owner monitor 在同一 posedge 更新队列存在观察竞态。原日志和缺口保留，不补写汇总或首次 done debt PASS。R ordinal=131072 的依据是已绑定的真实 ADD 顺序共 `64×(1024 hidden读＋1024 type读)`，以及该 trace 最后实际 `state0_ar=state0_r=131072` 的交叉支持，**不能写成已经观测到最后 R 的地址**。可直接带这组候选进入正式 full，无须仅为缺少汇总重跑长 trace；正式运行必须实际命中原 R 地址＋ordinal 选择及所需 hold，并从 owning accepted-R 记录确认末 TYPE_ROWS 地址，在首次 done 重新检查最终 R/AR 总数、两路末 B 总数/地址/span、全部 debt 和独立 gold。允许将被动 R 记录改在稳定时相读取，并以 `terminal_checked` 等明确同步标志保证 trace/full 结束路径等待原终态检查真正完成；这属于普通 TB 同步修复，数值、端点、DUT 和 hold 含义不变。未命中或任一检查失败仍按真实 FAIL 保留。

连续 120 s 没有任何已选语义进展（AXI accepted/delivered 计数、实际阶段、子任务退休或行/元素计数均不变），或者日志/仿真周期本身不再前进，应停止自己拥有的进程并保存最后状态；短暂纯算术窗口由真实子循环进展区分。ingress 后和每个完成的 ADD tile 用实际剩余工作量/近期阶段速率重算剩余成本；若连续两个相隔至少 60 s 的有效观察窗口均表明剩余工作无法在当前墙钟或周期帽内完成，按成本停止，记录已完成阶段和剩余范围，不原样加额重跑。进入新阶段尚无足够速率样本时明确“未定”，依靠语义进度与硬帽继续，而非反复停下等待人工审核。协议/数值/断言失败仍按真实 FAIL 保留，只有预算/停滞原因单列资源或成本停止。
