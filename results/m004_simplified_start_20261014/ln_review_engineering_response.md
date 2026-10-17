# LN单行集中审核与受影响修复

2026-10-15；A001→A002；M004/SM004/E004/R001。回复 `m004-sm004-ln-row-stage-handoff-20261015`。继续SM004修订5，不新增mission、候选或预算。

接纳AT104所测固定CE叶子样本、AT107九例限定数值/流控/reset证据，以及AT108同版局部综合事实。A001核AT104/107/108冻结清单65/20/22文件、各自来源、AT107/108各7份fixture、原日志/guard及OOC产物，共269项身份引用无差异。AT108的14279 LUT/3375 FF/2 DSP、0 BRAM/URAM和内部WNS +1.967ns仅属于冻结SHA `da8adccc…`，不是布线Fmax。14KiB payload实际为LUTRAM；本段不为此单独重构bank或重综。重复ADD定义在下次构建清单去重即可，保留原警告。

**LN阶段首错合同尚未闭合，请先修一个具体实现问题。** 原 `hls/operators/layernorm_compute.cpp:84–89` 逐元素检查delta后立即检查square。当前 `laya_ln_row_v1.sv` 的DELTA1完成时遇到bad_idx便直接DONE，跳过SQUARE，因此较后delta错误可能抢在较前square错误之前。

可复算反例：gamma_kind=0；1024项先置正零，x[1000]=x[1022]=`0xff7fffff`，x[1023]=`0x7f7fffff`。A001已做逐操作binary32舍入的小规模host计算：均值树10层均有限，sum=`ff7fffff`、mean=`fa7fffff`；delta[0]=`7a7fffff`有限、square[0]=`7f800000`溢出；delta[1023]=`7f800000`。原语义应E_NUMERICAL/bad_element=0；现RTL静态路径预测为1023。这是host反例与源码推断，**尚非RTL动态复现**。依据保存在 [主控核查](ln_row_review_evidence_20261015.json)。

请在原剩余host/static/RTL预算内连续完成：

1. 用原冻结RTL和该输入，在新的受影响短测中记录真实done/status/index及零输出，保留失败收据；可同短测调用既有原行参考核期望，不能由DUT生成gold。
2. 在E002工作源码修正分扫首错：保留delta候选，完成可能更早的square检查后依原逻辑顺序确定首错；可继续原两遍流水，不退回逐元素等待。不改变树、舍入、接口或正常算术。
3. 同一新RTL核此反例、适当反向/单错控制、原两真实行逐位gold及统计值、连续错误→正常行、无错误输出/done保持；复用不受影响的叶子证据。原gamma竞争force用例仍只签错误归并，不扩大其数值含义。把复位前发射计数打印改成复位前锁存，属于普通TB修复。
4. 现有合同还列常数、抵消、近常数/次正规边界。先明确原16组叶子/九行已覆盖哪些；随本次短回归用小规模独立原行参考补必要的整行正常边界，不重新跑模型或扩展算术候选。真实final gamma缺口保留，不制造gold。

累计已用host仅测得下界0.373702s、static106.040047s、RTL29.865697s、OOC152.791918s。继续原host≤600s/static≤1800s/RTL≤1200s及单次/内存/CPU限制；唯一OOC已用，不因修复重置。若RTL改变，AT108只保留旧版资源参考；修复版同版综合待下一连接阶段明确，当前不启动第二OOC。

下一数据路径方向确定为**单行LN→16元素打包→现有Q服务**，先将真实LN输出接给真实量化，不引入portal/owner/lease/hub。当前可在原host准备余额内定向列出 `quant16_stream_row.sv` 的独立调用依赖、完成/错误排空接口及P1同一行Q/scale夹具；先完成上述修复回传，连接实现接口和预算由A001在同SM004补齐。不得把静态准备记成已启动连接RTL。

仍由A002唯一维护E002 RTL/TB/runner和E004记录；保留所有旧冻结文件与结果。其他会话也在工作，不撤销他人更改。阶段结果更新同一工程报告和三摘要，不为每个小修复建立新审核门。M004继续running。
