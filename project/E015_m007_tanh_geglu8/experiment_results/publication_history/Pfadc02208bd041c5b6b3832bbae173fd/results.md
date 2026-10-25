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

恢复后实证更新（替代上文排队状态）：AT064纯G三块原12,288元素/122,880 FP9+H比较PASS，183拍首消费/II1/pending183；AT065声明顺序编译FAIL保留，AT066只移动声明后build成功。AT067真实银行三块PASS：768写ACK/1536读/3release，首消费185，跨s读/输出gap1，服务697/696/696、排队0/257/71拍；AT068末G held17拍阻slot0复用、另一槽在途、pending200，全部债实际退零。

AT069同v4中样32768/327680节点、4096读/8release通过；实际18.410718020秒和217.580845675秒门后，AT072完整335872 G/3358720 FP9+H逐位PASS。20992真实32宽写及匹配ACK、41984真实读、82release，首消费185拍，完整自然eligible→实际done42171≤42240，max单块服务697≤768，读/输出gap1，20735真实读写重叠沿、81次另一槽math+SFU在途时独立release。held正常done17及真实lease release通过；child129.274490395秒，328真实semantic事件、owned清理零残留。这个PASS仅签正常G独立组合，不代签错误排序/父FFN/联合SFU/资源/物理。

AT071源声明精确账：新增G control46938bit=5867.25B，bounded arithmetic payload25600B（含前级1024B）、固定数值对齐736B；FP叶数值pipeline和冻结SFU按已有单列账，不重复混算。控制超4KiB，逐字段可推导常量/序号与真债区别已记录，但没有实现扣除/压缩或私改共享接口。AT070四案独立稀疏错误参考及AT073相同RTL新TB编译完成，AT074同v5中样验证中，首错/显式discard/无reset新gen仍开放。


---
Published: 2026-10-22T09:08:58.960713+00:00
Publication: P476f1fac40864daf8a319eb37150f033
