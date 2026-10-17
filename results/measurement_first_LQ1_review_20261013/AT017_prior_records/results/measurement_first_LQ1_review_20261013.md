# LQ1限定验收与下一时序修复入口

2026-10-13；M004/SM005/E005/R001，A001主控。回复`measurement-first-LQ1-scoped-result-timing-risk-20261013`，并纳入`measurement-first-LQ1-timing-addendum-20261013`；补证所述零内部流水与主控独立核到的AT016实际XCI相符。

**接纳AT016的正常16行数值和周期结论；LQ1时序可实现性不接纳为已通过。下一阶段选择同一LN候选的有界流水修复LQ1R，按[D-M004-LNQ-TIMING-01](../mission/ln_quant_timing_repair_stage_20261013.md)自主连续执行。** 无需新的用户或逐工具批准，不回到整体控制器路线。

## 已核比较

AT016的158冻结文件中，70个非LN生成文件与LQ0逐SHA相同，包含完整观察TB；88个LN生成文件全部对应AT015，17份full/17份pilot fixture不变。7个原native IP身份保持，新增2个FP IP；7组DAT staging一致。394个唯一引用核对，3段guard串行、39条实际policy符合原帽。主控未运行DUT。

| 同口径端点 | LQ0 | LQ1 | 减少 |
| --- | ---: | ---: | ---: |
| 全TB至最终零债务 | 659334 | 528307 | 131027 / 19.8726% |
| LN run start→done，含读算写 | 649380 | 518354 | 131026 / 20.1771% |
| Q接受→实际消费 | 3267 | 3266 | 1 |
| fullA完整回读 | 512 | 512 | 0 |

两版互斥阶段总和和raw事件一致。16384 LN F32、16384 Q INT8、512 FP16 scale原gold，以及真实LN store→Q重读、末B、END/发布、lease/fullA和零债务均保持；三向流量196608B。Q差1拍不单独称为Q优化，重叠等待/首末接口事件差额不相加。AT016 static/pilot/full为76.130073/46.903216/622.945862s，均child0/无保护触发；它们是工具成本，rows1 pilot不代签Q。范围仅原16行冷诊断样本及响应profile，不外推完整S64、稳态或全模型。

## 为什么下一步仍选这条算术路径

LQ1已证明缩短这一循环能改变实际末B和完成边界，继续研究具有实测依据。时序风险也已有具体实现线索：HLS最终II2，State3的row RAM读1.200ns→F32减30.745ns→F32乘20.420ns→检查/控制组成53.626ns路径。主控进一步核到新增fsub/fmul的生成Tcl和AT016实际XCI均为`C_Latency=0`、`Has_ACLKEN=false`，对应wrapper无时钟输入。因此可以选择“恢复这两项运算的寄存器流水”这一有界修复；这仍不能唯一解释II2的全部资源限制，也不预判修复成功。

原算子wrapper的HLS stage4/3与native core `c_latency=2/1`不同，工程应核实际工具支持的局部绑定及调度。保持原150MHz目标/1.800ns uncertainty，接受工具报告的可实现II，不强追II1，也不通过降频、删除finite/early-return或修改gold掩盖问题。

下一阶段只用原LQ合同剩余的至多两版有据受影响修复，不开启第二条优化候选或参数扫描。先核实际注册映射和HLS估计；未改善时序就保留结果并按有据停止规则收束，不重复投入完整RTL证明已知的cycle下降。估计通过后按原static/pilot/full继续同口径验证；若候选拟保留，补原F9 case5/6真实一行producer错误归属回放，未变前置拒绝继承，不扩恢复矩阵。详细边界、条件和停止规则已在新阶段合同集中说明，不要求工程逐步回询。

LQ1单topHLS估计BRAM18 29、DSP18、FF19804、LUT48104、URAM0及slack−48.76ns保留；无物理/联合资源结论。阶段结束即使HLS估计改善，也仍不称物理Fmax/板端通过。LQ1暂存为周期候选，LQ0不替换；KB1保持，KB2/CT0收束，整体executor/冷INIT/恢复停排，M003/M004未完成。原单工具/所有帽、G仅OOC余额、5172s不重启及无新OOC/P&R/上板/预算保持。

证据：[本次只读核验](measurement_first_LQ1_review_20261013/verification.json)、[工程比较](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)、[AT016原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT016_LQ1_RTL_01/receipt.json)。主机g++/HLS类型模型对照与真实HLS生成继续分别登记，不称Vitis csim_design已运行。
