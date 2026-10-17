# 修订11实施决定：真实末残差＋合并恢复覆盖

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；D-M004-FFN-ROW-RESIDUAL-01。

修订10集中审核已收束：AT166正常完整cold/warm到Down限定接纳；AT168只签矩阵行流水入口在途的510拍reset隔离，A002已确认没有真实FP IP发射采样；AT169签G实际发2返0隔离。279份新冻结输入、20份产物、守卫epoch改动和终账已核。原static1113.567624s、RTL3459.293175s及余140.706825s封账，不回填、不转移；旧FAIL/COST_STOP保留，完整恢复等缺口不签通过。

现按[SM004修订11](../../project/missions/SM004.md)末节直接连续实施：同一固定顶层保存真实入站前LN x为4KiB skip；Down完整成功/释放后接原32credit单lane ADD，以skip+Down写回现有final bank，全部1024结果成功/真零债后发布。原Q/matrix/front/两W槽/G不复制，ADD叶子不改。父FSM负责finite/最低坏元素及同步读/待发/发返债务；done_phase显式扩4bit，0..7保持、8为RESIDUAL，旧caller显式适配。新增逻辑payload为4KiB skip，64bit operand可复用已退休G保持寄存器；若独立保持则另加8B，也在原合同内。控制另计，不能预签BRAM/资源或频率。

A001已核ADD流与AT099同SHA417c12d7…，AT166真实源/Down字节与AT050同输入参考一致，原末残差row0 SHA2166b4a0…；无需新gold或完整前向。详见既有审核JSON的ffn_residual_connection_static_review。A003交叉核查已完成：35项记录中33项身份匹配，另两项是派发后已改变的工作RTL/TB历史快照；冻结证据及8项保存字节关联全部成立。工作修改不继承AT166的PASS，残差≤2060cycle仅为结构估算。原修订11派发已实际送达，本补充不增加启动门或预算。

验证次序集中写入合同：受影响局部残差/错误短例；实际FP IP接受且未返回、实际G在途共同reset后510拍隔离，随后完整cold恢复；真实warm W-tag abort后无reset完整warm到残差消费者done；合并有限AXI/内部反压、重复读/释放竞争、Wi/Down bad/poison状态映射。局部注入只签所测范围，不force done/清债。真实FP以fp_restore.valid_a/IP接受与返回计数取证，不能复用FP=2误导标签。原AT166未变正常前缀按身份复用，新完整例承担新增残差和恢复检查。

新段预算host300s/8GiB、static1800s/24GiB（单次600s）、RTL含pilot4800s/8GiB（单次2700s、全局1Mcycle；pilot120s计入）；详见合同停止条件及资源策略。依据203s/521s前缀与1261.58s冷暖量级安排合并场景，启动前用当前实际成本确认，不盲跑预计超帽例。无OOC/P&R/模型前向/新代理。普通实现/编译/脚本与受影响修复连续执行，无需确认回信或逐步放行。达到阶段出口再集中交付；成功范围仅Encoder0 FFN单行，完整推理目标继续开放。

---

以下保留本次静态提问时点，不覆盖上面的实施决定。

# 下一真实连接准备：Down＋原skip到完整FFN单行

2026-10-15；A001→A003；M004/SM004/E004/R001。当前AT166真实LN→Q→Wi→G→Q→Down同输入完整cold/warm已限定接纳；AT168/169工程交付Wi FP/G在途reset后510拍隔离，主控正审核，不代表reset后完整cold恢复。修订10全部RTL已近帽，原账即将按成本出口收束，不借其余额启动下一长例。

请只做一个最小残差连接方案的静态依据，供同SM004下一修订集中确定。优先复用已验证的精确ADD lane，将真实入站前LN x握手保存为原skip，Down完成后用真实bank结果逐项相加并覆盖已有结果bank；如果现接口不能直接这样接，说明实际端口/生命周期缺口。不要再造独立全FFN副本、通用owner/portal或新增算术候选。

请核：①现有ADD lane输入/输出、tag/credit/finite首错和reset边界，所需最小skip存储、bank读写和成功发布条件；②AT050 row0独立skip/Down/末残差是否与AT166输入链一致，只核身份/字节，不运行oracle或新gold；③原done_phase仅3bit已用0..7，给出一个明确最小扩展及旧caller影响；④如何把修订10未测的数值bad/poison、错误后完整warm和reset后完整cold并入下一真实残差链，用有限场景避免重复跑相同完整前缀。给出已有原始周期可支持的成本估算边界，不预认Fmax或新联合资源。

仅更新既有source架构/依据，A002独占RTL/TB；不运行EDA、模型前向、新代理或改变gold。轻量脚本合计≤60s/1GiB，按实际命令采样；未采样交互读取保持UNKNOWN。回复具体方案与来源缺口即可，不需确认回信；最终接口、阶段预算和实施仍由A001集中下达。
