# A005：executor_hls_01 COST_STOP只读定位

日期：2026-10-13。父A002为共享实现和重工具串行执行owner。本诊断只读既有attempt、冻结源、有限原始日志及报告；唯一写入本文件和`agent/A005/result.md`。无子agent，无HLS/compile/RTL重启，无预算调整，无LLVM工具执行，未修改attempt内任何文件。

## 结论与证据等级

已确认：本次停止于Compile/Link之后的LTO reflow，最后可见事件是5个8192位stream端口的disaggregate；尚未完成Unroll/Inline，未生成top RTL。120秒内没有新的可见产物、文件数/总字节数增长或mtime推进，guard按既定合同正确执行COST_STOP。

不能确认：编译器内部死锁、某一个端口展开必然卡住、或大struct拷贝是直接原因。长时间不输出的内部pass可能仍在计算；现有信息没有内部pass完成量，CPU忙和重复remark不能补足这项证据。Compile/Link的同步调用树确实很大，但树的累计值不等于一个已经inline成平面的266124-instruction函数。

不支持“自动inline爆炸”的直接归因：LTO err日志有1138条`not inlined ... cost=never`，仅1条明确`Inlining function`（`FullMemory`构造函数），然后是5条port disaggregate。不能用泛泛`inline off`建议代替结构减法。

## guard事实与观察边界

| 项目 | 原始证据 |
| --- | --- |
| 状态/trigger | receipt `COST_STOP`；guard `semantic_stall` |
| elapsed/退出 | 280.4605300016701秒；child exit -9 |
| 最后进展间隔 | 120.08162789605558秒 |
| owned RSS | peak 1477768 KiB；1401个实际RSS samples/captures |
| 系统可用内存 | minimum 394223280 KiB，超过192 GiB门槛 |
| 原执行预算 | CPU0–3、nice19、idle I/O；24 GiB RSS、1800秒wall、120秒semantic stall |
| 最后artifact highwater | 543个文件、74586132字节 |
| 当前全部work实际统计 | 同为543个文件、74586132字节；最新mtime为01:41:00.711 UTC |

冻结guard的`production_guard.py:51–74`使用`Path.rglob("*")`遍历整个work（包括`.autopilot/db`），每5秒采样文件数和总字节数，以两个单调highwater之一增长刷新进展。不存在“hidden db没有被观察”的证据。`semantic_timeline.jsonl`在01:41:21和01:42:21 UTC记录同一个highwater，距最后进展分别20.013586秒和80.049471秒；触发于01:43:01.300 UTC。

观察口径有明确限度：同大小原地改写、被旧highwater抵消的产物替换、只在编译器内存中进行的pass都可能不刷新计时。这次最终全部work的最新mtime也停在01:41:00.711，因此没有现存磁盘证据显示120秒窗口内发生过同大小改写。guard证明可见产出停止，不证明编译器算法已死锁；保留COST_STOP而不改称综合成功或超时误判。

## 最末stage与产物时间

`work/logs/work.steps.log:108–195`只记录launch/config、`hls.syn.top=laya_task_lifecycle_executor`和09:38:25本地时间的新launch标记；它不提供已完成的综合pass序列。真正的末stage由`.autopilot/db/autopilot.flow.log:1131–1170`与pass日志确定：

| UTC时间 | 产物/事件 | 字节数/说明 |
| --- | --- | --- |
| 01:40:37.037 | `a.g.ld.0.bc` | 1784688；合并设计 |
| 01:40:37.318 | `a.g.ld.1.lower.bc` | 1784688；lower |
| 01:40:39.092 | `a.g.ld.2.m1.bc` | 14239104；库link中间态 |
| 01:40:40.117 | `a.g.ld.3.fpc.bc` | 1223984；globaldce/float conversion |
| 01:40:40.384 | `a.g.ld.4.m2.bc` | 1268820；float库link |
| 01:40:40.587 | `a.g.ld.5.gdce.bc` | 1223764；最后有成功完成记录的pass |
| 01:40:40.796 | `a.g.lto-343cb942.bc.tmp` | 0；没有完成的`a.g.lto.bc` |
| 01:40:41.289 | `a.g.ld.0.bc.clang.reflow.diag.yml` | 1024000；结尾截断在`Function: laya`，不是完整pass完成记录 |
| 01:40:46.333 | `autopilot.flow.log` / `hls_compile.log` | 最末为`Doing LTO`、reflow background poll 5000ms及Compile/Link警告 |
| 01:40:46.455 | `csynth_design_size.rpt` | 282666；Compile/Link=266124，Unroll/Inline=pending |
| 01:41:00.711 | `a.g.ld.0.bc.clang.reflow.err.log` | 369299；全work最后一次可见写入 |

`a.g.ld.1.lower.bc.opt.*`、`a.g.ld.3.fpc.bc.opt.*`、`a.g.ld.5.gdce.bc.opt.*`的err/out与diag文件均为0字节；flow有各pass的`result=success`，不能将空err/out解释为该pass失败。LTO没有success/完成标记。

最后err日志共1144行，其1139–1144行依次为：

1. Inline `laya::full::FullMemory::FullMemory()` into top。
2. Disaggregate `program_pending`。
3. Disaggregate `program_owner_receipt`。
4. Disaggregate `program_owner`。
5. Disaggregate `control_response_rejection`。
6. Disaggregate `control_response_receipt`。

这5个名字恰好对应冻结`executor_hls.cpp:79–80,97–99`的全部`hls::stream<ap_uint<8192>>`端口。定位到wide interface lowering是强证据；把最后一条remark当作准确卡死的函数边界是越界推断。`kernel.internal.xml`、`top-io-fe.xml`均未生成，`work/hls/syn`无`.v/.sv/.vhd/.dcp`。

## Compile/Link最大的20项

只输出20个最大function/location项；从2720个树行中以function/location去重（364项），同一项采用报告中最大的累计值并保留原calls数。以下值包含子调用，且calls数已在报告数值中体现，不能相加或再乘calls。

| # | 函数/位置 | 报告累计instructions | 原rpt行 |
| ---: | --- | ---: | ---: |
| 1 | top / `executor_hls.cpp:70` | 266124 | 23 |
| 2 | stream `step` / `executor_stream.cpp:38` | 238192 | 562 |
| 3 | actor `step` / `executor_actor.cpp:181` | 210006 | 786 |
| 4 | `port_step` / `task_lifecycle_port.cpp:28` | 130403 | 1031 |
| 5 | FSM `step` / `task_lifecycle_fsm.cpp:222` | 123872 | 1038 |
| 6 | `owner_event` / `task_lifecycle_fsm.cpp:55` | 44307（3 calls） | 1144 |
| 7 | `build_owner_event` / `generated_provenance_events.cpp:211` | 29214（3 calls） | 1151 |
| 8 | `descriptor` / `generated_provenance_events.cpp:65` | 28077（3 calls） | 1159 |
| 9 | `address` / `generated_provenance_events.cpp:58` | 24804（9 calls） | 1173 |
| 10 | `full_f32_address` / `laya_full_memory.cpp:286` | 24732（9 calls） | 1174 |
| 11 | `send` / `task_lifecycle_fsm.cpp:45` | 20635（5 calls） | 1094 |
| 12 | handoff `decode` / `executor_handoff_protocol.cpp:49` | 18550（2 calls） | 572 |
| 13 | transaction `encode` / `controller_transaction_codec.cpp:497` | 18035（5 calls） | 1095 |
| 14 | `build_generated_begin` / `generated_provenance_events.cpp:245` | 16350 | 1519 |
| 15 | `ordinary_begin` / `generated_provenance_events.cpp:180` | 16329 | 1520 |
| 16 | `byte_address` / `laya_memory_map.cpp:30` | 14256（27 calls） | 1195 |
| 17 | `response_key` / `executor_actor.cpp:48` | 14152（4 calls） | 787 |
| 18 | transaction `decode` / `controller_transaction_codec.cpp:699` | 13117 | 1051 |
| 19 | handoff `validate` / `executor_handoff_protocol.cpp:4` | 11832（4 calls） | 788 |
| 20 | `span` / `laya_memory_map.cpp:8` | 11610（27 calls） | 1197 |

stream子树占top报告约89.5%，port子树约49.0%。`LAYA_EXECUTOR_FIRST_REQUEST`只改变首次准入调用（`executor_bootstrap.cpp:79–83`），并没有排除`executor_actor.cpp:373`的RUN_ACTION→port→FSM链，因此不能认为FIRST开关已经形成小metadata调用树。Entry/State构造累计分别5790/5431，远小于该任务执行子树；不能把大static State构造单独列为已证实主因。

## struct拷贝证据与限制

- 明确存在`executor_stream.cpp:52`的`executor::Inputs in = live`。Inputs含1024字节cancel drain packet和256字节Host result packet，另有decoded control/fence/physical map；随后该局部副本的事实字段及cancel packet又被修改或覆盖。这里可以做具体的冗余拷贝减法，但没有IR计数证明它占此次stall的主要成本。
- 未在冻结HLS源中发现`FullRuntime`整对象clone/reset赋值。FIRST的`full_admit_first_request`（`laya_full_io.cpp:223–232`）只复制`rt.inputs = next`并更新准入字段；`executor_checkpoint.cpp:207–213`只是小TaskReservation allocator的容量probe，不是第二runtime。
- `task_lifecycle_fsm.cpp:46–48`复制完整transaction并encode；stream还有原1024字节packet留存/比较。这些字节归属和原包保留参与真实消费语义，不能为了降成本删去codec、完整K比较、旧owner或撤销清理状态。

## 最小、可证伪的后续结构实验建议

建议由父另行授权串行执行新候选；本诊断未启动任何实验。保留原120秒semantic stall和资源上限，历史attempt不覆盖。

1. **先隔离wide接口假设，而非直接改完整receipt协议。** 构建一个单独微top，保留原5个8192位ap_fifo方向、write_nb/read_nb及受控固定原包保持，不带actor/runtime/FSM；比较它是否越过同一disaggregate阶段。若微top也停止在相同阶段，wide lowering得到独立支持；若微top快速完成，它证明wide口单独不足以解释完整top停滞，不能因此宣称完整top可综合。微top本身是结构删减对照，不是原样restart。可进一步用16个512位稳定数据片段+一次whole-valid/ready对照，但仅作为独立定位：任何正式变更仍必须让accepted成功等于唯一shell完整原包的真实ack，保持full K、16实际response reads及取消旧owner约束，不能用最后一个FIFO写成功代替ack。

2. **最有量化依据的完整语义减法：专用NORM owner descriptor。** 冻结FSM `start:165–181`已经拒绝非NORM、非HIDDEN→NORM、非region0、非TOKEN、非1024宽及非全S owner；`owner_event:59`却仍经通用`build_owner_event`调用3次descriptor，每次计算first/last/next三次通用`full_f32_address`，形成报告中的9次通用地址链。仅为这条已准入NORM owner路径增加专用checked descriptor，保留`check_ref`/epoch-bank-region检查、B/S约束、容量/overflow、event sequence及失败码；一次验证NORM span后按原布局生成descriptor。原NORM布局是STATE0 base=8MiB，row_stride=4096，batch_stride=4194304，row0=0、rows=S、batch=255时owner_extent=`((B-1)*1024+S)*4096`。保留generic函数给其他caller；不能删除其他family的拒绝或invalid-cleanup路径。这一改动目标是移除该owner-event链的9次generic address和其中27次byte/span调用，报告累计24732是机会规模而非可保证节省量。用已有合法/拒绝/取消host用例及generic vs specialized的完整descriptor逐字节对照证明语义相同，再由父做有新SHA的新guarded候选，观察设计规模和末stage；不能仅以编译CPU或日志行数判成功。

3. **更小但证据较弱的copy对照。** 只在top拥有的本次调用临时Inputs上设置消费事实，避免`Inputs in=live`再复制，host通用API可保留旧const输入适配；只允许明确由top独占的临时对象可变，不能改live授权来源或借此增加runtime副本。比较新候选Compile/Link规模及末pass。如果规模几乎不降或停止点相同，应撤销“Inputs拷贝主因”假设，继续按第1项证伪；不据这处静态copy存在就延长预算。

第2项有源码准入限制与报告热点双重证据；第1项最能区分当前末stage的接口变换问题和整个同步调用树负担。两者都需要新的可审核结构差异，不能原样restart或放宽120秒。增加内部pass完成产物的观察有助于未来诊断，但只有已完成pass/设计规模/新RTL等有限工作事实才可计为语义进展，CPU计数、相同remark与心跳不构成进展。

## 关键原始身份

全部路径相对`R003/executor_hls_01`；本诊断读取后未修改它们。

| 文件 | SHA256 |
| --- | --- |
| `guard_hls/guard_result.json` | `1d803922c3042f8e646052318189754fe380ec9a5c44d2319271d2265fd2243b` |
| `guard_hls/guard_trigger.json` | `36d0896bd47f63cecbadd3791ce64aabc19d0313b33816530ae3069bce1b87bf` |
| `guard_hls/semantic_timeline.jsonl` | `0353a502581181f2e5c4695291d0d57a74586dafe477d46ade1c2eb2d93be678` |
| `work/logs/work.steps.log` | `2ad1cb0755c12d6c50a4babc9c920a63f46e05833e0773873e9146dae5bc46a0` |
| `work/hls/.autopilot/db/autopilot.flow.log` | `9c49b1429abad2f88723c9c1907ce23951cda87c1bbc1565c5fea790be0ac7f5` |
| `work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.err.log` | `327613d4127a15112ec5ec13292cf1deb482d4f83de8e155b200f6a23d8f18f5` |
| `work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.diag.yml` | `b9ffc42ead33dbda4d2424403a038629f0cddd404a38befc33b46f90edba2eb6` |
| `work/hls/syn/report/csynth_design_size.rpt` | `157fb9e4c47931d4beb52260c245a7ccee3ff4d98ac126341082b08b27e2765f` |
| `frozen/hls/control/executor_hls.cpp` | `91dbdd4166629bc2339fb6063e290cb5db2fa627a9d59e23fef7f6f42152d172` |
| `frozen/hls/control/executor_stream.cpp` | `f0ebe047556b77ee93d3b999f4c45eb99dd79e4330d8f0b62a19b42b351f23b6` |
| `frozen/hls/control/task_lifecycle_fsm.cpp` | `7e0355765d0533c2c32eabd8bec0bd1c89827f7f4eed4c2b18e808ed68665563` |
| `frozen/hls/platform/generated_provenance_events.cpp` | `1412526930e4dd43a8d98b18b8a0c02936841167ef110c0995b07b0b22f18722` |

generated executor RTL、资源/时序、同runtime shell/program闭合、physical closure/rearm与板端均NOT_RUN。本诊断不提升原host或控制RTL证据的范围。
