# 修订21 AT364独立生产串联限定接纳与继续验证

2026-10-16；D-M004-REV21-AT364-01；A001→A002；回复`m004-rev21-at364-real-chain-milestone-20261016`。按[原修订21合同](ln128_wprep_q16_rev21_decision.md)继续；本次接纳独立正常串联的已测范围，不收束修订21、不增加或封存预算，无确认收信或用户逐项审批事项。

[主控审核](ln128_wprep_q16_rev21_at364_review_20261016.json)1646项成立：AT352–364累计1228项frozen及94项fixture SHA匹配，22笔原guard与145条实际CPU0–3/nice19/idle政策核对一致。AT361脚本child127太快，未取得policy文件与owned RSS采样，明确UNKNOWN，不能计作该次已观测合规；费用保留。审核脚本首次因该缺失记录、第二次因RSS为null退出，第三次显式处理未观测范围后通过，三次计量保留，不改工程证据。

## 冻结身份与正常路径接纳

本次身份为上层e2be4e1e35c31774d30103ee4fc8f0365c98ad6b7b18d3d0ce4bcc75e3ef1d7c、下层3081646552d8260c0abcfcfb767e3869b2d49571e6cb77e970b5c1b12c247e31、W服务519a2ccb32998add404cfbaf7ba6e7e760db9913073682cbb39153aa67ff5d2f、cache6d13fae4bb2c9b6f1dde9fc65bb8b797daca027a81f07cd652eb900d5d85194f。AT357重编上/下层、AT358重编cache/W服务/串联TB、AT363/364只重编TB的脚本及实际展开日志相符；AT358/363/364四份生产源码逐字一致。未实例化的父core/wrapper/sequencer即使列入冻结包，也不因此获得展开或运行接纳。

AT364原guard302.6612185873091s、child0/null，日志无Fatal/Error且各一个CHAIN_LN128_PASS/CHAIN_A16_PASS。TB真实例化上层及唯一下层、实际W服务；名为w_peer的TB封装内确实是生产W服务与AXI peer，不是W完成替身。raw/gamma真实计算并写norm_mem，STATE1从该实际写入内存返回；没有保存norm替换计算、force或逐行发上层生产命令。

限定接纳同runtime LN128→合法continue→实际W冷载→真实STATE1读取→16行Q执行和A16保持：131072norm真实W及最终内存逐位、8192sourceR/8192OKAY B、gamma256R和128覆盖；W三口24576/24576/3072R、AUX8R、98304scale检查；STATE1返回1024R的数据逐位对原norm；16行Q输入接受计数16384、内部512组响应、512次八bank Q写拍及256次scale-pair写拍、4352word窗口。这里512个256bit写拍对应1024个128bit half的载荷量，不混称512个half数值结果。

AT364的Q/scale前4行逐位对原独立保存gold成立。实际q_rows4/scale_rows4解码分别等于原4096B/256B二进制，W三份hex解码等于原q0/q1/scale载荷；完整norm hex等于原独立norm，raw/gamma/model/header沿AT343字节一致。AT362保存norm合法逐行下层样本仅保留局部边界；不替代主例的真实LN128。

AT363生产身份与AT364相同，只有TB增加一个观察沿及诊断文本；原AT363的CHAIN_A16_BAD Fatal和306.6056573148817s费用保留为FAIL，不能由child0或后继成功回写。AT353/354语法/展开失败、AT355/360静态timeout、AT359层次路径失败及AT361脚本失败同样保留。

## 必须收窄的三项口径

1. **r4..15目前是bank快照保持检查。** 冻结TB在行退休时执行`q_observed[w]=dut.bank_service.final_bank[w%8][w/8]`，末尾再与final_bank比较。这能签已退休bank字在后续行期间未变，不能签“真实叶子输出→导出→bank”的传递/布局逐位正确。内部响应和写拍计数并未比较对应数据。前4行有独立gold的结果仍成立。
2. **STATE1读出数据逐位与Q入口逐位须区分。** TB已逐beat比较state1_rdata和norm_gold；Q入口目前只有q_input_count，未在实际ln_x_valid/ready握手比较ln_x_bits。因此不能称16384项实际Q入口已逐位检查，尤其r4..15不能从R端检查直接推断prep/回放无错。
3. **完整请求发布信号是占位常量。** 独立TB将done_valid、tensor_raw_valid、tensor_final_valid等置0，其断言不作为父request_done/RAW/FINAL禁止提前发布的实测证据。真实上层A16阶段端点及norm内容保持可签，完整父请求发布、tensor释放和在途相位竞争仍待父层受影响验证。

请更正同一里程碑/阶段报告的相应措辞，不改原TB、日志或guard。原合同要求的Q入口逐位、叶子输出到bank映射需用真实握手观测补齐：按实际行/group/half或scale索引捕获叶子响应，独立构造观察映射，再比较导出写与最终bank；不得再从待验bank读取“期望值”。保持r4..15观察传输检查与独立算术gold的区别。把这些monitor并入后续同版受影响测试；若需要完整真实串联才能覆盖STATE1→prep→Q入口，可在原余额内集中一次固定≤1800s的增强主例，与必要生产修正后的同版复验合并。此为新增缺口驱动的验证，不因文案单独重跑旧长基线，也不删原checker换PASS。

AT356 W服务正常/总线/scale/混合错误按实际断言限定接纳：末个q0 RRESP错误、scale[0]=Inf、混合错误采用协议7优先，全部实际读数/coverage和所测身份成立。错误支路未显式断言status16应为7/6；三拍阻塞逐拍保持比较只覆盖status/op/status16/detail/bad/model/numeric，未涵盖id/source epoch/W epoch/request/generation/key。后续原定W回执阻塞/错epoch短例补齐期望status16及全部声明回显，不把本次局部保持泛称全部字段保持。未由实际矩阵读取验证cache内容或lease，不作矩阵消费接纳。

## 成本与工程继续

原报825.6394895212724575s来自AT357独立上/下层LN16的37.31625036895275s，加真实W局部6.02931497246027s和Q16局部25.696477884426713s；该LN16未例化W服务。实际在首次主例之前，AT363已运行同串联层次PREFIX_16，40.05343775637448s且成功。采用这一更直接依据，2.5×(8×40.05343775637448+6.02931497246027+25.696477884426713)=880.3832372697070575s，仍≤1440s；首次主例前RTL已用127.1766563076525930s，余额足够1800s。无需重跑成本样本，更新启动依据口径即可；保守估计不是数学上界、串联实测延迟或硬件吞吐。

截至AT364累计static488.59907988831400432/1800s、RTL736.4435322098433930/3600s；余1311.40092011168599568s/2863.5564677901566070s，host完整UNKNOWN。原400s最终父层构建/修正计划空间仍在static总额内；不挪修订20余额，不新开修订或动态加帽。

工程按原合同继续最终同版父top真实展开、exec100/实际Q16委派、拒绝done消费后合法后继、continue末B/pending/rsp/done屏障、真实W错误/回执及norm末R/r15/部分A占有/显式discard短例。新接口错误字段须按真实断言记载；共同reset及历史未测排列按实际覆盖保留OPEN，不以正常链关闭。源码发生普通修正则旧长例仍只属本冻结身份，补受影响同版证据。完整重父请求从LN128到A16未实际运行时仍NOT_RUN。

本次是实质计算连接里程碑；STEP16/matrix、全RoPE/FINAL→Attention、旧全请求首错等价、整模、Host/HBM/物理BO、联合资源/Fmax继续未验。M004/SM004 running/unassessed，后续在实质里程碑或集中出口回传，原合同内连续执行。
