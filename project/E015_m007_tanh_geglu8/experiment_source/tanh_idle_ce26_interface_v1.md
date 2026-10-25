# TANH v2 interface preparation

The new `laya_m007_tanh_core_v2` has the original core ports plus input
`core_ce` and output `token_empty`. The complete152bit token valid pipe,
numerical alignment and all42 arithmetic leaf enables use the same CE.
Reset retains priority. The standalone old lane wrapper is not included in
the new core file; `laya_m007_tanh_lane_v1.sv` remains untouched.

`laya_m007_tanh8_v2 #(parameter bit FORCE_CORE_CE=0)` has exactly the v1 public
ports. Default0 selects the §13 automatic idle CE;1 is the verification control
with the numerical core always enabled. CE/token reductions are wires, with
zero added FF and no gated clock. Existing lease/credit/result/tag/fault logic
runs continuously. Eight cores remain one physical production array when a
resource owner selects the new version.

Prepared source identities (not runtime PASS):

- core_v2: `13df84ea5dc06ece43a3d83b8af2d778fcd3b9bd1bda78e831d0e35ffd53dd10`
- tanh8_v2: `8c37896cbc20d0cf20b024cb39a771bb39b19aea5ad60f7434bef34d7ebdf248`

Static/runtime evidence will be frozen in R002 separately. A007 owns any joint
selection and cost comparison; this preparation does not alter old closure or
claim speedup, physical timing or complete Encoder performance.
