# Executor bootstrap source接口答复

回复：`executor-bootstrap-source-question-20261012`  
决定：**D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01**。允许增加唯一hub的只读、完整绑定snapshot内部握手；[补充合同](executor_bootstrap_source_contract_20261012.md)为本次权威文本。

现QUANT source_query含QUANT Context/generation及lease副作用，不能直接当通用只读接口。新增固定版本/有限request-response，一次一个，响应保持至实际消费；最多1024B/方向，工程冻结共享C/SV布局与byte oracle。核完整NumericIdentity/L13M/Ref epoch/owner geometry、role和真实BO/base生命周期；响应来自hub现有published、完整owner。snapshot不创建或发布、不分配typed编号、不取代真实来源保护。NORM入口只接受encoder_00_out对应的完整B×S来源，不能把RAW或16行诊断owner重标成完整来源。

两处接线重点：
1. 不直接使用当前domain_drained作成功门，它包含active_owners==0，与查询已发布owner矛盾。使用真实scope/pending response/债务/fence及冲突lease安全条件，允许当前匹配source存在。
2. snapshot与producer实际读之间存在状态变化间隙。首个单action可用唯一shell排他门控封住source覆盖/release/epoch/base切换，启动前再核source/cancel，并保持到实际读债/完成/fence安全和action消费边界；若无法封住所有旁路，改用同一hub显式通用原子source lease。只读snapshot本身不得暗取lease，也不得被当永久READY。

新request只有旧状态安全后才begin→真实LYRQ/AUX LYMP校验→admit。同一已接受request中的检查点续行不再begin/admit，前序producer的任务/Ref及协议高水位须真实延续。TB受控前序初始化必须经正常hub生产/发布路径并记录相应编号状态；不层级写owner数组或重置计数。接受受控encoder_00_out fixture的有限诊断，但不签完整encoder前段或Host请求。

按合同补正确/错绑定、未发布/缺窗口、旧债务/返回、响应背压、snapshot后source变化/cancel、源读前防护和高水位回归。8/4 action收发及consumer工作继续，受影响host身份通过后串行生成executor并接实际LN/hub。无需新增审批；C009实施、C008/C010待验及M003/M004未完成保持，原预算不变。

