# M005 诊断综合：provenance hub 几何检查的架构边界问题

A002→A001；M005/SM006/E006/R001；关联 `m005-at071-at073-controller-scope-review-20261014`。AT073 最后 full 已结束：Down 256 AW/W/B、TMP 原 gold/邻区及 Wi/G 前缀通过，但 cycle375074 的 `FFN0 Down-to-residual retirement gate did not retain ticket` Fatal 使残差未启动；3/3 full 已用尽，累计 4974.979578s。详见 `M005_AT073_down_retirement_fail_20261014.md`。

诊断联合综合保留了三个实际失败身份：AT074 31.493478s 在 top 的 `default_nettype none` + `input logic` 端口展开失败；AT075 47.201637s 采用仅显式 `input wire logic` 的新 top（剔除该机械声明变动后与 AT070 top 逐字相同），通过该层，但在通用 `laya_generated_provenance_hub_v1.geometry_within` 动态循环失败。AT076 对原支持 `rows*repeats<=32` 的检查写成固定 32 步、完整当前 portal TB 短测 PASS（27.401092s），AT077 48.657160s 又在同 hub 的 `geometries_disjoint` 五层动态循环失败。三次综合均未产生网表、资源或时序，累计仅 127.352275s，原日志和 SHA 不改。

后一函数对最多两个 descriptor、各最多 32 个 geometry 区间做全部相交检查。直接固定展开会形成最多约 2016 个 64bit 区间对的组合比较，可能显著改变物理面积和关键路径；串行多周期实现又会改变 hub 请求接受/响应时序与状态职责。这已超出单纯语法修正的把握范围。请按 M005 R2 判断：可否在原综合预算内尝试保留行为的有界组合展开并以资源/时序作为诊断，还是应停止该物理分支、将 hub 检查资源架构作为下一集中设计问题？我会先保存现有最深综合证据、完成不依赖此选择的预算与功能缺口整理，不启动另一重工具。无论选择，AT073 功能失败和独立反压缺口不降格。

原证据：`../attempts/AT074_M005_joint_physical_01/guard_synth/`、`../attempts/AT075_M005_joint_physical_ports_02/guard_synth/`、`../attempts/AT076_M005_hub_geometry_short_01/receipt.json`、`../attempts/AT077_M005_joint_physical_bounded_hub_03/guard_synth/`。
