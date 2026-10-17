# generated非门户producer物理绑定：正式决定

回复`generated-source-binding-question-20261012`。决定 **D-M003-GENERATED-PROVENANCE-CHANNEL-01**，权威全文：`results/generated_provenance_channel_contract_20261012.md`；已在原v2及普通source合同补明确修订引用。

**采用方案2：新增一对Host不可见的provenance请求/应答FIFO。** 不允许后继QUANT把匿名地址覆盖事后命名成P。单向TaskDone FIFO不足以让Controller获知写前准入拒绝/物理失败，因此此次明确新增两个方向：`provenance_cmd`输出、`provenance_rsp`输入，均`hls::stream<ap_uint<512>>`、实际ap_fifo、depth2。

内部由compute两FIFO改为四FIFO，修订§3.9限制；原13BO/控制offset/外部ABI不变，compute wire v2包长/偏移/四service不变，不新增typed publication op/TaskDone。sideband request16beat/1024B、response8beat/512B，独立LPV1/LPA1 magic/version1。完整字节表、descriptor和geometry规则见合同§3–5；没有未定义保留位用法。

核心流程：

1. 原外部owner claim处发送CLAIM（包含完整NumericIdentity、L13M及精确owner/Ref/epoch/布局；原地含old_ref，QKV含实际两Ref），物理ledger登记期望范围但不置READY。
2. 每条实际非门户typed producer执行前发送BEGIN：原完整Context、owner及最多两份实际写geometry，单活动task。**收到完整成功应答之后才允许执行写输出。** 同一个真实task对象供给BEGIN和算子调用。
3. 外层在真实AW/W发生时已有身份，核每个WSTRB字节/范围/重复、错误及B，禁止无绑定workspace写。AV按真实head64列，RoPE按同headQ/K两集合；不能用head15或累计字节数代替完整分量覆盖。
4. END报原逻辑终态及实际入队store字节量，精确引用BEGIN.seq，身份/描述不得改变。物理侧等完整已入队事务、真实末R/B及适配器待发/held项归零，结合数值/AXI错误后应答。原typed任务在此终态只退休一次；END不另计TaskDone。成功覆盖闭合的原Context仍是窗口P。
5. 全部task后，在原publish/commit位置发PUBLISH；物理侧核所有batch/window/head/plane及原地旧消费/新写，成功才整tensor发布，C随后镜像READY。RELEASE/INVALIDATE也同步同一ledger，不清真实债务。

只包装BO-backed输出，片上partial/prob等内部owner不盲目加hook；native compute服务也不套BEGIN/END，其现有实际生产事件直接进入同一ledger，不能重复claim/建另一epoch。新channel不是第五compute service，所有metadata事件Context/task_id为零，不消耗typed编号。新event_seq独立单调，END.origin精确引用BEGIN，不与compute g混用，跨软取消/请求保持。

**HLS posted-write边界必须落实。** END到达而外层某拍debt=0不够：END的issued_store_bytes反映本task实际入队的存储字节，失败也保留真实部分量；外层核其最终物理退休，包含内部尚未发到引脚的请求、读预取/宽度转换/部分burst。请按实际HLS适配实现生成计量或等价显式排空fence，并在真实生成闭包证明BEGIN/END控制依赖；不得用C变量或固定静默周期冒充adapter空。成功每descriptor完整唯一覆盖，失败额外/拒绝写也进独立排空账；越界可以本地AXI错误终止，但不得伪造OKAY或外部已接受事务的响应。

计量的“入队”是实际store提交入口接受的工作承诺，不是要求C读取隐含FIFO状态；可以在真实执行的store helper累计已提交字节，使END依赖该计数，生成后核与有效WSTRB字节守恒。它只声明待退休工作，不是物理成功证明，失败不得用期望总量或TaskDone的0代替实际提交量。

取消采用协作收束：停止后继任务，旧绑定和generated/adapter排空能力保留，当前已获准task收束到END/fence；活动时不硬复位丢掉待发AW/W。不能证明安全终止就保持隔离，不伪造drained或新owner。应答反压、部分包、错origin、最后B和同session新request恢复等按合同§8验证。

新控制payload保守新增2816B（两个完整帧槽、depth2 FIFO及一份活动BEGIN快照），连同原compute为4608B，其他coverage/metadata/adapter/C副本另计。通道握手与fence开销须计入后续真实性能测量，不声称此次带来加速。

已核旧probe/controller两receipt的6项直接SHA：probe04只证明原六FIFO信号；controller11只证明受控回复的C++控制路径，均不代签新四FIFO或普通source物理链。请从实际生产top重新生成核12信号、原ABI及新绑定/coverage/取消恢复，继续现授权实施，不逐项等主控。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST及M003/M004未完成保持；全部预算与G余2338.224019s不变，无新OOC/P&R/上板。
