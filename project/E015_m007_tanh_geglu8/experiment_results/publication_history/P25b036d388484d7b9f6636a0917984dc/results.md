# E015：当前结果

原E008独立向量：add191904、mul217304、direct-div191792；初版3/4/12拍/II1、CE hold、真实inflight reset及恢复逐位通过。AT014重分段add、AT019精确radix4 div12、AT020 add3_z均重新原全向量PASS。AT029 add3_o原191904、AT030独立3888定向向量PASS；含maxfinite半ULP邻位、双大数进位、正负溢出、相消/符号零/tiny。旧FAIL原样保留。

| 小leaf综合+opt | LUT/FF/DSP | setup WNS/TNS ns /失败端点 | hold WHS/THS ns /失败端点 |
| --- | --- | --- | --- |
| AT010 mul4 |442/120/2|+0.332/0 /0|−0.018/−0.380 /24|
| AT021 radix4 div12 |2266/828/0|+0.182/0 /0|−0.031/−3.824 /419|
| AT022 add3_z |479/207/0|−0.325/−18.649 /75|−0.043/−1.522 /81|
| AT031 add3_o |462/208/0|−0.161/−2.637 /19|−0.043/−1.498 /80|

同Vivado2025.2/U55C有效3.333ns、uncertainty0.1ns、全IOdelay0.5ns；零latch/blackbox及约束缺失。add仍setup FAIL，全部hold违例保留，无P&R/物理300MHz。AT031最差输入fraction→small1，data2.904ns=logic0.757+route2.147；新add3_e等价指数对阶选择仅源码候选，尚未数值/OOC验证。

AT007原真实Encoder0全部128行WO→残差→LN→Wi→G局部参考，17产品、335872实际z/h、384边界、6非finite。AT018原42节点native SSE参考全336262最终等独立host libm，nodes.hex113320294B/SHAff69474c2d6d74ddb96a4fef13bd78f57132e816d0a2d6a92f8f524bac857a60。

AT027旧512输入与AT032旧16384输入单lanePASS：实际消费153拍/II1，真实256信用、flight152、held303、17实际inflight reset后64新gen/6错误记录保持退休；分别35236/701860总节点检查。版本add3_z/mul4/radix4div12，不能转签add3_o或add3_e。

主控核v2长例缺独立120秒停滞钟，AT034从未启动；AT033旧300秒成本门只作历史。AT036主机parser/timer14项注入记录/时间检查PASS（非DUT运行），v3预冻结0444/SHA c6e61e709cab196edc9386fc3c0e64dcc61fd612bcd33fabd99a53e31453e294。TB只在实际消费通过独立数值/status/tag检查后每4096或阶段末flush；checked/cycle严格增、node_checks不降，重复/无效/部分记录和mtime不续120秒。AT037重新编译8.507010s；AT038同版16384主/16710总消费、688128主/701860总节点PASS，153拍/II1及原协议覆盖不变，child11.893155467s；guard实收7事件、最大gap8.171398s。AT039同版实测成本界278.502067139s≤300s后，AT040完整336262主输入/14123004主节点PASS；含协议探测总336588消费/14136736节点，153拍II1与原信用/held/reset/错误退休不变。child103.284947961s，RSS839704576B，86真实事件最长gap8.377783104s，退出0、owned后代和进程组零残留。当前数值/协议通过不转签add3_o/add3_e或物理时序。

AT008–013 exact loaded guard self-SHA UNKNOWN窄边界保持；候选只bytecode设置差，生命周期/实际费用/清理及独立RTL/TB/输入证据另存，旧收据不改。新AT用预冻结guard并记录启动/取锁自身SHA。8lane/G、联合SFU/FFN、总资源/布线/板测仍未验证。

当前新leaf版本增量：AT042/043 add3_e原191904和独立3888定向逐位PASS；AT044同平台/同完整IO约束527LUT/208FF/0DSP，setup WNS+0.098/TNS0/0失败；hold WHS−0.043/THS−1.466/78失败保留，无P&R。此版本不覆盖旧add3_z/add3_o时序FAIL。

AT045新生成原152edge DAG，显式选择add3_e SHA703bf5eb2ccbcf0444d521cfa6d4d5da6b7ac21fc6c4c4d530c37d498ee3d627；lane SHAeec73a7badf5e065ab7b04d1dc454ce536f6b5a756ea923c241dd516818b28ef。AT046新编译/AT04716384中样、AT048实测成本界281.252076277s≤300s后，AT049全336262主输入/14123004主节点PASS；336588总消费/14136736总节点、153拍II1和原协议全部通过，child106.910094177s/RSS839524352B、86真实事件最大gap8.075176257s、owned零残留。manifest8c9cdd16e4f4e71f10465de12322212bc4d68cb52f462d3578af6f50a89026db，driver16f0882fa7d9759aad093e6f147d474b46d91c3a762560c8f59722bbf2182f38。AT048自由scope旧leaf名的文字边界见cost_scope_metadata_note.md，实际选源/算法/成本绑定按manifest，旧原件未改。

八lane新RTL/TB/runner已准备：恰8原core+1共享vector credit，无EXP或存储副本；mode1/phase1、96bit tag+8bit mask、显式request/gen/epoch，逐lane可退休数值错误，release等真实债。tag/mask预约26624bit/3328B及available256bit，其他真实metadata/流水位另计，未签父联合4KiB或总资源fit。AT050首次编译等待公共锁，尚无8lane功能/综合或G结果。


---
Published: 2026-10-21T09:43:30.713920+00:00
Publication: Pbce04c62678b406c94e4595fc96a3948
