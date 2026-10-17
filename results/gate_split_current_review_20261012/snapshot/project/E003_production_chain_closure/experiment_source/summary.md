# E003：当前生产链接入与回归

M003/SM003是M004完整Laya加速器的前置，A002单owner。唯一实现根E002/experiment；E003仅存证据。真实模型GGUF、五BO、四请求、独立gold、完整shape与数值规则不变。按L0→L1→L2→L3→最终身份→L4→L5推进，再继续SM004全模型与SM005性能/资源。

R002冻结完整请求57项与全构建61项依赖；最终稳定package/build/generated closure仍待建立。R003实现§3.9固定1024B命令/512B响应、两个depth2 private FIFO和真实resident服务绑定；包容量与外13BO ABI不变。

已实现实际历史ABI提取、pointer base mirror、完整45字段的13BO owner封装；AMD axi_dwidth_converter2.1实际SI512/128→MI32。LOAD门户实例化一份默认完整容量dualW/cache，使用真实native reader和lease/read/release；新增取消保持已接受及已offer的AR/R债务、epoch高水位及目标INVALID，避免待接收成功结果在取消同拍被消费。LOAD native adapter连接四实际converter和一13BO owner wrapper，同时计SI/MI债务及held/offered接口，并保留控制器owner0完整native字段。当前层级尚未接实际新generated caller/统一LOAD-quant-G-matrix hub。

主控已直接答复quant-g-answer-20261011，决定D-M003-QUANT-G-V2；权威合同results/quant_g_portal_contract_v2_20261011.md，SHA256 234f0f331cdd3a5f2f9daada1f5105f12c51f15f209870a164eb3f4d5ac7cdc6已核验。采用显式wire v2，原包容量和13BO不变；增加P/Q/L与future-dst、有限预约、G/quant分期、完整GATE owner及rows16父lease。定义阻塞已解除，尚无v2实现PASS。工程按原授权连续实施，旧v1结果保留冻结身份。

资源保持单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；CPU/CSim16GiB/1800s、static24GiB/1800s、RTL8GiB/3600s/40Mcycles与120s pilot。无新OOC，G余2338.224019s不重置。本轮无内部agents，actual_model/effort无证据保持null。

## 2026-10-11 v2及门户代号实施进展

权威为D-M003-QUANT-G-V2与D-M003-PORTAL-GENERATION-01。当前quant/G合同SHA256为5b23da9216c588aea04b10314fbd733e938c98c3d6674f8ac6c9e66e5b3c3123；生命周期补充SHA256为6c3017999c056fd6ba8e6e7566381f4bc790765c8d1e4adf3bbd27c44e62bc5e。234f0f…是修订前历史身份，不能代表当前合同。

C/SV显式VERSION=2，cmd1024B/rsp512B及13BO不变；P/Q/L与future-dst扩展、LOAD/非使用字段零约束及service/view回显同步。transport真实首拍握手校验固定64B可信头，只有可信fresh g可在失败响应/安全cancel封闭时推进H_closed；软cancel和session切换不清高水位，跨view空闲仍传播cancel。

TaskReservation与PortalReservation分离typed预约和持久H_alloc。Controller预约最大128窗口的385个typed task与769个门户command，G分期保持全部G→LOAD→Q/L；未发送g不回收，typed未激活预约可重建。此处仅控制预约与syntax验证，实际full_run_task仍是旧C路径，generic source provenance和真实portal caller/hub未完成。

新增laya_parent_a_lease_v2，5336bit归一化实体key，1011bit acquire/865bit release handle。实际fullA一次父acquire，后view局部grant，中间不真实release；末view或安全cancel真实release。当前独立真实fullA测试通过，尚未接matrix服务、父首错/TaskDone及全tensor目标账本。

## 2026-10-11 GATE tensor与matrix父路径实施

新增GATE tensor metadata ledger：同一GATE Ref/epoch覆盖最多128窗口/2048行，逐窗口保存P/Q/L与future binding，真实写债清零后累计覆盖，完整tensor才READY；消费者逐窗口取得读租约并等读债清零释放。该层不含物理GATE payload或GEGLU算术。

matrix binding现同时使用父A/W lease和tensor ledger。rows16的四个rows4 view各有独立portal generation，共用完整父L与稳定实体；中间view不清A/W，末view或安全取消才真实release。view成功在owner-retire握手锁存，父TaskDone只在全部view/末B/租约结束后一次产生。真实hub/caller和G→LOAD→Q/L生产接线仍待完成。
## 2026-10-11 物理GATE与G/QUANT分期实现

新增`geglu_gate_window_writer_v2`和`geglu_gate_tensor_store_v2`，把真实AXI512 GATE payload接到同epoch tensor ledger；每窗口只有末B和全部债务退休后才提交覆盖，活动取消安全排空后使tensor无效。

新增`geglu_gate_quant_split_v2`，GEGLU命令只生产GATE并返回，独立QUANT命令到达后才按完整P/Q/L、Refs、window、region和slot epoch领取GATE、实际量化并发布fullA。当前层级复用唯一canonical GEGLU、writer/store、quant/fullA实例；G阶段禁止AR/quant。已验证四个rows16 G窗口后一个window0 Q的局部运行路径。其余Q/L、LOAD、fullW/matrix、持久hub/generated caller仍待集成。

matrix runner的120s短pilot/3600s full路径现把最终manifest写入和receipt绑定放在同一函数；超帽拒绝分支有独立无Vivado有界检查。历史`matrix_parent_views_07`预算DEVIATION不变。

## 2026-10-11 真实父缓存matrix与split停滞保护

新增`laya_matrix_parent_cache_tb_v2`及受控runner，把v2 matrix binding直接连接实际fullA/fullW cache，并按一个rows16父的四个独立generation view检查完整缓存/数值/末B/父退休。该验证层使用预量化A fixture，生产DUT未因此获得实际G/Q接线结论。

split进度日志现只在实际work增加时输出；production guard对该marker维护work高水位，重复时钟/状态行不刷新120s semantic stall。

## 2026-10-11 actual G/Q→父matrix组合成本证据

`gate_quant_matrix_parent_03`冻结实际canonical GEGLU/GATE、独立QUANT fullA、真实fullW与父matrix四view的直接连接；A没有TB填充路径。static 84.239673s PASS；同一no-wave batch profile的一行真实G pilot 11773 cycles/63.410458s PASS。以已通过组件758736+114182 cycles为完整工作量上界，当前pilot 185.663 cycles/s并加10%余量投影5172s>3600s，故full为`COST_STOP/started:false`。manifest `f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`，receipt `042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。

`gate_quant_matrix_parent_01`旧成本逻辑仅按两个分立full墙钟估算3476s而启动；组合速率显出不适用后在591.128178s主动停止，保留FAIL/sigterm、无PASS marker。修正入口不增帽、不缩覆盖。`gate_split_progress_guard_03`另证明recognized split前缀缺work/缺字段/非法字段不刷新停滞计时，重复work也不刷新；receipt `51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

## 2026-10-12 G门户物理绑定与普通QUANT共享实例

新增`laya_gate_quant_portal_binding_v1`及decode/reader/TB，把真实v2 GEGLU命令绑定到物理WI AXI512读取、canonical GEGLU和GATE AXI writer。G完成条件只等待WI与GATE物理债务；writer busy包含待消费的逻辑完成，不能并入债务零，否则会与`g_done_ready`形成完成死锁。当前受控一行路径核独立AW/W/B、末B反压和返回绑定，G命令本身不隐式启动Q。

`geglu_gate_quant_split_v2`现让普通和GATE QUANT复用唯一`quant_task_to_dual_a_v1`及dual-A实例；按已冻结stage/source/row-space规则选择K和stride，普通来源在外部完整provenance发布后直接进入Q配置，GATE来源仍经过tensor lease。wrapper新增的`q_ordinary_source_published`目前只是受控边界；生产必须由持久hub按完整NumericIdentity、P/Q/L、Ref/region/epoch和来源证明驱动，不能由raw echo代替。现名为`gate_axi_ar*`的接口已经是共享QUANT source读口，生产集成须按解码source role路由实际BO。

权威generated来源决定D-M003-GENERATED-PROVENANCE-CHANNEL-01要求Host不可见的`provenance_cmd/rsp`两条512bit、depth2 ap_fifo。CLAIM/BEGIN/END/PUBLISH须与真实AW/W/B coverage、posted-write入队字节守恒和adapter排空fence闭合；原外13BO/控制ABI、四compute service和wire v2不变。该双向channel、唯一持久hub、实际generated caller与生产top十二根FIFO信号尚未实现/重生成。

## 2026-10-12 共享QUANT状态机受影响回归

历史`gate_split_04`之后普通/GATE共享唯一quant实例及G admission接口发生变化，因此用同一四窗口gold和成本路径重验当前RTL。`gate_split_05`在static暴露旧TB的隐式`.*`未声明新增`g_cfg_admitted`，只补声明后建立新attempt；未改DUT、fixture或覆盖。`gate_split_06`当前入口完整通过，保留四个rows16 G命令共享GATE epoch、全部G结束后才发独立Q、window0量化/fullA、物理AW/W/B与AR/R、tensor/lease取消清理。

本回归没有普通↔GATE无复位切换、其余普通K/row-space、跨batch共享source地址或真实hub source lease；这些按主控R-SM003-GATE-ORDINARY-PORTAL-20261012进入下一受影响集成，不从split PASS外推。


---
Published: 2026-10-11T15:28:18.196737+00:00
Publication: P173efffbe41b460dae8f9c5d67dd93cd
