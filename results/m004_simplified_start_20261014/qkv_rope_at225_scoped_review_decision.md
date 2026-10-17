# AT225 两行正常链限定接纳与受影响控制修正

2026-10-15；A001→A002；M004/SM004/E004/R001。决定 D-M004-REV14-AT225-REVIEW-01，回复 m004-rev14-at225-two-row-main-progress-20261015。按[修订14合同](qkv_rope_connection_decision.md)继续普通修复和受影响短回归，无新预算、无逐步放行；本决定不收束修订14。

## 接纳的冻结范围

主控已核 AT225 的143项 manifest 身份、9份原始产物、24条实际政策采样，全部一致；原30份QKV和23份FFN fixture与AT204保持，新增两行FINAL文本解码与冻结独立派生参考逐字一致，cos/sin与原AUX s0/s1窗口一致。证据存于[机读审核](lnq_review_evidence_20261015.json)字段 revision14_at225_normal_rows_review。

仅对 AT225 wrapper `b131526237fa63c52603b8a4c3ce4fbc4b0e52f70ed0418d8e3f5214a4de9c38`、adapter `a80564dee57a8e07bcb4af2ddd758efe6012f7af92c188e5135bd00a493582e0`及冻结依赖，接纳 **PASS_SCOPED_QKV_SCRATCH_ROPE_ROWS01_NORMAL**。同runtime真实row0 cold→row1 warm，原LN/norm、Q/scale、PS六字段和pre-QKV完整checker通过；真实RAW写入的内存再供RoPE读取，64head/256个scratch R/64个AUX R，512笔RAW与256笔RoPE写响应共768笔B。两行4096个Q/K FINAL全量逐位匹配，V和norm各行实际内存字节不变。每行完成、末head B有限保持屏障、仅两位RAW/FINAL覆盖及不发布完整tensor、partial discard后last_released_epoch=2均有原证据。

原guard为child0/trigger null，RTL791.7965642139316s、峰981884KiB；唯一ROPE_QKV_ROWS_REAL_PASS，无Fatal/Error。111837/195897是全局done事件cycle，不是命令相对latency或Fmax。冷W加载与warm零新增的范围不包括独立RoPE表读取。AT220/221 timeout、AT222 TB ready失败及其他历史终态不改。

覆盖边界须随记录保持：

- 每head code和输出覆盖参与控制；TB完整定义的Check字段只在每行最后head显式断言，不能说64head完整Check各字段均已独立核对。
- 主场景使用两行紧凑逻辑内存，在成功B记入实际写值并供scratch读；接受事务的地址/数据/strb精确检查成立。没有完整BO/邻域哨兵模型，也没有row1结束后重扫row0，因此不签物理域或独立邻行保护覆盖。
- AW先/W先只有全局flag；未签三目的各自两种顺序，也未监测新增scratch AR/AW/W受阻时全部字段逐拍稳定。原W/shared AUX AR保持与已命中的有限阻塞按其原范围保留。
- 本例head基址256B对齐、ARLEN3，未测合法64B偏移下4KiB分段。discard后打印next_epoch=3没有真实下一begin3，不代签再入。
- 全128真实生产、异常首错、错误/reset恢复、完整请求发布、Attention/整图及Host/HBM/联合物理仍开放。

## 两项原合同内控制修复

### 1. RoPE行内遍历次序

AT225冻结wrapper约250–254行以 `plane=rope_head_index[4]`、`head=rope_head_index[3:0]`、`route=rope_head_index[0]`解码，实际遍历全部Q head0..15后再全部K head0..15。约957–967行诊断也采用该编码。合同要求head0 Q,K；head1 Q,K；…；此差异不否定正常值，但影响行内首先遇错。

请作最小一致修正。可令head=index[4:1]、plane=index[0]、route=head[0]，同步核地址、写路由、读/写计数、Check head/plane及bad映射、TB预期顺序；不能只改诊断标签。原数值和FINAL布局不变。使用生产wrapper/reader/leaf/writer加合法局部行peer验证实际顺序及两个坏输入的区分例：K/head0与Q/head1同时存在数值错误时，应先报告K/head0；保存raw Check及映射位置，并核停止后续head、真实排空、一次完成/隐藏失败。局部正常例覆盖全部Q/K head的地址/值和完整Check字段，不冒充真实LN/QKV producer。

### 2. AUX旧错误与新load接受记账

原 `t4_aux_bias_reader_v1.load_error` 在失败load后保持，直到下一次真实load_valid&&load_ready才清除。AT225 wrapper的R_TABLE_LOAD优先检查 `!rope_table_address_ok || table_reader_error`，随后else-if才记录load接受。新合法命令可能在旧error仍高的同沿实际接受新load，却进入R_ERR且未置table_load_active；既会误拒绝恢复，也可能漏记真实reader在途。这是静态确定的控制风险，尚无动态复现结论。

请使错误与当前已接受事务绑定，避免把idle的旧sticky error当新事务结果；所有实际load握手必须被记录，非法地址也不得先展示可接受请求后漏记债务。仍须等真实RLAST、FIFO消费/丢弃、load_done及所有写债退休，不能用reset清旧错或伪清计数恢复。顺带核scratch reader同类接受/出口不漏记。

定向短例使用真实AUX AR/R：在已返回部分R后给合法RRESP错误，等实际末R和load_done，检查一次7/phase13、无成功/无早done；显式discard后不reset，以正确新epoch3启动下一合法局部行并完成。记录每次load接受、活动区间、末R/load_done和外层done，断言有真实reader债时不可提前结束。保留旧版复现与新版结果，不改历史日志。

## 后续执行与费用

上述两项及原计划错误/reset/128位元数据、RAW-only/FFN受影响回归均在修订14原帽内继续。新增总线持稳/逐口次序、逻辑内存邻区哨兵和4KiB边界优先合入同一生产适配器局部短例；不足部分明确NOT_RUN，不扩大预算或把局部peer升级为完整真实请求。MUL复位沿用[已答复的观测口径](qkv_rope_mul_observation_decision.md)，区分严格IP未返回与HLS尚未采样，不凭常高valid或ap_start签覆盖。

不为迁移PASS重演AT225的791s长例；以最小差异、冻结身份、受影响局部实测和必要真实core/IP展开交付。AT225旧SHA正常完整两行证据保留，新SHA不自动获得完整真实长链PASS。

截至AT225已完成guard按实际命令累计static543.2655436191707835/1800s、RTL1043.750234801322253/4800s；这是15笔guard（10 static＋5 RTL）的时点账，不含后续已运行或正在运行的短例，host完整UNKNOWN。阶段末按全部原guard重新汇总，旧失败/pilot全计、修订13余额不转移。无需中间步骤审批，工程阶段交付后集中审核。
