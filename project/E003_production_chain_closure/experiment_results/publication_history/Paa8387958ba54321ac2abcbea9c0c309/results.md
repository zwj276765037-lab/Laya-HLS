# E003当前结果



program RTL static48.662357s，pilot6682cycles/5.766016s，full22415cycles/6.577758s；三段guard child0/trigger null，CPU0–3/nice19/idle I/O、MemAvailable门、RSS/墙钟/120s进度帽均核。full在启动前以本次pilot1158.859100cycles/s，6682×4×1.5=40092cycles、34.596095s投影，低于本入口1Mcycle/3600s；这是有限fixture估计，不是完整图性能上界。static峰值2514820KiB，pilot/full峰值856736/856792KiB。11份DAT冻结/落位SHA逐项相等。

FSM host build/run10.041669/0.117152s，均exit0，六case原始marker在日志内。其runner保持1800s/24GiB RLIMIT_AS，只签host限制，不扩成owned-RSS/120s进度guard。`task_lifecycle_fsm_host_01`原FAIL保留：测试detail与Vitis detail namespace歧义导致编译exit1，未执行DUT；_02仅限定test调用为laya::detail后新冻结重跑，DUT及断言语义未变。

## 身份

独立核查：generation35组/1874项引用、FSM host53组/115项、RTL123组/280项；登记前211/211 current/frozen/pair、2269/2269 manifest/receipt引用一致。随后唯一registry补记真实program生成/RTL及FSM source闭包，导致generation两项、FSM三项live JSON变化，RTL闭包无差异；五项均为config登记，不是DUT/TB/gold/工具产物漂移。具体前后SHA在聚合verification中明确保留，旧receipt不覆盖、不重标。

交付：

graph_program_hls_01:
- input_manifest.json: `dfa38ba45d1ce7ac0257c6c9e7004d49cead81c4d95e9863c943ba1503f5e7af`
- receipt.json: `58aa61732800140ef921f82f3e36c72e5a27bc929e21f2f47ccb36078f0efedc`
- verification: `6b13e8f4407f7a6c0cd192a9d9ddb23a114591c2217773038b9c554fab5f8be2`

graph_program_rtl_01:
- input_manifest.json: `87131cdcc82562463e70287130767d6e5dd8bdbe61699195c78f8d202f17a5e4`
- receipt.json: `30aee37ebefb20fbadc91b400c56b7daf286214965242e29f9f947924b93229e`
- verification: `d5bae6dc2969d50aa3f4c5a3da2a0eb120ccc2d92072cd32e873b2f1ff62293b`

task_lifecycle_fsm_host_02:
- input_manifest.json: `b7b7486f29884d282f5e86f41b3ae190e4e676aaff45278b56265c1015ff91e5`
- receipt.json: `a6883894f5c7a4bee8499735d2f91d4d50dcbdc5e8228bde05a998cbbc8d5dbb`
- verification: `4246fbfe394cdda49fb473549b5383c3ce3038524fcc55b3dd06a13bcbb01c5c`

聚合verification：`dac277f992a762ee91dab222d02a271b38aa93f4349e524aa66fe7792cc96457`。文件：project/E003_production_chain_closure/experiment_results/runs/R003/program_generation_lifecycle_fsm_verification_20261012.json。

三摘要/A002同步后继续accepted-request唯一准入、executor top和action层真实消费边界，再连接实际LN master/monitor/唯一hub，以实际completion构造END/唯一typed退休并接Q/fullA独立gold。C009部分实施，C008/C010整体待验证；F6–F13旧限定关闭保持，L0/L1 PARTIAL，L2–L5 NOT_RUN，组合full NOT_RUN_COST，M003/M004未完成。原帽、单重工具、G余2338.224019s保持；5172s组合不重启，无新增OOC/P&R/上板、agent或预算。当前无本项目重工具。


---
Published: 2026-10-12T12:56:13.765224+00:00
Publication: P23a9a5e99f914514845a8c6ed7f0d9c0
