# 当前完整生产图与验证设计

2026-10-09，GPT-6 Astra / xhigh。执行和数值/资源规则以[阶段合同](../../../mission/encoder_decision_validation_workflow.md)为准。

原规格位于 [00_overall_design.md](../../../vivado/design_source/00_overall_design.md)，统一规格v1.0/2026-10-05；2026-10-09已核查§1 CPU/FPGA职责、§3真实维度和§4完整前向连接。该文档的历史“尚未实现”不覆盖当前已有证据。共同接口和逐算子数值继续沿用[规格入口](../../../hardware_agent/spec.md)及[修复合同](../../attention_rtl_repair_20261008/repair_contract.md)§2–§4、§7。已读真实实现为 `hls/platform/full_kernel_wrapper.cpp`、`hls/control/full_forward_controller.cpp` 和标准libm CSim TB。

生产入口为真实13口 `laya_typed_q8_forward`，static FullRuntime调用 `full_forward_ports`；端口为 embedding、io、w_q0、w_q1、w_scale、aux、state0、state1、qkv0、qkv1、ff0、ff1、att_out。生成后的实际位宽另核，源码max_widen_bitwidth=512不是实测位宽。

连接顺序：EMB_TOKEN→LN_EMB→28 Encoder（LN_ATTN，layer0例外；Q8 QKV→双shard/RoPE→KV→QK→Softmax→AV→WO/residual→LN_FFN→WI/GEGLU/DOWN/residual）→LN_FINAL→EMB_TYPE/ADD_TYPE→2 Decision（LN/QKV/无RoPEAttention/WO/residual/LN/FC1/RELU/FC2/residual）→marker gather/LN→Scorer Q8 FC1/bias/GELU/FP FC2/mask→candidate softmax/stats→hidden+stats concat→FP ACT FC1/bias/GELU/Q8 ACT FC2→结果commit。

完整图是本阶段验证目标。[集中验收](../final_acceptance.md)确认fe067完整HLS与新71532前链薄封装HLS、真实13口四请求持久CSim及helper CSim的各自范围；动态状态见唯一[阶段表](../stage_results.md)。薄封装真实RTL按成本停止，未到完整前链或整网成功路径；静态模块、byte地址与owner映射不能替代动态数值和响应债务。

有限RTL链必须保留声明范围内的真实producer→publication→consumer，输入/中间值/输出边界及缺失上游清楚标注；不得以外部预置QKV等同完整Encoder连接。完整RTL只有原始请求和权重驱动完整28+2层、独立结果和协议均通过才成立。

## 当前 fe067 生成映射（Sol 实际核查，尚非动态 RTL 验收）

[顶层RTL](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward.v)实例化 `full_execute_request`；该模块实例化真实 `graph` 和 `full_write_result`。[graph报告](../attempts/full_hls_01/work/hls/syn/report/p_anonymous_namespace_graph_csynth.rpt)保留Encoder 0–28与Decision 0–2两个循环；[graph RTL](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_p_anonymous_namespace_graph.v)实例化embedding、attention、residual、type_add、gather、candidate probability/stats及act concat子模块。这证明模块处于本次硬件层级，实际整网成功数值仍待RTL运行。

已知旧04934 QK/AV异常的针对性映射：本次[attention RTL](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_p_anonymous_namespace_attention.v)含QK/AV task issue；其[QK task RTL](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_full_run_task_20.v)确实实例化[qk_row](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_qk_row.v)，有q/k/mask输入、score写端口和浮点算术服务端口；[AV task RTL](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_full_run_task_22.v)实例化[av_row](../attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward_av_row.v)，有prob/v输入与partial输出，并将结果写入ATT_OUT。这已排除“生成任务完全缺少QK/AV数值端口”的旧症状；正式成功路径与结果需独立动态RTL核对。

生产byte地址由[内存映射](../../../hls/common/laya_memory_map.cpp)与[完整f32访问](../../../hls/common/laya_full_memory.cpp)提供：HIDDEN在STATE0/1的0–8MiB，NORM为STATE0的8–16MiB，TMP为STATE1的8–16MiB，QKV双shard分别QKV0/1 0–12MiB，WI/DEC_FF用FF0，GATE用FF1，ATT_OUT独立8MiB，TYPE_ROWS在STATE0的16908288B，scorer/ACT各region在STATE1的16777216B之后；QKV按plane/batch/local_head/1024物理token/64d取址。输出地址仍需结合owner epoch和实际任务核验，不把源码映射独自当作动态总线证明。

[控制器](../../../hls/control/full_forward_controller.cpp)在每段生产后进行claim/cover/publish、bind/acquire/release；QKV双shard及RoPE前后pair由[owner例程](../../../hls/common/laya_full_owner.cpp)管理。两个Encoder residual和两个Decision residual的 `src0=TMP`、`src1=HIDDEN`由控制器传入真实[VectorTask](../../../hls/operators/full_tasks_vector.cpp)并分别读取；scorer原位lease与commit后接候选统计和ACT，最终由[commit源码](../../../hls/control/full_result.cpp)先写数据/诊断再写128B header。这是源码到生成层级的映射，后继有限RTL链仍需实际检验producer→publication→consumer。

[RTL生成日志](../attempts/full_hls_01/guard/driver.log)标明 `runtime_session_generation` 和 `last_accepted_request_id` 为power-on initialization。冷启动静态来源可确认；暖复位/请求间状态清债尚无完整top RTL动态通过证据。CSim持久会话只证明软件执行合同。

持久13口CSim使用原CPU序列：B2 id1→gamma故障id2→B1_from_b0 id3→B1_from_b1 id4，同static runtime/BO且无reset。独立gold为 `d2_cpu_full_official/oracle`，输入为 `d2_cpu_full_official/dut/inputs`；DUT dump不能充当gold。原CPU runner中故障只改内存AUX的emb_norm_w首F32为+Inf，再精确恢复，原文件不写。三正常请求共141检查点；B2为37158 tasks和1924 Q8/QUANT tiles，每B1为18895 tasks和962 tiles。CSim真实top序列是新增覆盖，必须重新执行序列的B2首请求；不为旧B2独立用例重复建立验收。

## 已核定前端生产链入口

见[阶段合同的薄封装补充](../../../mission/encoder_decision_validation_workflow.md#完整前端生产链薄封装补充2026-10-09astra--xhigh)。首例固定B1_from_b0/S128全128行、hidden1024：真实parse→共享Controller::frontend→8 EMB_TOKEN→gamma load→8 LN_EMB，共17退休，两检查点各131072 F32。原Controller graph前段语句按原序抽取为共享helper，完整graph也必须调用它，测试top不复制glue。新top只含embedding/io/aux/state0/state1五生产BO＋独立observed；所有owner、地址、数值和任务路径复用生产实现。

这是最小验证入口/函数边界调整；完整核外部13口ABI不改。Controller源码参与model package build_preimage，因此已新建模型包/build tag和等payload请求身份副本，并以原独立gold回归真实13口四请求持久CSim141点。旧fe067完整HLS/CSim/XSim冻结为抽取前身份，不能冒充新helper的完整硬件。新薄封装即使完整通过也最多关闭原始请求/embedding→完整LN_EMB生产前段，Encoder QKV及后续整网仍未覆盖。冷启动限定，无新增暖reset或性能/物理资源结论。实际函数/文件映射与观测schema见下段；不另建放行包。

实际共享路径为[Controller::frontend](../../../hls/control/full_forward_controller.cpp)和[薄封装入口](../../../hls/platform/full_frontend_wrapper.cpp)，观察字段固定于[400-word schema](../../../include/laya_frontend_observed.h)。新包build为`71532a6b269495506766d83080762740`；新身份完整四请求CSim与B1/S128 helper CSim均已通过。薄封装[生成结构审计](../attempts/frontend_chain_hls_01/static_audit.json)追到真实EMB、gamma、LN、owner及读写路径，XSim静态展开通过；六口实际数据位宽均32-bit。真实[run_03](../attempts/frontend_chain_run_03/cost_stop.json)在34/128行算术及两块norm写出后成本停止，未到首次done、完整数值或owner末态。工作TB已补齐冻结schema内末态spec/identity断言，但旧run_03绑定原TB且未使用该修复；详见[集中验收](../final_acceptance.md)。
