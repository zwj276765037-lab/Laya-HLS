# SM012 CONTROL-ARENA-16：FFN 唯一后继准备

2026-10-22，A010 `/root/m007_weight_supply_engineering`。仅只读源码/既有原始数据与字节映射核查；未改生产 RTL、未运行 EDA、未生成数值 gold。R003 已 completed/frozen，本准备不改其收据、源码封存或预算。期望模型/effort 为 gpt-6.1-sol/xhigh；实际配置未核实。

## 确定的最小后继

只实现一条 **Encoder0 FFN island：公开 norm_ff F32 输入 → 同 quant/A 发布 K1024 → 原 matrix Wi K1024/N5248 → native 双槽 G → 4×8 拼32 → 同 quant/A 填另一 A 槽 K2624 → 完整成功屏障 → 同 matrix Down K2624/N1024 → 公开 Down F32 输出**。父命令一次，matrix Wi/Down 命令各一次，G 全任务命令一次。不能用 TB 逐块发命令或保存 G 覆盖 DUT。该最小范围从明确的规范化输入边界签功能，尚不签 R003 后真实 residual/LN 或完整 Encoder。

原 AT007 的 norm_ff/wi/geglu 只可作为这个输入边界的独立 fixture/期望；不能把它们称为 R003 WO 后已经运行的生产 LN、Wi 或 G。完整 Encoder 集成必须另接本文末尾的真实 residual/LN 生产者及保存 skip 生命周期。

## 精确映射和独立原始证据

| 层次 | 原列/地址/顺序 |
| --- | --- |
| W576 Wi 物理块 s | s=0..81；每块含 Wi 原列 `[32s,32s+31]` 与 `[2624+32s,2655+32s]`，每半32列 |
| W port p | p=0/1 为 GELU 输入半的两个16列，p=2/3 为乘法 gate/value 半；col=`32s+16(p%2)+lane+(p>=2?2624:0)` |
| 每 port 冷载 | `base[p]+s*32*576` 起，32个576B group record；Wi 每port完整span=1511424B |
| matrix 输出 | s→row0..127→half0/1，32F32/拍；out_col=`32s` 或 `2624+32s`；out_s 就是物理 s |
| G 填充 | fill_slot=`out_s[0]`，fill_s=out_s，fill_row=out_row，fill_half=`out_col>=2624`，data 原样连接 |
| G 银行 | bank=`slot*128+half*64+(row%2)*32+column`，addr=`row//2` |
| G 读/输出 | s→row→chunk0..3，每拍8lane；seq=`512s+4row+chunk`，完整96bit tag=`{gen32,epoch32,zero16,seq16}` |
| 原 G scalar | `row*2624+32s+8chunk+lane`；x=Wi前2624列，gate=Wi后2624列 |
| quant/A | 每4个连续 G chunk 拼一个32F32组；row=G row，group=s，K2624；group-major 顺序合法 |
| Down 输出 | 16个64列块，s→row→half；col=`64s+32half`，每拍32F32 |

**0/41、1/42 配对重排不成立。** 物理 Wi64 块已经同时带两半各32列；0与41分别对应 G列0..31和1312..1343。重排既破坏 native 单调 issue/retire，也违反 G 的 next_claim_s。不要把“原连续64列的块编号”套到现特殊 N5248 布局。

[mapping_byte_checks.json](mapping_byte_checks.json) 为实际独立字节检查：原 Wi→x/gate 671744值；AT058全部335872×12=4030464字段；41984个G向量地址；E012 Wi20992拍/671744值；全部167936个原Q8权重record/5709824B。只比较原文件和位置，未重算函数。原 Wi SHA e0b136715786a6ed83ce8aabb1f30944a09a366c7c0096a935be3eb7d52d8cfa；原 x/gate/geglu 等完整 SHA 在该证据及原 AT007 report 中。

E012 Wi/Down 的原 fixture 明确为16 original operator rows加112诊断行。实际逐行比较 E012 Wi source 与 AT007 norm_ff 为0/128行完全相同，E012 Down source 与 AT007 geglu 亦0/128。它们证明布局和原权重，不能充当当前原全128行链的数值期望。当前 AT007 产品止于 G，没有完整原 Down 的同输入 expected 或对应 quant/A packed gold；后继合同必须先授权独立局部 Q8(G)/Down 期望或明确缩到已具期望的边界。此准备未生成它们。

## matrix/W 预取、上下文与 G 两槽重叠

facade 独立的 load_next/issue_next 都从0单调递增；W cache slot 与 PS compute context 均为 s[0]。最多一笔 load_pending，按真实 W load response 标 slot_ready；slot_in_use 在真实 core block_done 后释放，W lease/read/return/release 全部保持原协议。可预取另一 W slot；不把 W cache slot、PS context 和 G payload slot 的独立生命周期合并成一个释放事件。core 按 retire_expected_s 输出，单块256拍，每行两半；PS 上下文只在第256笔实际输出消费后可复用。全 facade DONE 还等待真实 core/A/FP释放与在途预取响应，不能只凭末输出切 Down。

G 接受第一拍时顺序 claim s，slot=s[0]；所有256个 half/row 的**真实写ACK**覆盖后才 slot_ready。生产读依 s→row→chunk 的512次真实银行接受推进。G slot release 必须实际512个8lane输出被消费、对应 bank issued=returned、math/SFU/FP债均0、无未退写；另一槽可以继续在途。第三块 s+2 若旧槽仍活跃，fill_ready 合法反压，其数据可一直保持在 matrix 原有 out_hold，不新增 Wi holding。G末输出 held 必须阻同槽覆盖；另一槽可继续填/释放。

资源不是把 Wi/G 请求塞给同一个算术端口。Wi 实际使用原 shared256 FP 与 PS；G 使用原既有56mul/16add外池和一份原 TANH8。G外池有3/4拍固定返回和无返回ready的完整tag校验，不能直接接到 shared256 的8拍/广播端口或仅拼宽改时延。quant 有原32专用mul，外借 DIV8 phase5。TANH8 的两条直接div/lane在其原DAG内，不能改绑成 quant 的32拍 DIV8。上述物理叶必须各实记一次，没有联合资源/896DSP/300MHz结论。

原 storage 的 PS/G/context 是三个独立bankset，共用同一 request/gen/epoch/phase enabled。R003 matrix 本来就用 storage phase1，G 也要求 phase1，因此同一真实身份下可把 PS 束给 Wi、G 束给 G，不需要每块切 storage phase或伪造 ready。初次真实 matrix bind 时绑定 storage，随后只在实际 storage owner响应匹配后准入 G。初始 G/TANH 准备必须在首个 Wi输出前完成。`storage_idle` 是三个bankset的实际合取；matrix最终 FP释放可能等待 G bank响应退休，不能改成常量，也不能在G忙时重绑storage。既有 parent 用全 matrix_owner 路由 G 束，后继必须细分束使 PS/G 同时可达。

当前 attention_resources 只有 EXP8 的11bit专用tag接口，**没有** G的96bit TANH接口/56M+16A池。后继接线明确实例化原已验 G pool和原 TANH8各一次，复用原唯一 storage/FP/DIV/quant/cache；不能使用 G validation_shell，因它自带第二份 storage。原 EXP保留其 Attention用途，不将“同一个资源壳”写成EXP/TANH已共用物理叶。共享SFU/物理总量仍为主控未关闭的后继范围。

## 32F32 拼接和 Down 准入

一份1024bit holding 只保存当前row/group的32个数值，按4笔实际 G输出在 `[8*chunk+:8]` 写入。full 后保持至 quant input真实接受；允许旧完整组消费同沿接下一组chunk0，必须用旧值RHS保证消费旧组。使用16bit expected_seq及1bit full即可导出行/组/chunk并校验完整tag；已有父request/gen/epoch组合供给，不复制身份。全量为41984笔G输出→10496个32F32 quant组→10496真实A write/ACK，一次A发布。quant_group32 和 front 都只检查合法坐标/身份并按接受顺序退休，A coverage 才判唯一覆盖；它们不要求 row-major，故无需整G转置RAM。

初始norm_ff共4096个32F32组先由同一front发布K1024到A槽0；其真实DONE/DIV释放后才准入Wi。随后同一front重开K2624到A槽1，在Wi读取/lease槽0时接G结果。允许G结果投机量化/A填槽1。成功屏障的固定顺序是：**Wi实际成功DONE + 全335872 G输出/8rank覆盖与实际成功DONE + holding空、10496组已接受 → producer_close_success → quant全部退休/真实A写ACK/发布及成功DONE → 真实DIV/FP/SFU/bank/lease退休 → Down**。不能把quant最终DONE当成成功close的前置而环形等待。A可提前发布，但始终不lease给Down，失败时仍可合法取消未leased发布槽。

CONTROL-ARENA 接 A007 的真实安全切换；layer必须已L_IDLE/real_idle/head/RoPE无债，不能从layer DONE直接换G视图；G结束/显式discard和所有真实债退完才可G→A。same-owner不清，一拍REARM不准入，Check/cache/matrix/front不进入共享覆盖。

## 全局首错与失败退出的必要接口

G 原 first_error 顺序为 `(rank,row,column)`，rank0..7分别 input/u/v/w/t/z/y/geglu；不是s-major到达顺序。covered/evaluated 及资格支配掩码必须保持，完整数学错误仍处理原全域，原done_status6及实际tuple由G输出。协议错误原status8优先于G数值错误。quant局部按 `(global_phase,row,group,element)` 选错。matrix原status/row/col/group/stage保持本模块合同，不重写其rank。

父按原图依赖选择 **Wi源错误→G源错误→Q8(G)源错误→Down错误**，而非谁先物理到达。Wi/G/quant可重叠，Down不得投机。相关模块保持型DONE可作为原tuple储存，父在选定前不随意消费后丢失结果；source status需显式适配 G32bit 0/6/8、matrix/front3bit，而非截断。上游失败导致front status3仅是取消结果，父保留真正源错误；不将取消本身覆盖成首错。

**现G缺少上游取消入口，是确定缺口。** 只有 discard 且需要 needs_discard&&!active&&!done_valid&&math_idle；Wi中途失败时G会一直active等待缺失half/block，直接发discard无效。唯一后继补G的身份匹配 `producer_cancel_valid/ready`，与原已绑定rsp_request/gen/epoch比较，不新存身份；停止新fill/银行发射，保留此前接受的write/read/FP/SFU输出并真实排债，父继续消费已发布输出；取消终回执带独立cancelled资格，不虚构全覆盖/正常成功或复用protocol status8掩盖原Wi原因。消费取消回执后才走合法pair discard，清未完成覆盖，真实release后允许无reset新gen。实现/字段和回归由G当前owner串行承担，当前未添加接口或自行分配status码。

Wi失败或G取消时，front已有producer_close_success=0和A fill_cancel；只排实际接受quant/DIV/A工作，不补缺失组。assembler未交付的partial组可在上游取消确认后丢弃，不能伪造quant接受计数。若G协议故障先阻fill，父经公开protocol_fault停止交给G，并将随后Wi输出正常消费到明确discard sink，使原Wi完整检查/最终DONE继续，避免 matrix out_ready被G锁死；这些beat不得计为G填充。G数值错误不提前停止全域。quant数值错误仍接/评估余下G，保留本阶段全域首错；无法真实排清的缺失返回/协议故障按原reset/阻塞边界报告，不凭计数置零声称恢复。

## residual/LN 的实际出处与生产边界

原参考 fe9678e4 行761–777与 AT007生成器行24–32一致：Encoder0 skip为原embedding_norm（SHA5d8829...），WO来自真实context投影；`attention_residual=add(skip,WO)`（原产品 SHAbac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8），`norm_ff=LN(attention_residual)`（无gamma，SHA6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863），Wi只吃norm_ff，G后Down，最后`encoder_out=add(attention_residual,Down)`。不能把WO、attention context、初始skip或norm_ff自身直接当作Down残差。

R003只完成至公开WO，未接生产skip读/保留、真实residual add、row-major四context LN producer、norm_ff到quant的路由，以及Down输出与同一attention_residual的回加。现M007 layernorm32是纯共享FP/DIV/LN-bank控制器，不在R003实例中，其控制存储也不包含在4035.75B投影里。旧M004 residual/admission模块不作为生产复活路线。完整Encoder后继需明确skip/residual存储来源、原tensor地址/epoch/回收和所有实际add/LN资源；保存norm_ff只签上述FFN island边界。

## 责任、版本、容量和后继验收

A010拥有forward_controller后继接线/拼接/状态适配、matrix/W和本planning；当前不写RTL。A007此阶段唯一写G engine/math共享控制与layer接口，其交付前A010只读。新增producer_cancel由主控将单一G写入权移交后实施；pairs/pool/TANH和数值叶保持原合同。主控拥有合同、共享索引和联合预算。没有新并行agent或EDA资源申请。

4035.75B是当前联合控制投影，余482bit；拼接payload128B单列，17bit拼接控制、cancel/握手/phase flags、arena owner/rearm和任何新增meta均需实计，不能预先宣布可装下。复用父身份和保持型回执可避免复制64/128bit身份与整组错误tuple；不能把控制改名payload，不能将LN控制悄悄塞入现投影。最终逐声明账超4KiB则明确不合规。

后继须先：同源展开核唯一资源和控制账；原norm_ff真实量化→Wi前三native块→G完整输出比原Wi/AT058；实际双槽held/third-slot/W预取PS context回压；4×8拼接held和group-major A坐标/ACK；Wi中途失败→G新取消→front真实cancel→无reset新gen；晚G低rank反转/quant晚较小tuple/heldDONE，均禁止提前Down。补齐独立原Q8(G)/Down本地期望后，才有完整Wi82块→G335872→A10496→Down131072同runtime主例的签署条件和成本门。本准备不签同runtime FFN周期，也不把E015 G-only 42171拍或R003周期拼为FFN实测。

源码逐观察版本和SHA见[source_versions.json](source_versions.json)，各阶段原excerpt与receipt保留。A007的external-control live G engine/math静态接口只作当前设计依据；E015 ring15 math SHA849917c06995c4208d7b94b530c1071cdf6b4b76b6b0685dd1e17fc19531bb2e及AT146范围单列，当前live版本不继承旧PASS。R003 parent e35424a6 frozen不重跑。本准备只完成映射/接口判定，未关闭联合控制/实现/性能/物理与全Encoder验收。
