# 原13BO生产门户的416B模型身份合同

决定：**D-M003-MODEL-IDENTITY-13BO-01**；日期：2026-10-11；答复 `model-identity-question-20261011`。

适用 M003/SM003/E003/R003 的生产 caller/hub、相依集成及 M004。主控冻结字段与生命周期，工程按已有授权实施；本文不是实现或验收 PASS。原13BO/AXI-Lite ABI、门户 wire v2 的1024B/512B包长及字段偏移、单持久服务、数值/shape和全部预算不变。

## 1. 决定与依据

**原13BO生产门户采用专用 `L13M` 子格式 v1，不采用Q8S2注册描述符的逐字节编码。** `Command::model_identity` 仍为416B，包内范围仍为 `[200,616)`。四种service一律使用同一格式及同一个当前模型常量。只有本字段内部含义由本文明确；不占用包尾保留区，不增加外部端口、BO、寄存器或REGISTER_MODEL命令。

模型内容身份与物理分配绑定由两部分共同成立：caller与hub使用当前生成模型包的固定内容身份；RTL外层对五个模型BO保持**整个持久服务冷启动生命周期不变**的实际基址绑定。该绑定不随request generation切换或软取消重建。更换模型、重新上传或重分配任一模型BO，必须先安全排空并重新冷初始化整个服务。禁止用固定假generation/cookie冒充已注册Q8S2会话，也不把request generation当model generation。

已核依据：

- 原联合design §3.9规定外层镜像原控制寄存器并按role+offset/span形成物理地址；C指针不是物理地址。§4明示Q8S2为独立候选ABI，未替换原13BO。
- 现Q8S2 fixture的 `register[32:48]+register[64:152]` 是 **u32 word切片**，不是byte切片；共104 words，按每word LE序列化为416B。
- 现dual-W仅在LOAD准入显式读取旧字段的profile和非零model generation，同时把完整3328bit存储/比较；AUX期待头另为128B。这两处旧字段解析不能无条件用于新格式。
- 当前生成头可供给四tag、source SHA256、五个模型BO精确字节数；原13BO没有Q8S2 context/allocation cookie和完整注册记录的供给路径。
- 原Host常驻合同已有五模型BO固定分配/只读、单请求在途及未知终态不释放；但可移植Host策略的attestation标志和历史fe067专用检查不是当前生产XRT验证证据。

源与合同preimage的28份快照及SHA见[只读依据](model_identity_13bo_decision_20261011/verification.json)。实现真源仍在 `project/E002_Laya_HLS/experiment`，主控不修改工程源。

## 2. 完整416B编码表

下表均为相对 `MODEL_IDENTITY` 起点的**byte offset**，半开区间；包内绝对位置为200加相对位置。整数LE；tag/digest按生成头数组的原始字节顺序复制，不倒转字符串/word，不序列化C++ struct。SV向量低8bit对应相对byte0。

| 相对范围 | 长度 | 字段及唯一合法取值/来源 |
| --- | --- | --- |
| `[0,16)` | 16B | model_tag：当前 `kFullModelTag` |
| `[16,32)` | 16B | numeric_tag：当前 `kFullNumericTag` |
| `[32,48)` | 16B | layout_tag：当前 `kFullLayoutTag` |
| `[48,64)` | 16B | build_tag：当前 `kFullBuildTag` |
| `[64,68)` | 4B | magic，u32 `0x4d33314c`，字节为ASCII `L13M` |
| `[68,70)` | 2B | 子格式version，u16=1；与外层wire v2独立 |
| `[70,72)` | 2B | identity_bytes，u16=416 |
| `[72,76)` | 4B | validation_profile，u32=0，STRICT；其余值拒绝 |
| `[76,80)` | 4B | binding_policy，u32=1，FIXED_MODEL_BOS_UNTIL_COLD_RESET |
| `[80,112)` | 32B | source_gguf_sha256：当前 `kFullSourceSha256` |
| `[112,116)` | 4B | model_bo_count，u32=5 |
| `[116,120)` | 4B | model_bo_entry_bytes，u32=16 |
| `[120,124)` | 4B | model_bo_table_offset，u32=128，相对本字段起点 |
| `[124,128)` | 4B | reserved，必须全零 |
| `[128,208)` | 80B | 五个16B记录，按下面固定顺序；不能交换/省略 |
| `[208,416)` | 208B | reserved，必须全零；无隐式扩展、地址或cookie |

第i条记录起点 `e=128+16*i`：`[e,e+4)` 为role u32；`[e+4,e+8)` 为flags u32=1（READ_ONLY，其他bit=0）；`[e+8,e+16)` 为model_bytes u64，精确等于 `uint64_t(kFullModelBoSizes[i])`，不是Host allocation容量。

| i / 相对范围 | role | 生成头大小索引 | 当前观察值（byte） |
| --- | --- | --- | --- |
| 0 / `[128,144)` | EMBEDDING=0 | 0 | 54803648 |
| 1 / `[144,160)` | W_Q0=2 | 1 | 184682496 |
| 2 / `[160,176)` | W_Q1=3 | 2 | 184680448 |
| 3 / `[176,192)` | W_SCALE=4 | 3 | 23085184 |
| 4 / `[192,208)` | AUX=5 | 4 | 1671872 |

当前数值来自 `build/model-current-production-20261011/laya_model_layout_generated.h`，该文件当时的build tag为 `d590d9a1d2ce20523a513356f6c0d0fa`。表中观察值用于核对；生产编译必须取**本次最终build实际选用**的生成头，并与包、AUX、C/SV共同冻结，不能因本文引用了旧build而继续硬编码旧tag。模型内容/尺寸未改变时沿用原值；源码闭包变化按原build身份机制更新，不把历史包改名为新包。

该416B中**没有**model generation、context cookie、validation-record/manifest/candidate-build完整SHA256、物理base或allocation cookie，也不为这些信息规定“写零待patch”的暗槽。保留区的零仅表示保留；Host验证记录继续是已有包/部署证据，不声称已通过本字段送入硬件。READ_ONLY和profile是协议要求，不是调用者自报验证成功。

## 3. 权威供给与比较

### 3.1 caller及生成常量

generated caller从当前生成模型头构造唯一canonical416B；C与SV共享上述显式偏移/常量定义及同一生成包来源。所有LOAD/QUANT/MATRIX/GEGLU builder只使用这一canonical值。不得从请求自由字节、C指针整数值、Q8S2 fixture、随机cookie、task_id或portal g推导模型身份。

`NumericIdentity`的四tag必须分别等于本字段前64B，也必须等于当前生成常量。request_id、request generation、B/S、P/Q/L、Ref/epoch及每command g仍走原v2绑定检查，不写进MODEL_IDENTITY。相同模型在不同请求、G/Q/L阶段和父view间MODEL_IDENTITY逐字节相同，这不允许忽略其他实体/命令身份。

### 3.2 hub与持久实体

hub持有从同一生产包生成的可信canonical常量。整包校验后、产生该命令任何RAM/AXI/owner/lease副作用前，先核L13M格式、所有固定值与零保留区，再核**整个416B精确相等**及NumericIdentity四tag一致。不得把收到的首条命令内容登记为“可信模型”，也不允许只核四tag或非零字节。尚未建立合法物理模型绑定时也不得发射service。

缓存、预约、source provenance、GATE/tensor ledger、父A/W lease仍保存或等价无损关联完整模型身份，并在各自原有实体键中比较；两级门控不能互相替代。LOAD成功之前不建立READY；QUANT/G/matrix的模型身份相同不等于来源已经生产。release/cancel只能作用于实际持有的旧绑定，不能用错误新模型字段清掉其他实体。

响应继续使用现有512B编码及完整命令g/service/context/view/Refs绑定。caller保存实际outstanding命令的canonical身份，结合唯一活动槽与响应核验关联本次模型；不新增416B response echo，不借response保留位传model generation。

### 3.3 AUX和数值检查

LOAD的 `EXPECTED_AUX_HEADER` 必须等于当前生成包的canonical128B LYMP v1头：bytes0..19沿原magic/version/header_bytes=128/bo_count=13/原固定值，20..31为零；32/48/64/80处四tag及96..127 source SHA与MODEL_IDENTITY一致。AUX header读取offset=0，必须来自已绑定AUX角色的真实物理读取；逐字节比较和真实R债务退休保留。不能让caller任意提供一份“expected”头而hub只检查实际数据等于该任意值。

STRICT保留现有完整scale合法性、bias、量化及全部数值检查；本决定未启用VALIDATED_STATIC_MODEL_V1，不把原13BO生产路径升级成Q8S2 fast profile。Host包校验、原完整模型头校验也不因canonical常量存在而删除。

格式magic/version/长度/固定结构/保留位非法按现有E_ABI拒绝；结构合法但模型tag/source/精确尺寸与当前包不匹配按现有E_MODEL拒绝；request/task/ref/g错误沿原E_PROTOCOL等规则和已有错误优先级。物理模型绑定冲突不能产生成功或publication；相关错误按现有请求错误/排空路径传播，不增加外部状态码。可信首拍耗g仍按generation合同执行，后续模型拒绝不能让g重用。

## 4. 原13BO物理绑定生命周期

### 4.1 外层持久绑定

外层保留原13BO AXI-Lite镜像和每请求一致快照，再为模型角色0/2/3/4/5维护一个持久绑定记录：五个真实u64 base、bound有效位及必要错误状态。模型尺寸来自同一canonical生成常量，不从C指针或命令任意span推定实际allocation容量。

安全冷初始化后为UNBOUND。第一次接受实际ap_start的完整13BO快照时，核原role/对齐/range及base+精确model_bytes的u64溢出规则，建立五模型base绑定；必须在任何依赖该绑定的模型访问/compute命令准入前成立。bound仅表示地址生命周期已锁定，不表示请求、模型内容、AUX读取或W LOAD已通过。第一请求后续失败不自动解除该绑定。

每次后续ap_start的五模型base快照必须与bound记录逐role完全相等。原13BO镜像仍按实际AW/W/WSTRB更新，运行中AXI-Lite写入不得改变已锁存活动地址；变化仅能成为下次提交的候选。错误新base不得覆盖旧bound或用来命中旧W缓存，也不得通过fallback路由到另一模型后继续报告成功。准入拒绝及原错误返回必须有真实受控路径，不得把blocked模型访问伪造成成功R/B来喂给controller。该约束须在生产封装接入时落实并验证，现有base mirror自身尚未证明持久模型绑定。

IO及workspace的地址按原每请求锁存/owner-drain合同管理，本字段不增加它们的模型记录，也不扩展Host原有分配/复用授权。模型命令仍只送role+offset/span；所有物理地址由绑定记录及本次一致快照形成，先核范围/溢出。外层**不patch MODEL_IDENTITY任何字节**。

### 4.2 不改变绑定的事件

普通请求结束、同session更大request_id、提高request generation、数值失败、软cancel/drain、FullRuntime请求回收均不改变五模型base或canonical身份，也不重置门户H_alloc/H_closed。它们按原合同清理受影响任务、覆盖、valid及租约；允许的W驻留仍必须通过原完整键核验，不能把“模型未变”当作复用任何旧task/epoch的许可。

模型字段错误命令仅按实际错误路径拒绝并清理自己已拥有的状态；不得清空全service高水位或悄悄重新绑定。主动尝试更换模型/模型BO属于本服务生命周期外操作，Host停止提交，先完成下述安全冷启动边界。

### 4.3 唯一重新绑定边界

改变模型包/tag、模型内容（包括重新上传相同字节）、任一模型BO分配或物理映射、设备/context失效，都不能在原bound状态继续。Host须先停止新提交并确认所有旧工作实际终止，排空全部已接受R/B/FP、转换器/owner held项、FIFO和响应，再对caller、transport、hub及全部A/W/GATE/PS/ledger执行同域冷初始化。冷初始化使所有旧cache/lease/预约有效位失效并清除bound；未完成排空时不能通过清寄存器假装冷启动。平台无法证明安全终止则保持不能复用，沿原Host Poisoned/未知终态所有权规则处理。

只有此边界才能同时重建模型binding并按原generation合同初始化全service高水位。仅重建Host对象、ap_start、soft reset或reset某个cache都不成立。重新建立模型binding之前，Host按原合同重核当前包与kernel身份、真实五BO容量/内容和生命周期；本定义不新增Q8S2 REGISTER/REVOKE或18beat binding输入。

旧命令/响应不得越过冷启动边界重新送入：冷启动必须清理源端待发计划和两条私有FIFO，确认物理返回已排空。MODEL_IDENTITY无model generation成立的前提正是旧世界没有可再次命中的存活实体；不能只清base有效位而保留W READY或旧response。

### 4.4 保证与限制

五个固定base由外层实际镜像供给；BO真实大小、分配对象是否更换、同地址重分配/内容改写由受控Host生命周期负责。原13BO没有allocation cookie输入，硬件不能仅凭相同base区分同地址ABA重分配，也不能用128B AUX头证明全部模型字节的SHA。不得声称该格式具备Q8S2注册/读回认证或防御恶意Host的能力。

这与原固定只读模型部署边界一致；实际XRT绑定、完整模型包校验及设备结果未做时仍分别标未验证。Host attestation布尔值、生成常量、TB静态base各自不能代签这些事实。持久五base至少320bit加有效/错误状态须纳入真实metadata和联合资源，不因为wire包长不变就称零成本。

## 5. Q8S2兼容边界与受影响验证

旧Q8S2候选保留原编码、注册生命周期和历史证据。共享dual-W等模块须显式区分**实例的固定身份格式模式**：历史Q8S2诊断实例维持其原规则；原13BO生产实例固定L13M v1，严格拒绝Q8S2身份，不能由单条命令自动切模式。可以复用物理cache数据路径；禁止把原两处profile/generation条件改成“两种看起来合法即可”的无边界OR，或对L13M临时填假model generation绕过检查。所有上层binding须传递同一实例模式及canonical身份，未修改的低层只做完整opaque equality时无须另造格式转换。

工程沿现预算完成必要的受影响核验，并继续独立工作，不逐项等主控批准：

1. 独立C/SV416B字节oracle：全部偏移、五角色/精确大小、LE/向量顺序、所有固定值和零保留区；四service同源。覆盖跨tag/source/size/magic/version/profile/policy/record order/reserved的突变及Q8S2误送拒绝。
2. 生产hub/W路径：错误字段在service副作用前拒绝；canonical AUX与真实读头一致，scale/bias严格检查仍执行；LOAD→lease/read/release及G/Q/父view跨command完整身份一致，错身份和旧响应不能取得READY/覆盖/完成。
3. 外层：首次base绑定、后续相同base请求/新request generation、改变任一模型base、WSTRB高低字与运行中写入、软cancel保留绑定/高水位、held R/B下不能冷清、全域排空冷初始化后的新绑定。不能用手工TB断言bound代替实际镜像/门控握手。
4. 当前最终包/生成C/SV/生产caller/hub及源闭包同步冻结，完成受影响生产接入与当前完整CPU/实际CSim；旧Q8S2和旧局部PASS只保留原身份，不追认为L13M生产证据。无差别重跑未变算术不是本决定要求。

组合G/Q→父matrix full的NOT_RUN_COST与5172s投影超3600s缺口保持，不能因字段定义完成或重用组件结果消除。L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；完整Laya加速器与尽量高性能目标不变。原单owner/单重工具、CPU/RSS/墙钟/周期帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板或预算授权。
