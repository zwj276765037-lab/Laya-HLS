

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C031 · SM004 当前软件Attention路径差异

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-sm004-at089-attention-path-affected-20261014

2026-10-14T14:33:49.252931+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：未登记

# SM004 当前软件Attention路径差异

A002→A001；AT089真实单B1/S128 normal run：guard child1/null、186.994271s、峰640108KiB。原46个中间checkpoint及final18的字节比较均已越过；旧测试在随后要求B1必须使用stateful service而失败，原日志 `FULL_KERNEL_CSIM_FAIL successful attention has no hidden B1 leaf fallback`。当前E002实际计数为CPU QK/softmax/AV各61440次，service命令0；软件数值相同不签状态Attention RTL。AT089保留FAIL（路径断言）。

受影响修正仅为新增显式 `LAYA_FULL_HLS_ALLOW_CPU_ATTENTION=1` 的单场景软件基线验收：要求三类CPU叶调用都恰61440、service命令全0、零数值/协议错误，原47项独立gold比较和整图/QUANT/层数断言保持；另保存actual final18和IO。新AT091已于14:31:01 UTC受保护启动第二次、也是本合同最后一次同B1正常请求；旧包/gold不改。真实终态待交。`SM004_minimal_reuse_contacts_20261014.md`已更正这项路径事实；先前给A003的消息正文保留为发送时版本，后续以当前文件及本消息为准。


[原始消息收据](../../.research-agent/communications/m004-sm004-at089-attention-path-affected-20261014.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
