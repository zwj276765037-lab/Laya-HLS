# KB1集中审核：保留合并写，下一步检验更早完成输出

R-SM005-KB1-20261013；主控2026-10-13。回复工程KB1集中交付，并合并W加载与输出服务下界两条补充。依据用户已授权的测量优先重排；这是主控阶段判断，不登记为新的用户批准。

## 已核结果

接纳AT002为限定四行Down正常算术样本PASS，保留KB1四row合并写候选。主控静态复核141个引用文件SHA/bytes、两版各26源（只有writer不同）、12fixture、3原生IP、相同TB/runner/guard/helper，原始六组计数与解析JSON逐字段一致；6段guard串行、95条实际资源策略记录一致。完整PS/F32 gold检查、输出地址去重、末B/局部publication和一次真实done消费断言保留。[核验记录](measurement_first_KB1_review_20261013/verification.json)。主控未运行DUT工具。

| 同一边界 | KB0 | KB1 | 减少 |
| --- | ---: | ---: | ---: |
| cfg接受到first done | 21100 | 16183 | 4917cycles / 23.3033% |
| cfg接受到actual consume | 21107 | 16190 | 4917cycles / 23.2956% |
| 全冷TB结束 | 48864 | 43947 | 4917cycles / 10.0626% |
| cfg前A填充 / W加载 | 666 / 27064 | 666 / 27064 | 0 |
| 实际AW/W/B | 各512 | 各256 | 各50% |
| 有效 / 物理写字节 | 16384 / 32768 | 16384 / 16384 | 有效不变，物理减半 |

四distinct预量化A、K2624/N1024、bias0/冷reset不变；335872 PS lane-group、4096最终F32、512 TN8 packet完整比较。互斥状态和21100/16183；STREAM减3539、DRAIN减1403、FLUSH加25，其余不变，合计减4917。接口stall彼此重叠，不相加为独立延迟。7cycle done反压保持；原AW/W门及按实际beat的B延迟策略相同。减少事务自然减少本profile的按笔等待，不能据此宣布真实HBM或稳态吞吐收益。

KB1工具static/pilot/full实际58.188809/84.266939/431.227749s，child0且无guard触发；工具墙钟不当硬件性能。receipt内继承成本标签“same frozen DUT”不准确描述候选身份，已有成本补充明确writer改变；保留原收据，不用此标签作相同源码证明。1923bits仅新增pack语义存储，物理资源/时序UNKNOWN。继承两个writer错误窗口未动态验；完整LINEAR、Wi/G/Q同runtime、生产请求、恢复及M003/M004均未关闭。

## 两个服务下界改变下一步选择

1. q0/q1各20992拍，原固定每5周期最多4拍，最乐观服务长度20992+floor((20992-1)/4)=26239cycles。实际加载27064，单改读取器调度的理想余量不超过825cycles，约全冷1.88%，且未证明可全部实现。加载占61.58%不是可消除成本比例，因此不为这个大数优先重做读取器。
2. KB1已全用256个512bit写拍。当前peer在真实B消费前不接下一AW/W，首AW到末B4927cycles；工程静态报告按笔延迟累计4608次decrement，约319cycles只是在首AW不变等假设下的乐观间隙界，不是已测可节省延迟。256是当前单拍事务格式的最少写拍数，不泛称任意AXI burst也至少需要256个AW/B。更深待发队列不能改变该peer的服务能力。

主控另核冻结resident/front/adapter：当前按全部128个tile遍历每个group，最终PS只在G-1输出；resident把logical sequence与已发数量绑定，front也有严格group-major游标，adapter按最终tile/row输出。因此下一可证伪目标是**分块调度能否使首批完整结果更早出现，并真实重叠写回和后续块计算**，而非先扩输出队列。此判断尚无新DUT或收益结论。

下一执行合同为[KB1后续阶段](../mission/measurement_next_stage_20261013.md)：只做一个64tile分块候选的有界判断；控制实验限定32项owner表的真实REQUIRE/ACQUIRE/RELEASE_READ更新，工具排在算术出口之后。FullRuntime整体HLS/冷INIT及生产恢复不恢复。原单重工具/分类帽/G仅OOC余额/5172s不重启不变。
