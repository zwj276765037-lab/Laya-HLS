# WIGQD1 AT032：同一DUT连续四行链的观测与有限正常验收

D-M004-WIGQD-OBSERVATION-01；M004/SM005/E005/R001。唯一一次新full自然完成，AT032 static/pilot/full均PASS。仅AT031测试台增加被动事务观察，另冻结一份runner；DUT、fixture、gold、响应策略、容量、单实例、epoch切换及链间无reset未变。此结果是B1/S128、batch0/row0四行、外部预量化LN_FFN A的normal RTL样本，不是完整请求、恢复、物理资源或时序验收。

## 数值、物理交接与完成

- 同runtime Wi resident：20,992 stripes、671,744 PS lane-group、2,624 packet、20,992 F32原独立gold；1,312 AW/W/B、83,968B有效写入、最后B、lease/读债归零、7拍done保持及一次真实消费。切换前有效区逐字节读回。
- Wi reader从真实DDR发AR/R，四行各5,248 F32标量、合计1,312 R并完成四次row_done；G真实算术和10,496 F32 GATE写回逐位gold通过，656 AW/W/B。量化真实重读656 R，328组q/scale及d/recip独立gold通过，唯一dualA epoch2实际发布并供Down读取。
- 同一resident/dualW/dualA进入Down：10,496 stripes、335,872 PS lane-group、512 packet、4,096 F32原独立gold；82次四行A返回、256 AW/W/B、16,384B有效/物理写入、最后B、A/W lease、两次累计局部publication、7拍done保持及一次真实消费通过。
- 结束时逐字节扫描327,680B DDR：Wi 83,968B、GATE 41,984B、Down 16,384B均对原gold；其余185,344B保留初始0xA5哨兵且written标记为0。原测试台所有断言完成后才打印`WIGQD0_CHAIN_PASS`。

| 实际边界 | cycle |
| --- | ---: |
| Wi cfg接受 / 最后B / done有效 / 实际消费 / Wi完成 | 54416 / 101319 / 101327 / 101334 / 101335 |
| G合法cfg接受 / Wi reader首AR、首R / 四次row_done | 101339 / 101343、101347 / 106944、121440、135936、150435 |
| GATE首AW、首B / 末AW、末B | 110092、110109 / 159310、159328 |
| 量化首R、末R / 新A实际publish marker / bridge响应后A ready | 159341、161680 / 162045 / 162057 |
| Down W publish / cfg接受 / 最后PS / 最后B / done有效 / 实际消费 / 全TB | 189121 / 189122 / 205163 / 205298 / 205306 / 205313 / **205314** |

G cfg接受→全TB结束为103,975 cycles；Down cfg接受→首次done为16,184，→实际消费为16,191。上述是新同runtime冷样本的实测边界，不把WI0/GQD0独立全TB相加。边界表的reader/GATE时间由新增真实握手观察及原末尾断言支持。原继承`WIGQD_BOUNDARIES A_publish=290`记录的是最初Wi输入A的发布；不能当作量化后新A发布。后者应使用本次`stage=1 kind=a_publish`的162045；162057是bridge响应消费后的A-ready观察。

## 对旧停止的区分

AT031末条原guard marker为G接受cycle101339。AT032在同一DUT和响应策略下实际观察到Wi reader配置101341、首AR/R101343/101347、四行read/row_done、G issue/return、GATE 656次B、量化及Down完整完成。旧AT031的120秒停止发生于没有覆盖这些事务的日志空窗；该历史COST_STOP不回写PASS，也不把101339称为真实最终停拍。本次证明这些事务在AT032样本中持续推进，并没有证明所有响应profile下都不会停滞。

## 冻结身份、工具成本及边界

AT032 manifest 103行、101个不同冻结路径；相对AT031的102行只改第57行观察TB并新增冻结runner。206个source/frozen bytes/SHA逐项匹配，工具身份匹配；冻结guard正则检查确认状态快照不计语义进展，17个真实握手进度模板均可识别。3段guard串行；实际policy 31/9/9条均符合CPU0–3、nice19、idle I/O，child0、trigger null。静态82.816283s、pilot22.584340s、full1750.811857s；full峰1,504,888KiB、最低MemAvailable402,375,072KiB。full准入估计2871.684102s，低于原3600s上限；pilot只到真实Wi W前缀，不代签完整链。

原始证据：[AT032 receipt](../attempts/AT032_WIGQD1_observation_01/receipt.json)、[完整日志](../attempts/AT032_WIGQD1_observation_01/raw_full.log)、[manifest](../attempts/AT032_WIGQD1_observation_01/input_manifest.json)、[身份与策略复核](../attempts/AT032_WIGQD1_observation_01/verification.json)、[诊断正则检查](../attempts/AT032_WIGQD1_observation_01/diagnostic_regex_check.json)。旧AT031 COST_STOP与本次有限PASS分别保存；整体executor、完整28+2层/122矩阵、生产13BO、完整请求/恢复、联合资源/物理时序及M003/M004仍未完成。
