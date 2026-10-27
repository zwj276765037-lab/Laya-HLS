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

旧serial于UTC19:41安全退出：只向精确serial排队TERM/核pending16384/CONT，guard已回收，原工具session返回3（意图暂停），helper返回0；两身份均gone，无新facade。AT021已于UTC19:41:48.975887启动，guard454976/start73335043，Vivado455129/start73335502，原DCP只读打开；无优化结果。

主要证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/port_declaration_accounting.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/engineering_launch_audit.json。原报告、baseline timing_finding、日志和全部费用保留原路径。完整top fit、最终setup/hold、平台shell及上板均未验收。


---
Published: 2026-10-26T19:43:59.938821+00:00
Publication: Pc8117d1b176340ae86809909747c6a2a
