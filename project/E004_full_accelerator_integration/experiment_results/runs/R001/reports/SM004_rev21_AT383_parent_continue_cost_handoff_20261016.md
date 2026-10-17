# 修订21 AT379–383：stage done 屏障与父层继续接线成本出口

2026-10-16；M004/SM004/E004/R001；A002。沿 D-M004-LN128-WPREP-Q16-01 执行，M004/SM004 仍为 running/unassessed。本报告保留 AT380/381 构建失败与 AT383 定时停止；没有把短前缀写成完整父请求通过，也不自行封存修订21余额。

## 已测范围

AT379 只重编独立串联 TB；上层 `e2be4e1e35c31774d30103ee4fc8f0365c98ad6b7b18d3d0ce4bcc75e3ef1d7c`、下层 `3081646552d8260c0abcfcfb767e3869b2d49571e6cb77e970b5c1b12c247e31`、唯一 W 服务 `519a2ccb32998add404cfbaf7ba6e7e760db9913073682cbb39153aa67ff5d2f` 和 cache `6d13fae4bb2c9b6f1dde9fc65bb8b797daca027a81f07cd652eb900d5d85194f` 与 AT368 一致。一次真实 LN128 产生 131072 个逐 W 握手与最终内存核对的 norm、8192 个成功 B、8192 个 source R 和 256 个 gamma R。TB 用合法外部 `stage_input_done_ready=0` 保持最后 `stage_result_valid` 三拍，并同时提出 `stage_continue_valid=1`；三拍逐拍核 status0、`SL_FINAL`、退休数128、gamma token 保持、continue ready低及零 STATE1 AR/Q 输入。消费阶段 done 后到 `SL_HELD`，一次真实 continue 握手使 gamma token 退休，norm 覆盖仍满且零后继访问。日志 `CHAIN_LN128_PASS`、`CHAIN_STAGE_DONE_CONSUME_PASS` 各一次；[静态 guard](../attempts/AT379_SM004_rev21_stage_done_hold_01/guard_static/guard_result.json) 46.596447160467505s、[RTL guard](../attempts/AT379_SM004_rev21_stage_done_hold_01/guard_rtl_done_hold/guard_result.json) 278.195482281968s，均 child0、无 Fatal/Error。[冻结包](../attempts/AT379_SM004_rev21_stage_done_hold_01/source_manifest.json)148项逐 SHA/字节相符。

此例只签上层阶段完成握手与 continue 准入屏障；没有单独造成下层同步 pending/rsp、LN 叶子 done 未消费或 legacy 路由抢占，不能代签这些交接，也不签父层 request_done/RAW/FINAL。

主控收束时补核父 TB 边界：AT382/383 冻结的 `laya_staged_ln128_pilot_tb.sv` 将 W 三口 `arready/rvalid` 置零、STATE1 `arready/rvalid` 绑零，且以 `STAGED_LN_FORBIDDEN_SERVICE` 禁止 W AR；正常 LN128 终点立即 `$finish`。它是 LN-only 前缀 TB，不能通过延长同一仿真获得父 W/Q 证据。下段对当前父生产接线的描述是源码映射和所测层次展开，不是新增父继续接线的动态证明；父 sequencer/wrapper/该 TB 与 AT367 字节相同，core 文件与 AT372 相同。

工作源码中父请求 sequencer `9abc446e49f4c14d1519c975f21471f65f7d64a86b1dc627ae58178df6fb5d56` 已在完整 norm 覆盖后的 `S_STAGE_READY` 产生 continue，wrapper `3a11446adf0127e2294588006ecb285df627773a4f2aa8e9a15d3278aed7f9a7` 将保留的 request/epoch/W 描述符接到同一上层，且把上层 W_PREP 命令接唯一 core、真实回执接回上层，STATE1 512bit 端口向外透传；core `920d804f37cca1a3e5696a97b8c7d73938e734889e4914927ef4a5e4560a8192` 提供回执身份。AT380 首次以新父层配旧 core 冻结闭包，3.7815404813736677s 编译失败：旧 core 缺八个 `wprep_result_*` 端口。AT381 加入当前 core 后，3.8910791520029306s 编译失败：旧父 TB 的隐式 `.*` 缺 STATE1 端口。两次失败及费用原样保留，未取得 snapshot。

AT382 换成已有匹配父 TB，以当前父三模块和上述上/下层、W 服务/cache 冻结身份成功展开完整父请求 top；[静态 guard](../attempts/AT382_SM004_rev21_parent_continue_tb_ports_01/guard_static/guard_result.json) 69.6241029445082s，child0，无 Fatal/Error。相同 snapshot 的[真实父请求 row0](../attempts/AT382_SM004_rev21_parent_continue_tb_ports_01/guard_rtl_parent_row0/guard_result.json) 50.32597625441849s，`STAGED_LN_ROW0_PREFIX_PASS` 核 1024 个 norm、64 个成功 B、64 个 source R、256 个 gamma R、row0 逐位内存与未提前发布。父层继续接线仅获得**静态展开和真实首行前缀**；没有到达 continue/W/Q/A16 动态边界。[AT382 冻结包](../attempts/AT382_SM004_rev21_parent_continue_tb_ports_01/source_manifest.json)149项逐 SHA/字节相符，所用12份 fixture 与 AT367 父首行逐字节相同。

AT383 复用 AT382 完全相同的冻结源码、fixture 与已建 snapshot，去掉首行提前终止并运行固定120秒[父层前缀 pilot](../attempts/AT383_SM004_rev21_parent_ln_prefix_pilot_01/guard_rtl_parent_prefix/guard_result.json)。guard 于120.35708910785615s 以 timeout/-9 停止；日志只确认行0、1 退休，行1退休时source/B各128，第2行的 source 读取前缀出现。没有 LN128、continue、W、STATE1、Q 或 A16 终标。它是 COST_STOP，既非数值 FAIL，也非父层完整串联 PASS。以当前同版实际父层前缀成本，剩余 RTL 额度不足以给完整128行加 W/Q 一个有证据支持的启动依据；不能按独立层的317秒或父单行速率冒充新父图的同runtime成本。不存在合法的父接口可跳过128行直接到固定 W/Q；独立 AT368、core/W 局部 AT372 仍各守原边界。

## 机读身份、费用与后继

[AT352–383 逐笔账](SM004_rev21_guard_ledger_AT352_AT383_20261016.json)保留60笔 guard，包括所有旧 FAIL/timeout；新增 AT379–383 的七笔 guard 中，AT380/381 为构建失败、AT382 静态及 row0 为 PASS、AT383 为 COST_STOP。累计398条已观测 CPU0–3/nice19/idle 政策均匹配；AT361 policy/RSS 未取得仍 UNKNOWN。AT379–383 的五份冻结包共按各自 manifest 验 SHA/字节，无失配；host 完整累计 UNKNOWN。

static 精确 **1194.49134845845400532/1800s**，RTL 精确 **3276.6153784599155065/3600s**；余额 static **605.50865154154599468s**、RTL **323.3846215400844935s**，仍属修订21，不由工程自行封账或移入矩阵段。当前无运行中的重工具。已有独立正常链和受影响错误/恢复仍按各自冻结身份接纳，不为整理报告重跑。

给后继最小生产边界是上述父 sequencer、wrapper、core 三模块，加保持同 SHA 的上层、下层、唯一 W 服务/cache 和当前父端口 TB/真实 AXI peer；真实父层还须从 LN128 继续到 W 冷载、STATE1 Q16 与 A16，核回执、路由、数值和禁止早发布。同步 pending/rsp、LN done 未消费、legacy 切路在外部接口无可独立施加的合法阻塞口，保持 OPEN，不 force 内部债或增加新接口。完整父请求128→A16、矩阵、整模、Host/HBM、联合资源/Fmax 均 NOT_RUN。后继 MATRIX16 只有静态接口决定 D-M004-A16-MATRIX16-INTERFACE-01，本修订未实施或花费其预算。工程把本报告与精确余量交主控作修订21成本出口及后继独立预算判断。
