# FFN1 被动进展准备结果与前缀未准入

2026-10-14；D-M004-FFN-PROGRESS-REPLAY-01；SM005/E005/R001；A002。结论为 **COST_NOT_ADMITTED_INVALID_PREFIX_LAUNCH**。AT058/AT059 两份冻结尝试保留；本合同一次有因准备修正已使用，未运行四行 full，也没有本轮新 LN 源读、Wi/G/Down 或末残差联合动态结果。旧 AT057 的有界守卫停止不改写。

## 冻结身份和已通过的受影响检查

两次 manifest 各 336 项引用、334 个不同路径，逐 bytes/SHA 核查零差异。AT057 功能 DUT、生成物、FADD 叶子、fixture/gold、正常驱动/反压及存储映射保持。AT058→AT059 仅微测试任务名 `edge`→`tick` 与尝试 runner 路径变化；其余 21 项受影响本地闭包（含三份 FFN RTL）逐 SHA 相等，故 AT058 已通过的联合 static、适配器短测、wrapper 目的短测在 AT059 明示复用，不伪称重跑。

AT058 static 121.750s、峰 2946944KiB、child0/null，编译联合 TB 与同一个 35 分项被动观察器；实际部署的 7 份 LN ROM、63 项 fixture 与含 `FIXTURE=LN_FIXTURE` 的 11 个 plusarg 根在 verify-only 闸口 ACCEPT。适配器短测 25.181s、峰 1335100KiB、child0/null：原 256 次模拟 Down AW/W/B 的合法对照与一次残差受理、七拍等待、一次消费通过；新增旧/Wi completion、旧 TMP bank1/epoch2、错 Down 目的、缺末 B、缺 owner 退休、缺 READY、债未零、失败 done、done_valid 七拍但 ready 低等九个独立冷例通过。固定 HIDDEN 目的 `0x0000010100000002` 在 valid 等待和接受后与 local context 目的字段一致。这里退休由短 TB 注入，只签适配器受控路径。

同 SHA 的 AT057 残差 wrapper 短测 25.843s、峰 1350196KiB、child0/null。错 `cfg_dst_bank=0` 和错 `cfg_dst_base=STATE0` 分别在真实 descriptor 入口得到 E_PROTOCOL=7、源 AR/R 与目的 AW/W 均零、无发布、七拍响应保持及一次消费；合法 descriptor 对照真正受理一笔 skip AR/R，随后由测试注入 RRESP 错误，以 E_INTERNAL=8 有界结束。合法对照只证明真实源读入口可达，不是四行残差数值 PASS。适配器固定目的和 wrapper 可变 descriptor 两层不混写。

AT058 微测试 12.983s 在编译期因任务名 `edge` 是 SystemVerilog 保留字而 child1，原日志保留。AT059 只纠正该名称，微测试 20.842s、峰 1278824KiB、child0/null：35 分项逐个单独激活、ready 低时 valid 不计数、三 W R 端口同拍各计一次，总 work38。该原 RTL 打印经生产 parser 和逻辑时间测试实际读取，12 类序列通过；重复行、普通状态、重复 SIM_START、回退/未知字段不能续 120s，q0/q1/scale 单独推进均有效。AT057 原 52 条 W 日志只读构造候选累计值；新 schema 对每条均判增长，未冒充 FFN1 DUT 实测或继承旧时间戳。host 检查无 RSS/policy 采样，保持 UNKNOWN。

启动前 verifier 主机正例 ACCEPT，删一份 ROM 与改另一份 ROM 的两例 REJECT/spawned=false；真实 AT059 pilot 的运行期 verifier **没有执行到**，不能借主机反例替代实际 xsim 准入。六个工具 guard 串行，147 条实际 CPU0–3/nice19/idle policy 全匹配；内存和工具墙钟均在原帽内。

## 前缀停止与 full 不准入

AT059 pilot runner 错误地重新从冷 Vivado 工程走 compile/elaborate，而 AT057 已证的短前缀使用 static snapshot 直接启动 xsim。AT059 elaboration 本身耗 95s；7 份 ROM 在新的 `work_pilot` 目录完成 staging，但 120.435s guard 到帽时，实际 `runtime_preflight.json` 尚不存在、`simulation_started=false`、无 `FFN0_SIM_START`、无 `FFN1_PROGRESS`、无源 AR/R、无 `FFN0_PREFIX_PILOT_PASS`。guard `trigger=timeout`、child−9、峰 2974840KiB；这不是 DUT 停滞或数值失败，也不能将已编译 snapshot 记为真实前缀通过。

本轮没有可复算的新前缀速率，因而无法形成合同要求的可信 3600s/8GiB/40Mcycle 四行 full 成本准入；[full 不准入记录](../attempts/AT059_FFN1_progress_replay_02/full_cost_decision.json)已写 `admit=false`，full 未启动。冻结 snapshot 可供后继**重新制定**直接 xsim 启动方案时审查：从实际 static/snapshot 或本次 pilot 编译产物出发，先以同 manifest 对真实 cwd/7 ROM/63 fixture/11 plusargs 执行 verify-only，再在独立 ≤120s guard 下冷启动 xsim 并取得源 AR/R 与迭代观察。但该动作会改变本次 launcher，当前一次有因准备修正额度已经用尽，工程不自行重放或启动 full。

本次代码差异仅被动观察器/guard、启动封装及短 TB，功能 DUT 和原金值保持。观察表在[事件接线表](FFN1_progress_event_map_20261014.md)；[AT058 失败收据](../attempts/AT058_FFN1_progress_replay_01/receipt.json)、[AT059 收据](../attempts/AT059_FFN1_progress_replay_02/receipt.json)、[pilot 原日志](../attempts/AT059_FFN1_progress_replay_02/guard_pilot/driver.log)、[触发快照](../attempts/AT059_FFN1_progress_replay_02/guard_pilot/guard_trigger.json)、[两尝试身份/guard核查](../attempts/AT059_FFN1_progress_replay_02/verification.json)保留原始事实。

AT049 四行 LN→Down、AT054 局部残差及 AT057 前缀仍按各自原范围有效；本轮不能拼成同 runtime FFN 尾残差 PASS。双生产源 query/lease、普通多窗口 Q/L、Attention/WO、全模型/13BO/恢复、联合资源/物理时序和 M003/M004 继续开放。原单重工具、资源帽、整体控制停排及 G 仅 OOC 余额不变。
