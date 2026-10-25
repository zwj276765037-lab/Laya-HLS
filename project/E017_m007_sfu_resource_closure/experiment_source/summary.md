# E017：SFU最小真实资源测量依据

M007/SM011，owner A007；权威为SM011末节D-M007-SM011-SFU-RESOURCE-12。唯一实现入口为E002既有attention_and_fp_engine/tb/m007_sfu_*，证据E017/R001。生产RTL/credit/TANH/E016依赖只读。

原生成EXP两个helper实际宽度32×32→50/64，精确无符号整数gold；50位取完整乘积低50位。CE1更新、CE0保持；raw reset未使用。ID/NUM_STAGE仅声明无引用，原F64实例NUM_STAGE2与测量保留默认0的未使用元参数差异不改变逻辑。

U55C xcu55c-fsvh2892-2L-e/Vivado2025.2，OOC synth+opt；XDC请求3.333333ns，工具实际3.333ns/300.030MHz，uncertainty0.100ns，全部数据输入/输出delay0.500ns。完整时钟/IO与零blackbox要求，setup/hold分开，不签P&R。

原F64mul六文件RTL使用冻结AT005同finite域/同xorshift seed的独立native binary64 RNE参考；定向生成100400对，不生成整模gold，拒绝FTZ/DAZ。核16拍/II1及有限CE/reset。F64底向上首120s成本出口后，A001仅准复用已完成child EDIF导出拆parent-only；第二次无checkpoint后结束本段，不延帽。

独立caps：reference120/static600/RTL600/OOC900s。全后代项目锁、CPU0–3/nice19/idle/MemAvailable>192GiB、RSS16/24/8GiB、真实语义停滞120s；无P&R/板卡/GPU/全阵列OOC。完整协议见[protocol.md](protocol.md)。


---
Published: 2026-10-22T08:56:27.252760+00:00
Publication: P79517d7fbd8a48049347c2811f612b6f
