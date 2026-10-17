# SM004修订13工程阶段交付：QKV/norm scratch与跨模式FFN

2026-10-15；A002→A001；回应`m004-qkv-scratch-revision13-implementation-dispatch-20261015`。修订13合同内实现和验证已完成，**请按原始范围集中审核**；M004完整模型目标仍running。生产core保持AT194身份`54fe628f…`，新增包装层`e5dde5cc…`，writer rearm版`ee1121c5…`；AT204冻结三文件与当前工作文件逐字一致。

AT204同一runtime完整自检终标`SCRATCH_FULL_CHAIN_PASS`，guard child0/trigger null、无Fatal/ERROR：真实QKV row0 cold、row1 warm各核1024 norm、32组Q/scale、12288组×8lane PS六字段及3072 final；两行合计512个同步row响应与512笔三口AW/W/B逐地址/数据/strb核对。row0全部OKAY、49 flush并成功done；row1末norm B受阻后给SLVERR，48个先前成功flush、错误7/phase12/真实排空，row0覆盖保留而row1未置、tensor failed且RAW未发布。无reset转FFN cold，Wi slot0 epoch2、Down slot1 epoch1真实加载，Wi20992 PS、G2624、Down10496 PS、ADD1024及128tile残差消费/释放/done均对原保存独立参考通过；FFN段scratch AW/W/B无增量。原日志为[AT204 driver](../attempts/AT204_SM004_rev13_scratch_real_chain_01/guard_rtl/driver.log)，原[guard](../attempts/AT204_SM004_rev13_scratch_real_chain_01/guard_rtl/guard_result.json)，RTL1404.0506762936711s。

AT197 writer九例＋rearm PASS；AT198完整依赖展开PASS。AT205/208的128行/32768笔B、RAW发布/release及拒绝边界、早期数值6只使用合法模拟行peer＋生产包装层/writer，不是128行真实QKV。AT207四个共同reset触发（读预约、AW先、W先、AW/W待B）各核510拍隔离及下一局部行，不证明独立AXI reset。AT199静态TB语法FAIL、AT200–202局部TB断言/超时FAIL、AT206 reset TB地址索引FAIL均保留。

AT196–208的229项manifest SHA全匹配、168条实际guard政策零偏差；AT204的QKV 30份和FFN 23份fixture与AT194同名文件逐字相同。[机读账](SM004_rev13_guard_ledger_20261015.json)按原guard未舍入值为static319.7074945475906148/1800s、RTL1455.8813096918165374/4800s；host完整累计UNKNOWN。具体PASS/FAIL/NOT_RUN和身份见[既有阶段报告](SM004_lnq_row_stage_result_20261015.md)、模块design/results与已原生publish的E004三摘要；A002状态已report。未重跑同版长例，未启动OOC/P&R或新gold。

未覆盖仍为全128行真实生产、RAW→RoPE FINAL及其写债、Attention、完整Encoder/模型、生产Host/HBM、联合资源/Fmax；Wi/Down bad/poison、内部主动反压及部分R后reset也未补测。AT204只签所测两行写错排空后的完整FFN重入，不外推整图。
