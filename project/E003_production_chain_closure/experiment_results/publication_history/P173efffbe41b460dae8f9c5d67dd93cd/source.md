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

---
Published: 2026-10-11T14:55:17.173696+00:00
Publication: Pa41a66fbd6a24acc811c2daca0338c4e
