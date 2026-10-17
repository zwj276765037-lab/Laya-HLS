# 修订14 MUL复位探针的观测口径

2026-10-15；D-M004-ROPE-MUL-OBS-01；A001→A002；M004/SM004/E004/R001。回复 m004-rev14-rope-mul-handshake-observation-question-20261015。

可以采用控制限定的观测，但必须收窄到**具体一次算术操作的来源及退休关系**，不能只取Pipeline活动窗口。原接口确为NonBlocking/rate1、无输入ready，a/b valid常1，ce常1经ce_r成为aclken；“握手”在这里应解释为实际使能采样沿，不能统计原始tvalid脉冲。此答复明确观测定义，不改变叶子/IP、数值或预算，不阻塞正常实现。

主控已核原生成源码。Pipeline `rope_head_rope_head_Pipeline_VITIS_LOOP_25_2.v` SHA `49b16b7bca3734c55ae28382e77476b488a030137dbb982e7cbf250c902fd84b` 的operand mux位于628–653行，结果采样位于471–480行；U7在317–323行绑定ce=1。四次操作的精确调度如下（同时要求本次head有效、pair<32、iter0_reg有效及对应block=0）：

| 操作 | MUL wrapper输入选择阶段 | 输入语义 | 控制器采样结果阶段 |
| --- | --- | --- | --- |
| a | pp0_stage1 | saved_q0 × cosine_q0，即x[i]×cos[i] | stage3 → reg_228 |
| b | pp0_stage5 | saved_q0 × sine_q0，即x[i+32]×sin[i] | stage7 → reg_233 |
| c | pp0_stage12 | saved_load_1_reg_547 × cosine_q0，即x[i+32]×cos[i+32] | stage14 → reg_228 |
| d | pp0_stage16 | saved_load_reg_511 × sine_q0，即x[i]×sin[i+32] | stage18 → reg_233 |

优先只选一个正常、已完成真实装载的head中pair0的a，减少退出迭代/较早数值错误的歧义。其来源须绑定外层真实cmd/row/head/plane/epoch及本次leaf调用，检查实际operand位型来自已加载本head和对应table；不能只按位型相等认定归属，也不计尾部i=32的无效调度。

允许在TB增加只读影子token：在上述有效输入选择的时钟沿，记录U7 din0/din1及ce；下一实际IP使能采样沿核a_tdata/b_tdata确为上一拍din0_buf1/din1_buf1，且aclken=1、a/b_tvalid=1，再计一次本head的物理接受。原wrapper SHA `be5886843494fbbad3b95407aa36bbd637427904b067dfa24e2c0c7727e4d287` 明确有一级输入寄存；不能把stage1选择沿本身直接记为IP接受。影子token只用于观测，不送入DUT、不改变调度或返回。

**必须分开记录两种退休。** 一是该token到达IP r_tdata输出；二是原HLS控制在上述stage3/7/14/18实际采样到reg_228/233。原Tcl SHA `75d6e866fc1a55da3521dc67bd264d9cb043d35948c0d33f52901890e5993326` 配置c_latency=1，输出valid可能持续为1。因此不能把“控制器尚未采样”写成“IP尚未返回”，也不能用未变化的r_tvalid作返回计数。须在已计划的正常短例里用原生成IP仿真配置、使能时钟、输入寄存和一次实际结果/控制采样轨迹标定影子token的输出对应边沿；只根据NUM_STAGE名字或宽泛active窗口推断不足。记录接受前/后与输出/消费的采样相位，避免NBA前后混淆。

严格的“本次MUL IP已接受未返回”复位样本，只有在同一安全reset触发点证明该token已物理接受且尚未到达IP输出时才可签。若一级IP在接受边沿的更新后已经输出，或无法可靠区分对应返回，则不通过同posedge竞态/修改延迟/IP/ce/valid来制造窗口：该严格覆盖保持NOT_RUN（或已观测但证据不足时UNKNOWN）。工程提出的仅记录活动窗口与原始valid方案本身不够。

仍允许在“已物理接受，原HLS尚未消费该token”窗口做一次有价值的局部共同reset隔离探针；明确命名为 **MUL有效操作已接受、HLS结果未采样时的控制隔离**，同时报告IP输出是否已到。它不能代签上述严格IP未返回项。按合同核510拍无旧y/done/可见写/覆盖污染及下一合法局部head完整恢复；不伪称FP内部复位或全链恢复。若两种窗口均无法建立，保留缺口并继续正常链，不扩大成本。

以上均属修订14原帽内的观测澄清，主控未运行EDA。正常叶子/reader/writer和两行主场景继续；无需后续逐步确认，阶段交付按实际采样分别列PASS/NOT_RUN/UNKNOWN。
