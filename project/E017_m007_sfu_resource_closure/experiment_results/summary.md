# E017：限定结果与成本出口

execution_state: completed
verdict: inconclusive
applicability: 两个原EXP整数helper完整IO OOC及原F64mul finite域RTL；F64父资源/最终链接仍UNKNOWN

| helper实际配置 | DSP | LUT | FF | setup WNS ns | hold WHS ns | OOC费用s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 32×32→50 | 4 | 33 | 34 | +0.624 | +0.386 | 87.964250 |
| 32×32→64 | 4 | 47 | 34 | +0.624 | +0.386 | 88.890460 |

AT004/005均有真实DCP、blackboxes0、check_timing全部12类0、TNS/THS0。周期请求3.333333ns/实际3.333ns；完整IO0.500ns、uncertainty0.100ns。HD.CLK_SRC未指定，OOC无法估计父时钟偏；无P&R/物理300MHz结论，资源不外推联合fit。

AT003整数RTL PASS：17601连续独立对；总40340检查/18116接受/2054CE保持，172 reset+CE更新与1030 reset+CE保持，20170拍，一有效边沿捕获/II1。

AT010原F64mul六文件RTL PASS：100400连续native-RNE有限输入对，总101424精确输出/接受，1034CE保持、147 reset+CE更新/523 reset+CE保持，102490拍，延迟16/II1。独立参考SHA d99b76676e6bae759252bacb81654ef5b49c5b9f4c1eb236872d1c53122a15d1。raw reset未清payload；不代签服务token隔离或非finite输入域。AT008快速参考RSS/实际策略样本未捕获，保持UNKNOWN。

AT011底向上COST_STOP120.223383s：已完成两个child DCP显式open/export（27+14s），父stub停在cross-boundary/area优化。复用原EDIF的AT012 parent-only COST_STOP120.264021s：最后完成XDC应用（synth elapsed101s），停在Start Technology Mapping。两次均无Fatal、无parent DCP/EDIF；AT013未创建/未运行。F64最终链接、实际DSP/LUT/FF/setup/hold为NOT_RUN/UNKNOWN，不能把HLS16DSP写成实测，不能据成本出口判方法FAIL。

AT007在工具启动前因错误预留整120s触发脚本断言，prelaunch_failure.json保留；无伪造guard/执行费。其余失败/成本出口均计账且不覆盖。

总实际费用（s，精确和见budget_ledger.json）：reference0.334352/static9.540586/RTL14.734132/OOC417.342115，caps120/600/600/900。143项SHA核验/59个真实策略进程样本通过；timeout保存PID当前无非僵尸owned后代。六份生产SHA与六文件原RTL均保持。无新SFU实现预算，未用额度不转。

主证据：[final_delivery.md](runs/R001/final_delivery.md)、[machine结果](runs/R001/final_delivery.json)、[实际账](runs/R001/budget_ledger.json)、[终态核验](runs/R001/final_evidence_audit.json)。


---
Published: 2026-10-22T08:56:27.252760+00:00
Publication: P79517d7fbd8a48049347c2811f612b6f
