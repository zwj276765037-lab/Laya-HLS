# D2-I：生产Controller可达生成路径设计

设计：GPT-6 Astra xhigh；唯一实现：GPT-6 Sol max。当前为已细化的局部实施合同，实际源/TB和结果待执行。权威依据为[修复合同§7.6](../../repair_contract.md)，同时遵守[§7已审原文](../../contract_snapshots/d2_reviewed_contract.md)的分层证明边界。

建立独立I-L与I-V top，直接include当前官方controller而不复制方法；I-L从真实NORM张量与真实权重BO经实际owner生产到完整QKV linear，I-V从真实合法双source到residual/type向量。CPU/CSim先完成真实数值/owner成功与非法拒绝，然后局部csynth/分阶段IR验证。不得用D1 probe stub、手填READY或只编译不可达方法取代此项。

当前官方controller SHA256：`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，build tag `fe067c8aa0627ad770096f9721394645`。两top均不调用完整graph；I-L不做64行QKV长RTL cosim。具体输入节点、producer spec、合法/缺presence用例、工具/IR文件和guard见主合同§7.6。

## 独立设计审核

[独立审核](../../reviewer_d2_i_contract_review.json)已接受本项有界CPU/标准libm CSim/局部csynth/IR实施，决定为`ACCEPT_D2_I_CONTRACT_FOR_BOUNDED_CPU_CSIM_CSYNTH_IR_IMPLEMENTATION`。审核对应[合同精确快照](../../contract_snapshots/d2_i_reviewed_contract.md)SHA256 `935464f9b644180d6369c3528de411d838da1a83319db36ded56704c8da14e5d`，其中§7.6 SHA256 `05a447d412f605228b3a6d3e3d9cee6af973afd81dcee2ab41456333d60d2ab7`。当前源/TB与实际运行仍待实施；不放行I-L的64行QKV RTL或完整top HLS。

## 连续请求producer epoch补充

[草案v1预审](../../reviewer_d2_i_draft_v1_pre_review.json)发现诊断producer不能在每次请求硬编码epoch1：实际生产recycle保留owner的max_claimed_epoch。解析成功后由真实`controller.fresh(id,bank,region)`选择合法ref，首请求自然epoch1，后续递增；不清生产ledger或重置metadata。复合坏scale/缺pair和坏header/缺pair须保留原错误优先级。修正只在诊断wrapper/TB，正式controller及包身份不变。
