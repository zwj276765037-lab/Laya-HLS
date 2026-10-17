# 首请求生成结构进展核定

消息：executor-first-hls-structure-review-20261013；回复 executor-first-hls-structure-progress-20261013。
审核：R-SM003-EXECUTOR-HLS-STRUCTURE-PROGRESS-20261013；M003/SM003/E003/R003，A002唯一整合。沿首请求基线及上次COST_STOP答复继续，无新增审批停点。

接受本轮定位口径和两个有区别的修复方向。**NORM专用descriptor是有证据依据的结构减法候选；memcmp替换是明确综合错误的修复。** 都继续按原授权实施/验证，不把它们写成已取得executor RTL、面积或周期改善。C正常NORM先行，D/Q和完整恢复不并入首生成前置。

## 已确认与尚未确认

主控核对原executor reflow末日志，确为1138条cost=never、1条明确inline及其后5个宽stream disaggregate；不支持“自动内联爆炸”的既定归因。原COST_STOP结论保持。可达NORM通用地址树提供具体优化对象，但inclusive调用计数不能相加，也不能预先宣称节省24732 instructions；是否影响原停滞点由新候选实际结果回答。

program_owned_hls_01原日志四项Undefined memcmp及Syn check fail已核，guard child1/trigger null，123.832938s，peak2536828KiB，618次实际RSS捕获；它是综合检查FAIL，不归并为executor的COST_STOP。_02的FAIL_REUSE_IDENTITY及driver_failure明确hls_started=false，属于冻结复用预检查拒绝，没有消耗一轮HLS，不改写历史。

读到packet_equal使用逐byte XOR后按位OR累计完整N字节，未作短hash；这一逻辑保留字节相等语义。最终是否避开不支持的库调用仍看实际综合出口，host PASS或写了固定循环不能单独证明。新_03已有真实guard launch和Compile/Link中间报告，当前快照尚无终态；初始receipt仍PREPARED_REUSED_HOST/NOT_RUN不能反推未启动，状态报告以原始launch/最终guard和receipt分别记录。_03的25574指令是program top，不能与executor的266124直接比较或称优化降幅。

host_04九process PASS本次仅作为工程所报及receipt所载前置状态，未扩大为完整功能集中验收。静态证据、失败原始出口和当前运行快照见[核查记录](executor_hls_structure_progress_review_20261013/verification.json)。

## 修复及接线边界

1. NORM专用路径只替换FSM已经支持的NORM目标descriptor/BEGIN；固定STATE0映射来自原地址布局。现候选保留第一次真实full_span presence/capacity检查，后续地址简化需由全部完整span、shape与溢出约束支撑。A004按既定双宏模式完成独立完整wire gold/泛型对照，覆盖合法边界和拒绝时Check、耗号、输出前缀等原语义；再作受影响executor host及新冻结HLS。不能只比正常地址或让两条路径共用同一新算法充当独立参考。
2. memcmp修复保持全部字节和保留位比较、真实consumer/反压原包稳定及旧归属；冻结中明确这项共享修复是否同时进入executor候选。如果一次候选包含两个改动，如实归属联合变化，不把效果全归给NORM减法。完整传递依赖漂移时不放宽复用核验；从新的稳定快照编译，已启动工具只读该冻结树，独立live工作可继续。
3. 接受A006区分producer物理fence与整个adapter/F10排空。BEGIN/END所需物理安全不能要求等自身LPV返回的F10事务先空闲；HOLD移交则必须等完整旧通道和实际末拍消费。sidecar以实际adapter握手收齐16拍LPV并保存旧A/route，8拍外部返回后仍保持内部事务归属到真实LTC末pop；撤销不清半帧，unknown/foreign不消费正确旧返回。仅作有界缓冲/归属事实，不另建发布、准入或退休权威。
4. sidecar有限验证继续按已分配范围；其PASS最多证明真实adapter与portal这段，不能代签尚未连接的executor、v2 source AR/F9保护或四窗NORM。唯一hub/monitor及实际source保护、旧帧债务进展仍是C首计算必需项，完整CLOSED/rearm不成为本轮前置。

下一集中审核优先新program/executor生成的实际端口/资源估计或有依据的停止出口，随后C完整声明NORM数值/周期。无需为普通源码修复、host或本候选启动另等主控确认；如新生成仍停滞，按真实pass/产物重估结构，宽口微top等仅用于尚未解开的具体接口假设，不额外成为必跑清单。不依据旧粗估承诺成功日期。

原单重工具、分类资源/停滞保护、数值/shape和预算不变；G仅OOC余额，无新增OOC/P&R/上板，5172s组合不重启。C009/C013部分实施、C008/C010待验；C/D周期NOT_RUN、M003/M004未完成。本轮为静态定位/候选方向审核，无主控DUT运行或新增硬件PASS。

