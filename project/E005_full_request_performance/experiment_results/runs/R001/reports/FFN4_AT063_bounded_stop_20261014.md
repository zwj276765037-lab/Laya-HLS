# FFN4 AT063：Down 前语义停滞有界停止

2026-10-14；D-M004-FFN-WI-DESCRIPTOR-REPLAY-01；E005/R001/AT063_FFN4_wi_descriptor_01。结论为 **COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD**。唯一四行冷 full 在原3600s/8GiB/40M、真实工作进展停滞120s的 guard 下结束；`result_full.json` 为 FAIL，guard child−9/`semantic_stall`，耗2080.298887s、峰1036164KiB、最低MemAvailable426409200KiB。原日志没有 `FFN0_CHAIN_PASS` 或 Down 配置/末残差终态。没有重启原尝试，不把工具失败解释成数值错误或已证明的 DUT 死锁。

新static、同SHA Wi reader 短测、冷LN前缀、运行包/ROM/fixture/工具身份及五项拒绝等原准备证据保留各自有限范围。原full中 LN 源通过，Wi writer成功绑定；Wi矩阵20992 stripes、20992 F32、1312 AW/W/B在原检查后出现 `WIGQD_WI_COMPLETE cycle=271090`，Wi reader/GATE/第二次Q也真实推进。Wi当前日志的分项观察计数不能混作另一套矩阵实例或完整整链时延。

可直接从本次原日志定位的后段：Wi reader 最终四次row_done、20992 scalar；G issue/return/emit 均10496，GATE写656 AW/W/B；第二次量化读656 R、Q math/group输出按冻结检查推进，Down W 三端口最终 R=20992/20992/2624，`physical_W_published=1` 于cycle358880、`scale_checks=83968`。最后认可 `FFN1_PROGRESS work=282858`，guard显示自该语义进展120.092913s后触发，累计129条认可/0拒绝。日志末边沿不是精确停机周期：Down cfg、Down实际writer TMP、残差双源读/加/写、最终gold及655360B保护终扫均**NOT_REACHED**。旧AT049到Down与AT054局部残差的限定PASS不相加成此样本。

当前冻结TB在 W 发布打印之后进入 Down 候选/owner claim 检查（`frozen_new/ffn0_chain_tb_v1.sv:2602` 起），却未打印 Down cfg 的成功标记或 Fatal。现有输出不能区分零时间求值问题、时钟继续但无握手或缺失观察点；下一定位应保存独立信号/阶段证据，不能按 last cycle 猜 DUT 状态。

运行包冻结源及身份由 `source_manifest.json`、`package_manifest.json`、`preflight_full.json` 和完整/负例记录给出。事后只读 `verification_host.json` 实际重核342条源码引用/340个唯一路径，以及262个运行文件的源/包/本次full副本，bytes/SHA均一致；它不追认未列出的运行期dlopen资源。static/short/pilot/full的33/20/4/4条实际policy记录均为CPU0–3/nice19/idle匹配；四段耗121.554387/19.638691/24.189397/2080.298887s、峰3023612/1317680/1035304/1036164KiB。原始 `guard_full/driver.log`、`guard_full/guard_trigger.json`、`guard_full/guard_result.json`、`result_full.json` 保持不变。当前无性能整链cycle或联合物理资源结果。M005阶段A可在其新总预算内定位和做受影响修正；FFN4旧唯一full额度不回填，M003/M004仍开放。
