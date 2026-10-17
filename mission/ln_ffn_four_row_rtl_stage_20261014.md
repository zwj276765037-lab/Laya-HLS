# LNF0：四行LN_FFN真实store→Q/fullA有限RTL

D-M004-LN-FFN-RTL-01；2026-10-14；M004/SM005/E005/R001。A002唯一实现/工具owner，A001集中审核。接续[LNREF0审核](../results/measurement_first_LNREF0_review_20261014.md)。按既有授权直接实施，不增加普通工具审批。新RTL结果NOT_RUN。

## 选择与范围

先将AT014 LQ0既有LN→真实store→Q/fullA诊断入口适配为原enc0 LN_FFN四行。它一次解决新opcode/layer/shape、实际地址/发布/lease和数值验证，取得后继接入QAR0所需的真实边界与成本。本轮不重复Wi/G/Down长链，不将两条独立PASS拼成LN→Wi→G→Down的同runtime结论。

复用AT014冻结的原baseline LN生成核与83项生成物（71 `.v`、7 `.dat`、5 Tcl），top SHA `b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798`。复用原producer shell、存储monitor/hub、provenance/source lease和真实quant/fullA叶子；不引入第二套同类硬件、一般owner表或全局executor。不能直接采用LQ1/R时序违例核。生成物或IP无法原身份复用时，保留具体不兼容/工具证据后交付，不自动重新HLS或编辑生成算术RTL。

声明外部源是AT038独立enc0 attention residual前四行；本轮没有Attention/WO/residual硬件producer。`enc0_residual_rows4.f32.bin` 16384B、SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`；独立LN gold为`enc0_ln_ffn_rows4.f32.bin`、SHA `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`。量化q4096B/scale256B继续使用已核AT035原fixture，正确小端解码SHA分别`839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`、`4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`。gold只作比较，不写入被测目的存储或fullA。

## 请求、布局与受影响封装

诊断数值身份采用原request3/generation1、B1/S128，P为LN_FFN0x12/stage2/layer0/batch0/row0/rows4、gamma0、D1024、eps `0x3727c5ac`，Q为QUANT0x20；所有P/Q/L、Ref/epoch/owner描述符、BEGIN/END/PUBLISH/source-query的完整键与窗口一致。包序号request_seq、task_id、provenance seq和模型request_id分开记录，保留原协议语义，不把旧41/301等包序号当模型请求号。若生成核实际不能接受这组合法身份，给出具体检查点，不伪造tag放行。

原fixture脚本将B1/S64、layer1/LN_ATTN、16行和64MiB诊断span写死。本轮必须明确改成新合同身份，并保持真实原STATE0容量16920576B；HIDDEN源逻辑offset0、NORM目的offset8MiB，4096B/行，四行目标8388608–8404991。依据原布局真源核l13m、producer packet、owner descriptor、query跨度和base/BO映射，不能只改文件路径或显示标签。允许稀疏byte-addressed存储模型表达完整合法地址/容量，不要求分配整BO的仿真数组；未分配区写入也必须被边界和写集合检查捕获。

原LQ0 TB只在`target_rows==16`执行Q，并写死mask0xffff、计数16/1024/512及fullA遍历16行。本轮rows4的full必须真实执行Q，断言按物理语义调整为4行/256个512bit beat/128个row-group；fullA四行返回的组读应覆盖32 group、全部4096 INT8与128 FP16 scale，行mask0x000f。保留缓存容量，未覆盖行不冒充完成。原rows1 pilot可以仍只跑LN，不代签Q；不能因删掉16行分支而漏测新Q。

## 必须取得的真实RTL证据

1. 同一runtime仅初始reset：外部residual源→LN真实AR/R→真实AW/W/WSTRB更新目的存储→末B与原完成/END检查→唯一合法发布→Q实际AR/R读取刚写LN字节→原quant/fullA提交、完整键读取及release。Q不能读预装gold，published/admission不能由TB常量替代真实存储/ledger权威。TB可以发诊断命令，所有状态转移仍经原接口。
2. 四行4096 LN F32逐位对AT038独立gold；4096 Q INT8、128 FP16 scale对已核独立fixture。原每行64拍条件下source实际256R、destination实际256W、Q实际256R，三向各16384B。记录实际AR/AW/B次数和burst长度，不以请求beat数冒充返回；若包拆分与预期不同，先解释实际地址/边界/总字节，不能改计数绕过缺失。
3. 实际最后B前不发布、不准入依赖Q；在normal profile中对最后B作一次有限真实延迟，至少观察7拍，不能强置内部状态。保留原Q完成响应反压及source lease保持，只有真实响应消费后释放；记录END/发布、source-query/grant、Q接受/完成消费、fullA acquire/read/release与零债务边沿。
4. 原源只读字节、LN目的字节、WSTRB写集合和邻接/未授权区哨兵终检；目的初始哨兵并只由实际写握手改变。明确实际终扫范围及稀疏未映射写检测范围，不把局部扫描写成全BO逐字节扫描。完成消费仅一次、读写债务为零、lease关闭；若有原错误条件触发立即FAIL，不取消自检。

完整F9矩阵/并发/取消/生产恢复不在本normal阶段扩展；旧LQ0负例只按原身份保留，不继承为新opcode/rows4已测。QAR0默认入口/仲裁结果也独立保留，本轮的LQ0 shell不是QAR0整链接入证明。

## 执行边界与计量

一个封装/fixture适配候选，最多两轮有明确原因的受影响修正；同点重复无新证据即收束，不改数值/独立gold、缓存容量或扩大工具帽。先静态核manifest及编译，再≤120s实际rows1前缀pilot，按新前缀速度/真实完成行数/固定开销给出保守成本估计，在原帽内运行一次rows4 full；full失败后的受影响重验须属于上述修正额度。若pilot只覆盖部分LN，不得线性外推未执行Q而漏掉其成本；LQ0历史735.843s仅辅助依据，不能与AT035旧1782s相加宣称联合可跑。

记录全冷TB、LN run读算写区间、源/目的/Q首末AXI边沿和字节、实际末B、END/发布、Q实际消费/fullA完整读取/最终零债务。阶段分解互斥且求和，接口stall标明可重叠。新四行/新输入和LQ0十六行不算同口径A/B，工具秒数不算硬件性能，不按150MHz宣称部署时延。

A002代码只在E002/experiment，E005/R001新AT证据，旧冻结记录不改；尊重其他人的修改，不新增agent。全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static≤24GiB/1800s，RTL≤8GiB/3600s/40Mcycles、pilot≤120s、真实语义停滞120s。按实际语义进展记日志，诊断快照不续命。

交付原manifest/源码diff/fixture身份/日志/guard/policy、精确比较/存储保护/生命周期与周期报告，并更新三摘要。若通过，再由主控选择LN接入QAR0的同runtime全链，不自动启动另一长链。无新HLS/OOC/P&R/上板/预算；G2338.224019s仅OOC余额，5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排；完整M003/M004未关闭。
