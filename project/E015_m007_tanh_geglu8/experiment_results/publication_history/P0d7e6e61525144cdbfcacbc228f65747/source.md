# E015当前：G-COMPACT-14来源与方法

授权SM011末尾G-COMPACT-14，同E015/R001原余额接续，无OOC。A008唯一写G math/pool/engine/pairs及对应TB，其他生产模块只读；期望gpt-6.1-sol/xhigh，实际未核实。TANH原42节点23add/17mul/2direct-div、逐F32舍入、原数值/状态/分支均不改，冻结AT055复用，不重跑未变数值suite。

仅math/pool的394条重复96位tag改为完整seq16。公开96位tag={generation32,epoch32,zero16,seq16}保持，seq=s*512+row*4+chunk范围0..41983；高64身份、保留16位、全部16位序号在边界校验，低8只索引ring。固定上下文由清除后的首笔实际接受建立，不能因pending暂空而重绑；pool同拍实际接受通道须一致，每通道真实请求顺序另计。数学打包/校验函数显式接收context/valid，跨clear且seq不变亦正确。

新增context/valid/order291bit全计；所有资格/错误mask、live/available/sent/received、covered/evaluated、两槽真实FP/SFU/pending、原ACK覆盖和first_error保持，未读tail不扣、不改成数值payload。pre-credit仅本G实例TAG_WIDTH16，sharedcredit源不改；外物理SFU96位队列/lease、原数值pipeline另账不重复混算。当前engine/pairs及7份共享/数值源码SHA均保持precompact版本。

原AT058冻结335872×12字段和AT070每案2个原primitive/libm改动scalar独立参考不变，无DUT gold/无新整模参考。真实engine一次完整命令自主s/row/chunk8，验证一原storage、一冻结TANH8、一56mul16add池。返回反例只在TB公开边界加额外坏记录，真实原返回保持再到达；按实际请求/返回核债，不force state或假排债。

原heavy锁/CPU0–3/nice19/idle I/O/MemAvailable>192GiB/RSS16/24/8/24GiB、120s真实消费停滞不改。原900/1800/3000/1800秒累计帽，未知≤120、普通完整≤240且留≥120短例/归档；冻结v4/v5同版实际pilot/fixture/build/driver/argv精确门。

本段原始数值仿真全部结束后，protocol.md追加Compact14执行后文档补记；各AT原protocol SHA/归档不变，实际SM合同及源码/TB/driver快照为当时范围依据。最终版本仅签G-only目标和受影响功能/周期，旧历史不跨版升级。


---
Published: 2026-10-22T11:03:45.432534+00:00
Publication: P97fbc5edd1134bb2ae0a2662fff6877a
