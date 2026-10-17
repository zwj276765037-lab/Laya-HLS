# 真实LayerNorm producer→monitor/hub出口审核

回复：`layernorm-producer-portal-milestone-20261012`  
审核：`R-SM003-LAYERNORM-PRODUCER-PORTAL-20261012`  
范围：M003/SM003/E003/R003，沿用现生成分层及provenance合同。

**接纳layernorm_producer_portal_06的PASS_SCOPED_RTL成功路径。** 本次已超出受控master：实际生成LayerNorm engine的source读、算术、store helper提交、destination AXI、持久monitor/hub和查询lease在同runtime运行；生产caller、真实QUANT消费和完整tensor仍未验收。

主控核112/112 frozen及声明pair一致，交付manifest/receipt/verification三个SHA一致。审核时111/112 current、381/382引用一致：唯一差异为live `config/full_module_registry.json`新增`layernorm_quant_source`闭包，既有冻结DUT/TB、输入和运行产物无差异。这是后续登记变化，不撤销本次冻结PASS，也不把新增闭包纳入验收。[核查记录](layernorm_producer_portal_review_20261012/verification.json)保存依据与记录更新前副本。

## 已支持的结论

static 55.061775s；rows1 pilot 47267cycles/20.786439s；rows16 full 655511cycles/245.157115s。三guard child0/trigger null，policy及内存/CPU/I/O约束通过。full实际source AR/R=16/1024、destination AW/W/B=16/1024/16、有效WSTRB65536B；completion八拍携实际helper store/source各65536B。TB在首completion拍即要求末B全部退休，在完整completion前禁止END返回，并核最终read debt、owner与lease归零。

16384项F32逐位gold来自独立Python float32 adjacent-tree均值/中心方差/sqrt/reciprocal实现；source确为冻结encoder_00_out前16行。复用layernorm_producer_hls_01生成RTL，所选C头与生成时头逐字节一致，canonical包在内存重新生成后相等，七份ROM DAT落位SHA一致。

本次rows16诊断owner的PUBLISH和完整身份query/lease成立；rows1 pilot不执行stage2 QUANT query，不能补签_04 rows1 query。提前END仍为TB预填成功提交量，本次只核其最终与真实completion一致；生产END必须取实际completion。completion/末B因果签当前成功路径，不能据此把故障、取消、部分提交或所有生成adapter都认作已排空。

成本入口确在full启动前使用本次pilot：2273.934517cycles/s，按16行参考756272cycles×1.5得499s。该估计按行外推，不是完整周期上界；保留5Mcycles及3600s/8GiB保护。旧gate_split成本修复仍待落实，不以本runner代签。_01..05原失败保留；_05→_06共同112项闭包只TB改变，_04此前白名单归因撤回恰当。

## F9 / P1：BEGIN与实际producer请求尚无完整身份比较

静态核查发现生产准入缺口，本轮未动态复现，不撤销上述一致fixture成功路径。

冻结`laya_layernorm_producer_portal_shell_v1.sv:169–179`的`producer_front_ok`只核LPE1头与`provenance_origin_seq==begin_event_seq`；shell从BEGIN应答保存的授权只有event_seq。后续请求拍直接交engine，未把NumericIdentity、完整TaskContext、L13M、目标Ref/epoch/region与role/geometry同已接受BEGIN快照比较。生成engine的request_ok/supported核自身合法性和模型/shape，不知道hub已接受的BEGIN Context，无法补此跨协议比较。

具体静态反例：保持origin、模型、shape、地址及payload不变，只把producer请求中的task_id改成另一个合法非零值，或把request_id/generation改成另一组合法值。首拍准入仍成立，engine自身检查也无BEGIN期望值可比较，物理写仍能落在原scope覆盖范围，hub会按原BEGIN的P记录覆盖。仅地址一致和origin相等不足以证明这些写来自同一完整P。

请在现有单活动授权/请求槽内完成BEGIN↔producer请求的交叉绑定，成功比较后才允许engine产生AXI副作用；可复用唯一hub的不可变BEGIN快照，不另建发布权威。至少比较两协议共同的完整NumericIdentity/Context/L13M、origin、目标Ref/epoch/region、role及写范围/shape关系。completion也应与已接受producer请求完整绑定后才作为其完成/fence依据；当前shell的completion头/origin检查不能代签后续错误返回隔离。

补有界负例：相同origin但错task_id、错request_id/generation、错目标epoch（物理地址仍相同），另测旧/错绑定completion；前者须在真实source AR/destination AW/W前拒绝且不覆盖/发布，后者不能借错误完成释放旧scope。保留原绑定、债务及既有安全收束语义，不以清scope/复位掩盖拒绝。合法路径与BEGIN应答反压回归保持。此项归C009的真实producer身份接入，按现合同修复，不新增wire、Host ABI或预算。

## 连续工作

F9补齐前，可继续一致fixture下真实LayerNorm→共享QUANT/fullA的数值集成，但不得宣称生产身份准入已闭合。下一出口同时区分：实际completion构造生产END、真实消费者的query/lease和读债、完整tensor多窗口发布、取消/错误/迟到返回恢复，以及真实sequencer/adapter depth2连接。streaming adapter及独立工作继续，不需新增逐项审批。

C008/C009/C010整体不关闭；C012及F6/F7/F8既有限定关闭保持。三摘要Pc12e05ded50b47cbb482ec55b17aabad和A002同步已核。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成；5172s组合不重启，G余2338.224019s不变，无新增OOC/P&R/上板或agent。主控本轮未运行编译、仿真或综合。
