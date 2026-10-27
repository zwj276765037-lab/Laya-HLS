# E022：实际core资源与setup不通过；一次优化诊断已启动

AT019完整matrix core综合执行PASS，DCP身份保持。AT020报告执行PASS/source_verify_after真/child0/owned清理/锁释放，耗时22565.379247191s、峰RSS23.070541GiB、最低系统可用398.584511GiB。该执行PASS不代表硬件DRC或时序通过。

| Synthesized core资源 | 实际 | 完整核预算 | 器件总量 |
| --- | ---: | ---: | ---: |
| CLB LUT（已含combining） | 2139515 | 900000 | 1303680 |
| FF | 1391977 | 1800000 | 2607360 |
| DSP | 4352 | 7200 | 9024 |
| BRAM36eq | 0 | 1200 | 2016 |
| URAM | 0 | 640 | 960 |

当前core LUT为器件164.11%、完整核预算2.377239倍；本层直接1946767+dot_array137962+format54786=2139515，不将全部本层逻辑归为单一根因。Synthesized setup WNS=-1289.339ns、TNS=-301158.188ns、失败132577/3273333；hold WHS=0.065ns、THS=0、失败0。原最差n_reg[1]/C→error_col_reg[0]/CE有6091级逻辑，DataPath1292.568ns、logic359.024ns、unplaced route估计933.522ns。原工具组件和总量相差0.022ns，照录不猜因。没有placed/routed结果。

DRC为UTLZ-1 Error1、DPIP-2 Warning8192、DPOP-3 Warning4096、DPOP-4 Warning4352、CHECK-2 Advisory48，未关闭或降级资源错误。methodology实际完成，工具elapsed04:19:42/cpu04:28:04；报告显示2000项（TIMING-16 Warning1000、TIMING-18 Warning1000），不是全部timing失败数或新的全局worst。OOC有部分连接检查未运行。最终零blackbox/零latch/1时钟，完整get_ports190017与RTL全部端口位宽相符；check_timing的60880输入/112483输出缺IO delay是子集计数，不能作总接口估计。

旧serial于UTC19:41安全退出：只向精确serial排队TERM/核pending16384/CONT，guard已回收，原工具session返回3（意图暂停），helper返回0；两身份均gone，无新facade。AT023已于UTC20:01:06.360122启动，guard467064/start73450786，Vivado467207/start73451238，原DCP只读打开；无优化结果。

主要证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/port_declaration_accounting.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_launch_audit.json。原报告、baseline timing_finding、日志和全部费用保留原路径。完整top fit、最终setup/hold、平台shell及上板均未验收。




## pre-opt脚本检查失败保留与AT023接续

AT021/AT022均在任何opt调用前因顶层身份API检查FAIL：current_design.NAME实际为checkpoint_core_synth（容器名），checkpoint会话current_fileset.TOP实际为空。两次434.210852844s和455.505928938s费用/冻结源/源码核验/清理均保留，候选无、opt总调用0。这不是硬件或方法失败。当前改为从实际report_utilization标头严格解析并核Design=laya_m007_matrix_engine_v1及Device=完整器件，结合原DCP SHA/dcp.xml绑定；解析已用AT020原报告在Tcl中验证。before同口径utilization直接复用，after边界另存实际utilization，完整端口/时钟/约束与零BB检查保持。新Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5，guard4b6d3135...与canonical421649...不变；无RTL/约束/数值修改。

AT023实际launch为UTC20:01:06.360122，guard467064/start73450786、Vivado467207/start73451238；当前open原DCP，未形成优化结果。


## 优化前实际primitive/完整位接口证据与唯一opt开始

AT023已实际完成before全部身份/边界、资源与有界primitive报告，当前唯一一次opt_design已开始，正执行原生前置DRC。实际util资源逐项等于AT020；190017位端口名字/方向与全部RTL声明机械枚举完全匹配，missing/unexpected均0。直接primitive3910950，raw LUT2241625；g_operand_slot名称组FDRE1048576，raw LUT1058681（LUT3 491520+LUT5 475136+LUT4 49152+LUT2 32825+LUT6 10048）。mul_a/mul_b/trace_commit_data各有raw LUT6 139264。名称归组不是combining后本层LUT1946767或单一源码因果结论，原始有界样例/可用源属性保留。尚无优化后候选/资源结果，未关闭或降级UTLZ。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_before_resource_audit.json，以及reports/before_direct_*、before_ports.tsv和opt_invoked.txt。


---
Published: 2026-10-26T20:15:18.405243+00:00
Publication: Pf0f76556835e4f249b650888d548ed8e
