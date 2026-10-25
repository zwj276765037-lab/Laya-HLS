# E015：实验方案

## 真实来源、假设与基线

当前授权为SM011 D-M007-SM011-TANH-G8-08。原tanh_libm_canonical_generate.py和full_reference.py只读；每个独立F32舍入、分支与常量保持。先实现内部独立add3/mul4/direct-div12，复用E008原独立native SSE有限/边界/次正规向量，再原glibc TANH单lane、最后8lane及纯G engine。静态原DAG152拍只是目标。

## 平台与输入身份

Vivado2025.2/XSim，工具根/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin。小leaf OOC器件xcu55c-fsvh2892-2L-e、3.333333ns、uncertainty0.1ns、非clock输入/输出delay0.5ns。每AT保存命令、主机、全部当前M007源码归档和SHA；输入另由运行manifest绑定。期望gpt-6.1-sol/xhigh，实际配置未核实。

## 步骤、控制变量和独立期望

新leaf在真实寄存器边界重分段：add保留对阶sticky/精确加减/归一化/唯一RNE；mul保留完整48bit产品至目标精度对齐后唯一RNE；div按多位恢复除法流水保留精确余数，禁止倒数乘。原共享叶子只读且不替换。连续II1、CE保持、在途reset及paired-valid另验。原向量身份和数量由运行manifest核实，非有限payload的NaN细节不冒充有限全域证明。

## 指标、采集与结论规则

每AT receipt、stdout/stderr、frozen source和report为原始证据。叶子数值逐位通过只证明已列向量；OOC综合+opt单列setup/hold/面积/blackbox/约束覆盖，无P&R不声称物理300MHz。单lane必须实测≤160拍/II1后才展开8lane；成本或时序未达保持COST_STOP/FAIL并报告主控。纯G外部96bit SFU、phase1唯一65536B G银行，原s-major布局和全域input/u/v/w/t/z/y/gate rank按合同，不私改共享接口。

## 资源、异常与阶段报告

E015独立reference900/static1800/RTL3000/OOC1800s；E014余额不转。所有实际compute/EDA由m007_tanh_guard.py持公共m007_heavy.lock覆盖全部owned后代；直接只读复用已核E014 m007_ln_process_guard.py的subreaper/start_ticks/异常收尾机制，记录其身份。CPU0–3/nice19/idle I/O/MemAvailable>192GiB；RSS16/24/8/24GiB。未知pilot≤120s，初期所有AT≤120s；每次先检查剩余预算。仅写vector_and_ffn新m007文件、source增量和E015证据，A007/A010文件及旧canonical/gold只读。阶段/阻塞即时消息A001并更新A008实际console状态。

## 主控工作中澄清：G错误域与前缀数据

2026-10-21 A001实际消息认可：a/c均0<常量<1，正常合法finite x的u/t不会溢出；有效前置域内y有限。真实输入逆序首错用早gate错误对晚x/v/z错误；FP返回故障另标协议/peer扰动，不伪造正常numeric可达性。

G首输出属于本请求内可取消前缀数据，不是whole-task success。完整原rank/coverage和成功done前禁止Down算术启动。父可实际quant/A暂存，但G生产者失败必须排清真实已接受quant/DIV/A写债并取消，不假补未接受输入、不强制发布。A010的提前producer-cancel属于后继未验接口。本段只按该边界证明G前缀/全局成功，不代签Down父图。

## 120秒真实语义停滞与长例版本边界

AT033旧成本门通过后，主控核出guard v2长例路径缺独立120秒语义停滞钟；AT034从未启动。旧AT032/033/035及v1/v2保持原样，v2不用于长例。新v3保留总墙钟、预算、锁等待不计child、owned后代回收与启动/取锁自身SHA核验。

新版单lane TB在真实out_valid&&out_ready且独立结果/status/96bit tag检查全部通过后，按每4096次实际消费及各测试阶段末消费写入并flush JSONL。checked和物理cycle必须严格增加，node_checks不下降；无效/重复/部分事件、日志mtime或周期心跳均不能续计时。guard从child真实启动开始独立计算120秒无真实消费事件，触发SEMANTIC_STALL_STOP并保留原receipt和清理证据。raw事件与guard接收时刻分别归档。新TB/driver必须重新编译、中样、实际成本门，绑定相同编译manifest、driver、guard和独立输入；不能追改旧中样为新版证据。guard解析/计时单元测试使用注入记录与时间，只证明主机保护逻辑，不冒称DUT运行或真实等待120秒。

## 用户收尾后暂停（2026-10-21，A001实际消息转达）

用户明确“按此收尾后暂停”，范围仅让已启动/排队的当前八lane全样到原帽内终态并归档，保存接口准备；禁止再启动G实现/实验、父级实验、新OOC或其它后继。AT055八lane全336262主输入/14123004主节点已PASS，153拍/II1；原AT051 FAIL保留，当前所有owned guard均已终止、无未终态receipt。A001实际increment44集中核对并接纳八lane限定功能范围，实验整体仍未完成。

G pair RTL/TB只保留暂停消息前写入的未编译草稿，无G attempt或实际G进程；恢复必须先得到用户明确恢复通知。入口为R001/tanh8_pause_handoff.md、release_evidence_v1.json与pause_budget_and_process_audit.json。预算余额封存而不转移；不将暂停写成完整TANH/G、联合SFU、4KiB/总资源或物理300MHz通过。

## 用户恢复剩余G工作（2026-10-22，A001实际接续）

用户明确“继续任务”，恢复M007及本E015/R001剩余G。原53笔receipt余额与暂停账逐Decimal复算一致，见resume_20261022_audit.json；仍沿原900/1800/3000/1800秒总帽，不重置、不转移。AT055八lane完整功能冻结复用，不重跑；A007/A010共享文件只读，原heavy锁/CPU/RSS/120秒真实停滞及先未知pilot后同版成本门保持。

先对既有pair manager草稿与唯一原storage做独立地址pattern、32宽实际写ACK覆盖、16bank同步读、held/slot0→1→0/third-slot阻塞、release与实际债清后discard及新gen重装验证。此组件TB的client消费模型只模拟银行客户端，不代签真实GEGLU输出退休或G性能。其后纯G engine必须调用真实现有TANH8 SFU，完整原335872输出/首错顺序和实际G消费债另验；不复制整G/FP/存储，也不改原gold或用TB逐元素调度代替生产循环。


## 恢复G的原始输入与生产验证版本（2026-10-22）

AT058仅逐字节序列化AT007冻结原products，12字段MSB-first为x/gate/u/v/w/t/z/h/r/s/y/geglu。索引i,l映回原scalar=((i%512)//4)*2624+(i//512)*32+(i%4)*8+l，所有128行真实参与。AT057组件pattern不替代G算术期望；AT060/062失败及原log/收据完整保留，当前packed输出直接从原fixture低32bit逐lane取值，不删除FP9/H输出独立比较。

生产验证由`m007_g_engine_run.py`记录所有选中shared/RTL/TB/driver与编译snapshot SHA，RTL运行必须与build逐项一致；PS/context禁用的一份实际storage、一份AT055同源TANH8与恰56mul/16add外池。仅一次完整任务命令；producer按s/half/row真实32宽写入，生产FSM自主读s/row/chunk8。3s短例只签prefix+已接工作真实排债，不能生成全任务success。正常完整82s及error/recovery范围分别报告。

冻结G守卫`m007_g_guard_frozen_v4.py` SHA9e26368b7e8f241e0030d0856ea6c55f4223313941737de49f947dfdc7610020，只增加G专用成本计划校验，原v3自身身份/同锁/原累计预算/CPU/RSS/MemAvailable/subreaper/120秒真实消费停滞逻辑保持。未知pilot≤120秒；长RTL前必须实际同v4、同build/driver/source、至少32768标量正常中样PASS，fixture精确335872，成本式=pilot真实child_wall×target/pilot×1.10+10，且不超1200秒及原余额。不能复用TANH专用cost schema冒充G测量。新守卫尚无中样/长例PASS时不声称门已通过。

首块自然eligible=max(cmd_accept,末真实写ACK)，后块=max(本slot末真实写ACK,前块512th真实读接受+1)。每块first_ready/eligible/first_read/last_consume/release/queued_wait分别归档，正常首读≤eligible+1、每块≤768、首结果≤256、完整真实done≤42240；实际外部held另外记账。slot release必须本slot512实际G消费与bank/math/SFU/FP债零，不能要求global SFU idle造成跨s停顿。held最后结果17拍必须保持整个record、阻同slot的第三块填充；另一slot真实SFU在途与释放重叠单列。


## G错误/协议阶段归档及控制容量出口（2026-10-22）

AT073新错误TB复用未变生产RTL和资源壳；AT070每案仅两个原scalar稀疏修改。节点域掩码与原rank评估mask由原F32/libm独立生成，四案主检查分别3358710/3358713/3358715/3358720，原不可评估支配排除10/7/5/0完整计数。所有rank covered/evaluated按真实处理验证；每案335872主输入、2数值错误记录后held done6/错gen discard17/匹配discard、旧lease真实释放、新gen3块12288原结果无reset通过。新gen仍保留等待s3命令，不能称全命令success。

冻结v5 SHA936b7b2a791f3cd61d9aefa943b6fcd0677b85a24149e122fd8db1a4766a40ad只扩展错误fixture+实际恢复计数成本绑定；原生命周期不变。同v5中样AT074后AT075完整墙钟132.03900283394614秒，AT076–078按同版全例实测155.24290311734077秒界/180秒帽运行。旧v3/v4原件不改。AT079/080另用独立验证壳公开status interposer，只改变一个真实matching FP return的status8，valid/tag/data和真实债不变；部分协议done8/部分coverage discard/noreset新gen单列，不计全数值rank证据。没有层次force写coverage/债，没有伪造请求或输出gold。

AT081归档核查所有恢复attempt/source archive、当前选中源/历史差异、实际build snapshot、原fixture、raw semantic事件、真实终标和owned清理；最终79笔原预算见g_stage_final_budget_20261022.json。新增G control5867.25B>4KiB是当前不合规出口，数值payload/固定对齐及既有SFU/叶pipeline分别记账，不能伪装为payload扣除或借未来共享节省。2026-10-22主控明确本阶段完成三摘要/累计账/身份后保持生产RTL，后继紧凑状态寿命/tag/父级真实物理共享集中另定；当前不自行压缩或改共享口。阶段完成不代签E015资源/物理及全M007目标。

## G-COMPACT-14执行后协议补记（2026-10-22）

本节是所有受影响数值仿真结束后的文档补充，不追改各AT冻结的protocol SHA。AT082–123在启动时依据SM011的D-M007-SM011-G-COMPACT-14实际接续合同执行，并保存当时通用G协议、源码、TB、driver及guard快照。此前暂停/恢复/容量不合规出口保持历史原貌；本节不将旧PASS升级为当前源码证据，也不建立新预算。

本段仅改math/pool内394条重复96位tag为完整seq16；公开tag仍为{generation32,epoch32,zero16,seq16}，seq=s*512+row*4+chunk，范围0..41983。math及pool上下文各由清除后首笔实际接受绑定，高64身份、保留16位及完整seq16在公开边界检查；低8位仅作ring地址。上下文跨暂空、held结果、错误done、显式discard和真实债屏障保持，不能在pending暂空时重新绑定。pool同拍接受须同域，各通道请求次序独立计数。新增上下文/valid/order共291bit全部计入控制；不删除资格/错误mask、状态bitmap、coverage/evaluated、首错或未读tail，不改变数值、共享credit源、原engine/pairs、storage及冻结TANH8。

验证复用AT058独立335872×12字段和AT070原primitive/libm稀疏错误参考。输入域测试覆盖混域首拍、旧generation、错epoch、非零reserved、完整seq别名、held17/empty17及clear后重复seq0。公开返回反例在真实接受后额外注入坏记录，并保存真实正确返回随后到达；实际SFU/FP债不得因坏记录减少，全部原FP9/H/output比较保持。完整正常及rank0/2/5/7错误均按同版真实中样/成本门运行，并验证done6 held17、错gen discard拒绝17、匹配discard、实际lease释放和无reset新gen12288原结果；新gen只是三块prefix，仍等待未供给s3，不签全新命令完成。

单G声明控制目标≤2048B，联合4KiB/父物理复用另由主控定义；本段无OOC/P&R/联合SFU或FFN性能声明。全部沿用原reference900/static1800/RTL3000/OOC1800秒累计帽、唯一heavy锁及原CPU/RSS/120秒真实消费停滞机制。未知pilot≤120秒，普通完整≤240秒、成本计划精确绑定argv/build/driver/fixture/guard并预留≥120秒短例/归档空间。AT092测试探针停滞、AT096/100真实重复seq0缺陷及AT119零子进程argv成本门拒绝原样保留；修复解释和最终版本见g_compact14_source_delta_v2.json及最终handoff，未改gold或削减断言。

## G-RING-TAG-15启动协议补充（2026-10-22）

主控正式接续SM011末尾D-M007-SM011-G-RING-TAG-15，继续原E015/R001余额，不重置/转移、不OOC。仅math中256条tag_mem的16位完整seq改为8位高位，低8由实际slot地址组合恢复；所有函数显式传入依赖，expected_tag及其他管线仍完整16位。所有mask/bitmap/真实债/covered/evaluated/首错/算术payload和engine/pairs/pool/共享生产源码保持。预期减2048bit/256B，实际字段账完成前不签1707.625B；父物理共享/联合4KiB仍OPEN。

先真实math+FP池+TANH8满256槽并held17、同沿consume+accept复用同地址，独立比较旧记录及新序号跨255/256、511/512，公开全96位tag及全部原FP9/H/output；再重跑上段所有tag反例、clear同seq0、匹配status故障恢复、正常三块及held。新同版32768正常/错误成本pilot后，完整335872正常、full rank0与full inverse-row各一例真实discard/无reset新gen。rank2/5仅按原AT121/122身份复用未改算术/首错逻辑，不称当前SHA重跑。原fixture/gold/断言不改。每次unknown≤120s、普通完整≤240s、真实消费停滞120s、同版精确argv门与原资源锁/CPU/RSS保持，总余额始终预留至少120s短例/归档；成本不足时保留实际覆盖缺口。
