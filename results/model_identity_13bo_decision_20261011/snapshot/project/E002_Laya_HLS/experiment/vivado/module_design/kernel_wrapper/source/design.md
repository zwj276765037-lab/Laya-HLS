# Kernel与U55C平台封装：详细设计

## 2026-10-09：离线Host v2实际代码映射

[`host_session_policy.h`](host_session_policy.h)和[`host_session_policy.cpp`](host_session_policy.cpp)实现已审核的可移植`Session`协议核心，使用现有`laya_io`编解码；[`host_session_policy_tb.cpp`](../tb/host_session_policy_tb.cpp)以确定性事件backend核对初始化、顺序、结果验证和异常所有权。`EventBackend`暴露13参数的`group_id`、BO分配/模型上传、请求同步、start/wait/abort及结果读取事件；实际XRT实现仍需把这些事件绑定到真实设备。核心只校验调用方提供的`Attestation`标志，模型SHA、xclbin SHA、aux header及platform元数据仍需未来XRT适配实际扫描与共同绑定。

`Session`的当前状态为Cold/Ready/InFlight/Poisoned/Closed，并分别记录设备静止事实。预检拒绝不触发backend事件；可能已提交的start前保守交出BO所有权并消耗identity，未知终态的close/析构保留backend责任。CPU完整矩阵的[执行证据](../runs/host_session_offline_v1/cpu_success_evidence_tb_setup_v2.json)与[独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_host_session_tb_setup_v2_cpu_acceptance.json)记录304项通过；它们只验证可移植协议和测试backend。前版原文保留于[history](history/design_before_host_v2_acceptance_20261009.md)，实际结果范围见[results.md](results.md)。

## 2026-10-08：无板卡阶段的常驻Host最小合同

当前没有U55C板卡，标准路径未找到XRT头/库与实际platform，按[mission阶段5](../../../../mission/task.md)先完成可离线准备。本文与[results.md](results.md)是本模块唯一当前文档；前文精确快照在[history](history/design_before_resident_host_offline_20261008.md)。下面的04934资源/RTL记录属于旧制品；fe067完整CPU/B2 CSim通过不代表新完整RTL或平台通过。

本次只读核查的直接依据是[现有单请求Host](../../../../host/laya_host.cpp:367)、[XRT真实依赖门](../../../../CMakeLists.txt:83)、[请求会话顺序](../../../../hls/common/laya_full_io.cpp:194)、[共享请求/结果codec](../../../../hls/common/laya_io.cpp:106)、[原规格01§3–5](../../../design_source/01_host_runtime_and_abi.md:52)和[候选HBM连接](../../../../config/u55c_link.cfg)。现有Host一次进程创建device、加载xclbin、创建kernel和13个BO，五模型共448923648B每次上传；七workspace合184MiB每次清零同步，IO32KiB清零同步，完成后回读结果384B。模型上传不是已实现的跨请求常驻服务。

最小常驻目标是单进程、单设备、单kernel、同一模型身份、串行预编码请求列表；不包含网络服务、分词或业务解码。Session初始化一次核xclbin SHA、manifest/五BO完整SHA、aux header和四tag；用kernel.group_id(0…12)分配原13BO，五模型只上传一次并固定只读。保持真实参数顺序/原尺寸，不按候选HBM号手工代替group_id，不缓存多个模型，也不并发复用工作区。首版每请求仍清零/同步全部七workspace与32KiB IO，复用的是BO分配和模型内容；消除workspace清理另立后续优化，不能在未验证时假设旧payload均无影响。

请求必须先经过原共享parse_request及精确frame_bytes检查，四tag固定；generation非零且不降，同generation的request_id严格增，新generation允许任意非零request_id。直接比较调用方给出的uint64身份，不做隐式加一或改写：request_id达UINT64_MAX后，只有尚存在的更高非零generation可允许新ID；generation达UINT64_MAX后仅可能继续同代更大ID；二者均最大即本session身份空间耗尽。重新创建Host对象不能被当成硬件会话已复位。Host保守记录每次实际提交的identity，即使完成为设备错误也不重用该对；同generation的新ID或更高generation按合同恢复。Host预检拒绝发生在任何BO修改/sync/start前，不消耗提交序号。软件顺序规则与硬件last_accepted规则分列；未知是否接受时Host不能重放同一身份冒称新请求。

生命周期固定为Cold→Ready→InFlight→Ready，异常可进入Poisoned；一个session只能有一个InFlight。Ready时才能修改IO/workspace，kernel启动后这些BO归设备，所有读写与销毁等待对应终态。只有wait确认COMPLETED、结果同步完成、backend返回**恰好384B**、decode_result/四tag/request_id/generation/B/S通过，才交付结果；共享decoder允许尾随字节，精确长度必须在协议边界另查或用固定尺寸类型保证。OK还须原flags/输出数/finite检查；有效非OK结果只作为错误帧交付，不能打印成功，后续可用新identity发下一请求。错误/正常帧都保留原Status/detail与统计。无效ABI/身份/shape或非有限成功结果使会话Poisoned；保留原始结果为诊断，不将其当成功输出。

timeout必须先请求abort并核真实返回终态；即使abort报告COMPLETED，该请求仍标超时，不自动重试。timeout、设备异常或同步异常均使session不可继续，首版不尝试在线device reset/重载。确认终态前不得复用、改写或主动释放BO；unknown abort/异常终态须保留所有权并停止提交，由实际XRT/平台恢复边界另行验收。离线协议测试只验证这条状态规则，不能证明驱动能安全abort。创建失败/预检失败/设备失败分别记录，不伪装成数值结果。

逻辑Poisoned与设备静止证明是两个独立事实，API须显式保留terminal/quiescence标志或等效所有权token。进入可能已提交后抛异常的start之前，即保守转移设备所有权并消耗提交identity；start/wait/abort抛异常不得通过栈展开隐式释放BO。close/析构在所有权未知时不得发出release、改写或再次start事件，须保留资源责任；后续明确终态只能允许按未来固定XRT合同清理，首版Poisoned不能回Ready。结果sync/read异常同样Poisoned；已确认终态和结果有效是不同条件。

离线第一批限定为`host_session_offline_v1`的**可移植协议核心**：在本模块`source/host_session_policy.h/.cpp`及`tb/host_session_policy_tb.cpp`建立身份准入、单InFlight、terminal/poison规则与请求/结果验证组合；复用真实laya_io codec，使用测试专用可控backend事件记录分配/上传/同步/start/wait/abort顺序。它没有XRT入口、没有模拟kernel数值，也不修改生产Host/生产HLS/包。观察13次分配、5次模型上传是协议事件预期，不是实际设备传输。先提交API/状态表和实际source/TB包，审核后接受离线CPU结果；真实XRT Session/CLI适配及现有Host公共代码提取待此核心通过后另门控，不能把尚未编译的XRT adapter列为完成。

若本核心不执行现有manifest/SHA/OpenSSL扫描，初始化验证应作为显式外部attestation/precondition并测试失败路径，不声称实际扫描了448923648B模型。当前身份显式固定`LAYA_FULL_MODEL_DIR=build/model-attention-rtl-repair-20261008`；旧CMake默认目录不能静默替代。未来实际部署仍须一份记录共同绑定xclbin SHA、四tag、kernel/参数元数据、platform/shell与Host build；独立xclbin SHA和包tag检查尚不构成该绑定。

离线检查使用冻结真实请求/结果帧及独立固定字节序向量：正常连续请求、相同generation重复/倒退、generation提升、tag/size/offset错误、未完成时第二请求、错误帧后新合法请求、陈旧/错identity结果、非法成功flags/NaN、timeout与abort各种终态及所有Poisoned后拒绝。必须证明prelaunch拒绝没有backend副作用，InFlight中没有BO改写/重用，初始化事件只一次，结果只有完成并校验后交付。独立事件backend可产生错误/延迟，但不能被标为XRT sw_emu、RTL、PCIe/HBM或板卡通过；原XRT CMake目标继续要求真实头/库，禁止桩替换绕过。

边界矩阵另含：0/383/385B结果拒绝与独立冻结384B结果接受；request_id/generation最大值及溢出至零拒绝；start已提交后throw、wait/abort throw、abort非终态/unknown后close和析构均无release/reuse；timeout后abort为COMPLETED或ABORT仍超时且Poisoned。检查每条事件的顺序和禁止事件缺席，不能只检查最后枚举值。初始化失败不进入Ready；B2后B1覆盖未使用lane清零；冻结帧应带profile/包身份/hash，旧零tag参考帧不得被接受。

本批仅协议核心源/API/TB与受控CPU准备放行，构建及单次执行各4GiB/120s、4CPU、nice19、idleIO、0.2s采样、MemAvailable≥192GiB，本Laya重工具串行；AXI/Attention/Q8已有任务优先。禁止安装驱动、修改工具或运行设备命令。冷启动、每请求IO/workspace同步、start/wait、结果回读与校验的计时接口可在设计中分别登记，当前无设备数据；协议测试墙钟不能当作常驻Host延迟或50ms目标证据。

## 旧04934与P0/P1/P2记录

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

实际外部为13×32-bit数据/64-bit地址m_axi；另有32-bit数据、4/8-bit地址的两套AXI-Lite，ap_clk/ap_rst_n和interrupt。

每口150MHz原始单向0.6GB/s，源码byte读写与outstanding=1使有效率未知；512是最大宽化请求而非实际端口位宽。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-kernel_wrapper)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/kernel_wrapper`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：13参数生产核及真实XRT Host路径已实现；真实top标准libm CSim通过，XRT编译与设备阶段因本机依赖缺失未运行。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

对接XRT/平台和完整forward。首版采用HLS生成的s_axilite/ap_ctrl_hs控制与m_axi数据接口，wrapper登记并适配生成接口，不另写一套寄存器协议。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 平台目标 | U55C，Host通过XRT加载xclbin | 明确要求 | 用户/02 |
| 顶层名称 | 候选laya_typed_q8_forward；单次B≤2完整请求 | 推断 | 02§2 |
| 端口方案 | 13 BO/独立bundle候选，数据宽512bit | 推断 | 02§3 |
| 时钟/器件细节 | part/package/speed grade、实际clock/reset未指定 | 待确认 | 02§5/§8；G1 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [01_host_runtime_and_abi.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:36)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:52)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:62)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:68) | 请求/结果ABI、模型身份、Host交接与计时边界 |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:34)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:71)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:91)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:97)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:110)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | 外部kernel封装、13端口候选、工程文件与上板/复位边界 |
| [14_result_status_and_verification.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:19)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:59)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:102)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:120) | 写回完成、平台上板验收、状态与错误边界 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| Host准备 | 选择设备/xclbin与BO分组 | Host核对manifest并按kernel.group_id分配 | 仅加载一次模型；外部初始化不计入常驻请求 |
| 运行提交 | 13个BO参数与IO请求 | HLS控制启动forward，首版不自动重启 | 忙时保持IO/工作区归设备 |
| 完成/恢复 | 结果已写可见或运行故障 | 正常wait＋sync后读回；故障按runtime处理 | timeout不是设备静止证明，恢复前不复用BO |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| 控制 | XRT→HLS生成控制口 | s_axilite/ap_ctrl_hs | 寄存器offset从生成头/元数据核查 | 精确名称/宽度随平台，不手填 |
| 模型端口 | HBM→加载器 | embedding、w_q0、w_q1、w_scale、aux | 只读，参数编号0/2/3/4/5 | 独立bundle是否生成由HLS/link报告确认 |
| 工作区/IO | HBM↔forward | io、state0/1、qkv0/1、ff0/1、att_out | 参数顺序/候选bank见本地02原文 | 总线完成和写可见受平台/AXI协议约束 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- wrapper不更改数值；只校验必要的接口/版本一致性。
- AXI地址宽度、ID宽度、复位端口/极性和跨域转换位置均待实际生成接口。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| Host BO | Host分配，设备执行时占有 | run完成并同步/故障恢复后才能重用 | 不得把普通CPU指针当设备地址 |
| 接口返回队列 | HLS/平台生成逻辑 | 接受事务到退休 | depth/outstanding待接口及空间评估 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- master端口与bank映射是一对明确连接；多个bank范围不自动生成多个master。
- top负责网络连接，wrapper只处理边界；不按文档目录数量重复实例化kernel。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [laya_io.h](../../../../include/laya_io.h)、[laya_io.cpp](../../../../hls/common/laya_io.cpp)、[kernel_wrapper.h](../../../../hls/platform/kernel_wrapper.h)、[kernel_wrapper.cpp](../../../../hls/platform/kernel_wrapper.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_kernel_wrapper`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| BO回环 | 逐候选端口读写并核验分组 | 地址/内容一致、无越界、吞吐可解释 |
| 请求生命周期 | 非法shape、重复请求、最后写延迟与timeout | 不得提交旧结果；正常完成与BO同步顺序正确 |
| 复位/CDC | 空闲、运行中、恢复后的首请求 | 依平台语义验证在途清理，不假定HBM/模型必保留 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/kernel_wrapper/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G1实际平台/工具/IP许可与复位；G2生成参数/寄存器表；G4真实13 master资源时序；G5恢复API。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

唯一函数入口计划为`laya_typed_q8_forward`，参数0…12严格是embedding、io、w_q0、w_q1、w_scale、aux、state0、state1、qkv0、qkv1、ff0、ff1、att_out。每项是BO地址，计划独立HLS bundle；Host从生成元数据取得group_id，绝不由buffer_id代替arg_index。详细字段由01§6与14§9定义，AXI-Lite实际offset/端口位宽由工具生成。

| 阶段 | 输入／输出 | 可观察完成条件 |
| --- | --- | --- |
| RUN_ACCEPT | 一组13 BO与固定io头，锁定session | io/request/model只读所有权转设备；禁止auto-restart |
| VALIDATE | IO_VALIDATE，固定128B头→5目录→全部元素 | 未验证offset不用于读取；失败进入错误结果 |
| FORWARD | 单RequestContext，controller F0 | 接收唯一完成/失败，不只观察某个算子last |
| RESULT_DRAIN | 固定结果16384+0…383 | 所有master事务及结果写响应退休后返回／ap_done |

内部计算域reset和平台AXI域之间按02§8实际生成连接核对；本文不给出虚构的ap_rst_n等已生成端口。运行中timeout并不释放BO，Host确认停止/恢复后才能换generation。联合测试使用真实ABI fixture改一项offset/tag/index，检查越界访问为0；软件格式回放不等于XRT sw_emu或实际AXI通过。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `candidate_raw_logits` | `ir_1469 / add_119` | `native/forward_0/ir_1469.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 C批：13BO平台包装与真实Host（2026-10-07）

依据本次实际读取的[原规格](../../../design_source/02_kernel_wrapper_and_platform.md)及[task.md §12.4–12.5](../../../../hardware_agent/task.md)，由Astra xhigh核定。

新增hls/platform/full_kernel_wrapper.cpp将13个具名byte端口按既定序排列，各自m_axi bundle，s_axilite/ap_ctrl_hs，一次单请求无自动重启。请求512最大widen/outstanding1只是配置，真实端口报告决定物理宽度；byte load/store与逻辑4KiB段保证数值地址规则。新增真实host/laya_host.cpp按kernel.group_id分配13BO、常驻上传模型、wait/sync并校验结果，缺XRT时明确依赖错误而非成功替身。

可综合持久Runtime只保留缓存、owner与会话状态；每次调用在full_forward_ports建立局部FullMemory并显式传递给生产函数，CPU旧接口只转发同一实现。CPU/CSim可拒绝真实空指针，但综合路径不能把AXI基址0当缺失BO：合法枚举和可写权限由present/mutable_present检查，全部容量与offset检查继续保留，Host负责提供所有13个BO。依据见[实际13口pilot与源码审核](../../../../results/p2_environment_20261007/axi_base_zero_source_review.json)；该pilot不替代整网RTL或平台验证。

HLS CSIM/实验part不依赖实际U55C shell；v++/platform/XRT/板卡阶段独立门禁。必须检查ap_done时AXI写响应排空，CPU函数返回不代替RTL证明。复位实际极性/CDC由生成平台确认，不臆造本机不存在的部署配置。


## P2实际实现映射（2026-10-07）

- [full_kernel_wrapper.cpp](../../../../hls/platform/full_kernel_wrapper.cpp)与[头](../../../../hls/platform/full_kernel_wrapper.h)：13参数外部核，内部持久Runtime，非综合观察接口。
- [laya_forward_full.cpp](../../../../hls/laya_forward_full.cpp)：13 BO指针与固定容量绑定、完整controller入口。
- [full_kernel_csim_tb.cpp](../../../../hls/platform/full_kernel_csim_tb.cpp)：调用实际外部核并检查46个BO阶段及实际帧final18的HLS CSim TB。
- [laya_host.cpp](../../../../host/laya_host.cpp)：真实XRT Host。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。

此处Host为真实XRT路径源码，语法检查使用本地API声明桩只验证C++语法；它没有替代真实XRT编译/链接/设备运行，13参数kernel封装已实现，实际HLS接口与排空语义仍须工具证据。


## P2真实Host构建与运行合同（2026-10-07）

默认OFF的`LAYA_ENABLE_XRT_HOST`配置启用`laya_host`目标，`LAYA_FULL_MODEL_DIR`指定当前模型包生成身份头。构建要求真实XRT C++头、`xrt_coreutil`、OpenSSL Crypto及项目共享ABI codec；缺依赖须明确失败。独立CLI以源码[parse_options](../../../../host/laya_host.cpp)为准：

```text
laya_host --xclbin FILE --xclbin-sha256 HEX --package DIR           --request FRAME --result RESULT --timeout-ms N [--device INDEX]
```

FRAME为带当前四个非零tag的真实预编码请求，HEX为实际xclbin SHA-256。该工程入口核包和xclbin身份，按13个group_id分配BO并执行一次完整核；分词与业务解码仍属CPU应用层。XRT语法声明桩只用于已标明的syntax-only检查，实际target不会使用它。本机缺XRT/platform/设备，当前没有真实XRT链接、部署或板级恢复通过证据。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

13参数top ABI和调用期FullMemory保留。synthesis静态FullRuntime只保留控制和cache metadata，13个数值数组各自为独立全零global；固定typed数组访问器在HLS中inline解析到唯一global，CPU仍使用每个Runtime自己的数组。禁止静态cache/外部端口指针成员。两个URAM绑定改指真实weight_q/weight_scale；经结构pilot后采用cyclic reshape factor8/factor4，逻辑存储字64bits，保持逐元素地址与读写顺序。冷启动和所有非零控制默认值保留，不引入首次调用的大RAM清零循环。普通CSim与定义__SYNTHESIS__的真实13口CPU shadow分别验证，shadow只读实际结果帧，不恢复observer字段。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。顶层保留13个外部BO参数及150MHz实验part请求；Q8/scale仍分别cyclic reshape 8/4，元素类型与数组长度不变。实际完整顶层已生成Verilog、VHDL和IP，资源适配仍未通过。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
