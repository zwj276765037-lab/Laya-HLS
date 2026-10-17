# A005：五宽FIFO生成之后的executor只读定位

日期：2026-10-13。父A002为共享实现/整合及唯一重工具owner。本次只写本报告和`agent/A005/result.md`，不改源、接口、runner、旧attempt或预算，不创建后代。真实host/HLS由父在`executor_wide_fifo_diagnostic_01`执行；本次仅核原始结果、身份、实际RTL、工具日志、executor02冻结IR及当前源码。使用安装`llvm-dis -o -`做小量内存解析，CPU0–3/nice19/idle I/O、单次30s timeout、MemAvailable>192GiB；不写`.ll`或attempt、不启动编译/HLS/RTL。

## 结论与当前最小下一项

**同五个8192bit FIFO方向及实际nb读写，在本工具/原资源保护下可以完成生成。** 这排除“五宽口组合本身足以必然造成此次停止”的假设；不能证明完整actor状态图就是根因，不能签生产executor或RTL反压行为。接口与聚合状态/库操作的相互作用仍未被这个小调用图排除。

executor02最后完成IR中，唯一top可达的普通外部库函数是`memcmp`；其三条业务array比较路径已在当前源码改为完整`packet_equal`。不要把这项已实施修复重复列成新诊断，也不要从累计instructions下降判其有效。先按父当前完整候选的实际IR/生成结果核“memcmp是否完全消失、是否越过LTO”，明确所有同时变化。

若完整、无memcmp候选仍停在原区间，**下一最小、具体且可观测的结构假设是stream的2464B Inputs整体SSA复制/第二临时对象参与聚合传播**。仅使top独占的本调用Inputs原地供stream使用，保持完整成员与全部消费门、Runtime及外部接口不变。验收首先看新IR中该aggregate load/store和第二alloca确实消失，然后看LTO是否完成；不按累计规模的下降百分比判成功。本报告没有实施此改动。

## 实际生成及身份核验

| 实际记录 | 核验结果 |
| --- | --- |
| receipt | `PASS_SCOPED_GENERATION`；host另为`PASS_SCOPED_HOST` |
| guard | child0、trigger null；elapsed38.071846470s |
| 内存 | peak owned RSS2372468KiB；189次RSS samples/captures；minimum MemAvailable404466588KiB |
| policy | 22条实际process policy全部CPU0–3/nice19/idle I/O符合 |
| 生成top | 42256B；SHA `994f8cc0736202ca1539a67b7b2260db37a85618236aadd63532ed8b16a37ac2` |
| 接口 | 准确5 FIFO/15信号，加input ap_clk/ap_rst共17端口；无AXI或ap_start/done/idle/ready |
| 产物身份 | receipt的242条generated artifact和7条HLS guard file全部SHA/bytes匹配；342个冻结original/copy pair匹配 |
| host捕获复核 | 六份实际capture与原独立fixture逐字节相等，每份1024B，共6144B；未重跑host binary |

三个输出`control_response_receipt`、`control_response_rejection`、`program_owner`均为8192bit output din、input full_n、output write；两个输入`program_owner_receipt`、`program_pending`均为8192bit input dout、input empty_n、output read。实际RTL din接共享repack的真实ap_return；write门使用相应full_n和原sent/phase，read门使用相应empty_n和collected/phase，输入data接实际collect路径。不是仅补dummy端口；这些是实际结构连接事实，仍不是动态RTL反压/时序验证。

host marker实际为`raw_pairs=2 input_actual_reads=4 diagnostic_output_actual_writes=6 complete_bytes_per_packet=1024 output_lanes_blocked=3 complete_blocked_payloads_stable=3 bounded_host_peer_depth=2 software_calls=103`。bounded peer宏仅在host，HLS无此宏。该软件peer实测不能扩大到generated RTL反压或shell原子accepted握手。

## 工具通过了原停止附近的变换

两者同U55C、150MHz、Vivado flow、pipeline_loops=0、array throughput partition off/complete threshold=0；v++ wrapper SHA及实际ap_int/hls_stream头身份相同。实际reflow关键选项同为aggregate-bitwidth-threshold=4096、array-promotion-threshold=64、auto-small-array-partition/auto-array-promotion/auto-array-partition-for-flatten启用、throughput-driven-auto-array-partition=false、disable-inlined-alloca-merging=true、hls-bitcode-version=3.1。微top只有一个.cpp、一个项目header和AP_INT_MAX_W=8192；完整executor的四个生产宏/额外接口/模型及调用树不是相同变量，不能声称整个编译闭包相同。

原02五条末尾`reflow-disaggr/DisaggrSucc`在微top中也实际出现，原顺序是program_pending→program_owner_receipt→program_owner→control_response_rejection→control_response_receipt。微top随后继续stdarray访问inline、完成Compiling Optimization and Transform（8.49s）、synthesizability（0error/1warning）、Architecture Synthesis、Scheduling/Binding及全部RTL model生成。

微top实际`a.g.lto.bc`已完成24912B，且有真实生成Verilog。02仍只有0B `a.g.lto-7f2b011a.bc.tmp`；这比“最后出现同五口remark”更能区分实际是否越过该区间。微topCompile/Link563、最终HW transforms203仅描述这个诊断编译阶段，不能按其与executor226981的比例推断根因、硬件资源或速度。

微topXML估计顶层BRAM18=3、DSP=0、FF=24677、LUT=5933、URAM=0；只是该小模块HLS估计，不是executor资源、联合总量、实现后时序或请求吞吐。子模块资源含于顶层，不相加。

## executor02可达操作清单：库假设的具体边界

本次重读02最后完成`a.g.ld.5.gdce.bc`，按真正call/invoke opcode解析直接callee，不把`%call`变量使用或调用参数中的global当callee。全部459个defined函数均由top直接调用图可达；未发现间接call。

除LLVM/HLS intrinsics外，唯一可达external declaration是`memcmp`。已有报告定位的两个1024B top比较和一个256B Host result比较，经过stdarray/equal链到唯一直接memcmp站点；“直接站点1”不是“业务调用1”。当前actor/hls两文件的精确差异只把这三处比较替换为全字节XOR/OR，原decode、key和消费门保留。

此外可达86个`llvm.memset`站点，全部固定常数长度16–12288B；一个`llvm.memcpy`是owner_plan的8B常量。没有动态alloca、exception/landingpad、原子或vararg opcode，未发现malloc/free等普通external库调用。它降低“另一未解析普通库调用”的优先级；不能凭external清单排除已定义函数内部的工具不支持操作，也不能将llvm.memset说成已证停滞原因。此清单未拿86站点累计当成本。

微top同样在gdce中使用aggregate型8192 FIFO push/pop及8192 part-select/set intrinsics并成功lower。它直接支持这些具体宽口操作有可生成实例；02还有512bit接口、2496bit配置选择、复杂聚合与实际AXI/actor调用树，仍属不同完整上下文。

## 当前源码身份与混杂变量

02的25个compiled source中，当前读到三个不同文件：

| source | 当前差异 | 当前SHA256 |
| --- | --- | --- |
| `executor_actor.cpp` | 一个256B array==改packet_equal | `5cc361807fff8387de3793fb97042832024c7e7d444408f9942f061c68c04fbd` |
| `executor_hls.cpp` | 两个1024B array==改packet_equal | `21c0ae26bd0b74a648c5a76cf4922bad9b2d8b946939be5e14090981c0e4d1da` |
| `bootstrap_snapshot_protocol.cpp` | 从nested Request caller提取purpose再跨validate_fields边界，其余检查保留 | `606925b36174bea22469079e0c9f608936a708f71336b00634f81ebf4fef7990` |

第三项是共享packed-parent validator边界修复；本诊断没有修改、撤销它。当前完整候选不是纯memcmp单变量A/B。若它成功，只能接纳该完整身份成功并将原因收窄至已列差异/相互作用；不能单归memcmp。若它仍停且其新IR核无memcmp，则memcmp不是此新停止的必要条件。当前源码文本不能代签新IR中external已完全消失。

## 2464B Inputs假设：下一项精确观察

02 stream开头确有第二`alloca Inputs`及：

```llvm
%2 = load %"struct.laya::executor::Inputs", %"struct.laya::executor::Inputs"* %1, align 8
store %"struct.laya::executor::Inputs" %2, %"struct.laya::executor::Inputs"* %in, align 8
```

这是整2464B aggregate SSA，查memcpy会漏掉；完整1024B cancel pending、256B Host result、handoff Message、physical map/fences都在该类型。当前`executor_stream.cpp`仍是`executor::Inputs in = live`。top先构造其本调用唯一Inputs，填live绑定，然后调stream；之后只看持久actor、推进entry phase并return，不再读取该本地Inputs。因此top可以将**独占本调用对象**交给stream建立真实消费字段；旧host const API的复制语义可由不在生产top可达闭包中的适配保留。

建议父若选此项，只改变owned/in-place内部入口，保留全部Inputs成员/初始化、真实frame decode/末拍consumer事实、cancel pending完整旧record、反压保持及actor步调用顺序。不能传live共享引用作可变对象、注入消费bool、缩包或移除验证。保持唯一State/Runtime、持久高水位/owner/旧债务与所有端口/方向。

这项的可证伪预期是：新gdce该typed aggregate load/store及第二Inputs alloca消失，而named persistent State/Runtime定义、唯一static实例及外部接口保持；随后LTO完整产物/后续阶段或真实generatedtop出现，才接纳生成改善。若同帽仍同区间停，保留“这一复制不是单独充分解释”，不继续以减少若干instructions作为成功替代。它测试具体object transfer形状，不证明整个Inputs类型天然不支持。

## 聚合状态图假设仍未证实

02静态Entry304640B、State293888B、唯一FullRuntime275808B及其中FullOwners227120B均由原IR ctor dereferenceable和DI size可定位；本次未重新累计潜在leaf数当实际compiler work。没有FullRuntime整体aggregate load/store克隆，runtime在actor→checkpoint/bootstrap/lifecycle等路径中按同一持久实例引用传递。不要把Inputs局部copy推广成“整个Runtime反复复制”。

完整调用图仍包含16个actor phase、normal/cancel consumer、所有checkpoint/import/关闭与唯一runtime初始化构造，后者包含34×128 source history及128 GDownWindow等原持续义务。微top去除了这全部上下文，所以成功只保持“大聚合/跨phase别名与库操作相互作用”这个候选，不能定位到某一成员或declare actor为根因。

只有在无memcmp候选与精确Inputs转移候选仍无生成时，再依据新IR/原pass记录提出同一唯一Runtime内的明确representation/函数边界调整。不能直接缩减State历史、用多个top clone Runtime、丢取消/错误phase或重写授权边界来“验证”它。此报告不建议新的大拆分、必跑微实验清单、无依据inline pragma或延长120s保护。

## 关键原始证据身份

下列路径相对`executor_wide_fifo_diagnostic_01`；父可在原attempt复核，无需重跑工具。

| 原始证据 | SHA256 |
| --- | --- |
| `receipt.json` | `15f64f43322442d807e67c6d18d14d2ee4ae71abadbe2ffcc5210a08206fdba0` |
| `input_manifest.json` | `1f4ed0a1564dca0b6b46c5291fc51492316439f49cfef629560c0e577b876982` |
| `guard_hls/guard_result.json` | `89cb6fc0350847cd56e0641ff22053f294592a6e78fe5e17a841c60ce7ac49a5` |
| `guard_hls/driver.log` | `333f5419c61b639e3fcd00a8014f5b7434ce878b6aed8d51ef81b1a835d72d1c` |
| `work/hls/.autopilot/db/a.g.lto.bc` | `34fad1f8424c272f6ae39506af3221526699888d97312743ea612a429a115dce` |
| `work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.diag.yml` | `a32f1f0193ba0274ebe17707548761e11c362f9049aad02e553751feb9207f08` |
| `work/hls/.autopilot/db/autopilot.flow.log` | `11d4e849c79fb1a0dde5c581f6bb5e5b318fd61b118bb9ec425045986266d52b` |

executor02原gdce1216728B/SHA `a1184525b71685cb48b3ac5f6c20ad1df450e8ccc54728664ecf6624547e4266`。其旧COST_STOP身份及上一只读报告保留，不写回新候选结果。本轮没有执行新DUT，production executor/同runtime/实际shell接受/helper提交/唯一退休、完整model/graph/数值、安全physical closure/rearm、RTL反压、联合资源/物理时序/板端全部NOT_RUN，M003/M004未完成保持。
