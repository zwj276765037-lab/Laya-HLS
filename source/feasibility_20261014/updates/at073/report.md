# AT073与诊断综合：局部周期勘误，整模预算数值保持冻结

2026-10-14；A003；M005/SM006/E006/R001；截至工程AT077交付。关联 `m005-at073-research-measurement-update-20261014`。本补充只核查新证据，没有重跑整模模型或修改v4。

**AT073在同代表top上完成了Down及其局部检查，但在进入末残差前Fatal；三个诊断综合均未形成有效网表。完整FFN、稳定性、资源和频率仍不足以校准整模性能。** 原“暂不扩大当前串行路线投入”的建议保持，不能把接链或RTL展开失败推广成FPGA理论不可行。

## Down周期口径勘误

原日志第949–954行的三个端点是cfg_accept=358881、first_done_valid=375066、actual_done_consume=375073。工程初始消息/报告将“16185”描述为“cfg→消费含两端”，与原端点不符：

| 计量口径 | 周期 |
| --- | ---: |
| cfg→首次done的端点差（STATES明确首端包含、末端不包含） | 16185 |
| cfg→实际消费的端点差 | 16192 |
| cfg→实际消费、两端采样均计入 | 16193 |

v4采用第二种16192，所以无需更改Down服务率。已以 `m005-at073-down-cycle-correction-20261014` 直接向A002发送勘误，送达回执已确认；解释层修改由工程负责，本补充不更改其原记录。首次done到实际消费还隔7cycle，不能把它从已有包含该等待的区间中再次扣除或累计。

## 新证据能支持的范围

Wi、Down的两条完整`DOWN_MEASURE_BOUNDARIES`及`WIGQD_BOUNDARIES`与AT049逐字一致。它们支持本样本所列局部区间一致：Wi cfg→消费46917；G cfg→末GATE B57993；第二Q首R→A发布2703；Down W装载27064；Down cfg→消费16192。全部是端点差，来自各自局部窗口，不相加成新的完整FFN结果，也不推导不同数值/shape的统一效率。

AT073的`FFN0_PREFIX_PASS`于375074出现，随后是`Down-to-residual retirement gate did not retain ticket` Fatal。结合冻结TB的顺序检查，此前已通过Wi读1312 beat、G写/读656 beat、Down 256 AW/W/B、Wi/G DDR检查、Down TMP前16KiB独立gold及总64KiB窗口的邻区检查。原TMP总检查窗口为65536B，包含16384B有效输出及其余49152B邻区，不能误记为输出外另加64KiB邻区。该检查不等于最终655360B全链保护终扫。

Fatal是合取检查，原日志没有逐项失败操作数。末残差受理、双源AR/R、4096加法、HIDDEN写与最终gold/保护未到；不能补接AT054。Down窗口的q0/q1/scale/AUX `R_not_ready`均为0，未覆盖RVALID高且RREADY低的保持情景；独立合法反压完整样本也未执行。prefix cycle375074受TB顺序和响应策略影响，不是请求完成时间。

## 物理证据与投入判断

只读核对AT074/075/077原日志及guard：AT074为显式net类型展开错误，AT075/077为provenance hub动态循环展开失败；均child非0。三次尚无可用联合网表，因此LUT/FF/DSP/BRAM/URAM、Fmax和route结果不能替换UNKNOWN。编译循环展开错误不等于实际器件资源溢出，也不证明运行时循环不收敛。

A002报告hub组合展开或多周期实现存在面积/时序/请求状态的架构取舍，已提交A001集中判断；本补充不授权实现。若后续取得诊断物理报告，仍需分别记录其源码/网表身份及未闭合的功能，不能自动校准成可用加速器。100/150/200MHz继续只是v4条件扫描，150MHz/10GBps等假设下的6.919–8.133s也没有变成实测性能。

按工程ledger，M005新full已3/3、4974.979578s，次数限制已到；未完成全链且无独立反压样本的结论必须进入最终可行性评判。当前有证据支持的是局部算术/传输推进，仍没有支持扩大当前串行路线投入的整链与物理闭合证据。

## 核查身份与成本

[audit.json](audit.json)和[input_manifest.json](input_manifest.json)保存19份有界输入快照、日志行号、周期公式及综合错误；冻结TB的SHA与AT073清单对应条目相符，未重复校验完整工具/runtime包。首版报告/budget/input_manifest三个已审核SHA锚点不变。资料按读取时身份冻结，工程后续勘误不回写本次快照。

H009为证据检查：0.104183s、exit0、无分析guard trigger；A003累计H001–H009为3.371098s。实际资源样本及命令见[H009回执](../../host_runs/H009.json)，idle I/O独立采样仍UNKNOWN。没有执行EDA、参考前向、GPU或新增硬件尝试。
