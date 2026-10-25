# M007：完整Attention高性能主干与部署闭合

revision: 1 / 2026-10-21
architecture_decision: D-M007-CONVERGENCE-01
execution_state: paused
verdict: unassessed
owner: A001主控；A007硬件执行；A008 Host/CPU执行
implementation_root: project/E002_Laya_HLS/experiment

## 1. 授权、来源与唯一当前范围

用户明确要求“收敛成新的goal 制定详细的新mission 可以开始创建子智能体6.1-sol进行项目的推进”。本指令恢复M007内的实现、必要参考、编译、仿真和有界模块综合；沿research-agent/hardware-agent阶段连续修复，不逐次申请批准。旧M004/M006/SM007及原长会话不自动恢复，也不转入余额。原代码可复用，原失败和PASS范围保留。

本合同综合[PRO计划v2](../../PRO_plan/Laya_Full_Model_U55C_Deployment_Plan.md)、[Goal v9](../../goal/goal.md)及本地M006已量化要求。PRO计划SHA256：c549b3b1abb679dfc81cc4d23cebd9635a2ed8e2ac512ff311fdfda21c2f9152。当前主线的所有指标集中在[机读要求](performance_requirements.json)；旧M006只作为来源，不能用其paused/旧预算控制本段。本文与机读表描述当前要求，任何未取得新验证的能力仍NOT_RUN。

## 2. 收敛决定：明确采用什么

| 项目 | 本Mission固定选择 |
|---|---|
| 主线边界 | CPU输入/Embedding/初始带gamma LN → FPGA全部28 Encoder＋2 Decision → CPU完整scorer/ACT尾部 |
| Attention | QK、scale、finite mask、严格softmax、AV、Encoder RoPE均在设备；Decision无RoPE，不存在生产CPU Attention回退 |
| 输出 | FPGA按marker槽0..15收集原始hidden，再附原始CLS一行，17×1024 F32＝69632B；CPU完成marker LN及全部尾部 |
| D0诊断 | 可选小矩阵/CPU图调试工具，不作为强制前置或50ms验收；不重建旧TM4/TN8全网卸载主线 |
| 主干驻留 | 中间hidden/skip/QKV/context/Wi/G留在生产片上银行；HBM仅权重与入口/尾部staging。功能诊断spill另标，不能冒充性能路径 |
| 数值 | 当前冻结独立参考的严格函数输出、原归约和每步舍入；不继承PRO v1非线性容差，不改gold |
| 调度 | 固定图、共享服务、一个请求上下文；最终生产一次BEGIN。bring-up可分服务命令且张量留设备，另标未完成最终ABI |
| 并行实现 | GPT-6.1-Sol/xhigh；A007写attention_and_fp_engine硬件，A008写独立Host/CPU适配目录。A001唯一写goal/mission/审核/索引 |

CPU初始LN与68KiB出口沿用已有清晰边界。PRO v2的设备初始LN、512KiB完整hidden出口仅为替代建议，本合同不采用为生产默认。完整hidden可用于调试、独立参考或功能检查；计时必须声明真实出口。

## 3. 模型、完整计算与数值

固定B1/S128、D1024、16heads×64维、28 Encoder＋2 Decision；Encoder Wi5248/GEGLU2624，Decision FFN4096；16候选槽，最终16候选logits＋2 ACT logits。模型GGUF SHA为6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18；graph SHA为f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9，实际文件需绑定后才算取得。

每请求120大Q8、47,143,976,960 MAC；CPU尾部2小Q8＋2浮点linear。28层Encoder：layer%3==0为10个full，其余18个双向abs(q−k)≤64；Decision两层full。全部128key按finite mask计算；61,440 softmax行、7,864,320元素。QK64项相邻树，AV按key升序分别乘加；禁止FMA、重结合、在线softmax或跳mask项。原RoPE表、type表、bias位置均固定。

量化每32元素用原F32 amax/127和独立1/d；q使用完整F32 d而非先舍入的F16 scale，roundf halfway远离零。scale存F16；非法值按原规则报错，不silent clamp。恢复按I32 dot→精确扩scale→两次独立F32乘法→group升序F32 PS加法→适用bias。

严格FP修复可替换实现算法但不改变合法域/位型。必须分别标明：反例确实可达、证明不可达、仅样本未触发、未知。有限非负F16 scale、合法q、零初始PS且无外部PS注入时，无bias term/PS的2^-48格点证明可用于范围分类；不免除正常数舍入、signed zero、bias或Attention验证。

保留AT021新8拍add、AT022新8拍div、AT023旧11拍add次正规FAIL_NUMERIC。不能通过把合法输入拒绝、修改期望或只查子进程0来修复。非有限/overflow按现行finite检查及Check上报；模块返回与系统错误分类均要可追溯。

## 4. 高性能矩阵的实际结构与要求

统一300MHz、单算术域；阵列为两个Tm8/Tn16/Pk32按M并联，共8192 INT8 MAC/拍、II1，256个group32结果/拍。INT8 DSP≤4096；精确打包需独立符号/溢出证明。A与W分别512B Q/拍＋32B scales/拍；W广播两个tile，当前group复用八个M16窗口。

固定调度：4个N16超块→group升序→四Ntile→八M16窗口。每超块计算K拍；Wi的64列取两半各32列对应GEGLU。PS两套32KiB上下文，各512个1R1W bank、深16；同输出32拍复访，PS完整反馈≤24拍。算术向量在途≤64，独立返回信用128；每拍256个恢复结果，退休32 F32/拍，末超块≤256拍。

恢复每拍256次I32转换、256个精确F16×F16格式特化乘积、256次F32乘法和256次有序F32加法；dot发射至PS提交≤64拍。F16乘积的11×11整数实现必须逐位等价；不能用粗略通用FP峰值代替这一服务率。

| 完整M128矩阵 | K | N | 次数 | 完整服务周期帽 |
|---|---:|---:|---:|---:|
| QKV |1024|3072|30|57344|
| WO |1024|1024|30|22528|
| Wi |1024|5248|28|92160|
| Down |2624|1024|28|56576|
| FC1 |1024|4096|2|73728|
| FC2 |4096|1024|2|86016|

起点为F32输入已就绪、服务W cache冷的MATRIX_ACCEPT，终点为所有输出/Check/PS和事务退休；包含量化、首W加载、预取、bias、内部停顿及fill/drain。120次累计≤6,880,256拍≈22.9342ms，持续≥2.0TMAC/s。首32输出≤Q(K)+W0(K)+K+192；Q≤4K+128，W0分别1024/2224/3328拍。G82、G128、高列N5248不可沿用旧固定QKV终止条件。

## 5. HBM、片上存储与接口带宽

采用已有M006定义的超块/group/四N16持久重排，576B记录＝512B Q＋32B F16 scale＋32B零padding；矩阵4KiB对齐，跨页拆burst而不插空洞，Wi两半配对。重排必须可逆，原权重字节不变。

每题真实W读取414,351,360B（含23,019,520B padding），原有效载荷391,331,840B。bias73,728B初始化后留系数区。W双slot每份最大278,528B；不复制旧11MiB整矩阵cache作为正式结构。A双slot各557,056B，G量化cache356,864B。

4×512bit独立逻辑W读口，聚合≥96B/core-cycle＝28.8GB/s；每超块至cache可读的服务曲线C≤256+ceil(B/96)。每口8个在途、burst≤16×64B、总返回信用32768B、reader总缓冲≤48KiB。staging另两512bit口，各方向≥16GB/s；实际平台映射、CDC和争用须验证。

PS/G/LN银行按phase复用，不能用逻辑互斥删除实际实例资源。QKV三plane×64 bank×2048 F32，唯一1.5MiB；context512KiB；score复用64KiB PS，prob复用64KiB G配对缓冲，exp复用32KiB LN。详细bank/address公式和大小以机读表为准，读写响应、tag与valid采用同一request/generation。

## 6. Attention、严格函数和向量指标

256个F32乘法＋256个F32加法与矩阵恢复共享，分别独立issue/return/tag/credit；每叶子II1、延迟≤8拍。QK树T0..T5占adder0..251（128/64/32/16/8/4），最后4个adder做score bias，树级处理不同token；另4个精确×0.125单元≤16拍。AV当前乘法与较早乘积加PS独立，禁止配对等待和FMA。

| 模块 | 吞吐与局部约束 | 完整周期帽 |
|---|---|---|
| QK | 4score/拍，首4score≤160；完整128×128 | ≤4352/head |
| softmax | 8exp＋8直接div；64row context；行发射II≤16 | ≤2688/head |
| AV | 4query×64channel/拍；32拍复访，反馈≤24 | ≤4608/head |
| RoPE | 64pairs/拍；Q/K各64F32同时读写，原四表 | ≤2176/Encoder layer |
| 单head核心 | QK→softmax→AV完整退休 | ≤11648 |
| Encoder/Decision核心 | 完整16head，Encoder含RoPE | ≤188544 / 186368 |
| 全30层Attention核心 | 不重复计QKV/WO矩阵 | ≤5651968 |
| 量化 | 32F32输入/拍，1group/拍，≥128在途group | 首group≤128；tensor≤4K+128 |
| GEGLU | 8元素/拍，首输出≤256，4096配对块≤768 | S128独立流≤42240 |
| LN | 32元素/拍，4row context，3pass；row II≤128 | S128≤16704，60次≤1002240 |
| 残差/type/gather | 32F32/拍 | 残差/次4160；type4160；gather608 |

8-lane共享EXP/TANH：II1/lane、EXP≤256拍、TANH≤160拍；8路直接F32 divider II1、≤32拍，供Q/LN/softmax互斥使用。EXP/TANH保留冻结参考语义，divider不得改倒数乘。SFU/divider/Q/G额外向量总≤896DSP；共享恢复FP区≤1536DSP。旧EXP167拍局部结果可保留，旧TANH384拍为待解决差距；指标不因旧实现慢而自动降低。

全模型GEGLU9,404,416元素；Encoder FFN≤150016拍/次，Decision≤160256，未被Wi隐藏的FFN尾总≤36864拍。重叠必须由真实事件证明，不能把算子独立周期简单删除。

## 7. Host、软件尾部和生产ABI

CPU负责真实state/questions、tokenizer/recipe、合法S128、Embedding和带gamma初始LN；其结果为F32 H0[128,1024]（524288B）。输出按顺序为16个marker槽原hidden＋独立raw CLS（69632B）；有效marker必须0..127且mask覆盖，无效槽映射CLS并保持marker_mask=0，重复marker允许且保持原槽序。qtype及候选数遵原业务，不接受静默截断或丢候选。

请求边界采用u64 request_id、u32 generation、model/graph/numeric/layout/build身份、合法mask/marker/qtype、u64地址/span；输入输出不可非法重叠，严格检查溢出/对齐。控制元数据≤4KiB。具体字节ABI由单一schema生成Host/SV，新增适配不得伪称已完成XRT寄存器映射。成功必须绑定同一请求身份及真实数据/Check退休。

最终生产一次BEGIN、一次H2D和一次D2H；CPU拿到真实TAIL_READY后完成marker LN、scorer baked及显式bias、原GELU、FP32 scorer FC2、candidate mask/prob/stats、raw CLS＋stats、FP16权重ACT FC1、GELU、原Q8 ACT FC2和最终业务解释。不能把68KiB帧当作最终18logits或将失败变均匀概率。

XRT持久session、只初始化上传权重一次；真实group_id/BO长度/平台版本绑定。尚无设备时实现参考/ABI/可运行CPU入口并标board NOT_RUN，不模拟设备成功。D0、CPU oracle和生产device backend显式分离，禁止silent fallback。

## 8. 系统与物理验收

| 指标 | 要求（尚未测） |
|---|---|
| 用户kernel联合帽 | DSP7200、LUT900000、FF1800000、BRAM36等价1200、URAM640；另须与真实shell共同装入器件 |
| 物理 | xcu55c-fsvh2892-2L-e作为现工程目标；300MHz，最终route setup/hold达标、WNS≥0/TNS0、无blackbox |
| 设备互斥预算 | 13837345拍≈46.124484ms；详细分类机读表 |
| CPU | 固定CPU0–3；输入≤0.75ms、尾部≤2.25ms，Host余开销≤0.5ms |
| PCIe | 两笔payload总593920B；各方向有效≥8GB/s，每笔额外≤20µs，合计≤114240ns |
| 完整请求 | P50≤50ms、P95≤55ms；单上下文串行≥18QPS；≥200样本、连续吞吐窗口≥60s |

要求不等于预测或物理可实现性证明。若叶子/缓存/联合时序不成立，报告具体差距并由主控修订相应设计；不得降指标、漏算等待或放宽数值后签PASS。性能把W LOAD、CPU尾部、真实传输/launch/错误恢复计入；吞吐不用1/P50替代。A6000同模型/输入/明确数值口径比对，达50ms也不代表胜GPU。

## 9. 可执行阶段和依赖

| 任务 | 交付与边界 | 当前启动策略 |
|---|---|---|
| SM008 / E008 | 严格FP叶子（先add）反例修复、实际数值/II/延迟/OOC；接共享FP独立mul/add | A007立即开始，详见tasks/SM008.md |
| SM009 / E009 | 当前模型/参考身份、H0/68KiB尾帧schema及CPU适配、独立接口测试 | A008立即并行，详见tasks/SM009.md |
| SM010 | 高性能矩阵：可逆W重排→双slotreader→256恢复/PS→六shape完整M128 | 计划任务；首段资源和写入人交接后推进 |
| SM011 | 真实QKV→完整head→16heads/full/sliding/Decision→LN/FFN→28＋2 | 依赖已验证叶子与服务；不能用注入概率代签softmax |
| SM012 | 同版整图/CPU尾部、联合实现/XO/xclbin、真实平台与A6000比较 | 环境存在时分阶段定预算，无板卡如实留NOT_RUN |

首批任务并行编写、验证按资源锁串行；S0身份/可达域检查嵌入具体交付，不另建无止境审核线。每次正常错误修复、TB竞态修复、路径修复均自动继续；关键接口或数值变化由A001集中决策，不要求用户逐轮确认。

## 10. 首批独立预算和运行保护

| 当前任务 | 参考/单测 | static/编译 | RTL | 模块HLS/OOC |
|---|---:|---:|---:|---:|
| SM008/E008/R001 |600s|1800s|2400s|1800s|
| SM009/E009/R001 |600s|600s|不启动|不启动|

所有失败/timeout/旧版重验计费，原SM007余额不转。全项目一个重工具；CPU0–3/nice19/idle；启动前MemAvailable>192GiB；参考RSS≤16GiB、static/OOC≤24GiB、RTL≤8GiB且≤40Mcycle。首次未知路径pilot≤120s；之后必须有同版实际成本支持且落入剩余帽，static单次≤600s，RTL单次≤1200s，OOC单次≤600s，120s真实语义停滞保护。不能原样延帽重跑。

统一重工具锁`.research-agent/m007_heavy.lock`必须覆盖guard及其后代整个生命周期；A007为当前EDA持有人。A008实际编译或模型计算也先取同一锁，轻量文档读取不占锁。只管理本任务owned进程。禁止改工具安装或影响其他项目。

HEAD16-06/E010 R003新增完整16head路径按同版成本门采用单次RTL≤1800s的专用例外（详见SM011后继合同）；未知首pilot仍≤120s、普通RTL仍≤1200s。依据是已实测完整head85.99–88.93s，非对既有timeout原样延帽；CPU/RSS/并发/40Mcycle限制不改。

后继阶段预算由主控基于本段实际结果集中下达；这是项目资源分段，不要求用户再次批准合同内普通实施。完整P&R/板测/GPU基准本轮尚不启动，不把其未运行状态阻断当前可执行工作。

## 11. 证据、验收和交接

E008/E009仅存新protocol/三摘要/R001/AT，不建第二实现树；源码与TB仍在唯一E002根。每次冻结实际DUT/依赖/工具/IP/输入身份、原日志、guard、计数与末标。exit0且无Fatal/Error且完整自检末标才签通过。功能、数值、吞吐、综合、route、实板、业务质量各自判断。

完整图沿用独立47检查点和真实120矩阵边界；矩阵/Attention完成计数来自真实事件。旧141点软件回归只能按旧身份继承，不写成本次新实测。原独立参考保持独立，不导入DUT数值helper，不从观察输出生成gold。

A007/A008及时发阶段结果/实质阻塞给A001，原始证据保存在各自实验；A001维护本Mission集中审核。A002/A003旧会话保持旧任务inactive，避免并发写同一文件；不因项目恢复而向旧队列派重复工作。实际子智能体模型、运行ID和配置回执另存agent记录，登记不等于启动。

## 12. 主控主动接续约定（用户2026-10-21明确要求）

阶段交付由A001主动核对当前源码、原始关键结果、预算与受影响依赖，随即下达同一M007内下一可执行范围；普通接口定位、实现、仿真修复与预算内验证不等待用户再次催促。工程通过实际消息工具回传里程碑/阻塞，主控保持活跃处理并继续独立架构与集成工作。执行者完成本段不等于整个项目完成。

只有用户业务目标/数值语义/资源上限的实质变更、缺失外部硬件/权限且无可推进部分或用户明确暂停才需要升级给用户。没有实际运行或唤醒机制时不声称后台持续监控；不为普通接续默认建立定时器。旧队列不恢复，预算按新阶段独立记账。项目未完成时，主控不能只报告“等下一步”而不落实可执行工作。


2026-10-22执行更新：用户明确“继续任务”，按M007现行合同恢复；此前八lane收尾暂停作为历史保留，已验范围和独立预算不重置。当前入口为mission/current.md及results/missions/M007_resume_20261022.md。


2026-10-24暂停落实：D35实际28Encoder前缀PASS、final gamma LN原断言FAIL，完整30层未通过。按用户验后暂停要求收尾，不自动修复或重跑；最新事实见mission/current.md及results/missions/M007_summary.md。

2026-10-24最新明确授权：仅恢复SM012 D36 final LN修复和以保存实际H为输入的后缀分段验证；旧完整30层失败保留，不重跑前28层，本段结束后暂停。

2026-10-24 D36完成：限定gamma保持修复及保存实际H的后缀验证PASS，完整30层一次BEGIN未重验；核对/预算封存/owned清理完成后按用户要求暂停，无自动后继。

2026-10-24 D37：用户明确要求修复版完整30层一次运行/专用子代理/每小时常规汇报；详细预算与范围见SM012 D37，完成后暂停。


2026-10-25 D37收尾（北京时间）：修复版正式参数0完整30层一次BEGIN正常RTL验证通过，全部层输出/finalLN/type/544尾部逐字同原参考，实际提交/DONE/idle正常。主控独立核验已完成，预算封存、owned进程清空，按用户要求暂停。M007整体物理/部署/性能及异常全覆盖仍未验收；最新证据见results/reviews/m007_fixed30_final_review_20261024.json。
