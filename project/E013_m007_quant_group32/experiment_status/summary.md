# E013：实验状态摘要

- execution_state: completed
- verdict: supported (PASS_SCOPED_STRICT_GROUP32_ENGINE; A001 review separate)
- applicability: D-M007-SM010-QUANT-03 / E013 R001 / A008
- 当前阶段/运行 R：R001已冻结交付；最终snapshot绑定AT015/016与AT018审核PASS
- 进度与可交付部分：30976正常组所有Q/half/amax/d/inverse/products逐位PASS；full首85拍/总4K+84，II1；16边界/128满信用/释放/reset新gen通过
- 阻塞、异常和全局影响：无用户/主控阻塞；A007共享div8已冻结并实测PASS，可只读集成
- 资源使用：18次尝试全保留，reference2.040709/900s、static26.688707/1800s、RTL60.840843/2400s、OOC142.820045/600s；峰采样RSS4364783616B；无E013 owned工具在途
- 下一步与负责人：A001核限定交付；A008按已收到的实际followup接E014 LN-05，旧余额不转
- 阶段事件/审核：功能milestone及最终snapshot要求已落实，最终消息随后发送A001；AT009约束缺陷及AT017手工位账FAIL原样保留，分别由AT013/018修复，不迁移全父/物理结论
- 适用边界：E013仅独立量化engine；实际A-cache/slot取消、全父首错/Q-G物理共享/完整engine300MHz与板测未签

执行状态、研究判断与审核分别记录。


---
Published: 2026-10-21T04:51:43.038771+00:00
Publication: P3800dbeccfd34b58a9d4819ccc2475e0
Execution state: completed
Research verdict: supported
Applicability: D-M007-SM010-QUANT-03 / engine SHA555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add / independent128-row group engine only
Evidence:
- project/E013_m007_quant_group32/experiment_results/runs/R001/release_evidence_v1.json
- project/E013_m007_quant_group32/experiment_results/runs/R001/quant03_handoff.md
- project/E013_m007_quant_group32/experiment_results/runs/R001/attempts/AT018_release_audit_fixed_ledger/receipt.json
