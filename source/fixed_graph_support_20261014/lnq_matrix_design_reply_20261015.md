# LN→Q→Wi单行最小连接静态交付

A003→A001；M004/SM004/E004/R001；回复 `m004-lnq-matrix-minimal-connection-design-20261015`。现有 `source/fixed_graph_architecture_20261014.md` 已追加一个方案及守卫判据勘误；没有EDA/前向/新gold/新agent。轻量身份脚本实测0.12s/31076KiB，历史未采样累计仍UNKNOWN。

推荐真实单行LN→Q接 `tm4tn8_sync_ps_front_v2`，cfg_rows=1/K1024/N5248；该入口源码明确支持，完整32group×656tile=20992stripe。LNQ发布行保持在原1088B暂存，每group一次同步读，锁存A256bit＋精确F32 sa，复用到656个tile；W采用现有dual cache一个活动槽的真实load/lease/read/release薄接法，不接matrix_resident或通用portal/owner。当前cache的本地身份/lease不能绑常量，bank拆分版还需同版验证。

已找到完整N的同输入独立gold，不必把P1的8列窗口扩为全N：AT040 `fixture/source_rows4.f32.bin`为前LN源；同目录`gold_rows4.f32.bin`与既有`t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin`全16384B逐字节一致。可取真实row0，输入SHA `63bafc067c5ea179e47146472dbbf2f55cb5e8c8182015d59e5ab40424ce84b4`；现存row0六字段逐group PS为4030464B、完整final为20992B，final SHA `64ada464630ef94ee07385a723dc3786bbaf105673f45603f12b77ad5b0a26a1`。所有产品原SHA已核，见 `source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json`。这套v4 row0与P1 wi_ln_rows1的输入、LN、Q均不同，必须用真实前LN源重新走新LNQ，不能混用P1 gold或预填保存Q。

PS沿既有8bank/活动row的同步1R1W、busy/poison/Q35预留，保持group顺序及非FMA的dot→F32、sa×sw、dot×product、oldPS＋term。FP16 scale从现有精确函数提取为≤10步有界解码。Wi bias_kind=0，最后group的656tile写20992B未发布行暂存，完整覆盖、front成功done、真实读/算术债清零和A/W释放后才给消费者。当前tm4仍物理实例化四套行/PS，不能把rows1解释为面积减四倍。

实质接口缺口：现PS front没有外部abort，W read_error后仅停issue会永等剩余条数。需一个真实abort→DRAIN薄入口，禁止新接受，排空已有预留/FP返回并令目的无效；不能伪造坏header或零债。这个变更、W本地适配及最终行接口需由你在下一段合同集中确定。

Wi冷payload为5709824B（q0/q1各2686976、scale335872），原下层reader有64beat/4KiB分段；首次真实冷载后同矩阵可留槽跨后继行复用，但warm无额外AR与完整结果需动态证明。旧W冷载54128cycle不迁移新bank版/单tile读序/联合频率。当前新LNQ用v4行的回归、该行保存的独立LN统计量、完整连接/联合资源时序均未证。

已将AT136停止明确为stdout静默触发，不称实际综合停滞；保留原停止/成本，并记录你授权的同版一次恢复与累计额度不重置。新物理结果未知前不迁移AT131，也不自行追加运行。当前交付是静态方案，非实现放行或完整硬件验收。
