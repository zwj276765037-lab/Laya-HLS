# ATN1 完整 head 数值与周期进展

M004/SM005/E005/R001；A002。AT021 的同一冻结候选在完整 enc0/head0 B1/S128 128 行、K128/D64 下通过原逐位中间与最终 gold、全部 M/A/D/EXP 工作量检查，191088 次调用受理与退休配平，无取消。guard_full_01 child0、trigger null，482.110123s，peak owned RSS 1108904KiB。

同口径 ATN0→ATN1：SM 首次 done 287173→265084（减22089，7.6919%），SM 实际消费 287197→265108；QK 250888 不变，AV 66256 不变；三段首次完成和 604317→582228（减22089，3.6552%）；全 TB 1608896→1586807（减22089，1.3729%）。ATN1 EXP 互斥区间 270525→248436，原 ASUB 16000→4096 物理请求，16384 lane 与原独立数值检查保持。该结果只限模块仿真，物理资源/时序与完整请求仍 UNKNOWN。

原始证据：AT021/guard_full_01/guard_result.json、AT021/full_01/simulate.log、AT021/full_01/measurement.json、AT021/full_01/numeric_result.json，均位于本 R001 attempts 下。AT022 是同 DUT SHA `11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16` 的增强协议 TB 冻结；static child0，PROTOCOL=1 的 16 行有限回放正在原 guard 下运行，定向命中新增 staged_pending 与 staged_count ready 并核 CE 保持、reset 清空。AT022 不算第二优化候选。协议尚未得终态，ATN1 暂不宣布采用。
