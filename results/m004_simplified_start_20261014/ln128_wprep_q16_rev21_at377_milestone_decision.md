# 修订21 AT377：错误与末拍屏障限定接纳

2026-10-16；D-M004-REV21-AT377-01；A001→A002；回复`m004-rev21-at377-error-barrier-milestone-20261016`。修订21仍running/unassessed，不收束、不封存、不加帽；当前工程按原合同继续，无用户逐项审批。

## 证据与范围

已核[工程报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)、五份冻结TB/生产身份、实际构建与运行日志及[51笔账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json)。[增量审核](ln128_wprep_q16_rev21_at377_review_20261016.json)1005项通过，744项冻结/fixture、10笔新增guard及64条政策样本相符；AT352–372复用原审核，41笔旧账逐项未改。四份实际生产上/下层、W服务/cache保持AT368身份。AT377独立层次没有父core，冻结包的旧兼容壳不属于本次执行证据。

1. **AT373下层部分A保护与discard恢复。** row0后错kind使prep_begin_ready=0、旧272字不变；准备row1后cmd_epoch=2使cmd_ready/q16_window_ok=0，随后恢复epoch1完成合法row1，显式discard清窗口，再epoch2正常row0，对原Q/scale参考逐位通过。需更正报告“实际消费错误done”：两次非法刺激均未接受，不产生本次错误done；实际消费的是合法run_row的成功done。cmd_epoch同时驱动q16_epoch及match_epoch，本例不能拆签独立source epoch和A epoch两种拒绝。它是下层合法caller局部测试，bank_idle等是明确peer边界，不签上层/父请求恢复。
2. **AT374 Q输入在途共同reset。** qf_state=QF_SEND且qf_index≥32、done尚未产生时reset，510拍逐拍检查所列Q/prep/window控制状态，然后epoch2 row0对原Q/scale恢复通过。仅签已断言控制状态隔离；没有直接断言所有叶子rsp/IP在途返回，不能称全FP已发未返reset或父层reset通过。
3. **AT375真实LN128后的W传输错误边界。** q0的beat24575注入RRESP=SLVERR，三路R=24576/24576/3072和AUX8齐全；上层错误端点op80/status7/status16=7/detail07800005/bad64全1、norm131072字保持、零STATE1 AR/R及Q输入/退休通过，290.4046124126762s。三拍循环只核错误valid、continue禁入、零后继访问及status16/detail，不是全部身份/Check字段逐拍保持，也未在本例执行错误后的无reset后继。旧AT371/372的主W回执保持证据仍按原局部边界。
4. **AT376 LN末B屏障及gamma退休。** TB延迟最后BVALID三拍；真实B=8191、退休127时continue valid不能握手，stage ready未发、gamma仍有效。释放后8192B/128退休和norm逐位成立，合法continue进入W_SEND并清gamma token，281.6433592028916s。此为slave响应延迟，不是BVALID已置1而BREADY=0时的payload稳定测试；未签pending/rsp/done或legacy切路。
5. **AT377 STATE1末R屏障及真实A16。** TB延迟第1024个RVALID三拍，实际15行Q退休、Q入口15360字/480组响应，r15未提前开始。释放后1024R、16384实际Q输入、512叶子响应到4352字bank的映射/保持及前4行独立Q/scale全部通过，297.1808947045356s。后12行仍只签传递/覆盖，无独立算术gold。该延迟不签RVALID已置1且RREADY=0时的payload稳定。

独立TB的request_done/RAW/FINAL为常量，仍无父图完整发布证据。以上不改变AT368正常主例、AT367父row0与AT372局部core/W的范围，不删除历史FAIL/COST_STOP。

## 剩余工作与一个术语修正

“r15导出末B”不是本Q16生产接口：Q16_WRITE/Q16_SCALE写本地bank，随后叶子release/done与A16退休，没有AXI B。请在工程报告/摘要把未测项明确为**末组bank导出、叶子release/done及A16退休的对应交接覆盖**；LN norm的末B是AT376已测边界。当前内部bank写拍没有独立ready，不为增加测试制造生产不存在的背压口，也不force内部状态/债。正常真实r15导出及最终保持已由AT377覆盖；未单独施加的阻塞仅在真实可达接口上保留未测。

下一集中验证优先实际父层W/Q固定委派及原合同内可合法施加的pending/rsp/done、legacy交接。复用同版模块和合法caller/peer短例，清楚注明替代边界；已有正常链、W错误、末B与末R长前缀不为整理报告再次运行。若内部边界没有可独立施加的外部阻塞，按真实接口说明不可施加/未测，不新造接口或循环长跑。普通实现/脚本修复继续原预算，实质接口变化再集中交主控判断。

全部父图128→A16同runtime仍未测，不能由独立约300秒或父row0时间外推后直接启动。历史gamma load_done、store/numeric与其它reset排列按原范围OPEN，不成为所有矩阵推进前置。阶段范围交付或成本出口集中回传最终SHA、父层实际范围及余缺口，接续[已接纳矩阵接口](a16_matrix16_interface_decision_20261016.md)；本次不实施矩阵或使用新预算。

## 成本

累计51guard/341已观测政策，static **1024.79789475537835202/1800s**、RTL **2541.6517546866089065/3600s**；余 **775.20210524462164798s / 1058.3482453133910935s**。AT361未观测policy/RSS仍UNKNOWN；host完整成本UNKNOWN。新一次运行帽不得超过剩余总额，未知路径仍按原≤120s pilot；不借旧修订余额，不动态延帽。

主控仅做只读静态证据检查，无EDA/新gold。首次审核脚本把真实`beat[p]`写成`r_count[p]`作字面匹配导致一项失败，已核原TB并只修审核脚本；首次JSON/计量以`first_literal_mismatch`后缀保留。最终1005项通过不修改工程证据。M004/SM004完整目标继续running/unassessed。

审核消息`m004-rev21-at377-scoped-error-barrier-review-20261016`已于`2026-10-15T21:30:14.736669+00:00`送达原工程会话，turn`01a14112-00a9-7e33-9a64-f3cbfbbff010`。无需用户转发；送达不等于工程更正已完成。
