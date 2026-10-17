# E003/R003 物理GATE与G/QUANT分期里程碑交付

这是对`gate-parent-milestone-review-20261011`后续出口的实质交付。常规修复和运行均在原M003/L1授权及原资源帽内；没有新增OOC/P&R/上板。

## 新证据

1. `gate_store_04`：局部运行PASS。物理writer接tensor ledger，完整64行由四个rows16窗口组成并共用一个GATE Ref/epoch；完整tensor执行10496个真实AW/W/B，加取消场景总计10660。末B后才READY，另测错binding、重复消费、读债、跨窗口取消及同session恢复。202711 cycles、21.641107s、峰值1323428KiB。manifest SHA256 `3b277bcb27783335b8dfc1e6d2766c3f3303635e7b53bab2a118a0ef6b84b6be`；receipt SHA256 `7f4b0d945f0d46389bbbedcbba29c125c0752f53e07bdb1b467c6095fad5d982`。受控GATE word输入只签writer/store，不签真实GEGLU算术。

2. `gate_split_static_01`：局部静态PASS。当前唯一canonical GEGLU、物理GATE store、延迟QUANT和full dual-A层级编译/展开通过；48.698790s、峰值2133148KiB。manifest SHA256 `98c1eeaa0770cab88c301244e75abbe1c0822159e7d12a95c90509c8f3b9fe47`；receipt SHA256 `44fd5ef269465e2d321f70a272d37ace57aedb017b9854618f28bfdc33b88aa0`。无运行/数值声明。

3. `gate_split_04`：局部同runtime PASS。static 52.656369s；一行真实pilot 11769 cycles/32.550573s；full 758736 cycles/1054.961660s、峰值1326676KiB。四个G命令完成64行、335872 WI words、167936 GATE words、10496 AW/W/B；所有G结束前AR和quant为0，最后窗口末B后tensor才READY。随后一个独立Q命令领取window0，实际56 AR/2624 R，完成16 quant rows/2624 halves；GATE、q、d_full、reciprocal、scale和fullA四个rows4 view的1312项均核独立fixture gold，最后释放GATE/A lease并取消清理tensor。manifest SHA256 `bb7309b0e22f1de7940a144e8e93269367953851441705ade1cfba14ed4b9809`；receipt SHA256 `f8ad62afc4595dd7eb6d680b5cce1b4f5b6cb71d4381ea989ab6b47cb2ab9ad8`。

`gate_store_01..03`与`gate_split_01..03`失败均保留。split前两项是TB组合ready同拍采样死锁；`_03`的static/pilot已过，full因100000-cycle进度间隔触发120s semantic-stall；`_04`只修复TB握手采样和guard进度可见性，没有改DUT、fixture、gold或full覆盖。

## 成本记录修复

matrix runner现在由同一函数写最终manifest并把其SHA绑定到receipt，再决定是否启动full。`matrix_cost_stop_branch_01`以合成3601s>3600s执行真实拒绝函数，得到结构化`COST_STOP/started:false`；manifest SHA256 `01a85a6aedf2cc10d99221bce2fe5fda778e042206e6e5c8dae4ead82ac5f96a`，receipt一致，且不存在`guard_full`、`full.log`、`full.jou`。这项有界检查未启动Vivado，只签拒绝记录路径；`matrix_parent_views_07`的382.907547s功能PASS和预算DEVIATION原结论均保留。

## 范围和下一步

本批只证明实际canonical GEGLU多窗口同epoch→独立QUANT window0→fullA的局部链。其余Q/L窗口、LOAD→Q/L调度、真实fullW/matrix同runtime、唯一持久hub/generated caller、L2/L3、当前完整CPU/实际CSim尚未闭合。L0/L1保持PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。

模块design/results、R003/run和E003三摘要已更新并原生publish。工程下一步按现合同接真实QUANT fullA到fullW父matrix，补其余Q/L与LOAD调度，再接持久hub/caller。
