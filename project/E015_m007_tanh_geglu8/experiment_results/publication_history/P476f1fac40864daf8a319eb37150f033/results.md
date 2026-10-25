# E015：冻结TANH与恢复G阶段结果

AT055当前八lane全336262主输入/42033向量、14123004主节点逐位PASS，接受到实际消费153拍、每lane II1。含协议探测338828标量消费/14231096节点，pending256/flight152/held298、6种mode/身份/mask拒绝、真实17向量在途reset后64新gen向量、6非finite错误加2masked、外部release实际债屏障全部通过。child107.642217563秒，RSS839737344B，86条真实推进、最长guard gap8.414037240秒，owned后代/组零残留。A001 increment44已实际核对并接纳该限定功能范围。

AT052同版编译manifest4c5b6f70579f53890d75342ce4b0b4007b1cdbc1d1e82779aef364cb3e3384ac，drivera739bd6cd635a6bfe935f5890550300e2b2aace9a8e6d23e88109bd7fade1202；AT05332768中样17.962651286秒及AT054成本界212.7640610175秒≤300秒后运行。guard v3 SHAc6e61e709cab196edc9386fc3c0e64dcc61fd612bcd33fabd99a53e31453e294启动/取锁一致。

| 小leaf综合+opt | LUT/FF/DSP | setup WNS/TNS ns /失败端点 | hold WHS/THS ns /失败端点 |
| --- | --- | --- | --- |
| AT010 mul4 |442/120/2|+0.332/0 /0|−0.018/−0.380 /24|
| AT021 radix4 div12 |2266/828/0|+0.182/0 /0|−0.031/−3.824 /419|
| AT044 add3_e |527/208/0|+0.098/0 /0|−0.043/−1.466 /78|

同器件/全IO约束，零latch/blackbox/约束缺失；三个小leaf仅setup正，全部hold仍失败，无P&R/物理300MHz。原add/div失败保留。add3_e按AT031真实输入fraction→排序→对阶路径，把指数不等时对阶选择与完整尾数比较解耦；原191904和独立3888边界逐位PASS，3拍II1不变。AT049该版全单lane336262/14123004主节点PASS，153拍II1；AT040为旧add3_z完整单lane，不跨版升级。

AT051八lane旧TB组合ready采样导致额外真实接受，最终计数FAIL保留。AT052修正驱动后组合settle并强化main接受/消费/节点精确计数和真实17向量reset，AT053/055实证。旧AT008–013 exact loaded guard self-SHA UNKNOWN、AT034从未启动、AT048自由scope旧名说明均保留原件与窄边界，不改历史收据。

SFU tag/mask真实3328B、available32B及其它信用/lease/valid/core流水位另计；未签联合4KiB/总资源fit。未来EXP/TANH必须由A007复用单一队列与lease。暂停时未编译G草稿仍存uncompiled_g_preparation.tar.gz；恢复后的证据如下。八laneOOC、P&R、联合SFU/FFN、父级及部署NOT_RUN。完整阶段身份、费用和恢复边界见release_evidence_v1.json与tanh8_pause_handoff.md。

AT056/057 native pair组件PASS：1025笔32F32实际写、1537同步读向量、24592独立pattern位比较、128真实读写重叠沿，slot0→1→0、末写ACK/同步读/第三块/客户端屏障各17拍、真实写债discard和新gen重装。A001 increment45核验接纳组件范围；客户端消费是诊断模型，不能代签GEGLU输出退休。

AT058原产品fixture PASS：335872条、无新算术，reference2.459374242秒。AT059/061纯算术编译成功；AT060 FAIL保留（显示got/expected相等仍触发scalar断言，原因当时未定）。AT062 packed观察器FAIL保留：实际DUT输出有不同lane值，而期望构造重复lane0八次、status全零。当前直接读取原fixture逐lane final产品，独立中间/H/输出位比较均保留，AT063修正观察器构建排队；不能由此先行判断算术PASS。

新生产pure engine、单资源验证壳和TB已实现，AT065首次编译排队，仍未通过编译或集成仿真。全335872 G、自然eligible起点768/42240帽、held末G阻复用与全域rank/discard新gen仍待真实验证；未重跑冻结AT055。


---
Published: 2026-10-22T08:37:54.387189+00:00
Publication: P46febc0829634889ad82b342914a46a4
