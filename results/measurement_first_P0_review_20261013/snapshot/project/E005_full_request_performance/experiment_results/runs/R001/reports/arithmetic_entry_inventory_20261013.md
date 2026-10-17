# P0：算术入口有界盘点与KB0选择

D-M004-MEASUREMENT-FIRST-01；2026-10-13，A002整合。选择原冻结resident Down为KB0。P0只核所选闭包和现有备用证据，不重新清理全仓历史。新DUT测量仍NOT_RUN。

| 入口/身份 | 真实输入和独立gold | 继承周期/原成本 | 缺少观测与可执行入口 | 当前选择 |
| --- | --- | --- | --- | --- |
| resident_regression_02，26 frozen源、3 nativeFP IP；input_manifest SHA `2a8d23b82ce961f0b878b47b88823a3578d4afe43eefec468410b3db7ab6697d` | 四distinct预量化A；K2624/N1024；10496stripes、41984 row PS/335872 lane-group、4096最终F32；12fixture逐SHA相符 | 全TB48862cycles；static56.587s/pilot87.112s/full424.467s，峰值约2.3GiB/1.4GiB/1.4GiB；512 AW/W/B，heldB9217 | 原run_resident_affected_regression.py；新派生Down测量TB/runner在准备，补加载/状态/接口停顿及真实done消费；旧结果六处live漂移不预签live | **KB0首选**，新AT只读旧冻结DUT、保持gold和反压 |
| layernorm_quant_source_03与LN producer HLS01 | rows16/D1024真实F32输入、16384 LN F32、16384 INT8、512FP16；Q从真实LN store重读 | 冷TB659334cycles，full753.504s；source AR16/R1024、LN AW16/W1024/B16、Q AR16/R1024 | run_layernorm_quant_source_shell_v1.py；缺互斥阶段分解；03/04各303项核验，当前live又有六处联接变化 | Down不可复用才切；详ln_q_inventory |
| Attention tile v10，M16/A16/D4/EXP4，93冻结源及81snapshot匹配 | enc0/head0 B1/S128，128 query、K128/D64，真实Q/K/V与72有效mask；独立中间/最终gold | 正常604317cycles：QK250888/SM287173/AV66256；TB1608896/load140288，full471.004s | attention_tile_run.py；无AXI master/BO末B，物理资源UNKNOWN；SM占47.52%，97enabled-gap共9087次 | 历史瓶颈依据，不为盘点重跑head |
| G/Q8独立桥与sync Down | 已有独立局部数值PASS；完整身份与runner路径由A006定向盘点 | G bridge04原59975cycles；sync Down01原10496launch/41984PS、credit598，其余所列stall0 | 未在本页扩大核验；原模块source/results及对应receipt为证据入口；不把G/Q分段拼成Down KB0 | 仅候选选择资料，不阻塞P1 |

KB0输入A已预量化，bias kind0，初始reset；TB控制加载、owner和AXI响应。真实kernel必须计算全部PS/F32并实际store，不能注入kernel输出。范围不含Wi/G/Q生成A、完整LINEAR、executor或13BO请求。

P1新增AT001。计划同profile static/pilot/full，pilot≤120s；旧full约425s，保守原参考633s，最终full准入用新pilot实际速率及剩余区间估算冻结。全项目单重工具，资源原帽不变，不新跑OOC/P&R/上板。新增观测若导致入口两轮有依据修复仍无有效样本，则切LN→Q。

P2由KB0主要实际等待决定，优先供数/复用、PS反馈、buffer或输出等待中的一项；当前不提前宣称收益。若总周期分解则每周期互斥求和，重叠接口stall另列。资源采用既有相同身份报告或实际存储账；物理/联合未知保持UNKNOWN。

证据：原B/receipt与input_manifest；本目录attention_inventory_20261013.json、ln_q_inventory_20261013.md/.json。旧baseline不写回。
