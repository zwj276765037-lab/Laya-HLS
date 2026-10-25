## D-M007-SM012-FINAL-LN-SUFFIX-36（2026-10-24，E021/R004）

用户在获知可从保存H分段复测后明确“支持修复喝接着验证”，授权本段修复和验证；完成后仍暂停。不重跑前28Encoder、不自动恢复旧mission/物理/部署。D35原FAIL、frozen、日志和封存余额不改、不转入。

复用A010、A012（既定gpt-6.1-sol/xhigh）：A010唯一写forward_controller父v3、相关TB及模块source增量；A012唯一写tools/m007_verilator、E021/R004和三摘要。其他RTL owner保持暂停；双方共享工作区，不撤销他人改动，不创建新agent。主控唯一维护合同/总结果/验收。

最小生产修复是保证final LN的gamma选择在实际下层命令握手和执行期稳定；普通LN、数值叶、模型、gold、shape和正式kind5/6/7 ABI不变。先短例明确复现旧gamma命令/数据问题，诊断复合断言各项；同刺激验证修复，并补普通无gamma路径和有限命令延迟的保持检查。失败断言语义不削弱，独立参考不改。

分段输入固定为D35 AT001 `work/actual_fullgraph.layer27.f32.bin`，524288B/131072F32；使用前核采集身份和与原参考全字节一致，禁止用checker数据冒充实际输入。没有完整仿真状态快照，因此必须显式标记SEGMENTED_SUFFIX。采用默认关闭、仅验证使用的入口建立真实model setup、完整H装载与资源静止资格，再进入同一生产final LN→type→Decision0→Decision1→544输出/tail路径；具体最小入口在本节集中补充后实施。禁止TB强制done/债零/原28层完成计数、跳过实际后缀计算，或复制一套后缀FSM。原生产默认配置及旧完整检查保持；新增后缀checker只声称本段实际覆盖。

验收包括final LN全部131072值、type全部值、两Decision实际H和最终544向量对原独立gold逐字，真实tail写入/延后commit/heldDONE消费及真idle；记录后缀独立周期和墙钟，不与旧前缀拼成修复版完整一次BEGIN或端到端实测。前28层PASS保持原版本身份，受影响公共逻辑用必要短回归覆盖。

独立预算reference0/static1800/RTL3600/OOC0秒，RTL预留300s收尾。未知片段pilot≤120s；已有同环境真实两Decision331.6/339.3s仅作成本依据，final LN/type/tail及新构建开销另测，不记0。完整后缀单次≤1800s且启动前保守计划≤余额减300；每Decision≤600s、连续阶段/语义stall≤120s、40Mcycles。static默认未知≤120s，有同构建实测依据可≤600s，费用含失败/旧版复现/准备，不能原样延帽重跑。CPU0–3、单模型线程、nice19、idle I/O、MemAvailable>192GiB、static24GiB/RTL8GiB和全项目单重工具锁保持。无新工具安装/OOC/P&R/GPU/上板。普通修复和受影响测试按本段连续执行，集中交付后主控核原证据、清理owned、封账暂停。

D36固定测试入口：采用A010提出的`VERIFY_POST_ENCODER27_H`默认0参数。仅后缀验证配置为1；仍使用真实setup、kind7 BEGIN/TAIL_ARM和4096组公开H写入。在原`E_H_READY`的`h_load_success_valid && resident_retired`成立后，测试配置将layer_index置27、active_epoch_offset置448并进入同一`N_OWNER`；其它状态、FP/LN/source资格、lease/read/write及错误/退休均照生产路径真实发生。禁止在TB写入DUT内部态或模拟器完整状态。参数0逐分支保持原正式入口语义；这是模拟分段边界初始化，不能证明旧第27层实际退休到该入口的连续交接。

gamma修复固定为父端选择覆盖N_START及N_RUN，使provider延后的命令和保持期看到同一值；不改变provider/数学叶。旧版与修复版使用相同后缀测试入口、actual H、原gold和检查，仅此gamma逻辑不同。后缀checker应真实统计2层/8矩阵/32head/5LN/5VECTOR以及544输出/tail，保留原kind7默认checker，不填充原28层覆盖位。先旧版短例记录实际命令gamma与首次原数据/身份断言；修复版先验证finalLN/type及Decision0 preLN，再在已有同版片段成本支持下运行一次完整后缀。新失败据实际证据普通修复，既有失败不回写。
