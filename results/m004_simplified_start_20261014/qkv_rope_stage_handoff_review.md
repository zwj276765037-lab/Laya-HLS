# 修订14 AT215–241阶段审核

2026-10-15；A001→A002；M004/SM004/E004/R001。回复 m004-rev14-at241-engineering-stage-handoff-20261015。决定 D-M004-REV14-AT241-REVIEW-01。两项控制修复在所测局部范围闭合；修订14暂不封账，下面仅补原合同尚缺的四个叶子短例，不新增预算或逐步审批。

## 本次接纳与身份

主控已独立核958项冻结文件、237份原始manifest/guard/plan/policy/log、456条实际政策采样，零SHA/政策差异；53笔实际guard完整对应机读账。AT227路径启动失败的policy_checks不存在，保留未采样，不能记作政策PASS。AT225→AT232共同源只有wrapper与真实链TB变化；当前wrapper/core/adapter/writer均与AT232对应文件相同。旧失败、Fatal和timeout不回写。

当前wrapper `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`的地址/路由/诊断已统一为head0 Q,K→head15 Q,K；非法地址在load展示前拒绝，合法真实load握手记活动债，当前load_done才判reader错误。AT230/231同SHA TB以真实AUX第三个R的RRESP错误、16个R/一次load_done退休后discard再begin3，旧wrapper后继合法行返回7/13而失败；新版table load3/3、32个原leaf、384笔B及行FINAL通过。该直接对照闭合旧sticky error误拒恢复的具体问题，原AT231 child0不覆盖其Fatal。

AT230在K/head0和Q/head1各置NaN，先Q0后K0，原Check输出`00000000000000000740000f00000006`、外层6/13/bad1024，Q1未启动；真实读/写债及一次完成检查成立，接纳所测行内首错顺序。正常局部行逐head的成功Check定义字段和64项输出覆盖、cos1/sin0数值成立；错误Check的detail/完整64bit bad在该例主要由原日志保留，不把它扩大为完整异常ABI覆盖。

AT230及AT241的末RoPE B错误、scratch部分R后错误、AUX部分R后错误均接纳各自排空及失败隐藏；连续错误/discard后epoch7的局部正常恢复通过。AT230原RAW-only128位、FFN直接done/回显/flush同拍回归保持局部范围。AT232真实core/IP展开通过；未取得当前wrapper同SHA完整真实两行或完整跨mode FFN长链。

AT236原s127/head15 Q/K的四份input/expected身份及x/cos/sin/expected无损转换已核；AT237非对称表与2/3、5/7的手算精确位型已核。两例使用原HLS叶子与生产adapter，逐64项输出和成功Check通过，只签局部算术/接线。新增13项纯字节/整数核查全部成立，没有重算浮点参考或改gold。

AT241页尾短例接纳scratch64AR/128R、table3AR/32R及合法4KiB切分；RoPE两QKV口各AW先32/W先32，实际AR/AW/W受阻VALID及全部接口字段稳定，route/base/span到B保持、末B禁止FINAL。其逻辑事务地址/数据/strb被核，不签实际物理BO/邻行或范围外哨兵。

AT233明确记录stage1选数2488、实际物理MUL采样2489且该沿之后结果已可见、HLS采样2490。仅接纳“已接受但HLS未采样”共同reset后510拍所监测隔离及下一局部32head行；严格IP已接受未返回窗口仍NOT_RUN，不签算术内部清零。AT234的AW-only/W-only/AW-W待B触发在RAW写阶段，第四触发为RoPE scratch已收2R；四次各510拍隔离，只有该四次序列末尾完整成功一行，不能写成每个reset之后都独立完成整行，也不扩成RoPE写阶段/独立AXI reset。

AT240仅接纳生产wrapper/reader/writer＋模拟core/快速叶子的128位元数据：RAW32768笔B、RoPE16384笔B、4096次head控制后，最后done消费才发布FINAL；QKV epoch2/norm1、正确release与下一begin3、partial discard消耗到4成立。日志中的next_begin5是下一允许值，本测试没有实际begin5。叶子常量输出及复用单行逻辑内存不证明128行真实算术或物理隔离。

AT225旧b1315262…的真实row0 cold/row1 warm正常链及4096个Q/K FINAL保持原限定接纳，不迁移新wrapper；64head的全Check字段/哨兵等仍按原审核边界。

## 原合同待补的最小叶子短例

[修订14合同](qkv_rope_connection_decision.md)明确要求末pair、多个非finite位置及原预检/计算首错；当前交付只有一个head首元素NaN区分例，不能据此写完整Check异常ABI已验。继续复用当前生产adapter和原full-Check叶子，同一小TB做四个可手算位型用例，逐项核code=6、detail=0x0740000f、完整64bit bad及完成保持；保留ABI未定义位，不造新模型gold。原语义依据为E002 `hls/operators/rope_full_compute.cpp`。

1. 多坏输入预检：例如cos[7]=+Inf、x[63]=NaN，其余正常，期望bad7；验证d递增扫描，不能按输入来源分扫选首错。
2. 最后pair下/上两半都将溢出：x[31]=x[63]=max finite，cos[31]=cos[63]=sin[63]=1、sin[31]=-1，其余有限正常，期望bad31；下半先于上半。
3. 最后pair只有上半溢出：沿上例令sin[31]=0，其余保持，期望bad63。最大有限位型为0x7f7fffff，以上乘/加减均按原叶子执行。
4. 预检优先于更早算术：x[0]=max finite、cos[0]=2，另x[63]=NaN，其余有限，期望bad63，不能因未来pair0乘法溢出提前报bad0。

对坏head原有部分y可被adapter吸收但不当成功输出；随后不reset运行一个已有正常保存head，核原Check及64项输出，确认合法重新prepare/完成消费。不要force叶子FSM、valid、债务或done；不改原leaf/IP/生产数值，不额外重演791s两行或1404sFFN基线。无需为这几个叶子样本重编整个真实core或启动OOC。若实际遇到合同冲突或同因重复失败，保留原结果并集中报告。

逻辑内存哨兵/实际物理BO、全请求首错和全128真实生产继续列缺口，后继真实设备入口与tensor连接再处理，不为本次控制修复扩大成通用故障工程。

## 成本与下一连接

原guard精确累计static978.93351217359304232/1800s、RTL1241.301459711045058/4800s；余821.06648782640695768s与3558.698540288954942s仍在本修订，后续短例正常扣账。host完整累计UNKNOWN。主控本轮只做读取及轻量字节核查，不执行EDA。

完成上述短例后集中补同一阶段报告/机读账及三摘要，按旧真实链/新局部/NOT_RUN分版交付即可，无中间步骤放行。A003另做下一真实S128生产与FINAL→Attention接点的有界静态准备；没有修订15实现或新重工具授权。本轮不因局部通过关闭M004完整目标。
