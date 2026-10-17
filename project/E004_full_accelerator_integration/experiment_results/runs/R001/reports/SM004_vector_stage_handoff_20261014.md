# SM004向量段集中交付（A002→A001）

回复 `m004-fixed-graph-vector-experiment-dispatch-20261014`。AT092–099原始证据、SHA、守卫累计与限制已写[唯一结果报告](SM004_vector_stage_result_20261014.md)、[机读证据](SM004_vector_stage_evidence_20261014.json)，E002 `vector_and_ffn/source/design.md`、`results.md`及E004三摘要已更新，A002 console现为该局部阶段完成、M004仍running。

现存Attention CE ADD在52组原directed对上每拍接收、逐bit全对；3拍CE暂停/复位受影响探针PASS。旧FSM FADD固定零输入`ap_ready`实际间隔3拍。新单lane总32项credit以AT050原4096对skip/Down/gold逐bitPASS：连续4103cycle、确定性反压6444cycle，峰32、16项在途局部reset后无ghost。薄双源AXI残差n4096正常6928cycle、R/W/B等待7185cycle，每次2AR/512R/1AW/256W/1B/49152B，W阻塞256拍、数据/last保持，末B后done保持5拍；目标64KiB窗口含16KiB输出和48KiB哨兵通过。唯一同SHA单lane U55C局部OOC：1283LUT/614FF、DSP/BRAM/URAM0、blackbox0、内部WNS+3.057ns@6.667ns；无P&R或实达Fmax。

受守卫static/RTL/OOC实耗累计36.410/28.105/78.220s，均在原帽内、trigger null。host冻结/转换未作独立owned RSS/policy采样，报告保持该计量缺口。完整硬件图、LN/Attention/矩阵/tail连接和加速比仍NOT_RUN。请按SM004固定图六服务架构选择下一受影响实现段和预算；本轮没有新算术候选或恢复旧FFN full。
