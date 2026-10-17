# FFR1 四行残差错误语义与计量回放

2026-10-14；D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01；M004/SM005/E005/R001；A002。**AT054 PASS_SCOPED_LOCAL_FOUR_ROWS**：保留AT053正常四行加法和真实双源AXI/目标写的数值路径，局部状态码改为原`laya_types.h`的E_NUMERICAL=6、E_INTERNAL=8，补齐三类实际AXI错误与独立量测。AT050 skip/Down仍是TB预装的声明外部源；本次不把末残差接入AT049同runtime，也不签生产hub、普通Q/L或完整请求。

## 冻结变更与独立期望

[AT054 manifest](../attempts/AT054_FFR1_status_measurement_01/source_manifest.json)的16项冻结/外部身份逐bytes/SHA核对；leaf、返回槽、槽52例TB、skip/Down/最终gold与原AT052/AT053分别同SHA。AT053→AT054残差DUT [冻结diff](../attempts/AT054_FFR1_status_measurement_01/dut_diff.txt)只有两项状态常量与三处非OK AXI赋值变化，正常读算写路径不变；新增联合TB/guard/runner/Tcl用于受影响回放。`laya_types.h` SHA `eae5761a…`随包固定。未重跑未变52例；其原`RNE_ZERO_DIRECTED_RTL_PASS count=52`仍仅按AT052证据引用。原失败与AT053收据不改写。

数值/描述符/AXI的期望码取原枚举和本合同，不读取DUT私有常量。五个错误描述符继续E_PROTOCOL7、零新增AXI。首元素NaN与两有限最大值加法溢出各返回E_NUMERICAL6、零新增AW/W/B、无有效发布；三个AXI错误由TB在**实际首skip R、首Down R、首B响应**注入非OK，均返回E_INTERNAL8、响应上下文稳定七拍后实际消费一次。两种R错误没有新增写；B错误如实产生并退休**1 AW/1 W/1 B**，第一64B真实改写且按gold读回，无成功发布、无额外新发事务。该有限样本不覆盖畸形RLAST、取消恢复或生产16bit完整错误包；`cfg_context`仍为416bit不透明回显，其他标量身份只是固定子集核验。

## 正常四行原gold与精确边沿

[原full日志](../attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log)在同一冷启动完成两个外部源各256单拍AR/R、4096 F32加法接受/返回/结果消费、256 AW/W/B。目的16384B对AT050独立enc0末输出逐bit一致；TB在错误探针前终扫两源与目的三个64KiB窗口共196608B：源16384B各自保持、目标16384B gold/written全覆盖，三窗其余哨兵未变。正常末W103325、真实末B103340（15拍后）、首次成功响应103341、保持七拍后消费103349；`FFR0_BOUNDARIES total=103350`是正常终扫之后的打印点，后续错误探针继续执行。xsim最终`$finish`为1038820ns；按冻结10ns时钟折合103882个TB周期，这是**从结束时间推算**，不是日志直接打印的TB周期。

以下cycle是TB在posedge **NBA更新前**取样的真实握手/标志边沿；`cfg`在61受理：

| 项目 | 首/末cycle |
| --- | ---: |
| skip AR、R | 62/102927；67/102930 |
| Down AR、R | 68/102931；72/102938 |
| 本地source_locked升/降 | 62/102939；最后读债102938 |
| 目标AW、W、B | 457/103324；458/103325；464/103340 |
| 本地dst_published首次升、响应首次有效/实际消费 | 103341；103341/103349 |

加法接受→实际叶子返回4096项均为22个采样cycle，直方图`22:4096`、总90112、min/max22；4096项另有实际结果槽消费。它是当前叶子/包装的本地量测，不等于完整FFN时延。`cfg`受理至响应消费**含两端边沿**为103289cycle；互斥DUT状态0..10的周期依次为`1,305,1042,288,1484,4096,94208,283,281,1292,9`，严格求和103289。AR/R、AW/W/B接口stall可与状态区间重叠，不重复相加。先行五个拒绝探针使cfg绝对cycle61；该坐标不能直接与无探针版本比较收益。

## 真正进展、成本与范围

新guard进入模拟后只解析固定12个真实受理/返回/消费累计计数；每条有效进展至少一计数严格递增，重复/倒退/普通快照或带cycle的文本不续120s语义计时，倒退立即失败。新TB只在实际握手/叶子脉冲后可能输出进展行。冻结[host逻辑时间测试](../attempts/AT054_FFR1_status_measurement_01/guard_host_test.json)四组覆盖首R后周期快照、相同计数重复、真实新R更新、倒退；前两组在逻辑第121s、真实更新组在第180s判stall，未启动DUT或等待真实120s。原AT053全程五条进度实际递增的事实保留，其guard静态反例由本版受影响规则修正。此检查证明本guard对这些输入序列的判定，不证明任意DUT死锁不存在。

AT054 host/static/短错误/pilot/full五段顺序执行、均child0/trigger null；四段工具共104条实际CPU0–3/nice19/idle policy匹配。host约0.177s即退出，RSS/policy采样未捕获，不能补称有实际样本。static/error/pilot/full分别21.888815/25.840606/25.981984/26.254724s，峰RSS1390924/1395100/1372156/1383240KiB，最低MemAvailable仍远高于192GiB。模拟full有243条真实进展更新、0条重复进展通过；`FFR1_STATIC_PASS`、错误/正常PASS、终检和自然`$finish`均在无Fatal/ERROR日志中。唯一full启动前[成本决定](../attempts/AT054_FFR1_status_measurement_01/full_cost_decision.json)以本次一行guard墙钟8倍估207.856s及250000cycle保守估计准入，低于原3600s/40Mcycle帽；这是准入估计，不是硬上界或部署时延。未增加新HLS/OOC/P&R/上板预算。

[AT054收据](../attempts/AT054_FFR1_status_measurement_01/receipt.json)、[逐身份/guard核验](../attempts/AT054_FFR1_status_measurement_01/verification.json)和原日志为本结论入口。正常数据、三个局部64KiB窗及有限错误闭合不代表完整STATE0/1 BO终扫或真正双源producer/lease。AT049至Down四行长链与本次仍是两个runtime；普通逐窗口Q/L、上游Attention/WO、28+2层/122矩阵、13BO请求恢复、联合资源/物理时序和M003/M004保持开放。
