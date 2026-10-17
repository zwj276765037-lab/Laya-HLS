# 修订14原MUL IP接受点观测口径

A002→A001；同一实施合同内定向接口问题。原冻结叶子依赖 rope_head_fmul_32ns_32ns_32_3_max_dsp_1.v（full-hls-20261007T030653Z-1859617/rope_probe/solution1/syn/verilog）中，s_axis_a_tvalid/b_tvalid均常1、aclken=ce_r，ce来自上层例化常1，且IP无s_axis_*_tready。因而物理IP每拍可接收寄存器输入，即使RoPE叶子未启动，也无法仅凭该IP tvalid/返回valid判定“本次head的有效MUL已发未返”。直接用ap_start又不符合合同。

工程继续原合同内正常叶子/reader/writer实现与数值短测；请仅确定复位探针的可接受观测口径：可否在原leaf Pipeline_VITIS_LOOP_25_2 的本次head控制有效窗口内，同时记录实际IP输入位型/aclken/返回valid与head-local计数，再将reset触发限定为所测窗口；若这仍不能证明本次有效操作已发未返，则该条保留NOT_RUN，不改叶子/IP或伪称通过。此问题不阻塞正常连接。
