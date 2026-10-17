# 真实Embedding LN→Q→Encoder0 QKV行连接

决定：D-M004-EMBEDDING-QKV-ROW-01；2026-10-15；M004/SM004修订12/E004/R001。A001→A002，回复`m004-rev11-at174-at178-stage-closeout-20261015`，采纳A003的`m004-embedding-qkv-minimal-next-answer-20261015`。本段属于用户已批准Goal v4/M004修订3的完整推理实施，不新增mission或逐次审批。

修订11已封账，AT173原整体FAIL和已核FFN数值/有限恢复分项、AT174/175的限定收发覆盖均保留；剩余75.592s不转移。现直接进入下面的新接口实现、编译、定向仿真和普通修复。A002继续独占E002 RTL/TB及模块design/results、E004运行和三摘要；A001维护合同/审核，A003维护研究。不得撤销其他角色改动，不新建代理或第二实现树。

## 同一FSM与明确接口

扩展当前`laya_lnq_wi_gqdown_row_v1.sv`，仍仅一套LN/Q、matrix/front、双槽W、canonical G和ADD。现FFN分支保留，新增Embedding LN/Q/QKV固定分支，不复制完整计算链。

- 新增输入`cmd_mode`1bit：0=现Encoder0 FFN，1=EMB_QKV；`cmd_row[6:0]`为本请求token行0..127。命令握手时锁存，之后输入改变不得影响活动命令。本修订FFN只接纳row0，非0直接按原无活动事务的协议错误7终止、不启动任何服务；QKV支持该7bit行号，实证只取row0/row1。
- 新增输出`result_mode`1bit和`result_row[6:0]`，反映已接受命令，保持至结果释放及最终done握手；row_valid/rsp_valid/done_valid期间不变，无有效命令时不作语义承诺。既有直接caller显式接mode0/row0及新输出；冻结历史包不改，不用隐式截断或悬空输入适配。
- 保留`done_phase[3:0]`及FFN原0..8；新增9=QKV_LOAD，10=EMB_LNQ，11=QKV_MATRIX（含lease、算术、drain和释放失败）。命令/结果协议阶段及成功仍7=RESULT，数值状态6、协议/传输状态7和首错优先规则不变。本地端口变化不宣称生产Host ABI已接通。
- QKV的`cmd_task_context`沿现布局，rows=1、row0=零扩展cmd_row；父层拒绝这两字段与新端口不一致的命令，不能悄悄改写调用者身份。保留完整model/numeric/task identity和原request/generation，LNQ cmd_row及front config_row0均传真实行号。front自身生成的row/group/tile/tag、first_bad_element编码原样保留，不另造仅TB认可的索引。
- QKV使用gamma_kind=1、source_direct=0；原FFN前LN gamma_kind=0、后G直接Q不变。每个QKV命令从现有gamma流真实接受1024项，来源为当前模型`aux.bin`偏移128、长度4096的emb_norm_w。128B W AUX header不包含这条gamma流；无跨命令gamma缓存假设。当前输入边界仍由外部流供raw/gamma，不称AXI gamma搬运已实现。

## 保留真实norm，固定行布局

在`laya_lnq_row_v1.sv`新增观察输出`norm_valid`、`norm_index[9:0]`、`norm_bits[31:0]`，事件严格来自非direct模式真实`ln_out_valid && ln_out_ready`消费沿，不加norm_ready、不改变LN→Q背压。其在错误drain期间如仍有真实消费可继续出现；父层不得将观察事件当作LN成功。共同reset清有效状态，直接G→Q不发norm事件。

QKV命令预留原final_bank的tile384..511；按index%8、384+index/8保存1024个真实LN F32。新增计数至少11bit，检查顺序/地址及完整覆盖；不接受重号、漏号或阶段外写入。前LN保存和matrix写入阶段互斥，每bank至多1R1W，原消费者释放/done前禁止覆写。原FFN skip捕获路径按原语义保留，QKV不把raw skip发布为attention skip。

| 模式 | 可读tile | 数据 |
| --- | --- | --- |
| FFN | 0..127 | 1024个原skip＋Down末残差F32 |
| EMB_QKV | 0..383 | 3072个pre-RoPE Q/K/V，n=plane×1024+head×64+d |
| EMB_QKV | 384..511 | 1024个embedding_norm，后续attention残差源 |

合计QKV行16384B，装入原20992B结果bank；不新增整行norm/QKV RAM。继续同步256bit读、一份保持响应、rd_tile/rsp_tile10bit；非法范围按现协议处理，不读取旧payload。release优先新read，并等待读及旧rsp消费后结束；模式/行号和全部响应字段受阻保持。

## 真实矩阵、权重生命周期与发布

QKV固定rows1/K1024/N3072/bias0，32group×384tile=12288stripe、98304个lane-group PS。每group一次真实Q读，保持A256和精确sa供384tile；sequence=g×384+t。保留FP16精确解码、signed dot→F32、sa×sw、dot×product、oldPS＋term的非FMA数值顺序。Encoder0不在embedding LN后再做一次attention LN。

QKV只使用slot0，weight key按原编码family | (layer<<8)，即16'h0001；不能把文字{family,layer}误编码为16'h0100。q0/q1各1572864B、scale196608B，总3342336B；64B payload beat分别24576/24576/3072。冷命令沿真实AUX检查与三口reader加载slot0，QKV不加载slot1、不要求unused Down描述符/epoch非零；原FFN仍要求有效Wi/Down描述符。

每次LOAD须真实完成且load_error=0；确认槽身份/READY，再以完整身份成功lease/read/release。warm row1复用已加载QKV槽，重新lease并绑定本行真实task，W/AUX零新增AR。槽epoch、reader、返回和release不能绑常量。QKV回FFN时必须按原cold规则、在旧债全退后分别加载Wi/Down并使用符合原规则的新epoch；QKV READY不能被FFN warm误命中。不增加第三槽，不把缓存接口READY误当全系统成功。

成功发布必须合取：norm1024完整；g31的384tile/3072结果完整；LN/Q/front成功；真实读/算术/响应债零；W lease释放成功；Q row_release及最终done消费完成。随后直接进QKV ROW，禁止启动G/Down/ADD。错误行所有部分保持隐藏。数值坏/poison按原状态6和首错，真实协议/传输优先7；覆盖不足不能掩盖已知数值错误，全poison final_skip不能伪造commit。Q数值错缺组同理。共同reset清新增mode/覆盖有效和全部既有模块在途状态；普通阶段切换不得reset清债。

## 原参考与本段验收

[研究绑定](../../source/fixed_graph_support_20261014/embedding_qkv_binding_20261015.json)给出全部路径。A001独立核78条文件/切片身份、10对当前/AT173源码和17项字节/整数布局条件；包括前4行g31 PS=final及scatter第四字段的真实row-local。3份大W BO父SHA仅为AT091历史声明，本轮只核所用窗口。详情见[主控证据](lnq_review_evidence_20261015.json)的revision12_embedding_qkv_static_review。

使用AT091语义B1/S128、request3/gen1原raw/gamma和`task2_real_fixture_20`保存的完整QKV参考。`qkv_row1_*`表示一行case的token row0；实际token row1取`qkv_rows4_*`的第二行，不能误用名称。rows4的source/Q/scale/steps/final分别按1024 F32、32×32 int8、32 FP16、32×3072×6 u32、3072 F32切片。原raw row0 SHA222e2a57…、gamma dfb0f4aa…、norm f166773b…、QKV final d4d1b006…；row1 raw e5344461…、final18079bd9…。v4与AT091请求wire/build不同，只核载荷关联，不称整包同版；P1仅复用同位型row0历史LN统计，不用其8列gold替代3072列。

1. 先做受影响短例/静态核对：mode/row锁存与task行一致、FFN非0行拒绝、QKV unused Down字段、norm真实消费和direct模式无事件、失败不发布、gamma有限停顿、读边界127/128/383/384/511/512和4bit phase。新接点的受检正常/错误路径不得force FSM/valid/债务/done。未变叶子按SHA复用，短例用保存数据只签注明的局部入口。
2. 主场景保持同一个真实runtime：QKV row0 cold→完整512tile消费/释放/done→同请求row1 warm→完整512tile消费/释放/done。两行分别逐bit核1024 LN/norm、32组Q/scale、全部98304 lane-group PS六字段、3072 final；总196608 PS、6144 QKV final、2048 norm。核32group读A、12288 W读/返回/issue/commit守恒。冷载核成功状态与实际AR/R，warm核W/AUX增量0。
3. 保留同runtime QKV驻留，发一次FFN warm命令证明错误矩阵身份不能命中，在matrix issue前拒绝/真排空且零发布；之后无reset用新epoch cold加载原Wi/Down，运行原AT173真实输入至完整FFN末残差/消费者done。逐位核原LN/Q/Wi/G/Down/残差参考，证明共享mode/shape/bank切换；不另跑冗余FFN cold+warm基线。若单次预计超帽，可拆本段完整场景，但每个新runtime必须真实建立其冷/暖前置状态，并保留跨mode未覆盖边界，不能预填cache冒充warm。
4. 在上述运行合并有限合法反压：cold W与AUX AR分别保证至少一次真实VALID受阻并核全部字段稳定，R有限空拍；warm输入/gamma及结果响应保持、少量重复/倒序读、release与新read同拍优先。只能对可背压接口实施完整握手一致的停顿，无ready返回不可丢。每个端点打印真实阻塞计数，未命中即未覆盖；不要以周期门控假定命中。读完512tile不等于整S128写回。
5. 本段优先完成新QKV与跨mode回归。Wi/Down遗留bad/poison、内部主动反压、部分R后reset不作为此接点启动前置，不再冷LOAD等待末group做孤立注入。若有不改生产数据路径的低成本真实局部事务入口，可在总帽内补测并明确局部范围；否则保持NOT_RUN。不为探针另写一份判断替代生产逻辑，不在主场景PASS后未经受影响回归改变共享RTL。

记录每cmd真实接受及全局单调cycle、LOAD/LN/QKV/FFN各阶段起止、发布和done；分列cold/warm成本与AR/R，打印本次cmd/mode/row和实际发/返/债务。所有自检结束才给唯一最终PASS，退出0、无Fatal/Error且guard正常才算整次PASS；原始失败/局部分项分别保留。

## 独立成本与出口

修订12预算：host准备累计≤300s/8GiB；static/IP/展开累计≤1800s/24GiB、单次≤600s；RTL含pilot累计≤3600s/8GiB、单次≤1800s且全局≤1Mcycle；pilot≤120s并计入。新budget只覆盖上面新模式及受影响切换，不回填旧修订成本。三条完整成功行和一条错身份短路径是计划工作量，3600s是成本上限，不是已证明可完成时间。

全项目单重工具，CPU0–3/nice19/idle I/O、MemAvailable>192GiB；实际owned进程政策采样。首个长例先用本版≤120s真实pilot和阶段工作量作有依据估算；缓存冷载pilot不足以预测矩阵阶段时明确不确定性，可用同版局部matrix采样，全部记账。不能将旧四行预量化408.346306s、Wi的24/41工作量或旧150MHz直接当新墙钟/频率。长例估计不能落帽则拆成有证据的局部范围或成本出口，不自行延时。

guard看真实握手/阶段进展；复位计数epoch只在真实reset事件变化，不把stdout静默自动等同算法停滞。失败、pilot、编译与仿真按实际命令分类，全部原费用保留；普通接线/TB/脚本修复直接在帽内继续，不逐项等A001。重复同因且无新可检验原因、实质接口/数值冲突或成本出口时集中回报。

不启动OOC/P&R、全模型参考前向、新gold或新agent。阶段交付仍写既有SM004阶段报告、模块design/results及E004三摘要，给最终冻结身份、PASS/FAIL/COST_STOP/NOT_RUN和准确总账。当前新mode/norm保存/QKV连接均NOT_RUN；原FFN证据仅属原冻结身份。S128全部行、设备scratch writer/写响应债、RoPE、Attention与完整Encoder/模型、生产Host/HBM、联合资源/Fmax仍未验。
