# KB0→KB1 resident Down同口径比较

SM005/E005/R001；AT001 KB0与AT002 KB1均实际PASS。KB1同row合并相邻两个TN8半拍，4096 F32和335872 lane-group PS全部保持原独立gold；命令到首次done减少4917cycles（23.3033%），到真实消费减少23.2956%，全冷TB减少10.0626%。保留KB1为当前有限normal算术样本的改进候选；本轮不为凑数追加KB2。

| 真实边界（cycles） | KB0 | KB1 | KB1−KB0 | 减少 |
| --- | ---: | ---: | ---: | ---: |
| 全TB：cycle0→消费后检查结束 | 48864 | 43947 | -4917 | 10.0626% |
| cfg接受→首次done有效（pre-NBA采样） | 21100 | 16183 | -4917 | 23.3033% |
| cfg接受→真实done消费 | 21107 | 16190 | -4917 | 23.2956% |
| cfg前A填充 | 666 | 666 | +0 | 0.0000% |
| cfg前W加载 | 27064 | 27064 | +0 | 0.0000% |
| 首次done有效→消费（故意反压） | 7 | 7 | +0 | 0.0000% |
| 最后PS→最后B | 155 | 133 | -22 | 14.1935% |
| 最后B→首次done有效 | 8 | 8 | +0 | 0.0000% |

全TB包含冷reset、fixture填充、实际W读取、命令、末B及原7周期done保持/实际消费/去有效检查。A/W加载均在cfg前且不变；原历史48862不作为本A/B分母。计算/输出重叠，cfg→done不是纯算术忙碌时间。未重复冷暖或稳态样本。

| 输出/实际握手 | KB0 | KB1 |
| --- | ---: | ---: |
| 最终TN8 packet / F32字 | 512 / 4096 | 512 / 4096 |
| AW / W / B | 512 / 512 / 512 | 256 / 256 / 256 |
| 有效WSTRB字节 / 实际W字节 | 16384 / 32768 | 16384 / 16384 |
| WSTRB利用率 | 50% | 100% |
| 一次实际done消费 | 1 | 1 |

唯一DUT改动是writer内四个row-keyed pack缓存；26源中其它25项、12fixture、3native XCI及TB/runner/guard/helper一致。原AW周期门cycle%7、W门cycle%11、B延迟17+(实际beat序号%3)、done保持7cycle未变。事务减少自然减少本profile按事务收取的B等待，不能直接推广到真实HBM延迟/带宽。原raw的六类计数与JSON逐字段一致。

| 互斥状态：[cfg接受,首次done有效) | KB0 | KB1 | 差值 |
| --- | ---: | ---: | ---: |
| IDLE | 1 | 1 | +0 |
| ACQUIRE_A | 2 | 2 | +0 |
| LEASE_W | 2 | 2 | +0 |
| SETUP | 1 | 1 | +0 |
| READ_A | 82 | 82 | +0 |
| WAIT_A | 164 | 164 | +0 |
| STREAM | 17992 | 14453 | -3539 |
| DRAIN | 2792 | 1389 | -1403 |
| FLUSH | 59 | 84 | +25 |
| RELEASE_A | 2 | 2 | +0 |
| RELEASE_W | 2 | 2 | +0 |
| OWNER_RETIRE | 1 | 1 | +0 |
| REPORT | 0 | 0 | +0 |
| 合计 | 21100 | 16183 | -4917 |

该表只分解上述命令区间。STREAM减少3539、DRAIN减少1403，FLUSH增加25cycles；收益不是事务减半导致命令减半。

| 主要重叠条件（不能相加成延迟） | KB0 | KB1 | 差值 |
| --- | ---: | ---: | ---: |
| writer_packet_not_ready | 7761 | 2819 | -4942 |
| writer_tx_valid | 9858 | 4928 | -4930 |
| writer_AW_W_sent_no_B | 8705 | 4352 | -4353 |
| PS_commit_not_ready | 9586 | 4691 | -4895 |
| native_credit_stall | 7414 | 3875 | -3539 |
| W_return_not_ready | 7414 | 3875 | -3539 |
| W_request_not_ready | 7338 | 3829 | -3509 |
| AW_not_ready | 129 | 64 | -65 |
| W_not_ready | 0 | 0 | +0 |
| TB_B_delay_decrements | 9217 | 4608 | -4609 |

writer→PS提交/native credit→W供数反压的重叠计数一并降低，与合并写降低后端工作量相符，但这些计数并非互斥，也未独立隔离每一因果延迟。held_B仍只是TB delay decrement，不能全算可消除的DUT周期。

下一可考虑的实际成本是cfg前W加载/校验：27064cycles，占KB1全冷样本61.58%；真实q0/q1/scale R分别20992/20992/2624拍，共2854912B。三路DUT R-not-ready为0；TB active-R-gap分别5248/5248/656且与加载活动重叠。因此下一阶段应先区分真实供数profile与DUT必要加载/校验工作，不通过减少TB等待冒充DUT优化。生产复用或暖态需要另建明确边界的同profile基线，当前未测。

额外pack字段3×(512data+64addr+64strobe+1valid)=1923bits；算术IP不变。选择/仲裁/mux及物理LUT/FF/BRAM/时序、联合资源仍UNKNOWN。本轮未跑新OOC/P&R/上板。两个原writer错误窗口未动态测量，normal PASS不能代签恢复或生产接入。

KB1 static58.188809s（peak2402228KiB），pilot84.266939s（peak1424908KiB），full431.227749s（peak1426732KiB/2153RSS捕获）。三阶段child0/trigger null；六个KB0/KB1 guard起止串行，全部实际policy符合CPU0–3/nice19/idle I/O。墙钟只作工具成本。KB1 receipt内继承的same frozen DUT成本标签指算术/fixture历史参考，writer实际已变；启动前另有KB1_cost_basis_20261013.json限定，原receipt不回写。

P3合并取舍：薄HLS显式寄存器/固定容量RAM/有限微步骤优先，手写RTL同schema备选；FullRuntime整体HLS/冷INIT继续停排。尚未冻结下一控制原型。主控已明确目标应包含原容量source/window或owner关键表的真实全键校验、私有候选、一次commit/reject，而非仅24LTX/16LTC传输。设计排序没有生成/资源/周期验证含义；不为本报告恢复控制工具。

范围：四distinct预量化A、K2624/N1024、bias0/冷reset，真实fullA/dualW/nativeFP、受控owner/AXI peer、全部PS/F32、真实最后B/局部publication/一次done消费。完整LINEAR、Wi/G/Q同runtime、13BO请求、恢复、物理时序及M003/M004最终验收均未完成。

原始与可复算数据：

- [比较JSON](KB0_KB1_Down_comparison_20261013.json)
- [身份/日志/guard核查](KB0_KB1_Down_verification_20261013.json)
- [KB0计量](../attempts/AT001_KB0_resident_Down_measurement/evidence/measurement/measurement_full.json)
- [KB1计量](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/measurement_full.json)
- [KB1原日志](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/raw_full.log)
- [KB1收据](../attempts/AT002_KB1_Down_rowpack/evidence/measurement/receipt.json)
