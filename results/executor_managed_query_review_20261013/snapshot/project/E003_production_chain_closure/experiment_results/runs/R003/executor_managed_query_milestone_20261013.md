# Managed query wrapper 有限里程碑

范围 M003/SM003/E003/R003；A002唯一实现owner。沿 D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01；已收到 D-M003-EXECUTOR-CLOSE-REARM-01，CLOSE/CLOSED与重新准入仍是下一受影响实现。本轮没有生成executor/HLS/OOC/P&R/上板/agent，预算不变。

## 实现与已测行为

新增 `laya_executor_handoff_portal_shell_v1.sv` 把此前TB的前序LPV、executor LPV、共享STATE0 AW/W、snapshot/source-query保持门放入实际模块，同一portal/monitor/hub/两个depth2 query FIFO。正常前序HOLD期间末B/END/返回/PUBLISH继续；显式前序done与真实portal/monitor排空后才取得保持。当前admission/session/request、前序done及adapter_pending_zero仍由TB提供，未证明真实LYRQ/LYMP在该硬件runtime前序之前准入。

managed query开始许可仅管第一拍。实际第一拍入FIFO后锁存完整旧K/B和其唯一LBS2期望帧，shell记录旧query归属，持续cancel或base变化不封死后14拍/返回。完整1024B逐字匹配后才接唯一hub；hub沿原完整frame checker接受，撤销只给完整绑定E_PROTOCOL/flags3、零下界的负LBR2，不由半帧拼可信返回。已呈现成功返回即使尾拍取消仍保持原字节，所有新authority为0。

managed模式正/负LBR2末拍均进入等待阶段，不自动恢复前序，也不产生handoff_complete/legacy authority。真实绑定ABORT_CLOSED完整消费才能收束未提交query phase；撤销shell继续ISOLATED并保持保护锁，恢复输入和旧IMPORT均不开门。这不是整个请求CLOSE或恢复成功。默认诊断模式行为兼容保留。

## 运行结果

- portal_06：两拍实际query ingress后cancel持续为1，ABORT持续valid；其余14拍、真实16次返回读取和尾2/尾1各12周期反压完成，完整负返回与独立literal逐字相等，一次绑定ABORT关闭且零授权。16029cycles，41.456889s/1597520KiB。
- portal_07：两拍后snapshot base epoch7→8；完整返回仍绑定旧base7，和同一独立负literal相等；输入恢复不重新授权。16029cycles，41.832800s/1568984KiB。
- portal_08：成功返回尾2拍处cancel持续为1；完整成功字节未改写，旧query/ABORT正常消费，零授权/不自动rearm。16017cycles，41.230572s/1568820KiB。
- portal_09：完整LBS2的source epoch改动不匹配唯一旧K；实际接收16拍后隔离，hub query接受0、可信返回0、零授权。15964cycles，40.181376s/1646448KiB；无自动坏帧恢复结论。
- portal_10：当前wrapper正常路径保留112AW/7168W/112B、458752B和7次hub终态；HELD的实际共享writer/source-query probe被模块门拦住。实际helper仍是既有离线成功确认回放，GRANTED真实消费后CLAIM180/epoch9，typed仍7。16060cycles，40.975382s/1632028KiB。
- shell_05：原19个F18有限用例兼容；checkpoint_08：原5个默认模式；guard_10：原F15/F16/真实受控consumer/旧scope范围；monitor_16：原默认禁用及监控fixture。各自PASS不扩大旧结论。
- managed_query_decode_host_02：实际当前C++ checkpoint decoder/helper读取上述3份真实捕获，2份合法负返回完整roundtrip、1份稳定成功返回在cancel fence下拒绝；真实主机LYRQ/LYMP准入后3项helper拒绝均核整个FullRuntime逐字节不变，零导入/预约/退休；54 wire变体清输出。host fence受控，不能拼成同硬件runtime。

两份负捕获raw SHA `b6dc2a9345af331329b627f676bd4b49fe3d6ee634413899a99af2aaca375b66`；成功raw仍 `05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6`，原S/H1/1 literal直接相等，无改字节。

## 身份、观测与历史

完整口径401/401 frozen/声明pair；本次current378/401、递归manifest/receipt引用1379/1402。23项差异为两catalog的17处引用及portal_06/07/08的6处TB/runner后续变化，逐项写入history；五个选中portal的transport/shell/portal/hub/新wrapper各只有同一DUT SHA。预登记395/401为根据未变catalog身份推导的口径，明确不是新的历史时点采样。

12个选中guard起止串行、child0/trigger null，194条实际policy符合CPU0–3/nice19/idle I/O；MemAvailable、RTL8GiB/120s/120s及host24GiB/1800s/120s帽已核。资源观测完整性false：shell oracle0.166257s与host run0.145235s无owned-child RSS/policy，peak null，只保留配置/实际退出/墙钟；-MM和fixture生成是timeout/RLIMIT/launcher配置，不签owned-tree实测。

portal_05初版正常wrapper PASS保留，最终_10增加实际held writer/lease-query probe。_06→07仅TB计数/probe，_07→08同源不同case，_08→09仅TB/runner增加foreign全帧case，_09→10同源不同case。host_01因测试FullRuntime聚合初始化触发explicit构造警告，在-Werror下compile FAIL、DUT未运行；_01→02共同100pair仅TB初始化改为单独新建runtime，DUT/gold/runner/断言未改，失败guard/receipt保留。

## 仍未验收与下一步

当前是实际查询/交接连接，不是完整生产shell。前序数据为地址pattern，LN/encoder/Q数值、生成executor、LAP1 RTL、8/4 action、F10 24/16及同runtime实际helper仍未接。本stage在取消前已有LPV排空，不签活动LPV旧半帧/返回清理。静态已确认原LPV transport的`transport_abort=cancel&&service_domain_drained`仍会清私有framing/FIFO；managed整链须先分离新启动与旧归属排空，不能从本轮“old route可达”推定实际END/旧response不丢失。

按新CLOSE合同继续kind8/9 C/SV/oracle、真实结果/Host消费、完整A/K收束与待新准入阶段；持续runtime重新准入保留所有各自权威下界。随后实际LAP1/command/action/F10、source AR/F9/所有写修改入口及合法交接后QUANT lease，满足闭包后串行生成独立executor并接LN/hub/唯一软件退休/Q/fullA。源保护不是永久授权；13BO/alias/完整恢复仍待。

C009/C013 awaiting_implementation，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。G2338.224019s和全部原帽不变，5172s组合不重启。
