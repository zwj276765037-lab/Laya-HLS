> 最新current段为文末“G-COMPACT-14之后的附加临时工作区核查”；上文保留压缩前历史映射，不能把旧候选节省重复扣除。

# G／纯 layer／front／parent 控制复用只读映射（2026-10-22）

本报告只提供当前源码的字段、寿命和冲突，不改4KiB目标、接口或生产RTL；E017仍归档。期望gpt-6.1-sol/xhigh，实际配置UNKNOWN。引用的24份源码/原记录完整SHA见同名JSON，写完时仍逐份匹配。

**直接结论：G算术tag可在单请求域内表示为固定generation/epoch＋16位序号；身份编码之外，逐向量活跃/返回/持有、逐lane数值资格/错误信息和真实债仍须保留。仅压tag不能使联合控制达到4KiB。**

## 当前版本和账

G四文件与AT071声明账一致：engine `bfd87edc50ba1ca1`，math `4262795be7303822`，pairs `49ba8533dca944d6`，pool `bfcc7dcf863a1d67`。当前parent `e35424a62457ca08` 相对AT011仅有一处组合修正：`q_producer_close_success=!producer_failed&&(state!=CRUN||!c_fault)`，原式为`!producer_failed&&!c_fault`；所有顺序赋值字段集合未变，未替正在进行的回归宣称PASS。adapter/layer/front/matrix/core仍匹配AT011对应SHA。

| 账项 | 当前源码声明/保守容量 | 边界 |
| --- | ---: | --- |
| G身份 | 4747B | 包括真实G新增tag复制，不能改记原数值管线 |
| G逐lane mask／真实credit／coverage／error | 822／186.125／102／10.125B | 合计G控制 **5867.25B = 46938bit**；AT071 |
| 纯layer及其既有Check/cache/RoPE控制 | 20691bit = 2586.375B | E010/R004实际声明，含已有低4096 coverage复用 |
| matrix/front | 保守955B；含原8B保留额963B | E012/R004；profile-off已计，不再扣一次 |
| 新parent／context adapter | 1518／43bit；分别取整合196B | E016 AT011，当前组合修正未增加状态 |
| 既有联合控制 | **3746B**，余350B | 保守取整账；不是综合或物理fit |

来源为E015/R001/AT071 `work/report.json`、E016/R001/AT011 `source_control_audit.json`、E012/R004 `reports/control_storage_account.md`、E010/R004 `final_delivery.json`；同名JSON记录原文件SHA。

## Tag可派生部分

[G engine L66](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_m007_g_engine_v1.sv:66)实际构造：

```text
tag96 = {generation32, epoch32, 16'b0, seq16}
seq16 = {s7,row7,chunk2} = s*512 + row*4 + chunk，0..41983
slot=seq[9]，ring=seq[7:0]，scalar_column={s,chunk,lane}
```

request_id64不在96bit tag里，保存在pairs外层绑定并接受storage/SFU真实owner校验。request/gen/epoch必须稳定直到实际债、held输出、done与必要discard全部退休；不能用parent的FINISH握手单独判断G已释放。

| 当前tag复制 | 96bit条目数 | 压16位后声明字节 |
| --- | ---: | ---: |
| math tag_mem／expected_tag | 256／36 | 512／72 |
| pre_tag／t_tag／post_tag+r_tag | 15／7／14 | 30／14／28 |
| pre-credit／外侧FP pool | 32／34 | 64／68 |
| 合计 | 394 | 4728B→788B，候选省 **3940B** |

仅此候选后G控制为1927.25B，联合为5673.25B，仍超4KiB **1577.25B**。这不是已实现节省。当前数学/pool独立96位公开接口比engine生成域更宽；未来压缩必须明确只在该单请求域内，恢复完整tag并保留收到的gen/epoch/保留位校验。低8位ring每256次重用，不能代替16位序号；全窗口range推导尚无本次证明。expected与实际peer tag必须独立，不能由响应生成“期望”。quant front使用`{epoch,generation,row,group,16'b0}`，与G字段次序不同，不能直接共用一种隐式pack。

另有三个源码候选，均未计节省：pairs只有一笔write_pending，可由`generation,epoch,write_sequence-1,pending_s,pending_half_row,pending_slot`重构pending_write_tag96（最多12B）；math显式未消费的对齐尾声明共742bit（在16bit tag候选后另有262bit）；四个bitmap的五种实际状态可考虑≥3bit/vector编码（最多32B）。后两者是声明推理，不是综合FF减少。详见JSON具体下标与源码锚点。

## 必须保留的信息及其真实边界

| 信息 | 实际写入／读取／清除 | 可共享或冲突 |
| --- | --- | --- |
| `live/available/sent/received` | accept置live；真实SFU发/返分别置sent/received；末FP返置available；只有out_valid&&out_ready清槽并推进head | EMPTY/RESERVED/SENT/RECEIVED/AVAILABLE不同；SFU已返到输出可用间还隔后算术，held输出亦不释放。可编码，不可删有效状态。math L72–85、156–197 |
| `numeric_bad/peer_bad` | accept初始化；各rank/FP/SFU真实事件OR逐lane；head输出状态numeric6优先peer8；槽消费后才失效 | request/seq不能推导数据/协议错误。不能把全请求first_error当所有向量的mask。math L60、108–121、161、173–185 |
| `z_good_mem`及x/u/v/t/z/post/y/g资格管线 | matched z返保存8lane资格，跨可变SFU阻塞后供匹配SFU返和后级原数值域使用 | 资格信息必须随向量保留；若想由早期bad masks恢复z_good，须证明全部事件/同拍OR/异常peer路径等价，本报告不扣256B。数值payload虽清为0，原eligible也不能随之抹掉。math L76–84、163–193 |
| expected/pool valid、per-slot pending/SFU/FP债和pre-credit | 真实请求accept增债，只matched返回/真实输出消费减债；错误peer不退休真实欠债；slot全部三类债零且消费512才release | 两slot可同时活跃，不能改成一个全局busy；无错误路径下的固定时延界不能用于悄悄缩真实错误债。math L61–68、134–155；engine L75–82 |
| pairs coverage512bit | 唯一storage匹配write ACK置位；新slot claim/真实release/discard清除 | fill允许half/row任意顺序，且检查重复；不能由producer intent或一个写计数替代。pending ACK与同拍新fill须保留旧tag比较。pairs L34–55、69–73、118–137 |
| G covered/evaluated及first_error | checked event各rank计coverage/evaluated；first_error按rank,row,column持续择优；cmd_fire/discard/reset清 | numeric错误仍完成全域Check，protocol错误可仅排真实前缀；arrival先后不代表原rank。held done与needs_discard是两个边界。math L108–132、173；engine L82–83、108–118 |

## 与3746B既有控制的生命周期交集

| 现有工作区 | 可证边界 | 对G的复用判断 |
| --- | --- | --- |
| layer `qkv_coverage`12288bit／1536B | L_PREP逐真实QKV写置位；layer_start已把低4096改作output_consumed；必须经全部4096真实context响应消费，或显式discard，再加real_idle才回L_IDLE | 最大候选。不能在layer done握手或producer完成时提前交给G；当前E016没有G实例/phase，尚未有物理复用。layer L710–737、1146–1173；parent L1142–1158 |
| Check packed class planes4928bit／616B | 仅reset或下一prepare的check_clear清；error/fault/公开maps在L_IDLE仍保持 | 原错误/覆盖报告退休与validity接口未定前不能叫空闲616B。且当前已是两plane，不能再扣旧三bitmap节省。check L18–29、49–57 |
| RoPE私有416bit／52B | 五个实际债零、FP release、held DONE消费后IDLE，所需错误已由外层Check捕获 | 可研究小phase工作区；必须保留公开done/identity/error及下一start/reset，不能只因无新发射就覆盖。rope L25–46、83–103 |
| parent/layer/front/G绑定的request常量 | 生命周期要横跨所有子lease/实际债/held响应/显式discard | 有一个共有context的候选，但当前各公开模块独立锁存且父未接G；需单owner与typed encoder决定，不自动扣重复身份。 |
| matrix/front（含128×16坐标256B） | front等待真实quant/DIV释放、Awrite债与cancel/publication；matrix保留W预取/PS/双ctx/真实done | **不能按G全生命周期覆盖。** Wi producer与G双slot/math同时活跃；G可取消前缀可进入quant/A，而Down算术要等完整成功G done。坐标、producer失败与真实A债因此同G并存。front L48–52、69–87、93–135；matrix L203–205、252–275 |
| coefficient与A/W cache有效性/coverage | 显式rebind/invalidate，不随算术idle清 | 是跨phase保留状态，不能借作G scratch，否则破坏原表/缓存完整性。matrix L188–200、215–237 |
| parent first-cause与sticky fault | parent error_domain/source_status/tuple保持到done；G原rank tuple与Attention stage tuple不同；context fault仅adapter start/reset清 | 需要phase限定和原错误优先级。当前parent仅将c_fault限定CRUN的修正就是冲突实例；不能把所有错误位直接alias。parent L1114–1159、L1425；adapter L38–51 |

即便只把G compact metadata放入layer coverage，容量投影还差41.25B；额外空间、phase owner、有效性、同拍多写端口与mux本身均未实现/计入。G mask/error能在一拍写多个向量索引，而旧QKV bitmap写模式不同，不能把字节相等当一块单写RAM可直接替换。本报告给所有跨模块复用的已实现节省均记0。

## 原独立数值／服务账保持

G有25600B bounded算术payload（x/gate/result24576B＋pre-credit1024B）、736B固定数值对齐及56mul/16add原叶内部状态，均原账不改。TANH SFU既有tag/mask3328B、credit payload8192B、其余lease/valid与数值core维持原独立物理账；不重做SFU静态报告。原Attention softmax metadata3865B、SharedFP return-tag6144B，及matrix dot tag/valid2328B、half-product raw tag/valid12384B、converter3104B、format129B也照原owner账保留。新增G的tag/eligible/credit即便沿数值路径流动，仍是本次G控制声明，不能转记这些原预算来凑4KiB。

本次无EDA/参考gold/模型/GPU/板测。只运行两次受限只读检查：首轮发现parent版本变化并失败（工具报告墙钟0.02683564s，未取得内层单独时间）；第二次实际子命令 0.072866585s，峰self RSS18048KiB，CPU0–3/nice19/idle/1GiB/单次20s。单独记账累计0.099702225s＜60s；不触碰E017账。除这份md/json与必需agent实际状态报告外，无其它交付或生产写入。


## Current：G-COMPACT-14之后的附加临时工作区核查

本段为当前只读接续；旧映射原样保留。G当前实际15709bit＝1963.625B（AT106），math `85929df54f51dfb1`、pool `01325fa5162b3a44`；engine/pairs保持原SHA。layer `c3e80307f5a941c1`、RoPE `f437587efbec1de0`、private head `4ba9656ecf9097bd`。完整14份引用SHA及逐字段审计见JSON `current_additional_workspace_after_G_COMPACT_14`。无EDA或生产修改，E017账不动。

**未找到≥192B的附加工作区。** 仅复用1536B coverage后仍4173.625B，差77.625B。严格layer＋RoPE的条件候选只有293bit＝36.625B，仍差41B；即使加入pure layer内部无消费者的head私有统计，也只有645bit＝80.625B，裸容量仅剩24bit给新增selector等，不能宣布已fit。

### 可证上界与排除

既有20691bit控制精确分解如下；没有把旧SFU/数值管线或matrix/front/cache有效性移入候选：

| 部件 | bit | 判断 |
| --- | ---: | --- |
| 既有QKV／实际context消费coverage | 12288 | 已议1536B复用，不重复计附加空间 |
| 持久Check | 5058 | 4928 class planes＋97 error/tuple＋33 conflict/fault，继续公开保持，排除 |
| coefficient cache | 1514 | 身份/coverage/held响应跨phase保持，排除 |
| layer／RoPE／head身份 | 647＋128＋128＝903 | 保留绑定/descriptor，未假设公共context改接口 |
| 其它必须保留／当前仍读状态 | 283 | layer173、RoPE66、head/legacy44，详见下表 |
| 有条件的private临时候选 | 645 | 含head352bit；并非已实现物理union |

只看两个指定模块，layer除coverage自身891bit＋RoPE全部416bit也仅163.375B，连身份/持续读取状态都借走仍不到192B。把legacy head计账也纳入，排除Check/cache/903bit身份后的**宽松上界928bit＝116B**，其中仍含不能借的283bit；因此不可能在本边界凭空给出192B。

283bit保留项逐字段为：layer `state4,clock_count32,aborted/protocol_bad/public_read_owned/qkv_complete/context_discarded5,head_completed/head_context_valid32,active_head4,done/rope/context_release_cycles96`；RoPE `state3,family/aborted/protocol_error3,q/k/c/m/a_pending60`；head `state4,owner2,head4,clock_count32`加原resident flags2。特别是layer/head clock_count仍每拍RMW；RoPE的五债比较持续进入resource_debt_clear，sticky abort/protocol还影响IDLE时drain-ready，不能因债数值碰巧为0就称“不读”。公共layer timing/head快照也没有在下一prepare前自动失效。

### 候选字段、寿命和冲突

这里“不读”指**无有效消费者**；某些未valid地址/状态的组合扇出仍存在，表中明确列出，物理实现须隔离。

| 所有者／字段 | bit | 最后有效读与下一次覆盖 | 同拍写／冲突 |
| --- | ---: | --- | --- |
| layer av_groups／av_key | 32／7 | 仅L_HEAD AV返回核coverage；下次head_start清零 | 可同拍group写和key递增，不能变一写端口 |
| layer start_stamp | 32 | 直到最后L_RELEASE退出计算context_release_cycles；下一layer_start覆盖 | 下一次start capture；当前clock_count另存保留 |
| RoPE issued | 12 | IDLE仍组合解地址/tag，但launch=0无消费；下一start清 | 请求、coeff地址有效性须隔离，不能声称零扇出 |
| RoPE cycles | 32 | 只在非IDLE/DONE RMW；下一start清 | active周期递增 |
| RoPE commits | 12 | RUN完成条件；pure layer的r_commits无消费者 | 可同拍commit计数、first_commit和错误记录更新 |
| RoPE done_cycles／first_commit_cycle | 32／32 | 前者仅L_ROPE有效done复制到保留的layer rope_cycles；后者在pure layer无消费者 | release／first commit独立snapshot；独立RoPE接口不自动改变 |
| RoPE error_valid／rank／stage／element | 1／64／5／32 | 有效done时复制到持久Check；rank只作私有择优；之后IDLE且输入隔离无新candidate | 原record原子更新；**下一prepare前必须重臂/清借用record**，Decision可能跳过RoPE，不能把G位当旧RoPE错误 |
| private head start_stamp | 32 | H_QK/SM/AV完成时间差；下一head_start覆盖 | head clock_count仍保留，不借其RMW状态 |
| private head十个32位统计 | 320 | 在pure layer各仅“wire声明＋子实例输出连接”两处，无RTL消费者 | QK、SM、AV及prepare分别并行snapshot；standalone head默认行为不得改 |
| 合计 | **645** | layer71＋RoPE222＋private head352 | 是有条件的局部视图，不是192B |

十统计为done_cycles、qk_cycles、softmax_cycles、av_cycles、first_score_cycle、first_context_cycle、max_feedback_cycles、first_row_cycle、max_sum_tail、max_row_launch_gap。每字段位宽、LSB/MSB和实际引用行在JSON。它们可能已被综合作为无消费者状态删除，故只能作为保守源码容量候选，不能称已经存在80.625B可用FF。

有效交接必须是全部真实context消费，或显式discard已接受，再到layer `L_IDLE&&real_idle`、head `H_IDLE/prepare_ready`、RoPE `IDLE/owner=0`；layer done握手仍太早。反向交接必须等G实际idle、无held输出/done/needs_discard及真实银行/FP/SFU债。回Attention前需targeted rearm私有record，再允许prepare；这些接口/enable修改由主控集中决定，本次未实现。

### 一个具体FF union草图与端口条件

公共arena为原12288bit coverage视图＋645bit附加视图。Attention附加视图按JSON逐字段LSB连续排列；四个FSM/owner、全部身份、持久Check/cache、layer公共快照及两个free-running clocks保持原物理状态。

G base视图恰12288bit：tag_mem4096、numeric/peer/z_good三mask6144、pre-credit tags512、FP pool tags544、expected_tag576、pre_tag240、t_tag112、post_tag[0:3]64。附加645bit为post_tag[4:12]+r_tag160、资格对齐masks432、available[52:0]53。G其余2776bit（含全部已有context/order、pending/live/sent/received和真实FP valid）留在原G控制账；不新复制上下文。只有available的53bit借用，G的pending在外且0时out_valid恒0，实际G cmd的math_clear必须在首接受前清available，防止陈旧结果发布。

这应是**一个packed FF/reg视图、每字段next-state、最外层A/G owner写选择**，不是双份旧reg加一份影子RAM。G tag管线每拍并行移位，多个numeric/peer事件可同拍写不同vector，Attention也有多个独立计数/record写；必须保持源程序同位写优先级。G的无条件tag/mask移位在A owner时要抑制；A旧writer在G owner时也要抑制。不能套成一写一读RAM并声称端口够用。

容量投影为3746＋1963.625－1536－80.625＝**4093B**；示例只加2bit owner（A/TO_G/G/TO_A）为4093.25B，余22bit。若FF视图一拍targeted clear、现有上下文全部保留且无其它新增FF，才有这个算术余量；若需clear counter、额外owner context、错误/握手寄存器、独立取整或pipeline，全部重新计入。新增64bit或128bit context均已超余量。**这不满足所求≥192B安全候选，也不是当前可签的联合4KiB结果。**

### 本轮独立检查费用

新增受限脚本三次，前两次分别为source-delta条目映射错误和把组合`<=`比较误识为顺序赋值；均无EDA/源码修改，真实子墙钟0.127501452＋0.138522403s保留。第三次成功0.067426283s，self峰RSS17204KiB，实际CPU0–3/nice19/idle，单次20s/1GiB。新增累计0.333450138s＜60s；旧映射费用仍单独保留，不动E017账。当前仅交付源码寿命/容量/端口约束，下一步实现接口与实测验收由主控决定。
