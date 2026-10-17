# WI0：复用resident矩阵引擎，取得真实Wi完整输出

D-M004-WI-RESIDENT-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合及工具owner；A001集中评判。承接GQD0限定接链验收，按已有连续实现授权执行，普通实现与受影响验证不等待新审批。

## 本轮选择与理由

下一阶段只做**四distinct行enc0 Wi的真实resident输出基线WI0**：声明的原LN_FFN预量化A输入→完整dualA存储/lease→真实严格W加载/缓存→同一resident TM4/PS→原bias语义→KB1 writer实际AXI写入→最后B、局部发布与一次真实done消费。K1024/N5248、G32/T656、四行完整20992 stripes、671744 lane-group PS、2624 TN8结果packet、20992最终F32均保留。

已有`t2_tm4_real_wi_lut_full_01`验证完整Wi乘加/中间值，但没有生产writer出口；七shape缓存和writer各自通过也没有证明该组合。当前AT025 resident及KB1 writer静态支持Wi形状和op0x32，因此选择真实组合验证，而不先重跑旧乘加单元。该任务为后续Wi→GQD0连续连接补齐具体上游，**本阶段不签Wi→G同runtime通过**，也不扩成全模型控制重构。

## 冻结输入、资源复用和数值

- resident/同步PS/native FP、完整dualA、严格双W及KB1 writer从AT025/AT002冻结闭包派生，显式记录共用源的身份；不得沿用漂移live源冒充旧版本。只实例化一套既有矩阵引擎和原容量缓存，不为Wi增加第二套矩阵算力，不用更小表/shape降低成本。G本阶段无需实例化。
- 输入使用本项目`t2_widown_av_fixtures_01/work/fixtures`的原四行Wi q/scale与真实W/metadata。Wi A是明确声明的外部预量化LN_FFN边界；允许通过完整fill/commit/finish接口填入，不层级poke、不强置READY、不把PS或输出期望作为DUT数据。LN实际producer及其量化不在本阶段。
- 原manifest确认`mlp_wi.0.weight`的K1024/N5248、`bias_kind=0`、bias_span0；按真实模型保留kind0旁路，不虚构非零bias测试，也不把它推广为其它层bias组合已验。保持原F32运算顺序、舍入/非有限处理和group0→31累加次序。
- 原Wi独立输出binary为83968B，SHA `b5542b2f20473041f9f420cc740ebef48343c714b98b6748c0f5ba1c5cff4d25`；与AT025外部Wi mem解码后的20992个词逐一相同。原A q/scale、W及完整中间gold逐SHA冻结；只做本项目路径映射，不回写历史baseline、不重新用DUT产生gold。
- 原fixture数据来自request3/B1/S128/enc0的batch0、row0=0四行；GQD0诊断配置曾使用batch1、row0=7。两者数值相同不等于运行身份相同。WI0明确冻结实际numeric identity、linear context、slot/epoch、source/A/W/PS/dst ref、row/batch和地址步长；可保留原诊断重定位，但逐字段说明，不隐式把坐标改写当生产衔接已验。

## 必须观察的实际出口

用原完整A/W真实读口和完整身份驱动resident；A32组每组返回四行、W20992次完整tile/group供数，实际计数以冻结调度核对。W三路q0/q1/scale真实传输分别2686976/2686976/335872B，严格校验不省略。保留原容量、lease、validate-before-commit与native流水；高tile511/512/655和末组31必须实际通过。

完整原PS独立gold逐项比较，2624 TN8 packet与20992个最终F32在实际writer路径比较。KB1四row合并写按该形状应形成1312个512bit输出beat、83968有效/物理字节；这是待验覆盖目标，不能提前填写为实测。最终内存只能由真实AW/W/WSTRB更新，检查每个有效输出地址恰当覆盖、范围外哨兵保持、最后B之前不得发布。writer op0x32、dst类6、row stride20992B及原batch stride语义保持，不沿用Down的4096B地址观察器。

原受控响应策略继续：同三口R供数规则、AW/W周期门、每笔B延迟17+(物理beat序号%3)、done故意保持7拍并真实消费一次。新shape自然改变交易数与阶段相位，不通过减TB延迟制造收益。严格检查A/W释放、PS/输出债务和局部publication；完成后不能残留有效输出或再次消费done。保留受影响的外层非法准入零issue、输入/返回保持和末B屏障检查。继承未测晚错/撤销/reset恢复仍未验，本轮不扩整套恢复任务。

不预先改通用DUT；若新形状暴露真实宽度、地址或接口缺陷，保留失败，仅作有证据的受影响等价修复。改动共享算术/writer/cache后，重验必要已通过范围；原身份未变的叶子结果直接复用，不重跑整个历史测试集。不得放宽gold或容量来获得PASS。

## 计量、成本和停止

单实现static→≤120s真实pilot→有依据的四行full，至多两轮有具体原因的受影响修复。pilot需报告实际完成的W加载/校验、A供数、stripe/PS、writer阶段；未到输出则明确NOT_RUN，不以预填W或短K替代。原源供数Wi full668.561s、KB1 Down full431.228s只是成本参考，不能按二倍工作量保证新组合耗时。以新pilot和冻结闭包建立保守准入估计；若不能支持3600s内完整运行则有据COST_STOP，不加帽、不原样循环、不扫候选。

至少记录：初始reset释放、A合法fill接受/实际发布、W LOAD接受/实际READY、Wi cfg接受、首末issue/PS、首末AW/W/B、首次done有效/实际消费、全部债务归零的事件；互斥阶段和重叠stall分开。将合法与拒绝命令分开标记，在真实握手/完成上采样；发布后的晚观察只能称“ready by”。进展标记须对应真实接受/返回/校验推进，并让原guard识别，不能用时间心跳绕过停滞保护。

本轮只产出Wi0真实数值、物理接口覆盖及新冷基线，没有第二优化候选。通过后集中交付，再确定单矩阵引擎分时复用、原双槽A/W所有权及真实Wi存储重读→G的最小连接方案；不把两份旧PASS或周期相加当成连续链。不要求完整executor/CLOSED先通过。

## 执行和验收边界

唯一代码根E002/experiment，证据E005/R001；已有helper可沿原职责复用，不新增agent。全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static24GiB/1800s，RTL8GiB/3600s/40Mcycles，pilot≤120s、真实语义停滞120s不变。主控只审证据，不运行DUT工具。

无新HLS/OOC/P&R/上板或预算；G2338.224019s只原OOC余额、5172s组合不重启。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排。KB1、ATN1及GQD0限定事实保留，LQ1不生产采用、LQ1R/KB2关闭。完整28+2层/122矩阵、13BO、真实请求/恢复/联合资源及时序和M003/M004仍未完成。

依据：[GQD0集中审核](../results/measurement_first_GQD0_review_20261013.md)、[Wi身份与原始核验](../results/measurement_first_GQD0_review_20261013/verification.json)、[原Wi fixture manifest](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json)、[历史算术/接口阶段表](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md)。
