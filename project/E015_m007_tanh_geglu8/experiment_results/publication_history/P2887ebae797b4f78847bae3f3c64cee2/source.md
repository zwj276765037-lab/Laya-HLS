# E015：TANH-G8-08来源与方法

授权SM011 D-M007-SM011-TANH-G8-08。A008仅拥有vector_and_ffn新M007实现/source增量与E015证据；原canonical/gold、A007共享FP/DIV/EXP/storage和A010矩阵只读。原glibc42节点23add/17mul/2div及每次独立F32舍入、分支、常量保持。独立native SSE/RNE/FTZ0/DAZ0原运算向量；原B1 Encoder0全部128行WO→残差→LN→Wi参考，335872真实z、384边界、6非finite。AT018独立42节点参考最终全等原host libm。

当前原DAG152edge、add3_e/mul4/radix4 direct-div12，真实3/4/12拍II1；单lane先于8lane。八lane恰8core+一份只读shared vector_credit，mode1/phase1、96bit tag/mask及完整request/gen/epoch。小leaf OOC为Vivado2025.2/U55C有效3.333ns/uncertainty0.1ns/全IOdelay0.5ns，仅综合+opt，功能和物理阶段分别报告。

独立reference900/static1800/RTL3000/OOC1800秒；全部实际compute/EDA持唯一m007_heavy.lock，CPU0–3/nice19/idle I/O、MemAvailable>192GiB，RSS16/24/8/24GiB。预冻结v3实际checked-consume事件独立120秒停滞、总墙钟/RSS/预算/后代回收共同保护；长例由同版实际pilot成本门绑定。期望gpt-6.1-sol/xhigh，实际未核实。

用户明确“按此收尾后暂停”由A001实际消息转达；当前八lane已收尾，不启动G、父级或新OOC。恢复入口R001/tanh8_pause_handoff.md，需用户明确恢复。


---
Published: 2026-10-21T10:09:57.366771+00:00
Publication: Pe0452edaab6d463cb9594cb10b5c60a6
