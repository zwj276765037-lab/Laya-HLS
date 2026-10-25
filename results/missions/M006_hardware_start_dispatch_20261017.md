# M006硬件恢复派发：完整板端Attention首段

2026-10-17；A001→A002；D-M006-HARDWARE-START-01；M006/SM007/E007/R001。

直接用户新授权：本主控会话用户在Goal/Mission修订完成后问“可以开始进行硬件修改了吗”。按开始硬件实施与必要验证处理，M006本段硬件暂停解除；旧M004/SM004与A003仍暂停。这不是旧内部消息自行解除暂停。

请现在按 `mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md` 连续开始实际工程。上位合同为Goal v8、M006修订5及performance_requirements.json：全部Attention在FPGA，CPU只输入/尾部/Host，旧CPU Attention/62DMA/旧预算已废止。先读NEW_CHAT_START/current及上述合同，不沿用你旧A002使命顶部M004排程。

你仍是唯一E002实现/重工具owner；E007只存新证据。期望gpt-6.1-sol/xhigh，实际配置由你核查记录。不要回退他人修改；原baseline/冻结证据/独立参考不改。父控已登记SM007/E007/R001，初始attempt本批AT001。开始后更新自己mission入口、state和E007三摘要，不能仅回“收到”而不开展。

首段优先生产共享256lane FP、QKV/PS/G/LN bank复用及QK/AV，严格SFU/divider单lane真实综合风险核查→8lane/softmax/RoPE接入，最终真实生产模块OOC。完整单head/16head只按实际完成范围签，保持8192MAC/300MHz/7200DSP和逐shape帽；不可CPU Attention fallback或TB保存结果替算。详细顺序、数值、写入和范围在SM007，普通修复/编译/回归无需逐次放行。

本段独立累计：模块参考/单测900s，static1800s（单次≤600s），RTL3600s（pilot≤120s、单次完整≤1200s），模块综合/OOC3600s；原CPU0–3/nice19/idle/MemAvailable>192GiB，单重工具，RSS和停滞保护见合同；旧余额不转。允许模块期望核算和模块EDA，当前不做CPU/GPU整模基准、整模新gold、完整平台P&R或上板。

达到实际阶段成果、资源/数值实质阻塞或成本出口直接发我；有实际综合结果再集中架构评判。请以真实启动状态与第一项实现/验证结果回报，而非等待新的逐项确认。
