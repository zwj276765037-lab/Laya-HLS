## D-M007-SM012-ORIGINAL30-BOUNDED-35（2026-10-23，E021/R003）

**任务和授权来源。** 用户明确要求继续完成原30层模型验证，且要求主控在子智能体交付后主动核对推进。增量119已直接核AT005原kind7首层实际H、AT010/011两种完整公开Decision的实际H与public输出逐字等于原独立参考；D34同版本试验的CPU/墙钟及语义分段现已足以制定首个完整整图运行计划。D34/R002限定组件/成本阶段封存，原失败、UNKNOWN及未用余额保留不转入。本段复用A012的工具/E021 owner、A010父/TB owner，不新建代理、不恢复旧M004/M006。普通实现/测试脚本修复仍连续执行。

**本阶段成本例外。** 当前每Encoder核心约329s、额外preLN约11.5s，两Decision完整实测约332/339s；原full/sliding均算128×128，不能按mask面积打折。相同工作量分项代理10196.799374s（约2.83h），加入35%规划裕量、三个未测交接各120s及60s清理得14186s；这是条件规划额度，尚未测的后续层/交接保持UNKNOWN，不称严格费用上界。590空调用A/B无收益、PC热点分散，不继续用小优化假定倍速。原D34的3600s单次门不能承载该明确授权的完整请求。主控据新实测将**本段唯一一次完整kind7运行**的单次墙钟上限定为15000s；本项目AGENTS中的通用3600s在这一次有明确任务/预算/阶段保护的整图尝试上由本段替代，其它任务不变。不是改写原120s COST_STOP或首层计划终止收据，原尝试原样保留；不无界加时、不自动重复完整长跑。

**独立预算。** reference0/static300/RTL15600/OOC0秒，RTL保留600s，单次完整RTL≤15000s。启动前必须具备≥15000+600s余额（预算内准备/脚本验证计static；不先消耗新RTL配额做无关试验）。CPU仍0–3且model1/context1实际单线程、nice19/idle I/O、MemAvailable>192GiB；static24GiB/未知单对象或批次≤120s，RTL8GiB/40Mcycle/真实语义停滞120s，全项目一个重工具锁不变。完整运行无新安装、GPU、HLS/OOC/P&R/板卡、CPU新gold或新模型。原R002全部收据与已知/未知成本独立封账。

**精确执行身份。** 复用AT010/011生产与86629840完整TB、f4d真实120张量W peer、原FP/IP/gold；Verilator5.020+local fixed-batch-v1+converge512，未采用590 no-op或SIGPROF后继，模型单线程，原fastO2/slowO1/runtimeOs。数学对象/四生成头/PCH/编译flags及完整输入身份按实际manifest核验；同版可复用，只为必要只读全层capture/main或外部driver重编。kind7一次公开BEGIN，初始H仅原embedding_norm4096组；后继所有层H由实际RTL产生，不能切层注入、预装中间gold、跳层、缩shape、改变算术/舍入/断言或用CPU/DPI代算。两种独立Decision仅作原身份组件依据，不拼接冒称整图。

**分段保护与范围。** 一次进程连续执行原28Encoder+2Decision，保留全部原checker。每层从真实入层到原层端点连续≤600s；每个连续计算/交接段≤120s，按已经验证的preLN（首层省略）、QKV、16个依序head、Attention成功、WO、residualA、postLN、完整Wi/G/quant→Down或完整FC1/ReLU/quant→FC2、Down/FC2成功、residualB及真实层端点建立严格状态机。各BEGIN、中途计数/retirement不得重置连续段帽；global变更/阶段事件须核层号/单调计数/前序真实完成。Encoder27→final gamma LN→type→Decision0前置LN的新增交接单独≤120s；最后Decision1→544个真实尾写/flush/延迟commit/成功DONE消费与正常idle亦≤120s。初始setup/H费用包含第一层；清理/产物写入计总墙钟。无新gold时严格递增真实retirement只续stall计时，不能续阶段/全局计时。任意数值/协议/身份/缺事件/乱序失败立即停止；资源、总额、逐层/逐段帽触发明确COST_STOP，不自动加时重试。

**真实验收。** 原30层H端点、final LN/type、初始输入/gather合计34个FPGA/输入端点依原独立字节参考检查；另13个CPU checkpoint仍仅身份绑定。必须实际一次BEGIN、120矩阵/目录、480head、60LN、60残差+1type、28GEGLU、两次FC1各16384真写/ACK/发布后才FC2、30个层端点，以及544×128=69632B真实尾写、flush、1次合法commit及全部资源退休/heldDONE/正常idle，完整原终标且无Fatal/Error才PASS。计数定义以原生产/TB实际事件为准，不能把retirement日志当gold值数。保持actualH0、每层真实H捕获、原public尾输出和元数据/唯一坐标/字节数/实际SHA，主控独立逐字核原参考；capture只读真实接受/提交接口，不重建gold。只读capture普通修复不改checker或DUT。

运行中按实际阶段/层端点报告进展并保存日志；初始新driver先以原AT005/010/011事件做回放/缺事件拒绝测试，少量synthetic次序案例与真实运行证据分开。完整正常链通过也不代签所有异常恢复、四态X传播、联合面积/布线时序、Host/DMA/板卡性能；M007整体验收状态据真实范围另判。
