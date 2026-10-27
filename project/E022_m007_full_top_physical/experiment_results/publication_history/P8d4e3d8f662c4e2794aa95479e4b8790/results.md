# E022 当前core资源异常与阶段持留

AT019真实core_synth PASS，elapsed 50108.013762 s，峰owned RSS172.063992GiB；520296664字节core DCP SHA a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90，只是matrix core、非完整kernel。AT020已完成util/hier/ram/clocks，Synthesized CLB LUT2139515（164.11%器件/2.377239倍完整核900000预算），FF1391977、DSP4352、BRAM/URAM0；LUT已经计combining。原层级直接逻辑1946767 LUT占90.991%，dot_array137962、format54786，不能凭BRAM0推断具体buffer根因。当前综合态资源门槛不通过，opt后资源变化仍待实际测量。UTC2026-10-26T13:51:25.492336Z仅对轻量serial3603650/start66216629发pidfd SIGSTOP，实际T；AT020 guard109263/start71064760和wrapper109276/start71064911独立session运行，没有收到信号。旧serial state保留历史running_report_core快照，独立hold_receipt记录实际持留。当前AT020处check_timing，不设deadline，trigger=null。SM012末节已授权本报告正常完成后安全退出旧serial，同SHA完整DCP一次常规opt_design，新attempt/另存候选及前后资源/primitive有界分组；不重综合/功能、不改RTL/端口/cone/时钟，不自动facade/全父/place。若opt后>器件或>900000分别集中出口。E022由A010唯一发布，root保留两小时用户通知。

AT020已实际完成Synthesized timing_summary及setup/hold各50路径报告：WNS=-1289.339ns、TNS=-301158.188ns，setup失败132577/3273333；WHS=0.065ns、THS=0、hold失败0，core周期报告3.333ns。最差n_reg[1]/C→error_col_reg[0]/CE，6091逻辑级，DataPath1292.568ns，其中logic359.024ns、工具unplaced route估计933.522ns。当前core综合态300MHz约束不通过；没有placed/routed时序结果，不能冒称最终route失败或只差报告。no_clock/unconstrained_internal_endpoints/loops均0，60880输入和112483输出未加shell I/O delay。路径报告-nets弃用各报一条critical warning，保留原日志。当前继续drc，无deadline/trigger=null，serial仍T；后继仅既定同DCP一次opt资源诊断，RTL不改。

---
Published: 2026-10-26T14:46:02.325112+00:00
Publication: P97b7b03772444c5fa1e806044e2e90c0
