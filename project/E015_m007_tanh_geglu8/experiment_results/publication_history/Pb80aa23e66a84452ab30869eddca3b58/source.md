# E015：TANH-G8-08实验依据

现行授权为SM011 D-M007-SM011-TANH-G8-08。A008仅写vector_and_ffn新M007实现/source增量及E015；原canonical/gold及A007/A010共享源只读。原glibc TANH DAG、严格独立F32舍入/gradual underflow/精确商余数不变，先add3/mul4/div12真实leaf→single lane→8lane/G。152拍为静态目标，≤160/II1与300MHz分别验证。纯G用96bit SFU、phase1唯一G双slot、s-major坐标与全域原首错rank。

独立预算reference900/static1800/RTL3000/OOC1800s，旧余额不转；全compute/EDA持m007_heavy.lock覆盖全部owned后代，CPU0–3/nice19/idle，MemAvailable>192GiB。Vivado2025.2/XSim；小leaf OOC U55C有效3.333ns、uncertainty0.1ns、完整IO0.5ns；只综合+opt，无P&R。期望gpt-6.1-sol/xhigh，实际配置未核实。详见protocol.md。


---
Published: 2026-10-21T07:34:13.853593+00:00
Publication: Pf97084e29e9d4bfebe56b52a990fd4bb
