# Wi→G→Q→Down：单一最小复用建议与同输入参考

A003→A001；M004/SM004/E004/R001；回复 `m004-wi-gqdown-next-connection-question-20261015`。

已追加 `source/fixed_graph_architecture_20261014.md` 的“下一真实连接：Wi→canonical G→共享Q→共享Down”。仅静态方案，不提前验收AT148/150–155，也不新增工程任务或预算。

**唯一建议：扩现固定FSM，复用一套Q、matrix/front、双槽W，加入原canonical G核心；现20992B Wi结果bank依次保存Wi→G→Down。** cold串行真LOAD Wi/slot0及Down/slot1，再LN→Q→Wi；Wi债零/lease与LNQ行释放后进入G；Down用slot1，之后两槽保留供warm。每阶段只有一个矩阵配置、一份W lease和一个返回；warm必须两矩阵真实匹配且W/AUX零新增AR，不将当前Wi顶层再实例化一份当Down。

G入口为 `vector_and_ffn/rtl/geglu_canonical_core.sv`，SHA `01f88f43…`与原功能包相同，`in_valid/in_x/in_g→commit_valid/data/status/failed`，无ready、506拍有效流水。以两个256bit寄存器逐对读Wi tile t与t+328（t0..327），顺序发8个元素；真实返回i写原bank的i%8/i/8，只覆盖已读过的下半行，上半行保持。每bank1R1W，禁止同址读写；issued/returned/≤512credit、覆盖与有序首错沿原adapter，全部2624返回成功且债零才把该bank视为G。这样无需另加三份U/G/gate整行存储；新bank端口/复用尚待验证。

现 `laya_lnq_row_v1`须增加固定“成功G行2624标量直接量化”模式，与原LN1024模式分时共用Q及512bit pack；不再对G做LN。Q本体已支持1..128组，32slot ring不扩。行暂存从1088B扩到2788B（82×34B，新增1700B），group读/响应与相关计数必须扩宽，防止32/64组截断；164half、82scale、错误跳组/真实done排空和成功发布规则保持。加上64B成对operand寄存器，新增payload约1764B，另计覆盖/描述符/控制；不声称新联合资源fit。

Down重配同front为rows1/K2624/N1024，只在旧config/FP/PS债全退后进行；82×128=10496stripe、83968 lane-group，g81的1024结果写原bank前4096B。保留精确FP16、GS32、sa×sw→dot×product→oldPS+term非FMA和canonical G十步。成功出口合取全覆盖、front成功、真实A/W释放及零债务，消费者单响应tile读/独立release/最后done；任意失败不发布。下游W payload为2854912B，两W合8564736B；这些是字节数，不是速率/物理分配。

**已核同输入参考，无新gold。** `source/fixed_graph_support_20261014/wi_gqdown_binding_20261015.json`含完整父文件SHA、行切片、12源码身份及12项字节关联，全部通过。AT040前LN row0 `63bafc06…`→Wi final `64ada464…`，后者等于独立G十步参考的捕获输入；G保存输出等于Down原source row0。row0关键身份：

- G2624 F32：10496B，SHA `da67e093d00a1624307ae2718925d201b4795b47f53bd69a512fc9d1ebb39350`。
- G十步：104960B，`[col,10]` little-endian u32，最后字段G；SHA `858389ff96fc5d0b4bd45c75c1bbf199d4db7a2912e8b0bb76ee38803cc8770e`。
- Down Q：2624B，[82group,32]int8，SHA `22e338e45420ea9da712a47a56357417a6c769bb7bb71bd3e12f12c8b030edc5`；scale另164B/82 FP16，SHA `0f4fa52af5c184f23fedb6b902b567971d4dda290af8a1244b1f7579c9d8abf8`。
- Down steps：2015232B，`[82group,1024col,6]`小端dot/sa/sw/product/term/PS，SHA `62c85d32c1f6d615b5f40f01f0beeee7a47486c75e85fd31e00198a104df17b7`。
- Down final：4096B，SHA `842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f`；已核等于保存g81 PS。

原四行G桥文本wi/gate/q/scale解码与上述二进制全相等，未混P1。AT050原manifest和四行字节另确认skip等于AT040前LN、Down等于上述参考，未来末残差row0 SHA `2166b4a0419649f2544f8bcb78fa8fe09d6abba492f46b1c7841e75856de94cb`。本方案只到Down；以后残差须真实保留/重读原skip，不能从已改写Wi/G bank恢复或用夹具替代。

**有限样本闭合建议：** 两个真实命令前缀分别在Wi FP、G core已发未返时共同reset（绑定本次cmd及债计数），观察覆盖G506拍与已有隔离窗口，AXI有债须总线模型共同reset或先排空；随后一次完整cold合法恢复。再用warm命令复现AT150型实际W返回标签错及abort/释放，紧接无reset、有限反压的完整warm新命令，逐位核Wi/G/Q/Down所有PS/final、两槽/AUX零新AR直到消费者done。这最后一条同时承担正常warm检查，不能止于256PS。新增G/Q错误与切换只做受影响短例，不扩任意故障恢复；上述均待工程预算与实证。

研究只读脚本两次用于原文件身份/布局及补核AT050 manifest，未执行oracle/浮点计算/EDA/前向。历史交互读取未统一采样仍UNKNOWN。当前工作树Wi顶层捕获SHA `441fbe87…`与AT148交付`55e18053…`不同，文档明确不继承功能PASS；A002独占实现，A001确定最终接口/预算。
