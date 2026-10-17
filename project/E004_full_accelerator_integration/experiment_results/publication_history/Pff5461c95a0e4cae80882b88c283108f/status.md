## 修订21 AT378阶段状态（2026-10-16）

独立stage真实W错误后显式discard与新epoch row0恢复局部PASS；父层tensor生命周期未测。剩static729.40182127989829798s、RTL772.2631691843271335s仍属修订21，host完整UNKNOWN；M004/SM004继续running/unassessed。pending/rsp/done未消费与legacy换路、父请求实际W/Q委派仍开放；matrix/整模/物理未运行。[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md)。

## 修订21 AT377阶段状态（2026-10-16）

原合同内受影响错误和末拍屏障取得AT373–377限定PASS；独立真实正常LN128→W→A16仍由AT368同SHA负责。剩余static775.20210524462164798s、RTL1058.3482453133910935s未封存，host完整UNKNOWN；M004/SM004继续running/unassessed。continue同步pending/rsp及done未消费、legacy换路、末组bank导出、叶子release/done与A16退休的可达交接排列及父top实际W/Q委派仍开放；完整父请求同runtime到A16、后继matrix/整模/物理未执行。[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)。

# E004：状态


## 当前修订21状态（AT372，2026-10-16）

execution_state: running；verdict: unassessed。独立真实LN128→W→首A16已在AT368增强监视器同版PASS，父top当前仅AT367真实row0，core/W局部AT372四短例PASS。AT369编译FAIL、AT370默认O0 pilot COST_STOP与旧AT363 Fatal保留。剩static981.87301475927234898s、RTL1943.6001937072724075s仍属本修订，不封存、不挪旧余额；host完整UNKNOWN。后续在原合同内补continue末B/pending/rsp/done屏障、部分A/显式discard与父层实际W/Q短例；完整父请求、STEP16/matrix、全RoPE/Attention、Host/HBM和联合物理未验。见[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT372_observer_wprep_engineering_stage_20261016.md)。

execution_state: running（M004完整目标）；verdict: unassessed（完整加速器）。主控D-M004-REV14-CLOSEOUT-01已按分版证据有界收束SM004修订14：AT225旧wrapper真实row0冷/row1暖RAW→RoPE正常链限定PASS；当前wrapper `0d3e340e…`的AT230–241受影响控制/传输局部和AT232真实core/IP展开PASS；AT236/237/242原full-Check叶子与生产adapter局部算术、异常次序和恢复PASS。AT242只签四种Check次序、结果保持与无reset后继正常head，不签wrapper错误写回或全请求首错。

修订14最终55笔guard实耗static/IP1001.90892168506979732/1800s、RTL1247.0794125087559535/4800s，未用798.09107831493020268s及3552.9205874912440465s均封存；host完整累计UNKNOWN。本段不再启动重工具，原FAIL/COST_STOP及严格MUL IP已接受未返回reset NOT_RUN保留。当前wrapper真实两行/跨mode FFN同SHA长链、物理BO/邻区哨兵、全128行真实producer、Attention/Encoder/整模、生产Host/HBM及联合资源/Fmax仍未验。S128真实源与固定请求修订15已开始实施并获得所测前缀证据，FINAL→Attention仍未实施；M004继续running/unassessed。

修订15工程阶段running，AT250旧wrapper两行真实前缀获主控限定接纳；当前wrapper `d4856aee…` AT264一行真实全链及逻辑哨兵、AT256/259/261/260局部控制、AT252模拟128行调度、AT262/263真实core局部入口已获主控D-M004-REV15-AT264-01分版接纳。累计42笔guard，static1769.133914342150093/1800s、RTL2768.097435323521494/4800s，host完整UNKNOWN；本轮已停止重工具。修订15未因两行前缀而完成128行生产或请求发布，完整目标继续running/unassessed。

AT265按AT264决定补完末行错误peer，static/RTL本次各20s小帽内child0/null；仅局部调度出口PASS，已由D-M004-REV15-CLOSEOUT-01限定接纳。AT243–265合计44笔guard，static1773.706414608284832/1800s、RTL2773.568239858373999/4800s，余static26.293585391715168s、RTL2026.431760141626001s已封存；旧两行真实前缀、当前一行全链和未验完整请求的边界不变。

修订15已按D-M004-REV15-CLOSEOUT-01有界收束，不启动同修订重工具；M004/SM004完整目标仍running/unassessed。逐行与旧全请求head优先异常首错次序差异维持UNRESOLVED，该句为修订15收束时点历史；修订16现已实施。

## 修订16收束与修订17当前状态（2026-10-15）

D-M004-REV16-CLOSEOUT-01已按AT268旧adapter八tile及AT270–272当前adapter短例分版收束，旧余额封存。修订17依据D-M004-STAGED-LNQ-01继续工程阶段，AT297同版120秒pilot仅退休row0/1，未达16行估计门，真实LN128/NORM_STAGE_READY为COST_STOP/NOT_RUN；AT290 Q16局部、AT292/294/296错误/恢复、AT298/299模拟调度/reset及AT300当前leaf旧模式兼容仅在所测范围通过。原失败和pilot费用完整计入。修订17账余额static109.0716547369957103s、RTL1939.0749267190694595s仍属本段，待A001集中审核决定，不自行封存或转移。完整M004/SM004保持running/unassessed；全请求异常等价、完整producer→FINAL→Attention、Host/HBM与联合物理未验。


修订17已由D-M004-REV17-REVIEW-01按成本出口收束，余额封存；当前工程转修订18 Q16部分窗口准入修复及LN128成本诊断。修订17机读账漏四项manifest与AT297全次source R口径见追加勘误，原guard不回写。真实LN128和NORM_STAGE_READY仍未通过，部分Q16窗口占有缺口在修订18实测/修复前保持OPEN。


## 修订18工程阶段状态（2026-10-15）

Q16部分窗口旧版覆盖反例与当前core局部修复已实测；同SHA默认/`--O3` A/B有单次约3.91%成本改善，但AT306真实16行pilot120秒帽只退休两行，保持COST_STOP。按合同停止该性能假设，不启动LN128长例；修订18剩余static157.61403870023786266s、RTL2036.72993215359746s交A001阶段审核，未自行转移。下一具体边界为在生产父top保持唯一实例的共享活跃LNQ/bank/prep/source/norm服务验证层及真实16行成本验证，需单独合同。M004/SM004继续running/unassessed，全请求首错及后续父图仍开放。


D-M004-REV18-REVIEW-01按成本出口收束修订18，未用static157.61403870023786266s/RTL2036.72993215359746s封存，不转后继；AT306并非全128数值失败。Q16部分窗口具体覆盖漏洞在所测局部闭合，真实16/128行与父图接口仍开放。M004/SM004保持running/unassessed。

## 修订19当前工程状态（2026-10-16）

下层生产服务LN_ONLY本地生命周期与Q16 bank/占有已完成同版局部回归；父top仅AT323真实row0前缀，AT322错误恢复及AT325 PS/G/QD/ADD固定bank客户在各自范围PASS。上层仍由旧sequencer/wrapper驱动128行循环和16行错误屏障，独立stage 16行pilot、真实LN128、NORM_STAGE_READY均NOT_RUN。修订19累计static1706.08185053430498095/1800s、RTL1473.825600214302521/3600s，剩static93.91814946569501905s/RTL2126.174399785697479s，host完整UNKNOWN；旧失败照原账保留。现静态余量不足已实测一次父top重展开，上层归属迁移后的新身份不能借旧SDB签证。工程将[阶段报告](../experiment_results/runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md)交主控确定下一可执行接口和独立预算；修订19未自行收束、余额未封存，M004/SM004保持running/unassessed。

## 修订20 AT331时点状态（2026-10-16）

AT331为当前同版父top真实row0前缀；bank物理实例已外移到上层，父本地LN_ONLY拒绝Check来源修复完成局部反例与回归。上层128行调度、16行store错误屏障、source/gamma预装及norm行FSM仍未集中，独立stage 16行pilot、真实LN128与NORM_STAGE_READY为NOT_RUN。修订20剩static1086.08419444039464s（其中400s为最终父top构建计划空间）、RTL3332.710004530847072s；旧余额不转移，host完整UNKNOWN。M004/SM004仍running/unassessed。下一步按原固定切口完成上层唯一控制，随后先独立16行成本门，再决定合同内LN128；不升级本次row0/局部Check为完整生产PASS。[当前阶段报告](../experiment_results/runs/R001/reports/SM004_rev20_AT331_bank_extract_local_check_milestone_20261016.md)。

## 修订20 AT351当前出口（2026-10-16）

生产上层单一owner及独立真实LN128正常链已完成同版RTL；父请求top仅row0前缀。受影响source末RRESP、norm末B、gamma非有限、跨页界/有限总线停顿、描述符拒绝与prep在途共同reset各按阶段报告局部PASS。AT351增强本地拒绝后继未展开成功，另有gamma load_done错、store错后数值优先、bank pending/rsp或末B受阻的legacy交接、LN/回放在途reset和父top同runtime全128待测。static剩1.5645533520728266s不足最小约35秒增量展开；RTL余额2276.149455938488265s封存于本修订出口，旧帽不借。M004/SM004仍running/unassessed，完整请求、Host/HBM与联合物理继续未完成。

D-M004-REV20-CLOSEOUT-01已正式收束修订20并封存static1.5645533520728266s/RTL2276.149455938488265s；这些余额不转后继。下一工程段待主控独立合同与预算，M004/SM004仍running/unassessed。


---
Published: 2026-10-15T21:50:29.821633+00:00
Publication: P3df4c9d0c0874282b3b6fbffa2abb864
Execution state: running
Research verdict: unassessed
Applicability: AT368独立正常串联；AT373-378下层恢复、W故障/恢复和末B/STATE1末R局部屏障PASS；父完整请求同runtime到A16未验
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT378_20261016.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT378_SM004_rev21_w_error_discard_recovery_01/guard_rtl_w_recover/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT375_SM004_rev21_chain_w_bus_error_01/guard_rtl_w_bus_error/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT376_SM004_rev21_continue_last_b_barrier_01/guard_rtl_last_b/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT377_SM004_rev21_state1_last_r_hold_01/guard_rtl_state1_last_r/guard_result.json
