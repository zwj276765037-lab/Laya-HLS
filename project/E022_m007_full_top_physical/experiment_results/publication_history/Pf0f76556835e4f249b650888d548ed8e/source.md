# E022：同版完整matrix core一次优化诊断

SM012/D38；A010唯一工程owner。生产91源/ROM及父11 generic、xcu55c-fsvh2892-2L-e、原3.333333333ns XDC保持。当前只复用AT019完整matrix core DCP（520296664B，SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90）；不是完整parent/top网表。f849 operand表示版沿用已验局部四态桥接，D37原完整30层正常路径证据保持原版本，没有重跑。

AT020已正常结束并完成源码/工具清理/锁核验；旧serial已精确有序退出并回收，未进入facade。AT023_core_opt于UTC2026-10-26 20:01:06.360122实际启动：原DCP→完整边界/约束快照→同口径资源和有界直接primitive统计→唯一常规opt_design→独立core_opt.dcp→边界完全相等检查。后继独立report_core_opt只读候选，报告同口径资源及全局最差/原固定n_reg[1]→error_col_reg[0]/CE各1条setup路径。优化尚未形成结果；当前opt调用标记存在=False。

不改RTL/数值/shape/接口/容量/并发，不加tieoff/case analysis或裁剪cone，不更改频率或保留属性；不自动facade/全父/place/route。core仍>1303680 LUT或>完整核900000预算时按实际资源出口集中审核；达900000也只是必要条件。

完整端口核验已更正为190017标量位=input62860+output127157，逐项计宽等于AT020 get_ports；此前173364是no_input/output_delay计数之和加clk，并非完整接口。优化前后仍按完整名字/方向/时钟/约束精确比较。

沿原单重工具锁、256GiB owned RSS、MemAvailable>192GiB、CPU0–3/nice19/idle/max4线程及300s真实CPU/log/checkpoint停滞保护。implementation/reports无墙钟期限，历史费用及失败全部保留。

协议：[一次优化诊断](../experiment_source/core_opt_diagnostic_protocol.md)；实际冻结源/命令：[AT023](project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_launch_audit.json)。




## checkpoint模式身份检查的实际修复

AT021/AT022均在任何opt调用前因顶层身份API检查FAIL：current_design.NAME实际为checkpoint_core_synth（容器名），checkpoint会话current_fileset.TOP实际为空。两次434.210852844s和455.505928938s费用/冻结源/源码核验/清理均保留，候选无、opt总调用0。这不是硬件或方法失败。当前改为从实际report_utilization标头严格解析并核Design=laya_m007_matrix_engine_v1及Device=完整器件，结合原DCP SHA/dcp.xml绑定；解析已用AT020原报告在Tcl中验证。before同口径utilization直接复用，after边界另存实际utilization，完整端口/时钟/约束与零BB检查保持。新Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5，guard4b6d3135...与canonical421649...不变；无RTL/约束/数值修改。


---
Published: 2026-10-26T20:02:19.332497+00:00
Publication: P2c86e925e0e343c59b98653c920f5f9a
