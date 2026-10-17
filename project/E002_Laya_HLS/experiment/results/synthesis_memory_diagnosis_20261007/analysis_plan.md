# 综合内存增长诊断方案

本次只诊断主机编译器内存增长，不更改冻结生产源码、模型、build tag 或数值合同。用户要求保护其他项目；实验由唯一 Sol max 执行者按下面的预算串行开展。

## 已知事实与口径修正

- 扩大内存重试的 clang RSS 已记录峰值为 360.629 GiB，树 RSS 为 361.572 GiB；这是主机进程驻留内存，不是 FPGA 资源需求。
- Design Size Report 的顶层 1,078,825 指令是包含子调用路径的累计值，不能当作 108 万个独立 IR 节点。已有 cmplx 数据的 Performance-final 172 个函数自身 instructions 合计 61,991；随后 fe.simplify 合计 62,066，顶层 inclusive 1,078,899。实际执行中的后续 pass 尚未定位。
- 链接期 345 个函数自身 instructions 合计 35,853，而顶层 inclusive 为 2,590,344。大量调用路径确实存在，但不能单凭这个放大过的计数解释 360 GiB。
- 主输入 bitcode 约 2 MiB，13 个数值缓存共 8,641,536 B。小文件和有限源数据经过编译器对象展开、关系分析可能大幅增加内存；具体增长规律必须测量，不能由数量级差异直接断言泄漏或工具缺陷。
- 现有 reflow 诊断末尾为 descriptor 多维字段 complete partition；最后一条打印信息不一定对应当前正在耗内存的 pass，也不证明这些字段就是根因。

## 按证据优先级推进

1. 保留旧、新运行证据，核对实际 clang driver/cc1 命令、pass 开关、cmplx 顺序、bitcode checkpoints、旧 SIGTERM 栈。量化真实 IR、自身/累计口径、数组和常量，而不重新运行完整顶层。
2. Controller 已确认：在独立目录复制并重放现有 bitcode 的唯一原 clang reflow 子命令，仅用于诊断；不重跑源前端，不追求 RTL。硬上限 8 GiB RSS、192 GiB MemAvailable 底线；内存明显增长到 2/4 GiB 时采 2–3 次本任务栈/工具 pass 信息后结束。Sol 先核查 ptrace 可用性，只调试自己新建的诊断进程，不改变全局限制或其他进程。工具诊断开关在独立命令中留证，不能覆盖生产文件。
3. 根据定位到的 pass，选择下列一个最小对照；先测最小两档，只有结果能区分假设才继续增加尺寸。每次只改变一个变量，记录真实 pass、RSS、耗时、实际 IR 和优化后的数组；若相关代码被优化掉，该样本不能支持结论。

## 可证伪假设与对照

| 假设 | 源码证据/路径 | 首选对照变量 | 支持或反证的判据 |
| --- | --- | --- | --- |
| 大缓存的元素级分析/标量化导致增长 | 静态 FullRuntime→FullCache；weight_q[5373952] 经动态 index 指向 full_read，其他大数组在聚合结构内 | 保持动态读写和访问点数不变，仅将单个缓存容量按 4K、16K、64K、256K 元素递增；比较独立全局数组与等价嵌套 struct 两种形式，第二轮才改变形式 | RSS 是否随容量异常增长；哪个 pass 首先增长；结构变化是否消除同规模开销。必须保持数组真实存活，不以源声明尺寸代替优化后尺寸 |
| 动态 owner 指针/别名分析与访问点的交互 | find()/empty_slot() 遍历 record[32] 返回指针；每条记录含 covered_rows[64]/old_consumed_rows[64]；多个任务共享同一 runtime | 固定记录尺寸，记录数 2/4/8/16/32；或固定记录数、仅增加调用点。动态指针版与按索引访问版比较时其他代码完全一致 | 找到随对象数/调用数的非线性 RSS 或 pass；若小例未复现，不能认定生产路径无问题 |
| descriptor 剩余 partition/ROM传播 | kFullWeights[124] 与 kFullTensors[153] 的 name/hash/ne/qbase字段；动态 lookup/copy 到 current_weight | 提取 descriptor lookup，固定访问模式，记录数 8/32/124；完整字段与去除非计算 name/hash字段的实验副本一对一比较 | 相关 partition pass 是否出现，IR/峰值是否有数量级变化；移除字段只属诊断，不授权修改生产描述符 |
| 工具优化器算法/版本问题 | AMD clang cc1 同一 reflow 阶段内 RSS 急增，当前缺少分配栈 | 固定同一小复现输入，只改变已识别的一个 pass/可用的另一工具版本 | 需实际 stack/pass 和可复现开关/版本对照；禁把 kill 后通用 bug-report 提示认作工具自行崩溃证据 |

## 执行预算和取证

- 一次一个诊断任务；实验进程树 RSS 最大 32 GiB，MemAvailable 最低 192 GiB，任一先到即停止；bitcode 短重放拟采用更严格 8 GiB 上限。
- nice 19、原允许 affinity 中四个逻辑 CPU、idle I/O、OMP/MKL 等线程 2；只控制自己的新 session/已核对启动时间后代。
- 沿用已经修复的外置保护逻辑：先 STOP、保留有界现场，再 KILL；监控异常及退出亦清理自己的后代。不修改生产 runner 或其他进程。
- 原始日志保存 UTC；人读报告使用 Asia/Shanghai。本轮结果必须区分确定事实、实验证据支持的解释、仍未验证的推测。
- 所有实验源、命令、配置、源码 hash、guard、原始日志、IR 数字和峰值均留在本诊断目录。不得用小例综合 PASS 宣称生产完整 top 通过。

## 最终交付

给出能解释增长量级的实测尺度关系或具体工具 pass/栈；说明哪些候选已被证伪，哪些仍不确定。若仍未定位，列出本轮具体排除结果和唯一最有价值的下一步，不能只重复“图太大”。不以继续加主机内存作为根因解释。

## 首轮已核定实验合同

2026-10-07（Asia/Shanghai），controller批准优先执行一次有严格预算的 bitcode/reflow 定位实验。具体命令必须来自原始成功启动过的 cc1/reflow argv，输入复制到本目录，所有可写路径改成本目录。记录原始/诊断 argv 差异；仅允许诊断输出或用于debug的启动方式差异，不改变优化或硬件语义开关。若原命令重放条件不能完整重建，明确停止并报告，不擅自用不同优化过程替代。8 GiB是停止上限，不是实验目标；取得同一增长阶段的2–3个可读栈即可结束，随后由Astra根据结果决定唯一必要的最小对照。

## 源路径的进一步约束

- `include/laya_full_runtime.h:102` 声明13个大数值缓存；`hls/platform/full_kernel_wrapper.cpp:5`把整个 FullRuntime 声明为静态对象。两个 URAM pragma 只绑定 weight_q 与 weight_scale，源码中没有显式 ARRAY_PARTITION pragma。此事实不证明工具最终保留了原数组存储。
- `hls/common/laya_full_owner.cpp:114`的 find()/empty_slot() 扫描32个 owner 记录并返回动态记录指针；所有任务共享这组记录。它是对象/别名分析候选路径，不是已证实根因。
- `hls/memory/full_loader.cpp:115`把动态位置的 weight_q 切片作为 uint8_t 指针交给 full_read；`full_read`按BO枚举选择具名外部端口。大数组、动态地址和跨函数指针共同存在，需要由栈证明哪部分进入昂贵分析。
- `hls/common/laya_full_memory.cpp:97`的 full_equal_weight() 实际比较两个 SHA256 数组和 name48。full_lookup_weight() 扫描124项并复制整descriptor；full_lookup_tensor()/embedding_table()扫描153项并比较名称。名称/hash不能直接称为“未使用的调试字段”，实验删除字段即使降内存，也不等于生产可无损删除。
- 原SIGTERM记录只有通用 Terminated/bug-report提示，没有真实调用栈。当前高内存执行者是AMD厂商LLVM7 clang `-cc1` reflow，而不是早期源代码分析的clang16。
- 现有 reflow输入 a.g.ld.5.gdce.bc 为2,077,332 B。厂商llvm-dis统计1045个有定义函数、65个声明、910 globals，约72,736条文本IR指令行；这是进入该整段reflow之前的另一checkpoint，与cmplx阶段自身指令统计不应混为同一时刻的数据。最终 a.g.lto.bc 尚未产生。

## 首轮结果及唯一追加对照

受限reflow重放于本地15:58启动，最多约4.019 GiB树RSS即按计划停止并清理。前两次栈分别位于自动数组划分的PredicateAnalyzer/CUDD初始化、LoopFlattenCostModel，它们随后释放或继续，不能混同最终360 GiB增长。第三栈落在 `HLSGen::runOnModule → HLSBuilder::generateGlobals → rewriteGlobalVariableInitializer → HLSRewriter::mapBytes → HLSIRBuilder::GenerateBitConcat → ConstantInt::get`。这将下一验证聚焦为巨大全局初始值的转换/位拼接。

只读原IR证实：`runtime`是显式ConstantStruct，包含208个嵌套zeroinitializer以及i8 -1/i8 6等非零默认值。DWARF类型布局给出FullRuntime 8,720,240 B、FullCache 8,642,664 B、FullOwners 65,552 B；FullCache的13个大数值数组均为zeroinitializer。这个布局总尺寸包含元数据和对齐，和8,641,536 B数值数组容量口径不同。尚无APInt实际bitwidth或分配累计量，不能直接声称平方增长或内存泄漏。

Controller核定的唯一追加实验：

- 新建独立`init_probe`，不包含生产Runtime。`struct State { uint8_t flag; uint8_t data[N]; }; static State state = {INITIAL_FLAG, {}};`，flag在数组前。
- top接受动态index/value，保存old=data[i]、oldflag=flag，再写data[i]=value和flag^=value，返回`old | (oldflag << 8)`；i=index&(N-1)。这样两类状态都动态存活，不能被常量折叠为一个固定返回值。
- N仅4096和16384，INITIAL_FLAG仅0和1，共4次串行。同尺寸对照仅改变1个初始值；两尺寸对照仅改变N。保持ram_1p/uram data存储pragma、实验part/150MHz和既定三项低自动化配置。
- 每次RSS上限8 GiB、MemAvailable底线192 GiB、nice19/4CPU/idleIO。先查看实际IR的数组长度、动态访问、初值和ObjectDecomposition后的形态；若全被优化掉，样本无效。记录峰值、耗时和完成/保护状态，不做整网cosim。
- 四次结果回到Astra后才能决定是否需要第三个尺寸或字段位置对照。禁止真实5m数组。差异应由实测RSS随N的关系、同一HLSGen热点和实际常量布局支持，不能仅凭第三栈猜测因果。

## 精确位宽探针（替代追加源码小例）

四个简单State小例均被拆成flag/data两个global，且reflow仅约0.109秒，现有采样不足以准确比较短峰；它们没有复现原聚合初始化路径，不能作为反证。Controller批准唯一一次精确GDB重放，不继续扩展小例。仍采用8GiB/192GiB保护和低优先级。

先在HLSGen::runOnModule入口停，再对GenerateBitConcat入口0x14b0da0设有条件临时断点（目标位宽>=1,048,576bits）。按SysV ABI读取rcx为IntegerType*、rdx为ArrayRef元素数、rsi为其起址；位宽为`*(uint32_t*)(type+8)>>8`。然后在0x14b0edc常量创建callsite读取rdi所指type位宽、r12累计bit偏移、r15/rbx/rsp及bt。最多额外两个大concat入口以辨别对象；不得逐片段高频断点遍历。取得位宽/分片数/偏移即停止，不追求大内存复现。名字无法从已有符号/IR映射取得则保留不确定，不调用不明inferior函数。

只读binary证据保存在`GenerateBitConcat.disassembly.txt`、`ConstantInt_get.disassembly.txt`和`binary_evidence.json`。循环先将源片段转换到目标整数宽度，再用同宽ConstantInt编码累计shift offset；即使源片段为零，零值检查也发生在offset常量创建之后。ConstantInt使用LLVMContext的APInt→ConstantInt表驻留唯一常量。仍须以现场W/M值支撑量级解释，不能把条件公式当已测的完整峰值或内存泄漏。

## 精确测量与最后一项IR初值对照的结果

精确探针读到W=2,653,009 bits、M=6,480,158个输入分片；常量创建处W相同、首次偏移为0。一次APInt密集载荷为331,632B，键和值两份为663,264B；360GiB相当于约58.3万个不同常量的两份载荷，属于条件量级换算，不是实测分配次数。探针1秒采样在8.44GiB树RSS读到越限并停止，保留超调事实。

Controller最后只授权一项复制IR对照：仅把`runtime`的顶层显式初值替换为整体零初值，其余IR逐字不变；使用原reflow命令的同一优化参数、复制可写路径、nice19/4CPU/idle I/O、8GiB RSS停止阈值、192GiB可用内存底线和0.2秒采样。后续澄清批准HLSGen完成标记即停，或cc1自然结束；不要求a.g.lto.bc，不追加第二次重放或任何后续综合。

本轮实际cc1自然退出1，整体采样峰值3,738,992KiB；前置15阶段归一函数统计与原运行相同。变体在HLSGen进入后约3秒报告`full_recycle_request`的pointer phi/select错误，无HLSGen完成标记或a.g.lto.bc。真实编译器的只读调用顺序显示globals先于functions，错误对应FunctionBuilder::visitSelectInst；因此对照支持避开全局初值热点、推进至后续函数转换，但不是完整阶段或数值验证通过，也不证明该后续错误存在于冻结生产输入。最终结论与范围以[报告](report.md)、[唯一对照记录](reflow_runtime_zero_probe/runtime_zero_probe_findings.md)和[审核](final_review.json)为准；本轮诊断到此结束。
