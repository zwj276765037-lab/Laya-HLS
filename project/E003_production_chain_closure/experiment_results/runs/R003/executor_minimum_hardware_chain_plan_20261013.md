# 最小真实硬件链：关键路径与估时答复

回复 executor-minimum-hardware-chain-priority-20261013；M003/SM003/E003/R003，A002。

**近期改为先交付同runtime首请求计算及周期基线。完整跨request恢复不再无条件排在前面；真实准入、归属、授权、数据债务和消费门仍必需。** managed LPV审核已收到，按冻结范围接纳，不增添框架前置。以下是只读盘点和工程估计，没有启动新HLS/OOC/RTL。

## 1. 可用模块与真实缺口

| 模块 | 实际已有证据 | 首链仍须完成 |
| --- | --- | --- |
| program | graph_program_hls_01生成top SHA 0373c9a…；rtl_01实际四depth2 FIFO和结果consumer。仅NORM_LAYER1_ATTN单action。 | 与executor实际4/4、8/4连接；真实旧command归属/部分帧与通知。当前源码新增pending路径，extern C仍把issued_command_key传nullptr，没有硬件LAP1出口。变更该接口或增加Q发起须重新冻结并生成，旧RTL不能冒充当前源码。 |
| adapter/F10 | controller_transaction_adapter_hls_03确有生成RTL SHA 42f9056…；原FAIL保留，独立端口纠正审核PASS；rtl_03八独立协议case及实际24/16消费门。 | 将F10通知接executor的真实LTC1 consumer，producer/LPV/compute三对FIFO接真实服务；用真实adapter状态提供pending/fence/preowned，替换受控输入。 |
| LN | layernorm_producer_hls_01实际生成SHA b0971fb…；guarded_source_05一行1024F32与F9；quant_source_04旧冻结rows16→Q/fullA独立gold。 | 接真实adapter、source guard及monitor/唯一hub；从真实completion构造END并完成唯一软件退休。当前LN请求绑定codec已有漂移，复用须以旧RTL+已验证F9 wrapper的明确闭包评估，不能签当前全部HLS源码。 |
| LPV/hub/monitor/控制 | managed_lpv_rtl_04及shell/query/source guard有有限RTL证据。 | 唯一wrapper实际安装真实准入A，连接HOLD/导入helper/完整控制consumer及源/目标移交。现MANAGED_LPV_OWNER=0、hook tie0，尚非生产接线。 |
| executor | 实际actor/port/FSM/helper主机路径和F17/F19回归；当前23源，NORM支持B×S的rows16窗口。 | **无独立extern C HLS top、无生成RTL。** 必须做有界入口与source闭包，真实解析LYRQ/LYMP、锁A及配置、同runtime导入/GRANT后发LGP；完成8/4与24/16实际consumer。不能把同步host reference当硬件。 |
| Q | 既有真实QUANT/fullA及source lease的独立gold入口可复用；旧TB仍由send_q发命令。 | 实际program或原合同内真实sequencer发起QUANT、匹配lease/AR/读债/释放。当前有限program/FSM只支持NORM，**Q的实际控制发起是含Q基线的必要缺口**，不能以TB send_q代签。 |

本次重核三生成manifest共34/33/30项frozen全匹配，三top SHA匹配；current分别6/5/7项漂移，逐项记录在同目录 `executor_minimum_hardware_chain_inventory_20261013.json`。旧artifact可作为明确冻结模块复用候选，不是当前闭包无条件PASS。

首次计算必要：真实FIRST准入与A/物理绑定；原HOLD→完整LBR2 consumer→实际helper IMPORT→GRANT；持续同拍撤销启动门；source全部已接入修改/AR入口保护；旧半帧/END/返回在撤销下仍能进展；两层真实末拍消费；实际AW/W/B、source读债、lease/fence以及唯一退休；Q实际发起及gold。全13BO和完整graph仍属于后续完整目标，首基线如仅接单STATE0须明确限定，不能声称原完整请求成功。

## 2. 正常首请求与恢复的先后

- **no-LGP/committed ABORT完整错误终结可后补扩展覆盖**：首计算基线遇到这些分支即终止测量、保留完整旧A/K/commit/下界和失败隔离，不自动恢复、不接受第二请求，也不声称已完成该错误请求。真实旧半帧和债务清理仍不能延后或堵死。合同CLOSE/rearm §4规定已准入即欠Host错误结果，IMPORT合同§5规定提交不回滚；这些义务保留，不能删出口或伪造成功。该延期仅是有限测量先后，不是生产语义豁免。
- **CLOSED与完整请求关闭**：计算测量可停在真实action/数据完成、退休及Q返回后的受保护终态，保持锁和旧请求，不rearm。若要签“生产managed请求已安全关闭”或释放A/锁，CLOSE/rearm §2明确成功和失败都必须真实结果/Host消费→真实安全→CLOSED完整核验消费，不能跳过。所以可先取得计算周期基线，不能在缺CLOSED时宣布完整请求生命周期PASS。
- **新准入/rearm可明确后置**：有限首请求只使用真实初始化FIRST一次，之后保持等待、不开放旧IDLE。CLOSE/rearm §5对第二请求的完整旧关闭依据、一次真实新准入、持续高水位保留仍原样执行；原begin/recycle清零问题不以第一请求掩盖。

顺序依据：分区合同§8.5明确第一个出口为真实LN action→executor→F10/adapter→LN→monitor/hub→真实END/退休，然后source lease→Q/fullA；未执行恢复路径显式待验。IMPORT合同§4是首次派发的硬前置；managed LPV合同§1–5是旧工作归属/安全前置，§6请求换A只在真实关闭后。不存在“全部恢复异常先通过才能首次计算”的独立条款。

## 3. 单owner阶段与粗估

| 阶段 | 出口 | 工程工作量粗估 |
| --- | --- | --- |
| A | 冻结首请求基线闭包；有界executor入口、真实A/控制consumer/导入授权；受影响host与独立oracle | 2–4小时 |
| B | 串行executor HLS，端口/资源估计审核及有限RTL动作consumer；按接口需要重生成program | 1–3小时 |
| C | 同runtime program→executor→F10/adapter→完整NORM窗口→实际LN/monitor/hub→END与唯一退休；首个计算周期基线 | 2–4小时 |
| D | 实际Q发起/lease/源AR接线和gold，冻结首条含Q链周期与模块资源估计，转测量驱动优化 | 2–4小时 |

预计下一次executor候选需A/B两个阶段，约3–7工程小时；首条含Q基线约四阶段、7–15工程小时。是任务分解后的粗估，没有同类executor完整生成样本，不能承诺日期或成功上界；协议/综合规模失败会重估，不能原样重试或加帽。可先在C获得可见LN计算测量，不等待D和完整rearm。

依据：已完成program HLS109.026s/3379604KiB、adapter HLS370.877s/5987504KiB、LN HLS99.227s/3117840KiB；RTL静态program48.662s、adapter112.120s，LN→Q旧pilot55.006s。这只支持已知模块工具尺度，**不证明23源executor会在帽内生成**。下一轮规划1次executor、必要时1次program HLS；成功且无返工参考串行工具约600–1800s，逐次仍受static24GiB/1800s、真实120s停滞和pilot8GiB/120s帽。联合full只按新profile pilot实测准入，不重启5172s组合。

G2338.224019s在goal/protocol中是**G累计OOC余额**，不是可挪用的HLS/RTL共享秒池。本次不启动OOC/P&R，上述HLS/RTL各记原类别，G余额保持。可先报可复现周期、FIFO等待/AXI计数及HLS模块资源估计；最终联合LUT/FF/BRAM/DSP和时序仍需原阶段内真实综合/实现，当前不伪造联合资源基线。

具体不确定性：executor闭包含完整runtime/绑定codec，需防静态展开再现旧graph停滞；旧生成模块与新绑定接口的兼容；真实first-ingress/导入配置映射；Q目前缺有限控制实现；当前profile加入四窗口及Q后的实际仿真速率。工程先解这些关键路径，不继续无条件扩大恢复矩阵。

用户本轮已明确允许大任务自主拆分并行子agent，research-agent安装版和来源包已更新；子agent继承同技能、父agent统一所有权/预算与联合验收。本次Laya盘点保持A002实现owner，未创建项目子agent或启动实验；并行规则不增加重工具、OOC或总资源授权。M003/M004仍未完成，已有有限审核范围保持。
