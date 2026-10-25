# M007验收覆盖与推进依赖

2026-10-21；需求来源[合同](../../mission/M007_完整Attention高性能主干与部署闭合/contract.md)与[指标](../../mission/M007_完整Attention高性能主干与部署闭合/performance_requirements.json)。本表按可核证据分层，不能折算为完成百分比。

| 组成 | 当前证明 | 尚缺主线验收 | 承接 |
|---|---|---|---|
| F32 add/mul/div | 单lane逐位、II/延迟、OOC；shared256算术接口 | 全阵列资源/时序与整图首错 | SM008已限定，SM011继续集成 |
| QKV/PS/G/context | 真实同步端口；QK/AV数值读写 | 全phase父级唯一实例/联合容量 | A007；A010只读复用 |
| QK与AV | 完整S128单head分别逐位、4187/4508拍 | held读/完成交接已修复回归；完整head full/sliding已核11038拍；16head仍待验 | E010/R001→R002 |
| softmax/SFU/div共享 | 8lane EXP真实域II1/167拍；共享8div真实域32拍/错误退休 | 独立softmax2333拍及真实head串联已核；新leaf TANH单lane336262主输入/14123004主节点153拍/II1已核；八lane全336262已核；统一SFU/联合面积仍缺 | E010/R002限定完成 |
| RoPE/完整Attention | R003原B1三层真实128行×16head局部参考已核；完整Encoder0/full与Encoder1/sliding RoPE2070拍/全产品与QK/V逐位已核 | sliding RoPE及有限停顿已核；RoPE在途abort/reset恢复已核；新完整身份Encoder双head已核，新DIV长例11head前缀已核、semantic_stall停于head11；完整16head未验，R004纯层两种单head/取消已核，完整16head与whole-layer Check、QKV→WO仍缺 | HEAD16-06/R003实际参考已运行，生产RoPE/16head实现中 |
| W576四口供数 | 四代表可逆和真实AXI模型服务曲线/双槽 | 全120tensor接入、真实HBM/CDC、全服务物理 | E011首段收口，E012复用 |
| 8192MAC阵列/恢复 | 实际8192MAC II1；四代表N64各8192逐位、错误排债/reset恢复 | 完整预量化WO17945/QKV51833/Wi87839/Down44443拍已核；其余shape、真实F32联合、物理持续2TMAC/s仍缺 | E012/R002成本出口已接纳；R003真实F32首3块及新DIV恢复已核，完整F32 QKV56017/WO22129/Down55027拍已核；Wi/FC1/FC2成本出口，接R004纯抽取 |
| 量化/LN/FFN/向量 | 原数值参考/低吞吐历史局部 | E013最终三流/满队列/复位已核；LN精确标量1/25拍、phase6依赖8拍及LN-exp银行已核；完整128行plain/gamma LN逐位和16618/16626退休拍已核；LN父集成/GEGLU/残差待 | 量化限定完成；LN-05/E014限定收束，小OOC hold违例保留；TANH-G8-08/E015单lane局部153拍；div12 setup+0.182/add3_e setup+0.098，全部hold/P&R未闭合；新leaf全样已核 |
| CPU业务前端/尾部 | 原生Session156检查、full/lazy与冻结请求逐位一致 | input≤0.75ms/tail≤2.25ms的200样本仍有越帽，保留FAIL | E009/R002冻结；CPU性能后继开放 |
| Host/XRT与整机 | ABI/身份/error合同和未绑定后端 | 真实设备BEGIN/一次H2D+D2H、全30层同runtime、200样本及60秒吞吐 | 依赖实际平台/硬件 |
| 物理与GPU对照 | 部分叶子OOC，供数整体COST_STOP | 300MHz联合布线/资源/U55C实测；本地A6000同口径实测 | 尚未执行，不由局部乘算替代 |

当前无需要用户追加决定的普通实现阻塞；缺真实板卡不阻断可独立实施/仿真的部分。主控收到交付即核对并接续，保持原始失败与版本边界。

2026-10-21增量41：当前f4508add共享FP消费者完整全128原context→WO已核131072值/22129拍，仍是保存独立context局部输入。E016/R001 SINGLE-PARENT-11已派发A010，生产父实际启动/结果待工程收据；不把合同登记当验收。

用户已明确在八lane阶段收尾后暂停：增量44接纳八lane全部336262主输入/14123004主节点153拍II1；G/父接线保留未验源码，不启动后继。恢复入口M007_pause_20261021.md。


2026-10-22：用户明确恢复M007，原暂停已解除；A010父集成/A008 G/A007接口支持按原范围接续。此执行状态变化不升级上表任何验收结论。


2026-10-22增量45–47：G双槽原银行组件通过，尚未签真实G输出/吞吐。E016实际唯一资源父展开与3746B控制声明账已核；catalog同版4096量化/A写确认→768公开QKV写/24576值、8364拍三块前缀通过；8非法身份/跨层key零工作拒绝及无reset后继通过。完整QKV/Attention/WO仍未闭合。专用长例guard的停滞/重复计数/真推进反例通过，后继长例须实际绑定使用。

2026-10-22增量48：E017两个真实整数helper的17601连续输入和CE/reset行为已核，完整IO约束synth+opt各4DSP/34FF、LUT33/47，setup+0.624ns/hold+0.386ns、零黑盒。raw reset不清payload；此测量不签F64mul、EXP8、联合SFU或布线300MHz。父完整QKV→首head仅处于实际运行，结果未升级。


2026-10-22增量49–56（优先于上方历史时点）：旧父同runtime完整QKV→RoPE→首head已核；当前父仅受影响共同reset/QKV3另SHA验收，独立真实context消费者完整4096组不代签父16head交接。完整G335872输出/3358720节点、42171拍已核；可达rank0/2/5/7四例全域错误排序及匹配FP status故障的实际排债/discard/无reset三块恢复通过。G新增控制5867.25B超额；压缩目标与物理共用尚未实现，不签联合4KiB。E017 helper OOC/F64有限域功能保持，parent资源链接成本中止，无联合SFU结论。E016 R002调试配置成本对照不改变硬件性能；完整16head/WO、FFN/30层、整机性能、联合资源/时序和上板继续OPEN。


2026-10-22增量57–58：G-COMPACT-14已实际通过，控制15709bit=1963.625B（原5867.25B），净省3903.625B；291bit新增上下文/有效/顺序完整入账，mask/债/覆盖未删除。当前构建全335872正常与rank0/2/5/7全域错误/三块新gen恢复、旧身份/保留位/同低8不同seq不退休真实债及实际正确返回均核过。完整周期42171不变。此处更新上方“G压缩未实现”历史时点；联合父4KiB仍OPEN。E016/R002仅同源QKV3配置比较，无观察提速，限定收束；完整父链未升级。


2026-10-22增量59接续：两项只读准备已交付，尚无新增完整16head动态通过。A008已实际收到G-RING-TAG-15，利用槽地址恢复tag低8位，目标再省256B；当前已验仍1963.625B，未实现前不改账。A010已实际收到FULL-PARENT-15，E016/R003补完整16head/context/WO供数及终点checker；独立static600/RTL6000、完整单次≤3600、同版两head成本门与600s保留，无旧余额转移。A007提供的附加80.625B条件复用余量过小，暂不改生产共享模块。后续采用更小G控制和原layer coverage的真实单份存储，尚未签联合4KiB。


2026-10-22增量60–61（最新）：G ring-high8实际1707.625B/math11343bit，完整正常42171拍及受影响full rank0/inverse-row恢复通过；rank2/5保留AT121/122原身份。当前e354 AT007完整原Encoder0 Attention父链在同runtime完成QKV393216、RoPE2048、16head、真实context4096、同quant/A发布与真实债退休、WO131072、独立243bit成功回执held5和唯一退休；父cmd→末WO256947拍通过。此更新上方历史“16head/context→WO未验”，但仅限本条原Encoder0 Attention正常链。完整Encoder/FFN/30层、Decision/bias、真实context故障恢复、联合资源/4KiB/布线/部署仍OPEN。CONTROL-ARENA-16已派发实现，尚无新的共享workspace通过结论。
