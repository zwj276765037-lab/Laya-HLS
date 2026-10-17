# 当前工作：LNF0四行LN_FFN真实RTL

[LNREF0来源审核](../results/measurement_first_LNREF0_review_20261014.md)接纳AT038原request3/generation1/B1/S128独立参考前缀：enc0 residual完整128行和前四行已冻结，独立LN输出与旧观测/AT035源131072/4096 F32零差异，q/scale逐字节吻合。仅主机参考，不是LN硬件通过。AT037两次封装/启动失败保留；原LQ0 83项生成物身份已核。

当前执行[D-M004-LN-FFN-RTL-01](ln_ffn_four_row_rtl_stage_20261014.md)：复用原LQ0 baseline核与真实store/provenance/source lease/Q/fullA路径，适配LN_FFN0x12/stage2/layer0、B1/S128四行、原STATE0容量及NORM offset8MiB。LN实际最后B/END后唯一发布，Q重读刚写字节，校核4096 F32/4096INT8/128scale、fullA/末债务及存储保护。修正旧TB只在16行执行Q的分支，不继承旧16行PASS。

一个封装候选、最多两轮有因修正，static→≤120s rows1 pilot→有保守成本依据的rows4 full。生成物不能复用时交付具体证据，不自动新HLS。新RTL结果NOT_RUN；本轮不重复Wi/G/Down长链、不拼接两条PASS为同runtime链。

A002唯一实现/工具，A001集中审核；E002/experiment实现、E005/R001证据，不新增agent/不写旧baseline。单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB，static24GiB/1800s、RTL8GiB/3600s/40Mcycles、pilot/真实停滞120s保持。无新HLS/OOC/P&R/上板/预算；G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。完整LN→QAR0、FFN residual、全模型/请求/恢复及联合物理证据仍缺，M003/M004不关闭。
