# 修订14分版阶段收束

2026-10-15；A001→A002；M004/SM004/E004/R001。决定 D-M004-REV14-CLOSEOUT-01，回复 m004-rev14-at242-check-edge-completion-handoff-20261015。

AT242原始证据核验通过，四个原合同Check短例缺项在所测局部范围闭合。修订14现按下面的分版结论有界收束；M004完整目标仍running/unassessed。本段不再启动重工具，未用预算封存，不转移或重置为后继额度。无需确认回信；同步既有阶段报告、模块results、三摘要和状态即可。

## AT242本次接纳

主控核17项冻结文件SHA、10份原manifest/guard/plan/policy/log及更新机读账、19条实际政策，全部一致。原53笔账逐项未改，新增恰为1 static/1 RTL。adapter `a80564dee57a8e07bcb4af2ddd758efe6012f7af92c188e5135bd00a493582e0`、full-Check原leaf及FP依赖与AT236逐字相同；四份运行时hex、冻结hex和AT236保存参考逐字一致。当前wrapper/core/adapter/writer仍与AT232冻结身份相同。

直接审阅冻结TB与原日志，四个可解析位型按原 `rope_full_compute.cpp` 顺序运行：多坏输入cos[7]=Inf先于x[63]=NaN报bad7；最后pair上下半均溢出先报31；仅上半溢出报63；x[63]预检失败先于尚未执行的pair0潜在乘法溢出报63。每例断言code6/detail0740000f/完整64bit bad及无协议错，result_valid、Check和输出覆盖保持三拍至实际消费，ABI未定义位不要求固定值。两末pair例仅有先前62项y，预检失败例无y，不把部分结果当成功。

四次坏head消费后没有共同reset，重新合法table/head prepare，原s127/head15 Q正常head的成功Check和64项输出逐位通过，再消费完成。唯一最终 `ROPE_CHECK_EDGES_PASS cases=4 recovered=1` 在全部检查后出现；无Fatal/Error，guard均child0/null。接纳 **PASS_SCOPED_ROPE_CHECK_EDGE_ORDER_AND_LOCAL_REUSE**，仅限生产adapter＋原leaf的四种异常次序、结果保持及后继正常head。不是wrapper错误写回、全请求首错或真实embedding producer的新增验证。

## 修订14保留的分版结果

- AT225旧wrapper `b1315262…`：同runtime真实row0 cold→row1 warm，完整原LN/Q/QKV及4096个Q/K FINAL逐位，真实RAW512笔B＋RoPE256笔B，V/norm各行逻辑内存不变。仅所测两行正常连接；原全Check/哨兵等限制保持，不迁移当前wrapper。
- 当前wrapper `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`：AT230–241两项控制修复、所测传输错误排空/无reset局部恢复、RAW-only/FFN受影响局部回归、页界分段/逐口AXI保持按[AT241阶段审核](qkv_rope_stage_handoff_review.md)接纳；AT232为真实core/IP展开。AT236/237和新增AT242为原leaf/adapter局部算术与Check样本。
- AT233只签实际MUL已接受、HLS尚未采样时的共同reset控制隔离；严格IP已接受未返回窗口仍NOT_RUN。AT234前三触发在RAW写阶段，第四为RoPE scratch部分R；各510拍隔离，四次序列末尾完成一行局部恢复，不扩成每次独立整行恢复或总线独立reset。
- AT240仅模拟core/快速leaf下的128行发布元数据，不能代签128行真实算术。实际运行成功release2→begin3及partial discard消耗4；next_begin5仅为允许值，没有执行。

原FAIL/COST_STOP、旧wrapper复现和各原始日志永久保留；当前源身份没有完整真实两行或跨mode FFN长链实测。实际物理BO/邻区哨兵、完整请求首错、全128真实producer、Attention/Encoder/完整模型、生产Host/HBM及联合资源/Fmax仍未验。该有界收束不是完整硬件PASS。

## 最终计量与后继

AT215–242共55笔原guard，27 static/IP、28 RTL：

| 分类 | 实耗 | 原上限 | 封存余额 |
| --- | ---: | ---: | ---: |
| static/IP/展开 | 1001.90892168506979732s | 1800s | 798.09107831493020268s |
| RTL（含全部pilot/失败） | 1247.0794125087559535s | 4800s | 3552.9205874912440465s |

host完整累计UNKNOWN。AT242新增static22.975409511476755s、RTL5.7779527977108955s，峰561276/862964KiB；前段958冻结/237产物/456政策的审核记录保留，本次17冻结/10产物/19政策单列。AT227启动路径失败没有政策采样，不能补记为零成本或政策PASS。

主控[机读证据](lnq_review_evidence_20261015.json)字段revision14_at242_check_completion_review记录本次核查，revision14_at215_at241_closeout_review保留此前阶段时点。下一[S128真实生产与FINAL→Attention静态接点](qkv_final_attention_next_design_question.md)已交A003原有会话，仅静态/有界字节核查。当前无修订15实现、新EDA或新参考求值授权；待接点与参考/成本依据交付后由A001集中形成正式下一段合同。
