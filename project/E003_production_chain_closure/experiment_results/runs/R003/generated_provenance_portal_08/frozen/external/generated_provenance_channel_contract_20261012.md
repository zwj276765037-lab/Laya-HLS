# generated producer物理绑定通道合同

决定：**D-M003-GENERATED-PROVENANCE-CHANNEL-01**；日期：2026-10-12；答复 `generated-source-binding-question-20261012`，适用M003/SM003/E003/R003及M004。

## 1. 决定及被修订的边界

**采用方案2，新增一对内部provenance请求/应答FIFO。producer必须在写入前显式绑定身份，成功完成后再由物理侧确认覆盖和债务。** 不采用后继QUANT给匿名地址覆盖事后命名；同地址、串行次序及末B都不能单独证明其属于所声称的P。

此决定明确修订联合design §3.9“只有两条私有FIFO”的内部接口限制，以及[普通source合同](ordinary_linear_provenance_contract_20261012.md) §5尚无sideband定义的边界。内部controller现在有原compute_cmd/compute_rsp和新增provenance_cmd/provenance_rsp，共四条512bit私有FIFO。新增通道不属于Host ABI，不新增外部BO/寄存器，也不改变compute wire v2、四种compute service或数值op。本文中的CLAIM/BEGIN/END/PUBLISH等是独立通道的控制事件，**不新增publication typed task或TaskDone**。

原13BO外层仍唯一拥有真实AXI仲裁、L13M模型base绑定及一份物理owner/provenance ledger；不得另建一份可与compute服务互相矛盾的READY账本。工程是唯一实现owner。本决定定义接口，不是生成、实现或验收PASS，不增加工具预算。

## 2. 实际端口、容量及顺序

内部C top在现参数后显式追加：

```cpp
hls::stream<ap_uint<512>>& provenance_cmd; // controller输出
hls::stream<ap_uint<512>>& provenance_rsp; // controller输入
```

两者均为实际`ap_fifo`，各depth=2；生成端口须核对din/full_n/write及dout/empty_n/read的真实方向/极性。外层完整连接，不暴露给Host，不以理想TB回复替代实际接收器。新端口、所有层级声明、生成配置和绑定脚本进入同一生产源码闭包。

provenance request固定1024B/16beat，response固定512B/8beat，均按byte0先发、每beat低8bit为较低地址byte。接收端各一份完整request/response槽；另最多一份活动BEGIN的不可变绑定快照。一次最多一个未应答event、一个活动generated producer task。禁止BEGIN嵌套、跨typed task拼匿名覆盖、无限事件队列。

每个event必须完整收到并校验后执行；完整response被caller接收后才能开始下一个event。BEGIN成功应答只开放**这一条**typed producer；END应答关闭它。producer活动期间compute不得发射，metadata事件只在两个执行路径均处安全边界时处理；END是关闭活动producer的例外，不能因等待“无活动producer”而死锁。原compute父lease可按合同持久保留，但不得与不相关generated writer重叠。

保守新增控制payload为1024+512+2×2×64+1024=2816B；加原compute的1792B，共4608B。BEGIN快照可无损压缩，但C序列化副本、coverage/错误/owner状态、AXI适配器与数据暂存另计；该数字不是综合资源或零额外成本。单活动task的覆盖检查有界，不增加tensor数据缓存。

## 3. request v1完整编码

全部偏移为byte半开区间，整数LE；Context/Ref/NumericIdentity沿现显式字节编码，禁止C struct内存拷贝。协议magic与compute分离。未使用字段及所有保留位必须零。

| 范围 | 字段 |
| --- | --- |
| `[0,4)` | magic u32=`0x3156504c`，字节ASCII `LPV1` |
| `[4,6)` | version u16=1 |
| `[6,8)` | action u16，见下表 |
| `[8,16)` | event_seq u64非零，每event严格递增 |
| `[16,20)` | task_id u32；BEGIN/END等于Context.task_id，metadata事件为0 |
| `[20,24)` | flags u32=0 |
| `[24,26)` / `[26,28)` | request_beats u16=16 / response_beats u16=8 |
| `[28,32)` | reserved=0 |
| `[32,40)` | origin_seq u64；BEGIN等于本event_seq，END精确引用已接受BEGIN.seq，其他事件为0 |
| `[40,42)` | reported_status u16；仅END携带原typed计算的逻辑Status，其他事件=0 |
| `[42,43)` | reported_unit u8；仅END携带原逻辑TaskDone单位，其他=0 |
| `[43,44)` | reserved=0 |
| `[44,48)` | reported_elements u32；仅END有效，其他=0 |
| `[48,52)` | reported_error_detail u32；仅END有效，其他=0 |
| `[52,56)` | reserved=0 |
| `[56,64)` | reported_bad_element u64；仅END有效，按原TaskDone取值，其他=0 |
| `[64,148)` | 完整NumericIdentity，84B |
| `[148,160)` | 原typed TaskContext，12B；metadata事件全零Context |
| `[160,576)` | 当前canonical L13M v1，416B；所有事件必填并核验 |
| `[576,577)` | descriptor_count u8，1或2 |
| `[577,578)` | reserved=0 |
| `[578,579)` | expected_unit u8；BEGIN/END=F32(1)，metadata=0 |
| `[579,580)` | reserved=0 |
| `[580,584)` | expected_elements u32；BEGIN/END为实际typed任务规定完整输出元素数，metadata=0 |
| `[584,592)` / `[592,600)` | issued_store_bytes[0/1] u64；仅END有效，见§7；其他=0 |
| `[600,608)` | reserved=0 |
| `[608,736)` / `[736,864)` | 两份128B owner descriptor；未使用的第二份全零 |
| `[864,928)` / `[928,992)` | 两份64B write geometry；BEGIN/END使用，其余事件全零 |
| `[992,1024)` | reserved=0 |

| action | 值 | 语义 |
| --- | --- | --- |
| CLAIM | 1 | 显式建立目标owner及完整期望覆盖；old_ref非零表示原合同允许的原地更新开始 |
| BEGIN | 2 | 绑定将要执行的真实typed producer、目标Ref/epoch及本task写范围；通过应答后才允许其写 |
| END | 3 | 报告同一typed任务的逻辑终态与实际入队store字节数；物理接收器核覆盖和drain后应答 |
| PUBLISH | 4 | 请求全tensor/双owner原子发布，物理侧独立核全部覆盖/成功/债务；并非自报READY |
| RELEASE | 5 | 原合法owner release；有读者/待返/被引用证明时拒绝或依原规则保留必要引用 |
| INVALIDATE | 6 | 撤销指定owner/epoch资格；不清真实债务，不替代活动task的END/安全取消 |

BEGIN/END必须是真实已有op的合法Context；本版只包装有外部F32输出、实际进入原typed dispatcher的非compute producer。无m_axi输出的内部缓存任务不伪造geometry；Host CPU原始输入沿原导入合同，不冒充FPGA typed生产。compute LOAD/G/QUANT/MATRIX自身不再套一层BEGIN/END，其真实生产事件直接进入共享ledger。

只在BO-backed owner的实际claim/发布/释放边界发metadata事件，不能给所有内部`full_owner`调用盲目加hook；例如AV内部片上partial/prob发布不发送嵌套事件。task函数内暂存的逻辑owner更新不得提前成为物理READY，相关外部PUBLISH移到该task END确认之后。

END的NumericIdentity、L13M、Context、descriptor_count、expected_unit/elements及全部descriptor/geometry须与活动BEGIN逐字节相等；仅帧header、逻辑终态和issued_store_bytes按表变化。不得在END改Ref、缩范围、换P或补头；origin_seq不是task_id算式。

## 4. owner descriptor与write geometry

### 4.1 每份owner descriptor的128B

| 相对范围 | 字段 |
| --- | --- |
| `[0,8)` | target_ref：沿portal Ref格式，含region及末字节零 |
| `[8,16)` | old_ref：正常claim为全零；原地更新为明确旧Ref/region |
| `[16,17)` / `[17,18)` | owner stage / layer，来自真实FullOwnerSpec |
| `[18,19)` / `[19,20)` | owner batch（255表示全部活动batch）/ row_space |
| `[20,22)` / `[22,24)` | owner row0 / rows，u16 |
| `[24,26)` / `[26,27)` | logical width u16 / Content u8 |
| `[27,28)` | layout u8：0=原普通F32布局，1=原QKV双shard布局 |
| `[28,29)` | 实际BO role u8，必须由该Ref/region的原映射导出 |
| `[29,32)` | reserved=0 |
| `[32,40)` | bo_span u64，原13BO对应合法容量 |
| `[40,48)` | owner_base_offset u64，BO内offset；QKV为该shard在原布局中的基点 |
| `[48,56)` / `[56,64)` | row_stride / batch_stride，u64 |
| `[64,72)` | owner_extent_span u64：从上述基点到本owner原布局所需最后字节的最小包络，含布局空隙但不把空隙算已生产数据 |
| `[72,80)` / `[80,88)` | head_stride / plane_stride，u64；普通F32为0，QKV沿原映射 |
| `[88,128)` | reserved=0 |

以上值不是caller自由地址授权。hub独立依据原内存映射、完整Ref/region、shape、B/S、stage/content及L13M核对角色/布局/范围，用锁存13BO base形成物理地址，65bit检查加法溢出。动态S不得缩小原固定TOKEN batch stride。相同owner后续事件的描述必须完全一致；原地时old/new配对只按原白名单、epoch高水位及真实lease建立。

CLAIM/PUBLISH/RELEASE/INVALIDATE的两个descriptor仅用于原QKV pair，必须是实际bank0/bank1两个Ref，按该顺序处理并原子成功/失败；其他owner事件descriptor_count=1。BEGIN/END允许两个**合法、不重叠写集合**，可以是不同owner，也可以是同一owner的两份相同描述，例如RoPE同shard的Q/K分别写。重复owner descriptor不等于重复claim或独立epoch。已完成原地commit后，后续新消费/变换使用old_ref=0的新正常描述；提交前END/PUBLISH保持原old_ref，不能提前丢失旧证明。

### 4.2 每份write geometry的64B

| 相对范围 | 字段 |
| --- | --- |
| `[0,8)` | first_offset u64，BO内第一个实际写segment起点 |
| `[8,12)` | segment_bytes u32，非零且为4的倍数 |
| `[12,14)` / `[14,16)` | row_count / repeat_count，u16非零 |
| `[16,24)` / `[24,32)` | row_step / repeat_step，u64；count=1时相应step=0 |
| `[32,40)` | total_write_bytes u64，必须等于segment_bytes×row_count×repeat_count |
| `[40,41)` | component_kind u8：0=普通全宽，1=ATT_HEAD，2=QKV_PLANES |
| `[41,42)` | head u8，ATT/QKV为实际0..15，普通为255 |
| `[42,43)` | plane_mask u8，仅QKV使用bit0/1/2=Q/K/V，其余=0 |
| `[43,64)` | reserved=0 |

允许写集合精确定义为所有 `first_offset + repeat*repeat_step + row*row_step + byte`，其中byte<segment_bytes；加法/乘法均检查溢出，segment之间和两descriptor之间不允许地址重叠。所有集合必须属于对应owner、本TaskContext的batch/行以及实际op合法分量；geometry必须由同一实际typed task及原地址函数生成并在hub复算，不接受“能装进BO就合法”。本版task.rows≤16，单task总写字节不超过16×5248×4；普通全宽geometry对应完整K/N，不能自行缩小。

AV只列实际head的64列；RoPE列同head的Q/K写集合（可用两descriptor），不列V为新写；V按旧pair已发布证明继承。当前可用映射举例不改变原数值/布局。完整owner期待的head/plane/row集合在CLAIM时已由owner类别固定，不能由BEGIN临时删减必需分量。

coverage必须检查每个实际WSTRB字节恰好属于本task、成功路径覆盖完整且不重复；零WSTRB填充lane不计数据。可用有界位图或经证明的每segment有序游标＋partial-byte mask，不能仅比较累计字节数。最大活动task的字节位图保守上界335872bit，实际压缩、双端映射及开销须报告；历史owner/window证明仍沿普通source合同有界管理。

## 5. response v1完整编码

| 范围 | 字段 |
| --- | --- |
| `[0,4)` | magic u32=`0x3141504c`，字节ASCII `LPA1` |
| `[4,6)` / `[6,8)` | version=1 / 原action，u16 |
| `[8,16)` / `[16,24)` | event_seq / origin_seq，u64精确回显 |
| `[24,26)` | 最终Status u16，沿原Status枚举及错误优先级 |
| `[26,28)` | flags u16：bit0=DRAINED，bit1=SCOPE_ACTIVE，bit2=OWNER_PUBLISHED，其余0 |
| `[28,32)` / `[32,40)` | error_detail u32 / bad_element u64，沿原错误编码 |
| `[40,44)` / `[44,45)` | 本事件确认的output_elements u32 / OutputUnit u8；仅成功END为原typed输出，其余0/NONE |
| `[45,46)` / `[46,48)` | descriptor_count u8 / reserved=0 |
| `[48,56)` / `[56,64)` | 两descriptor实际观测的store字节数u64；仅END有效，其余0 |
| `[64,148)` / `[148,160)` | NumericIdentity / 原Context原样回显；metadata Context全零 |
| `[160,168)` / `[168,176)` | descriptor0 target_ref / old_ref |
| `[176,184)` / `[184,192)` | descriptor1 target_ref / old_ref；未使用全零 |
| `[192,512)` | reserved=0 |

caller核action/seq/origin/完整NumericIdentity/Context/四Ref/descriptor_count及状态字段；每次只一个outstanding，原BEGIN全绑定由caller和接收器各自保留，响应不另塞416B L13M或geometry。BEGIN成功时DRAINED=1表示前一阶段实际排空，SCOPE_ACTIVE=1；END成功/已安全退休的失败时DRAINED=1、SCOPE_ACTIVE=0。OWNER_PUBLISHED只有成功PUBLISH置1，END闭合某窗口不置此位。

错误仍须保留首次错误及原优先级。逻辑错误和外层RRESP/BRESP/协议错误归并，不能因C报告OK而覆盖物理错误；已观察非法总线事务按现工程错误映射进入非OK，不发明新的Host状态码。无法证明drain时不得返回带DRAINED的终态或允许下一绑定；timeout/guard停止不能伪装成完整response。

## 6. 完整生产/发布流程

1. **CLAIM**：在首个相关producer之前登记准确owner/期望tensor范围；先完成原逻辑检查，发送并等待物理应答，再允许外部写入。正常进入FILL；原地检查旧owner已发布、无冲突读者及合法old/new Ref，建立独占lease。QKV pair原子处理。全tensor元数据此时没有覆盖，不因claim变READY。
2. **BEGIN**：dispatcher从已分配的原typed task构造此帧，实际执行必须使用同一任务对象/绑定。外层核身份、owner、合法任务顺序/重复、geometry及此前所有controller/compute/adapter债务，安装不可变活动绑定，再应答。caller收到完整成功应答后才进入相应计算和写输出代码。
3. **真实执行**：外层在AW/W发生时已经知道P/Ref/NumericIdentity，按活动geometry核每个写字节、绑定每条burst和最终B；不以未来QUANT来命名。普通数值任务和模型输出不改，读写都保留真实RRESP/BRESP。未获BEGIN的protected workspace写不得进入HBM。
4. **END**：原任务停止产生新工作后提交逻辑终态及issued_store_bytes。END不是真实完成宣言。外层等待已入队的写全部显现、覆盖/响应/适配器排空并归并错误，才确认该task终态；成功贡献进入共享coverage，在覆盖首次闭合时保存真实原Context为P。失败不贡献成功窗口，目标INVALID。
5. **typed退休**：Controller收到并验证END真实终态后，才最终发布该typed TaskDone和来源记录。必要时把现`finish`拆为逻辑结果准备与最终退休，不能预先把C的`drained=true`用于物理成功；原任务只退休一次、op_calls只计一次，失败仍沿原语义计数。禁止逻辑done与END各计一次。
6. **PUBLISH**：完成所有task后，在原full_publish/commit位置发送metadata事件；物理侧独立检查全部batch/window/head/plane成功、所有债务零、旧lease消费/新写完整且无sticky失败，才原子发布并应答；C侧随后完成READY镜像。已有source窗口P保持原值。提前PUBLISH、缺head、错误pair、仅C covered/READY均被拒绝。
7. **Q/L**：之后普通QUANT从共享物理ledger取得已发布窗口凭据，核P/Ref/范围并真实读；A冻结来源，MATRIX核A及原父lease。合法原地旧epoch读按普通source合同，不能因当前owner处EXCLUSIVE_RW一概拒绝，也不能向无关消费者开放。
8. **RELEASE/INVALIDATE**：在对应原owner生命周期位置同步物理和C状态，真实读写债和父/A引用未退休时不得重用证明存储。原地完成及QKV原子commit由带old_ref的PUBLISH表达，不另造typed任务。

CLAIM/PUBLISH等可以覆盖由compute native服务写出的同一owner：native服务必须识别同一已登记owner，不重复claim或建立另一epoch；native producer completion直接更新同一ledger。G/Down现有明确P/Q/L预约和原物理覆盖规则保留，不能用sideband END为native结果补造一次生产。

## 7. AXI与HLS排序：必须关闭的实际边界

**两个方向的握手均有因果作用。** BEGIN成功应答是执行控制依赖；不得仅把BEGIN写进FIFO后立即写payload。END成功应答是后继task/owner切换依赖；不得只发送END便让下一task开始。实际生成RTL必须证明这两项，不凭C源码顺序、`ap_idle`或固定等候周期推断。

HLS可能把C store送入内部队列后才发外部AXI。因此END携带两个`issued_store_bytes`，来源是本task向generated memory-store路径**实际完成入队**的有效字节计量，与对应descriptor一一绑定；它不是期望循环次数、不是物理成功字节数，也不是TaskDone.output_elements在失败时的0。成功END必须等于两geometry的完整字节数；失败END保留真正已入队的部分字节数（可为0）。计数不回绕，未使用descriptor为0。

这里“入队”指真实store提交入口已经接受、必须完成或显式错误终止的工作承诺，不要求C读取工具未暴露的内部FIFO状态。允许在实际执行的production store helper逐次累计提交字节，并将此计量作为END的真实数据/控制依赖；该计数仅说明待退休工作量，不能证明已经到达AXI引脚或写成功。生成后必须证明此提交计量与实际有效WSTRB字节守恒；合并写按有效字节对应，不能用预先填好的期望总量替代失败短路计数。

外层分别统计实际WSTRB字节、唯一覆盖与B结果；错误/重复/被拒事务也单独计入已入队工作的排空账，不当作成功coverage。只有所有已入队store均已完成真实总线退休或明确的本地错误终止，外加所有AR/R、AW/W/B、converter/holding/生成adapter待发项归零，才封闭BEGIN。不能在END到达时看到外层debt=0就直接关闭；尚未出现在引脚上的posted store也属于旧绑定。

非法地址若不能归入任一descriptor，记独立rejected-store排空计数；失败关闭时将它与所有实际接收的store字节共同核对END的总入队量，不能漏计而永久等待某descriptor的成功coverage。成功END仍要求每descriptor分别精确计量、完整唯一覆盖且没有rejected字节。原地任务的旧数据消费也须来自相应真实R返回或native QUANT完成的旧窗口读证明；PUBLISH不能靠C的old_consumed位绕过读后写次序。

工程须在真实生成闭包中落实并验证store入队计量与END排序（允许依实际HLS写适配实现选用等价的显式排空fence），冻结它与生成master请求/返回状态的对应。END之后不得再产生未被其计量/排空fence覆盖的旧task请求；read prefetch、部分burst、合并写及失败短路同样在此范围。不能把C变量置1当作adapter idle，不能凭一段总线静默推定内部空；未证明该关系的生成版本不启用普通source物理路径。此项是本接口的实现义务，不要求另行用户审批或扩大预算。

监视/计量在有限宽度转换前后选择一个权威边界，并保证另一侧完整子beat债务归并，禁止重复计数。AW/W独立到达：没有可用AW地址绑定时不得把W无名发给HBM，可有限缓冲或反压，且保留所有已提出VALID/payload。已有`laya_axi_owner_v1`允许W先于AW，不能据此漏掉新provenance层的地址核验。

越界/未授权写在转发前拒绝；如果generated AXI需要完成这个被拒事务，允许有限AXI错误终止器消费完整本地事务并返回真实的本地DECERR/SLVERR，明确记录“未到HBM/失败”，不得返回OKAY或增加成功coverage。已经被外部接受的事务必须等真实R/B，不得伪造响应。正常模型/IO前导读取及请求/结果IO按原owner规则处理，永不被转为普通source写证明；protected workspace的generated写必须有活动BEGIN。

绑定正确性以受控、冻结的generated dispatcher为逻辑任务权威：同一个任务对象供给BEGIN和实际算子调用，物理侧独立检查覆盖/地址/错误/退休。该通道不声称能通过地址与Context重新计算数值算法或防御恶意替换的controller；数值仍由原独立gold和当前生成闭包验证。

## 8. seq、取消及恢复

provenance通道使用独立u64分配高水位`H_prov_alloc`与接收封闭高水位`H_prov_closed`，不与compute g混用，也不使用task_id做event序号。每条CLAIM/BEGIN/END/PUBLISH/RELEASE/INVALIDATE各取新seq；BEGIN和END不是同一seq，END.origin精确指向BEGIN.seq。management事件不消耗typed task_id，compute命令计数不变，新增event计数单列。

共享ledger在每个完整NumericIdentity下统一记录已接受producer/native task的typed次序：新BEGIN及新的native typed task必须晚于已观察的typed高水位；内部无外写任务可形成ID空洞，不要求物理侧看到连续ID，也不为缺号伪造TaskDone。已有同一Linear父的后续view走原parent键/覆盖规则，不作为新typed task，不能让普通BEGIN冒充合法重复view。metadata事件不推进此typed高水位。请求排空撤销后可按新NumericIdentity建立新的typed记录，两个event/command高水位仍跨请求保持。

seq分配后不回收，软取消、request generation切换和同session新request均不清高水位。可信首拍由LPV1/version/action/长度/flags/保留位和action对应task_id/origin合法性判断；可信fresh首拍即使后包失败或取消也在安全封闭时耗号，坏头的大seq不得污染高水位。处理方式沿原generation合同，metadata的task_id=0是此新协议的明确例外。完整身份/geometry校验仍在整包后，首拍可信不允许产生物理owner副作用。

取消在BEGIN安装前：不产生任何该producer的AXI工作，清理部分包/FIFO需与caller停止提交协调，不能把旧字节当新header。BEGIN一旦安装或成功应答，取消先使source/待发布资格无效并停止后继task；旧绑定、地址检查和真实债务仍保留到安全排空。

**活动producer采用协作式停止：保留generated执行及适配器的排空能力，允许当前已获准typed task收束至END/明确fence，再返回取消失败。** 不在它仍可能持有部分AW/W或待发store时硬复位generated controller。取消不是要求丢弃已经无法撤销的写；这些写仍归旧task并污染为INVALID，不能覆盖新owner。当前task无法结束/无法证明终止时保持隔离和未知终态，不复用资源，不伪造drained或TaskDone。

BEGIN应答尚未完整消费、END/response背压、两拍FIFO待pop、trusted header取消、QKV一侧尚有B、旧lease读债等边界都按同一规则。活动scope内坏END/错origin不能释放绑定：保留协议错误，依现请求取消/fence安全排空，不能把错误包当正确闭合证据。正确终态响应安全交付/废弃后才清scope槽。

同session更大request_id恢复前，旧request所有活动scope/native command/FIFO/response和债务必须排空，撤销其window provenance/未来tickets；新记录以完整NumericIdentity区分。L13M五模型base绑定及compute/provenance高水位保持。只有全域安全冷初始化能同时清两通道、caller、hub和缓存/ledger；仅reset其中一个endpoint或重建Host对象不成立。

## 9. 受影响验证与证据层级

工程连续完成以下现授权内工作，无新增逐步审批：

- C/SV独立字节oracle，全部action/布局/零保留位/畸形帧；seq及origin、防重放、END与BEGIN完整比较、response绑定。元数据事件不伪造typed计数。
- 从当前真实生产内部top重新生成四FIFO，核12条FIFO信号、极性/depth及外部13BO/全部原控制offset不变；不能把旧六信号probe称为新接口通过。
- 真正generated producer→外层AXI监视→共享ledger→QUANT：BEGIN应答反压时无提前写；END遇最后B、内部posted store或R/adapter债务不能提前成功；成功和逻辑失败的部分入队计量均有对照。CPU受控ACK只能签metadata，不签此项。
- 错P/Ref/request/model在BEGIN或后继Q比对拒绝、写范围/重复/额外WSTRB、W先于AW、跨4KiB/宽度转换、RRESP/BRESP及本地错误终止；身份从BEGIN保持到最后返回，不能借后继Q改名。
- 16-head多窗口Attention、QKV pair/RoPE、普通LN/向量与SCORER原地旧source→A→新写、跨batch及同session取消恢复。P仍按原窗口闭合事件保存，PUBLISH必须等待整个tensor。
- 最终C/RTL/generated/model依赖同步冻结并完成受影响回归；当前完整CPU/实际CSim、物理完整请求、资源/性能分别报告。单纯FIFO probe、控制面PASS不代签整图。

记录新增BEGIN/END/metadata握手周期、等待末B/fence的停顿及metadata资源，为后续完整请求性能优化提供实际依据；不宣称新增通道本身带来加速。不能以性能理由删除命令应答或覆盖检查；将来若批量化，须有等价身份与排空证据。

主控本次核对28份只读依据/preimage，以及`portal_fifo_probe_04`、`portal_controller_11` receipt的6项直接SHA引用，均匹配，见[依据记录](generated_source_binding_decision_20261012/verification.json)。前者只证明旧512bit ap_fifo六信号，后者只证明受控service响应的C++控制/来源metadata路径；本轮未核全部manifest依赖或运行工程实验。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；组合full NOT_RUN_COST继续保留。原CPU/内存/墙钟/周期帽、单重工具及G OOC余2338.224019s不变，无新增OOC/P&R/上板授权。
