# E006 关键结果摘要

当前完成只读容量/接线边界盘点、给 A003 的现有计量答复，以及AT063原full终态核查：2080.299s后因Down W发布后120.093s无认可进展而有界停止，Down cfg及整链终检未达；E006 新同 top 正常与不同反压全链 RTL、联合综合、place/route 均 NOT_RUN，LUT/FF/DSP/BRAM/URAM、关键路径、布线频率和整模收益均 UNKNOWN。此处不将 AT063 中间进展写成整链 PASS。

RTL 声明容量：dualA payload 139264B；dualW q/scale/bias 合计11461632B；四行 PS 83968B＋metadata 5248B，均不是物理利用率。现有 AT049 到 Down 的四行链、AT054 局部末残差和 AT021 单 attention head 各有原范围内计数，不能相加为本代表链或整网时延。B1/S128 production-v2 帧的16个 scorer 槽有2个有效候选；完整图含122次 Q8 调用为参考图结构推算，非122次真实 RTL 运行。

证据为本 R001 的容量答复、production-v2 身份补充与代表 top 边界盘点；旧 E005 原收据及运行状态仍在其原路径。


---
Published: 2026-10-14T02:11:00.283760+00:00
Publication: Pcfd731a48c8e49f0b7feb9c7a9017f5e
