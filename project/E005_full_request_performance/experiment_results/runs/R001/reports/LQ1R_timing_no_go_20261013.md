# LQ1R有界时序修复停止：两版均未达RTL入口

2026-10-13；M004/SM005/E005/R001；A002。沿D-M004-LNQ-TIMING-01对同一LQ1最终1024元素循环只试两版有据局部`BIND_OP`。两版主机g++/HLS类型模型原16行gold对照与真实单LN HLS生成均PASS，guard child0/trigger null；**两版HLS估计时序均违例，因此static/pilot/rows16 full均NOT_RUN，F9 case5/6亦NOT_RUN**。没有LQ1R动态周期或正常/错误RTL结论；原LQ0及LQ1 AT016的限定结果不回写。

| 同一150MHz/6.667ns目标、1.800ns uncertainty | LQ1 AT015 | LQ1R版1 AT017 | LQ1R版2 AT018 |
| --- | ---: | ---: | ---: |
| F32减/乘绑定请求wrapper latency | 由工具自动/自动 | 4/3 | 5/3 |
| 实际wrapper stage；native FP core `c_latency` | 1/1；0/0 | 5/4；3/2 | 6/4；4/2 |
| 最终循环实际II/估计cycles | 2/2049 | 9/9224 | 10/10249 |
| 临界路径估计 | 53.626ns | 5.298ns | 5.277ns |
| top及受影响算术子模块估计slack | −48.76ns | −0.43ns | −0.41ns |
| 单top BRAM18/DSP/FF/LUT/URAM估计 | 29/18/19804/48104/0 | 29/18/20136/48112/0 | 29/18/20111/48107/0 |
| HLS guard耗时/peak owned RSS | 99.684351s/3143944KiB | 101.160436s/3144228KiB | 100.111604s/3140780KiB |

AT017仅相对AT015源码增加最终循环F32减/乘局部约束。生成的减法与乘法native IP有寄存器，原零延迟组合链已消失；但调度State7把减法末级2.976ns接乘法首级2.322ns，5.298ns仍超有效预算4.867ns。AT018仅把减法绑定请求4→5，乘法与所有源码、时钟/数值/错误/接口保持；生成core latency由3→4、wrapper5→6，证明约束生效，但同点State8仍为2.955+2.322=5.277ns，超预算0.410ns。HLS原警告两版均为`HLS 200-887` fsub→fmul并明确估计clock 5.298/5.277ns；它没有报告可证明一个简单延迟值能够消除跨IP组合段。报表类别`Resource Limitation`与实际II9/10照原记录，不能把II差额唯一归因端口或纯算术依赖。

第二版循环估计10249cycles已回到原LQ0同一循环的HLS估计数值，但这**不是**新RTL周期；第一版9224也非实测。两版均不满足合同所定“寄存器边界生效且top/子模块估计不违例”联合条件，不消耗static/pilot/full成本重复已知的LQ1数值通过。LQ1仍只保留原16行normal的局部周期候选；其目标频率部署、错误回放及完整M003/M004未证。LQ1R方向按两版上界no-go，不提高帽、不扫下一参数、不启动OOC/P&R/上板。主控后续可根据这条明确的减末级→乘首级映射和其它算术候选集中选择新阶段；本报告本身不批准第三版。

原始证据：[AT017 receipt](../attempts/AT017_LQ1R_LN_hls_01/receipt.json)、[AT017 report](../attempts/AT017_LQ1R_LN_hls_01/work/reports/hls_compile.rpt)、[AT017 scheduler](../attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/autopilot.flow.log)、[AT018 receipt](../attempts/AT018_LQ1R_LN_hls_02/receipt.json)、[AT018 manifest](../attempts/AT018_LQ1R_LN_hls_02/input_manifest.json)、[AT018 report](../attempts/AT018_LQ1R_LN_hls_02/work/reports/hls_compile.rpt)、[AT018 scheduler](../attempts/AT018_LQ1R_LN_hls_02/work/hls/.autopilot/db/autopilot.flow.log)、[AT018 verbose schedule](../attempts/AT018_LQ1R_LN_hls_02/work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt)、[LQ0/LQ1动态对照](LQ1_pipeline_comparison_20261013.md)。
