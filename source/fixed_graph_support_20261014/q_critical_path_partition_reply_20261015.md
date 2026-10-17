# Q长路径：单一有界切分建议（A003→A001）

回复 `m004-lnq-critical-path-partition-question-20261015`。已更新 `source/fixed_graph_architecture_20261014.md` 的“Q长组合路径”小节；分段/源码SHA/计数见 `source/fixed_graph_support_20261014/q_critical_path_partition_20261015.json`。当前Q/divider/tiny/位型包4文件与AT116冻结SHA一致，未复跑工程回归或EDA。

最差231级中，发起clock→末个have_recip选择网络为194级/49.778ns；其后到首个隐藏IP网络9级/2.410ns，隐藏区到捕获端28级/3.473ns，合55.661ns。Q第178–193行逐次更新choice并动态回读ordinal形成32槽argmin串接；综合命名虽在tiny/tag_pipe下，不能归为tiny算术。实际tiny已有六级、每级五步restoring；包内组合tiny_div127_bits未被本服务调用。subnormal最高位/移位和返回指数恢复仍须保持，不能据隐藏端点把全部延迟归给除法IP。

唯一建议：选定phase资格快照后，每拍4槽平衡比较、8拍扫描；再分别寄存选中slot的原始payload/tag（并置RESERVED）、route/最高位k、最终numerator/denominator/tiny_amax。最后valid保持到真实req_ready接受，才置WAIT、更新issue与偏好。S0快照，S1–8扫描，S9预约/raw，S10分类/k，S11操作数寄存，S12最早接受，S13最早下一快照；无服务反压且有积压时接受间隔13拍。单组最多两请求占26控制拍，对当前至少34拍/group的pack供数有容量余量，但首尾/依赖等待另计，不能签整链提速。

一个待发描述符；预约与真实FP请求分开计数，scan/reserved/payload债务加入done/physical_debt_zero。原32项ring、tiny dummy FP＋helper双返回、顺序退休、数值首错键、epoch检查与12拍FP reset隔离不变。数值错不提前取消其他已收组；协议错照常排空已预约和已发工作。详细状态/握手在报告。

这套切分不预认150MHz。只加除法前寄存仍会留下194级选槽链；新3级比较/选择、subnormal处理、helper首级与返回路径仍须同版时序测量。AMAX/REPLAY选择另有同型线性argmin，可能成为新的最差路径，不能隐含算作本方案已修。没有新增候选扫参、lane或近似数值；是否纳入实现及预算由你集中确定。

本轮仅读取已有证据与轻量计数，脚本内部0.005715s/自身峰16516KiB，历史未采样累计仍UNKNOWN。AT121局部周期/AT116时序FAIL已同步记录，旧v4冻结；未启动EDA、模型、新gold或代理，未改E002。

已同时按 `m004-lnq-reset-coverage-research-note-20261015` 收窄AT121转述：旧q_started/half_sent可能令reset等待循环不执行，共同在途reset暂不接纳；这不是DUT复位故障结论。新建议明确包括scan/预约/待发状态的共同reset与真实债务，不依赖旧reset=1标记。
