# LQ1R第一版：注册映射成功，HLS估计仍差0.43ns

2026-10-13；M004/SM005/E005/R001；A002。AT017由AT015的31份冻结源派生，仅最终normalize循环新增`delta` F32减`BIND_OP latency=4`与`norm` F32乘`BIND_OP latency=3`，原II1 pragma及全部数值/错误/存储接口保持。主机g++/HLS类型模型原16行数值对照exit0；HLS生成PASS，guard child0/trigger null，101.160436s、peak3144228KiB。未运行RTL。

实际生成最终循环F32减wrapper为5级、native core `c_latency=3`；F32乘wrapper为4级、native core `c_latency=2`，两者均非旧零延迟组合IP。HLS最终循环pipelined=yes、实际II9、估计9224cycles；单top估计BRAM18 29、DSP18、FF20136、LUT48112、URAM0，top及受影响算术子模块slack均**−0.43ns**。这些是HLS估计，非物理时序/联合资源或实际cycle。

调度原警告`HLS 200-887`与详细State7一致：F32减末级2.976ns紧接F32乘首级2.322ns，形成5.298ns路径；当前有效预算6.667−1.800=4.867ns，故本版不准入static/pilot/full。这个具体剩余路径支持仅将F32减再加一级寄存器约束作第二版有据尝试，检查是否把末级路径压到预算内；不改乘法、数值或错误语义，也不扫其它latency。若第二版仍有估计违例，按两版上界停止本修复方向。

原始证据：[AT017 receipt](../attempts/AT017_LQ1R_LN_hls_01/receipt.json)、[AT017 input manifest](../attempts/AT017_LQ1R_LN_hls_01/input_manifest.json)、[HLS汇总](../attempts/AT017_LQ1R_LN_hls_01/work/reports/hls_compile.rpt)、[调度明细](../attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/layernorm_row_arithmetic_Pipeline_VITIS_LOOP_107_7.verbose.sched.rpt)、[调度警告](../attempts/AT017_LQ1R_LN_hls_01/work/hls/.autopilot/db/autopilot.flow.log)、[减法IP配置](../attempts/AT017_LQ1R_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fsub_32ns_32ns_32_5_full_dsp_1_ip.tcl)、[乘法IP配置](../attempts/AT017_LQ1R_LN_hls_01/work/hls/syn/verilog/laya_layernorm_producer_engine_fmul_32ns_32ns_32_4_max_dsp_1_ip.tcl)。
