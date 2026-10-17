# A005：executor_hls_01→02 COST_STOP只读结构定位

日期：2026-10-13。父A002为共享实现/集成及单重工具owner。本轮唯一写入本文件和`agent/A005/result.md`；只读01/02冻结源码、日志、报告和最后完成bitcode。使用现有`llvm-dis -o -`及`c++filt`做小量内存解析，不写attempt或`.ll`，不编译、不重启HLS/RTL、不改预算、不创建后代。父当前独立推进explicit-key候选；本诊断不替其结果。

## 结论

01和02停在相同可见LTO reflow阶段；两次归一化reflow命令完全相同，最后均为同五个8192位stream端口的disaggregate成功remark。02的优化记录明确标记`Pass: reflow-disaggr / Name: DisaggrSucc`，所以能够确认完成了这些被命名端口的变换；不能把最后一条成功日志解释为该端口本身卡死，也不能确认其后的私有内部pass、死锁或特定struct为直接原因。

联合NORM专用路径与完整byte-loop比较改动使Compile/Link调用树累计266124→226981，下降39143（14.71%）；直接、独立的gdce IR非debug指令只有41689→41517，下降172（0.41%）。两种口径不可替换。sourceanalysis、owned RSS及停止点没有得到对应改善，尚未生成top；不能将累计差全部归NORM，或写成综合/硬件性能改善。

两次所有99个named LLVM struct定义逐字相同；持久Entry仍304640字节，内含唯一275808字节FullRuntime。stream仍把2464字节Inputs整体load再store到第二局部对象，但没有FullRuntime整体load/store克隆。后者是下一项明确且尚未被01/02改变的最小结构减法；它有IR证据，但其停滞因果仍未验证。

另外，02仍存在真实、top可达的外部`memcmp`路径：top中两个1024字节std::array比较，以及actor `observe_host_result`中一个256字节比较。已实际通知父；这是完整库比较修复线索，不是已证明的COST_STOP根因。

## 对照条件与guard事实

两次实际top、25个production source、五个defines、v++ executable身份和实际复用driver身份相同。defines为partitioned caller、transaction sequencer、sequencer codec、FIRST及`AP_INT_MAX_W=8192`。目标U55C、150MHz/6.667ns、Vivado flow、pipeline_loops=0、array throughput partition off及complete_threshold=0不变。源码包含NORM专用和多个codec/top的packet_equal改动，比较不是单变量实验。

| 原始指标 | executor_hls_01 | executor_hls_02 |
| --- | ---: | ---: |
| receipt/guard | COST_STOP / semantic_stall | COST_STOP / semantic_stall |
| elapsed seconds | 280.460530 | 285.493267 |
| semantic stop interval seconds | 120.081628 | 120.071008 |
| peak owned RSS KiB | 1477768 | 1476484 |
| 实际RSS samples/captures | 1401 | 1426 |
| minimum MemAvailable KiB | 394223280 | 387041848 |
| child exit | -9 | -9 |
| Source Analysis/Preprocessing seconds | 109.28 | 109.95 |
| Compile/Link累计instructions | 266124 | 226981 |
| Unroll/Inline | pending | pending |
| work现存files / bytes | 543 / 74586132 | 543 / 74658264 |
| 最新work mtime UTC | 01:41:00.711353 | 02:22:10.142046 |

原CPU0–3/nice19/idle I/O、MemAvailable严格>192GiB、static24GiB/1800s、120s真实停滞保持。两次最终work最新文件均为reflow err日志；02在02:22:29及02:23:29 UTC的artifact highwater均543/74658264，最后一次进展由5秒artifact采样观察，最终02:24:14.423682触发。没有同大小原地写或hidden db被漏看的现存证据；进程内部运算和CPU忙仍不能代签已完成pass。

## 最后完成pass与具体变换

01/02均完成：设计link→`reflow-lower-math-intrinsics`→HLS库link→`reflow-globaldce / reflow-float-conversion`→float库link→`reflow-globaldce`，最后完整产物`a.g.ld.5.gdce.bc`。随后clang-3.9-csynth路径启动LTO reflow，输入此bitcode、目标`a.g.lto.bc`，带完整接口/聚合参数：`reflow-aggregate-bitwidth-threshold=4096`、auto array promotion/partition开、`disable-inlined-alloca-merging=true`、`hls-bitcode-version=3.1`。归一化两attempt绝对路径后，整条reflow命令逐字相等。

| 最末文件 | 01 bytes / UTC | 02 bytes / UTC |
| --- | --- | --- |
| `a.g.ld.0.bc` | 1784688 / 01:40:37.037629 | 1816404 / 02:21:46.158288 |
| `a.g.ld.5.gdce.bc` | 1223764 / 01:40:40.587188 | 1216728 / 02:21:49.993889 |
| `a.g.lto-*.bc.tmp` | 0 / 01:40:40.796221 | 0 / 02:21:50.190920 |
| reflow diag.yml | 1024000 / 01:40:41.289298 | 1007616 / 02:22:10.139046 |
| reflow err.log | 369299 / 01:41:00.711353 | 360692 / 02:22:10.142046 |

最后六条err日志内容相同，仅源码位置99→100：inline `FullMemory::FullMemory()`，再disaggregate `program_pending`、`program_owner_receipt`、`program_owner`、`control_response_rejection`、`control_response_receipt`。NeverInline1138→1127，两次都只有这一条明确inline成功、五条disaggregate成功。没有自动inline爆炸证据。01 diag在NeverInline对象名处截断；02 diag已写到reflow-disaggr的成功记录，最后一条仍截断。此差异是日志buffer落盘边界，不代表02完成了新的整体综合阶段。

gdce IR中的宽口是多层聚合：`hls::stream<ap_uint<8192>> → ap_uint<8192> → ap_int_base<8192,false> → ssdm_int<8192,false> → i8192`。其write_nb调用aggregate类型的`llvm.fpga.fifo.nb.push...ap_uint<8192>`，read_nb调用返回`{i1, ap_uint<8192>}`的`llvm.fpga.fifo.nb.pop...`。所以末日志的具体动作是对C++ stream/ap_uint包装聚合的HLS disaggregate/interface处理，不是源C++ byte-loop比较或普通LLVM globaldce；最终标量FIFO端口/RTL尚不存在，不能从前端IR签端口展开完成。

两次无完整`a.g.lto.bc`、`kernel.internal.xml`或`top-io-fe.xml`，syn下无generated `.v/.sv/.vhd/.dcp`。只能定位到最后可见变换，不能从参数名或成功remark推断私有pass下一步正在处理哪个Runtime成员。

## 累计调用树与独立IR分开计数

下表来自design_size.rpt，同函数/位置取最大累计条目；含其子调用和报告calls，不可相加、也不可再次乘calls。位置02引用新冻结行，01完整原位置见前次报告。

| 调用树条目 | 01累计 | 02累计 | 02 rpt行 |
| --- | ---: | ---: | ---: |
| top | 266124 | 226981 | 23 |
| executor_stream::step | 238192 | 199200 | 569 |
| executor::step | 210006 | 171272 | 798 |
| lifecycle::port_step | 130403 | 92254 | 1047 |
| lifecycle::step | 123872 | 85723 | 1054 |
| lifecycle::send（5 calls） | 20635 | 20635 | 1110 |
| owner_event（3 calls） | 44307 | 19575 | 1160 |
| owner builder（3 calls，02为NORM专用） | 29214 | 4482 | 1167 |
| BEGIN builder（02为NORM专用） | 16350 | 2933 | 1494 |
| handoff::decode（2 calls） | 18550 | 18414 | 579 |
| transaction::encode（5 calls） | 18035 | 18035 | 1111 |
| executor::response_key（4 calls） | 14152 | 13980 | 799 |
| transaction::decode | 13117 | 13117 | 1067 |

02仍包含其他合法caller的通用full_f32_address；NORM owner已替换不等于全设计地址逻辑消失。port/FSM累计下降38149是相同受影响子树的重复展示，不能分别相加；owner/BEGIN属于其中的下层。packet_equal以显式完整串行loop保留验证，并改变其他codec比较树。因此只报告这些路径的观测差，未建立NORM单独或packet_equal单独因果比例。

独立计数来自最后已完成gdce bitcode，只计各defined函数体一次、排除`llvm.dbg.*`调用；不展开调用、不乘调用次数。每条opcode起始行计一个instruction，label/metadata/续行不计，call计调用本身。

| 独立IR指标 | 01 | 02 |
| --- | ---: | ---: |
| defined functions | 466 | 459 |
| named struct types | 99 | 99（定义逐字相同） |
| 非debug直接instructions | 41689 | 41517 |
| aggregate typed load+store站点 | 964 | 962 |
| 实际llvm.memcpy站点 | 1 | 1（8字节owner_plan常量） |

| 直接函数体非debuginstructions | 01 | 02 |
| --- | ---: | ---: |
| executor::step | 2182 | 2182 |
| lifecycle::step | 1786 | 1786 |
| transaction::decode | 1519 | 1519 |
| full_decode_validate_request | 1126 | 1126 |
| top | 806 | 806 |
| lifecycle::start | 783 | 783 |
| executor_stream::step | 778 | 779 |
| checkpoint::accept | 641 | 641 |

这是pre-LTO IR，尚未完成inline/unroll或硬件lowering；比调用树小并不代表综合成本也同比小。已有核心函数体和聚合对象未发生大的结构改变，解释了“累计规模降很多”不足以证明本次停滞已解除。

## 保留的聚合结构与明确copy

字节数由IR ctor参数`dereferenceable(N)`及DICompositeType的size交叉一致；是编译ABI对象尺寸，不是综合RAM/寄存器资源。scalar leaves只按named type递归展开固定数组和struct，整数/float/pointer各计1；是潜在聚合形状，不是工具实际flatten数量、IR指令或硬件资源。以下父子均inclusive，不能相加。

| 持久/临时对象 | ABI bytes | 递归scalar leaves | 01/02变化 |
| --- | ---: | ---: | --- |
| 唯一static Entry | 304640 | 145073 | 无 |
| Entry.actor / executor::State | 293888 | — | 无 |
| State.runtime / FullRuntime | 275808 | 121385 | 无 |
| FullRuntime.owners / FullOwners | 227120 | 104069 | 无 |
| FullRuntime.g_down_plan / GDownPlan | 33936 | 11224 | 无 |
| FullRuntime.inputs / FullInputs | 10496 | — | 无 |
| Entry.transport | 7592 | 7225 | 无 |
| 单次executor::Inputs | 2464 | 1881 | 无 |

FullOwners包含32个完整FullOwnerRecord、34个SourceProvenanceRecord；每个source含128个完整SourceWindowProvenance，以及原QKV/RoPE/head行历史数组。GDownPlan含128个完整GDownWindow。这些是当前持续Runtime/历史义务，不能因FIRST诊断仅执行NORM就删除、缩小、每次重新构造或移到Host。synthesis已排除FullCache软件tensor大数组，不能再把这些实际编译结构误称CPU weight tensor。

两次IR都直接存在stream `Inputs in=live`对应的：

```llvm
%2 = load %"struct.laya::executor::Inputs", %"struct.laya::executor::Inputs"* %1, align 8
store %"struct.laya::executor::Inputs" %2, %"struct.laya::executor::Inputs"* %in, align 8
```

这不是memcpy；查memcpy会漏掉真正的2464字节aggregate SSA值。top自身已有一个本调用的Inputs临时对象，stream又分配第二个。copy包含完整handoff Message、physical map、256字节Host result和1024字节cancel pending record，后续stream按真实consumer事实覆盖部分字段。两次没有FullRuntime整体aggregate load/store；runtime只以唯一持久对象引用传递。不能把局部Inputs复制推广为“整个Runtime被反复复制”。

## 仍可达的memcmp：可具体修复的库路径

02保留`declare i32 @memcmp(i8*,i8*,i64)`。唯一直接调用站点在`std::__equal<true>::equal<unsigned char>`，但上层有三处实际完整array比较；直接站点1不等于业务调用1。沿top直接调用图459/459个defined函数均可达，三处比较也可达：

| 冻结调用位置 | 比较的完整对象 | IR debug位置 |
| --- | --- | --- |
| executor_hls.cpp:216 | echo与原program_owner，1024B | line216/column52 |
| executor_hls.cpp:237 | pending与已保存program_pending，1024B | line237/column50 |
| executor_actor.cpp:105 | in.host_result与s.result_packet，256B | line105/column22 |

实际IR调用链为top或actor→`std::operator==<unsigned char,N>`→`std::equal`→`std::__equal_aux`→`std::__equal<true>::equal`→`memcmp`。02已经把其他比较换成packet_equal，仍留这三处；已向父发真实消息，包括其先发现的两处top和新发现的Host result一处。更改仍须比较全部原bytes，保留原decode、reserved-byte、完整K/commit、late/replay拒绝和accepted原子握手。现有证据不能证明memcmp导致本次同pass停滞，也不能用删除比较来验证。

## 下一有区分力诊断、最小结构减法与分区边界

父当前explicit-key候选及上述完整库比较修复有各自新身份，先按其真实结果判断。本诊断不要求原02重跑、不增加宽口微top必跑清单、不扩大预算或依赖无证据inline pragma。

父随后转达主控R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION：program有限生成已接纳，需要区分unsupported操作、五宽口lowering和完整actor状态图。依据这项最新方向，**优先的单个可选诊断是原五宽口微top对照**；这是有区分力的结构对照，不是再做一轮累计指令减法或必跑清单。保留原五个8192位ap_fifo的准确方向（control_response_receipt/rejection、program_owner三个输出；program_owner_receipt/pending两个输入）、实际write_nb/read_nb调用与其原包保持/反压语义，移除actor/FSM/Runtime调用树，使用一个有界稳定完整record；采用已明确的byte-loop比较而不引入memcmp。顶层常量/固定data只属于诊断刺激，不能代签真实准入、helper、完整shell accepted或program消费。

若这个有限对照在原24GiB/1800s/120s真实停滞帽内生成并越过reflow，则五宽口本身不是充分停止条件，下一步才聚焦完整actor聚合/状态图或其中仍unsupported的操作；微top PASS不能独自证明actor状态图就是根因。若移除完整调用树后仍在同样五口变换附近COST_STOP，则得到wide lowering有独立贡献的强证据，下一接口候选才有理由针对宽对象表达而非继续削NORM累计数。它仍不能证明内部死锁或允许缩减全包/原子accepted握手。新的program生成说明当前平台能够生成某个相关有限设计，不能替代原五方向接口的独立对照。本轮仅提出这个候选，未创建源码或执行工具。

若进一步需要完整候选的结构减法，01/02尚未改变、现有IR能够精确定位的最小项，是为top独占的本调用Inputs提供in-place/owned step入口：top原临时对象直接供stream写入真实消费事实，host通用const API可保留原copy适配。只移除这一个2464B整体load/store和第二临时对象；完整cancel pending bytes、原packet保存、codec/完整key/model/base、事实生成顺序及旧owner撤销不变。不得把共享live输入直接变为可变、让任意caller注入已消费bool，或复制/清空Runtime。该改动原输入对象生命周期和独占性有top源码/IR依据；对pass成本的收益尚未知，需现有受影响host消费/取消检查及父新冻结guarded候选验证，不能许诺减少多少instructions或必过reflow。它单独对三个根因假设的区分力弱于上述有限对照，不应因容易修改就自动成为默认再试候选。

如果同样的停止点继续存在而需要真正切断剩余92k累计lifecycle子树，分区不能只把port/FSM挪成另一个top后在两边各留Runtime。当前FIRST准入、checkpoint helper原子import和action/owner/allocator退休都读写同一Runtime，必须有唯一Runtime owner。真正切分至少需要以下明确内部事务；这是必要语义边界说明，不是本轮新增已核定接口：

- FIRST admission由同一Runtime owner完成原完整LYRQ/LYMP及物理映射验证，输出原完整A；入口安装receipt和持久撤销仍按真实全包消费者事实反馈。
- helper import把原完整LBR2及冻结完整A/K/fence送唯一Runtime owner，沿原helper全部校验与一次atomic commit；返回绑定同一完整owner/输入对象的提交结果和真实下界，actor据其实际消费再构造IMPORT_OK，不能由transport自行宣告成功。
- action request/completion沿现完整LAP1/LAC1固定wire及真实depth2消费者传递，Runtime owner独占Port/Machine、allocator/owner/history/seq及唯一typed退休。事务adapter/physical END/hub仍保持原唯一物理权威。
- 多种内部请求串行、最多一个旧事务及一个有界返回；full A/K引用必须稳定且完整可核，cancel不重绑/清空旧半帧或结果。跨边界不传C指针、整可变Runtime、短hash或无tag长期bool；完整包与原子验证不削减。

这种职责切分才真实移除入口top对lifecycle实现的同步调用闭包；仅换文件、留下动态fallback或clone Runtime不能算完成。已有接口并不直接提供这些Runtime命令，因此分区需要父/架构owner明确合同；不能为规避当前停滞自行偷偷迁权。本轮没有实施或执行该分区。

## 身份与可复核读取

读LLVM用Vitis安装自带`lnx64/tools/clang-3.9-csynth/bin/llvm-dis`，工具实际`--version`为LLVM7.0.0svn；SHA256 `880acc2948de595512d36d9cd996b64e2e213e9ac3fb8e13db55d62c326ae4b6`。初始直接启动缺`libsqlite3.45.1.so`，随后只给诊断子进程设置安装内`Vitis/lib/lnx64.o`库搜索路径，未安装/修改工具。读取方式`llvm-dis <attempt>/work/hls/.autopilot/db/a.g.ld.5.gdce.bc -o -`，stdout仅在内存解析，CPU0–3/nice19/idle I/O，每次30s小工具timeout；未写attempt。计数规则和关键IR摘录见上文，可从同bitcode/tool复算。

| 相对各attempt文件 | 01 SHA256 | 02 SHA256 |
| --- | --- | --- |
| input_manifest.json | 9cd56f47f29acaa1fda45437cac0bf37712cda3143f37e648161535bce4b6bcb | 0edff41591aa752c701f874b8af3867e9c4b96eb64f11aeed1132759433f23be |
| receipt.json | 1d43bcf93e87c4caeddd3758f7eb43957bbb12fc463522f5da0449659f6ab537 | 3d37f7b1c233b51220d525f0e8aadcd079cc345374ec5af5c47d159cd7062ee0 |
| guard_hls/guard_result.json | 1d803922c3042f8e646052318189754fe380ec9a5c44d2319271d2265fd2243b | 554d3240eb1e6828085927a7f7d9e6310a36b13943b7fbfb06e90761d88880d0 |
| guard_hls/guard_trigger.json | 36d0896bd47f63cecbadd3791ce64aabc19d0313b33816530ae3069bce1b87bf | 4094fc684dc27743784c86c30594683c28d567212cced745e3328487e99f8354 |
| work/hls/.autopilot/db/a.g.ld.5.gdce.bc | 5713209b11b5e8c632b216b782f9c3a51c203e69653116e74f04ee2662be8499 | a1184525b71685cb48b3ac5f6c20ad1df450e8ccc54728664ecf6624547e4266 |
| work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.err.log | 327613d4127a15112ec5ec13292cf1deb482d4f83de8e155b200f6a23d8f18f5 | cfc34b8d805ef3bf4770fc9f4bb68e859d80cab1568871b1984dec3f67036755 |
| work/hls/.autopilot/db/a.g.ld.0.bc.clang.reflow.diag.yml | b9ffc42ead33dbda4d2424403a038629f0cddd404a38befc33b46f90edba2eb6 | ab232c2e76e0b6b03eabf6fbefa34635e678e388db9a589e79407ed1223563e3 |
| work/hls/syn/report/csynth_design_size.rpt | 157fb9e4c47931d4beb52260c245a7ccee3ff4d98ac126341082b08b27e2765f | ba90fdd06d0c8266ffd401afc9fbaa8c5387059544531f69c3abe3779f438722 |
| frozen/hls/control/executor_hls.cpp | 91dbdd4166629bc2339fb6063e290cb5db2fa627a9d59e23fef7f6f42152d172 | 1fe70679d86b5ad7855d600f7b33654c0b41f6b57fda7133efccd3694ddb3a34 |
| frozen/hls/control/executor_stream.cpp | f0ebe047556b77ee93d3b999f4c45eb99dd79e4330d8f0b62a19b42b351f23b6 | fc9d0c8450888565d976ea14db23c4abd9229d959f4e466e62301d3a5a4bd826 |
| frozen/hls/control/executor_actor.cpp | 6fa40035390ada006f3e825afc7d5fabb07c58ae38f114ec77b0a150f248b2b1 | ec111529a37d21af5d9dce05c8aa9fc4f3b5dc2688d0b215f65d6e49e858a923 |

两次冻结`laya_full_runtime.h` SHA同`3d32915e0f0319ae929b59b96de2fb949d89ef04c051a235021200789f784cfa`，`laya_executor_actor.h`同`674447592cbee1089b346125d9d1366561f91241f4fd8b2f8d2b32d365776ef2`，`laya_executor_stream.h`同`4137d042cfa5f625e67b47e1e72c73be9287ce2847e49094d3097325a94bd3ec`，与聚合类型无变化吻合。02 packet_equal.h SHA为`15208715792a535a5b7259db8b8126c22c6c30168561eb716eec0698cd4744cb`。

HLS结果保持COST_STOP；generated top/端口、联合资源/时序、同runtime业务/物理安全closure、完整model及板端均NOT_RUN。本诊断不提升任何此前host或局部RTL PASS范围。
