#!/usr/bin/env python3
"""Fill native research-agent records after a verified, full baseline copy."""
import datetime, hashlib, json, pathlib, subprocess, socket
N=pathlib.Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
D=N/'project/E002_Laya_HLS/experiment'
B='project/E002_Laya_HLS/experiment'
I='project/E001_baseline_import'
RR=I+'/experiment_results/runs/R001'
H='/home/zwj/.codex/skills/research-agent/scripts/research.py'
C='/home/zwj/.codex/skills/research-agent/scripts/console.py'
R='results/compute_throughput_optimization_20261010'
receipt=json.loads((N/RR/'copy_receipt.json').read_text())
assert receipt['status']=='PASS_COPY_VERIFIED',receipt['errors']
def write(rel,s):
    p=N/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s.strip()+'\n')
def dump(rel,obj):write(rel,json.dumps(obj,ensure_ascii=False,indent=2))
def call(script,*args):
    r=subprocess.run(['python3',script,*args],capture_output=True,text=True,check=True)
    return json.loads(r.stdout)
def link(label,rel):return f'[{label}]({rel})'
count=receipt['counts'];gb=receipt['logical_regular_file_bytes']/1024**3
src=receipt['source']
common='原模型/完整shape/层数/独立gold及数值规则不改；真实模型数据、独立参考、自检断言、超时保护、原始日志与源码/输入身份必须保留。未变且已通过的测试复用原身份，只重跑受影响范围。'
budget='全项目最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable>192GiB。RTL≤8GiB/3600s/40Mcycles，pilot≤120s；static≤24GiB/1800s；模块OOC≤24GiB/3600s，120s真实语义停滞保护。只管理本项目owned进程。整体OOC/P&R/专项时序未在此接入阶段启动，无U55C，不影响服务器其他项目。'
write('README.md',f'''
# Laya-HLS

这是按 research-agent 原生结构建立的独立项目。原 `LLAMA-HLS/Laya-baseline` 当前阶段收口后，完整复制到本项目；原工程保留。**完整加速器尚未验收**，本次搭建与一致性核对通过不代表整网硬件通过。

新对话从 [NEW_CHAT_START.md](NEW_CHAT_START.md) 开始，实际代码工程在 [{B}/]({B}/)，其 [README]({B}/README.md) 和 [阶段收口]({B}/{R}/stage_results.md) 保留历史事实。

| 目录 | 用途 |
| --- | --- |
| [goal/goal.md](goal/goal.md) | 完整高性能 Laya 加速器目标、正确性与性能验收口径 |
| [mission/current.md](mission/current.md) | M001复制完成、M002实现计划及下一步 |
| [project/missions/](project/missions/) | 可独立验证的小任务合同 |
| [{I}/]({I}/) | E001复制协议、SHA/链接映射与核对收据 |
| [{B}/]({B}/) | E002完整原工程副本：HLS/RTL/TB、模型包、冻结日志、结果和历史工程 |
| [source/method.md](source/method.md) | 当前方法、来源与路径使用约定 |
| [agent/agent_manage.md](agent/agent_manage.md) | 主控、工程、研究角色；新项目代理均未启动 |
| [results/overview.md](results/overview.md) | 一页现状与通过/失败/未验证边界 |
| [question/question_manage.md](question/question_manage.md) | 待实际提出的技术问题登记入口 |

完整复制核对：{count['file']}个普通文件、{count['dir']}个目录、{count['symlink']}个符号链接；普通文件逻辑字节 {gb:.3f}GiB，逐文件SHA256一致。副本与原文件不共享普通文件inode；内部链接重新指向副本。[复制收据]({RR}/copy_receipt.json)保存精确数字，历史日志/收据中的原绝对路径按[路径约定](source/path_mapping.md)解释。

不直接运行冻结attempt脚本。新运行须使用副本工程根并重新生成路径配置，防止写回原工程。共享模型目录为 `Workspace/Laya/model`，按只读输入使用。
''')
write('AGENTS.md',f'''
# Laya-HLS：独立 research-agent 项目

先读 `NEW_CHAT_START.md`、`goal/goal.md`、`mission/current.md`、`results/overview.md` 和 `results/review_queue.md`。使用 `/home/zwj/.codex/skills/research-agent/SKILL.md`，硬件实现同时使用 hardware-agent。

本项目根为 `{N}`；唯一新实现工程为 `{D}`。原 `{src}` 是保留的历史来源，禁止删除、移动或因副本开发写回原工程。复制的文件是历史原样记录，未来新运行路径依 source/path_mapping.md 重建。

父目录Laya的AGENTS中，M002/SM002/E002/A002、refresh_console.py及Laya-repair描述属于旧Laya顶层投影，**不是本独立项目的登记**。本项目同名ID只在自身 `.research-agent/project.json` 中解释。不改Laya顶层goal/mission/results/刷新器或其他项目；本项目摘要由research.py publish原生维护。

主控唯一维护goal、顶层mission、索引、模型策略、review与总结果。工程维护E002实现、模块source/design.md和results.md、RTL/TB及原始运行；研究维护方法与瓶颈证据。模块复用既有source/rtl/tb目录，design.md只引用design_source规格位置，不额外复制规格。共享RTL/接口与索引必须只有一位写入负责人；你不是唯一在服务器工作的用户，不得撤销他人修改或管理无关进程。

最新分工：GPT-6.1 Sol/xhigh按既定mission连续实现、编译、仿真、修复和受影响回归；GPT-6 Astra/xhigh仅在实际综合结果之后集中评判结果和改进方案。普通实现或脚本错误没有逐次源码/编译/运行审批，不要求用户逐轮审核。未定义的实质架构、接口或数值变化不得偷偷替换合同，按现行模型政策处理受影响边界。仅在实质阻塞、阶段完成或最终结束时向用户报告。

{common}

{budget}

PASS、FAIL、NOT_RUN和COST_STOP分别记录，软件CPU/CSim、分段RTL、同runtime完整RTL、OOC、P&R/时序、上板独立报告。目标优先正确性、完整推理、可核实吞吐改善与资源预算；50ms不是唯一硬门槛。代理注册不代表启动，未取得真实runtime/thread/model不得填写为已运行。
''')
write('goal/goal.md',f'''
# Laya-HLS 目标

将真实 Laya Typed-Decisions Q8_0 微调量化模型实现为具有可核实性能改善、可部署资源预算的U55C加速器。来源：用户要求先做到计算性能与推理准确度，再考虑最终综合时序；性能同时考虑请求流水吞吐，50ms仅为远期参考。

CPU负责token Embedding、输入/请求打包、固定权重一次完整校验与会话生命周期、XRT控制/同步及结果解码。FPGA承担后续全部LayerNorm、内部EMB_TYPE、动态activation量化、Q8矩阵、Attention、GEGLU/向量、Decision/scorer/ACT及真实响应退休；不将后续LN移到CPU。U55C是PCIe加速卡，没有承担这些Host工作的独立通用CPU，Host是服务器CPU。沿用两个Llama baseline的CPU/XRT/PCIe/HBM部署框架，不能因此假定板端已通过。

## 成功标准

1. 同冻结模型完整B1/S128、28 Encoder＋2 Decision＋scorer/ACT、全部122 Q8矩阵，在当前实现身份下对独立参考验证数值/最终决策及故障后恢复。
2. 模块连接证明真实producer、缓存/lease/owner、AXI读写债务和最后B退休；分段替代覆盖必须列出没有覆盖的同runtime整图行为。
3. 同一模型/shape/反压/缓存/计量边界比较冷暖延迟、填充排空、完整请求完成间隔、有效服务及停顿，功能接通不能直接写性能改善。
4. 分别取得目标器件模块资源、联合无重复计费预算、真实物理时序与板端结果；未执行层级保持未验证。

{common}

当前事实：旧冻结build完整CPU及真实Vitis CSim通过；多块局部RTL/OOC有范围通过，当前完整13BO物理生产连接、全图硬件和上板未通过。准确率需要冻结带标签数据集与同模型对照，几个请求逐位一致不代表数据集准确率。A6000原50ms报告口径不同，暂不计算加速比。

{budget}
''')
write('mission/current.md','''
# 当前 mission

| ID | 状态 | 合同 | 下一步 |
| --- | --- | --- | --- |
| M001 | completed / 复制核对supported | [工程复制与Research接入](M001_工程复制与Research接入.md) | 已交付独立项目和新对话入口，原工程保留 |
| M002 | planned / 完整硬件unassessed | [完整Laya加速器实现](M002_完整Laya加速器实现.md) | 新对话恢复实际副本、核实当前身份，再按SM002接通生产链 |

最新用户决策：在当前阶段结束后完整复制搭建Laya-HLS；不删除原baseline；用户另开专用新对话。此接入阶段不新启动LN、更宽Q8、整图工程或G新物理闭合路线。已有常规实现授权和取消逐轮审核的偏好保留，当前没有新代理或硬件工具运行。
''')
write('mission/M001_工程复制与Research接入.md',f'''
# M001：工程复制与Research接入

execution_state: completed
verdict: supported
applicability: 本次baseline完整副本一致性与research-agent登记，不含新增硬件验证。

用户要求当前阶段性任务结束后将 `{src}` 完整复制到 `{N}`，保留原工程，方便新对话专用实现。SM001/E001已完成原样普通文件复制、SHA256一致性、权限与entry集合检查、跨源hardlink检查、内部链接重映射。完整副本置于E002/experiment，不搬移原工程。真实精确结果见[收据](../{RR}/copy_receipt.json)。

一次低优先级复制与串行校验，无硬件工具/新agent启动。已建立目标、M/SM/E/A记录、三摘要、资源与模型政策、真实边界和交接入口。下一步转M002，不能据复制PASS宣布完整加速器PASS。
''')
write('mission/M002_完整Laya加速器实现.md',f'''
# M002：完整Laya加速器实现

execution_state: planned
verdict: unassessed
applicability: 尚未在新项目启动实现；继承结果各按原冻结身份和范围解释。

## 痛点与当前基线

完整CPU/CSim是旧稳定build23c62cd4的软件通过；目前新Q8驻留、Attention与G存储优化是局部硬件结果，实际13BO生产入口未完整连接。直接复用局部PASS不能判整网硬件通过。权威现状是[副本阶段结果](../{B}/{R}/stage_results.md)与[联合设计](../{B}/{R}/source/design.md)，历史已知失败、成本中止和未验证保留。

## 实现和验收

通过SM002恢复同一副本工程与当前输入身份；按已定义的显式命令/完成FIFO、持久fullA/W/PS/bias/writer、真实AXI owner/debt绑定原13BO生产壳。先接通同runtime最小真实producer边界，再冻结新build进行完整CPU/CSim与有界分段RTL；能合理完成才整层/整图RTL。当前Attention/G/PS结果复用必须身份匹配。最终用完整请求延迟和完成间隔检验性能；不能用条件150MHz换算当物理频率或端到端实测。

{common}

## 负责人、资源与停止条件

A001主控/架构结果评判；A002唯一工程实现负责人；A003按实际需要研究瓶颈。角色目前仅登记未启动。工程GPT-6.1 Sol/xhigh连续修复；Astra/xhigh在综合结果后集中评判及改进。普通修复无用户逐步审批，实质合同改变处理受影响边界；不新增无关正式审核材料。

{budget}

当前接入不启动实现。新对话应先读取[交接入口](../NEW_CHAT_START.md)、核对既有路线与缺口，保持功能/吞吐优先，基于实际资源账再决定G存储物理闭合、LN和更宽Q8的顺序。长仿真先pilot和实速估成本，不能合理完成则列分段替代覆盖和未覆盖项。
''')
write('project/missions/SM001.md',f'''
# SM001：完整复制与一致性验证

所属M001；实验E001。execution_state: completed；verdict: supported。

输入为原baseline当前阶段收口后的全部entries；输出为E002/experiment完整副本及E001/R001核对证据。采用rsync -aH，再将内部符号链接改为副本内相对引用；普通文件不改内容。通过标准：文件/目录/link集合一致，全部普通文件SHA256一致、权限一致、无与源共享普通文件inode、全部复制links有效、源在核对中未改变。结果[收据](../../{RR}/copy_receipt.json)满足全部检查。

由本次主控串行执行；未启动A001–A003，未跑硬件工具。低优先级I/O，不删除源，不管理其他任务。若目标非空、身份变化或核对失败即停止检查，不盲目覆盖。交付为新原生结构、三摘要、模型政策和NEW_CHAT_START.md。
''')
write('project/missions/SM002.md',f'''
# SM002：真实生产接口与推理吞吐闭合

所属M002；实验E002；execution_state: planned；verdict: unassessed。

## 输入、输出和验收

输入为 `{B}` 当前代码与冻结真实模型/请求/独立gold，具体身份从原manifest及实际后继build生成。输出为接通完整13BO真实调用闭包的可运行实现、当前身份完整CPU/CSim、真实producer分段RTL、自检/原日志、服务计量及资源账。完整层数/shape、错误优先级/CE/reset/AXI响应合同不变。gold独立，不为DUT结果改动。通过只对实测覆盖声明，不拼局部PASS成完整推理。

## 执行顺序与依赖

1. 核实副本路径、工具/输入以及既有模块终态，冻结初始实现身份。旧attempt脚本不得直接执行。
2. 复用已验证physical cache/fullA/syncPS/输出服务，按联合设计§3.9完成同生产C闭包命令/完成流与原13BO RTL外壳；接口不是已有PASS。
3. 同runtime真实Wi→G→quant→Down等producer链数值/owner/debt验证，Attention新身份接入；当前最小Down若已有PASS也不能替代上游Wi完整生产。
4. 稳定新身份完整CPU/CSim四持久请求、141独立点及故障恢复；受影响RTL先成本pilot，再完整或分段替代覆盖。
5. 实测请求流水和服务停顿，以真实联合资源账选择后续LN/Q8容量改进。整体物理与上板单列后续范围。

## 负责人和范围

A002拥有E002/experiment代码/TB/脚本与模块design/results；共享入口单owner，不撤销他人改动。A001维护合同和全局记录，A003仅研究来源与可检验方案；新代理实际身份待新对话真实启动才报告。

{budget}

{common}

数值首错、响应错误、真实资源冲突或成本阻塞如实记录并停在依赖边界；允许普通错误连续修复和受影响重跑。用户不要求逐轮审核，只有实质阻塞、阶段完成/最终结束报告。当前新项目未执行此小任务。
''')
write('source/path_mapping.md',f'''
# 副本路径与历史身份

| 项目 | 路径 |
| --- | --- |
| 原工程（保留） | `{src}` |
| 新项目管理根 | `{N}` |
| 新实现工程 | `{D}` |
| 共享模型（只读） | `{N.parent/'model'}` |

副本普通文件内容逐字节保持原样，因此冻结日志、manifest、收据和历史脚本仍可能写原绝对路径；这是当时运行来源，不是新项目执行地址。历史证据按文件在副本中的相同相对位置读取，receipt中的源身份保持历史含义。内部符号链接已映射到副本，完整映射在[{RR}/symlink_mapping.json](../{RR}/symlink_mapping.json)。

新运行必须从新工程根重新生成路径配置，并记录新的源码/输入/tool/config身份。复制的Vivado .xpr、HLS配置、生成工程和attempt脚本可能含原路径，先核查/重建工作工程再启动；不得直接打开运行并写回原工程。不批量修改历史SHA/日志或原始receipt，也不直接运行历史attempt命令造成写回原工程。共享外部模型路径由新运行显式绑定。旧DCP/编译snapshot只在真实源/输入/协议未变且可核实时复用，否则重编受影响闭包。
''')
write('source/method.md',f'''
# 当前方法和来源

部署框架参考两个Llama baseline的Host CPU/XRT/PCIe/HBM模式；算法和数值输入来自真实Laya量化微调模型。原研究/设计保存在副本 [source/](../{B}/source/) 与 [vivado/design_source/](../{B}/vivado/design_source/)，模块详细规格/结果在 [vivado/module_design/](../{B}/vivado/module_design/)。

当前路线：CPU token Embedding＋固定模型一次校验，FPGA全部后续LN/动态量化/Q8/Attention/非线性/Decision；以宽块访存、权重广播与双缓存、同步PS、真实producer交接、共享FP服务改善吞吐。各候选只按独立参考和实测身份判断，软件整图与局部RTL证据分层解释。

当前设计与下一生产接口方案见 [联合设计](../{B}/{R}/source/design.md)，阶段终态见 [stage_results](../{B}/{R}/stage_results.md)。新项目没有新增算法论文或未经验证的性能结论；A003需按实际瓶颈提出可检验实验，而非扩展非关键报告任务。

路径采用[path_mapping.md](path_mapping.md)，完整副本核对独立于硬件正确性。50ms与150MHz都不能替代当前实测整网结论。
''')
write('NEW_CHAT_START.md',f'''
# 新对话从这里开始

请在 `{N}` 使用 `$research-agent` 继续Laya-HLS，硬件工作遵守hardware-agent。先阅读本地AGENTS、goal/goal、mission/current、results/overview与review_queue，再读取E002三摘要。原baseline完整保留；未来只写 `{D}` 及本项目原生记录。

## 已经完成和仍未完成

E001完整复制与一致性核对PASS。E002只是继承当前硬件基线，**完整加速器、同runtime13BO整图RTL、资源fit、物理时序和上板未验收**。具体当前模块终态以 [阶段结果]({B}/{R}/stage_results.md) 为准。旧冻结build23c62cd4完整CPU/CSim四请求、141点/18,094,384 F32及gamma故障恢复PASS；它不能给已改变的新working源身份代签。已知历史数值FAIL、覆盖FAIL、成本中止全部保留。

## 优先恢复的工程工作

1. 核对当前源码/输入身份及已结束工具，不将旧注册A运行状态带入新项目；按agent/model_policy与实际运行工具启动/登记负责人。
2. 按[联合设计§3.9]({B}/{R}/source/design.md)接真实生产C闭包命令/完成FIFO、持久物理服务和原13BO RTL外层：实际BO基址/role/offset，AR/R及AW/W/B债务与RRESP/BRESP/最后B。
3. resident Down、G三bank桥、Attention新tile各以当前封存终态复用。外部冻结Wi checkpoint不能替代上游Wi矩阵producer；外部prequantized A/W不能替代物理缓存链。Attention保留原逐row数值首错、CE/reset及生产caller协议；保存的UNVERIFIED补丁不是已应用/通过实现。
4. G三bank功能已通过，但新父OOC成本中止，完整资源/新RAM映射仍UNKNOWN。§8.4.11为未运行的分层OOC备选，保留原累计预算，不原样加帽。Attention若新OOC终态非PASS，按其实际范围恢复，不能复用旧helper DCP代签新CE namespace。
5. 稳定接入身份后重跑受影响完整CPU/CSim及真实分段RTL，用实际pilot估成本，列整层/整图替代覆盖与缺口。以真实性能/资源账决定LN服务、更宽Q8或多请求调度，不先扩阵列再忽略存储/反馈/输出。

## 工作方式

用户取消每轮人工审核：GPT-6.1 Sol/xhigh连续实现与验证；GPT-6 Astra/xhigh在实际综合结果后集中评判和优化方案。不得默换模型。只报告实质阻塞、阶段完成或最终结束。{budget}

本项目A001–A003是未来角色登记，runtime/thread/actual_model为空；本次没有替用户创建新Desktop对话或启动新硬件实验。已有授权常规修复不用重新确认，但新对话仍须读取当前任务合同，不能将登记等同实际执行。
''')
write(I+'/experiment_source/protocol.md',f'''
# E001：完整复制实验方案与实际执行

来源为用户当前阶段结束后完整复制的要求；源 `{src}`，目标 `{D}`。原工程不移动、不删除、不覆盖。R001保存真实import_project.py、execution_identity.json、copy.log、source_inventory.json、file_sha256.jsonl、symlink_mapping.json与copy_receipt.json。

方法：research.py init/add登记独立项目→rsync -aH全量复制→内部links重映射→逐普通文件双侧SHA256→entry集合/类型/权限/跨源inode/源变化核查。输入身份为R001/source_inventory.json及file_sha256.jsonl，原硬件输入身份完整留在副本内。复制与核对低优先级串行执行，未启动EDA或新代理。

通过标准为所有上述检查无error；实际receipt status为PASS_COPY_VERIFIED。此实验只支持副本一致性，不支持完整硬件功能、资源或性能判断。生成原生管理文档不修改复制工程内容。
''')
write(RR+'/run.md',f'''
# R001 — E001 完整复制与核对

Execution state: completed
Verdict: supported
Applicability: baseline完整副本及内部链接映射的一致性。

- 原工程：`{src}`；目标：`{D}`。
- 起止：{receipt['started_at']} → {receipt['finished_at']}。
- 命令/主机/工具/脚本SHA：[execution_identity.json](execution_identity.json)。
- 实际启动外层：`timeout --signal=TERM 1800 flock -n <原R>/control/heavy_tool.lock taskset -c 0-3 nice -n 19 ionice -c 3 python3 /tmp/laya_hls_import_20261011.py`；原R为上述原工程的`results/compute_throughput_optimization_20261010`。
- 完整复制日志：[copy.log](copy.log)；源entries：[source_inventory.json](source_inventory.json)。
- 普通文件：{count['file']}，目录：{count['dir']}，links：{count['symlink']}，逻辑普通文件bytes：{receipt['logical_regular_file_bytes']}。
- 逐文件双侧SHA：[file_sha256.jsonl](file_sha256.jsonl)；links：[symlink_mapping.json](symlink_mapping.json)。
- 退出：复制命令与核对成功；[copy_receipt.json](copy_receipt.json) error列表为空。
- 原普通文件不改；副本普通文件字节一致，未与原文件共用inode；内部links指副本。
- 本运行不执行硬件验证，也不启动新代理，不能判定整网硬件PASS。
''')
write('project/E002_Laya_HLS/experiment_source/protocol.md',f'''
# E002：继承基线与下一实现实验方案

## 范围与权威来源

完整工程代码位于 `experiment/`，来自原baseline阶段收口后完整复制。所有原代码、HLS生成、RTL/TB、模型包、build、原始attempt日志/receipt保留；复制证据在E001。当前硬件合同/结果为 [联合设计](../experiment/{R}/source/design.md)、[联合结果](../experiment/{R}/source/results.md)、[阶段表](../experiment/{R}/stage_results.md)。此协议映射既有证据，**没有在新目录运行硬件**。

## 平台、数据与身份

目标U55C，Host CPU/XRT/PCIe/HBM框架；真实板卡不存在，部署平台/XRT实测未验证。已有Vivado/Vitis2025.2实际路径/版本以每次原receipt为准。真实Q8 GGUF SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；共享模型只读，输入为完整B1/S128、28 Encoder＋2 Decision/scorer/ACT，122矩阵。旧软件完整PASS身份是build23c62cd4778f54e3cc7508f5d05558de，当前working源已改变，应新建身份验证。

## 步骤和独立参考

按SM002顺序核对现状→显式生产cmd/rsp接口与13BO外层→真实producer及驻留服务连接→稳定新身份CPU/CSim→有界RTL/性能计量→受影响模块资源→集中技术评判。CPU参考/原独立gold和中间checkpoint必须沿用原定义，不读取DUT结果改gold。

原attempt脚本的绝对路径保持历史内容，禁止直接启动；从副本重新生成配置和新的本实验运行R目录，每次记录全部实际源、IP/XDC、模型/输入/reference/tool/config身份与完整日志/退出码/保护原因。复用旧已通过闭包必须验证身份与协议/语义未变，并写“复用”，不是新实测。

## 判定、计量和成本

自检逐位/原适用LN容差及首错/反压/CE/reset/owner/响应退休断言；进程0与实际PASS marker及完整动态计数共同判定。真实输入的几个请求一致不推出数据集准确率。冷暖延迟与完整请求完成间隔按同模型/shape/条件单列，局部cycles、条件150MHz及综合估计不当端到端/Fmax。

{common}

{budget}

成本中止与功能FAIL分开。长仿真先实速pilot，不能合理完成则做有界模块/边界替代并注明未覆盖同runtime整图。新运行尚未启动，E002当前状态为planned、整体verdict unassessed。
''')
for aid,role,model,task,owns in [
    ('A001','controller','gpt-6-astra','项目主控与综合结果评判','goal/、mission/、results/、原生索引与模型策略；实质合同协调'),
    ('A002','engineering','gpt-6.1-sol','按SM002连续实现和验证','E002/experiment实现、模块design/results、RTL/TB/脚本、原始运行与三摘要'),
    ('A003','research','gpt-6-astra','依据真实瓶颈提出可检验方案','source/methods/与论文来源；不自行改工程接口/RTL')]:
    write(f'agent/{aid}/mission.md',f'''# {aid}：{task}\n\n角色{role}；M002/SM002/E002。当前只是未来负责人登记，未启动。先读本地AGENTS、goal与SM002、E002三摘要/协议和当前阶段表。写入范围：{owns}。共享文件单owner；你不是唯一在服务器工作的用户，不撤销他人修改。模型{model}/xhigh显式设置，实际值在真实启动后核查。\n\n{common}\n\n{budget}\n\n重要里程碑/实质阻塞/最终结果向实际主控消息回传，console.py report同步真实状态，详细证据留E002。无逐次用户审批；旧冻结结果只能按身份和范围复用。''')
    write(f'agent/{aid}/config.md',f'''# {aid}：启动配置\n\n期望角色：{role}；期望模型：{model}；期望推理强度：xhigh。来源：用户最新分工及本项目agent/model_policy.md、.research-agent/models.json。\n\nactual_model: null\nactual_effort: null\nruntime_id: null\nthread_id: null\n\n尚未启动，登记不是运行证据；启动前用research.py model-resolve解析并核查实际能力，不默换模型。角色职责、写入范围和预算见mission.md。''')
    write(f'agent/{aid}/status.md',f'# {aid}：状态\n\nexecution_state: planned\n只完成角色登记，本项目没有真实代理或运行进程；后续由实际负责人更新。')
    write(f'agent/{aid}/result.md',f'# {aid}：结果\n\n本项目代理尚未启动，未交付新实现/研究结论。继承基线见E002三摘要，复制结果由E001承担。下一步按mission.md在新对话真实启动后登记身份与结果。')
    payload={'execution_state':'planned','current_task':task,'stage':'角色登记完成、等待新对话恢复','blocker':None,'next_step':'读取NEW_CHAT_START.md并按SM002真实启动','runtime_id':None,'thread_id':None,'actual_model':None,'actual_effort':None}
    dump(f'agent/{aid}/planned_report.json',payload)
    call(C,'report','--root',str(N),'--agent',aid,'--input',str(N/f'agent/{aid}/planned_report.json'))
with (N/'agent/model_policy.md').open('a') as f:
    f.write('\n## 当前用户执行政策\n\n工程使用GPT-6.1 Sol/xhigh连续实现、编译、仿真、修复；GPT-6 Astra/xhigh仅在实际综合结果后集中评判与改进。取消逐轮用户审核；不把模型登记当实际运行。未定义合同的实质变更不能由普通修复偷偷替代。角色策略由models.json解析；真实启动后单独记录actual_model/effort及配置证据。\n')
with (N/'agent/agent_manage.md').open('a') as f:
    f.write('\n## 实际执行状态\n\nA001–A003均planned，runtime/thread/actual_model为空。本次建立项目没有启动新代理，旧baseline代理也不自动绑定到本项目。任务/写入范围详见各A/mission.md。\n')
write('question/question_manage.md','''# 技术问题登记\n\n本次工程复制没有新增需要用户回答的问题，不重复确认已授权常规操作。新对话遇到实际技术问题时用Q记录关联M/SM/E和承接角色；回答必须指向当前版本证据，不能仅凭理论标记已解决。''')
write('results/overview.md',f'''
# Laya-HLS 当前概览

**复制搭建完成；完整加速器尚未验收。** 本项目按research-agent原生结构管理，原baseline完整保留。工程副本在[{B}](../{B}/)，新对话入口[NEW_CHAT_START](../NEW_CHAT_START.md)。

| 范围 | 当前结论 | 证据/限制 |
| --- | --- | --- |
| E001完整工程复制 | PASS_COPY_VERIFIED | {count['file']}个普通文件双侧SHA一致，{count['symlink']}个links映射副本，源未删改；[收据](../{RR}/copy_receipt.json) |
| 旧稳定身份完整CPU/CSim | PASS_SCOPED | build23c62cd4，四持久请求、141点/18,094,384 F32与故障恢复；非新working源整图硬件 |
| 模块RTL/局部连接/OOC | 多项范围PASS，失败与成本中止保留 | [当前阶段终态](../{B}/{R}/stage_results.md)；不直接相加外推整图 |
| 当前13BO生产接入、同runtime全图RTL | 未验收/未验证 | 接口§3.9已定义，E002新项目未运行 |
| 全局资源fit、P&R/Fmax、U55C/XRT/HBM/板端性能 | 未验证 | 尚无板卡，150MHz仅条件预算 |

目标是正确完整推理、可核实吞吐改善及部署资源预算，50ms不是唯一硬门槛。CPU token Embedding与固定权重一次校验；FPGA后续全部LN/动态量化/Q8/Attention/向量/Decision。模块数值、完整最终决策、数据集准确率分别判断。

M001/SM001完成，M002/SM002计划待新对话恢复。A001–A003仅登记未启动，实际模型/线程为空，无新硬件工具运行。用户已取消逐轮人工审核，当前无需用户新增决策。下一步是按SM002优先接实际生产闭包和稳定身份回归，不无限扩展非关键诊断。
''')
write('results/review_queue.md','''
# 阶段审核队列

本次M001/SM001复制一致性已由实际收据核查，用户要求的结构和交接已交付。没有新待用户批准事项；不伪造“用户approved”。用户已明确取消每轮人工审核，普通实现/脚本错误按授权连续修复。

E002继承原阶段的范围PASS、历史FAIL和成本中止，详见实验三摘要与原始终态。复制接入不构成完整硬件最终验收。新对话在实际综合结果后进行集中技术评判，重要合同影响或无法解决的实质阻塞才按依赖报告；不为每个小步骤新增正式审核文档。
''')
write('results/reviews/SM001.md',f'# SM001：复制核对结论\n\n技术核查：通过，[实际收据](../../{RR}/copy_receipt.json)errors为空。仅支持完整副本/links一致性；不是硬件验收。原工程保留。没有伪造用户审批或新代理运行。')
write('results/reviews/SM002.md',f'# SM002：当前验收边界\n\n新项目未运行SM002，整体未验收。继承模块证据见[阶段表](../../{B}/{R}/stage_results.md)。未来基于真实综合结果集中评判；不重复逐步审批。当前无人为审批阻塞。')
write('results/missions/M001_summary.md',f'# M001总结\n\n完整工程复制与Research原生结构接入完成，SM001/E001 supported。证据[copy_receipt](../../{RR}/copy_receipt.json)。原工程保留，普通文件双SHA一致，links映射副本。新对话入口已写；没有新增硬件验证。')
write('results/missions/M002_summary.md',f'# M002总结\n\nexecution_state: planned\nverdict: unassessed\n\n完整加速器未交付，当前为继承基线及明确下一任务。已验证、失败、未验证边界见[E002结果](../../project/E002_Laya_HLS/experiment_results/summary.md)，SM002待新对话恢复；不得因所有旧owner终态或复制成功宣布全局完成。')
write('results/hardware_progress.md',f'# 硬件进度\n\n当前工程完整复制，未在新项目运行工具。[原当前阶段](../{B}/{R}/stage_results.md)记录各冻结身份真实终态。\n\nCPU/CSim：旧稳定build完整请求通过；RTL：局部服务、真实矩阵/桥有范围通过；13BO整图新生产caller：未验收；模块综合：部分有实际账，G新父成本中止；整体资源/物理/上板：未验证。\n\n下一工作按SM002先接完整生产闭包与当前身份回归，功能/吞吐优先。')
write('results/hardware_metrics.md',f'''
# 硬件指标：层级和身份

以下是继承的限定结果，不是新目录重跑或整网性能。当前最终模块数据以[阶段表](../{B}/{R}/stage_results.md)和对应receipt为准。

| 指标 | 继承事实 | 限制 |
| --- | --- | --- |
| 旧32bank cache装配 | 384URAM / 224 BRAM tiles | 该装配身份，不能直接加到新全图或证明fit |
| 原G51整row OOC | 176828LUT / 299253FF / 48DSP / RAM0 | row/control 256419FF；新三bank已功能通过，父OOC成本中止，不能沿用旧账称改善 |
| G51不变算术子树 | 95754LUT / 42834FF / 48DSP，51 FP位置 | 精确导出算术子树，非新父完整映射；tanh已包含，不能重复计费 |
| quant16真实Wi/Down行 | 141 / 341cycles | 流式服务限定输入；不当完整请求耗时 |
| syncPS | F_PS_min37，接受gap1..3 | 不能取最小gap1声称持续II1；真实四row完整Down独立中间值通过 |
| 驻留Down完整局部链 | 48862cycles；10496stripe/335872lane-group PS、4096 F32输出/512真实AW/W/B通过 | A来自预量化fixture；strict W仍83968scale checks；bias_kind0旁路，无G/quant seamless或13BO证明；非完整请求 |
| 新Attention v10真实完整head128 | 正常QK250888＋SM287173＋AV66256＝604317cycles，旧基线6816248 | 约11.279倍模块计算改善，enc0/head0/B1/S128限定；协议另在tile16_03同身份验证，非完整加速器性能 |
| 频率/带宽/请求吞吐 | 未测 | 150MHz是条件；无U55C、无P&R/Fmax、无完整物理13BO请求计时 |

性能改进按同输入/缓存/反压/计时口径，分别记录冷暖首延迟、完成间隔、填充排空、供数/反馈/输出stall。综合WNS与条件cycles÷150MHz不可写为板端Fmax或实测延迟。
''')
write('results/method_verdicts.md',f'# 方法判断\n\nE001支持完整副本一致性。E002整体unassessed，旧CPU/CSim和局部RTL/OOC分别按原身份范围支持已记录行为；历史数值/覆盖FAIL和成本中止保留。\n\nQ8广播/双缓存、同步PS、量化流水、共享Attention与非线性路线仍要由真实生产连接和当前身份资源/性能证据决定；局部性能改善不证明完整高性能。当前缺少同模型GPU与带标签数据集对照，不能判加速比或数据集准确率。')
for e,source,results,status,execution,verdict,app,evidence in [
    ('E001',f'# E001：复制依据\n\nM001/SM001要求当前阶段收口后完整复制原baseline，保留原工程。协议为rsync -aH＋links重映射＋双侧逐文件SHA/类型/权限/entry/inode校验。源{src}，目标{D}。输入与命令身份留R001。',f'# E001：结果\n\nPASS_COPY_VERIFIED；{count["file"]}普通文件、{count["dir"]}目录、{count["symlink"]}links，逻辑普通文件{gb:.3f}GiB。SHA全一致、errors为空，原普通文件未改、原工程未删、副本普通文件不共源inode；links重映射副本。\n\n证据[copy_receipt](runs/R001/copy_receipt.json)、[逐文件SHA](runs/R001/file_sha256.jsonl)、[链接映射](runs/R001/symlink_mapping.json)。不包含硬件验证。','# E001：状态\n\n完整复制与结构接入已完成，原工程保留，新对话交接就绪。没有新硬件运行或新agent启动。','completed','supported','本次完整baseline复制一致性与内部链接映射，非硬件正确性',[RR+'/copy_receipt.json']),
    ('E002',f'# E002：继承硬件基线\n\nM002/SM002的实际代码为experiment/中的完整baseline副本。目标U55C，无板卡；CPU token Embedding/静态校验，FPGA后续LN/动态quant/Q8/Attention/GEGLU/Decision。真实模型、完整层数/shape和独立gold不变。\n\n当前依据[联合设计](../experiment/{R}/source/design.md)、[阶段结果](../experiment/{R}/stage_results.md)，下一入口是§3.9显式生产流＋原13BO RTL外壳；它尚不是已通过实现。',f'# E002：当前结果\n\n旧冻结build23c62cd4完整CPU和Vitis CSim：四持久请求、141独立点/18,094,384 F32与gamma故障恢复PASS。当前working源码已改变，此结果不能代签新整图。\n\n真实四rowQKV/Wi/Down、同步PS、G六row/物理GATE→quant/fullA等有范围RTL通过；驻留Down局部完整输出/最后B已通过，但A来自预量化fixture、仅bias_kind0，未覆盖非零bias/活动reset/晚错/生产13BO；Attention最后终态统一查[阶段收口](../experiment/{R}/stage_results.md)。原G51RAM0/大量FF的实际账保留，新三bank功能通过但父OOC成本中止，完整新RAM映射/装配未闭合。\n\n历史数值FAIL/覆盖FAIL、ordinary TB failures及COST_STOP均保留。物理13BO生产入口、同runtime完整图RTL、资源fit/P&R/U55C/XRT/HBM/板端性能/数据集准确率未验收。没有在副本执行新测试。','# E002：状态\n\n新项目实验尚未执行；继承阶段终态已封存，待新对话按SM002恢复。完整加速器未完成。当前没有运行代理/硬件工具，不把角色登记当开始执行。优先实际生产连接与稳定新身份功能回归，再按真实瓶颈优化吞吐。','planned','unassessed','当前副本继承各原冻结身份的限定证据；新项目完整硬件目标尚未验证',[B+'/'+R+'/stage_results.md',B+'/'+R+'/source/results.md'])]:
    payload={'source':source,'results':results,'status':status,'execution_state':execution,'verdict':verdict,'applicability':app,'evidence':evidence}
    rel=('project/E001_baseline_import' if e=='E001' else 'project/E002_Laya_HLS')+'/experiment_results/import_publication.json'
    dump(rel,payload);call(H,'publish','--root',str(N),'--experiment',e,'--input',str(N/rel))
event={'event_id':'EV_SM001_R001_baseline_import_complete','small_mission':'SM001','trigger':'milestone','summary':'原baseline当前阶段收口后完整复制、双侧SHA核对和research-agent原生结构接入完成；原工程保留。','impact':'只支持工程副本一致性；E002完整加速器尚未验收，新代理未启动。','evidence':[RR+'/copy_receipt.json'],'affected':['SM001'],'action':'新对话从NEW_CHAT_START.md恢复M002/SM002；本事件为信息登记，无用户审批门。','requires_decision':False}
dump('results/import_completion_event.json',event)
call(H,'event','--root',str(N),'--input',str(N/'results/import_completion_event.json'))
research_snapshot=call(H,'snapshot','--root',str(N))
console_snapshot=call(C,'snapshot','--root',str(N))
dump('results/research_snapshot.json',research_snapshot)
dump('results/console_snapshot.json',console_snapshot)
print(json.dumps({'status':'NATIVE_RESEARCH_RECORDS_FILLED','project_root':str(N),'actual_code_root':str(D),'agents_launched':False,'hardware_tools_run':False,'snapshot_saved':True},ensure_ascii=False))
