# E016/R004 FFN-REFERENCE-18：原局部参考与成本出口

2026-10-23，A010。execution_state=completed（本合同阶段出口），verdict=COST_STOP_FULL128 / ONE_ROW_LOCAL_REFERENCE_PASS。未改生产RTL，未运行EDA、CPU新编译、GPU、板卡或整模型；R003和封存60s准备账均未转余额。模型/effort期望gpt-6.1-sol/xhigh，实际未核实。

**原输入row0的Q8(G) codes/scales和Down1024值已生成；完整128行未准入。** AT002完整实际费用0.6786189379636198s，固定公式`1.35*128*P+10`=127.26535248011352s>120s。剩余总预算并不改变单次准入门。未调小成本系数、未排除启动/打包费用、未延长timeout或原样重跑pilot。精确机器记录见[AT003 cost_exit.json](attempts/AT003_cost_exit_audit/work/cost_exit.json)。

## 数值来源与实际核对

直接调用原独立CPU参考fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784的`quantize_many/quantize_rows/q8_linear_full`；F32 inverse在半精度scale存储之前，原roundf等价规则、I32 dot和group0..81逐次F32舍入不变。未使用Python宿主double代替浮点计算。Python3.12.3/NumPy1.26.4、NumPy实际核心SO和build config、libm fce00b6f...均冻结；fegetround=0且实际F32最小subnormal加法保留。没有新编译，static费用0；不虚构参考的C++编译flags。

AT001交集PASS：旧Down diagnostic row112的82组packed Q8和1024个输出逐位匹配旧原参考；AT007原norm_ff row0重新经原Wi权重得到5248个Wi原值逐位匹配。旧诊断行仅用于证明调用适配，本次新Down仍只输入AT007原G row0，未替代数据。原权重Wi SHAf7cee5bb...、Down SHA570c3274...、原G SHAf65d20ee...完整版本在每次input_identity/report中。

AT002生成、AT003独立序列化/原scalar quant对batched quant核对PASS：

| 真实产品 | 已完成范围 | SHA256 |
| --- | --- | --- |
| G packed Q8 | row0，82组，2788B | a8b10fee9f0c4e4d4f720d10bddfc7b0f4482fdf494739c62d99443e3514e757 |
| G S8 codes | row0，2624B | 22e338e45420ea9da712a47a56357417a6c769bb7bb71bd3e12f12c8b030edc5 |
| G F16 scales | row0，82个/164B | 0f4fa52af5c184f23fedb6b902b567971d4dda290af8a1244b1f7579c9d8abf8 |
| norm_ff packed Q8 | row0，32组/1088B | d991258960159311a4abcb70cd20fe9181d9b9a9b5252b410a93d125c66c2f57 |
| Down F32 expected | row0，1024值/4096B | 842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f |

[单行fixture及完整清单](attempts/AT002_one_row_reference_pilot/work/report.json)另含A272bit row/group-major hex、G source groups、native Wi保存产品输出布局、原Wi/Down W576四port文件复制身份。pilot one-row标记不允许当完整128-row RTL输入或expected。真实事件显示新G quant→norm quant→Down row1024完成后才序列化；Down计算完成相对事件起点0.009886853s，fixture序列化结束0.385939775s，整child0.678618938s。一次性输入/hash/权重复制及序列化占显著费用，但**本阶段不以计算子区间替代合同整child成本门**。

## 唯一后继接线和新增控制

[逐束连线表](reports/ffn_connections.md)固定公开norm_ff→同quant/A槽0→Wi native0..81→双槽G→唯一1024bit拼接→同quant/A槽1→完整成功屏障→Down。PS/G同phase1实际身份按束并行，matrix/shared256与G原56mul/16add池分开；原storage/FP/DIV/cache唯一，原G pool/TANH8各一次，不能把EXP11bit接口当TANH96bit接口或复制validation_shell storage。

[精确新增控制设计预算](reports/ffn_control_budget.json)：复用现2套descriptor、request/gen/epoch和5bit state（旧20+新12编码）；新增pack_seq16、full1、fault1、cancel_sent1、close_sent1共20bit，payload holding128B单列。A007已实际AT012核CANCEL17增加3bit，局部取消测试通过、完整同版正常仍待最终交付。以已接纳4036B基线，后继父预计4038.875B/向上4039B，余57B；这是待实现重新逐声明核账的设计预算，不是新父实现/物理fit。直接多加Wi/Down两套base/span将增1024bit并超帽，所以本后继是独立FFN island命令，不能称一次Attention命令已覆盖完整Encoder。

G取消固定遵循CANCEL-17，A007唯一写，本任务未碰G文件。Down只在Wi/G成功、成功producer_close后的完整quant/A发布及真实债/lease退休后准入；上游失败实际取消排债，不补缺失输入、不伪造覆盖。首错保留Wi→G→Q8(G)→Down的图顺序。

真实上游仍缺skip保留/严格residual add/LN生产者：norm_ff=无gamma LN(embedding_norm+WO)，最终Down残差回加同一attention_residual。保存norm_ff/G是明确参考边界，不能代签生产Encoder；LN控制未包含现4036B预算。

## 异常、版本和交付边界

首次guard启动因条件表达式else20缺空格在Python解析阶段失败，未取得lock或启动参考child；日志保留，并以整工具调用12.4s作保守费用计入本R004，修复未改oracle/gold。AT001/002/003实际收据、source archives、原始stdout/stderr及owned子进程清理均保留。pilot源SHA d07cc6db...归档；后继仅把audit改为明确审核成本出口下实际1行，未重跑pilot，审计SHA单列，不以修改后源冒充pilot版本。

当前可交付一行精确局部fixture和完整接线/预算；完整128行Q8(G)/Down仍NOT_RUN，因此整FFN数值/周期签署条件未齐。父级同runtimeWi→G→Down、完整Encoder/30层、联合SFU/896DSP/300MHz与U55C均未测。下一步由主控依据实际成本出口集中确定后继，不自动延帽。最终费用、文件身份和实际console状态见[publication.json](reports/publication.json)与[budget.json](reports/budget.json)。
