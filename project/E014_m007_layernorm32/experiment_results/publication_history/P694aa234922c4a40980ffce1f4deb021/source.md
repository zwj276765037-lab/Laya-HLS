# E014：LN-05实验依据摘要

实验：m007_layernorm32；大 mission：M007；小 mission：SM011；类型：hardware。

| 项目 | 当前内容 |
| --- | --- |
| 要回答的问题/假设 | 严格原三遍1024 LN，32F32/拍、四ctx、完整S128能否在16704拍内实际退休 |
| 方法及机制 | 先精确div1024≤16拍/迭代sqrt≤32拍，再只读唯一sharedFP256、div8、LN-exp32KiB；不复制共享阵列/行payload |
| 平台、工具、约束和输入版本 | Vivado2025.2/XSim；两标量已做xcu55c-fsvh2892-2L-e综合/opt、有效3.333ns及完整IO约束；整体LN/P&R未测；原encoder00/27与final_norm保存gold绑定见合同 |
| 基线、控制变量与改变项 | 冻结full_reference.py SHAfe9678e4…e9784 layernorm_rows；EPS3727C5AC、两棵10级相邻树与独立F32算术不改 |
| 指标、单位、验收和适用条件 | first row≤448、rowII≤128、全128行≤16704；metadata≤8192B；错误/hold/债/reset另验 |
| 方案/权威来源 | mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md D-M007-SM011-LN-05；E014 protocol |

已实际从E013冻结交付接续；独立预算reference900/static1800/RTL2400/OOC900s，旧余额不转。
A008唯一写layernorm_engine新M007文件/source增量及E014。A007共享源只读，phase6新源
SHA80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230已交付，AT006受影响回归通过。
当前engine SHA2799427bb0fe36ddb45da21357868ff04a415fbda62c7dca11a4912d0266c263。
完整plain128和原encoder27+final_norm_w gamma128全中间/最终逐位通过；真实四ctx占满、有限停顿、
局部错误排债/无reset新gen、gamma/身份/共同reset恢复通过。两小标量综合setup正、hold仍有违例；
整体LN/父图物理共享、原16行tile及全模型首错不在已签范围。desired gpt-6.1-sol/xhigh，actual未核实。
