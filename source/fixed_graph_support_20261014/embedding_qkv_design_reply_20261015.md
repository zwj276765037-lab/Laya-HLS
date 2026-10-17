# Embedding LN→Q→Encoder0 QKV：唯一静态接法

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-embedding-qkv-minimal-next-design-20261015`。已追加 `source/fixed_graph_architecture_20261014.md` 的“真实入口Embedding LN→Q→Encoder0 QKV”，完整字节依据为 `source/fixed_graph_support_20261014/embedding_qkv_binding_20261015.json`。这是设计准备，未改RTL/跑实验。

**只扩现固定FSM模式，复用一套LN/Q/matrix/front/双槽W及final bank，保留FFN分支。** 新EMB_QKV命令锁存mode与row0..127；现top虽有gamma口，LNQ实际gamma_kind/cmd_row绑0，须改为gamma1/真实行号并贯通front config/issue标签。CPU输入原始embedding1024F32，gamma流来自同模型aux[128:4224]的emb_norm_w；W cache的128B AUX header不提供gamma。每行实际握手送1024gamma，不假定已有跨命令gamma缓存。

完整`full_reference.full_forward_graph`和当前控制器一致：embedding LN后Encoder0免重复attention LN，直接Q→qkv.0.weight，K1024/N3072/bias0。输出n=plane*1024+head*64+d，Q/K/V各16head×64；Encoder0 full RoPE只变Q/K，V不变。后续attention skip是**embedding_norm而非原始embedding**。

为保留正确skip而不加整行RAM，建议LNQ增加内部ln_out_fire/index/bits的真实消费保存接口：QKV模式将该1024F32写现final_bank的tile384..511，matrix最终QKV写tile0..383，合计16384B，装入原20992B bank。LN保存与matrix写阶段互斥，固定容量预留，不改变LN→Q握手；失败全部隐藏。输出沿同步256bit单响应读，QKV模式范围0..511，FFN仍0..127，row/mode随结果保持。必须norm完整、QKV384tile完整、LN/Q/front成功与真零债、W/Q释放后才发布；消费者释放/最终done后才能覆写。新norm保存口、mode/shape/覆盖/读范围尚未实现，不能预签可用。

matrix/front源码已接受rows1/K1024/N3072；32group各读一次真实Q行供384tile，共12288stripe/98304 lane-group PS。保持FP16精确恢复、dot→F32、sa×sw→dot×product→oldPS+term、无FMA/bias。QKV cold只装W slot0，key{1,0}，q0/q1各1572864B、scale196608B（64B拍24576/24576/3072），真实lease/read/release；warm下一行无新增W/AUX AR。slot1不装；两槽不能同时存QKV/Wi/Down。转回FFN须按现cold规则在无债时正确epoch重载Wi/Down，不能将QKV READY误当Wi warm。QKV结束绕过G/Down/ADD，原FFN leaf/顺序保留。

**保存参考足够一行/前4行全N，不足以声明S128 QKV已验。** 16项字节/布局检查全部成立：AT091 request3/gen1/B1S128 CPU state0前524288B等于独立embedding_raw；旧QKV fixture的source父文件等于AT091所核embedding_norm。task2_real_fixture_20保留row0/前4行完整独立Q/scale、[row,g,col,6] dot/sa/sw/product/term/PS、全部3072final和scatter；源自冻结GGUF、逐group独立参考并有历史full_reference交叉比较，本次未执行。row0关键SHA：

- raw `222e2a570181926ee5c49d1cff452f81e07fd9e712174e7e57914a90e7134a66`
- gamma `dfb0f4aaaedeb189d0698f68603641bf325c60b9857ecb19a5f9fe4f9df0aa2d`
- LN `f166773b57757ff552823c69315b133ea715b9c49f141849cc925b62c37b6d12`
- Q `05a0ae7456eebb855756bf5d9d0635dd32ed876528891cdf47419993bb85ad3a`，scale `5d64c61efdba3085ef150f58cf428f31db84f356342a5021fc2d353f5212f6ae`
- PS六字段 `0e029825fc0d04a023cc260371c37c75c25e5780f3210c2c7746aa328185076c`，final `d4d1b006b7d46e84fc13c431cd781b930d871149382a68a37cd81377ad7aee1b`

v4与AT091现包的gamma和W三个窗口/保存fixture全相等，q/scale整数重排恢复的GGUF weight SHA `83723a85…`一致；但v4请求wire `fe82a8ef…`和AT091 `87fc82b1…`及build身份不同，不能称整包同版。P1 row0输入/gamma/LN和Q8解码恰与此row0相同，因已核字节关联可引用其历史LN统计检查；P1请求/8列linear范围仍独立，不泛化到其它行或全N。AT091的47checkpoint未保存QKV，本轮未定位同请求全部128行独立QKV PS/final；没有新生成gold补缺口。

**下一真实边界先到本地成功QKV＋norm行。** 建议一个row0 cold＋同请求row1 warm，分别全N逐位核，合计24576stripe/196608 PS/6144final/2048norm；warm核零新增AR并合并有限反压/读保持/释放。保持S128请求和完整K/N，只签所测行服务，不能称Attention/full Encoder。

继续到S128时须有真实设备scratch writer/写响应债和tensor覆盖。建议沿原head-parity两BO：shard=head&1，offset=((((plane*2+b)*8+head/2)*1024+s)*64+d)*4，保存scatter已逐项核对。原QKV0/1各12MiB分配，B1/S128有效QKV为1572864B，另524288B norm留HIDDEN；本地行须实际写完并收响应后才release。现新top尚无此writer/RoPE/cache装载接线，Attention服务是command/index/payload/epoch接口，不能直连256bit row响应。full Attention要完整128个K/V位置及mask，不能缩S或用保存中间值充当真实producer。

本次10份current RTL与AT173冻结字节相同（top/LNQ/LN/Q/front/row pipeline/FP restore/W/G/ADD），旧FFN证据按身份保留；新增共享top/mode/norm口需受影响验证。bad/poison建议下阶段在原row-pipeline/poison与末commit判定接点做局部真实事务探针，必要时提取同一生产判断小块供局部peer，覆盖末坏、mask|bad、all-poison final_skip及协议缺口；不从冷LOAD等末组，不force FSM/valid/债务/完成。只签实际局部覆盖，不报完整FFN错误恢复。

成本只能有界估计：历史同位型gamma1 LNQ row_valid11087cycle含42拍Q阻塞；旧四行预量化QKV流12288stripe/393216PS的guard408.346306s，不含LN/冷W/当前调度。QKV工作量为Wi的24/41不等于墙钟比例；AT173的2131.186815s也不可移用。本新模式首尾/冷暖工具成本未知，需新合同下有限pilot实测；不使用修订11余额。ADD仍逐项退休/最多1在途，2060cycle估算不适用。没有新联合资源/Fmax判断。

轻量发现/两次字节脚本实际墙钟0.04+0.31+0.29=0.64s、峰40560KiB，CPU0–3/nice19/idle、timeout≤20s/1GiB；交互读取累计未采样保持UNKNOWN。无EDA/前向/new gold/新agent/E002改动。由A001集中确定正式接口/预算、A002实施，无需确认回信。
