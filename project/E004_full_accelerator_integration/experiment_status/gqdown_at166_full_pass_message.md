# SM004修订10 AT166同版完整冷/暖数值通过

AT166冻结源码`laya_lnq_wi_gqdown_row_v1.sv` SHA `3a749c8981e833b75a0645f92bb84546158551735758c35870847838010ddcf1`，双槽真实AXI冷LOAD、真实前LN row0→Wi→canonical G→同一Q直接82组→Down。原独立同输入参考逐位核LN1024、Wi32组Q/scale和20992 PS、G2624、Down82组Q/scale和10496 PS，以及最终1024 F32。真实G发射输入逐项核保存Wi值，边界gate tile511/512/655均过。冷命令消费者done cycle178317，暖命令cycle291678；每命令20992+10496 W读/返回、PS与issue守恒。冷/暖累计AR均为Wi q0/q1/scale 656/656/82、Down 328/328/41、AUX2，暖未新增LOAD AR。原日志`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT166_SM004_down_ret_pair_index_full_01/guard_rtl/driver.log`，源与fixture SHA在同attempt `source_manifest.json`；guard child0/null、1261.580029s、峰owned RSS967920KiB。语义为**PASS_SCOPED_FULL_LNQ_WI_G_Q_DOWN_COLD_WARM**, 仅本测试端点和冻结SHA。

AT163第1472项G失败由gate地址9位加法在512回绕；AT164原G核心保存Wi输入2624项独立PASS；AT165修复gate读址后G全行PASS，但Down slot1单tile返回被误按slot下标读取而失败；AT166改为ret_q[0]/ret_scale[0]后全链通过。旧FAIL与全部费用保留，不追认为PASS。

尚未覆盖真实Wi数值bad/poison映射、错误后完整暖行、顶层真实在途共同reset，以及刻意的AR/R/内部有限反压与重复读/释放竞争；本段剩余RTL约1113s，工程继续按原合同在帽内做定向短测，成本不足的长场景保留缺口，不扩大额度或启动OOC。完整图、末残差、联合物理仍开放。具体计量和文档阶段末集中更新。
