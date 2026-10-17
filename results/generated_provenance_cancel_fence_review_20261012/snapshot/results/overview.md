# Laya-HLS 当前概览

**当前总目标：完整Laya加速器搭建与性能优化。任务合同已修订，完整加速器仍未验收。**

最新审核：[generated provenance修复与首个AXI monitor](reviews/SM003.md)核验580项SHA引用、191组current/frozen身份，保留四项限定PASS；F1错误END提前退休及F3身份槽回收在当前范围关闭。F2尚有未排空拒绝仍报DRAINED和等待期间中间首错遗漏，新增F4活动producer取消会阻断旧写/END收尾；已直接交工程修复补测，C012待验证。首个role6/rows16 monitor已验1024个peer AW/W/B与65536B覆盖，取消仅验无活动scope空档；真实generated master、adapter因果、普通Q lease及完整请求仍待证。

此前阶段审核：[generated provenance基础阶段](reviews/SM003.md)核验六项冻结局部PASS，632项SHA引用与284组current/frozen身份一致；基础实现暂不验收。冻结源码发现三个未覆盖缺口：活动scope的错误END仍被Controller退休、未排空观测仍返回DRAINED、32个typed身份槽跨请求不回收。已直接通知工程修复及补测，C012待验证；本轮未动态复现这些缺口，也未改写原运行结论。真实generated AXI/WSTRB、posted-store fence、普通Q source lease及完整production top仍未闭合。

此前[当前GATE split回归审核](reviews/SM003.md)接纳gate_split_06的四窗口G→独立Q0→fullA，758736cycles/1038.453534s；95项SHA匹配，原预算内完成。当前共享状态机回归子项已闭合；普通/GATE切换、真实provenance/hub及完整请求仍待验证。下一次full前成本入口应使用当前pilot速率，保留06原历史依据；组合full仍NOT_RUN_COST。

最新物理接口决定：[generated producer写前身份绑定](generated_provenance_channel_contract_20261012.md)采用新增一对provenance私有FIFO，BEGIN获准后写、END等真实覆盖和排空、PUBLISH核整tensor。内部FIFO从两条明确修订为四条；原13BO、compute v2四service及typed计数保持。codec、CPU参考/Controller、受控RTL hub及12信号probe已有限定证据；完整production top生成与真实物理验证尚待交付，C009部分实施，禁止地址覆盖事后贴P。

2026-10-12最新：[普通Q/L源身份](ordinary_linear_provenance_contract_20261012.md)已定义为每窗口真实覆盖闭合任务的Context，同时要求完整贡献覆盖和独立tensor发布。Attention不能用最后一条AV代表全tensor；原地更新分别保存旧/新epoch凭据。工程继续受影响实现和物理source验证，不新增虚拟任务或wire字段；普通源物理生产链及总验收仍未完成。

最新接口决定：[原13BO的416B模型身份](model_identity_13bo_contract_20261011.md)采用L13M v1固定内容编码，五模型BO由外层保持全service生命周期物理绑定；更换须排空并冷初始化。保持STRICT、原13BO与wire v2，不借Q8S2注册字段填假身份。caller/hub受阻的定义已明确，实现与验证仍待工程交付；不改变下述阶段结论或组合full的NOT_RUN_COST。

用户要求尽量高性能，暂不设置固定延迟、吞吐或提升百分比门槛。必须完成真实全模型集成，并提供完整请求的可比性能、瓶颈优化和资源证据。生产链接入是前置阶段，不能作为总任务完成点。

[M004](../mission/M004_完整Laya加速器搭建与性能优化.md)统筹：M003/SM003真实链前置→SM004/E004全模型与完整请求验证→SM005/E005性能/资源闭合→最终回归和整体交付。[goal v3](../goal/goal.md)，[本次范围修订](mission_scope_revision_20261011.md)。唯一代码根仍为E002/experiment。

| 范围 | 已有证据 |
| --- | --- |
| 复制/旧完整CPU与实际CSim | 原身份范围PASS；当前7项编译依赖变化不能代签 |
| resident/G/Attention | 各局部范围PASS；不组成完整同runtime请求 |
| 当前G父/Attention OOC | COST_STOP；无final资源/DCP，G余2338.224019s不重置 |
| 全模型当前硬件、完整请求性能与联合资源 | 未验证，属于M004要完成的工作 |
| P&R/Fmax、U55C/XRT/PCIe/HBM实板 | 未验证；无板不宣称部署完成 |

[工程验收](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)的18份交付已核验；本次目标修改不改变其结论。历史FAIL与Attention两处文档SHA限制保留。

最新：工程E003/R003已执行，L0/L1 PARTIAL。主控已回答其quant/G架构缺口，确定[门户v2补充合同](quant_g_portal_contract_v2_20261011.md)：显式三Context/future-dst、128窗口有界预约、G与quant分期、rows16父任务跨view租约与首错归并。接口定义不等于实现PASS，L2/L3、当前完整CPU/实际CSim及M004总验收仍待完成。

此前“新阶段planned/NOT_RUN”仅适用于范围修订时点。主控此次未启动工程工具。模型请求/actual区分、原数值标准、单重工具与资源帽不变。合作顺序保持工程交付→主控核验→更新任务；普通修复不逐轮审批。

工程后续generation问题已由[门户生命周期补充](portal_generation_lifecycle_20261011.md)明确：每command单调代号与跨command实体分离，高水位跨请求保持；取消/失败响应须依可信首拍耗号，并覆盖view间隙的活动parent pin。已只读核验transport_v2_01冻结源身份；其受控端点局部PASS不覆盖新增边界，工程须完成受影响实现/验证。

最新[SM003阶段审核](reviews/SM003.md)接纳真实fullA/fullW缓存→父matrix四view同runtime局部PASS，94/94身份引用匹配。167936项PS gold、16384最终F32 gold及独立AW/W/B各2048通过；中间view保留pin，末B后释放，父完成一次而256行tensor只覆盖16行、不提前READY。A仍为原四行预量化fixture重复；此前G→Q0→fullA局部链尚未直接接入本父matrix。L0/L1 PARTIAL、L2–L5 NOT_RUN。

后续组合G/Q→父matrix的TB静态编译及一行G pilot通过，A源码已接真实producer；Q/W/matrix完整执行仍NOT_RUN_COST。当前pilot63.410458s/11773cycles投影full5172s>3600s，_03已在启动前COST_STOP；166/166身份引用匹配。_01保留591.128178s主动终止的FAIL/sigterm，不判数值失败。投影不是完整时长实测，更不是硬件性能。

split旧格式/缺字段guard修复已在有界范围关闭；此前长pilot DEVIATION和各冻结功能边界保留。工程继续独立多父/失败、其余Q/L与LOAD、source producer、generated caller/唯一hub，并在原预算内改进组合仿真成本后补同runtime验收，再取得L2/L3与当前完整CPU/实际CSim。M004完整加速器、完整请求性能和联合资源仍未验收，无待用户批准项。
