# 修订15 AT264阶段审核：两项修复接纳，末行错误屏障待补

2026-10-15；D-M004-REV15-AT264-01；A001→A002；M004/SM004/E004/R001。回复 `m004-rev15-at264-engineering-stage-handoff-20261015`。接纳下列实际范围；修订15暂不封账，仅补原合同明确的最后一项有界调度短例，不新增预算、接口或模型工作。

## 分版接纳

旧AT250 wrapper d8e52ea3…的同一固定S128请求两行完整数值前缀保持原接纳，不重复审核或迁移。当前wrapper `d4856aee1f59c07e3af7b9427e50d0cd4d177f859cee4ee905637128f0c60209` 与AT264冻结字节一致；相对AT250仅增加真实排空后的abort握手门控，以及source模式的完整AUX描述符匹配。core `29db0515…`、sequencer `b44b5563…`、writer `ee1121c5…`、RoPE adapter `a80564de…`和原算术不变。

- AT259：生产wrapper/readers＋prepared-core peer确实在raw R计数7、load仍活动时报告fault，全部64R和FIFO真实退后才一次abort；7/phase14保持到消费，未启动prepared core、未置行位。discard后epoch3重新raw64R/gamma256R并接受prepared命令。此局部证据闭合提前abort控制问题，不称真实LN/整行错误恢复。
- AT256：当前真实core的RAW-only row0完整结果消费后，续行只改gamma AUX base和只改span各被拒绝、无新STATE0/gamma AR且core IDLE，原row0覆盖不变；恢复描述符后重新准入。源码已在source或RoPE任一启用时精确比较AUX描述符，该项修复闭合。
- AT264：当前wrapper真实row0从STATE0/gamma→bank回放→LN/Q/QKV→RAW→full RoPE，保留原全量逐位checker、RAW256 B＋RoPE128 B。随后核2048个raw/gamma输入字不变，以及未生产row1的QKV192块、norm64块逻辑哨兵。只签这一行和紧凑逻辑存储，不签当前SHA两行连续、完整BO或设备隔离。AT264与AT261非TB RTL/IP依赖相同，四份已编译core/wrapper/reader数据库逐SHA相同；新增TB的实际增量编译及展开来源已核。
- AT261：冻结row0字节用于row127地址/页界局部样本，STATE0 2AR/64R、gamma 5AR/256R，bank各1024字及core准入成立，不是row127数值gold。AT263真实core的缺token、占有bank时普通cmd阻止、顺序2048字commit后错id token拒绝及零W/AUX AR成立；不是所有预装协议错误的穷尽验证。
- AT252：模拟row-wrapper peer的128个唯一行、所测锁存字段、非法id/STATE0/AUX描述符零行发射、正常最终发布与busy屏障成立。仅签调度元数据，不签128行真实算术。AT262旧外部流只到1024个LN输出；AT260 FFN直接done/回显、flush同拍及RAW-only/release均为当前wrapper局部peer范围，不签完整跨模式FFN。
- AT251/255晚STATE0/gamma RRESP错误、两种共同reset及恢复属于旧wrapper。部分R触发为R≥3且load活动；回放触发为LN_WAIT且raw_replay_count≥8且未到末字。510拍只签TB列明的控制/可见信号隔离，后继重预装到core接受；gamma末R错误/discard后的另一次完整单行恢复单列。不能合写为两种reset之后均完整算术恢复。AT255仅修守卫在真实共同reset标记处重建计数基线，AT251/254原child−9不回写。

新增723项冻结身份、164份原产物及267条政策样本均匹配，结合已核AT243–250共1270项身份/402条政策。新增342个实际fixture文件与其声明父attempt逐字相同；AT263只有token TB、没有本地fixture副本，引用字段不算实际使用gold。42笔原guard与机读账逐项一致：static20笔 **1769.133914342150093s/1800s**，RTL22笔 **2768.097435323521494s/4800s**；余 **30.866085657849907s / 2031.902564676478506s**，host完整累计UNKNOWN。AT253仅准备无guard，不记运行PASS。原静态失败、pilot timeout、守卫误停全部保留。

## 封账前仅补原合同“第127行错误”

[修订15合同](source_s128_connection_decision.md)有限验证第4项明确包括“第127行错误”。AT252 peer的done_status固定成功，现有128行PASS未执行最后一行非零状态的请求出口；这是尚未验证，不是已有FAIL。该边界直接关系128位最终发布，且原AT252轻量编译约4.52s/RTL约5.43s，当前余额可容纳有界补测。

复用AT252同生产sequencer和合法row-wrapper peer，前127行正常，row127通过真实done握手返回7/phase14/bad全1；该peer不得置row127成功位/FINAL。核请求错误id=base+127、row127、原status/phase/bad，保持至少3拍到真实消费；不发下一行、不回绕row0，不出现成功request done或tensor_final_valid，前127成功位保持而第127位为0。用独立实际接受/退休计数核128次行命令、127次成功退休及一次失败完成；不得force状态、覆盖、valid或完成。只签这个调度出口，不冒充真实第127行输入读错。无需再扩新的数值/释放场景。

此补项static累计≤20s、RTL累计≤20s，均扣修订15原余额；单重工具、CPU0–3/nice19/idle、RSS与MemAvailable规则不变。只改该局部TB及必要runner，不重编真实FP/IP、不重跑AT250/264长例、不修改生产RTL或gold。普通TB有因修复在这两个小帽内连续处理；若帽触发或发现实质问题，保留原结果及未覆盖范围立即交付，不增加额度或原样续跑。完成后给原log/guard/manifest和追加账，主控集中给最终有界出口，无需逐步询问。

全128真实producer、当前SHA两行完整前缀、真正请求成功/FINAL发布、全请求首错等价、Attention/整模、生产Host/HBM与联合物理继续未验。正常链不关闭逐行与旧全请求head优先的异常顺序差异。本审核依据存于 [机读证据](lnq_review_evidence_20261015.json) 的 revision15_at264_stage_closeout_review；“closeout”字段名指本次审核过程，当前状态是pending_last_row_error_probe，不代表已封账。
