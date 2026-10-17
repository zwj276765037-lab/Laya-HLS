# Encoder→Decision 阶段结果

阶段：encoder_decision_validation_20261009。当前状态 **PARTIAL_ACCEPTED_COST_STOP**：分层 CSim、HLS 及静态结果通过集中验收；完整冷前链和整网 RTL 未完成。GPT-6 Sol / xhigh 执行，GPT-6 Astra / xhigh 设计和集中验收。[权威合同](../../mission/encoder_decision_validation_workflow.md)；[一次集中验收](final_acceptance.md)。

| 项目 | 状态 | 证据/覆盖 |
| --- | --- | --- |
| cpu_full | REUSED_PASS | 3正常S128整图/141点，另1次故障恢复；原身份复用 |
| csim_b2_full | REUSED_PASS | 真实13口B2/S128；47点、9047192 F32、37158 tasks、28+2层 |
| csim_b1_persistent | PASS | `attempts/persistent_csim_01`：真实13口/同一static runtime和BO；B2→gamma故障→B1×2，正常141点/18094384 F32，故障17 tasks/flags9/零logits/AUX完整恢复；exit0，197.22s，峰值1738524KiB |
| frontend_source_package | PASS | `attempts/front_model_check_01`：共享生产 `Controller::frontend` 抽取后新包 build `71532a6b269495506766d83080762740` 严格当前源码检查通过；原 model/numeric/layout 不变，四个非AUX BO哈希不变，AUX仅规范头部build字节80–95变化；四份冻结请求副本仅build字节88–103变化；[逐项身份比较](attempts/front_model_check_01/identity_comparison.json) |
| frontend_full_csim_regression | PASS | 新71532身份真实13口四请求持久CSim `attempts/persistent_csim_front_identity_01`：B2→gamma故障→B1×2，同一static runtime和13 BO；正常141点/18094384 F32逐位通过，故障17 tasks/flags9并恢复；exit0、无guard触发，197.096s/峰值1738684KiB；[编译输入身份复核](attempts/persistent_csim_front_identity_01/postrun_compiled_closure_check.json)通过 |
| frontend_helper_csim | PASS | `attempts/frontend_chain_csim_02`：新71532身份、固定B1_from_b0/S128，同一生产frontend；raw/norm各131072 F32对冻结独立gold逐位通过，17 tasks（8 EMB+1 gamma+8 LN）、3 owner claims、owner/coverage/identity/工作区尾部哨兵及IO不写检查通过；exit0/无guard触发，20.818s/峰值1260096KiB。生产 `owner_leases` 仅计独占原位lease，前链值0；16次读acquire/release为源码路径期望，真实STATE0→LN总线读取待RTL验证。`_01`原通过保留，`_02`仅修正报告措辞后重跑 |
| frontend_thin_hls | HLS_GENERATION_PASS | `attempts/frontend_chain_hls_01`：新71532身份六口 `laya_frontend_chain` 生成RTL/IP且exit0、无guard触发；434.464s/峰值4184840KiB，实际六口数据均32-bit；HLS估计LUT136486/约10%整器件、BRAM81、DSP23、FF39901、时钟4.867ns（目标6.67ns），顶层latency未知；这些不是P&R/实测。生成结构及XSim静态展开见下一行 |
| frontend_thin_static | PASS | `attempts/frontend_chain_hls_01/static_audit.json`逐文件封存190 Verilog、68 DAT、6 FP IP VHDL，核对top→共享frontend→真实EMB/gamma/LN任务、算术、读写及owner调用图；FSM/start有pin reset，runtime标量依赖冷初值、owner RAM依赖DAT，暖reset未验。原TB `compile_01` 及只读LN探针 `compile_02` 静态展开均通过；`run_02` 暴露探针把idle高电平误计为行完成，已受控停止。修正为已接受start→单次ready/done配对后，`attempts/frontend_chain_compile_04` 再展开exit0、无guard触发，167.395s/峰值4647460KiB，生成当前 `frontend_chain_static`；中途停止的`compile_03`证据保留 |
| current_full_hls | HLS_GENERATION_PASS | `attempts/full_hls_01`：fe067完整25TU，exit0；RTL/IP与报告生成；1193.18s，峰值10435308KiB，无guard触发；实际13口32-bit、LUT估计1810065/138% |
| production_connectivity | PARTIAL_STATIC | [80项生成结构审计](attempts/full_hls_01/static_audit.json)通过：13口实际32-bit、28+2控制图、QK/AV真实数值端口与写路径、双residual输入、owner和commit模块；实际producer→consumer数据及AXI响应债务待有限RTL链 |
| full_top_front_chain_pilot | COST_STOP | B2/S128真实完整顶层静态展开[通过](attempts/front_chain_compile_03/guard/guard_result.json)：931.50s/峰值14588352KiB；实际[RTL pilot](attempts/front_chain_run_02/guard/guard_result.json)于235.82s主动成本停止，172032 clocks、7426次AXI总握手、LN输出0B、峰值1746820KiB。相隔93s的样本3214→6308总握手，约33/s；若后续LN写保持此阶段总事务服务速率，仅1MiB LN输出的262144次32-bit写握手就需>7800s。该条件估计触发成本停点，非LN实测吞吐下界；未作数值PASS |
| frontend_thin_rtl_probe_01 | COST_STOP | 首次真实冷RTL `attempts/frontend_chain_run_01` 在1014.660s按无可观测语义进度规则主动停止：raw 524288B完整写出、AUX gamma 1024 F32完整读取、LN从STATE0实际读完首个16384 F32 tile，但norm/observed仍0，首tile读取后AXI总accepted停在577199。峰值896012KiB，guard触发`sigterm_requested`、子进程-9；不是RTL数值FAIL或完整链PASS。`run_02`仅发现新增只读探针误计idle完成，于34.468s受控停止，原日志保留 |
| bounded_production_rtl | COST_STOP | 完整顶层B2前链原COST_STOP保留。共享生产 `Controller::frontend` 的B1/S128薄封装 `attempts/frontend_chain_run_03` 在1584.281s按[两组实际分阶段速率及成本外推](attempts/frontend_chain_run_03/cost_stop.json)主动停止，未加3600s/40M帽；峰值896308KiB、guard `sigterm_requested`、子进程-9，末记18882560周期。raw 524288B真实写完、AUX gamma 1024 F32真实读完、LN实际读取STATE0前三块49152 F32、完成34/128行内算术、STATE1 norm写出131072/524288B（前两块）。两组相隔≥110s的行/写读样本中取较快实测速率，以1548.140s/32行锚点条件外推完成需3686.181s，超墙钟帽86.181s；验收期从另两次相隔110s的采样离线复算3663.279s/3678.996s也条件超帽。这些不是运行时已保存的两次ETA或严格延迟下界。observed仍0、无首个ap_done，未作完整独立norm数值比较、owner末态/首done响应债务检查，故不宣称薄链RTL PASS或功能FAIL |
| frontend_terminal_tb | SOURCE_FIXED_NOT_RECOMPILED | 集中验收发现旧run_03测试台的末态owner/spec/identity断言不全；已在工作 `tb/frontend_chain_mem.c` 按冻结400-word schema补齐，C11严格语法检查通过，验收时工作TB SHA256 `bc5f4c4a12f09abb4c32868003ebc1c468d86dd5b8e024eca2995558c483f9f2`；后续按真实 `ok().bad_element=UINT64_MAX` 将成功期望word5/6修为 `0xffffffff`，当前工作TB SHA256 `bd43eac110bf2ab9813dff89459309cf1a96b0fe753eea693076c64ba0dd27a7`，同样严格C11语法通过。未重编译/运行XSim，旧run_03继续绑定原TB SHA256 `b923f6e7cebafbef4691f3d36f31fe9a4131aea05da52b5a74f479b1eda78ef4`，不增加当前RTL覆盖 |
| encoder_qkv_attention_rtl | NOT_RUN | 真实QKV生产→RoPE→Attention；旧外部预置不覆盖 |
| full_model_rtl | NOT_RUN_COST | 本次 fe067 HLS `compute_one` 每 GS32 组仍为179–199 cycles；B2 Q8单项需527610943072–586561886432 cycles，远超40000000-clock帽；整网RTL数值/协议未运行 |
| physical_platform | NOT_RUN | P&R/Fmax、平台、上板、50ms未验证 |

唯一动态状态在本表维护，stage_results.json仅为同内容机器投影。既有CPU证据见[正式报告](../attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)，B2 CSim见[独立验收](../attention_rtl_repair_20261008/reviewer_d2_c_full_top_csim_review.json)。上一阶段见[四项完成验收](../offline_validation_20261009/type_resumption_final_acceptance.md)，不在旧阶段表登记新运行。

fe067完整HLS、旧身份CPU/CSim及旧四请求CSim保留原运行身份。生产前链等价抽取已形成独立新包；当前新版完整HLS尚未生成，旧完整HLS不能与新薄封装拼接为同一制品。新身份四请求真实top CSim及B1/S128前链helper CSim、薄封装HLS/静态展开均通过；薄封装真实RTL仅形成上述部分连接/算术进度证据，因成本停止而未达到首次完成或数值验收。整网RTL继续保持NOT_RUN_COST，不以局部或CSim冒充整网PASS。

集中验收结论：完整顶层B2及B1/S128薄封装真实RTL均未在现有墙钟帽内完成；薄封装按实测阶段速率条件外推超帽约86秒，另两次相隔110秒的采样在验收期离线复算也条件超帽。未证明完整raw/norm数值、末态owner/spec、末端hold或首次done债务。旧04934完整RTL存在已知缺陷，不能作为fe067或新71532制品；71532新版完整HLS未生成。无上板或50ms结论；整个离线工程仍未完成。详见[集中验收](final_acceptance.md)。
