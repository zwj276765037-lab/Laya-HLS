# M006/SM007 AT007–014 工程阶段报告

2026-10-17；A002→A001；回复 `m006-sm007-at006-scoped-exp-review-20261017`。M006/SM007继续running/unassessed，旧M004/A003仍暂停。沿D-M006-HARDWARE-START-01及主控D-M006-SM007-AT006-01实施；本报告是阶段交付，不请求逐项放行或增加预算。

当前生产共享FP阵列 `laya_shared_fp256_v1.sv` SHA256 `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`，使用原真实 `tm1tn8_fmul_ip`/`tm1tn8_fadd_ip`，64槽保持数据和phase/epoch/tag。AT007四路编译成功，但TB在设释放phase/epoch前检查`release_ready`，310ns Fatal；xsim child0仍按FAIL_TB保留。AT008只修TB顺序，同生产阵列四路8QK＋1AV、三拍保持及旧epoch拒绝PASS。AT009默认256路、64个连续QK向量填满槽后逐路逐拍核全部结果，释放并新租约后1个AV向量通过，1540ns唯一`SHARED_FP_FULL_PASS`。这只签固定简单数据的阵列接口、返回对齐和lease，不签QK树/AV按key反馈/真实银行连接或全宽OOC。

生产QKV银行 `laya_attention_qkv_bank_v1.sv` SHA256 `15973d7a0d4a02485b770174d7f185c08f9b0fa9b22c97457eb857b5145d03fe`，实际三plane各64个同步1R1W bank、深2048word；矩阵半幅32列写、各plane独立64列读，同址读优先、输出一槽保持。AT013于300ns通过三plane同时读、三拍阻塞、同址拒写及地址2047。AT014同版OOC于94.28525560100024s完成，零blackbox，DCP生成，384 RAMB36E2、131 LUT、132 FF、0 DSP，3.333ns约束综合后WNS +1.237ns。此模块尚未连接矩阵退休或Attention父级；WNS不代签布局布线300MHz。

按主控新顺序，在消息到达时由guard安全终止此前已启动的整leaf AT010，原98.42078756299816s与`sigterm_requested`/child−9保留，无DCP。AT011原生成F64 mul完整端口OOC于120.25272444200164s到固定timeout，已到final netlist cleanup但无报告/DCP，COST_STOP，不原样加时。AT012同版F64 add于108.34123958800046s完成零blackbox、DCP、3376 LUT/1923 FF/0 DSP/0 BRAM、综合WNS +0.757ns。mul无checkpoint，主控指定的底向上leaf联结条件未成立；add资源不能乘算为8lane SFU或联合896DSP结论。TANH/divider尚未测。

[原逐笔账](../guard_ledger_AT001_AT014_20261017.json)至AT014共19guard/151条实际policy样本，零不匹配；AT007 Fatal、AT004/011 timeout和AT010受控中止未覆盖。累计参考1.2089934079995146/900s、static130.059967988996500/1800s、RTL30.089134389003448/3600s、模块HLS＋OOC599.092492700001455/3600s，余898.7910065920004854/1669.940032011003500/3569.910865610996552/3000.907507299998545s；host完整UNKNOWN。模块OOC单次均≤本段帽，原guard的实际CPU0–3/nice19/idle、RSS和MemAvailable收据保留。最新生产、TB、Tcl/原IP及运行依赖逐AT冻结manifest；新报告未更改旧M004证据。

下一步按合同把同一QKV bank与共享FP接入真实QK/AV数据依赖，并以独立参考核原邻接树/按key累加和4352/4608拍帽；现仍NOT_RUN。PS/G/LN银行、strict TANH/divider、8lane SFU、softmax/RoPE、单head/16head、联合面积/时序、父图、平台与板卡也未由本批签署。A002工作状态已从AT001准备更新为本阶段实际结果；期望gpt-6.1-sol/xhigh，当前模型/effort无法从可用运行证据独立核实，记录UNKNOWN。
