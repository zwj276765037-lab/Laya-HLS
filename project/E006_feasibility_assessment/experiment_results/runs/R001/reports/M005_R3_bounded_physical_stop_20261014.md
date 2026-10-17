# M005 R3 有界物理诊断终态：综合内存上限停止

2026-10-14；M005/SM006/E006/R001；A002。结论是 **COST_STOP_SYNTH_OWNED_RSS_24GIB**。AT087 的同一冻结代表 top 在联合 OOC 综合中于 277.203887s 达到 owned RSS 上限，guard 以 `owned_rss_at_or_above_limit` 停止 child（−9）。峰值 25,205,756 KiB，守卫上限 24 GiB＝25,165,824 KiB；最低系统 MemAvailable 408,212,128 KiB。7 条实际进程策略记录均为 CPU0–3、nice19、idle I/O。原日志没有 Vivado 综合 ERROR、`M005_SYNTH_COMPLETE`、有效 DCP、利用率或时序报告；不能判器件 fit 失败、报真实 LUT/FF/DSP/BRAM/URAM/Fmax，route 未准入。

## 真实链与物理候选边界

AT073 最后一次 normal full 在 cycle375074 的 Down→残差票据合取断言 Fatal。Down 真实 TMP 64KiB 检查窗口由16KiB有效写入/独立 gold 和48KiB未写哨兵构成；末残差与最终655360B终扫未到。Down cfg358881→首次done375066差16185cycle，至实际消费375073差16192cycle；两端采样计入16193cycle。3/3次新 full 累计4974.979578s，独立合法反压完整样本未运行。物理候选保持同顶层端口/算术/存储容量，但 hub、store monitor 和半精度解码的受影响组合实现有新身份，不能继承 AT073 为其整链 PASS。

AT087 输入 preflight 为 `ACCEPT`，核154项继承 source 和10项本地准备文件；新本地 top SHA `dc1be2563a2db3c84fd9f0df9b5f584dcb0553668b6210da30c221cbb63b7959`，hub SHA `61ff01bcb73b39401d5eab043337275036cf0018e5e0f75d9acfb84fe2decf57`，store monitor SHA `22212edd041265012efe0d8252a3ff6894899c01d41ab1ce6a6bcd7189962f10`，matrix resident SHA `2706e4b80322516a30d021473ebaa861da16581caef5f9895352e1f276496907`。AT087 相对 AT086 的 RTL/IP/ROM/约束一致，runner 只把综合无语义日志阶段的120s静默阈值置于3000s墙钟之后；仿真及route的120s语义阈值未改变。两尝试均未产生有效网表。

| 证据 | 结果 | 可用范围 |
| --- | --- | --- |
| AT079 旧AT040动态函数→固定上界函数差分 | 140个已知输入逐值一致；另测count 0/3拒绝、未知role不得接受 | 1/2 descriptor、1/32项、末项重叠、跨repeat/descriptor、同/异role、相接、owner边界、64bit回绕及固定种子128例；不是穷尽证明 |
| AT080 真实portal | 原7161cycle回归PASS；冷重置后帧合法但几何重叠BEGIN获E_PROTOCOL，响应保持、scope未开，7261cycle标记 | hub受影响接入；受控物理观察，不代签完整链 |
| AT081/AT083 综合 | 55.410566/56.655490s，分别停在store monitor动态几何扫描、matrix resident half解码while的RTL展开 | 无网表/资源/时序 |
| AT082 store monitor短测 | 35.598036s、3097cycle PASS；原16个64拍burst、65536B覆盖及错误/排空检查 | 同监视器局部范围，不代签所有几何组合/物理容量 |
| AT085 half解码差分 | 全65536个binary16输入，旧/新32bit输出逐bit一致 | 仅规格化函数，不代签完整matrix |
| AT086 综合 | 168.587982s、峰9,749,660KiB，被不适用的120s静默进展守卫停止 | 已越过上述展开错误；不是综合死锁/网表结果 |
| AT087 综合 | 277.203887s、峰25,205,756KiB，24GiB owned RSS保护停止 | 同候选物理成本上限事实；资源/频率仍UNKNOWN |

AT074/075/077旧展开错误累计127.352275s；连同AT081/083/086/087，本mission综合实际累计685.210200s/3600s。新增短/static与AT066–069缺计时项的保守记账见 `M005_budget_ledger_after_AT087_20261014.json`：短测上界283.855331s/600s、static上界1335.673109s/5400s；host历史执行时间仍UNKNOWN，不按零扣减。route已用0/3600s，但没有有效DCP或容量报告，不满足启动条件。

R3要求组合代价过大或预算停止即集中交付，本分支至此停止：不升24GiB帽、不再以新AT重试同候选、不自动改多周期hub或缩小检查/容量。此结果支持“当前组合候选在给定综合资源帽内未取得可评估网表”；它**不能**判整颗U55C、其它架构或FPGA项目整体不可行。M005阶段A完整功能/稳定性、阶段B资源/布线频率、整模真实收益均未证，A003条件v4不因本次失败改成实测性能。

原始路径：`../attempts/AT087_M005_joint_physical_synth_guard_07/{input_manifest.json,preflight_synth.json,guard_synth/guard_result.json,guard_synth/guard_trigger.json,guard_synth/driver.log,vivado_synth.log}`；受影响差分与短测见AT079/080/082/085各自`run_result.json`或`receipt.json`。原尝试和日志不回写。
