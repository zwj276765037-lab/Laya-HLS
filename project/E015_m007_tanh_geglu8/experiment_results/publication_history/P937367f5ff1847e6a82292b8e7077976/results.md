# E015：当前结果

三原始fast叶子原独立向量逐位通过：AT003 add3=191904，AT004 mul4=217304，AT005 div12=191792；真实3/4/12拍、连续II1及各CE hold36拍、真实inflight reset丢2项、45paired新返回。AT001 SV语法失败保留。

| 小OOC | LUT/FF/DSP | setup WNS/TNS ns / endpoints | hold WHS/THS ns / endpoints |
| --- | --- | --- | --- |
| AT006 add3初版 |470/201/0|−0.956/−31.674 /54|−0.027/−0.833 /51|
| AT010 mul4 |442/120/2|+0.332/0 /0|−0.018/−0.380 /24|
| AT011 div12 |1701/606/0|−1.464/−143.025 /203|−0.030/−1.599 /216|
| AT012 add3等价重分段 |475/206/0|−0.351/−14.757 /82|−0.043/−1.493 /81|

全部0latch/0blackbox、完整约束覆盖零缺失，仅综合+opt。mul4仅setup正，所有hold违例保留；add/div仍setup FAIL，无物理300MHz。原61ca→ce7c源码差仅add3重分段；主控已逐字核mul4/div12/pkg未变，可限定继承数值；新add数值仍等待AT014。

AT007真实Encoder0全部128行局部WO→残差→LN→Wi→G参考完成1.998655s，17个产品含全部G节点；335872实际z/h、384邻位边界、6非finite记录。主控已核context转置、Wi两半和原调用；参考生成不代签RTL。AT008原DAG重排生成152edge/42节点，尚非联合lane验证。AT009重分段build已完成；AT015联合build等待时取消，无child/receipt或费用。

当前独立新文件准备add3提前exact-zero和div12精确radix4：原接口/周期/数值不变；尚无新数值或时序结论。单lane/8lane/G、联合SFU/FFN、总资源/P&R/板测未验证。


---
Published: 2026-10-21T07:51:39.027482+00:00
Publication: Pb80aa23e66a84452ab30869eddca3b58
