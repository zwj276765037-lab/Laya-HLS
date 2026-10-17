# 14 怎样验收：从正确输出到U55C性能测试

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline测试与上板说明](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/README.md) 和 [上板运行脚本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/run_inference.sh)，补齐Laya的联合验证、完整模型质量和请求延迟口径。通过C仿真、通过综合、完成上板是三个不同结论。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 最终交付目标 | 完整Laya的U55C正确推理，并评判加速效果 | 只完成文档，未获得Laya xclbin | 明确要求 | U2/U3；S6 |
| 结果接口方案 | 4KiB结果区；wait＋sync＋身份/status校验 | 精确字节/错误合同见§9，编码器与硬件未实现 | 推断（本次实施合同） | 01；本文§1、§9 |
| 参考证据 | 历史Typed FP/Q8质量与A6000报告仅作起点 | 模型/请求/计时口径并非本次FPGA配对 | 工程事实 | S5 |
| 数值/质量门槛 | 保留既有建议值，按G6冻结最终阈值 | 没有用户逐项指定或本次硬件通过记录 | 推断 | S3§12；本文§3、§4 |
| 验证状态 | 按C、RTL、综合、实现、时序、上板分别留证 | 全部硬件阶段未执行 | 工程事实 | S6；本文§7 |

## 1. 结果怎样安全交回CPU

首版使用01中io BO的4KiB结果区，起点16384。结果头预留128bytes；候选logits放结果内offset128，预留128bytes；act logits放offset256，预留64bytes；offset320之后供状态详情、计数和预留。

结果头保存版本、status、request_id/generation、model/numeric/layout/build标识、B/S和输出长度。候选为 `[B,16]` F32，act为 `[B,2]` F32。精确字段偏移由本文§9规定，后续共享IO定义据此生成，并用CPU/HLS打包回放测试校验，不能依赖未经检查的C++结构padding。

硬件把输出和状态写完后结束kernel。Host先 `run.wait()`，再将结果同步回CPU，核对身份、长度与status，成功后才解码。首版不要求CPU轮询自定义commit行，也不要求手写LAST_RUN_CYCLES寄存器；完成与访存排空通过HLS/XRT接口及RTL/平台测试确认。

无效shape/index、数值错误等能由HLS检查的情况返回错误状态，logits无效。设备/AXI故障或timeout未必能写出完整结果，Host记录运行错误并恢复，不能继续使用旧结果或立刻覆盖尚在使用的BO。

## 2. 先按链路验，再拼整网

| 联合测试 | 同时接通什么 | 最容易遗漏的检查 |
| --- | --- | --- |
| 请求与结果 | Host打包→XRT→kernel→结果回读 | 参数编号、bank、B2、旧generation、非法索引和timeout |
| Embedding/LN | 随机行读→解包→反量化→完整行LN | 34-byte跨拍、ID边界、LN输出暂停 |
| 量化/Linear | LN→amax/replay→A8 cache→dot/恢复→PS排出 | q/scale配对、反馈II、宽产出窄出口、bias顺序 |
| Attention | QKV→旋转/重排→QK/mask→softmax→AV | QKV最后写响应、有限mask无合法key行、共享引擎冲突 |
| FFN/residual | Wi→U/G→GELU/gate→量化→down→残差 | 配对双读口、4/8-lane速率、Wi/down互斥、旧hidden存活 |
| Decision/业务输出 | 两层Decision→scorer→统计/act→CPU | 固定16列、1028维、两次bias、ties、温度边界 |

每条链都要测试随机停顿、长短输入和缓存复用。C仿真主要验数值；有限深度FIFO的反压/死锁、AXI完成和真实流水要用RTL联测、hw_emu或板上证据补齐。

## 3. 数值和质量怎样判定

导出器先证明q/scale逆重排逐字节一致。在同一候选算法且相同输入位模式下，量化q/scale、INT32 dot应精确一致；native_backend与候选算法另按§10验证，不能跨profile假设逐位一致；R1必须与R0 term逐位对账。FP32参考冻结运算顺序、归约树和函数版本，HLS近似单独报告误差。

以下门槛保留自S3§12，状态均为**推断（建议值，正式验收前解决G6）**，不是用户已逐项确认的合同，也没有全图通过结果。

| 检查对象 | 保留的建议门槛 | 应提交的证据 |
| --- | --- | --- |
| 中间浮点值 | `abs_err<=1e-4+1e-4*abs(ref)` | 首次差异、最大误差及输入范围 |
| 最终raw logits | `abs_err<=1e-3+1e-3*abs(ref)` | 未舍入的全部输出 |
| 最终概率 | 绝对误差<=1e-3 | 与同参考/温度配置逐项比较 |
| 质量 | 相对Typed Q8准确率下降≤0.5个百分点，答案一致率≥98% | 同一400案例/2000决策快照及逐例差异 |

发现后续q不同，要定位首次上游数值差异；给定相同输入时的量化/dot精确性与全网误差分开验收。

若采用上述建议质量线，以历史Typed Q8的76.85%（1537/2000）为起点，对应至少76.35%（1527/2000）；这两个数分别是历史软件成绩和推导的建议门槛，均不是FPGA成绩。分别报告choice/score/noul/action和低margin翻转，保存未舍入输出，不能只比较展示层四位小数。

## 4. 什么才算完成U55C部署

需要同时交付：

1. 模型包、配置/导出工具版本、真实请求及CPU参考；
2. 由当前源码构建的xo/xclbin及Host，kernel参数和HBM映射匹配；
3. 合并资源与实现时序报告，记录实际platform、XRT和工具版本；
4. FPGA完整网络输出、质量报告、连续请求稳定性记录；
5. 实测各阶段耗时及相同Typed请求的GPU对照。

资源建议沿用S3§11：DSP<=实际用户区80%、LUT<=70%、BRAM/URAM各<=75%、逻辑缓存<=28MiB，**状态为推断/建议预算，正式上限待G6**。物理资源不得超出选定platform可用区；布线后的目标时钟需满足WNS>=0、TNS=0，并核查约束覆盖和hold检查，才能声称对应频率达标。这是拟定工程验收方法，当前没有实现报告。先验证实际阵列规模和HLS函数实例数量，再谈性能。

稳定性建议连续至少1000个合法请求（S3§12；推断，次数待G6），覆盖B1/B2、S64/128/256/512/1024及1/2/3/16个有效候选。较长S的运行时间单独报告，不沿用短请求指标。

## 5. 性能怎样测才可与A6000比较

主测试保存退款/部门两题的Typed输入文件，B2/S128、候选16；有效长度以实际tokenizer捕获为准。GPU与FPGA执行同一模型语义和同一请求，记录各自物理padding。

| 测量项 | 起止范围 |
| --- | --- |
| 冷启动 | 打开设备、加载xclbin、分配BO、上传模型 |
| 常驻完整请求 | 接收请求到CPU产生最终答案 |
| Host分段 | 分词、组帧、H2D、提交/等待、D2H、解码 |
| 设备kernel | 使用XRT profiling/设备时间戳或经过验证的硬件计时 |
| 链路诊断 | LN/quant/dot/恢复、QK/softmax/AV、FFN、访存与stall |

测量建议采用至少30次预热、200次正式请求、3轮（S3§12；推断，次数待G6），保存逐次值，报告P50/P95和分位算法。串行延迟与并发吞吐分别测试；两题一次请求的耗时不能除2当作独立单题延迟。

**循环执行次数不是硬件周期数。** 真正的模块cycles需要时钟计数/监测或仿真trace；未实现该监测时只报告逻辑事件数和实际测得的区间。写回前抓取的计数快照也不能当作包含写回排空的总kernel周期。

## 6. 后续交付关口

| 先后顺序 | 交付物 | 共同评审的文档 |
| --- | --- | --- |
| A 输入与平台 | 统一配置/IO、GGUF模型包、真实请求、板卡平台清单 | 01、02、04 |
| B 基础计算链 | Embedding/LN、量化/Linear组合测试及资源/II | 05–09、15 |
| C 重数据链 | QKV/attention、FFN/residual完整时间轴和buffer表 | 03–05、09–12、15 |
| D 全图功能 | Decision/scorer/act、Host解码、整网数值和质量 | 01、03、13、14 |
| E 上板与加速评判 | xclbin、时序、板上稳定性、配对GPU性能 | 02、14、16 |

报告明确区分“需求/设计建议”“条件计算”“C/RTL仿真”“综合”“实现/时序”“上板实测”。本次仅完成规格整理和文档检查，没有执行任一硬件验证阶段。


## 7. 当前验证状态与未来证据要求

| 阶段 | 本次实际状态 | 将来允许报告通过所需的证据 |
| --- | --- | --- |
| 文档归并/来源核查 | 已整理；检查记录见S6 | 文件引用、关键数值/合同完整性及Astra文档审核 |
| 模型/软件历史结果 | 引用S1/S5已有记录；本次重算GGUF hash | 历史记录注明模型、数据、时间与运行对象；不代替Laya硬件验证 |
| 独立Golden-C/HLS C仿真 | 候选Golden-C与HLS C仿真未执行；已有真实原生CPU捕获，见§10.3 | 独立期望值、普通/边界输入、中间检查点、命令/版本/原始日志 |
| RTL/XSim或HLS协同仿真 | 未执行 | 有限FIFO、随机背压、FP反馈、复位/恢复、数量守恒、自检统计与退出码 |
| HLS/合并综合 | 未执行 | 所有模块及互连的资源、实际II、RAM端口/复制、完整接口报告 |
| 布局布线与时序 | 未执行 | 当前源码/约束对应的实现报告、实际clock、setup/hold/CDC及约束覆盖 |
| sw_emu/hw_emu | 未执行 | 同Host/参数/schema的功能回放和平台连接证据；不能当硬件速度 |
| U55C功能/稳定性 | 未执行 | 硬件xclbin身份、完整网络输出、质量集、连续请求和恢复记录 |
| 配对GPU性能 | 未执行 | 同Typed模型、同请求、同计时口径的原始逐次GPU/FPGA时延 |

自检用独立参考产生期望值，失败应有断言或`$fatal`。按hardware-agent运行器执行时，所有检查完成后才输出`HARDWARE_AGENT_SIM_PASS`，退出码须为0且无ERROR/FATAL；采用项目原入口时允许等价严格标准。当前目录没有该运行器或测试台，也没有本次PASS结果。

每次运行记录源码/约束/IP/外部数据hash、命令、工具与平台版本、seed、测试用例数、完整日志和退出码；远端使用明确指定的主机/目录。随机种子、超时与回归次数目前未冻结，不给出虚构默认值。文档验证不需要板卡；真正的硬件测试范围须与后续授权任务一致。

## 8. 错误类别与覆盖范围

| 类别 | 拟采用语义 | 联合覆盖 |
| --- | --- | --- |
| ABI/model/shape | 计算前拒绝不匹配版本、模型标签或B/S范围 | 01→02→03→14；数字编码见§9，G2保留代码生成／联调 |
| index/buffer | 越界token/marker/offset不能转成HBM访问 | 04/05/06/13；最后合法项及首个非法项 |
| numerical | 非有限输入/中间结果、非法scale等返回失败，输出无效 | 07–13；全零、次正规、舍入边界、极端值 |
| AXI/device/timeout | 可能无法获得结果帧；runtime记录故障并恢复 | 01/02/05；未完成run不能复用BO |
| reset/stale result | 新generation不接纳旧输出；复位后第一请求完整重建状态 | 02/03/15；空闲/运行中/排空阶段分别覆盖 |

本次数字错误码和结果头由§9定义；设备故障恢复API仍待平台确认。错误状态通过结果帧／XRT报告，不从历史手写寄存器表取值拼接。

## 9. F0结果字节合同、错误与退休

本节与01§6、15§10–§16构成同一份拟实施接口合同。结果区为`io[16384:20480)`；下表offset相对结果区起点。固定已定义长度为384bytes，区域剩余bytes不解析。Host每次提交前把结果区清零并同步；正常完成时kernel也覆盖整个已定义384bytes，包括未使用的batch/lane和保留位，错误结果不得保留旧logits。

### 9.1 128-byte结果头

| offset | bytes | 字段／类型 | 语义 |
| ---: | ---: | --- | --- |
| 0 | 4 | magic／字节数组 | ASCII `LYRS` |
| 4 | 2 | abi_major／u16 | 1 |
| 6 | 2 | abi_minor／u16 | 0 |
| 8 | 2 | header_bytes／u16 | 128 |
| 10 | 2 | status／u16 | 下表OK或错误码 |
| 12 | 4 | result_bytes／u32 | 384 |
| 16 | 8 | request_id／u64 | 已锁存的请求ID；identity_valid=0时为0 |
| 24 | 8 | generation／u64 | 同上 |
| 32 | 16 | model_tag／字节数组 | kernel当前构建绑定值，不能直接回抄不匹配输入 |
| 48 | 16 | numeric_tag／字节数组 | 同上 |
| 64 | 16 | layout_tag／字节数组 | 同上 |
| 80 | 16 | build_tag／字节数组 | 同上 |
| 96 | 2 | batch／u16 | shape合法时B，否则0 |
| 98 | 2 | seq_len／u16 | shape合法时S，否则0 |
| 100 | 2 | candidate_count／u16 | OK时16*B，错误时0 |
| 102 | 2 | act_count／u16 | OK时2*B，错误时0 |
| 104 | 4 | candidate_offset／u32 | 128 |
| 108 | 4 | act_offset／u32 | 256 |
| 112 | 4 | flags／u32 | bit0 identity_valid、bit1 logits_valid、bit2 cycles_valid、bit3 event_counts_valid，其余0 |
| 116 | 2 | error_stage／u16 | 15定义的stage值扩至16bit；OK为0 |
| 118 | 2 | error_operator／u16 | 15的operator扩至16bit；校验阶段无算子为0 |
| 120 | 4 | error_detail／u32 | 下文原因码；OK为0 |
| 124 | 4 | reserved／u32 | 0 |

`identity_valid`在请求magic、版本、header/目录固定尺寸、flags/reserved通过，且ID/generation非0后置1，此时可以锁存身份；后续tag/shape/目录错误仍可回显ID。此前失败将两个ID置0，Host用本次唯一run关联诊断，但绝不能当成功结果。`logits_valid`当且仅当status=OK且全部有效输出已完成写入时为1。Host须同时验证版本/长度、四个tag、request_id/generation、B/S、计数和logits_valid，再读取候选/act；仅有magic或OK不足以接纳。

### 9.2 数据、计数与错误细节

| offset | bytes | 内容 | 排列／有效性 |
| ---: | ---: | --- | --- |
| 128 | 128 | candidate F32[2,16] | `128+4*(16*b+c)`；masked但未施加温度的logits；B1第二行清零 |
| 256 | 64 | act F32[2,2]及padding | `256+4*(2*b+a)`；只用前4*2*B bytes，其余清零 |
| 320 | 8 | prewrite_cycles／u64 | 若有真实时钟计数：接收run至结果写入前的快照；不是包含写回排空的总kernel周期 |
| 328 | 8 | tasks_retired／u64 | 已退休计算／加载任务数量（不含IO_VALIDATE/RESULT_COMMIT trace伪算子），不是时钟周期 |
| 336 | 8 | accepted_input_elements／u64 | 仅五张量有效元素总数（B*S*2+32*B+B），不含头/目录/padding；通过完整输入检查后一次计入 |
| 344 | 8 | committed_output_elements／u64 | OK为18*B，错误为0 |
| 352 | 8 | first_bad_element／u64 | 错误张量的紧凑线性元素索引；不适用时UINT64_MAX |
| 360 | 4 | error_task_id／u32 | 首个错误任务；输入校验/无任务时0 |
| 364 | 4 | counter_scope／u32 | 0=无cycles；1=run接受至结果预写快照；event计数由flags bit3单独指示 |
| 368 | 16 | reserved | 全0 |

未实现真实时钟计数时prewrite_cycles=0、cycles_valid=0、counter_scope=0。event计数未实现则三项计数均0并清bit3。无论计数是否启用，header的输出元素数量仍必须正确。错误时128–319全部清零，清logits_valid和输出计数；first_bad_element仅是诊断，不能改变失败判断。

| status值 | 名称 | 何时使用 |
| ---: | --- | --- |
| 0 | OK | 全部任务成功、所有数据与响应排空，结果提交 |
| 1 | E_ABI | magic/version/保留位/固定头几何/非模型tag不匹配 |
| 2 | E_MODEL | model_tag不匹配或模型布局表与GGUF身份不一致 |
| 3 | E_SHAPE | B/S、目录dtype/rank/dims/stride/count不符合合同 |
| 4 | E_INDEX | token/qtype/mask/marker非法，或无有效token/候选 |
| 5 | E_BUFFER | offset/长度/对齐/范围/缓存epoch或所有权错误 |
| 6 | E_NUMERICAL | NaN/Inf、scale溢出、非法量化结果等数值域错误 |
| 7 | E_PROTOCOL | task/data标签、顺序、数量、last或有限FIFO协议不符 |
| 8 | E_INTERNAL | 已验证输入下控制状态或不变量失效 |

`error_detail=(domain<<24)|(object<<16)|reason`。domain：1头、2目录、3输入元素、4buffer、5算术、6stream、7控制；object为头字段起点offset/目录tensor_id/buffer_id/流种类编号/算子编号的u8值；reason u16：1格式或魔数、2版本/标识、3保留位、4范围、5shape、6stride/count、7对齐、8长度/溢出、9epoch/ownership、10非有限、11溢出、12顺序/数量/last、13无有效项、14状态不变量；15共享数值算术域拒绝。reason15明确登记既有P1/P2共享数值叶函数的`E_NUMERICAL`诊断：`domain=7, object=实际operator, reason=15`，涵盖其已实现的非有限、溢出或非法算术域检查；保留reason10/11作为已有更具体原因，不改变status或算术语义。`first_bad_element`仅在实际返回有效索引时说明位置，其余仍为UINT64_MAX；更细信息只有运行实际记录时才在日志说明，不增加384B帧字段。

Host事件`HOST_TIMEOUT=0x1001`、`HOST_DEVICE=0x1002`、`HOST_STALE_RESULT=0x1003`仅存在于Host日志，不能当成kernel必然写得出的status。可预期输入错误按01的校验次序；执行中取第一个被观察到的错误并锁存，之后排空错误不覆盖首因。

### 9.3 结果提交和错误排空

正常路径：所有算子done被控制器接收→所有工作区/结果输出写响应完成→形成计数快照与结果→写128–383数据/详情→写0–127结果头→等待这些写入全部退休→HLS函数返回／ap_done。不要求Host轮询头，Host只在XRT wait成功及D2H同步后判断。不同master的AXI响应不能靠程序排列想当然保证，需要HLS/RTL确认函数返回已排空；若所选生成接口无此保证，补实现层fence后才放行。

可捕获错误路径：禁止新算子和新逻辑输入，已接受的AXI事务与不可撤回的FP运算继续退休；输出进入丢弃接收端并按已发射数量收齐，相关目标buffer作废，释放在途引用后产生失败done，最后提交错误结果。错误导致缺拍或总线不再响应时可能无法排空，Host超时恢复；不得在仍有旧事务时伪造done、重用buffer或提交下一generation。

## 10. 真实Typed Q8数据与候选硬件算术的双重参考

用户明确要求数值参考使用真实Laya量化微调模型推理数据。本次固定对象是`laya_typed_decisions_q8_0.gguf`，455179648bytes，完整SHA-256见04§2。不得用随机权重、人工输入或另一版本Laya输出冒充该参考。随机背压和合成边界仅用于补充协议／算术域测试，并在结果中标记为supplemental。

| 参考类别 | 必须实际来自什么 | 能验证什么／不能冒称什么 |
| --- | --- | --- |
| native_backend | 同一GGUF的真实GGML CPU或GPU执行；真实Typed tokenizer输入 | 模型实际输出、中间节点及质量；backend/设备改变后单独留身份 |
| hardware_candidate | 真实输入／捕获中间值＋同一GGUF权重，按07–13候选运算顺序独立软件回放 | HLS/RTL按候选合同实现是否正确；不能称为原生backend逐位结果 |
| protocol_supplement | 上述真实数据不变，仅加停顿/返回延迟；或显式标注的合成极值 | 协议和边界；不能代替真实模型端到端数值证据 |

GGUF的Q8_0规定了**权重存储**；并不证明真实CPU/GPU使用本项目的activation Group32/FP16 scale、固定树或非FMA累加。原生backend的activation量化、scale精度、融合、归约顺序须读实际执行路径／捕获确认。候选量化q/scale和INT32 dot仅对**相同输入位模式与同一候选算法**要求精确；原生backend没有相同表示时应报告浮点中间误差，不伪造该checkpoint。硬件候选全图还要对native_backend做误差/决策一致率分析；建议阈值§3未因接口细化自动成为已达标结论。

### 10.1 可执行的采集合同

每个capture保存：真实文本、问题及候选顺序／qtype；tokenizer来源和文件hash；五张量的未压缩原位数据；candidate_masked_before_temperature `[B,16]`与act_logits `[B,2]`原位F32；源GGUF路径、完整hash、bytes；运行时间、命令、源码commit、未提交补丁hash、构建flags、库版本、backend/device、线程数、精度/优化选项。不能只保留展示四舍五入结果。

每个tensor的manifest记录`name, graph_node_id, source_kind, dtype, shape, strides_bytes, storage_order, byte_order, file, byte_offset, byte_length, sha256`，以及batch/token/head/feature的轴意义。native GGML存储转成规范行主序时，同时记录原shape/stride和转换；任何值改变均须另命名，不能覆盖原捕获。节点未导出写`unavailable`及原因，不能填写计划值。模型输出必须注明是mask之前、之后、温度之前还是之后。

采集优先级：五输入和两个最终输出→embedding/LN→Encoder 0与27层→final LN/type add→Decision两层→gather/scorer双bias→候选概率/统计→act 1028输入、256隐藏和2输出。每层推荐捕获QKV pre/post RoPE、attention结果、GEGLU、residual layer_out。请求使用实际业务文本；先保存tokenizer实际有效长度，再选择允许S档并保留物理padding。72/94和B2/S128仅历史计划，不强行写成采集事实。

### 10.2 模块数值参考映射与联合断言

| 模块／链路 | 真实数据检查点 | 必须额外比较或断言 |
| --- | --- | --- |
| common／kernel_wrapper／memory_map／top | 五输入、manifest、最终两输出 | 字节回放、tag、13参数编号、紧凑S与固定1024stride |
| hbm_loader_and_cache | GGUF原始q/scale/F16/F32，重排导出块 | 逆重排逐字节相等、末尾/4KiB/bank/epoch |
| embedding_engine→layernorm_engine | 实际token对应embedding_raw、embedding_norm；type embedding | 34B组拼接、PAD照常计算、完整行统计、native与候选误差 |
| activation_quantizer→q8_linear_and_restore | native层输入、真实矩阵权重、native Linear输出 | 单独生成candidate q/scale/dot/term/PS；注明与native差异 |
| rope_and_mask→attention_and_fp_engine | QKV pre/post RoPE、QK/masked score/prob/AV | full/slide边界、有限mask、S个key齐全、最后QKV写响应 |
| vector_and_ffn | Wi双半、gate、down、旧hidden及residual输出 | U/G同一位置、4/8lane转换、旧hidden寿命 |
| decision_scorer_act | Decision输出、marker、scorer两次bias、raw/masked logits、p、stats、act输入/输出 | 16列、重复/无效marker、1028的最后4值、近似top2顺序 |
| result_status／forward_controller | 真实终值和请求身份，执行trace | 18*B有效输出、错误无旧数据、任务退休/排空后提交 |

本次真实数据入口和已捕获清单由`reference/`中的实际采集manifest与运行记录登记，硬件各模块TB引用同一份capture，不各自生成一套“黄金随机数据”。只有最终logits可用时可先验证端到端；未捕获的模块中间值仍列为缺口，不因此宣称该模块已比对通过。

### 10.3 本次已取得的真实证据与数值差异

实际入口为[原始前端输入/输出](../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)和[ABI兼容S128输入/输出](../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)，模型、运行源码commit、插桩与二进制hash、每节点ne/nb和hash均在各manifest。最终每包登记1698个tensor记录（1696个原生图记录＋2个衍生U8 mask）、42个语义alias、122个直接backend Q8 activation scratch和32个执行前CLAMP快照；原生与衍生记录分开标识。非连续VIEW保存native storage span，必须按ne/nb解码，不能直接把文件bytes当紧凑张量。

本次真实后端审计确认122个Q8_0权重/F32输入的MUL_MAT先在backend转换activation为Q8_0，再走`llamafile_converted`；另一个F32/F32和一个F16/F32尾层走`ggml_vec_dot`。backend实际activation scratch已补充直接捕获，属于native中间数据；它不是由候选Python/C++重新量化生成。是否与候选q/FP16 scale、恢复term和累加完全一致，仍须逐张量核查；内部dot/term/PS若未导出就保留未捕获状态。不能从相同类型名推出数值一致。

实际图还包含30个`FLASH_ATTN_EXT`（28 Encoder＋2 Decision），其K/V/mask各经F16 CPY，共90个转换。这意味着原生融合attention和本版拟定FP32 QK→finite mask→softmax→AV存在精度／归约路径差异。原生融合内部score/prob不是可直接捕获图节点，当前标`unavailable`；可以用真实Q/K/V和mask做**candidate**显式回放，但不能把派生score/prob改标native。FPGA数值profile、资源与质量需按这一差异重新验收。

输出alias：candidate masked、温度前为`ir_1469 / add_119`；mask前为`ir_1464 / squeeze`；act raw为`ir_1616 / linear_123`。输入适配的原因和局部数值差异见01§7；生产TB选择abi_replay全16列期望。节点全量捕获会改变buffer分配，软件工程已额外对比正常分配／只捕获两个输出路径，结果证据以reference运行记录为准，不能据插桩一次运行推断性能。

捕获耗时包含全节点导出和磁盘I/O，只用于运行记录；它不是稳态CPU/A6000延迟，更不是FPGA时延。软件采集成功和1856B帧回放成功不改变所有硬件阶段“未执行”的状态。生成candidate独立回放、F16/FP32路径误差与正式质量线仍是G3/G6缺口。


### 10.4 捕获时点、已验证范围和不可替代的缺口

原生GGML CLAMP构造in-place view；只在图结束时读tensor会拿到覆盖后的值。本次32个preCLAMP快照保存30个attention mask、原候选计数以及act softmax原始p，`act_probability_vector`明确指向`audited_outputs/preclamp_31.bin`。该机制要求CPU单线程；不能在多线程下沿用同样插桩而声称无竞态。manifest中`overwritten_preop_nodes`列出的原节点末尾记录仅代表覆盖后状态，TB不得按名字误当操作前输入。

最终两套capture和正常分配对照绑定同一二进制SHA-256 `0e7a9bf6bc7c5a48bc2aacc60bc522ac418a82632ffc87be878974b7a4f728b1`。每包[verification.json](../../reference/runs/typed_q8_ref_20261005/abi_replay/verification.json)记录tensor/scratch/preCLAMP hash核验，`capture_normal_output_comparison`记录两个raw输出逐字节一致；完整重现入口为[reference/README.md](../../reference/README.md)。这只是软件采集完整性／帧回放验证。

实际输入覆盖仅退款noul和部门choice两题、B2/S94原始与B2/S128适配；qtype1/score、B1、其他S档、1/16候选等边界及完整质量集仍待采集/执行。未建立完整hardware_candidate逐算术回放，未捕获原生融合attention内部score/prob，scorer两次bias的每个内部瞬间也不能只凭最终图级alias宣称已单独验证。G3/G6保持开放。
