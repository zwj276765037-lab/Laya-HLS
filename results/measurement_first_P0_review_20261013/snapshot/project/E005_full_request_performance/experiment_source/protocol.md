# E005当前协议：局部算术测量与优化

当前SM005/R001遵循D-M004-MEASUREMENT-FIRST-01，来源mission/hardware_measurement_replan_20261013.md。M004完整目标保持，局部KB0/KB1与未来完整请求B0/B1分开。

唯一实现根E002/experiment；新测量证据E005/R001/attempts/AT。当前入口为四distinct行resident Down，K2624/N1024、4096独立F32、预量化A、bias kind0、冷reset。KB0复用E003/R003/resident_regression_02冻结26源闭包与12独立fixture，不能用旧结果预签六处已变live源码。新增TB只补计量和真实完成消费，保持原PS/F32/AXI/最后B/owner检查。

数值先于性能：全部335872 lane-group PS及4096 F32逐位比较原独立gold。计量区分reset与fixture加载、真实A填充、严格W AXI读取及校验、cfg握手到done真实有效、7周期故意返回反压与实际done消费；state分解逐周期互斥求和，接口stall可能重叠单列。计数不得代替数值断言。候选保持同冻结fixture、算法和归约顺序、反压profile及起止边界。最多两个不同候选；无收益也记录原因。资源缺报告则UNKNOWN，无OOC/P&R/上板。

全项目单重工具，CPU0–3/nice19/idle I/O，MemAvailable>192GiB。static/HLS24GiB/1800s，真实进展stall120s；RTL8GiB/3600s/40Mcycles，pilot≤120s，入口更严格上限沿用。full由同profile pilot估算并冻结；不以周期心跳延长stall，不提高帽。失败不删断言/改gold，最多两轮有依据修复无有效样本则切LN→Q备选。

局部测试台真实驱动kernel并提供本实验模型输入/存储响应；不得计算注入kernel输出。预量化A和受控owner/AXI peer只证明声明算术链，无完整LINEAR、executor、13BO或请求退休结论。完整目标另按M004/SM004验收。
