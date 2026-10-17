# R-SM003-GATE-SPLIT-20261011：限定功能接纳与下一集成出口

主控已审核`gate-split-runtime-milestone-20261011`。权威记录`results/reviews/SM003.md`新增R-SM003-GATE-SPLIT-20261011，证据快照`results/gate_split_stage_review_20261011/verification.json`。194/194条身份引用及12/12条历史fixture输入/输出引用匹配，消息所列manifest/receipt SHA一致。

接纳gate_store_04物理writer/store局部PASS、gate_split_static_01静态PASS、gate_split_04同runtime四G窗口→独立Q0→真实fullA局部PASS。数值范围是原四条不同enc0 WI行按mod4重复，64行为多窗口执行/容量覆盖；WI和内存peer仍由TB驱动，只消费window0的16行。其余Q/L、真实上游WI producer、LOAD/fullW/matrix、唯一hub/generated caller及L2/L3未通过。原PASS不扩大为全模型结论。

matrix_cost_stop_branch_01调用实际拒绝函数的3601s有界检查足以关闭本次manifest/receipt一致性修复项：COST_STOP/started:false、最终哈希一致、无full工具产物。它不签matrix RTL新运行；views_07的历史预算DEVIATION保持，不改名追认、不补跑。

本批受核static/pilot/full未超对应时间/RSS帽；split full前2277s估算基于历史四行94.854549s×16×1.5，并记录了当前pilot32.550573s/11769cycles，实际full1054.961660s。_03→_04冻结files/fixture_files仅TB进度间隔100000→20000不同，DUT/gold/full覆盖未变。_03 semantic_stall中止保留。

有一处需要在下一相关full前按原授权常规修复：split TB第144行每20000cycles无条件打印FULL_CURRENT；production_guard第90–94、153–155行见匹配行就刷新semantic_last，未检查实际工作量。即使DUT/AXI不再推进，仿真时钟和重复日志仍可刷新120s停滞计时。本次37条进度行writes逐次增加，所以本次局部功能与观测成本保留，但不能签“真实停滞保护有效”。请让只有实际接受/返回/退休或单调已完成工作量变化才能刷新，排除cycle、心跳及重复状态；可修TB发出条件或guard解析，并有界核验工作不变而日志/周期增长仍停止、真实推进可继续。保持120s停滞及原时间/RSS帽，不需历史full重跑；其他独立实现继续。

另注意split PASS行actual_AW与actual_B均打印write_beats，不能视为独立通道计数。下一受影响集成TB应分别统计真实AW/W/B握手，尤其核定held最后B的退休；本次writer/末B结论结合store层限定证据保留。

沿现合同继续：真实QUANT fullA→实际fullW父matrix，补其余Q/L与LOAD→Q/L调度，再接唯一持久hub/实际generated caller。集成须保持多父同tensor、原首错优先级、真实末R/B与lease清理、唯一父完成及同session恢复；最终源/生成依赖身份下完成当前完整CPU/实际CSim。普通修复连续推进，不新增逐项用户审批。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。完整Laya加速器与尽量高性能目标不变，无固定性能门槛；局部cycles和仿真墙钟不作为完整请求性能。原单owner/单重工具、模型/shape/数值/13BO、全部资源帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板。主控本轮只读审核并更新记录，未改实现或运行工程实验。
