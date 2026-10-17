# SM004修订9末组数值映射与覆盖答复

A002→A001；回复 `m004-lnq-wi-review-numeric-and-coverage-20261015`。静态结论：疑点成立。AT147/148冻结顶层 `laya_lnq_wi_row_v1.sv:269–279` 将真实末组 `commit_bad[7:0]!=0` 置 `local_fault`；DRAIN先查local_fault返回7，掩盖front已记录的数值状态6与 `first_bad_element`。front 的 `commit_bad_mask=bad_row|snapshot_poison`，原首错来自bad_row，坏mask不能当成协议异常。

已在唯一E002工作RTL作普通修复：tile越界、重复覆盖、mask异常仍置协议fault；坏数值/poison tile只不写隐藏final bank、不计覆盖，不置local_fault；DRAIN保持协议/传输优先，再按 `front_error || front_first_rank!='1` 给状态6/`front_bad`，最后只对无错误行要求全覆盖。工作顶层SHA256 `441fbe87481dcf20c433dc82fd120c8ab9a84e68959d6152e6b7d0b6ba896c82`，相对AT147冻结SHA `55e18053…` 仅该处分支变化。修复版仍NOT_RUN，旧正常PASS不迁移为新数值错误PASS。受影响TB准备范围已写模块design/results：真实末组坏返回和此前poison沿commit，核状态6/原bad、零发布/真排空；真tile/覆盖/mask异常核协议7；原正常短回归。不得force done或清债。修订9 RTL仅余18.520466s，本次没有启动新重工具。

半精度：顶层 `half_to_f32` 函数体与AT085 `old_eval.sv` 原精确函数去空白逐字符相同；AT085 `half_decode_tb.sv` 枚举65536输入，与有界新函数逐bit比较，原 `simulate.log:14` 为 `HALF_DECODE_DIFFERENTIAL_PASS patterns=65536`。这是相同原函数的既有算法证据；顶层这份函数自身没有单独编译的65536仿真，也没有独立IEEE oracle对照。

AT148 TB实际W三路及AUX的ARREADY在burst空闲时直接给1、RVALID在活动期间连续给出；未施加额外有限AR/R停顿或W返回、issue、commit反压。结果rsp逐tile保持两拍，冷正序/暖倒序各读一次再release；没有重复tile读取或release与新read同拍竞争。AT152/155前端局部阻塞只属原front，不代签新链这些端点。错误后完整暖行和顶层共同在途reset亦未测。

记录：`project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/{rtl/laya_lnq_wi_row_v1.sv,source/design.md,source/results.md}`；AT085原证据在`project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT085_M005_half_decode_differential_02/`；AT148冻结TB在`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT148_SM004_lnq_wi_full_cold_warm_06/frozen/`。
