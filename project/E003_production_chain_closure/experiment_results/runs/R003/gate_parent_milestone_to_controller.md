# M003 GATE tensor与matrix父路径里程碑

工程沿R-SM003-V2-PARENT-20261011继续实施，现交付两项实质局部PASS，请按现合同边界审核；不请求新增成本或范围授权。

1. `gate_tensor_04` PASS_SCOPED：同一GATE Ref/epoch最多128窗口、2048行，逐窗口P/Q/L及future binding、实际写债后覆盖、整tensor READY、逐窗口读租约/读债、跨窗口cancel及同session恢复通过。1234 cycles，guard20.816296s/peak1290512KiB。manifest SHA `9fe0fa24e0fdf212dd3803e255e1b89a80de1a8a4a2aee04278de32a4ab49a31`，receipt SHA `dbc8e0e12a61f8757162c835c20d4c4492d51e89c9f16f4dd7fbd753bdda1314`。仅metadata ledger，未代签GEGLU算术/物理GATE payload/hub。
2. `matrix_parent_views_07` static/pilot PASS：58.001144s/382.907547s，peak2413404/1389172KiB，128440 cycles。18 commands/replies；新增9个真实rows4 view覆盖成功父、跨view空档cancel、同session更大request失败父。每view不同portal g；每父只一次真实A/W acquire/release，成功父和失败父各一次parent complete，cancel不伪造TaskDone；AW/W/B各2563，最后view第512个B反压后才释放。失败父继续四view，受控合法u64 rank 2112000→5280验证跨viewmin归并。manifest SHA `d42efa43c511b8a5b95cbb88cc444b43a54fd382a1c02ee546b9d7dff0ad69fe`，receipt SHA `8782d874db30980652e9f9ef667205e138271e683bdc3b2f05daa6077da1366a`。

同时`matrix_tensor_02`已通过128父/512 view/2048行同dst epoch覆盖与sticky tensor失败，`matrix_parent_current_01`在当前ledger接口后重新冻结PASS。binding修复了owner retire后writer清coverage导致中间view响应published误报0的问题，现于真实retire握手锁存view成功。

所有失败attempt保留：`gate_tensor_01..03`、`matrix_parent_views_01..06`。E003三摘要已发布为`Pe49a2951903447688a0b35a7e28d528c`，模块design/results和R003/run.md已更新。

边界保持：受控A/W cache端点、诊断零输出及受控rank不代签真实cache/模型数值；物理GATE writer/reader、G分期、QUANT父A、唯一持久hub/generated caller、L2/L3、当前完整CPU/实际CSim仍待完成。L0/L1继续PARTIAL、L2–L5 NOT_RUN，M004继续；无新OOC/P&R/上板，G预算不变。
