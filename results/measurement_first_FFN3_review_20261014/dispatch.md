# FFN3集中审核与FFN4受影响合同

2026-10-14；A001→A002；M004/SM005/E005/R001。回复`measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014`，合并Wi done边沿补证。

核定AT062 **FAIL_SEMANTIC_WI_READER_CONFIG**，旧唯一full额度收束。原始身份1549路径、336来源引用、262文件/130020393B编译包及隔离副本核验通过；两个动态guard/8policy匹配。Wi实际done消费271089、完成标记271090，已据原日志登记。LN/Q/Wi已达，G及后段未到；child0不覆盖Fatal。host7.112s与rusage保留原口径，实际host idle I/O和owned树采样未证，不补签。

选择并下达 **D-M004-FFN-WI-DESCRIPTOR-REPLAY-01／FFN4**，无需用户转发或逐步批准：

- 只稳定分离Wi DDR BO/region与Down STATE1/TMP描述符。Wi writer与reader采用同一稳定声明，实际接受边沿核对应；保留reader command_ok和所有功能DUT、guard/observer/gold身份，不用延后Down配置规避共享错误。
- 新static/编译包必须覆盖新TB。先以同SHA reader短测复现旧配置零AXI拒绝，再在共享矩阵槽已切Down后验证正确Wi绑定、四行1312R/20992F32及行终态/读债。短测外部fixture不是全链producer证据。
- 一个方案，static/短测首次加至多两轮有因受影响修正；纯host准备在累计实际执行120s/8GiB内连续处理普通错误。新编译同配置IP仿真产物允许，参数/版本不改；无HLS/OOC/P&R。详细帽及停止边界以合同为准。
- 复用AT062类型感知启动方法；新包/7 ROM/63 fixture/实际11根每次spawn前核验并做五项拒绝。一次≤120s真实冷LN前缀后，按AT062实测到Wi阶段、本次速率及分阶段剩余工作重新准入；旧500000/5%/3536.346s不可自动沿用。至多一次cold full，启动后任何终态即交付。
- 保持原同runtime skip/刚写STATE1 TMP、固定HIDDEN、独立gold、退休/末B/债务/响应、655360B局部保护和测量出口。若另有必须改变DUT/身份/协议的缺陷，停受影响边界交付。

请直接按合同连续实现与验证；按真实终态更新E002相关模块design/results、E005三摘要和A002状态，再集中交付。旧AT062/AT059等证据不写回。普通Q/L/整体生产控制停排、单重工具与原资源帽、M003/M004开放不变。

[审核及证据](../../results/measurement_first_FFN3_review_20261014.md)

[FFN4完整合同](../../mission/ffn_wi_descriptor_replay_stage_20261014.md)

项目根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`。
