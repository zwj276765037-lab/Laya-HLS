# M003 generated provenance Controller F1b修复交付

交付ID：`generated-provenance-controller-f1b-milestone-20261012`  
回复审核：`generated-provenance-cancel-fence-review-20261012`  
范围：M003/SM003/E003/R003，当前生产C++源码闭包的Controller END终态判断。  
结论：F1b在本范围取得PASS；未排空错误不再提前清除generated-store tracker。M003/M004总体状态不变。

## 修复与验证

Controller现在只在完整绑定且`DRAINED=1/SCOPE_ACTIVE=0`时清tracker并进入typed retirement。合法匹配的两种非终态错误均保留BEGIN绑定、descriptor geometry、实际issued bytes、`last_task_id/tasks_retired/op_calls`和活动tracker：

- `E_BUFFER, DRAINED=0, SCOPE_ACTIVE=0`
- `E_PROTOCOL, DRAINED=0, SCOPE_ACTIVE=1`

既有终态物理失败仍以`DRAINED=1/SCOPE_ACTIVE=0`恰好退休一次，随后同session更大request/task恢复成功；成功终态路径保持。codec继续允许如实表达未排空错误，没有以禁包代替caller终态检查。

`portal_controller_31`在CPU0–3、nice19、idle I/O及1800s/24GiB保护下PASS，实际23.100374s、261212KiB。当前生产闭包41个编译单元全部通过，受控Controller集成保持25条compute门户命令、13个typed task、四个普通P窗口和原G/LOAD/Q/四view matrix元数据路径。

| 证据 | SHA256 |
| --- | --- |
| `portal_controller_31/input_manifest.json` | `fc304513154cf641dd4300ae24db4754209df94f4f6adb6cbc6f723056914293` |
| `portal_controller_31/receipt.json` | `12033b85e4e8ab31deb7f652003bde54c9b002272d3dcd9ee84743ecc1f4d387` |
| `generated_provenance_controller_f1b_stage_20261012/verification.json` | `56c9ca233c239b23f820a79085f48aabdc43de588cbef359bd64886af03d2ebf` |

冻结核查为82/82 current、82/82 frozen、82/82 pair及171/171引用匹配，0 mismatch。`portal_controller_30`及更早PASS/FAIL均保留原身份。

## 边界与下一步

该attempt是受控service response下的C++ metadata/retirement回归，没有执行persistent RTL hub、真实AXI store monitor、production adapter fence、数值full graph或硬件。F2/F4此前限定证据范围不扩大。

工程继续在唯一持久hub实现逐窗口P、全tensor发布门、完整身份source query与原子读lease，并以该握手替换普通QUANT布尔来源准入；同时继续production generated master/store提交与adapter fence因果接线。L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，无OOC、P&R或上板。
