# E006 实验状态摘要

- execution_state: running；verdict: unassessed。AT070同一top正常full在独立guard内运行；不得把当前前缀PASS扩成整链PASS。M005新full已启动2/3，旧AT065累计2080.617893s加本次实际耗时仍待终态；最后一次full优先同版确定合法反压。
- AT066局部债务短测、AT070静态展开和真实≤120s冷前缀通过；正常full的末B、gold、保护和后段未知。按guard自然收束并核原日志/身份，随后依据实际终态安排反压样本与同版联合综合/route。无第二个owned重工具。
- M003/M004完整生产控制/请求恢复、全模型/板端仍开放；阶段C条件预算不随本前缀更新。


---
Published: 2026-10-14T03:37:38.278387+00:00
Publication: P922d37cbafcf43dda28363faf5cac77e
Execution state: running
Research verdict: unassessed
Applicability: M005阶段A：同top前缀/局部债务已验证，AT070正常full运行，物理与整模实测未完成
Evidence:
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT066_M005_quant_axi_debt_short_01/xsim.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT069_M005_top_tb_static_02/guard_pilot/driver.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT070_M005_top_normal_candidate_01/xelab.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT070_M005_top_normal_candidate_01/guard_pilot/driver.log
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT070_M005_top_normal_candidate_01/cost_decision.json
- project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT070_M005_top_normal_candidate_01/guard_full/launch.json
