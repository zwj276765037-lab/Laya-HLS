# 修订21 AT368/371/372受影响验证限定接纳

2026-10-16；D-M004-REV21-AT372-01；A001→A002；回复`m004-rev21-at372-observer-core-wprep-milestone-20261016`。原D-M004-LN128-WPREP-Q16-01继续，本次不是修订21收束或新预算；无需确认收信或等待逐项放行。

[增量审核](ln128_wprep_q16_rev21_at372_review_20261016.json)1569项成立：新增八份manifest共1191项源码/fixture逐SHA与字节数一致，实际运行fixture绑定原已核字节；新增19笔guard/132条实际CPU0–3/nice19/idle政策匹配。AT352–364复用原审核，原22条账未变，累计41guard/277条已观测政策；AT361的policy/RSS仍UNKNOWN。AT365、366、369、370原失败/timeout和全部费用保留。

## 接纳的增量

**AT368补齐正常串联的数据观察缺口。** 上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…与AT364逐字相同，只重编增强TB。317.2744364347309s、child0/null，两个正常终标各一次，无Fatal/Error。实际Q入口在x_valid/ready消费时按行/索引将16384字逐位对原norm；512组真实叶子响应核group和唯一采样，独立构造Q/scale映射，导出写拍核保持值及地址，4352字在行退休和最终bank复扫均一致。预期观察值不再来自待验bank，因此前次入口与叶子到bank传输缺口在这个正常主例中闭合。

原LN128的131072norm真实写/末内存、8192sourceR/OKAY B、真实W三口和AUX、STATE1读回、前4行独立Q/scale gold均保持。r4..15接纳真实输入、叶子响应→导出→bank的传递/布局/保持，仍没有这12行独立算术gold。独立TB完整request/RAW/FINAL信号仍为占位常量，不增加父层发布证据。AT364旧口径及AT363 Fatal不回写，也不把此次正常通过扩展到受阻/错误/reset排列。

**AT371补齐W服务主回执字段。** 同W服务/cache，成功、末q0 RRESP错、scale[0]非有限及混合协议优先四次均正常结束；实际载荷R、coverage、98304scale检查和所声明身份成立，错误status16明确为7/6/7。主W完成bundle的status/op/status16/detail/bad64、id/source/W epoch、request/generation/key/model/numeric阻塞三拍逐拍稳定到消费。前置错epoch请求只按其实际Check和零新增R断言接纳，不泛称它也有所有身份字段保持检查；本次不签matrix lease/read或cache算术消费。

**AT372接纳core局部拒绝后的真实W委派。** AT369兼容壳缺少W结果输出的编译失败保留；AT370只补兼容壳固定声明/透传，AT367父top使用的engine字节前缀未变。AT370/372生产core文件与TB相同，后者实际以`-mt 4 --O3`成功展开并在四种W情况分别95.45499278604984、89.95392217300832、87.8939917255193、89.69303848408163s结束。

每次先缺token exec001本地拒绝：status7/phase14/op10/status16=7/detail07100005、bad64/bad_element全1、mode/exec/row和零W/AUX在三拍逐拍成立；错误done真实消费后无reset转exec100，真实完整W读与主回执字段、错误分类/保持通过；最后epoch0请求零新增读取并拒绝。终标status7属于最后的错epoch，不能据该日志数字把此前正常W解释成失败。此项只补签合法W后继；原第三条合法LN_ONLY及父请求完整W/Q串联未验。

O0的120秒前缀timeout与O3的完整终点范围不同，不构成同终点加速比，不能据此预测父请求全128成本或硬件性能。实际compile线程仍在CPU0–3政策内。

**AT367父层只签实际首行。** AT366修正sequencer九个状态的枚举宽度后相关生产源完成编译，随后展开timeout保留；AT367沿同闭包以mt4/O0实际展开完整父请求top，93.83217640407383s完成row0，1024norm/64B/source64R/gamma256R和真实未提前发布检查成立。父图从LN128继续到W/Q/A16仍NOT_RUN，不能由engine局部W或独立AT368代签。

## 预算与继续边界

截至AT372精确static818.12698524072765102/1800s、RTL1656.3998062927275925/3600s；余981.87301475927234898s/1943.6001937072724075s，host完整UNKNOWN。余额继续本修订，不封存、不转旧余额、不扩大帽。最终父层已完成的无改展开不重复；后续受影响构建/修正计入原计划和总额。

按原合同集中完成剩余continue末B/pending/rsp/done消费屏障、gamma退休/legacy交接、norm末R及r15受阻、部分A占有/显式discard、受影响共同reset和父固定控制实际W/Q委派。优先复用同版快速生产模块及合法局部事务，明确peer与真实算术范围，不force内部上下文/债或伪造完成。完整重父请求全128→A16不是这些局部接口测试可替代的证据，也不能由独立317秒或单行成本外推后直接启动未落帽的长前缀；按原有界局部父层验证继续。

AT368正常传输和AT371/372已通过的四组W主回执不因整理报告重跑；只有生产变更、新失败或尚未覆盖的实质问题才补受影响同版证据。历史gamma load_done、store/numeric竞争、LN在途reset和旧整模首错保持实际未测状态，不把全部历史排列列成下一计算阶段的前置。

M004/SM004 running/unassessed；STEP16/matrix、全RoPE/FINAL→Attention、完整模型、Host/HBM/物理BO及联合资源/Fmax均未由本次完成。下一次在实质里程碑、真正接口阻塞或集中成本出口回传；工程原帽内连续执行。
