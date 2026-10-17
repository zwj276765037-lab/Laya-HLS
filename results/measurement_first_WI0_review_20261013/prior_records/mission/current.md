# 当前工作：WI0真实Wi resident完整输出

[GQD0限定接链已验收](../results/measurement_first_GQD0_review_20261013.md)：四行外部Wi F32→真实G→GATE写入/重读→量化→唯一dualA→KB1 Down，完整原gold、最后B/lease/局部发布及一次done消费通过。全TB102660cycles，合法G接受→Down消费102634；W加载27064，Down cfg→消费16190。GATE精确首AW/末B及最早A发布未采全，仅保留界限；当前样本不含Wi计算。

当前执行[D-M004-WI-RESIDENT-01](wi_resident_producer_stage_20261013.md)，A002唯一实现/整合/重工具owner。四distinct行enc0 Wi、K1024/N5248，复用既有resident/原容量A/W缓存/KB1 writer，验证完整671744 PS lane-group与20992实际F32输出、最后B/发布/lease/真实消费。原模型Wi bias_kind0已核，预量化LN_FFN A是明确外部输入；不增第二矩阵引擎。WI0新结果NOT_RUN，Wi→G同runtime仍未验；普通实现与有据受影响修复连续推进。

Wi独立gold与GQD0外部Wi输入的20992个词已逐一相同，旧Wi乘加full没有当前resident writer出口，故先补此必要实际producer边界。完成后再选择单引擎复用与真实存储读入G的连接，不把独立PASS或局部周期拼成完整链。

KB1/ATN1/GQD0限定保留；KB2/CT0本轮收束，LQ0/LQ1限定事实保持，LQ1不生产采用、LQ1R关闭。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排。代码唯一E002/experiment，证据E005/R001，不新增agent、不写旧baseline。原单重工具/分类帽、G2338.224019s仅OOC余额、5172s不重启，无新HLS/OOC/P&R/上板/预算。完整28+2层/122矩阵、13BO/请求/恢复/联合资源与M003/M004仍未完成。
