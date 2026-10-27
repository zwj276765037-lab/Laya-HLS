# E022：同版完整matrix core一次优化诊断已完成

A010 / M007 / SM012 / D38。工程诊断已完成；完整top物理任务因优化后core超器件容量而阻塞，等待主控集中架构/映射判断。没有自动full-parent/facade/place/route后继。

适用版本：生产matrix engine f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd，91源/ROM闭包、父11 generic、xcu55c-fsvh2892-2L-e、原300MHz XDC（文件周期3.333333333ns，工具报告3.333ns）保持。D37原完整30层正常功能保留其原源码身份；本f849 operand表示版沿用已验局部四态桥接，未重跑完整功能，也不把优化网表或边界检查当新功能PASS。当前DCP是完整matrix core子树，不是完整parent/kernel。

原core_synth.dcp520296664B，SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90。AT020报告正常完成并核源码/清理。旧serial已按已测原handler精确排队TERM、核pending16384、CONT并回收，原工具session exit3为意图暂停；无facade。AT021/022均在任何opt调用前因checkpoint对象身份API误用失败，费用/冻结源/原件保留。实读container NAME=checkpoint_core_synth，fileset.TOP为空；AT023改用真实utilization的Design/Device标头严格核当前网表，结合SHA绑定dcp.xml，实际验证通过。

仅AT023调用一次普通opt_design，无directive搜索/UTLZ降级。执行PASS，另存core_opt.dcp493065634B，SHA97426945bdf39b3ad1b6e0056583fa5153df570018efb219a017e9a87ca942f3。190017位port名字/方向与全部RTL声明机械枚举全等；before/after及AT024复开的完整port/clock/导出XDC边界字节相等、零BB，原DCP未变。实际Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5、诊断guard4b6d3135ba5696cc2c9b1afb50fe925317aaac03a967c017bedf20fa2fb5168d，canonical421649...未改；AT023/024均有实际冻结版本与来源。

AT024只读复开候选完成util/hierarchy/ram/clocks、bounded直接primitive名称归组、全局最差和原n_reg[1]→error_col_reg[0]/CE固定setup路径各1条。固定对象/路径均实际存在；两条结果相同。仅此bounded setup观察，没有post-opt全TNS/hold/placed/routed覆盖。

未改RTL/数值/shape/接口/容量/并发/时钟/保留属性，未加tieoff/case analysis或裁剪cone。全项目单锁、256GiB owned RSS、系统可用>192GiB、CPU0–3/nice19/idle/max4线程、300s真实CPU/log/checkpoint停滞保护保持；物理墙钟null/disabled，全部历史费用不清零。所有本轮owned工具/guard/serial已退出，锁释放。

复现协议：[core_opt_diagnostic_protocol.md](core_opt_diagnostic_protocol.md)。最终收据：project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_engineering_receipt.json；清理/状态：core_opt_diagnostic_final_state.json。源码、raw报告与每attempt失败/成功记录均在原路径，不搬移或覆盖。


---
Published: 2026-10-26T20:59:14.009870+00:00
Publication: P1da0aeb88e96456e9da255967d19a2cd
