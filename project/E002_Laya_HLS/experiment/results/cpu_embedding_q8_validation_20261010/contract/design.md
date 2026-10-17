# CPU Embedding、FPGA LN 与 TM1 Q8：授权执行合同

状态：**AUTHORIZED / IN_PROGRESS**，2026-10-10，GPT-6 Astra / xhigh。依据用户“支持 开始任务”，执行[阶段计划](../../../mission/next_stage_plan.md)的三个任务，按依赖连续推进。本文补齐该计划的接口、准入、owner、错误和验收细节；未重述部分直接继承计划。Sol / xhigh 为唯一实现/运行负责人，Astra / xhigh 负责实质合同变更及阶段末集中验收。普通实现、编译、测试台和脚本修复不另设审批。新阶段只维护[一张动态结果表](../stage_results.md)，各次机器日志/manifest 另存；不改旧冻结证据、Laya 顶层索引或复用 M002。

## 0. 当前优先级与准确度/性能判定（2026-10-10修订）

用户最新指令优先：**先完成硬件计算性能与推理准确度验证并解决实测瓶颈，暂停下一轮整体OOC、P&R与专项时序优化。** 允许为功能验证进行必要HLS→RTL/IP生成、静态编译、RTL运行、普通实现修复及受影响回归；§6.2.1等价rank实现和原失败证据保留。历史资源与频率缺口不删除、不改判通过，但不再作为本轮功能/周期性能或Task3连续链验证的前置条件。后续物理实现重新安排前不自动重启整体综合。

“准确度”分为三种证据，逐项记录，不能互相代替：

| 维度 | 本阶段可执行判据与范围 |
| --- | --- |
| 数值正确性 | 使用真实GGUF/固定真实请求的独立oracle；CPU raw及Task2量化、中间值和全部输出保持原逐位检查，LN沿用§5误差线且基本FP规则不变。完整图CSim、前端RTL、隔离ACT/QKV RTL、真实producer连续链、整网RTL分别判定 |
| 端到端决策一致性 | 仅对实际完整执行的请求，用原生产结果帧/解码规则独立核对最终logits/分数、有效候选及最终决策，报告后端、请求数、逐项一致/首差及失败恢复。检查点一致或局部tensor通过不能替代最终结果核对；CSim结论不能标为RTL/板上决策一致 |
| 任务数据集准确率 | 需要已确定的数据集、独立标签、评估方法和基线；本轮固定fixture/四请求不构成该证据。不新造数据集、样本数、准确率门槛或容差；未执行则明确NOT_RUN，不宣称业务准确率达成 |

本次修订依据包含v4完整图CSim的141检查点/18094384个F32逐位一致、完整B1/S128前端RTL的131072项norm逐位一致，以及隔离原型局部结果；它们均只归属[阶段表](../stage_results.md)所列身份和覆盖。真实producer连续链、整网RTL及数据集准确率须由各自实际证据关闭。最终结果尚未独立解码核对时，保留“数值覆盖已测、决策一致性待证”，不把三次成功请求折算成数据集准确率。

性能以实际RTL周期为主要证据，trace-off吞吐、完整LOAD/RUN和各阶段停顿均绑定同一实现；XSim墙时只衡量验证成本。保留原QKV稳态一group/clock与完整请求50ms目标，不增设新局部性能数值。数值PASS与性能目标判定分开：目标未达、前端周期/搬运缺口未解决时，不能称性能整改完成。150MHz仅为条件换算，50ms@150MHz=7.5M cycles并非已实现预算；CPU、传输、其他层及Host仍需计入完整请求。A6000已有25.047/25.224ms P50/P95属于另一模型/BF16/B2-S94/K_pad3，按[阶段计划](../../../mission/next_stage_plan.md)保留比较边界，不直接算当前Q8_0/S128/16槽的加速比，也不更改原50ms目标。

## 1. Task1 固定范围与实现边界

首个正式 RTL 是 B1_from_b0_S128，request_id=3、generation=1、B=1、S=128、hidden=1024。CPU 只生产输入 token Embedding；所有128行包括 padding token 均从真实 GGUF 查表。FPGA 执行完整 LN_EMB，后续所有 LayerNorm、EMB_TYPE、Encoder、Decision、scorer、ACT 的职责不变。B2/S128 布局和失败/恢复用 CPU/CSim 覆盖，不能称作 B2 RTL 通过。

薄入口固定为 `laya_cpu_embedding_ln_chain(io, aux, state0, state1, observed)`。IO=32768B，STATE0=16920576B，STATE1=16919104B；AUX 沿用新包实际清单。入口不接 embedding BO，不回退 EMB_TOKEN，不写 LYRS 成功帧。IO/AUX/STATE0 只读；STATE1 仅合法 LN 输出地址可写；observed 为本文定义的1728B诊断输出。生产地址、256B 描述符逐字段 ABI、CRC32C、Host 同步和输入持有顺序完全采用阶段计划 §1，不再重定义另一份布局。

CPU producer 从 GGUF `tok_emb.weight` 的32个 Q8_0 group/row 解码：每组34B，half scale 扩展至 F32，scale 有限且非负；q 为 signed INT8，限制[-127,127]；以独立 binary32 乘法生成 `float(q)*scale` 并检查有限。不得从 oracle/CSim/DUT dump 生产 raw。独立参考从真实 token/GGUF 重算，并与冻结 raw gold 交叉核对；CPU raw 和上传 STATE0 的131072项必须逐位相等。保留 signed zero/half 次正规，不做 scale canonicalization。

实际 GGUF：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf`，SHA256=`6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。冻结独立参考根为 `results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/`，实际请求源为同级 `dut/inputs/`。新源码/profile/CPU producer 进入新 source/build closure 和包/request 绑定；model/numeric 语义保持，layout tag 由实际规范 preimage 计算，不能手填旧 tag。

## 2. 单一准入点、错误优先级及不变式

将原 `full_parse_request` 拆为共享 decode/validate 与 admission/commit，新增入口在两者之间验证 CPU raw 描述符。原入口继续复用共享规则。禁止先调用会更新 session/回收 owner 的旧 parse 后才检查描述符，也不复制巨大 FullRuntime 回滚。采用显式引用和布尔参数，不引入可空 metadata 指针作为综合控制捷径。

每次调用先清 invocation-only 诊断、错误、任务/op/claim/layer 计数和 expected-source 授权，request_valid/model_header_valid=false；保留旧 inputs/session/last_accepted_id、owner spec/identity/epoch/coverage、payload，直到准入成功。被拒请求不能继续使用旧授权，也不能把上次任务数报告成本次任务数。输入身份字段显示最近一次真正接受的 inputs；diagnostic 身份只反映本次可信 LYRQ 固定头。

唯一规范优先级：

1. 原 LYRQ header/tag/shape/directory/payload/token/mask/marker/qtype/model-header 检查，顺序和原 status/detail/bad_element 不变；然后原 session 单调性检查，仅检查不变更。
2. 描述符可读范围 → magic → version/bytes/mode → flags/reserved → descriptor CRC → request_id/generation → 四 tag → B/S/hidden/dtype/source → base/strides → payload/extent/BO范围 → request_frame_bytes → request CRC。组内按下表列出的偏移升序检查。同一请求多错时只报告最先错误。
3. 全部通过后才调用原 recycle/soft_reset（需先满足原无活跃 owner 条件），再一次提交 inputs/session/last_accepted_id、request_valid/model_header_valid。回收仅清 metadata，不覆盖 Host 已写 STATE0。recycle/soft_reset 失败保留其原首因，不能提前推进 accepted id。旧 owner 及会话不因描述符失败而改变。
4. 准入后 claim HIDDEN0 并扫描 raw；raw 非有限/CRC 错属于执行失败，已经消耗本次 request_id，禁止 LN 并 cleanup。随后只能用更大 request_id 或合法新 generation 恢复。

CPU profile 专用 detail=`detail(0x0a,0x01,reason)`，不新增 Status 或 Op 枚举。描述符错误的 bad_element=UINT64_MAX；具体字段由 descriptor_error_offset 给出描述符相对字节偏移，不占用 tensor 元素索引。全局成功 bad_element 同为 **UINT64_MAX**。

| reason | Status | 含义；descriptor_error_offset |
| --- | --- | --- |
| 1 | E_BUFFER=5 | IO 无法覆盖[20480,20736)；0 |
| 2 | E_ABI=1 | magic 不是 LYER（含缺描述符）；0 |
| 3 | E_ABI=1 | version!=1、bytes!=256、mode!=1；依次4/6/8 |
| 4 | E_ABI=1 | flags、reserved u32（offset108）或尾部保留字节非零；12/108/首个160..255 |
| 5 | E_ABI=1 | descriptor CRC32C 不匹配；156 |
| 6 | E_PROTOCOL=7 | 与 LYRQ request_id/generation 不同；16/24 |
| 7 | E_MODEL=2 | model tag 不同；32 |
| 8 | E_ABI=1 | numeric/layout/build tag 不同；48/64/80 |
| 9 | E_SHAPE=3 | B/S 不同于已验证 LYRQ 或 hidden!=1024；96/98/100 |
| 10 | E_ABI=1 | dtype!=1 或 source_selector!=0；102/104 |
| 11 | E_BUFFER=5 | base!=0、row_stride!=4096、batch_stride!=4194304；112/120/124 |
| 12 | E_BUFFER=5 | payload/extent 不等于规范公式，或实际 STATE0 不能覆盖 extent、算术溢出；128/136（BO/溢出归136） |
| 13 | E_BUFFER=5 | request_frame_bytes 不等于已验证 LYRQ 实际帧长度；144 |
| 14 | E_ABI=1 | request CRC32C 不匹配；148 |
| 15 | E_NUMERICAL=6 | raw 首个 NaN/Inf；offset=UINT32_MAX；bad_element=(b*S+row)*1024+col |
| 16 | E_ABI=1 | 完整有限 raw 扫描的 CRC32C 不匹配；offset=UINT32_MAX；bad_element=UINT64_MAX |

原 owner/地址访问/算子错误保留原 status/detail，不重编码为上述 reason。描述符错误 error_stage=1、error_operator=IO_VALIDATE(0x84)、error_task_id=0；原 LYRQ/model/session parse 错误 stage/op/task=0。raw import/claim/cover/publish 错误 stage=1、op=IO_VALIDATE、task=0。LOAD_LN_PARAMS/LN_EMB 错误保留真正 stage/op/task_id。IO_VALIDATE 仅错误归属，不派发或退休算子任务。

raw 按 batch/row/col 扫描，每次读取一个完整 F32 后更新已读元素/字节和CRC；若该值非有限立即停止，计数包含坏元素，首因优先于尚未完成的 CRC。只有完整扫描才 scan_complete=1；actual_raw_crc 对已读前缀也作标准 final XOR，空前缀为0。只有 scan_complete 且有限且 CRC 相同才 raw_verified=1，才允许 cover/publish。

## 3. owner 生命周期和固定计数

导入是非算子 action：claim成功后 imports_started=1，完整成功 publish 后 imports_committed=1；不增加 tasks_retired、last_task_id、任何 op_calls，不移位原枚举。使用原生产 full_claim_owner/full_cover_owner/full_publish_owner，不直接设置 READY/valid/coverage。HIDDEN0 为 `{HIDDEN,bank0,new_epoch}, region0,stage1,layer255,batch255,TOKEN,row0=0,rows=S,width1024,F32`。epoch 通过相同物理 owner 的 max_claimed_epoch+1 产生，冷例1；溢出遵循原拒绝规则。全部 raw 验证后逐 batch 登记 rows[0,S)，再 publish。

共享前端后半段固定 `load_gamma(1) → norm(LN_EMB) → full_release_owner(old_hidden) → checkpoint("embedding_norm")`。raw checkpoint 可用于 CPU 独立比对，但不得改变设备读写。失败输出 spec 统一为零初始化，不把未发布 HIDDEN0/部分 HIDDEN1 作为成功输出；只有完整尾段成功才把 HIDDEN1 复制到薄入口输出 spec。

| 冷 B1/S128 终态 | 固定期望 |
| --- | --- |
| 任务/op | tasks_retired=last_task_id=9；EMB_TOKEN=0、LOAD_LN_PARAMS=1、LN_EMB=8；Encoder/Decision=0 |
| ownership | owner_claims=3；owner_leases=0（此为 exclusive lease，不是read acquire数）；所有readers=0；incomplete=0 |
| HIDDEN0 | FOUND=1；id=1,bank0,epoch=max_epoch=1；上述spec；FREE(0),valid=0,coverage全0；真实raw payload仍完整 |
| LN_GAMMA0 | FOUND=1；id=0x2a,bank0,epoch=max_epoch=1；region0,stage1,layer255,batch0,BATCH(2),row0=0,rows1,width1024,F32；READY(2),valid=1；coverage word0=1，其余0 |
| HIDDEN1 | FOUND=1；id=1,bank1,epoch=max_epoch=1；其余spec同HIDDEN0；READY(2),valid=1；coverage words0..3=0xffffffff，其余0 |
| owner identity | 三者完整 B1/S128、request_id3/generation1 和新四tag全部匹配；高32位同样检查；slot为真实查找值且三个不同，禁止由TB预置 |
| 导入 | admitted=descriptor_valid=raw_verified=scan_complete=1；imports_started=imports_committed=1；raw_elements=131072、raw_bytes=524288、import_rows_covered=128；三对CRC各自相同 |
| 执行 | request_valid=model_header_valid=1；global/last_exec/cleanup均OK；bad_element=UINT64_MAX；phase=8；error_stage/op/task=0；cleanup_attempted/completed=0 |

B2/S128成功同样3 claims、17个算子任务=1+16、0 EMB_TOKEN，导入262144项/1048576B/256行。HIDDEN覆盖words0..3及32..35为全1，其他0；gamma仍仅bit0。持久请求沿用epoch递增，不能重新写死cold epoch1。

预准入失败：当前调用 tasks/op/claims/imports/covered 均0，未接受且无 cleanup；owner/session/last accepted保持调用前值。已准入 raw失败：claim=1，imports_started=1、committed=0、covered=0，任务/op=0；HIDDEN0最终INVALID、valid=false、coverage=0、readers=0，其余不新增claim。成功导入后gamma数值故障：claim=2，tasks_retired=last_task_id=1、LOAD_LN_PARAMS=1、LN_EMB=EMB_TOKEN=0；HIDDEN0保持READY/全coverage，gamma INVALID且coverage0；没有新HIDDEN1 claim。保持LOAD_LN_PARAMS原数值首因，不用cleanup结果覆盖。

cleanup只在准入后的失败执行，撤销FILL/EXCLUSIVE，不撤销已READY的owner；READ/非零readers按原E_INTERNAL处理且单独记录cleanup错误。任何失败均禁止成功发布，失败后下一合法请求的回收与重新导入必须可恢复。

未来混合完整graph删除的仅EMB_TOKEN任务：B1/S128总任务18895−8=**18887**；B2/S128为37158−16=**37142**；QUANT分别962/1924，Encoder28+Decision2不变。gamma首故障为1个退休任务，不能套旧17。保留原LYRS accepted_input_elements=`2*B*S+33*B`含义，raw计数另列；原accepted failure flags9、success11、可识别预准入reject flags1及失败零logits不变。导入不新增operator任务，也不能为迎合DUT改变这些期望。

## 4. observed ABI：CFO1，432个u32

LE、全部64位低字在前。words0..399继承[原字段布局](../../../include/laya_frontend_observed.h)：global0..63，三个112-word owner块位于64/176/288；MAGIC改为0x314f4643（CFO1）、VERSION=1、WORDS=432。保留global54..63和owner40..47为0，owner48..111仍为64个coverage words。所有字段来自本次真实runtime/检查结果，不是硬编码expected值。输出仅432 words，后续guard不写。

| word | 字段/语义 |
| --- | --- |
| 400 | profile=1（所调用入口的固定profile） |
| 401–405 | descriptor_valid、admitted、imports_started、imports_committed、raw_verified，分别为0/1 |
| 406–407 | expected_raw_crc、actual_raw_crc |
| 408–409 | raw_bytes_scanned u64 |
| 410–411 | raw_elements_scanned u64 |
| 412 | import_rows_covered，累计成功cover的batch行数 |
| 413 | descriptor_error_offset，非profile描述符错误时UINT32_MAX |
| 414–415 | import_bad_element u64，非raw数值错误时UINT64_MAX |
| 416 | reached_phase：0原parse、1descriptor、2admitted、3claim完成、4scan、5publish完成、6gamma、7LN、8全部成功；失败保留所到阶段，cleanup不覆盖 |
| 417–419 | first_error_stage、first_error_operator、first_error_task_id；成功为0 |
| 420–422 | cleanup_attempted、cleanup_completed（仅实际调用且OK为1）、scan_complete |
| 423–424 | request_crc_valid、descriptor_crc_valid |
| 425–426 | expected_request_crc、actual_request_crc |
| 427–428 | expected_descriptor_crc、actual_descriptor_crc |
| 429–431 | 保留0 |

descriptor_valid只有全部descriptor/request绑定检查完成才置1。expected CRC在完整descriptor可读并解码后填，未读取为0；actual CRC在相应计算完成后填，未计算为0。所有新诊断每次调用初始化，不携带上次值。最后一次observed B退休前不得ap_done；诊断并不代替外部AXI实际覆盖与债务监测。

## 5. Task1 验证、预算与证据范围

连续执行CPU生产/独立参考 → strict CPU/CSim（含B2布局、描述符反例、raw故障、gamma首因及持久恢复）→ 新HLS → 端口/owner结构核查 → 编译/≤120s pilot → 有依据的正式冷RTL。反例至少逐类覆盖上表1..16（CRC以外字段变异应重算descriptor CRC以触及相应检查）、旧request/generation、descriptor失败保留session/owner、raw错误消耗id、之后更大id恢复。CPU/CSim可直接改变FullMemory字节容量测试bounds；固定capacity薄RTL不伪称可运行动态容量case。

完整RTL raw/STATE0逐位检查；LN输出131072项有限并满足 `abs(dut-ref) <= 1e-4 + 1e-4*abs(ref)`，报告逐位相同数量、首差、最大绝对/相对误差。原相邻归约树、binary32 RNE/独立操作、eps=0x3727c5ac 不变；禁用FMA/重结合/FTZ补偿。真实基本FP运算若触及已有FP119的33例不符则按FAIL留首差，不能被末端容差掩盖。

外部端点分别记录导入和LN读取的实际地址/元素覆盖；两个阶段各覆盖完整raw，不能共用一次覆盖冒充两次。STATE0地址524284的hold必须命中**LN阶段最后R**，并另hold STATE1最后B；首次ap_done要求io/aux/state0/state1/observed五口所有physical与adapter debt=0。检查全BO输入保护、输出外sentinel、owner/spec/全identity/coverage/readers及描述符/诊断guard，退出0且完整自检PASS、无ERROR/FATAL/保护触发。不能从pragma推断端口真实512-bit。

工作TB此前仅修正success bad_element断言为UINT64_MAX，当前修正哈希 `bd43eac110bf2ab9813dff89459309cf1a96b0fe753eea693076c64ba0dd27a7`，不等于新RTL通过。旧run03冻结TB及旧集中验收保持原历史身份，不回写覆盖。

服务器/单重工具/CPU0–3/nice19/idle I/O/0.2s聚合RSS/严格MemAvailable>192GiB及停止条件全部继承阶段计划。Task1首次正式RTL的有限wall/cycle帽现由**本次**HLS调度+120s pilot及已核对可复用的旧LN分阶段实测，按下节一次落实；Sol连续执行，无需新签字。旧17任务、旧全链3686s/33.78M总估计或旧75分钟提案不直接作为新预算。8GiB RTL RSS不变，正式运行触发保护后不得无修复只加帽重试。Host/CPU raw/同步/kernel/完整端到端分别计时，无板卡仅报告离线harness与仿真。

### 5.1 首pilot后的正式冷RTL预算（2026-10-10，一次细化）

**可直接执行完整B1/S128冷例，固定4300s墙钟、40000000 clocks、8GiB owned RSS，任一到帽即停止。** 不要求先获得HLS完整top的有限latency，也不另加一次1200s成本trace。对象是 `attempts/cpu_front_hls_03` / `cpu_front_static_03` 对应build `2792695f489c751a7fec9c7d98638ece` 的真实五口RTL，所有原数值/owner/独立gold/hold/首次done检查保持。既有 [首pilot](../attempts/cpu_front_pilot_01/cost_stop.json) 原日志、guard及当时NOT_RUN_COST判断保留，不回写为PASS。

成本依据的复用范围已轻量核对：

- 新pilot在120.3619015s内到2203648 cycles，真实导入29271/131072 F32，未进LN但持续推进；直接比例为538.966s、9867669 cycles。首次预算上取600s、10.5M cycles，包含该pilot已承受的冷准入/启动开销，不把导入速率当LN算术速率。
- 新 `cpu_front_hls_03/work/hls/syn/report/layernorm_row_arithmetic_csynth.rpt` 与旧 `results/encoder_decision_validation_20261009/attempts/frontend_chain_hls_01/work/hls/syn/report/layernorm_row_arithmetic_csynth.rpt` 的逐循环调度一致：初始化2 cycles/项、均值/方差树每加7 cycles、差平方10 cycles/项、最终norm15 cycles/项。合法1024宽的树节点数为1023；报告的动态循环巨大max和父级`?`不代表该固定形状必然不可估计。
- 新旧五类FP的Verilog wrapper（add/sub、mul、div、sqrt、compare）去top命名前缀后一致；对应VHDL在同样改名并合并工具生成的字符串换行后也一致。STATE0、STATE1、AUX的m_axi RTL及full_write去top前缀后一致，数据宽度均32bit。LN整模块并非逐字相同：原共享乘法/比较端口在新版成为本地实例，full_read也新增导入路径；故只复用局部调度、FP语义和已核对接口的分阶段成本，不宣称新全top等价或新RTL已通过。
- 旧真实 [LN采样](../../encoder_decision_validation_20261009/attempts/frontend_chain_run_03/phase_progress.jsonl) 已测两段7行/110.012s（约15.716s/行）及两个约110.013s的块写/下块读窗口。预算取17s/行、125s/窗口；按8个窗口保守包含首读、7次块间写读及最终写排空，另给60s gamma/owner/diagnostic余量。

据此初始条件估计 `600 + 128*17 + 8*125 + 60 = 3836s`，4300s帽保留464s额外余量。周期估计 `10.5M + 128*45000 + 8*2.2M + 0.5M = 34.36M`，小于40M帽；45000 cycles/行覆盖上述固定形状LN调度，2.2M/窗口高于旧实测约1.93M。它们是有证据的保守工程估计，**不是严格上下界或成功保证**，不借旧结果替代新数值/协议验收。

Sol直接进行一次新冷启动正式运行，保留完整输入/源码/工具manifest。每60s保存wall/cycle、import已读元素、LN独立读、实际row start/done配对、树步骤、norm写字节/响应及剩余阶段ETA；进入新版LN后逐步以新版真实行和写读速率替代旧估计。旧系数只用于尚未实测的阶段，不能拿本次导入cycle/s推定FP阶段wall速率。运行期间连续120s无真实语义进度，或连续两个相隔至少60s的有效样本预测总wall>4300s或总cycles>40M，依原规则停止留证；算术树推进属于有效进度，AXI静止本身不判停。

首120s pilot是预定的短采样终点；本节是新阶段首次正式成本帽落实，不是失败正式运行后的无理由增额。若本次正式运行触发上述停止/资源帽，则保持实际COST_STOP/NOT_RUN_COST范围，不原样提高帽重跑。若首次ap_done到达，仍须完整131072项norm、全部owner/coverage/guard/hold及所有五口债务检查通过才可登记RTL PASS。Task2轻量准备可独立继续，重工具仍全树仅一个。

### 5.2 前端性能缺口与后续测量边界

已完成的v4 cold03按[原阶段观察](../attempts/cpu_front_rtl_03/phase_observations.json)为31,158,417 TB cycles，起点是复位释放，包含launch/AXI-Lite及仿真反压，并非单独测得的AP接受→done。假设150MHz换算207.7ms，为完整请求50ms的约4.15倍；导入约9.69–9.71M、LN首算术→128行约19.37–19.38M（含块流转）、最后行→norm写全约1.38–1.40M。该测试口径已暴露必须解决的前端周期和搬运瓶颈，不能将数值通过等同于性能通过，也不能把这些采样窗口当作纯LN算术下界或板上延迟。

先复用已有结果定位导入CRC/读事务、LN算术、块读写与排空的占用；后续受影响运行以被动事件计数补齐精确起止、有效字节和停顿，区分相交窗口，不另启无关诊断报告或为填指标原样重跑已通过冷例。保持CPU只做token Embedding、LN全部在FPGA、导入与LN两次真实消费及原数值/owner检查。实现等价优化按原授权连续进行；涉及架构/接口/数值的实质修改仍由Astra集中修订受影响合同。沿用4300s/40M/8GiB和原保护规则，不因性能问题加帽重复运行。

## 6. Task2 固定原型边界

隔离原型名 `q8_tm1tn8_gs32_512`，实现放在现有 Q8 模块下 `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/{source,rtl,tb}/`，设计和动态结果只引用本文及本阶段表，不复制逐次设计/审核包。采用TM1/TN8/GS32，完整LOAD_W→真实输入加载/quant→dot/restore/PS→bias→真实512-bit输出/B响应。首版仅支持ACT K256/N2/rows1与Encoder layer0 QKV K1024/N3072/rows1或4；这些是完整K/N，rows4按四个TM1顺序处理且复用同一W。

复用[Q8现行模块设计的“命令、端口与状态”“算术、bank与流水落实”](../../../vivado/module_design/q8_linear_and_restore/source/design.md)中真实WeightKey/BO布局、原128-word描述符字段、模型头检查、session/task/epoch/claim/first-error语义与独立参考规则；其历史审批门、TM4尺寸、32-bit输出、完整模型测试扩展及旧性能承诺不适用于本原型。新descriptor word0=0x31543851（LE字节Q8T1），word1=1；其余字段含义复用上述布局，形状只接受本节两类。旧Q8J magic拒绝。所有窄字段先检查原始高位再转换；source的全身份/row/spec来自独立fixture，不从待验证owner自抄。

每次ap_ctrl_hs只处理LOAD_W或RUN_TILE；首LOAD绑定session，后续命令同request/generation/四tag/B/S，切换session须在债务清零后reset。LOAD task_id=last+1；RUN quant task_id=last+1、linear task_id=last+2；实际开始的失败任务消耗id和已claim epoch，前置拒绝不消耗。缓存metadata reset为INVALID，payload不批量清零。全部W校验后W_READY，实际quant完成才A_READY；PS及局部目的全部计算/bias且写B退休后才发布。局部QKV行输出不是全128行/全层owner发布。

### 6.0 首版外部fixture来源准入（2026-10-10细化）

首版采用**固定、独立证据绑定的外部fixture重放profile**，保持现有128-word descriptor和端口，不新增一个由同一调用者随意填写的“expected owner”。唯一来源为冻结 `oracle/B1_from_b0_S128/` 的 `act_hidden.f32.bin`、`embedding_norm.f32.bin`，取下表明确切片。硬件支持的session固定request_id=3、generation=1、B=1、S=128，四tag精确匹配实际新模型包编译常量；不能在首LOAD时接受任意非零身份后仅做descriptor与自身session的比较。

| fixture / consumer | 独立固定的来源规格 | RUN允许的context |
| --- | --- | --- |
| ACT / LIN_ACT_FC2 | HEAD_WORK(id10), bank0, region2；外部fixture版本epoch1；语义节点act_hidden，stage6/layer255，BATCH/F32，batch0、row0=0、rows1、width256 | WeightKey(12,255)，op0x37、stage6/layer255，batch0、row0=0、rows1、K256/N2 |
| QKV row1 / LIN_QKV | HIDDEN(id1), bank1, region0；外部fixture版本epoch1；语义节点embedding_norm，stage1/layer255，TOKEN/F32，batch0；完整参考节点128×1024，只导入row0=0的一行视图 | WeightKey(1,0)，op0x30、stage2/layer0，batch0、row0=0、rows1、K1024/N3072 |
| QKV rows4 / LIN_QKV | 同上，导入rows0..3的四行视图；source epoch仍为同一不可变fixture的1 | 同上但rows4；不能由row0+rows<=S自行接受其他切片 |

这里source epoch1明确表示**本隔离profile的外部fixture注册版本**，不声称它等于冻结完整图的原producer owner epoch。尤其生产act_hidden来自ACT_HIDDEN上的BIAS_GELU_ACT原地变换，存在真实epoch递增；当前二进制参考文件没有可供本top读取的owner状态，不能据descriptor中的1伪称已经验证该原owner。当前top不创建/强制一个外部READY owner，也不证明其实际READ/coverage/lease；它验证的是上述固定输入profile和本地真实W/A8/PS/dst生命周期。Task3必须从实际producer与runtime元数据取得完整owner/spec/epoch/coverage，不得用本节静态表替代连续链验证。

独立fixture maker在现有manifest中登记：profile版本、request/generation/B/S、四tag与包身份、原节点路径/完整文件hash、选中行范围/字节偏移/长度/切片hash、上表来源语义规格及注册epoch1。这些期望由固定case定义和实际源文件生成，**不得从待测descriptor反读复制**。现有Host/TB在launch前逐字核对实际输入BO有效区域与该切片、检查其余sentinel，并在命令终态前保持输入不可变；activation地址可按已有64B对齐/span规则搬移，物理base不是来源身份。用于负例的受控数值扰动另记派生输入hash，不伪称原冻结输入。无需把hash塞进descriptor或增加硬件hash扫描；报告须保留“外部fixture provenance由独立harness确认”的边界。

准入实现必须用独立常量/显式分支核对所有ABI可表达的来源字段：id、bank、region、epoch、request/generation/B/S、batch、row0/rows、K/N、consumer op/stage/layer/WeightKey和四tag；未在ABI中独立传输的来源stage/layer/row_space/content按上述profile静态定义并登记，不能宣称这些是从外部owner读取后逐字段验证。`valid_ref()`仅能证明编码合法，**不能**替代`src.epoch==1`与固定来源ref/spec核对。LOAD继续要求src=NONE及原零字段，不读取activation；RUN任一来源不符在quant开始、任何新A8/PS/dst claim及activation读之前拒绝。source epoch0/2/其他合法非1值均拒绝，不把其当成新的合法producer。

错误约定保持现有码：原ABI/tag/基本形状/WeightKey优先级不变；在session绑定前，固定B/S不符为E_SHAPE/detail(7,op,5)，固定request/generation不符为E_PROTOCOL/detail(7,0,4)。随后保留原session/task顺序检查；RUN来源ref/epoch/切片不符沿用E_BUFFER/detail(4,src.id,4)，bad_element=UINT64_MAX、done_task=0，无任务/epoch消费，本地W/会话状态保持。原W/A8/PS/dst新epoch与task递增规则不变；同一fixture可在后续合法task重复读取，source epoch仍1，不能跟随PS/dst递增。

受影响负例须使用独立期望检查至少：只改source epoch为2、0及其他合法大值；只改ACT bank、QKV bank/id/region；把QKV row0改为仍在S内的1；把首LOAD/RUN request或generation改成另一个非零值、B改2、四tag单字节改变；以及拒绝后原合法下一任务恢复。核对零activation读、零新claim/retire/arith issue、原W/session未变和准确status/detail，不以descriptor回显作为通过条件。无需新增审核门、观察接口或报告包；并入既有CPU/CSim及后续联合RTL接口自检。

### 6.1 固定存储与供数

只为ACT/QKV所需最大形状分配，禁止复制TM4最大模型缓存：

| 存储 | 逻辑容量与端口合同 |
| --- | --- |
| W q | 8 banks ×12288×256bit；每bank每issue读一次，分别提供一个输出列的32个q |
| W half scale | 8 banks ×12288×16bit，同q地址；每bank每issue读一次 |
| 输入F32 | 8 banks ×128×32bit，单行最大1024；一个512-bit输入beat分两拍写8banks |
| A8 q/scale | 最多4行×32×256bit和4行×32×16bit；单个buffer保留本RUN已量化的全部行，同一个group读一次后广播8个输出lane |
| PS | 8 banks ×384×32bit，1读+1写端口；同时最多一个未提交版本占用某tile；另有8×384 lane_bad位 |
| bias | 8 banks ×384×32bit；bias_kind来自真实WeightKey，ACT只2列有效 |
| arithmetic结果预留 | 当前实现Q=35个group slot（§6.6，限定验收见§6.9）；每slot保存8个F32 next-PS、8lane有效/错误及完整tag；发射前原子预留，不能返回时才找空间。旧Q32实测保留原身份 |
| 数值trace | 独立D=4个256bit group trace slot，仅选中的(r,n)预留；按§6.3.1由专用32bit observed writer完成全部真实B响应才退休，FIFO交接不释放slot；trace开启会产生真实停顿，性能以关闭trace的同一制品测量 |
| 输出pack/writer | 当前实现每口一个64B填充pack、一个独立64B事务寄存器及至多一个已接受tile的32B拆分暂存（§6.7，限定验收见§6.9）；仍仅一笔未B事务，首版AWLEN=0；后续恢复OOC时全部纳入 |

W地址 `tile*G+g`，G=K/32，QKV T=384、G=32，最大地址12287。原生产双q shard布局保持：对shard s的相对512-bit beat b，u=floor(b/4)、pair=b%4、tile=2*floor(u/G)+s、g=u%G；beat低/高256bit分别写bank 2*pair/2*pair+1。scale beat b含32half，依j=0..3、lane=0..7写bank lane/address 4*b+j；单写口至少四拍解包。首版按q0→q1→scale→bias串行加载；报告这些实际时间之和，禁止以端口峰值假定重叠。q/half字节与GGUF逆重排结果逐位一致，padding列仍按原LOAD合法性检查。

无双W、双A或双PS。rows4先逐行复用单行F32输入缓存做8lane两遍量化，将全部四行A8保存在同一buffer；全部量化成功后才退休quant任务。随后linear按r/g/tile顺序发射，复用单行PS；[HLS发射循环](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/q8_tm1tn8_joint_dma.cpp)只在全部行之后发送finish并等待writer completion，没有逐行输出B barrier。前行某tile的最后group真实commit时，完整result/row/mask/bad已复制到独立tile输出寄存器；该tile的busy按原c+2规则释放后，下一行g0可用oldPS=0并重置本tile的bad_lane，不能覆盖尚未commit的同tile。允许这种逐tile安全交接与前行输出尾部重叠；不增加另一PS/request上下文，不放宽全命令writer/trace/物理债务清零。全部四行成功才退休linear。原“无下一行计算与本行输出重叠”表述与实际实现不符，本次据源码和84实测纠正，不据数值PASS追认旧条款已满足，也不新增行barrier。真实RAM原语/位宽/端口及映射仍须由对应身份的生成/OOC证据确认；当前新OOC暂停，不把数组维度或pragma当作物理证明。

### 6.2 算术、反馈、预留和首错

256个signed8×signed8乘法采用一乘法一DSP意图，8个32项相邻精确整数归约树。允许从暂停C1的[六级integer tree源码](../../../vivado/module_design/q8_linear_and_restore/c1_pipeline_stage_v4_clocked_units/rtl/c1_integer_tree_service.sv)仅复用“products→16/8/4/2/1”六个真实寄存边界及符号扩展方法，缩为8lane/单A行；新tag/oldPS宽度按本原型实现。旧C1顶层、Q64/D4 owner、writer bridge和v3/v4脚本不接入或运行，不继承其18-cycle/F21/流水PASS。算术局部边界测试含-128、-127、0、127及精确dot；这不改变生产quant/模型q的原合法范围。

每个有效lane严格执行：`dotf=F32(dot)`；`product=F32(sa*sw)`；`term=F32(dotf*product)`；`next=F32(oldPS+term)`。需要8个转换、16个独立乘、8个加的服务能力；所有half→F32及每个中间结果按原语义检查。group0 oldPS=+0且仍做一次加；group依升序，不树化group、不FMA、不FTZ；最后group全部commit后，bias_kind=1才另做一次bias加，bias_kind=0不加额外+0。量化保持 `d_full=F32(amax/127)`、未舍入d_full求inv、F32乘后roundf远离零、scale保存F16 RNE；不先用保存half求inv。

发射顺序row→g→tile。tag至少携带当前task/epoch、row、g、tile、8lane mask、last_g及预留slot/序号，所有标签与数据同拍推进；valid但未ready不能改变输入或计数。无阻塞FP管线只在预留Q slot及所需D slot后发射，固定返回只能写其已预留slot。返回经过真实完整八lane收齐和首错检查才变成可commit，按issue顺序每拍最多commit一个group；commit真实写8个PS bank，随后释放slot。单tile busy从issue保持到PS commit，最早在commit cycle c之后c+2再次issue同tile，不作旁路猜测。

实际安全反馈F和全路径II I由新流水/PS RAM/commit一同测量，下一group同tile间隔至少max(T*I,F)。QKV T384时目标持续一group/clock，ACT T1显式反馈等待。结果容量按§6.6修订；若容量或FP/输出实际服务率仍限制II，报告该瓶颈，不把integer tree的II1标为全路径II1。禁止沿用C1的18/F21数字。结果满、trace满、feedback、W/A供数和writer反压分别计停顿；协议等不可继续错误停止新issue并排空已接受事务。数值错误还须按下段完成必要的更低rank检查，绝不因错误丢失已占slot或提前done。

首错继续按生产rank `(floor(n/8), r, n%8, g, 检查阶段)`，bias排在对应输出全部group之后；不能按新row/g/tile发射或完成先后选择。较高rank数值错误出现后，尚未执行的低rank工作仍须被评价，包括后续row的较小tile；已错lane停止依赖其失败结果的运算。bad_element仍是独立原编码 `r*5248*128+n*128+g`。LOAD先按padded n→g检查scale再bias n；Quant按r→g，先该32项finite扫描，再d/inv/half，再q逐项。可已写的失败局部payload不要求回滚，但目的invalid，未写/无效区域必须保持sentinel；消费者不得读取未发布对象。

#### 6.2.1 首错组合路径的等价时序修正（2026-10-10）

[joint OOC42 原始时序](../attempts/task2_joint_dma_ooc_42/work/timing_summary.rpt)在6.667ns下为 **TIMING_FAIL**：WNS=-12.019ns、TNS=-3803.124ns、393个setup失败端点。最差路径从 `ps_controller/tile_tdata_reg[257]` 到 `bias_output/first_bad_element_reg[11]`，数据延迟18.633ns（逻辑6.625ns、估计布线12.008ns），88级逻辑含32个CARRY8及DSP乘法/ALU/PCIN；来源是bias_kind查找后宽rank计算、八lane串行比较/选择及bad_element计算。此结果是综合后OOC，不是P&R。保留该失败身份；integer tree实用320DSP（256个乘法承载DSP加64个加法/PCIN DSP），whole top为458DSP，不能把256写成整树总数。

首轮修正采用等价有界组合实现，不新增流水寄存级。`first_error_rank`仅为PS/bias到joint bridge的私有排序信号，未进入descriptor/observed/DMA ABI；**PS和bias须在同一制品中一起替换**为以下共同编码，不能混用原算术rank与新键：

- 有效键为无符号23bit `{tile[8:0], row[1:0], lane[2:0], group[5:0], phase[2:0]}`，次序与原 `(tile,row,lane,g,phase)` 完全一致。PS使用真实g和原检查阶段（0..4），bias使用group=G、phase=0；G只取本profile合法的8或32。内部以有效位和23bit键比较，可复用已有数值错误有效状态；原64bit私有端口保持有效键零扩展，无错时仍输出UINT64_MAX。
- 每个原有首错更新事件先从错误mask选出最低lane，只生成一个候选并与已保存键比较一次。PS采用原commit错误mask；bias采用 `final_mask & final_bad & ~held_bad`，保持原 `final_valid && bias_kind[final_tile]` 条件。同事件tile/row/group相同，lane优先于phase，故最低错误lane就是最小rank；不能将此规则误用到跨事件/跨row或tile的选择。仅严格较小时替换；joint bridge相等时仍选PS，detail和原更新握手/时刻不变。
- 外部 `bad_element` 保持原64bit编码。令12bit `n={tile[8:0],lane[2:0]}`；15bit row_base按row0/1/2/3取0/5248/10496/15744，15bit `s=row_base+n`，则22bit `{s,1'b0,group[5:0]}` 零扩展即原 `r*5248*128+n*128+g`。合法最大s=18815、bad_element=2408352，group≤32使拼接等价于移位后相加；bias使用G。显式定宽，不依赖unsized int乘法/移位的隐式扩展。无错误的外部bad_element继续为UINT64_MAX。

上述有界表达式只适用于原准入及标签检查后的合法metadata；不得先截断非法高位再把命令接纳为合法。该rank修复本身保持FP计算/舍入、首错检查覆盖、PS commit与c+2反馈、原Q32/D4、AXI真实B退休、source准入和任务计数；后续结果容量单独按§6.6修订，D4不变。rank首轮不改变ready/valid或增加首错债务；若后续实测必须增加寄存级并改变可见时序、完成条件或反馈，再由Astra集中修改受影响合同，不静默改变接口行为。

Sol按现有授权连续完成功能修复与回归，无新增审核门。受影响验证须核对多lane同时出错且phase不同、后到达的更低tile/row优先错误、PS与bias竞争、严格相等时的保持规则、无错sentinel和拒绝/恢复；独立期望使用原生产排序/原bad_element公式。继续既定ACT及QKV1/4全lane中间值、真实DMA/AXI反压、最后tile/有效字节与最终债务检查。**按§0最新优先级，原“下一轮整体OOC”安排暂停，不继续专项时序优化。** 仅RTL变化时可按未变依赖身份引用HLS30，新的功能closure仍绑定更新RTL；OOC42失败、tree320/whole458 DSP及HLS frontend21.308ns均保留原身份。等价修复和局部回归不构成150MHz结论；Task3按§7真实producer/数值/性能准入，不再等待新OOC。

### 6.3 真512-bit接口、尾字节和退休

模型q0/q1/scale、activation、out0/out1实际外部AXI data必须512bit；descriptor/observed和AUX可32bit并单列成本。顶层可以组合HLS load/quant/compute与明确RTL pack/writer，功能RTL覆盖全部适配；后续恢复OOC时同样必须包含全部适配，不只测integer子模块。`max_widen_bitwidth=512`不能代替生成接口证明。

每口单outstanding、burst≤16beats、不得跨4KiB；地址和span先作u64溢出/边界检查。activation base64B对齐，out base沿用4B对齐；writer按64B边界pack数据，以实际64-bit WSTRB只使能有效F32的4个字节。ACT N2仅8B写使能，其他56B不能借read-modify-fullwrite当作合法写；QKV按原plane/head/batch/row/d到两shard的地址公式，把相邻两个8F32结果pack为一个64B beat，禁止顺序整矩阵布局冒充生产scatter。

输出B是外部真实B handshake，不能以HLS函数返回或FIFO入队当作写完成。每个事务记录AW/W/B、useful bytes、总beats、WSTRB mask及4KiB边界；first done时所有读R/writeB、结果/trace slot、writer缓冲与descriptor/observed债务为0。随机AR/R/AW/W/B反压、最后R/最后B长hold、4KiB拆分、4B对齐非64B输出基址及guard必须实际测试；接受的数据/address/strb在反压中保持稳定。

预期工作量（不是cycle实测）：ACT加载q0 2048B=32宽beat、q1=0、scale128B=2beat，bias8B与模型头另计；RUN input1024B=16beat，8个group issue、16个有效lane group、512个有效MAC，output8B。QKV加载q0/q1各1572864B=24576beat，scale196608B=3072beat；每行input4096B=64beat，12288group issue、98304有效lane group、3145728MAC，output12288B=192满宽beat（各shard96）。四行issue49152、output768beat，W只加载一次；头/descriptor/trace/对齐额外beat单列，不混入有效MAC。

#### 6.3.1 observed trace writer与单一地址控制（2026-10-10接口细化）

批准独立32bit `observed_trace` AXI写master，连接**同一个**32768-word observed BO，不增加payload BO或改变128-word descriptor；descriptor word62仍固定32768，word63及64..127保留零。原HLS observed master保留header、quant q/half trace职责；新writer仅写选中(r,n)的group trace。两个master的地址空间共用，写入区域互斥，资源/端口/债务分别实测；对外逻辑P_OBSERVED字节统计为两master实际传输之和，不漏记或重复记trace字节。

顶层新增一组64bit `observed_base`、64bit `observed_span`控制影子寄存器。start只在上次所有债务已清时接受，原子锁存这两个值；`base%4==0`、`span>=32768*4`、`base+span`不溢出必须在任何HLS启动/trace发射前满足。非法配置由顶层control fault报告，不启动HLS、不发observed访问、不消耗descriptor task/epoch。busy期间不接受新配置或改变活动锁存值。顶层启动顺序固定：锁存并核验→用**同一base**完成HLS observed pointer的AXI-Lite参数写入→以同一base/span初始化trace writer命令上下文→启动HLS。不得让Host分别填写两套未核验的observed指针；不以HLS指针cast取得地址，不新增HLS trace-config stream。实际HLS寄存器偏移按生成接口清单绑定，地址高32位同样必须传递/测试。

固定trace布局仍为word17664起（byte70656），group g的第j个word地址=`observed_base + 70656 + 32*g + 4*j`，j=0..7；payload顺序仍为dot、sa、sw、scale product、term、已commit PS、g、valid。只允许本命令选中有效lane及g<G（ACT8/QKV32），与group tag对应；所有64bit地址运算先检查溢出和span，未用group和其他observed区域保留sentinel。HLS不能重写该group区，writer不能写header/q/scale区，且不能为trace重新计算一条算术路径。

首版trace writer采用**每group八笔单beat写事务**，逐word升序，AWLEN=0、AWSIZE=2、WSTRB=0xf、WLAST=1；全writer最多一笔未B退休事务，故每笔天然不跨4KiB。接受trace事件时锁存完整256bit payload、D4 slot及完整160bit owner tag；AW/W在反压时保持稳定，已发送事务仍须排空。FIFO/stream握手只表示交接，不释放D4。只有第八笔真实B handshake之后，才向预留存储返回该slot和完整tag的终结ACK；存储必须匹配当前等待owner，拒绝错slot、错tag、重复/陈旧ACK，不能只因slot编号相同而释放。八个OKAY响应才计成功trace group；BRESP错误须锁存writer/protocol fault，禁止成功发布，即使该事务的物理债务已退休也不能报告trace成功。失败清理保持原排空规则，不能把假ACK用于清债或绕过数值/协议失败。

joint completion必须等待PS真实commit、两个512bit输出writer以及D4/trace writer全部排空，再交给HLS写最终header；最终top done还须等待HLS observed的最后物理B和全部adapter债务。trace writer状态、未B事务和ACK在途属于该同一完成条件，不能仅检查输出两口。选中trace关闭时不分配D4、不发trace AW/W，仍沿用同一base/span绑定与最终header路径。

本节trace接口保持PS、算术、首错和D4容量，结果容量后续见§6.6。受影响自检沿用当前授权连续执行：实际AW/W/B反压及第八B长hold时D4保持占用、完整tag ACK核对、非零高地址/边界/guard、两个observed master区域保护，以及首次done所有债务为零。源码存在或FIFO交接正确不能代替物理AXI测试；trace on/off数值与off周期性能绑定同一联合制品。新OOC依§0暂停，历史证据不跨身份拼接。

### 6.4 独立参考和接受标准

顺序为signed边界/完整32项dot → 真实ACT K256/N2一行 → 真实layer0 QKV K1024/N3072一行 → 四行。ACT输入来自真实act_hidden，QKV来自真实embedding_norm；当前生产controller在layer0直接使用该LN_EMB输出，layer>0才另行LN_ATTN。权重从同一GGUF独立逆重排；旧ACT偏移q0=184680448、scale=23085056、AUX bias=617664只是来源定位，实际运行用新包manifest逐项绑定。新包的权重payload不得偷偷重排成寄存器fixture。

独立oracle逐位比较全部quant q/half、dot、scale product、term、每group PS、bias及全部输出。RTL用被动issue/commit observer捕获真实八lane事件与独立gold比较；固定observed选中trace仅作定位，不对每列重新跑全矩阵补覆盖。真实ACT两列全部group、QKV完整声明rows的全部有效lane/group应有检查计数。至少覆盖负dot、零组、F16次正规、非法scale/输入非有限、错身份/ref/epoch/shape、未LOAD、重放、N2尾列、复合首错及下一合法恢复，保持旧原始失败证据。

当前同一原型身份必须取得CPU/CSim及真实BO LOAD→quant→dot/restore/PS→bias→output/B的RTL数值/协议结果，并按§6.5实测完整周期性能。ACT全部有效lane及QKV完整K/N的一/四行各自关闭覆盖；输出少tile/少字节、首错/恢复或最后B/首次done债务任一不符均为FAIL，不以局部中间值通过代替。trace on/off数值一致，吞吐采用off的同一构建。无新整体OOC/时序收敛前置条件；实际资源、DSP映射和频率缺口保留历史身份，待后续物理实现恢复时重新验证，不能以pragma或功能时钟称实达150MHz。工具/器件及6.667ns/0.035ns原约束请求保持，不做器件迁移；约束请求不等于实际频率。

Task2 RTL保持8GiB/3600s/40M clocks；先≤120s pilot支持固定范围完成。CSim、必要HLS→RTL/功能编译及单重工具限制沿用阶段计划；新OOC/P&R/专项时序优化暂停。若触发保护或数值/协议违约，保留FAIL/NOT_RUN_COST及首因，在合同内普通修复后重跑受影响项，不删断言/改gold/加帽原样试跑。数值通过而全路径II目标未达到时，明确数值PASS与性能TARGET_NOT_MET，继续瓶颈整改或给出有证据的阻塞结论，不能把“性能已经测量”写成“性能整改完成”。

### 6.5 周期性能测量与接受边界

复用现有TB的被动事件/AXI观察，不新增对外观察ABI或独立逐次审核报告。对每个实际完成的ACT/QKV1/QKV4记录源码/生成/输入身份、trace模式及固定反压配置；在相同输入与同一制品下分别保留压力验证和trace-off性能结果，不把关闭真实协议检查作为加速方法。记录实际命令接受（当前top定义的start handshake）至首次done；冷复位/AXI-Lite配置另列，不能把不同起点的计数直接对比。

- LOAD：q0、q1、scale、bias/头及初始化至W_READY/命令退休的实际周期、R beat与有效字节；串行加载按真实时间线累计。
- RUN：activation读/两遍quant至A_READY，首/末issue，dot返回、FP restore返回、PS commit，bias及output排出、最后物理B、diagnostic与首次done。列出服务延迟与完整阶段窗口；重叠区间不能重复求和，未被观察的边界标未测。
- 吞吐：trace-off稳态issue间隔及分布、issue→commit反馈F、有效MAC/cycle；compute窗口和含LOAD+RUN的完整窗口分别报告分母。同权重重复RUN只能计已实际证明的复用，冷LOAD成本仍单列；ACT的无效六lane不能算有效MAC。
- 瓶颈：供数、量化、dot/restore服务、PS反馈、result credit（旧Q32、当前Q35）/D4、output writer/真实B及诊断停顿。计数可重叠时明确口径，不能将其直接相加为总周期；最后完整输出/真实响应退休前不能提前结束统计。

既有QKV稳态目标为一group/clock，ACT按T1真实反馈显式等待，无新ACT数值延迟指标。对未达目标的实际限制给出可复现事件和受影响阶段，按现有合同修复，实质架构变化再集中修订设计；不扩大形状之外的工作或通过降低精度/删层改目标。将这些系数与§5.2前端放入原50ms完整请求预算，未测层/传输保留区间或未知；只有条件预算闭合才可称离线可行，仍不得称物理频率或板上50ms通过。

### 6.6 结果信用的最小容量修订：Q32→Q35

本轮性能阻塞判断依据为[QKV1 off79](../attempts/task2_joint_dma_qkv_row1_traceoff_perf_79/guard/driver.log)、[ACT off81](../attempts/task2_joint_dma_act_traceoff_perf_81/guard/driver.log)、[QKV4 off84](../attempts/task2_joint_dma_qkv_rows4_traceoff_f_84/guard/driver.log)及其manifest所绑定的当前RTL。79实测LOAD488555、RUN24585 TB clocks，12288 issues占18410-cycle窗口，6122个间隙全部被入口计为result-credit stall；其source-empty/tile-busy/trace-credit/output-W stall为0。起点是TB segment，不是精确AP接受或板卡计时；W通道不阻塞也不能证明内部pack/commit不阻塞。81的8次issue窗口260cycles给出同tile间隔37，末issue→commit为34cycles；79末issue→末commit为491cycles。故6122不能解释成统一“32发射+16空泡”，它包含输出反压延长的结果占用。

84已终态PASS：guard exit0、756.12043s、峰值RSS2784164KiB且无保护触发；LOAD488555、RUN88079 TB cycles，49152 issues占75089-cycle窗口，25937间隙均计result-credit，source/tile/trace-credit/output-W stall为0。完整49152个issue→PS commit样本无缺失，F为min34/max491/mean48.037272；`<32/<64/<128/<256/<512/<1024/≥1024`分箱为`0/47546/31/61/1514/0/0`。最小延迟支持下述固定路径判断，长尾支持下游commit阻塞，现有聚合计数尚不能精确划分两者各自造成的空泡。首issue为RUN+11273，末commit为+86852，最后输出B为+86907；traceB0/outB768/obsB32，完整dot/term/PS与四行scatter输出、sentinel和首次done债务通过。日志cycle520000时commits13451已超过首行12288，但outB190仍少于首行192，直接证明§6.1的跨行输出尾部重叠，尚未测完整行边界的精确重叠窗口。

结合原身份的ACT与QKV1/4 trace-on/off正例，可接受其声明范围内真实BO LOAD→quant→group算术/PS→bias/scatter→物理退休的数值与协议结果；动态状态仍由[原阶段表](../stage_results.md)维护。这是隔离正例的集中限定接受，既有一group/clock目标仍为TARGET_NOT_MET；未测负例、实际生产owner链、整网RTL/最终决策及数据集准确率不据此关闭，旧失败和历史时序缺口保留。

按当前[integer tree](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_integer_tree.sv)、[FP restore](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_fp_restore.sv)及[reserved store](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_reserved_store.sv)的真实寄存边界，令issue握手边沿为c：tree结果由FP入口在c+6接收，首级IP在c+7接受，FP1结果寄存在c+13，FP2在c+14接受且term于c+20寄存，FADD在c+21接受，reserved store在c+32接受固定返回；无commit反压时c+33置commit_valid、c+34真实PS commit并归还信用，c+35才能再次使用该信用。FP IP配置保持6/6/11、各服务II1。本次不增加同拍commit→issue旁路，因此连续每拍issue所需最小Q为35；Q32在无下游阻塞时只覆盖32拍占用，差3拍。实际F窗口继续与这些边沿核对，返回/commit反压分开计量；长尾491不要求把Q扩大到491。

批准固定 **Q=35、D=4**，不改算术级数、同tile busy/PS反馈保护或错误排序。内部接口与边界一次规定如下：

- result slot索引改为6bit，合法0..34；issue_head、commit_head、commit_slot及所有按result slot索引的metadata/结果数组同步扩为35项。指针显式34→0回绕，不按6bit自然回绕。所有return索引先检查`<35`再访问数组；35..63、错tag/重复return不能释放或覆盖任何合法slot，沿原protocol fault处理。
- `result_free/reserved/returned`保持6bit，取值0..35；每拍守恒和为35，原子issue消耗、fixed return转RR→RD、真实commit归还的顺序不变。配置准入/compute_done/零债务断言统一比较35。full时禁止第36个未退休issue，禁止用下游可能ready推测归还。
- 160bit内部tag宽度及D4/trace fulltag ACK接口保持。result slot编码为`{tag[63],tag[4:0]}`；原其他低字段`[35:5]`和identity字段`[159:64]`位置不变。私有group序号由`[63:36]`改为`[62:36]`（27bit），当前最大49152组远小于其范围；真实groups_processed/完成计数仍是原32bit且原形状准入不截断。arithmetic统一写入slot高位，FP/return统一解码；所有TB的序号读取同步更新，但fulltag一致性仍比较完整160bit，不能屏蔽bit63逃避slot32..34覆盖。
- FP restore的按result slot索引meta_tag/mask/phase/trace扩大至35项，fifo_slot元素扩大为6bit。该FIFO只排队FADD在途顺序，保持原32项、5bit读写指针及6bit计数；固定无反压FADD占用约12项，不能因结果Q35误将该FIFO当35个全路径credit。返回不受commit反压，已预留35槽能承接全部返回；监测该FIFO无溢出及slot32..34不别名。

逻辑存储增量按每group共享metadata计算，不能再乘8：store每槽`2+160+9+8+1+2+256+8+24=470bit`，加3槽为1410bit；restore每槽`160+8+24+256=448bit`，加3槽为1344bit；32项fifo_slot各加1bit为32bit，三个已寄存slot指针/输出各加1bit约3bit，合计约2789bit加译码控制。160bit流水tag不加宽、W/A/PS和MAC/FP实例不复制。非2幂深度的真实RAM/LUT映射可能有取整，此处不是综合资源或时序结论。

受影响短自检先覆盖35槽同时占满、第36请求反压、固定返回期间commit长hold、同时issue/return/commit、至少两次35槽回绕、索引31/32/34/0、非法35/63及旧tag/重复return。用独立tag/数值scoreboard核对每项一次commit、信用守恒和终态35/0/0，D4第八真实B/fulltag ACK规则不变。随后真实fixture多tile连续供数检查：g<G−1且无source/trace/commit反压的稳态窗口应不再因结果容量出现周期性空泡；ACT同tile反馈不承诺因Q变大加速。此项通过仅证明容量已匹配无阻塞算术流水，不代表最后group或整个RUN达到II1。

### 6.7 输出最小流水：整tile pack与单事务TX分离

真实QKV fixture的bias_kind=0，最后group的commit通过`tile_slot_ready`受bias pending和writer反压；不能归因于QKV bias浮点加。修改前writer每tile逐个32bit WORD写pack，再串行AW→W→B，因此旧`output_W stall=0`仍可有大量内部停顿；以下pack/TX实现的实际覆盖见§6.9。ACT的单tile bias加及其数值检查继续保留。本次不复制bias/FP阵列，只修订两个现有输出writer的数据打包与发送职责。

外部tile/AXI/完成ABI、scatter公式、单口最多一笔未B事务和D4均不变。每口固定一个64B pack（data512/strb64/address64）、一个独立64B TX（同宽）以及至多一个已接受tile的原256bit暂存和拆分进度；无长队列、额外输出tensor或下一row PS上下文。两个writer独立工作，只有接收正确shard的已commit数据才占空间。

- 并行形成一个tile全部有效lane的真实地址、数据和4-byte WSTRB，将同一64B对齐beat内的有效lane在一个pack更新事件中合并，不再用每个lane一拍的WORD循环。合法QKV tile为8 F32，ACT为2 F32；4B对齐而非64B对齐基址可能使tile跨两个beat，此时保留已接受tile的剩余部分，分两次合并且按地址顺序，不丢、不重复lane。仍逐项等价核验u64溢出、span、plane/head/shard/row范围；地址不连续时先封存旧pack，不能按顺序矩阵布局代替scatter。
- pack填满、遇下一不连续地址或真实finish时封存；只有TX空或原事务已在本边沿实际B退休才能向TX转移。TX持有完整不可变地址/data/strb，AW与W可各自独立握手并记录sent标志，任一反压时其valid/payload稳定；原事务B退休前不得发送下一事务AW/W。首版保持AWLEN=0、AWSIZE=6、WLAST=1，每笔64B对齐，天然不跨4KiB。若AW先接受而W仍阻塞，错误/finish也必须完成已接受事务的W和真实B。
- TX发送和等待B时允许填充下一pack；空间不足则按ready反压，不能借假B或提前归还slot维持吞吐。新逻辑必须正确处理同拍B退休、pack→TX及新tile/尾片合并，既有字节不能被clear或新数据覆盖。flush后不接收新tile，已接受尾片继续处理；`flush_done/debt_zero`只有tile暂存、pack、TX及AW/W/B债务全部空才为真。上游finish仍须等待PS和bias真实排空，保留最后n3064 tile等已修复的退休边界。
- useful bytes按实际接受的有效F32计一次，physical bytes按W握手64B计一次，AW/W/B计数保持真实；BRESP错误继续阻止成功发布并排空已接受债务。单beat响应服务时间会限制长期writer吞吐，不能把pack可每拍收tile写成AXI每拍完成或整条链II1。

每口新增TX的数据/地址/strb为640bit，两口1280bit，另加valid/AW-sent/W-sent及少量拆分控制；原256bit tile暂存可复用。加上§6.6约2.8kbit，只是逻辑存储预算，字节对齐/选择组合逻辑与物理映射未综合；无新OOC/P&R/专项时序运行。

短writer自检必须覆盖两相邻tile合一满beat、两个shard及head/plane地址跳变、ACT8B尾字节、非64B对齐基址与跨beat/4KiB、AW/W独立反压、TX等B期间下一pack填充、两个pack满后的真实反压、最后B长hold、错误响应及首次done零债务。每字节独立参考与sentinel保持，覆盖同拍交接和最后tile。先完成有限credit/pack自检再连续执行受影响ACT/QKV完整BO回归；不逐次提交审批，不降低已有gold/检查范围。

### 6.8 有界连续命令与分层流水吞吐验收

本次最小连续服务例为**一次真实LOAD后至少两次合法、同权重的trace-off RUN**，首选QKV一行；ACT短例先验证TB命令/计时关联，QKV四行及trace-on独立回归覆盖受影响数学和最终输出。所有case沿现有真实fixture、完整K/N、原RSS/墙钟/cycle帽；旧79/81/84基线按未变身份复用，不为补计数重开旧长跑。

同一冷session保持request3/generation1/B1/S128、四tag、WeightKey、外部source完整ref和fixture epoch1不变，输入/权重BO在全部RUN期间不可变。冷LOAD task1、W epoch1后，RUN1 quant task2/linear task3、PS/dst epoch1；RUN2 quant task4/linear task5、PS/dst epoch2，内部A8 max epoch也从1增至2，W epoch仍1。后续RUN按原规则每次推进两task和各本地新epoch，不重放旧task/PS/dst身份。只在前一命令首次done且全部物理/adapter/credit债务清零后启动下一命令；不加入跨命令InFlight重叠。LOAD计数保持1，W uses依次1/2、reuses依次0/1，状态与diagnostic按每次真实invocation独立核对；RUN间不再有q0/q1/scale权重读。可在前一命令完成后重置输出/observed的测试哨兵与seen覆盖，源输入不改；每次输出、地址/WSTRB、计数、完整owner/epoch/首次done独立自检，不能因同值残留而漏掉第二次写入。

测量区分以下层级，不另建报告包：

| 层级 | 首次结果、稳态与排空的计量 |
| --- | --- |
| 算术group | 同tag记录issue/固定return/真实commit/credit可用；填充至首commit，g<G−1的稳态完成间隔与最后group分别统计；排空至最后commit。报告Q占用、真实F及供数/trace/commit各类停顿，归因重叠不能求和冒充总时间 |
| output | 首tile接收、首物理B、每口相邻B间隔/有效bytes每cycle、pack/TX占用和排空；内部可重叠不等于外部B已退休。只有实测source/commit可持续且完整最后group也无停顿时，才可称全路径一group/clock |
| row/矩阵RUN | 首group、首完整有效输出至全部输出B及done；输入/quant前段、group稳态、最后group输出和诊断尾段分别报。rows4沿§6.1逐tile安全交接；分别捕获下一行首issue和前行最后物理B，测真实重叠窗口并检查同tile先commit后重用，不能用单行PS推断全行输出串行或多行独立上下文 |
| 同权重连续RUN | 记录每次真实命令接受、首次done、实际中间控制空隙及相邻done间隔，报告有限样本数和RUN/clock；假设频率换算另标。至少两次RUN只给有限完成间隔，不能伪造P95或多请求稳态统计 |
| 层/完整请求/decision | 当前无独立request context/跨层并发调度，原FullRuntime共享inputs/owners/cache/current_weight、KV/head/score状态，controller逐任务检查完成；隔离RUN不是完整推理，不得标成实测requests/s或decisions/s。后续需真实全图及结果解码才能测这些指标 |

对相同对象的真实接受时刻a_i、完成时刻d_i，以cycles报告首结果延迟`d_1-a_1`、各对象延迟`d_i-a_i`及有限平均完成间隔`(d_N-d_1)/(N-1)`（N≥2）；实际控制间隙保留在该间隔内。只有实际时钟f明确时才换算`f/间隔`，使用假设150MHz时显式标条件值。相邻RUN的该指标单位为RUN/s；完整请求及decision按实际完整完成/解码计数，不能把group、row或矩阵替代。流水填充、稳态服务及排空必须来自对应事件，N=2不声称已经建立统计稳态。

流水预算使用共享资源工作量：任一资源r的请求服务间隔下界为每请求在r上的**总**工作/有效服务率，所有共享Q8层先累加；阶段取max仅适用于已证明独立资源、buffer端口、owner/lease及重叠时间线。当前单W bank不能一边供计算一边覆盖下一矩阵，单A8/PS不能偷偷承担下一请求；KV双bank也不是两个独立request上下文。若以后增加双缓冲、独立Q8/Attention引擎或跨请求流水，必须在原合同集中确定资源数量、每上下文request/epoch/lease/credit、调度/依赖、错误隔离和reset，不假定这些资源免费。

数值目标和单请求50ms保持，同时新增吞吐评估但不新设硬门槛。[原完整图预算](../../attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md)中真实B1/S128 Q8工作47,160,754,688 MAC由256-MAC/issue共享引擎即使II1@**假设**150MHz处理，也需184,221,698 cycles=1.22814465s，吞吐上限约0.814236 B1/s；20 B1/s仅作预算示例时需943.21509376 GMAC/s或6288.100625有效MAC/clock，其他算子/搬运另计。这些是理想服务量必要条件，不是板卡数值或已经实现的多引擎方案。Q35/pack整改旨在得到可信、可复用的局部流水服务，不足以改变该共享算力下界；单次前端207.7ms、LOAD约393216-cycle标量scale校验、量化和诊断串行也未因此解决。未达全路径II、未测负例、真实producer链、整网RTL及数据集准确率分别保留，不能以局部通过作最终全阶段PASS。

### 6.9 Q35、pack/TX与连续RUN本轮集中限定验收

本轮代码/合同核对及原始终态支持 **PASS_SCOPED**：Q35的6bit合法slot、34→0回绕、160bit全tag及bit63编码、35项metadata/原32项FADD FIFO、PS busy与逐tile行交接符合§6.6；pack/TX保持单笔未B事务、独立AW/W稳定、真实B退休和bias排空后finish，符合§6.7。`flush_reported`保留到旧请求下降，避免重复flush锁死下一命令。[credit88](../attempts/task2_q35_credit_88/input_manifest.json)覆盖105次有序commit、35槽满/第36反压、两次以上回绕、同拍issue/return/commit和非法slot/错tag/重复return；[bridge91](../attempts/task2_bridge_fix_91/input_manifest.json)覆盖两次配置/完成与真实B。原writer87是旧修复身份；[当前writer109](../attempts/task2_writer_q35_current_109/input_manifest.json)以当前RTL和原九例TB重过ACT尾写、满beat合并、4B偏移/4KiB边界、head/plane跳变、AW/W独立反压、等B期间pack填充/容量反压及错误B债务排空，guard exit0、10.93s。89时间帽中止和90定位日志保留，不回写PASS。

同一当前RTL、HLS30/wrapper依赖和独立真实fixture的新完整DMA覆盖精确限定为：[ACT103](../attempts/task2_joint_dma_act_timing_103/input_manifest.json)一次LOAD后两次合法trace-off RUN；[QKV1 off104](../attempts/task2_joint_dma_qkv_row1_cont_104/input_manifest.json)一次LOAD后两次合法trace-off RUN；[QKV4 off107](../attempts/task2_joint_dma_qkv_rows4_reg_107/input_manifest.json)一次LOAD及一个四行RUN；[QKV1 on108](../attempts/task2_joint_dma_qkv_row1_on_108/input_manifest.json)一次LOAD及一个trace-on RUN。四次guard均exit0且无保护/ERROR/FATAL，墙钟分别77.68/579.30/731.46/487.29s；各242项输入manifest逐项核同当前依赖，109的5项也核同。每次RUN均保留独立q/scale、有效lane全部dot/term/PS、完整scatter输出/有效字节、header身份/epoch、sentinel、输入保护和首次done全部物理/适配器债务检查。104两RUN各12288组及3072个F32，权重仅LOAD一次；107共49152组及12288个F32/768个输出B；108有真实trace256笔B、输出192笔B、observed49笔B。新的ACT trace-on和QKV4 trace-on组合未在本轮重跑，旧相关结果只保留旧Q32身份；不得把上述受影响组合覆盖写成当前所有组合均新测。96与100的新TB事件监测失败保留，不能从其提前打印的数值PASS推出整例通过。

计时起点为外层控制器上升沿的`command_start && command_ready`接受，终点为首次wrapper `command_done`，并在该点复核零债务；包括AXI-Lite参数写、HLS启动、完成轮询及排空，**不是生成HLS内部ap_start→ap_done**。103每RUN为3471cycles，相邻done3473、控制间隙2；104每RUN为18933cycles，相邻done18935、控制间隙2。107的四行RUN为65463，108一行trace-on为20797cycles。对比旧基线只使用相同TB段口径：QKV1由24585降至18935（约23.0%），QKV4由88079降至65465（约25.7%）；冷LOAD仍488555。连续两RUN只给同权矩阵命令的有限完成间隔，不是完整请求或decision吞吐，也不是统计稳态。

**无输出阻塞的算术稳态目标局部PASS；当前固定压力profile的全路径目标仍TARGET_NOT_MET。** 104/108各11904个g0..30实际issue首末间隔为1.000cycle，证明Q35消除了该无阻塞窗口的容量周期空泡；全12288组issue跨度仍13148，860个间隙均落在末组相关的result-credit反压，F为34..134、均值36.580566，Q占用峰值35。107共49152次issue跨度52862、3710间隙，F为34..134、均值36.674561；跨全部行的nonlast均值1.084049含前三行末组窗口，不能作为纯g<31稳态II。TB物理slave固定`B_HOLD=9`，104每口96笔B首末平均13.936842cycles；这是该固定压力下的真实事务退休，不能把860间隙全判为硬件本征不可消除损失，更不能冒充板上HBM服务或无反压全路径II1。107每口跨四行的B首末均值107.148825还含行间计算区间，同样不是局部writer服务II。本轮不另加B_HOLD0长例；若以后需要，明确对应scope/成本后按实际证据区分。

107的row0/1/2末输出B分别为cycle513135/526373/539611，下一行首issue为512976/526214/539452，三次均重叠159cycles；全量四行数值与地址检查支持§6.1的逐tile安全PS复用，不能外推成独立多row或跨命令/跨请求上下文。D4与最终真实B规则保留，未新增W/A/PS或MAC/FP实例；逻辑存储估算不转为物理资源PASS。

本次只关闭上述实现与验证范围。完整负例及故障恢复组合、真实producer/完整owner链、整网RTL/最终决策、数据集准确率、实际频率及50ms均未关闭；旧HLS21.308ns、OOC42时序失败及rank修正保留。新整体OOC/P&R继续按§0暂停。动态阶段状态仍只由[原阶段表](../stage_results.md)维护，本节不构成Task2所有覆盖或整个阶段最终PASS。

### 6.10 完整图流水预算重新核算的限定结论

本轮按用户“重新核算”只读既有源码/报告并短复算，新增唯一预算正文[pipeline_budget.md](../pipeline_budget.md)及其[机器JSON](../pipeline_budget.json)，旧联合预算冻结。当前v4 manifest/build147c8e身份、122张Q8/47,160,754,688 MAC、B1/S128、28 Encoder/2 Decision/16 marker不变；CPU仅token Embedding，全部LN及EMB_TYPE仍在FPGA。50ms首请求目标单列，20 B1/s仅为50ms完成间隔示例，附10/20/40 B1/s和100/150/200MHz条件敏感性。

修正后的关键口径为：当前整数树每通道32乘法DSP+8树加法DSP，原R0两FMUL/PS FADD再8，故直扩48 DSP/通道；旧40只有树改LUT才成立，packing2仍未验证。按当前task≤16逐任务ceil的TM1/TN8理想issue为184,221,704 cycles，比纯MAC/256多6个尾部cycle。全量scale校验11,542,592项含ACT48个padding，当前4cycles/项共46,170,368cycles；加q0→q1及scale unpack主体为53,384,488cycles=355.897ms@假设150MHz。单W bank下LOAD与Q8服务相加，模型常驻HBM不删除此装载。无新实际Fmax或整网RTL证据。

预算分别评价当前同步单请求、一套独立Q8/Attention/vector跨请求重叠、加宽与两Q8引擎分工；共享资源用每请求全部工作量，相互独立才可对资源服务取max，不能逐层取max。实例TM16/TN8占6144 DSP、F256 QK/AV占1280，vector/quant/LN/非线性512及控制/偏置/转换256配额合计8192，裸余832但shell和精确非线性物理映射未知。其单W Q8+LOAD主体432.656ms，仍不是示例50ms间隔方案。RAM、bank/ports、PS反馈、softmax/quant除法、Host和184MiB/request的生存期均保留；当前单in-flight没有因此升级为多请求runtime。

本轮接受范围仅为身份/公式/已有证据口径的一次离线预算更新，不是硬件资源/时序/性能或整个阶段PASS。下一只选择§7所列scale扫描候选，不实施新RTL，也不启动Task3长链。既有§6.9限定数值/协议结论保持，所有未验证项继续在原阶段表中保留。

## 7. Task3 依赖与集中出口

Task3已授权，当前准入为：Task1完整CPU raw→FPGA LN数值/owner正确；Task2完整ACT/QKV声明范围的数值/协议通过、trace-off全路径周期/瓶颈和运行成本已有依据；在原设计中绑定实际producer/runtime接口和新实现身份。**新整体OOC、资源收敛及物理时序不再作为本轮前置条件。** 性能目标尚有缺口时可准确标明后开展有限连接验证，不能称性能整改完成或50ms已达。

§6.6–§6.8的有限流水整改已得到§6.9限定接受，联合预算重新核算已在§6.10及[预算正文](../pipeline_budget.md)集中完成。下一只选择**现有TM1/TN8单W的scale合法性扫描一项/拍候选**，本轮不实施。候选保持原LOAD q0/q1/scale/bias读取次序、padded n→g检查次序、scale校验先于bias校验的首因、WeightKey/epoch和失败不发布W；允许严格等价half位分类或流水化扫描，但±0、正subnormal、Inf/NaN/负非零的接受/拒绝必须与原half→F32后finite/非负语义完全一致。拟验证独立65536种half位型与多坏值最低n/g、padding坏值、scale/bias同时坏时首因、合法恢复及真实债务，再沿原ACT/QKV完整K/N和独立gold覆盖受影响LOAD/RUN。新的功能RTL生成、pilot及受影响回归仍按既有资源/墙钟帽先核成本，整体OOC/P&R暂停；本次预算授权不自动启动这些运行或昂贵Task3整链。

一项/拍的checker条件收益为3×11,542,592cycles，@假设150MHz约230.852ms；它通过后单W LOAD主体仍约125.045ms，当前Q8数学仍至少1.228s，不能宣布50ms或示例20 B1/s已达。加宽、双W、多请求/多引擎及向量融合均需按预算明确新增资源与owner/lease/credit边界，不能免费重叠。Task3有限producer连接继续保留以下范围/成本准入；实质结构变化原位修订合同，普通实现与受影响回归依已授权具体范围由Sol连续执行，不新增逐步审核文件。

连接顺序仍为FPGA LN_EMB输出→layer0 QKV完整K1024/N3072及全部128行/双shard发布→RoPE→真实KV装载/QK/mask-softmax/AV，覆盖全部16 heads及声明query行。数据来自实际producer，consumer通过runtime取得并验证完整identity/spec/epoch/coverage/lease；禁止沿用§6.0 fixture epoch1或TB预置READY，禁止在连接链内部预装本应由DUT生产的QKV/RoPE/Attention tensor。通过要求为独立全输出数值、producer→consumer实际数据、双shard/owner/地址、最后响应/sentinel/首次done债务，以及明确的全路径周期和停顿结论。局部fixture、分段重放及旧预置Attention证据分别标范围，不能称同runtime连续链通过。

用必要的新生成调度、既有实测系数和≤120s pilot核算固定范围；在Task3原8GiB/3600s/40M帽内预计可完成才执行正式RTL。成本不合理则完整范围NOT_RUN_COST，继续可独立完成的算子/接口段，并在原表写明段的真实输入producer或外部重放、完整输出/owner边界及未验证连接；不缩K/N/rows/head冒充全链，不试跑无界串行整网。生产源码变化后重跑受影响的新profile四请求持久CSim、gamma首因/零输出/恢复，沿用§3固定任务数；未变v4全图CSim可按原身份复用。仅生成当前功能验证必需的RTL，完整HLS/整体OOC不再是本轮额外出口。

阶段末在既有结果表作一次集中验收：分别说明真实全图CSim、完整前端RTL、隔离ACT/QKV RTL、实际连续producer链、整网RTL的数值与最终决策覆盖，以及数据集准确率是否实测；独立报告既有吞吐目标与50ms条件预算、前端瓶颈及未达项。数值通过不能覆盖性能未达，测量完成不能替代整改完成，不把不同身份/局部结果拼成整网PASS。完整模型、F32规则和误差标准保持；后续物理平台、实达Fmax、包含CPU和传输的50ms仍需实际验证，本轮暂停不将其关闭。
