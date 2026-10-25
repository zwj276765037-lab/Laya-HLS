# Laya-HLS：独立 research-agent 项目

先读 `NEW_CHAT_START.md`、`goal/goal.md`、`mission/current.md`、`results/overview.md` 和 `results/review_queue.md`。使用 `/home/zwj/.codex/skills/research-agent/SKILL.md`，硬件实现同时使用 hardware-agent。

本项目根为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`；唯一新实现工程为 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`。原 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline` 是保留的历史来源，禁止删除、移动或因副本开发写回原工程。复制的文件是历史原样记录，未来新运行路径依 source/path_mapping.md 重建。

父目录Laya的AGENTS中，M002/SM002/E002/A002、refresh_console.py及Laya-repair描述属于旧Laya顶层投影，**不是本独立项目的登记**。本项目同名ID只在自身 `.research-agent/project.json` 中解释。不改Laya顶层goal/mission/results/刷新器或其他项目；本项目摘要由research.py publish原生维护。

主控唯一维护goal、顶层mission、索引、模型策略、review与总结果。工程维护E002实现、模块source/design.md和results.md、RTL/TB及原始运行；研究维护方法与瓶颈证据。模块复用既有source/rtl/tb目录，design.md只引用design_source规格位置，不额外复制规格。共享RTL/接口与索引必须只有一位写入负责人；你不是唯一在服务器工作的用户，不得撤销他人修改或管理无关进程。

最新分工：GPT-6.1 Sol/xhigh按既定mission连续实现、编译、仿真、修复和受影响回归；GPT-6 Astra/xhigh仅在实际综合结果之后集中评判结果和改进方案。普通实现或脚本错误没有逐次源码/编译/运行审批，不要求用户逐轮审核。未定义的实质架构、接口或数值变化不得偷偷替换合同，按现行模型政策处理受影响边界。仅在实质阻塞、阶段完成或最终结束时向用户报告。

原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。

全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。

PASS、FAIL、NOT_RUN和COST_STOP分别记录，软件CPU/CSim、分段RTL、同runtime完整RTL、OOC、P&R/时序、上板独立报告。目标优先正确性、完整推理、可核实吞吐改善与资源预算；50ms不是唯一硬门槛。代理注册不代表启动，未取得真实runtime/thread/model不得填写为已运行。

## Codex工作对话

同名分区Laya-HLS已创建四个职责对话：项目主控与架构评判、工程实现与验证、研究探索与瓶颈分析、技术问答。入口与真实绑定见agent/work_chats.md及.research-agent/codex_workspace.json。A编号仅为内部兼容标识；三个主角色目录保留。技术问答维护question，工程仍是实现文件的唯一写入负责人；建立聊天不代表启动硬件实验。恢复时复用既有入口，不重复创建。


## 四个职责会话自主通信（用户2026-10-11直接授权）

用户已明确授权主控、工程、研究、问答四个既有会话自主提问、答复、决策和交付，无需用户手工转发。直接人类来源及实际四个收发身份见 `.research-agent/communication.json`；技能规范见 `/home/zwj/.codex/skills/research-agent/references/communication.md`。优先使用原生发送工具；当前服务器会话缺少该工具时，运行 `python3 /home/zwj/.codex/skills/research-agent/scripts/communicate.py send --root /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS --from 自己的角色 --to 对方角色 --kind question或answer --id 稳定消息ID --message-file 项目内文本路径`。答复添加 `--in-reply-to 原问题ID`。发送会唤醒既有对话并保存原生接受回执；仅写Markdown不能宣称已通知。授权仅覆盖本项目现有任务内协作，不改变职责、合同、模型、审核停点或实验成本约束。

<!-- research-agent:organization-rules:begin -->
## 统一记录与导航（用户已授权落地）

日常入口为根目录 README.md；任务、实验、工作通信和用户问答分别从 mission/index.md、project/index.md、communication/index.md、question/index.md 定位。四个实际会话见 agent/index.md。详细规则见 /home/zwj/.codex/skills/research-agent/references/organization.md。

首页、索引、任务/实验/批次README和通信时间线由 organize.py 统一生成；不得手工重写生成区。主控继续维护 goal/任务合同/决定/审核，工程继续维护唯一E002实现及运行证据，研究维护source，问答维护question。手工更新原记录后运行 python3 /home/zwj/.codex/skills/research-agent/scripts/organize.py refresh --root /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS。发布、状态报告和辅助通信已有自动刷新钩子。

旧M/SM合同、R目录、attempt名称、输入/源码/原始日志和收据保留原路径。正在进行的R003及其已启动尝试继续原路径执行；不为目录整理重启、重跑或扩大预算。新批次采用R，新具体尝试采用AT；新mission采用任务文件夹。旧登记ID再次使用时保持原身份和路径。

消息统一写入 .research-agent/communications 并按回复链生成C讨论。使用 communicate.py send 自动归档，原生发送后 archive 实际接受结果。答复关联原消息；送达、答复、实施、验证状态分开，重要讨论由负责人确认范围并附证据后登记待验证/关闭，不要求普通消息反复确认或用户审批。

当前总mission仍是M004，M003是前置；导航不修改科学结论或验收状态。主控切换当前任务/依赖时运行 organize.py configure。仅有记录和局部PASS不能代签完整加速器。

<!-- research-agent:organization-rules:end -->

## M007当前执行授权（2026-10-21，优先于旧队列和单一A002描述）

用户明确授权新Goal/Mission及GPT-6.1-Sol子智能体推进。当前M007合同和SM008/SM009限定：A007拥有E002/experiment/vivado/module_design/attention_and_fp_engine及E008；A008拥有E002/experiment/host/m007_deploy、tests/m007_deploy、tools/m007_deploy_identity.py及E009。A001拥有目标/合同/指标/索引/集中审核。你不是唯一在代码库工作的人，保留他人编辑。

旧M004/M006/SM007及A002/A003会话不自动恢复、不转旧余额；新执行者不是复制的新项目。M007统一重工具锁`.research-agent/m007_heavy.lock`覆盖全部实际重工具进程，预算见当前任务。仅在边界交接后改变同一文件owner。用户恢复指令覆盖旧全局暂停，但不复活历史任务队列。

## 主控主动接续（2026-10-21）

用户明确要求主控收到子智能体交付后主动核对、下达后继范围并推进M007，无需用户催促。阶段门是主控内部核验，不是每段向用户重新请求授权。主控应保持活跃处理实际消息、解决依赖、复用现执行者；只在确需用户决定或外部条件时升级。登记、定时文件或状态页不代表实际后台执行能力，不默认创建定时任务。

M007阶段接续D-M007-SM011-QKAV-01：A007从已完成的E008叶子交付转入SM011/E010/R001，继续拥有同一attention_and_fp_engine实现目录及E010三摘要/原运行。E008历史证据不回写；原生PS/G/context存储在此唯一实现并供后继matrix/G复用。A008按SM009追加合同继续业务前端/解码，所有权不变。当前SM011局部QK/AV无需等待未实现的SM010父图，不能代签父图接线或完整Attention。

M007 D-M007-SM010-WSUPPLY-01：A010唯一拥有hbm_loader_and_cache内新增M007供数/双超块cache文件、该模块source新M007小节、tools/m007_weight_pack.py及E011证据。旧t4/父入口只读；A007/A008所有权不变。A009勘查已交付，不再并行改上述实现；后续恢复PS必须串行交接并复用A007唯一银行。

M007 D-M007-SM010-MATRIX-02：A010结束E011后接E012/R001，新增拥有q8_linear_and_restore内M007文件及该模块source新小节；其原W服务所有权保留。A007的shared FP/storage只读直接实例化，不复制或并行改写；A008 Host所有权不变。

M007 D-M007-SM010-QUANT-03：A008在E009/R002冻结交付后接E013/R001，新增拥有activation_quantizer下M007新文件及source增量小节；旧quant16只读。A007唯一写shared_div8/严格FP与Attention，A010唯一写A cache/W/矩阵，A008只读实例化这些模块，不建另一份物理除法/恢复服务。开始以主控实际followup为准；记录准备不等于运行。原Host/CPU未达性能项保留并延后有界接续。

M007 D-M007-SM011-LN-05：A008在E013冻结交付并收到实际接续消息后，新增拥有layernorm_engine下M007新文件/source增量及E014；A007仍唯一写sharedFP/div8/LN-exp，A008只读复用。phase6真实返回旁路由A007修改，E014负责独立受影响测试。旧LN/旧任务不恢复、不改gold；其它owner边界保持。

M007 D-M007-SM011-HEAD16-06：A007冻结E010/R002受影响恢复后直接进入E010/R003，同目录唯一拥有layer/head/RoPE与QKV写别名实现；旧bank可薄壳兼容，不复制资源。A008 LN、A010 fullN及共享文件单owner不变。新完整16head单次RTL专用≤1800s且同版成本门，普通≤1200s/未知pilot≤120s及全项目锁保持；见SM011合同。

M007 D-M007-SM010-F32-MATRIX-07：A010在E012/R002冻结/成本出口后直接接R003，同一生产路径接A008已冻结quant_group32与唯一DIV8，新增真实A fill取消和F32流父控制；A008当前LN及A007 Attention所有权不变，冻结量化/共享RTL只读。独立预算与全域quant首错/实际债条件见SM010，原余额不转，不代签整图。

M007 D-M007-SM011-TANH-G8-08：A008在E014/LN-05交付后接E015/R001，新增vector_and_ffn下m007实现和原始证据；严格TANH快速内部叶子/8lane及纯Gengine，原共享FP/DIV/EXP/storage仍由A007唯一写并只读复用。TANH/EXP公共SFU集成后继由A007负责，不私自改现wrapper；G使用现65536B银行，禁止复制整G tensor。详见SM011；未实际启动不得登记running。

M007 D-M007-SM012-SINGLE-PARENT-11：A010在E012/R004实际出口后新增独占forward_controller中的M007 parent/top/router/context-quant-adapter及source增量、E016/R001。A007保持Attention/资源文件唯一写入人，A008保持TANH/G；父仅一份同版FP/PS/DIV/QKV，不接含私有资源兼容壳。独立预算和串行锁见SM012，旧预算不转；正式接续已授权，无需用户催促。


M007 D-M007-SM012-CONTROL-ARENA-16：A008已冻结G-RING-TAG-15；A007接E018/R001，新增暂时独占vector_and_ffn的laya_m007_g_math_v1.sv、laya_m007_g_engine_v1.sv共享控制q/next接口及必要TB/runner，与自身layer coverage接口/新workspace组合实现。A008此阶段不并行修改上述文件。A010保持父controller唯一owner，当前完整Attention父结果冻结，仅做FFN接口只读准备；所有数值叶、其他共享资源及旧任务所有权不变。

M007 2026-10-23后继：A007继续独占G engine取消接口/组合透传及E018 R002（D-M007-SM012-G-CANCEL-17）；A010新增E016 R004独立局部参考/fixture准备（D-M007-SM012-FFN-REFERENCE-18），不写G或运行EDA。A008的G编辑仍暂停；E018 R001/E016 R003保持冻结。

M007 2026-10-23用户明确继续FFN、残差/LN、完整Encoder及30层：A007接E018 R003 CANCEL-END-19；A010接E016 R005 FFN-CHAIN-20并唯一写forward_controller，G接口只读；A011只读架构source/m007_residual_encoder30_20261023.md，不写工程或主控索引。所有实现仍在E002唯一树，旧证据封存，详细范围/新独立预算见SM012。

M007 D-M007-SM011-RESIDENT-RESIDUAL-21：A007结束E018 R003后接E019 R001，新增独占attention_and_fp_engine中hidden32/resident_vector32/Qscratch公开adapter及必要TB/runner。A010父controller独占不变；不并行修改共有QKV/资源源，变动前告知冻结依赖。LN第三owner压缩尚待正式细化，旧A008不自动恢复。

M007 D-M007-SM011-LN-COMPACT-22：A008复用原host_tail_engineering，仅接E014 R002与layernorm_engine纯canonical/external q-next压缩及协议/首错验证；A007继续E019与唯一真实workspace/shared资源，A010父不变。A008不恢复旧Host或G文件编辑，不跨写共享arena。实际启动依主控followup，不转旧预算。

M007 D-M007-SM011-JOINT-ARENA-23：A007完成E019 R001后经实际followup接R002，独占attention_and_fp_engine新增workspace_v2/joint_v2、VECTOR v2与resident LN provider；A010现v1父/build冻结不改，A008 LN pure接口仍唯一owner。同一真实12288bit四owner，规范布局12120bit；详细预算/验证见SM011，旧余额不转。

M007 D-M007-TANH-IDLE-CE-26：A008在A011静态§13交付后，经实际followup接E015/R002，唯一写vector_and_ffn新tanh_core_v2/tanh8_v2及必要TB/runner，旧v1和G不变。A007唯一写joint组合选择，A010唯一写父；无活动lease数值CE按§13，预算见SM011。catalog暂不同时实施，旧预算不转。
M007 D-M007-SM012-MODEL-CATALOG-28：A008完成E015/R002独立CE等价交付后经实际followup接E020/R001，唯一写新model_catalog reader/TB/source、tools/m007_model_catalog.py及对应tests；父/W mux/bias仍A010、type/VECTOR/资源仍A007。固定格式与新独立预算见SM012，旧余额关闭不转。

M007 D-M007-TANH-PROCESS-CONSOLIDATE-31：A008完成E020/R001后经实际followup接E015/R003，只新增vector_and_ffn的tanh_core_v3/tanh8_v3及验证，旧v1/v2冻结。A011只追加原source全模型ABI；A010父独占与当前v2构建不变，A007D29尚待实际接续。

M007 D-M007-SM011-TYPE-RESIDENT-29：A007经实际followup接E019/R004，唯一写attention_and_fp_engine新type bank/VECTOR v3/joint v3及必要验证。旧joint v2/body6f7363b6和A010当前父快照保持；A008新TANH v3只读等交付，A011父ABI文档单owner不变。

M007 D-M007-SM012-FULLMODEL-PARENT-32：A010经实际followup接E016/R007，新canonical parent_v3/两槽catalog-W mux/真实transport_idle/bias facade仍由A010唯一写，A007独占TYPE-29/joint_v3、A008 catalog/TANH只读复用。旧v2/R006保持独立身份与预算；正式ABI见source §14，先源码后D29重工具窗口，主控实际派发才记running。

M007 D-M007-SM012-COMPILED-RTL-CROSSCHECK-33：用户2026-10-23直接允许隔离添加Verilator5.020并交叉验证；A012新增唯一拥有E002/experiment/tools/m007_verilator及E021证据，不写生产RTL/原TB/gold。A010父/按需peer与A007资源owner保持。root管理用户工具目录的固定包，不能系统安装或改全局PATH；新后端未验同数值/周期前不能迁移全图通过结论。详见SM012新合同，实际spawn后才记running。


M007 D-M007-SM012-ORIGINAL30-BOUNDED-35（2026-10-23）：用户已授权完成原30层，主控据E021/R002首原始层及两完整Decision实际成本，为E021/R003唯一一次原kind7整图定义独立static300/RTL15600（留600），单次RTL15000s，替代本任务通用3600s；每层600s/连续阶段120s/语义stall120s/40Mcycle、8GiB、CPU0–3且单线程nice19/idle、MemAvailable>192GiB及全项目单锁不变。不自动延时或重跑，不改shape/数值/gold，不转旧余额。详细条件/实际验收见SM012 D35；其它任务继续原帽。


## 用户指定本轮停点（2026-10-24）

用户明确要求“完成验证后 暂时暂停项目”。继续当前 D35/E021 R003 AT001 唯一原30层运行，完成实际结果核对、额外交接监督合并、原始证据/摘要归档与owned进程清理后，M007及主控/执行者登记paused，等待用户明确恢复。不得自动接续新实现、实验、优化或物理/部署阶段；当前失败或成本停止须保留报告，不自动重跑。当前运行尚未完成，本指令不是立即中止。

2026-10-24后续明确授权：用户同意修复并使用保存的Encoder27实际H接着分段验证，恢复范围仅SM012 D36/E021 R004。A010父RTL/TB、A012工具/运行各自恢复，其他owner和旧任务继续暂停；不重跑前28层，不转D35余额，不冒称完整一次BEGIN通过。本段完成后再次暂停，具体独立预算/验收见SM012 D36。


## D36验证完成后的暂停（2026-10-24最新状态）

用户授权的gamma修复及保存实际H后缀验证已完成并限定PASS，证据/预算/owned清理归档。按用户原要求本段结束后暂停M007，等待明确恢复；D36普通修复授权不再启动新实验或后继。原28层旧证据、R003FAIL、完整30层一次BEGIN未重验及其它开放项保持。


## D37最新用户授权（2026-10-24）

用户明确要求修复版完整30层一次运行并创建子代理、常规每小时汇报。仅恢复SM012 D37/E021 R005；实际新A013接tools/m007_verilator与E021运行写权，A012和其他工程保持暂停；生产RTL/TB只读。参数VERIFY_POST_ENCODER27_H=0/原kind7一次BEGIN完整28+2真实计算，单次15000s/独立RTL15600、static1800及原逐层/逐段资源保护见D37，覆盖本次通用3600s上限。完成收尾后暂停，不自动扩展后继。
