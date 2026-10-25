# E010：工程协议

## 权威与范围

依据 SM011 D-M007-SM011-QKAV-01 和 M007第6节/performance_requirements.json。代码唯一写入 E002/experiment/vivado/module_design/attention_and_fp_engine；原E008只读。当前是S128单head QK与独立AV，不能代签softmax、RoPE、16head、矩阵供数或父图物理复用。

PS配置2上下文×512银行×16F32，G/prob256×64F32，context64×2048F32。score/AV-PS/prob采用SM011指定bank/address别名；同步读、response保持、实际write commit与generation/phase债参与退休。reset只清有效性/债，不清payload RAM。

## 输入与独立期望

原fixture：E002/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture，enc0/head0/request3/gen1，mask72有效，RoPE后。q/k/v各32768B，score/prob各65536B，maximum512B，out32768B。原full_reference.py SHA256 fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784。原输入/期望只读，运行manifest冻结所有实际文件及工具。后续fixture生成不得导入DUT计算helper或改参考语义。

QK逐次F32 RNE：256产品→六级相邻树→精确×0.125→原bias；全部128key，strict > max保留tie位型。错误候选采用8query tile逻辑检查顺序。AV外层key递增，4query×64lane产品和加法各自RNE，实际PS反馈，最后32F32写context。局部滑窗另生独立局部参考并注明不是整模gold。

## 执行与采集

Vivado工具根 /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin；m011_run.py按fresh AT冻结RTL/TB/runner/guard/helper。每AT保留source_manifest、command、guard_result、driver.log、receipt。PASS要求退出0、无Fatal/ERROR且完整自检marker。错误/超时原始证据不覆盖。

AT001 storage已用公开端口检查PS首尾bank/addr、G首尾bank/addr、context首尾bank/addr；3拍commit/read hold，PS同址read优先，旧generation拒绝，pending阻止rebind，reset清在途response。配置容量不代表逐地址动态全扫。

后续按实际QKV生产写口载入完整数据→自主QK→所有score/max公开读回；独立prepare AV装入V和原prob→自主AV→所有context公开读回。必要中间值采用被动监视实际FP返回；不得注入或强制内部payload/债。记录服务accept、首score/context、末commit、done与hold/消费的周期；初始化费用另列。有限停顿、generation、done hold、abort/reset在途通过合法接口验证。

## 资源与异常

E010/R001总帽reference600/static1800/RTL2400/OOC600秒。未知路径先≤120秒pilot，单次static≤600、RTL≤1200秒且40Mcycle、OOC≤600，120秒语义停滞；全程m007_heavy.lock覆盖guard及子进程。CPU0–3/nice19/idle；MemAvailable>192GiB；RSS reference16/staticOOC24/RTL8GiB。每次按实际guard墙钟计费；失败同样计入。新银行/小适配OOC只在功能后按授权执行；无256阵列长OOC/P&R/GPU/板测。

真实里程碑、预算/接口实质冲突立刻消息A001。普通实现修复按现授权连续进行。功能PASS、周期PASS、物理/时序结果分别记录。


## R001完成与版本交接

AT017复现合法DONE消费/held read response丢失；AT018仅改core RELEASE保留response握手、拒绝新read，以真实storage债阻止lease release。AT018/019 handoff及AT020/021同版normal QK/AV全部通过。共享FP/QKV/storage接口未变。source_manifest/guard/receipt和snapshot依赖保留，各变更用fresh AT，不修改旧原始证据。

最终入口：nice -n 19 ionice -c 3 taskset -c 0-3 python3 <module>/tb/m011_run.py build core AT018_done_read_response_handoff_fix；随后rtl core同AT --mode handoff，AT019 --mode avhandoff --build-at AT018_done_read_response_handoff_fix，AT020/021 --mode qk/av同snapshot复用。所有实际stage first/last/count位于R001/stage_cycles.json及原driver.log；初始化单列。R001已结束，后续R002不回写R001。
