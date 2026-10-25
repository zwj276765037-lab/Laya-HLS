# E010：实验依据摘要

M007 / SM011，A007唯一拥有E002 attention_and_fp_engine及E010。权威 [SM011](../../../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md) D-M007-SM011-QKAV-01；[协议](protocol.md)。

R001检验完整S128单head自主QK和独立AV经实际QKV、唯一PS/G/context及共享256mul/256add逐位完成、真实债退休并满足局部周期目标。当前功能/周期PASS，DONE/held read响应交接已实际复现修复并同版QK/AV回归；不能由独立AV原prob装入签softmax/完整Attention。Decision、RoPE、16head、矩阵父图、OOC/P&R/板测未验。

独立参考为未改full_reference.py（SHA fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784）和原enc0/head0/request3/gen1/RoPE后/mask72 fixture；原16384score/128max/8192context复算逐位一致。QK六级相邻F32 RNE、精确0.125scale、原bias/strict max；AV key递增逐次F32产品/partial。额外sliding为原局部reference新期望，不是新整模gold；Check排序为独立有限诊断，不冒称模型轨迹。

PS2×512×16/G256×64/context64×2048 F32原生逻辑银行无重复role RAM。该阶段端口别名不签matrix/G父图物理复用。Vivado2025.2 xsim；全guard子进程持m007_heavy.lock，CPU0–3/nice19/idle、MemAvailable>192GiB；R001独立reference600/static1800/RTL2400/OOC600s。
