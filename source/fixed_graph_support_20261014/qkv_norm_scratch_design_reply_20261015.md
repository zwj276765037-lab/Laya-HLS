# QKV＋norm到scratch：单一有界writer方案

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-qkv-norm-scratch-minimal-next-design-20261015`。

已追加[原架构文档“QKV＋norm行到设备scratch”](../fixed_graph_architecture_20261014.md)，[最小身份/布局依据](qkv_norm_scratch_binding_20261015.json)、[只读脚本](check_qkv_norm_scratch_binding_20261015.py)及[实际计量](qkv_norm_scratch_binding_time_20261015.txt)齐备。52项文件/窗口、22项静态检查成立；0.06s墙钟、18864KiB峰RSS，CPU0–3/nice19/idle、20s/1GiB保护，交互读取UNKNOWN。无EDA、前向、新gold、新代理或E002/E004改动。

**唯一方案**：在当前行top外接固定薄消费者，保留一套计算top；QKV模式独占现rd/rsp/release，复用一个`tm1tn8_axi512_writer`，FFN模式原读/释放透传。当前top `54fe628f…`、LNQ `cd35f5a6…`及Q/front/pipeline/FP restore/W cache共7份均与AT192/194冻结相同，193/195编译来源已绑定；原数值分项可按身份保留，新增消费/写响应/模式切换待验证。

writer SHA `1606920748ffbbdbd8f9197b24b8a783d890dedaf394e7d6401f4f8bb551a448`匹配原109九例局部PASS及日志/guard：已有独立AW/W接受位、不可变TX、B错误真实排债。只需补**债零且无tile/flush时的同步rearm握手**清上一命令fault/flush/计数；旧caller接0，新叶子需短回归。原fault仅reset清除、错误时不发flush_done，不能直接当可连续错误恢复接口。AT101向量页尾分段源码身份亦已核，但它绑定双读/ADD，不作本段writer；不引用AT097跨页代码/速度。

writer固定线性mode，外层按plane/head给段基址和local n0：48个QKV head段各256B/8个TN8响应，再1个4096B norm段；每段末响应真实交付后flush，债零、flush完成并撤下后才换base/路由。单writer经锁存目的把AW/W/B路由到QKV0/QKV1/HIDDEN三个写口，全局最多1个TX，目的保持至末B。保留原held32B＋pack64B＋TX64B=160B，复用top已有32B响应，不加整行RAM或第二matrix；64B只是组两半beat的理论最低payload，不是本复用实现资源。

每行QKV两shard各6144B、96个单拍AW/W/B，norm4096B、64个，总16384B/256事务/512读/49次flush。`AWLEN=0/AWSIZE=6/INCR/WLAST=1`；目的base64B对齐，逐拍自然不跨4KiB，不另建长burst分段器。QKV地址严格保留`((((p*2+b)*8+h/2)*1024+s)*64+d)*4`和head&1；norm为HIDDEN独立行`(b*1024+s)*4096+i*4`，原raw在STATE0时沿控制器另一bank规则用STATE1 HIDDEN offset0。B1/S128有效QKV每shard786432B、norm524288B；BO布局仍各12MiB和HIDDEN8MiB。QKV最大exclusive offset10256384B，必须按稀疏范围、BO包含/溢出/活跃源隔离核查，不能只给6144B连续空间。row0/1所有保存scatter地址/数据及norm原字节均核对。

包装层锁存cmd/mode/row、request/generation、model/numeric/task与三目标epoch/base/span，校验结果回显；每次一个真实同步读预约，rsp受阻由core保持。只在512响应和256个OKAY B全部退休、read/held/pack/TX债零后release，再消费core done并给一次外层完成；建议保留4bit并用phase12=SCRATCH，传输错误7、原算术6及phase保持，最终码由主控定。core row_valid只表示本地行可读，core status0不能掩盖写错。

真实BRESP错误停止新read、排掉已有同步响应；原writer清未发payload但不撤销已展示AW/W，真实B清TX。标签错误则flush已有pack并等所有债零；错误路径等debt_zero、不等成功flush_done、不强求完整计数。真实release/core done后一次外层错误。W可能已修改内存，部分写必须保持不可发布，不能假装回滚。共同reset仅覆盖wrapper/core/writer及受控AXI peer一起取消在途事务；清有效/覆盖/epoch，残留字节无效，不签总线独立reset或旧B自动恢复。

固定请求持128bit row_written＋sticky tensor_failed，完整一行B/释放/done成功才置唯一row位，重复row写前拒绝。只有全部128位、无失败、债零才允许RAW tensor发布；任一写失败阻止本epoch发布，新epoch须在债零/旧消费者释放后重新初始化。两行样本不得补齐剩余位。pre-RoPE Q/K待真实RoPE，V保持；norm保留至attention skip消费。RoPE RAW→FINAL覆盖、写响应、Attention加载/命令/mask和全128依赖仍缺。

**有限验证建议**：同runtime真实row0 cold完整scratch正常＋row1 warm完整scratch，第二行最后norm TX在真实AW/W后有限hold并返回错误B。两行均用原full QKV/norm/scatter逐bit检查；三个目的保证AW/W真实阻塞和两种接受顺序，正常末B前禁止release/成功，错误末B后禁止置成功位/tensor发布，并验一次完成/真实排空及邻行哨兵。正常与错误共512次真实单拍AW/W/B，未估墙钟。局部rearm/页尾/共同reset用同一生产适配器合法同步peer短事务覆盖，保存值只作注明的局部入口，不冒充全链producer或完整恢复。

把遗留跨mode与该新接点合并：row1错误排空后，无reset用Wi slot0 epoch2/Down空slot1 epoch1进入原FFN，直至完整末残差/消费者done；同一次QKV前缀验证新写回和旧重入，不再单独只重演AT195。若同版profile不落新帽则集中保留缺口，不仅延长旧墙钟或缩K/N；错FFN warm拒绝按未变core原身份复用，不额外重跑长行。

**成本事实**：AT193接受到done差78677/50909cycle、整次714.517070s/child1；AT195为1100.280453s/child−9，原guard明确trigger=`timeout`，只到Down issue9542/commit9530。原FFR1_PROGRESS的aw/w/b是复用字段，不是scratch总线计数。修订12RTL3568.453182073s、余31.546817927s封存。本段仅可证明结构工作量，AW/W/B等待与新组合墙钟/资源/Fmax未知；须新profile，不按字节比推速。新scratch连接及完整FFN跨mode均未验；最终接口、预算、实施仍由A001/A002负责。
