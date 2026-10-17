# KB0 resident Down实际测量

AT001，PASS_SCOPED_KB0_DOWN_MEASUREMENT。四distinct预量化A行，K2624/N1024，bias0/冷reset；全部10496stripes、41984rowPS/335872lane-group及4096最终F32与原独立gold逐位相同。真实fullA/dualW/nativeFP/局部owner、最后B和一次done消费通过。

| 边界/指标 | 实际值 |
| --- | --- |
| 全TB cycle0→完成后检查结束 | 48864cycles |
| cfg接受→first done-valid pre-NBA采样 | 21100cycles |
| cfg接受→真实done消费 | 21107cycles |
| 完成有效后原有故意反压 | 7cycles，实际consume一次 |
| A填充接受→publication post-NBA检查 | 666cycles |
| W加载接受→publication post-NBA检查 | 27064cycles |
| 最后PS→最后B | 155cycles |
| 最后B→first done-valid采样 | 8cycles |
| AW/W/B实际消费 | 512/512/512 |
| 有效WSTRB/实际W物理字节 | 16384/32768，利用率50% |

互斥actor状态覆盖[cfg接受,首次done采样)共21100cycles：{"IDLE": 1, "ACQUIRE_A": 2, "LEASE_W": 2, "SETUP": 1, "READ_A": 82, "WAIT_A": 164, "STREAM": 17992, "DRAIN": 2792, "FLUSH": 59, "RELEASE_A": 2, "RELEASE_W": 2, "OWNER_RETIRE": 1, "REPORT": 0}。其和严格等于对应区间，不等于全TB。A/W加载位于cfg之前。原48862全TB只到7cycle held-response末端，新48864增加实际consume及deassert检查；DUT first done边界保持。

以下条件重叠，不相加成延迟：writer packet-not-ready7761、tx-valid9858、已送AW/W但无B8705；PS commit-not-ready9586、native credit7414、W return-not-ready7414、W request-not-ready7338。原held_B9217是TB在negedge逐次减少17+(实际beat序号%3)的计数，不代表9217个可直接消除的DUT周期。W加载R-not-ready三路均0，q0/q1实际R各20992、scale2624；TB active R gap各5248/5248/656。

KB1选择降低输出存储工作量：四row pack cache合并相邻半拍，同全部gold、计算/归约和响应策略。理由为真实50%strobe和writer反压链，而不是从最大state项直接推断根因。预计512→256实际事务仅是待验证预期；不改变TB delay策略/7hold，不跳过加载。额外pack语义字段1923bits，具体LUT/FF/RAM/时序与联合资源UNKNOWN；本轮无OOC/P&R/上板。

static 57.309921s，pilot 85.733545s，full 437.203005s；各child0/trigger null。full peak 1421840KiB。工具墙钟只作成本，不能当硬件性能。实际计数与原日志见AT001/evidence/measurement/measurement_full.json、raw_full.log、receipt.json。

范围为局部冷样本算术链，预量化A/受控owner及AXI peer；无同runtime Wi/G/Q、完整LINEAR/13BO请求、稳态吞吐、冷暖对照或物理频率结论。
