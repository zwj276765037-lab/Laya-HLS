# E015：TANH-G8-08实验依据

授权SM011 D-M007-SM011-TANH-G8-08。A008只写vector_and_ffn新M007/source增量与E015；原canonical/gold、共享FP/DIV/EXP/storage只读。保持原glibc DAG与每个F32舍入、渐进下溢和精确商余数。3/4/12拍叶子先行，单lane≤160/II1后8lane/G；静态152拍不代表时序通过。纯G公开96bit SFU、phase1唯一双slot G银行、s-major/未来group-major Down和全域原input/u/v/w/t/z/y/gate首错。

Vivado2025.2/XSim；小叶U55C有效3.333ns、uncertainty0.1ns、全非clock IOdelay0.5ns，综合+opt且不做P&R。独立预算reference900/static1800/RTL3000/OOC1800s，公共重工具锁覆盖owned后代、CPU0–3/nice19/idle、MemAvailable>192GiB；旧余额不转。期望gpt-6.1-sol/xhigh，实际未核实。完整协议见protocol.md。


---
Published: 2026-10-21T07:51:39.027482+00:00
Publication: Pb80aa23e66a84452ab30869eddca3b58
