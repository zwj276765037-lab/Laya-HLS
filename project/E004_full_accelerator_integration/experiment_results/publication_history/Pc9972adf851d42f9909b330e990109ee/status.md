# E004：状态

execution_state: running（M004完整目标）；verdict: unassessed（完整加速器）。主控D-M004-REV14-CLOSEOUT-01已按分版证据有界收束SM004修订14：AT225旧wrapper真实row0冷/row1暖RAW→RoPE正常链限定PASS；当前wrapper `0d3e340e…`的AT230–241受影响控制/传输局部和AT232真实core/IP展开PASS；AT236/237/242原full-Check叶子与生产adapter局部算术、异常次序和恢复PASS。AT242只签四种Check次序、结果保持与无reset后继正常head，不签wrapper错误写回或全请求首错。

修订14最终55笔guard实耗static/IP1001.90892168506979732/1800s、RTL1247.0794125087559535/4800s，未用798.09107831493020268s及3552.9205874912440465s均封存；host完整累计UNKNOWN。本段不再启动重工具，原FAIL/COST_STOP及严格MUL IP已接受未返回reset NOT_RUN保留。当前wrapper真实两行/跨mode FFN同SHA长链、物理BO/邻区哨兵、全128行真实producer、Attention/Encoder/整模、生产Host/HBM及联合资源/Fmax仍未验。S128真实源与固定请求修订15已开始实施并获得所测前缀证据，FINAL→Attention仍未实施；M004继续running/unassessed。

修订15工程阶段running，AT250旧wrapper两行真实前缀获主控限定接纳；当前wrapper `d4856aee…` AT264一行真实全链及逻辑哨兵、AT256/259/261/260局部控制、AT252模拟128行调度、AT262/263真实core局部入口已获主控D-M004-REV15-AT264-01分版接纳。累计42笔guard，static1769.133914342150093/1800s、RTL2768.097435323521494/4800s，host完整UNKNOWN；本轮已停止重工具。修订15未因两行前缀而完成128行生产或请求发布，完整目标继续running/unassessed。

AT265按AT264决定补完末行错误peer，static/RTL本次各20s小帽内child0/null；仅局部调度出口PASS，已由D-M004-REV15-CLOSEOUT-01限定接纳。AT243–265合计44笔guard，static1773.706414608284832/1800s、RTL2773.568239858373999/4800s，余static26.293585391715168s、RTL2026.431760141626001s已封存；旧两行真实前缀、当前一行全链和未验完整请求的边界不变。

修订15已按D-M004-REV15-CLOSEOUT-01有界收束，不启动同修订重工具；M004/SM004完整目标仍running/unassessed。逐行与旧全请求head优先异常首错次序差异维持UNRESOLVED，该句为修订15收束时点历史；修订16现已实施。

## 修订16工程阶段状态（2026-10-15）

D-M004-REV16-AT268-01已限定接纳旧adapter的八tile正常链；当前adapter的AT270–272局部读错、末B错、页界/停顿和无reset恢复已交主控集中审核，本工程阶段不再追加原样长例。修订16仍待主控阶段结论，当前账余static1491.71694993041456s、RTL2505.7806947566568727s，不自行封存或转移。真实128行producer→FINAL→Attention同runtime、全请求异常次序、完整Encoder/模型与Host/HBM联合物理未验；M004/SM004维持running/unassessed。


---
Published: 2026-10-15T11:52:52.143160+00:00
Publication: P71d814d65206484f934e171d3eac27dd
Execution state: running
Research verdict: unassessed
Applicability: 旧AT268 adapter模拟发布peer head0八tile正常链；当前adapter AT270–272局部错误/停顿与恢复；M004完整加速器未验收
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev16_attention_consumer_engineering_handoff_20261015.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev16_guard_ledger_AT266_AT272_20261015.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT268_SM004_rev16_attention_eight_tile_01/guard_full_8tiles/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT271_SM004_rev16_attention_aw_stall_peer_01/guard_page_stall/guard_result.json
- project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT272_SM004_rev16_attention_q_last_rerr_01/guard_q_last_rerr/guard_result.json
