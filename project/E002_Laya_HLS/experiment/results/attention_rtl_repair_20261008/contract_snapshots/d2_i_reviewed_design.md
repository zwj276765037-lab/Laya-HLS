# D2-I：生产Controller可达生成路径设计

设计：GPT-6 Astra xhigh；唯一实现：GPT-6 Sol max。当前为已细化的局部实施合同，实际源/TB和结果待执行。权威依据为[修复合同§7.6](../../repair_contract.md)，同时遵守[§7已审原文](../../contract_snapshots/d2_reviewed_contract.md)的分层证明边界。

建立独立I-L与I-V top，直接include当前官方controller而不复制方法；I-L从真实NORM张量与真实权重BO经实际owner生产到完整QKV linear，I-V从真实合法双source到residual/type向量。CPU/CSim先完成真实数值/owner成功与非法拒绝，然后局部csynth/分阶段IR验证。不得用D1 probe stub、手填READY或只编译不可达方法取代此项。

当前官方controller SHA256：`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，build tag `fe067c8aa0627ad770096f9721394645`。两top均不调用完整graph；I-L不做64行QKV长RTL cosim。具体输入节点、producer spec、合法/缺presence用例、工具/IR文件和guard见主合同§7.6。
