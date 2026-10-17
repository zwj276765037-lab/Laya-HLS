# QAR0：共享量化入口的有限仲裁修复与原schema对齐

D-M004-SHARED-QUANT-ADMISSION-01；2026-10-14；M004/SM005/E005/R001。A002唯一实现、整合及重工具owner，A001集中审核。承接[QWIGQD0审核](../results/measurement_first_QWIGQD0_review_20261014.md)。这属于新接入共享包装的必要修复，直接按既有连续实现授权执行；不恢复通用executor或生产恢复关键路径。

## 问题和本轮唯一目标

AT034正常四行数值/存储链通过，但EXT_QUANT=1、IDLE、无已持有外部任务时，ext_quant_ready含!cfg_valid，cfg_ready又含!ext_quant_valid。两个源同时valid且保持到接受，会同时得到ready=0；没有首次接受可以改变状态。这是冻结RTL的静态活性反例，尚非本项目动态复现的死锁，不撤销AT034顺序样本PASS。

本轮只修这个共享入口及其相邻命令/响应归属，并将诊断Context的opcode对齐原任务schema。量化/矩阵/G数值图、各缓存容量、原独立gold和真实存储路径不变。LN_FFN producer接入在本修复之后另行确定，已取得的LN来源只读报告保留，不在本轮另开捕获或HLS。

## 仲裁决定

在bridge空闲、无未消费响应、无已选择任务且目标端可接受时，**G入口固定优先于外部QUANT**。两路valid同时保持时，唯一接受G；外部保持valid/payload等待。只有外部valid时沿原外部路由接受。没有外部请求时保持原G路径行为；EXT_QUANT=0保持旧默认行为。

cfg_ready、ext_quant_ready、量化cfg_valid/数据选择和真实接受事件必须来自同一个选择决定，避免一边被接受而另一边的payload送进quant_task。一个周期最多一次命令接受。未选择者不能提前得到reject/done或改变状态。

已经接受的外部任务不被新G valid抢占；选择和响应归属保持到原拒绝或实际响应消费及物理债务归零。已接受G同理：外部请求只能等待，不能改变GATE量化的Context/K/地址/路由。固定优先级只保证有限竞争请求的本地选择，不宣称无限连续G流量下外部请求无饥饿。

不新增第二套quant_task/dualA/dualW/resident、仲裁队列或通用owner/退休表；优先保持原算术和存储模块逐SHA复用。新增状态如确有必要，明确每位用途、复位/保持/释放条件与唯一writer，不能把调试状态算作生产功能。

## 身份口径修正

以本项目include/laya_tasks.h的实际Op及Context打包schema为真源：外部LN_FFN producer=0x12，QUANT=0x20；Wi=0x32，GEGLU=0x60，GATE后的QUANT同为0x20，Down=0x33。保留B1/S128、encoder0、batch0/row0四行及原数值、ref/slot/epoch的完整语义。检查所有相关P/Q/L引用和比较项一致映射，不能只改一个显示标签。

AT034外部P/Q曾用0x60/0x61，GATE Q亦需检查；它们在局部路径作为不透明完整键相互匹配，并不证明生产opcode正确。旧样本/manifest不回写。新版本调用字段与schema一致，不为此新增完整生产权限解码器，也不声称已验证所有不合法opcode组合。已知拒绝测试使用原实际校验的owner_admitted/source_published等条件，不能把当前未检查的opcode错误当成必拒条件。

## 定向验证和正常链载体

工程在启动前给出少量明确用例及实际ready/accept/reject/done/cfg payload/AXI/债务观察点，直接实施，不新增源码审批。至少覆盖：

1. IDLE双valid均保持，目标通路就绪时唯一G接受，另一请求不丢失且保持payload；G完成或按原规则拒绝并释放后，等待外部请求能够接受。可以用已知owner拒绝G探针验证这个边界，零算术/AXI/缓存提交必须成立。
2. 真实外部LN_FFN量化在运行和完成响应被反压期间，G valid保持仍不能抢占/获得伪接受；实际外部响应消费和债务清零后，等待G可按规则接受或拒绝。
3. 真实G执行及GATE量化/响应期间，外部valid保持不得切换quant payload或获得响应；G收束后等待外部可以被处理。若采用安全拒绝探针，选择合法空槽/完整已知字段配owner拒绝，不能破坏仍待Down消费的A epoch2。
4. 拒绝后选择释放、响应不串到另一个入口、同一命令/响应不重复接受；外部valid正常撤下后不阻塞G。EXT_QUANT=0原默认单入口行为至少做受影响静态配置核验，已有未变叶子数值按SHA复用。

这些可以在原四行完整链的诊断TB中插入有限合法反压和已知零工作拒绝探针，使一次full同时验证共享边界及完整gold；保持所有真实工作量和数值，不用TB强置内部phase/active/债务。若需独立短RTL，只做有区分力的最小入口用例，不把完整Wi/G/Down为每个用例各重跑。至少有一份真实RTL能显出旧双valid互锁被消除及新唯一接受，不以布尔脚本或源码检查替代。

修复候选的实际full必须保留原源4096F32→4096 INT8/128scale、Wi20992F32/671744 PS、1312实际Wi R、GATE10496F32/656 AW-W-B及656R、第二量化328组、Down335872 PS/4096F32/256 AW-W-B、末B/lease/7拍保持/实际完成消费、393216B只读输入/输出/哨兵终检。只初始reset，slot0 epoch1→2原复用语义不变；独立短协议case的reset不代签生产活动reset恢复。

补新增源AR事务数及首末AR/R边沿、区分两轮Q的per-task和TB累计计数，真实进度与诊断快照仍按原guard规则分离。这些计量随受影响验证一起取得，不单为修复旧标签再重跑旧版本。协议探针会改绝对周期和响应相位，本轮不是同口径性能比较，不据cycle差宣称加速。

## 有界执行与交付

只做一个有限包装修复候选，最多一次有具体原因的修正；同点无新证据停止即交付，不扩一般并发/错误矩阵。static→≤120s实际前缀pilot→有保守成本依据的一个完整四行回放。若本轮允许的有因修正影响RTL，可做必要受影响重验；不能超过原3600s/内存/周期帽或用心跳规避120s停滞。AT034 full1778.416778s仅成本参考，新增协议工作必须计入新准入估计。

交付原反例、最终选择/路由方程、定向实际事件与唯一接受/保持/归属/释放证据、schema表、新manifest/原日志/收据/完整gold和逻辑状态账。若定向用例只能证明部分边界就如实限定，不签通用公平性、取消恢复或生产权限。新结果NOT_RUN；AT034正常结果独立保留。

原职责和资源不变：A002单owner，E002/experiment唯一实现、E005/R001新证据；保留并适配其他人的修改，不新增agent、不写旧baseline。全项目单重工具，CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static24GiB/1800s、RTL8GiB/3600s/40Mcycles、pilot≤120s、真实语义停滞120s。无新HLS/OOC/P&R/上板/预算；G2338.224019s仅OOC余额，5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排；完整M003/M004仍未完成。
