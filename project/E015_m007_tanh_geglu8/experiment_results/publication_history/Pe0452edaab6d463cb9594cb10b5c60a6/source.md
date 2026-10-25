# E015：TANH-G8-08实验依据

授权SM011 D-M007-SM011-TANH-G8-08。A008只写vector_and_ffn新M007/source增量及E015；原canonical/gold、A007共享FP/DIV/EXP/storage和A010矩阵只读。原glibc42节点23add/17mul/2div、阈值/分支/常量/每次F32舍入不变。3/4/12真实快速叶子先行，原DAG152edge为静态结果，TANH外部≤160/II1与300MHz分别实证。纯G公开96bit SFU、phase1唯一双slot G、s-major/后继group-major Down与原全域Check。

Vivado2025.2/XSim；小叶U55C有效3.333ns、uncertainty0.1ns和全IOdelay0.5ns，仅综合+opt。独立reference900/static1800/RTL3000/OOC1800s；全compute/EDA持唯一锁覆盖owned后代，CPU0–3/nice19/idle、MemAvailable>192GiB，旧余额不转。期望gpt-6.1-sol/xhigh，actual未核实。协议与G前缀可取消/全局成功/Down启动边界见protocol.md。


---
Published: 2026-10-21T09:56:10.389908+00:00
Publication: P25b036d388484d7b9f6636a0917984dc
