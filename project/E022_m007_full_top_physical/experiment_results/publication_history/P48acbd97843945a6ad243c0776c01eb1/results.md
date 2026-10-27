# E022：一次opt后核心LUT仍超器件；后时序观察运行

同DCP唯一普通opt_design完成，LUT2139515→2091399，下降48116（2.248921%），仍为器件1303680的160.42%、完整核900000预算的2.323777倍。当前候选core资源明确不通过，不能进入place/route。完整top资源及最终物理时序仍未取得。

| 同口径资源 | 综合core | 一次opt后core | 完整核预算 | 器件总量 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT（已含combining） | 2139515 | 2091399 | 900000 | 1303680 |
| FF | 1391977 | 1391977 | 1800000 | 2607360 |
| DSP | 4352 | 4352 | 7200 | 9024 |
| BRAM36eq | 0 | 0 | 1200 | 2016 |
| URAM | 0 | 0 | 640 | 960 |

AT023执行PASS/child0/source_verify_after真/原DCP未变/工具和guard清理/锁释放；elapsed1992.074475108s、峰16.459915GiB、最低系统可用402.565830GiB。opt_design自身elapsed00:16:11/cpu00:15:04，候选checkpoint已实际保存493065634B、SHA97426945bdf39b3ad1b6e0056583fa5153df570018efb219a017e9a87ca942f3。190017位port与全部RTL声明名字/方向全等，before/after完整port/clock/XDC边界字节相同（SHA12cea865f889597ed55b7bff981f34ac1467ebc52045c093e25d0b10034a6a5a），零BB。该执行PASS不是资源或时序PASS。

before直接primitive3910950、raw LUT2241625；g_operand_slot名称组FDRE1048576，raw LUT1058681（LUT3 491520/LUT5 475136/LUT4 49152/LUT2 32825/LUT6 10048）；mul_a/mul_b/trace_commit_data各raw LUT6 139264。这是有界名称/primitive计数，不等同combining后的本层LUT1946767，也不作全部LUT单因归属。post-opt层级/primitive复开观察待AT024真实报告。

原综合态setup WNS=-1289.339ns、TNS=-301158.188ns、失败132577/3273333；最差n_reg[1]/C→error_col_reg[0]/CE有6091级逻辑，DataPath1292.568ns、logic359.024ns、unplaced route估计933.522ns；组件与总量差0.022ns照录不猜因。原hold WHS0.065ns/THS0/失败0。优化后全局及固定各1条setup观察尚在运行，不沿用原值冒充新测。

AT020报告执行PASS22565.379247s/峰23.070541GiB，DRC实际UTLZ-1 Error1、DPIP-2 Warning8192、DPOP-3 Warning4096、DPOP-4 Warning4352、CHECK-2 Advisory48；methodology TIMING-16/18各Warning1000（报告2000项，不是全部timing失败数）。OOC有部分连接检查未运行；未降级或关闭资源错误。pre-opt API两失败AT021434.210852844s、AT022455.505928938s均保留，不算已执行opt，不当作方法FAIL。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_completion_audit.json、engineering_before_resource_audit.json、reports/after_utilization.rpt、boundary_preserved.txt；project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_opt.identity.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_launch_audit.json。完整top、shell、最终setup/hold与上板性能未验收。


---
Published: 2026-10-26T20:37:39.785848+00:00
Publication: Pbcb96229b6774cfebf240a63c8c6a926
