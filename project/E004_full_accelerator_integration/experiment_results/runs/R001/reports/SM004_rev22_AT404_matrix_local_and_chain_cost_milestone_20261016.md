# 修订22 AT384–404：首 TN8 局部与组合 LN pilot

2026-10-16；工程阶段进展，修订22继续实施；不签独立主例或父图动态矩阵。

AT394 在实际下层/Q16 边界建立 16 行 A 窗口，合法 claim、错 epoch 拒绝、三拍保持与 release 通过；原 Q/scale 仅前四行有独立 gold。AT395 使当前 matrix/front、上层及 bank-link 同时完成静态展开。AT396 同时含真实 Q16 与 matrix/front 的 120.33197969943285s pilot 只到 Q16 行13，`timeout/-9` 为 COST_STOP，未到 claim 或 TN8。

AT398 同版 matrix/front 在合法 A/W 夹具 peer 上完成第一 TN8：1024 次同步 A 请求/响应、128 次 W 请求/响应、128 stripe、512 行组退休、16 次末组 PS 单口写、16 位 PS 覆盖及首 tile held。TB 从原 `qkv_rows4_output_f32.bin` 逐字节读取前四行 t0 的 32 个 final，与实际 PS 写数据逐位比较；后12行 A 使用零值合法 peer，因此不签独立算术 gold。该边界没有真实 W cache、LN/Q 上层或 AXI B。

AT402 改用同版唯一生产 `laya_w_prep_service_v1`/`t4_dual_w_cache_v1` 的实际 W 冷载，真实 AXI peer 取得三口 24576/24576/3072 R 及 AUX8，再由 matrix/front 真实 lease/read/ret 完成相同首 TN8 和前四行 32 个 final gold 比较。W cache 的任务 context 必须有非零 task ID；AT401 的合法冷载后因 TB context 全零被真实 lease 拒绝，日志 Fatal 保留，AT402 修正 TB 刺激为 task ID 1 后通过。AT399 编译缺 TB 声明、AT400 夹具初始化竞态及终止运行均保留。

AT404 将当前上层、下层、matrix/front 和 W/cache 放进同一独立组合层静态展开；仅做 `PREFIX_16` 成本 pilot。120.34823258407414s 到真实 LN 行2 退休、行3 源/计算在途，未到完整 LN16，`timeout/-9` 为 COST_STOP。按合同不能以三行速率外推、不能动态延帽或启动 1800s 主例。该 TB 在 A16 后目前立即 finish，且其 AXI writer peer 仍只允许 norm route2；AT404 的展开与前缀不证明 matrix PS/B 或整个 LN128→TN8 主链。

当前工作源码的 matrix 服务 SHA `8b6416ea…`、上层 `fde9304e…`、下层 `9825b8be…`、front `938a910b…`、W 服务 `519a2ccb…`。AT398/402 的完整冻结身份和实际输入见各自 `source_manifest.json`；AT404 另有独立闭包。原 AT386/388 旧 abort TB 错误、AT392 错夹具终止、AT393 timeout 与本轮所有失败不回写为 PASS。

[逐笔机读账](SM004_rev22_guard_ledger_AT384_AT404_20261016.json)记录36 guard、248条实际政策样本零 `matches=false`；精确 static 517.3644667509943262/1800s、RTL 851.543613880872725/3600s，余1282.6355332490056738s/2748.456386119127275s；host 完整 UNKNOWN。机读表的 `PASS_SCOPED` 仅表示有终标且日志无 Fatal，具体功能范围以本报告和各冻结 TB 断言为准。

下一步在原修订22预算内完成唯一 front/W 服务的父层抽取、上层 PS writer 合法局部入口与真实 B/退休验证、固定父 exec011 委派；新生产组合身份变更后只补受影响测试。完整独立 LN128→首TN8 主例、父动态 W/Q/TN8、错误首错与 store 延后、全384 tile 和后续模型仍 OPEN。成本门在取得同版完整 LN16 样本前保持关闭。
