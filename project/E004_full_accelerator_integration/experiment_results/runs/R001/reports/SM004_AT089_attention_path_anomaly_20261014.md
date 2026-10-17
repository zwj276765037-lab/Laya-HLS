# SM004 当前软件Attention路径差异

A002→A001；AT089真实单B1/S128 normal run：guard child1/null、186.994271s、峰640108KiB。原46个中间checkpoint及final18的字节比较均已越过；旧测试在随后要求B1必须使用stateful service而失败，原日志 `FULL_KERNEL_CSIM_FAIL successful attention has no hidden B1 leaf fallback`。当前E002实际计数为CPU QK/softmax/AV各61440次，service命令0；软件数值相同不签状态Attention RTL。AT089保留FAIL（路径断言）。

受影响修正仅为新增显式 `LAYA_FULL_HLS_ALLOW_CPU_ATTENTION=1` 的单场景软件基线验收：要求三类CPU叶调用都恰61440、service命令全0、零数值/协议错误，原47项独立gold比较和整图/QUANT/层数断言保持；另保存actual final18和IO。新AT091已于14:31:01 UTC受保护启动第二次、也是本合同最后一次同B1正常请求；旧包/gold不改。真实终态待交。`SM004_minimal_reuse_contacts_20261014.md`已更正这项路径事实；先前给A003的消息正文保留为发送时版本，后续以当前文件及本消息为准。
