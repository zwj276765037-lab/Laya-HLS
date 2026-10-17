# 修订21 AT378真实W错误后独立stage恢复

2026-10-16；M004/SM004/E004/R001；A002。承接[AT377受影响报告](SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)及D-M004-REV21-AT377-01。修订21仍running/unassessed，本条仅增一个同runtime局部恢复；不封预算、不借旧余额。主控AT377限定审核指出的非法未接受、保持字段、BVALID/RVALID延迟及Q16无AXI B口径已在前报告和E004/E002摘要修正，原冻结TB、guard和日志未改。

AT378沿AT368相同生产上层`e2be4e1e…`、下层`30816465…`、W服务`519a2ccb…`、cache`6d13fae4…`及原fixture，只重编串联TB。先完整真实LN128、continue及W冷载，并在最后q0 RRESP注入SLVERR；W三口24576/24576/3072R与AUX8R排完，上层错误端点协议status7且零STATE1/Q、原131072字norm保持，`CHAIN_W_BUS_ERROR_BOUNDARY_PASS`成立。失败三拍后TB通过现生产`stage_release_fire`显式discard，检查stage回IDLE/债零，再以新id300/epoch2走同一生产入口真实读gamma256R和source64R、计算及写回row0的1024字与64个B，原独立norm gold逐位，终标`CHAIN_W_ERROR_DISCARD_RECOVERY_PASS`。两终标均在同一[RTL guard](../attempts/AT378_SM004_rev21_w_error_discard_recovery_01/guard_rtl_w_recover/guard_result.json)中，286.08507612906396s、child0、无Fatal/Error。静态增量构建45.80028396472335s成功；[冻结包](../attempts/AT378_SM004_rev21_w_error_discard_recovery_01/source_manifest.json)148项SHA/字节复核一致。

此例由TB直接合法驱动独立stage的release和第二次请求，未走父wrapper/sequencer的tensor_release、e/e+1/e+2完整策略或请求done发布；因此只签独立阶段错误后新epoch row0，不代签父请求恢复。日志中的`STAGED_LN_ROW_RETIRED row=255`是TB诊断变量`last_retired`跨discard未清，在生产退休计数从128重置为0时以8bit减1打印；它不是生产row255事件。恢复终点直接断言生产退休数1及新增64B/64sourceR/256gammaR/1024norm。AT375原错误边界与AT368正常主例仍按各自身份，不因本次同版TB重编改写。

[AT352–378机读账](SM004_rev21_guard_ledger_AT352_AT378_20261016.json)累计53guard、352条已观察CPU0–3/nice19/idle政策匹配；static **1070.59817872010170202/1800s**、RTL **2827.7368308156728665/3600s**，余static729.40182127989829798s、RTL772.2631691843271335s，host完整UNKNOWN。AT361 policy/RSS未观测仍UNKNOWN，历史Fatal/timeout保留。

父完整请求实际W/Q委派与LN128→A16同runtime仍NOT_RUN。继续屏障中同步pending/rsp或LN done未消费，以及legacy换路尚无本层合法外部阻塞证据；不force内部状态、债或增生产ready口来制造测试。A16正常末组bank导出/叶子release/done及退休由AT377覆盖，额外可达阻塞排列未独立施加。后继MATRIX16只有D-M004-A16-MATRIX16-INTERFACE-01静态设计接纳，没有动态或预算使用；整模、Host/HBM与联合资源/Fmax仍开放。
