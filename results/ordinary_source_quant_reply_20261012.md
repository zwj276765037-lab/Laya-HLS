# R-SM003-ORDINARY-SOURCE-QUANT-20261012

答复：`ordinary-source-quant-milestone-20261012`。四项冻结局部PASS保留；接纳B1/S64、role6、stage2/K1024下四个完整rows16 producer窗口及一个真实Q窗口的source query/lease→共享quant/fullA连接。**新增F5/P1：短producer可能被记为完整标准窗口，整tensor发布门尚不能验收。** 这是冻结源码路径发现，本轮未运行故障复现，不把既有PASS重标为FAIL。

主控独立核450项文件SHA引用（435 manifest、15 receipt）、93组current/frozen/pair全部匹配，保存44份依据；五个guard阶段均child0/trigger null，原CPU0–3/nice19/idle I/O/MemAvailable与static/pilot帽有记录。审核与核查记录：`results/reviews/SM003.md`、`results/ordinary_source_quant_review_20261012/verification.json`。

## F5：窗口完成位必须代表标准窗口的全部行

`generated_source_lease_01/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_hub_v1.sv`：

- `source_window_event_ok:299–307`只要求rows在1..16、row0按16对齐、范围不越owner；expected_elements与geometry按本task的rows核验。
- `finish_end:528–530`随后把整个`owner_window_closed[window]`置1。
- `source_owner_complete:317–323`只核这些位；`PUBLISH:562–566`据此通过整tensor覆盖门。

同一B1/S64、role6、K1024 owner可构造四个真实匹配BEGIN/END：row0=0/16/32/48，各rows=1，expected_elements=1024，geometry为4096B单行、row_step=0，issued/observed均4096B、成功且已排空。共享context/frame与geometry合法性检查允许此输入，END仍各置一整个窗口位。在PUBLISH取得当前TB同样的coverage=true物理摘要时，内部完整性门已为真，但实际只覆盖4/64行。额外physical coverage输入不是逐窗口ledger漏算行数的替代证明。query后来因P/Q行数不符拒绝rows16，也不能纠正已发生的错误发布。

按现有D-M003-ORDINARY-SOURCE-PROVENANCE-01 §2/§3修复即可，不改ABI/包长/任务定义：当前单全宽producer路径只有完整标准窗口才能置closed，行数应为`min(16, owner_end-row0)`；若实现支持分段贡献，就必须累计无遗漏的实际行/分量覆盖后再闭合。不要缩标准窗口或以“存在一次成功END”代替完整覆盖。P仍保存导致真实完整覆盖的原Context。

请补有区分力的有界回归：非尾窗口rows1及其它不足16行不得置完整位/发布；四个稀疏单行不能发布64行owner；完整四个rows16仍能发布并执行现有Q。尾部若属于此实现支持范围，按owner真实剩余行核验；不为测试改变原模型shape。错误后保持既有失效、排空和同session恢复规则。只重跑受影响ledger/portal/Q及必要monitor入口，保留全部旧attempt。

## 接纳范围与后续

租约核验与response背压持有行为按当前测试接纳。独立比对确认source/q为case_11..18共256项、scale为8项，各重复64次形成16384/16384/512项；TB读取128个四行group核q/scale。不能称16384个独立数值样本。producer物理观察仍受控；本轮不签production generated master/adapter_pending_zero真实因果、多role/QKV、跨batch/shape、普通/GATE无复位切换或完整请求。

F5归C008普通source证明和C010集成待验证；C009仍部分实施。C012此前F1/F1b/F2/F3/F4基础错误处理的限定关闭保持，消息回复链不扩大其关闭范围。当前三摘要P2ccfcb52fb494844a4620f55b92e57a3及A002同步已核；先前F1b launcher历史缺口保留，不补跑。

工程继续上述修复，并行于依赖关系上独立的production master/store提交及adapter fence因果接线；物理来源闭合后继续来源切换/shape/role、LOAD、其余Q/L、matrix与完整CPU/实际CSim。单重工具及原预算保持。下一次full前让当前pilot速率实际参与成本判定的既有要求仍待交付，不重启未改善的5172s组合profile。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST，M003/M004未完成。总目标仍是完整Laya加速器且尽量高性能，无固定性能门槛；无新OOC/P&R/上板、agent或预算，G余2338.224019s不变，无新增用户审批项。
