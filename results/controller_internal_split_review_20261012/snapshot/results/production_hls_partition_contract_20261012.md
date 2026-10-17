# 生产HLS分层生成与最终连接合同

决定：**D-M003-PRODUCTION-HLS-PARTITION-01**，2026-10-12。答复`production-source-switch-hls-blocker-20261012`，适用M003/SM003/E003/R003与M004。工程仍是E002/experiment唯一实现owner。

## 1. 决定与依据

**允许并采用Controller caller/shell与既有service模块分层、独立生成，最后在唯一production RTL top连接。无须继续单一HLS编译单元容纳整个执行图。** 这改变编译和内部模块边界，不改变原13BO外部ABI、四条compute/provenance私有FIFO、compute wire v2、LPV1/LPA1、typed任务及数值合同。按本合同连续实施与受影响验证，无逐次审批。

当前单体`generated_production_controller_hls_05`的115组源码与当前身份一致；_05/_06/_07均停在Compile/Link 13,223,459 instructions、Unroll/Inline pending，约375.507/380.544/375.533s触发原120s进度保护，无候选RTL。两种inline/noinline变体未产生可区分改进且已撤回。这个结果足以停止当前profile；它证明原保护条件下未完成生成，不证明编译器永久死锁，也不证明单体架构在任意预算下绝不可能。13.2M是编译IR规模，不是硬件资源或请求性能。

本决定补充联合design §3.9、M003 L1及[D-M003-GENERATED-PROVENANCE-CHANNEL-01](generated_provenance_channel_contract_20261012.md) §9：其中“实际generated controller/top”可以是当前身份下实际生成、完整连接的分层实现；不再要求全部13路master及每个算术函数由同一次HLS生成。最终top的ABI、原物理生命周期和同runtime验收要求全部保留。

## 2. 固定职责边界

| 层 | 职责与唯一权威 |
| --- | --- |
| Controller caller | 原任务图、shape/layer/batch循环、任务/Ref分配及预约、command/event高水位、BEGIN/END/owner事件、逻辑错误路径及唯一typed退休。保留完整请求，不缩层数或只生成demo调度。 |
| 非门户producer engines | 从原实现提取的实际算术/读写任务体，复用现LN、内部embedding、Attention/RoPE、向量/残差、Decision/ACT等家族边界及数值实现。返回逻辑结果与真实提交计量，不自行发布owner或最终退休typed任务。 |
| 既有compute services | LOAD、QUANT、MATRIX、GEGLU继续走原四service和wire v2，保持唯一共享fullA/fullW/PS/GATE与持久服务实例；不再在production caller内另编一条软件算术fallback。 |
| 最终RTL shell/hub | 原13BO/control接口、L13M和base生命周期、owner仲裁、真实AXI/宽度转换债务、共享provenance ledger、source lease与取消/fence，仍是物理成功/发布的唯一权威。 |

同一engine可被多个layer/task重复调用，不按28层或每条task复制算术硬件/全量缓存。调用方可保留原逻辑metadata和状态机，但不能与物理hub各自生成可矛盾的READY。禁止把整份可变FullRuntime、C指针或完整tensor搬过新控制接口；engine只获得此任务必需的冻结参数和有界局部状态。实际tensor仍使用原BO/已有缓存与布局。

生产编译必须真实切断跨边界的算术实现闭包。可采用工具支持的RTL blackbox/函数替代或各模块独立top加薄RTL连接，要求相同的下述语义。仅添加inline pragma、保留动态fallback的原完整调用图、只有C声明而没有真实engine RTL，都不算完成拆分。CPU参考及现有独立gold保留；不能用空函数、恒定ACK或Host执行代替FPGA职责。

## 3. 内部任务调用与退休

四条原私有FIFO仍为512bit/depth2、原方向与包长；它们连接真实caller和持久hub，不增Host端口或第五compute service。独立engine允许新增**仅层级内部可见**的有限参数/启动/完成接口，这不是新增门户协议或typed op。

每个engine采用固定宽度的request valid/ready与completion valid/ready语义（可以等价映射到HLS控制接口）；最多一个活动非门户任务，最多一个待接收请求槽和一个完成槽。请求/完成在反压时内容保持。工程按各原typed任务类型在共享定义中冻结字段、宽度、端序与端口映射，并登记registry；不采用C结构体padding或裸指针布局。原任务中用到的字段必须无损传递，不凭task_id算式补字段。

请求必须绑定完整NumericIdentity、原Context、所需完整Refs/region/epoch及原task参数、shape/几何、已核L13M模型绑定；有受保护写入的任务还绑定BEGIN.origin及相同descriptor。L13M可通过有应答的持久配置绑定一次，然后逐请求核同一绑定，不允许engine静默持有旧model/base。只读或无外写任务仍沿原身份、owner和读债规则，不伪造BEGIN或省略读后错误。

一个任务对象同时产生BEGIN与engine请求；BEGIN成功应答且完整绑定后才允许真实producer启动。BEGIN反压或拒绝不能提前写。compute执行与非门户producer互斥维持原合同；本次不引入新跨任务并发或改变调度次序。

engine完成返回同一身份/任务绑定、真实逻辑Check/TaskDone字段及两个descriptor的实际`issued_store_bytes`（另保留原错误/排空所需信息）。它只表示逻辑计算/提交状态。caller构造原END；物理hub完成真实覆盖、提交量守恒、总线债务和adapter fence后返回终态，caller仍要求完整匹配且`DRAINED=1/SCOPE_ACTIVE=0`才清tracker并恰一次退休原typed任务。engine完成、END和service view不能各记一次TaskDone。

取消停止新启动，保留已经获准engine、参数、posted store、返回及当前BEGIN至安全END/fence收束。reset/CE、首错归并、失败部分提交量、迟到完成隔离和同session恢复沿原合同；不得用复位子模块、丢弃完成或假drained解决停滞。每个engine实例只承接被dispatcher选中的原任务，旧完成不能交给新请求。

## 4. BO路由与真实fence

最终外部仍是原13BO、控制寄存器偏移、位宽/AXI语义及锁存基址规则。拆分后单个engine可只带所用的m_axi端口；在shell内按固定role路由到原逻辑BO端点，caller/engine共享原generated owner通路。当前八个可写bundle的写能力及全部必要读能力须在组装后的映射表和真实端口中逐项核实，不能要求每个小模块都生成冗余13路master，也不能删掉最终必要端口来过检查。

caller与任何engine的端口切换/owner交接，都必须包含已接受、已提出未接受、返回反压、converter、有限队列及adapter内部待发债务。多个物理master汇入同一逻辑BO时，原地址/Ref绑定必须在写转发前已确定；保持W-before-AW、WSTRB、4KiB/宽度转换、真实R/B错误及本地拒绝事务的安全退休。共享monitor只在明确的权威边界计一次，子beat债务完整归并。

`issued_store_bytes`须由实际engine store提交路径累计，并成为其完成/END的数据和控制依赖；失败短路只报告真正提交量。不能让caller按期望shape预填，不能把engine ap_done直接当adapter空。工程依据实际生成适配器落实“END之后不再产生未被计量及fence覆盖的旧请求”，绑定真实状态/显式排空握手；CPU变量、TB输入、总线暂时静默或只有字节相等均不充分。读prefetch、W/地址分离、合并写和拒绝事务同属证明范围。

`generated_store_monitor_07`只证明受控master/fence条件下，END早于首AW不会靠外部暂时idle提前终态；它不免除上述真实生成模块因果义务。

## 5. 连续实施与验收出口

先按当前调用图与设计尺寸报告确定最小可生成切分，记录每个原生产任务由哪个真实engine承担、哪个source/config生成、哪些状态持久。优先生成控制壳及一个实际普通producer，连接真实store helper→generated master→monitor/hub→普通Q，取得可区分的进展；其余模块沿同一模式补齐。registry/构建清单是唯一生产闭包，每个分区须有当前源码、工具/配置、生成RTL和最终连接的身份映射。不为常规模块实现再等待主控逐个批准。

必要出口：

1. 实际caller生成四FIFO共12信号并核方向/极性，最终连接保持depth2；整套top展开/连接检查核原13BO、所有控制offset和读写能力，无悬空实例或仅声明blackbox。
2. 实际非门户producer的BEGIN反压→真实数据写入→END早于首AW/末B/adapter待发门控→共享hub发布与原子Q lease→真实Q/fullA。使用原独立数值gold，覆盖成功、失败部分提交、取消、旧返回拒绝及同session恢复。受控模块测试只签各自范围。
3. 受影响调用/退休回归和当前完整CPU/实际CSim恢复到既定四持久请求、141点/18,094,384 F32及故障恢复口径；实际分层硬件连接另做同runtime验证，软件/CSim不代签。
4. 接其余Q/L/LOAD、真实matrix与全模型请求，继续M003 L2–L5与M004。新边界的启动/等待/存储开销纳入后续完整请求性能比较，联合资源中每个engine/缓存只计一次。分区分别生成不代表完整资源、时序或性能已过。

原单重工具、CPU0–3/nice19/idle I/O/MemAvailable门、static24GiB/1800s、pilot8GiB/120s、RTL8GiB/3600s及120s进度保护不变；HLS分区生成属于当前L1静态生成范围，不授权整体OOC/P&R/上板，也不增加G预算。以有限分区清单推进，不通过无界重试或改名绕过成本保护。需要full时按当前pilot速率和已冻结工作量先判断成本；原5172s组合profile保持NOT_RUN_COST。

HLS可观察进度可结合工具阶段与实际编译产物高水位；文件增长不等于算法语义进展，更不等于RTL成功。原始guard/log保留，不能将不断增长的日志/临时噪声当完成证明。拆分后仍不可在原帽内生成的分区，提交该分区的明确瓶颈与新可检验方案，继续不依赖它的工作。

## 6. 当前判定

F5在本轮单全宽窗口范围关闭；两个来源切换和早END monitor局部证据接纳。C008/C010完整集成仍待验证；C009的拆分方向已明确，实际production生成与fence因果仍未完成。此前F1/F1b/F2/F3/F4限定结论不扩大。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。完整Laya加速器且尽量高性能、暂不设固定门槛的目标保持。定义与生成成功均不能代替完整工程验收。
