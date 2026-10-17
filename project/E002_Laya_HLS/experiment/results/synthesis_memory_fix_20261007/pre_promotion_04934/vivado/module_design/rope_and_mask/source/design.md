# RoPE、QKV重排与有限mask：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/rope_and_mask`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：真实表RoPE、双shard转换与有限mask接入完整attention；当前完整CPU/CSim及既有代表性RoPE RTL用例通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

把QKV投影结果整理为attention按head读取的布局，并对Q/K做half-split旋转。mask生成使用与QK一致的b/q/k位置，V和Decision路径按图旁路。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| RoPE配对 | 64维head中(i,i+32)，i0…31 | 工程事实 | 10§2/图记录 |
| 表选择 | full theta160000，slide theta10000；Decision无RoPE | 工程事实 | 10§2 |
| 位置与mask | 题内s；finite -10000/-20000，先合并mask再加score | 工程事实 | 10§4 |
| 候选速率 | 4pair/clk→8feature，需捕获/重排/排出 | 推断 | 10§2/§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [04_model_package_and_memory_map.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md) | [§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:61)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:92) | RoPE表、QKV布局/stride及缓存生命周期 |
| [10_rope_and_mask.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:28)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:49)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:63) | half-split RoPE、QKV就绪、有限mask及attention交接 |
| [11_attention_and_fp_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:35)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:45)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:76) | attention对QKV/mask的就绪和缓存要求 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:84)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | Attention联合流水、QKV交接及共享资源/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| CAPTURE | QKV Linear或raw QKV存储 | 完整64维Q/K head与本题位置 | 取得half-split两侧 |
| ROTATE/REORDER | x及实际F32 cos/sin表 | 两次乘法再加减，重排到连续feature | 结果buffer可写且标签一致 |
| STORE/BARRIER | 旋转Q/K，V旁路 | 按head奇偶写QKV shard | 全层B/S/所有head最终写入可见后attention启动 |
| MASK | 当前QK位置和attention_mask | 合并padding/local bias | 与对应score同时交付/背压 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| raw QKV | Linear/cache→RoPE | 每token Q1024/K1024/V1024；head64F32 | 位置s不带batch偏移 | 完整head捕获后配对 |
| 表 | aux/cache→RoPE | 四张F32[1025,64] | Q/K按当前层full/slide选择 | 直接保留表值，不重算三角函数 |
| 最终QKV | RoPE→qkv0/1 | F32[3,2,8,1024,64]/shard | shard=head%2，V原样 | 写响应/可见性到齐后发布就绪 |
| bias | mask→QK/softmax | F32，b/q/k上下文 | full为padding；slide先local＋padding | score暂停则bias和位置一起保持 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- y[i]=FP32(FP32(x[i]×cos[s,i])-FP32(x[i+32]×sin[s,i]))；另一半按原文加法式，保留逐步舍入。
- padding=(mask[b,k]-1)×10000；local在abs(q-k)≤64为0，否则-10000；slide combined=FP32(local+padding)。
- score=FP32(FP32(qk×0.125)+combined)；不能-inf替换、跳key或将padding query清零。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| head输入/结果 | 各64×4=256bytes起点 | 捕获→旋转→连续读出 | 并行Q/K或双buffer需另核算端口 |
| RoPE表 | 4×1025×64×4=1049600bytes模型数据 | 模型有效期只读 | HBM aux已有存放；片上驻留策略未定 |
| QKV存储 | 两shard，04定义 | 整层就绪后所有attention读取完成 | F0 raw→读取Q/K→覆写；F1融合另评估 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 4pair/clk需要x/cos/sin窗口与16次乘法、8次加减匹配；输出重排不是零成本。
- F1从PS直接旋转再散写可省raw Q/K往返，必须与Linear和loader共同证明回压/端口。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [rope_and_mask.h](../../../../hls/operators/rope_and_mask.h)、[rope_and_mask.cpp](../../../../hls/operators/rope_and_mask.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_rope_and_mask`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 位置/窗口 | b1、head0/15、s0/1023、±64/±65 | half-split、表选择、mask对应正确 |
| 有限mask | padding query及窗口无真实key | 仍对全部有限score计算，不偷偷跳算 |
| 屏障 | 延迟最后写及暂停score输出 | attention不早读，bias/坐标与score一致 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/rope_and_mask/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G4表窗口/重排buffer/浮点尾和写回周期；G3固定浮点参考；G1物理接口。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

RopeTask使用src_qkv_ref[2]／dst_qkv_ref[2]固定数组、head:u8、mode:u8和table_set:u8，另含TaskContext。两ref各代表一个shard，bank=head%2；不能把bank0当完整QKV。F0全层QKV_RAW先完成；controller取得独占原地转换，任务从旧epoch读Q/K，写预留新epoch，全B/S/head完成才发布QKV_FINAL。

当前head的64值完整读入ROPE_HEAD，按i与i+32配对，position=row0+local_row，不含b*S偏移；Q/K各用实际full/slide表，V值保持且在final epoch覆盖账本中登记为继承。四张表F32位模式来自GGUF，不现场重算sin/cos。Decision不发ROPE；Encoder mode按layer%3。

mask是QKTask内部的同步坐标函数：输入b:u8、query/key:u16、mask_mode:u8及请求U8 attention_mask[b,key]，精确转F320/1；输出F32有限bias。padding=(mask-1)*10000，slide local按abs(query-key)≤64为0否则-10000，再FP32(local+padding)；score先乘0.125再加bias。没有独立mask stream等待关系，QK暂停时其坐标/结果同时停住。

联合TB使用真实QKV pre/post节点与请求mask，检查head0/15、planeQ/K/V、S128最后位置、局部窗口边界±64/±65、padding query照常计算以及最后Q/K写响应延迟。native表/输出与候选非FMA运算分开对账；不能用native第一个head通过代替两shard整层屏障验证。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_q` | `ir_238 / getitem` | `native/forward_0/ir_238.bin` |
| `enc0_k` | `ir_239 / getitem_1` | `native/forward_0/ir_239.bin` |
| `enc0_v` | `ir_240 / getitem_2` | `native/forward_0/ir_240.bin` |
| `enc0_rope_q` | `ir_255 / add_2` | `native/forward_0/ir_255.bin` |
| `enc0_rope_k` | `ir_262 / add_3` | `native/forward_0/ir_262.bin` |

原生融合attention内部QK score／probability明确未捕获；native K/V/mask的F16转换和FLASH_ATTN_EXT与候选FP32显式链分开登记。此处不能把candidate生成的score/prob称为上述alias的native节点。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对RopeTask的stage、head、full/slide模式、双shard引用、old/new epoch及逻辑输出数量；基础状态模型只检查调用者声明的覆盖与RAW→FINAL内容转换。尚未按plane/head/B/S与请求/layer核验完整QKV覆盖，因此当前PASS不证明全层RAW或FINAL屏障，也不证明RoPE数值运算、V保持或实际写回完成。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。


## P2 A批：完整head旋转与finite mask（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§2–5](../../../design_source/10_rope_and_mask.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/rope_full_compute.cpp`；`rope_head`使用64项真实F32 cosine/sine及完整输入head，half-split配对和每次乘加顺序由task§12.2冻结。允许原地调用但先捕获完整head；Q/K分别旋转，V不变，Decision旁路。finite mask在`qk_row`同一任务内生成，保持全部S项；不生成异步mask流。真实ir_238/239按ne/nb提取并使用固定GGUF四表，核对head0/15、B2和末位置；±64/±65及无窗口内真实key在attention联测。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/10_rope_and_mask.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

RopeTask仅在两shard完整RAW就绪后原子申请EXCLUSIVE_RW旧/新epoch；每head/row先捕获完整Q/K64再写，V携带旧完整覆盖。只有全部Q/K/B/S及写退休完成才双shardFINAL_READY；失败两版皆作废。Decision直接在完整三plane scatter后发布final，不调用RoPE。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[rope_full_compute.cpp](../../../../hls/operators/rope_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`rope_head`（有限mask数值位于attention模块的`qk_row`）。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_attention.cpp](../../../../hls/operators/full_tasks_attention.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
