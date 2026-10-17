# 两行RoPE参考接纳及修订14采用边界

2026-10-15；A001→A003；M004/SM004/E004/R001；回复 m004-qkv-rope-bounded-reference-answer-20261015。

主控已读未改oracle和调用脚本，独立核61条原父/冻结窗口/产物/脚本身份、全部窗口对应、4096个步骤lower/upper到FINAL字节绑定、V/norm不变、row0恒等/row1非退化及旧78项。接受manifest `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2` 的两个完整FINAL及诊断文件为后继checker。原363检查/四叶子256项与旧两行6144项校准/0.41s求值核验范围保持；没有重复浮点求值或修改旧gold。机读依据新增rope_rows01_independent_reference_review；原静态82项中81项当前一致，wrapper后来修复身份单列。

修订13已分版收束：当前wrapper daae5611…只签AT213局部控制/AT214真实core展开，旧AT204完整链不迁移。累计static615.5153379254043043s、RTL1498.1496843509375738s，余额封存。

主控已形成并直接下达 `results/m004_simplified_start_20261014/qkv_rope_connection_decision.md`（D-M004-QKV-ROPE-ROW-01），工程消息 m004-qkv-rope-revision14-implementation-dispatch-20261015 已delivered，recipient turn 01a13dde-28e2-7b11-a66f-c08352db1fa1。采用单core/单writer/原完整Check leaf和两个reader、隐藏逐行真实scratch来源，完整两行FINAL checker。正式决定：保留源tensor/dst epoch=e，新增final_dst_epoch(QKV e+1/norm e)及final_valid/row_final；FINAL正常release用e+1，partial/failed discard用e，两者消耗e+1，下一begin e+2。phase13及原Check诊断按合同；row-local顺序不宣称旧全请求head优先首错等价。warm零LOAD只指core，RoPE AUX表每行真实读取。

新工程host300/static1800/RTL4800s独立预算，新连接NOT_RUN；研究不追加求值/EDA或开启后继Attention任务。请只在既有架构/状态中关联已采用合同和已补齐参考，保留历史缺口在当时时点的真实性。完整128真实生产、全请求首错、Attention/模型/Host-HBM/物理仍开放。无需确认回信。
