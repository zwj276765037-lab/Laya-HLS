# E013：关键结果摘要

QUANT-03完整group32 engine功能/周期限定通过；最终AT014/015/016绑定实际编译snapshot，
AT018发布审核PASS。唯一engine SHA555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add。

| 指标/单位 | baseline | 当前结果 | 差值/不确定性 | 原始证据与定位 |
| --- | --- | --- | --- | --- |
| 实际norm128/K1024 | 原独立参考，帽4224拍 | 4096组全部Q/half/amax/d/inverse/products逐位一致；首85/全4180拍，II1 | 帽内44拍；前4行原fixture关联PASS | runs/R001/attempts/AT015_snapshot_bound_full/work/report.json |
| 诊断K2624/K4096 | 各128行，帽10624/16512拍 | 10496/16384组逐位一致；首85/全10580/16468拍，II1 | 各帽内44拍；不是模型轨迹 | 同AT015 |
| lease/init | 单独计量 | lease wait1拍，正常peer在其后2拍输入；初始实际reset4 rising edges | 不隐入流测时 | 同AT015 lease_initialization_metrics |
| 错误/信用/恢复 | 128真实预约，合法口刺激 | 16边界错误阶段/element；128满槽/129阻150拍/完整held稳定，256组有限停顿；16记录释放屏障；8协议拒绝不占槽；24组真实div在途reset后gen2恢复 | 非全父首错或A slot取消 | runs/R001/attempts/AT016_snapshot_bound_protocol/ |
| 存储声明账 | raw16384/packed4352/metadata8192/总32768B帽 | raw16384，packed4352，slot metadata4016；全部其它6764B，总27500B上取整 | 源声明账，非物理RAM映射 | runs/R001/release_evidence_v1.json storage_ledger |
| 小amax综合 | xcu55c-fsvh2892-2L-e/3.333ns/I/O0.5ns | 1634LUT/988FF/0blackbox，WNS+0.958ns；全约束覆盖缺失0 | 只小叶，非engine/P&R | runs/R001/attempts/AT013_amax_same_dcp_retime/work/report.json |
| 原始helper | 独立2072格式/52amax输出 | 全PASS；5 enabled-edge/reset隔离 | 原身份复用 | runs/R001/attempts/AT003_local_format_amax_rtl/ |

研究判断：PASS_SCOPED_STRICT_GROUP32_ENGINE；A001审核另记。1份真实shared_div8+32个原严格mul，未复制物理服务或修改独立gold。

适用版本/平台：Vivado2025.2/XSim。AT014 source_identity从实际frozen编译路径生成；AT015/016各有运行前xsim.dir SHA清单、实际命令/UTC和运行后清单，非回填旧结果。原输入SHA5d882938…4213056、独立reference SHAfe9678e4…e9784，完整身份见[release](runs/R001/release_evidence_v1.json)与[交接](runs/R001/quant03_handoff.md)。

异常保留：AT009 XDC不支持remove_from_collection导致1001 input delay缺失，旧runner时序PASS不能整体采用；AT013同DCP重约束修复。AT017审核因手工leaf位数加总错误FAIL，旧705实际605bit/leaf，修正后总量减少400B，DUT/gold未变，FAIL与成本保留。

总成本含全部18次尝试：reference2.040709/900s，static26.688707/1800s，RTL60.840843/2400s，OOC142.820045/600s。峰owned采样RSS4364783616B。
限制：实际A-cache发布/整slot取消、全父Check与首错、Q/G/idle_Q物理共享、完整engine资源/BRAM/300MHz/P&R/上板/完整模型均未签。
