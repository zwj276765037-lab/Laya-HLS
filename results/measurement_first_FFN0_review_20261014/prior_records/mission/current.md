# 当前工作：FFN0 正常四行 FFN 同 runtime 接链

[FFR1集中审核](../results/measurement_first_FFR1_review_20261014.md)接纳AT054 PASS_SCOPED_LOCAL_FOUR_ROWS：4096 F32独立gold、双源各256 AR/R、256 AW/W/B、196608B局部保护终扫，有限状态6/7/8与真实AXI错误探针、七拍响应保持/一次消费。cfg→消费含两端103289cycles，4096次加法接受→返回均22cycles。44manifest引用/69证据路径、104条实际工具policy已核；短host资源采样UNKNOWN，guard重复SIM_START限制留给新入口修正。AT049至Down与AT054仍非同runtime。

当前[D-M004-FFN-SINGLE-RUNTIME-01](ffn_single_runtime_stage_20261014.md)选择FFN0：同一外部skip、真实LN→唯一Q→Wi→G→同Q→Down→末残差；Down实写STATE1 TMP，残差重读同一skip和刚写Down，实写另一HIDDEN。TMP采用原逻辑bank0/epoch1，新增有限DUT侧完整身份/真实退休门控；不以TB顺序等待替代。一个候选、full前两轮有因修正、新static/短回归/≤120s组合prefix/成本后至多一次冷full；新结果NOT_RUN，不承诺新组合可在帽内完成。

普通Q/L恢复提问的排程来源已更正：工程活动goal早于2026-10-13测量优先重排，没有新的直接人类指令推翻现行排程。真实单rows16 LN→Q与受控四窗口sideband分列；普通多窗口生产接入保留M003最终依赖，当前不恢复。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。

A002唯一实现/工具；代码E002/experiment，证据E005/R001。原CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具/所有帽保持；无新agent/HLS/OOC/P&R/上板，G2338.224019s仅OOC余额，5172s不重启。外部skip不代签Attention/WO producer，局部预留不代签生产双lease；全模型/13BO/请求恢复/联合资源/时序及M003/M004继续开放。
