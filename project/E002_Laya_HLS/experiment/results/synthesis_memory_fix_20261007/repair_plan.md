# 综合内存修复合同 r1（2026-10-07，Astra xhigh）

## 目标、隔离与冻结边界

修复已实测的`runtime`混合巨型初值→宽整数常量展开，并处理验证途中发现的owner动态指针选择结构；以实际综合报告为最终准绳，继续完成完整top RTL。原[诊断](../synthesis_memory_diagnosis_20261007/report.md)与build tag `4f12ecfe940ecf2a8998a8626fc1ed1c`的CPU/CSim证据保留。

- 唯一实施者：GPT-6 Sol max；设计/合同/验收：GPT-6 Astra xhigh。先设计、后实施、再审核。
- 原工程：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`。
- 独立候选：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007`。代码、构建、导出包和回归输出均在此或新的专用结果目录；原reference symlink仅作只读输入。禁止覆写原GGUF、oracle、旧model-p2-final、旧运行证据或工具安装。
- 13参数外部接口、模型/数值/布局语义、全部数组元素类型/尺寸、所有权状态含义、请求/复位/恢复顺序和§12.2数值前像保持不变。§12.2前像4953 B，SHA-256 `aeb13e7937d29fe6a2c68c407249f294212aa24f4e45fd3862b092795ab066f7`。
- 器件仍`xcu55c-fsvh2892-2L-e`、150MHz；`pipeline_loops=0`、`throughput_driven=off`、`complete_threshold=0`。F0仍串行，不因64bit存储字声称8路/4路并行计算或性能达标。

## A. 将数值RAM与非零控制初值分开

核定采用**13个独立、全零的synthesis全局数组＋固定数组访问器**。不采用静态cache指针/引用成员、不用raw byte storage重解释、不改默认枚举来追求全零，也不增加首次调用清零8MiB缓存的初始化循环。

1. `FullRuntime::cache`在普通CPU/CSim下继续拥有原来的13个数组，保证多个CPU Runtime各自独立；在`__SYNTHESIS__`下仅保留原`activation_source_ledger`和`activation_meta`。所有控制字段和嵌套类型的原默认值逐字保留，包括INVALID=6、layer/batch/bo=255、Check.bad_element=UINT64_MAX、各ref/epoch/valid/identity初值。
2. 新增`include/laya_full_cache_storage.h`：按下表声明精确数组类型与13个名字固定的访问器，如`full_cache_weight_q(rt)`。CPU返回`rt.cache.weight_q`，synthesis直接返回唯一对应全局数组；访问器在HLS强制inline，不含按运行时枚举选择数组的分支。需要const时提供保持const的重载。禁止在静态对象中保存这些引用。
3. 新增`hls/platform/full_cache_storage.cpp`：在`__SYNTHESIS__`下定义13个独立、可写、静态寿命的全零数组，CPU不增加共享缓存。由正常生产source list编译，禁止测试专用实现替代生产定义。核实链接后每个数组只存在一个对象，所有使用者指向同一对象。
4. 修改实际缓存访问点使用固定访问器；`rt.cache.activation_meta`与`activation_source_ledger`仍直接访问原metadata。loader传字节切片给`full_read`、浮点leaf传数组的顺序和范围不变。不能改数值leaf、截断数组或减少有效范围。
5. wrapper的两个BIND_STORAGE转到真实独立`weight_q`、`weight_scale`对象，仍`ram_1p/uram`。输入/output端口仍由调用期局部`FullMemory`传递；不存在静态外部AXI指针。

| 数组 | 类型与形状 | 字节数 |
| --- | --- | ---: |
| weight_q | int8_t[5373952] | 5,373,952 |
| weight_scale | uint16_t[167936] | 335,872 |
| weight_bias | float[5248] | 20,992 |
| activation_q | int8_t[16][128][32] | 65,536 |
| activation_scale | uint16_t[16][128] | 4,096 |
| input_tile | float[16][4096] | 262,144 |
| ps_tile | float[16][5248] | 335,872 |
| gamma | float[2][1024] | 8,192 |
| rope_table | float[2][1025][64] | 524,800 |
| kv | float[2][2][1024][64] | 1,048,576 |
| score | float[2][16][1024] | 131,072 |
| av_partial | float[16][64] | 4,096 |
| fp_act_weight | uint16_t[256][1028] | 526,336 |
| 合计 | 13个数值RAM，未含控制metadata/局部数组/物理碎片 | 8,641,536 |

冷启动逻辑状态与旧实现一致：这些数值数组原来即全零，控制metadata保留全部非零初值。请求回收和soft reset继续只按原逻辑失效/更新metadata，不额外清数值RAM、不重置epoch高水位、不使旧请求重新合法。硬件复位的实际RAM配置行为和平台reset仍以生成实现验证，不借源码静态初值宣称板级复位验收。

## B. owner查找改为索引，保留原子性

仅在`hls/common/laya_full_owner.cpp`内把`find`、`empty_slot`、`claim_slot`这类返回可空record指针的私有helper改为索引：合法0…31，固定32作not-found。`find_index`按原顺序返回第一个same_physical匹配；`empty_index`返回第一个ref.id==NONE；`claim_index`仍先找已有物理对象再找空槽，所有原约束和拒绝原因保持。

- 所有访问先排除32，再用`rt.owners.record[index]`直接索引或建立局部引用。不保留null与record地址之间的phi/select、不返回运行时选择的record指针、不建立指针数组。
- QKV成对claim必须仍在写入前完成两槽选择与全部拒绝检查；两者首次命中同一空槽时，第二槽按原顺序选择排除第一槽的首空槽，保证两个不同槽。失败不得部分fill、改变owner_claims或清coverage。
- `full_recycle_request`先完成所有busy/readers拒绝检查，再同步A8 record与numeric metadata高水位；仅numeric A8合法且无owner时才选空槽。没有空槽时不写。随后原失效、coverage清理、counter和请求gate处理顺序保留。
- 保留最大epoch/溢出规则、same_physical特殊alias、旧lease ref、双shard事务边界、已接受失败后的恢复与last_accepted_request_id水位。不得用整块memset替代typed reset。

## C. URAM存储字核查与唯一打包方案

已核查旧实际report：4,096×8bits单bank使用1 URAM，16,384×8bits使用4 URAM（旧init_probe的Memory表）。若同样窄映射用于完整W，条件外推weight_q需1,312、scale需41 URAM，不能把8.24MiB逻辑容量直接当板上可用空间；这不是完整设计实测结论。

Controller已批准唯一打包pilot：`weight_q`使用cyclic ARRAY_RESHAPE factor=8、`weight_scale`factor=4、dim=1，两者逻辑存储字64bits，保留数组元素类型和逻辑索引。条件容量为164+11=175 URAM；实际必须以生成report的字宽、深度、端口、banks和URAM数核对。其余11数组不在此轮擅自reshape。允许小型RMW增加周期，由HLS正确排序读/写；不改变F0算术发射合同，不增加手工并行或不同归约顺序。

先通过结构pilot的边界/尾部/邻元素保护和signed Q8回读再纳入候选wrapper。若reshape被忽略、出现数组复制/不支持的端口结构，停在该门禁提交证据，不盲试多个factor或直接运行整网。

## 精确代码与文件范围

预计生产变更仅在以下文件；需要扩大范围时先回Astra审核：

- `include/laya_full_runtime.h`：仅synthesis缓存成员布局；新增`include/laya_full_cache_storage.h`。
- 新增`hls/platform/full_cache_storage.cpp`；`hls/platform/full_kernel_wrapper.cpp`：真实RAM绑定与经pilot验收的reshape。
- `hls/common/laya_full_owner.cpp`：索引化owner访问，metadata语义不变。
- `hls/memory/full_loader.cpp`、`hls/operators/full_tasks.cpp`、`full_tasks_front.cpp`、`full_tasks_attention.cpp`、`full_tasks_tail.cpp`：仅13数组访问器的机械替换。
- `config/full_sources.cmake`和`config/full_module_registry.json`登记新增storage源，归kernel_wrapper；模块数仍15，生产源数相应由24到25，以实际闭包判定，不改门禁来硬写旧数量。
- 新的结构/owner/shadow测试与专用保护运行器可放候选`tests/`及新的结果目录。仅为登记真实新增source或执行这些独立门禁修改构建入口；禁止弱化既有assert、expected、严格source检查、数值阈值或跳过原用例。
- HLS 8份完整/共享算术compute与`hls/common/laya_numeric.cpp`不改。实际修复diff须逐文件提交Astra，并机械核对数值前像及算术文件不变。

在写相应代码前，候选模块`source/design.md`与`source/results.md`增加本合同引用、当前候选状态和实际/待测边界。重点是kernel_wrapper、hbm_loader_and_cache、forward_controller；机械接入的embedding、layernorm、activation_quantizer、q8_linear、rope、attention、decision模块也指向同一合同，不另编预算。

## 分阶段验证与资源保护

任何时候只运行一个本任务的重工作业。继承已核查的owned-session/启动时间保护：nice19、原affinity中4个逻辑CPU、idle I/O，0.2秒采样；主机MemAvailable底线192GiB。结构pilot/精确reflow用8GiB树RSS停止阈值；最终CPU/CSim/完整csynth用32GiB树RSS阈值。触发立即STOP/有界留证/KILL自身任务；超调实记。不得终止其他项目进程、调整系统策略或再扩大到数百GiB。构建最多4并发；既有runner若写-j8，候选改为可配置且默认为4后再派生最终build身份。

1. **结构与owner门禁。** 使用真实候选global定义、固定访问器与实际metadata/owner代码的独立小顶层，动态读写使所有验证对象真实存活。验证13数组分离、无静态cache指针和巨型混合初值；LLVM输入/输出的实际存活数组、长度、初始化形式必须留证，不能用已优化掉的声明作PASS。打包pilot回读覆盖首/末元素、7/8和3/4等word交界、末word、邻元素未改、负Q8及scale原位型；产真实RAM报告。owner小顶层走首空槽、已有槽、空槽耗尽、QKV第二槽冲突排除、busy拒绝、A8仅numeric/仅owner/两者高水位、回收及恢复，用实际生产helper而非复制实现。仅有C++执行PASS不替代该小顶层HLS接受。
2. **剩余控制初值核查。** reduced FullRuntime仍有约79KB控制数据，此为待工具布局复算值，不能凭容量认定内存已解决。保留pilot的实际IR形态、reflow峰值；需要时用既有8GiB受限宽位断点记录实际GenerateBitConcat的W/M和阶段。若后续完整候选输入已可用，可只重放该reflow取证，禁止为此启动第二次完整csynth。输出IR中最大整数宽度不能冒充临时常量最大值；测量不到则明确记录，交Astra按实际结构和内存证据决定门禁。
3. **定稿身份，再完整CPU回归。** 代码、构建/运行脚本和source清单稳定后，在候选`build/model-repair`用既有exporter从同一冻结GGUF重新导出。得到新build tag、manifest/header/build_preimage；不得使用旧tag承接新源码PASS。`--strict-current-sources`和完整final_gate保持启用，新header/storage源纳入实际闭包。新包embedding/w_q0/w_q1/w_scale整文件hash须与旧包相同；aux除[0:128]身份头外逐字相同；153tensor记录/152保留/122Q8/124WeightKey及布局和独立还原检查不变。所有请求在新输出复制并按既有工具重绑定新build tag；token、shape、输入和独立数值oracle不变。执行既有27项CTest、75fixture、真实整图141点/持久已接受故障→两次恢复等完整CPU门禁，不删步骤。
4. **验证真实synthesis分支。** 普通CSim不定义`__SYNTHESIS__`，不能单独证明独立global存储分支。新增CPU shadow独立编译全部实际生产source，定义`__SYNTHESIS__`，调用真实13口top；不重新引入observer/host memory字段、不导出内部cache捷径。用真实模型和请求读取实际384B结果帧，和独立oracle核对全部有效F32位型、状态/身份/长度/flags。一次进程的同一static runtime至少执行B2成功、已接受的同类gamma故障、恢复后B1两次，核对错误清零与恢复输出；不得重新启动进程替代持久恢复。标准libm、-fno-fast-math、-ffp-contract=off与既有CPU数值合同一致。该shadow证明synthesis分支软件语义，仍不代替RTL。
5. **真实13口HLS CSim。** 用新包、新请求、同一独立oracle执行既有标准libm严格O2真实B2 47点CSim。该结果与shadow分别报告，不能互相覆盖。
6. **一次受控完整csynth。** 上述门禁、源身份和Astra差异审核通过后，使用既有真实完整顶层入口及冻结三项低自动化选项，应用已验收的RAM分离/reshape，在32GiB/192GiB保护下只尝试一次完整csynth。必须记录HLSGen是否完成、最大RSS、资源/接口/时延/RTL是否真实生成。资源超限、时序不满足或再次工具失败如实提交；缺真实platform不阻止part级csynth，但此任务不自动展开XRT平台link/布局布线/上板。

每步记录命令、工具、实际所有输入hash、独立expected来源、退出码、完整日志和结果。失败有具体新证据时只修其原因并重跑受影响门禁；不得扩大内存或反复盲跑整网。

## 审核与回到原工程的条件

候选工程不是最终遗留位置。Sol提交准确变更清单、前后hash、CPU/shadow/CSim/综合的实际结果，Astra审核每项生产变更和初始化/索引/存储字语义。

- 当前**不回写**原工程。功能门禁与独立新身份闭合、候选完整综合实际结果已审核后，由Astra核定精确推广清单。若综合仍有阻塞，可仅在有证据证明独立修复有效且明确保留综合未完成时决定是否推广，不把此项自动视为PASS。
- 推广前把将被覆盖的原源码/配置/文档按相对路径和hash保存到新的`results/synthesis_memory_fix_20261007/pre_promotion`；旧tag模型与既有results不覆盖。仅复制已审核的上述文件及对应模块文档，新增文件按清单登记。
- 新模型包留在新目录，默认入口切换到它须在推广清单中显式记录；路径变化若进入build前像，按既有身份规则重新派生并执行必要严格复核。不能给同一候选源码凭空沿用不匹配tag。
- 最终原Laya-baseline的当前源码、所指包、实际编译闭包与结果入口一致。最终报告分别说明内存增长修复、数值/持久语义验证、完整RTL/资源和后续物理阶段的真实状态。
