# M003 generated provenance审核修复与首个真实AXI monitor

交付ID：`generated-provenance-monitor-milestone-20261012`  
范围：M003/SM003/E003/R003，当前生产身份。  
结论：主控审核F1/F2/F3已闭合；一个固定role6、单descriptor、连续rows16的真实AXI512 store monitor已连接persistent hub并取得限定PASS。production top真实generated master、adapter内部排空因果、普通QUANT source lease、多role/QKV与完整数值链仍待实施。

## 审核项闭合

1. F1：`portal_controller_29`验证合法scope-active错误END保留generated tracker及issued bytes，不推进typed退休；只有`DRAINED=1/SCOPE_ACTIVE=0`的匹配END终态退休一次。
2. F2：`generated_provenance_ledger_07`与`generated_provenance_portal_10`验证`physical_drained=0`的END不返回终态，scope及首次物理错误保持到后续真实fence。
3. F3：CPU和RTL均连续通过33次同session递增request；typed槽只在较新合法CLAIM且旧域全部排空时回收，迟到旧request被拒绝，高水位不回退。

## 当前证据

| attempt | 结果 | 主要量 | receipt SHA256 | manifest SHA256 |
| --- | --- | --- | --- | --- |
| `portal_controller_29` | PASS | active错误END不退休；23.144976s/260820KiB | `cbb35b67b82e219833e85da05afa3a2e501da73a6ab3a7e111cd694358bf0739` | `54639a160b885121c9497f71348b6d59ab3c5fd9c97d0a3dffe0be8759c5568c` |
| `generated_provenance_ledger_07` | PASS | 301 checks、fence wait、33 requests、stale reject；22.229241s/260884KiB | `b8df6625fbf24b7a41a9501fefdce06778ccf16aadcd6fb329a32720d375701d` | `757b522a2f71427483b59dc25bea0ee43df25a9bb4c90e726102028d2fc2aa12` |
| `generated_provenance_portal_10` | PASS | 7107cycles、accepted148/retired151/terminal35；22.966027s/1435972KiB | `987f7ab09274392e51079978c7e79f875674db3e61446b7e84a09dcac687c5ec` | `c197e6da3c25062bba29f844fb5f817b4ccc3488b38636d639f71b3f1c1f7aaa` |
| `generated_store_monitor_03` | PASS_SCOPED_RUNTIME | 5961cycles、1024真实AW/W/B、65536B唯一覆盖、2本地拒绝 | `e46f6c8f60a82527e012764f09b1f1ed12f0621b9a70719a626af90fd6fe4c45` | `b6ee73cb068216e67c4e262068be4d3e0e0109180f53c5561147751aa6986a29` |

聚合核查191/191 current、191/191 frozen、191/191声明pair及580/580 receipt/manifest引用匹配，0 mismatch：

- `project/E003_production_chain_closure/experiment_results/runs/R003/generated_provenance_monitor_stage_20261012/verification.json`
- SHA256 `95d5aaf0a708a67f8bbf93b2310458b51af9de7dab18f12f8d9bcc4235735ab1`

`generated_store_monitor_01`编译FAIL和`_02`非法burst drain断言FAIL均保留；`portal_controller_28`、`ledger_06`与`portal_08/_09`旧身份PASS也保留，不用来代签当前闭包。

## 真实monitor的已验证边界

- BEGIN真实候选包在写前核role/geometry；不支持role不得开启物理scope。
- AW/W可独立到达并支持W-before-AW；合法单拍只有在全部WSTRB字节范围唯一后才转发。
- 1024个peer AW/W/B各自独立计数，末B及adapter fence都阻止END提前终态。
- 越界写转发前本地DECERR；非法两拍burst完整吸收两拍W后才返回本地DECERR，失败字节进入实际排空计量。
- cancel后保持安全排空并允许同session恢复。

## 证据边界与下一步

TB提供的`adapter_pending_zero`延迟只证明门控行为，没有证明generated HLS adapter内部待发store与该信号的真实因果。monitor当前固定role6、一个descriptor和连续rows16；production top真实generated master、多role/QKV、宽度转换及普通QUANT source lease未通过。

工程继续把真实generated store提交/adapter fence接到production top，并将persistent hub的source query/lease原子接入普通QUANT；随后做普通/GATE无复位切换、其余K/row-space/跨batch、多role/QKV，再继续LOAD、其余Q/L、matrix和当前完整CPU/实际CSim。L0/L1保持PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST，M003/M004未完成；无新OOC、P&R或上板。
