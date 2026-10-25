## E016/R004 FFN-REFERENCE-18 current stage (2026-10-23)

execution_state: completed
verdict: COST_STOP_FULL128 / ONE_ROW_LOCAL_REFERENCE_PASS
applicability: 原保存G/norm_ff row0的CPU期望；不签完整128行或RTL。

单行实际0.6786189379636198s，1.35*128*P+10=127.26535248011352s>120；全128 NOT_RUN。已生成G2624个S8 codes/82个F16 scale、norm_ff32组、Down1024个F32；AT003原scalar-vs-batch quant/序列化核对PASS。现20bit父控制计划加A007已声明3bit取消，4036B保守基线上4038.875B/向上4039B，非新父实现/物理fit。

证据：[R004交付](runs/R004/final_delivery.md)、[预算](runs/R004/reports/budget.json)、[cost gate](runs/R004/reports/cost_exit.json)。R003以下原PASS和封账原文保留。

---

# E016/R003：完整原Encoder0 Attention父链 PASS

execution_state: completed
verdict: supported
applicability: 仅原Encoder0一次命令QKV→Attention16head→实际context→WO→成功回执；不签完整Encoder/FFN/30层、物理或部署。

| 实际边界 | 结果 |
| --- | --- |
| QKV | 48块、12288公共QKV32、393216 F32原值 |
| RoPE | 2048真实Q/K提交、原postQKV逐位核 |
| 16head | score/prob各262144、context131072、maximum2048、prob bank ack32768；每head独立数值/身份/周期终断言 |
| 实际公共context | 4096读/响应，query/head/half/tag/gen与32F32逐位核；4096真实quant/Awrite/Aack、一次发布，layer与量化/DIV/A真实债/所有权退休后才WO |
| WO | 唯一matrix/cache真实WO冷载16块，每块1024连续issue/commit；4096公共32F32输出/131072值原gold |
| 首次父成功 | status/source/domain/tuple独立预期0，request77/gen8/epoch9，243bit保持5拍后真实消费一次并回IDLE |
| 有限WO反压 | 中间至少8拍、末输出至少12拍，实际held计数8/12，完整输出与身份稳定、无早DONE |

AT007唯一full实际wall 2828.967579680s，PASS，数值及周期合同均通过。完整实际周期字段：{"parent_cmd": 591, "QKV_cmd": 4781, "QKV_last": 56610, "layer_start": 56617, "layer_done": 235394, "context_start": 235395, "context_last": 239492, "WO_cmd": 239584, "WO_last": 257538, "WO_done": 257544, "dispatch_total": 7, "raw_parent_cmd_to_WO_last": 256947, "raw_QKV_cmd_to_WO_last": 252757, "cycle_pass": 1}。保留原始总周期和外部held，不偷偷扣停顿；模块QKV57344/layer188544/WO22528、dispatch16/合计128与Attention父段268416帽仍按实际事件检查。

同AT004完整snapshot：AT005 QKV3 PASS48.746615243s/8364拍；AT006真实两head pilot PASS877.589479115s。固定实测门P2=877.232754763s、Hmax=114.465794125s、Q=628.900676903s，E=1.10*(P2+14*Hmax+Q)+10=3429.520004357s≤3600，余额≥E+600，故仅自动一次full、timeout3430。Q明确是context+WO的可证伪占位而非实测；本次完整runtime实际CSUB入口→WO DONE为267.514431983s，未超过该Q，区间包含context派发，不能冒充硬件频率。逐head实际wall与周期见actual_complete_chain_metrics.json。旧R0013494.95秒仍为旧版本/旧observer估计；R003使用新合同、新预算和同snapshot实际数据，无旧attempt延帽。

失败保留：AT001生成器end拼接语法FAIL1.914082291s；AT002 build PASS后AT003首批quant/A处xsim内核exception FAIL6.614362462s。等价显式TB字符串/数组分支后AT004 build PASS43.694276949s、AT005/006/007在此组合执行；没有把异常解释为方法数值失败，也未隔离单一构造因果。AT003旧fatal分类未识别FATAL_ERROR文字，但缺终标仍FAIL；原receipt不改，后继分类已扩展。

最终审计1035文件、1670检查PASS；xsim运行可变配置/日志差异单独登记。独立费用reference0/static94.410942169/RTL3761.918036500/OOC0s，含失败与最终审计；余额static505.589057831/RTL2238.081963500s，R001/R002未转余额。

---
Published: 2026-10-22T13:31:19.500493+00:00
Publication: Pfd2a618f579944179887ea44e2919cbb
