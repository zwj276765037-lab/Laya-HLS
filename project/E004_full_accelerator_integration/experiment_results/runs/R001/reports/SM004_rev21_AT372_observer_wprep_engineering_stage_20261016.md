# 修订21 AT365–372受影响验证阶段交付

2026-10-16；M004/SM004/E004/R001；A002。承接修订21原合同和AT364限定审核。本报告只记录工程已运行的范围，M004/SM004继续running/unassessed，不封存修订21余额。逐笔原始成本和冻结检查见[AT352–372机读账](SM004_rev21_guard_ledger_AT352_AT372_20261016.json)。

## 生产身份与串联数据

AT368沿AT364同一生产上层`e2be4e1e35c31774d30103ee4fc8f0365c98ad6b7b18d3d0ce4bcc75e3ef1d7c`、下层`3081646552d8260c0abcfcfb767e3869b2d49571e6cb77e970b5c1b12c247e31`、W服务`519a2ccb32998add404cfbaf7ba6e7e760db9913073682cbb39153aa67ff5d2f`及cache`6d13fae4bb2c9b6f1dde9fc65bb8b797daca027a81f07cd652eb900d5d85194f`，只重编增强串联TB。其[冻结包](../attempts/AT368_SM004_rev21_chain_leaf_observer_01/source_manifest.json)148项含实际读取fixture逐SHA匹配。静态46.89623959176242s成功；[RTL guard](../attempts/AT368_SM004_rev21_chain_leaf_observer_01/guard_rtl_full_chain/guard_result.json)317.2744364347309s、child0、无Fatal/Error，`CHAIN_LN128_PASS`和`CHAIN_A16_PASS`各一次。

新增监视器在实际下层叶子`x_valid/ready`沿以row/index将`lnq.x_bits`逐位对原独立norm：16384项全过。512个同步Q响应按row/group独立采样Q8和scale；在每个Q/scale导出写拍核所用保持值和地址，再由这些**叶子响应**构造4352字期望映射，逐行退休和A16终点对真实bank逐位检查。该期望不从bank读回生成。因而r4..15现在可签STATE1→Q入口及叶子响应→导出bank的传递、布局与后续保持；其Q/scale算术没有独立gold，不能称12行数值gold通过。r0..3另有原独立Q/scale gold逐位。AT368保留原131072norm真实写/末内存、8192sourceR/成功B、W三口24576/24576/3072R+AUX8R、STATE1 1024R逐位与A16保持检查。独立TB的request_done/RAW/FINAL仍是占位常量，不能代签父层发布。

AT367实际完整父请求top重新展开，使用`-mt 4 --O0`，静态38.20180566050112s；[父row0前缀](../attempts/AT367_SM004_rev21_parent_elab_mt4_01/guard_rtl_parent_row0/guard_result.json)93.83217640407383s、1024norm/64B/source64R/gamma256R通过，无提前完整发布。AT365语法构建失败及AT366原120.41216295771301s展开timeout保留；AT367只到row0，未从父请求同runtime跑到W/Q/A16。父生产sequencer`9abc446e49f4c14d1519c975f21471f65f7d64a86b1dc627ae58178df6fb5d56`的枚举宽度修正已在AT367构建；完整父图仍NOT_RUN。

## 唯一W服务与core局部恢复

AT371仅重编W服务TB，W服务/cache SHA与AT368相同。[四笔RTL](../attempts/AT371_SM004_rev21_wprep_full_fields_01/source_manifest.json)依次核合法冷载、末q0 RRESP错误、scale[0]非有限、两错混合协议优先：全部24576/24576/3072R、8AUX R、98304scale检查及真实覆盖，预先错误W epoch请求零新增R。错误回执分别要求status16=7/6/7与原detail/bad64；成功为0。四种回执均在阻塞三拍逐拍比较status/op/status16/detail/bad64及id、source/W epoch、request、generation、key、model、numeric，消费后done撤下。四笔均child0且无Fatal/Error。这是W服务局部，不是父matrix lease/read或父请求阶段发布。

AT369发现原兼容壳新增W回显身份端口未代理，静态3.6712235640734434s编译FAIL。生产壳`laya_lnq_wi_gqdown_row_v1.sv`已只补固定透传，当前SHA`920d804f37cca1a3e5696a97b8c7d73938e734889e4914927ef4a5e4560a8192`；父top实际使用的engine在AT367→当前壳前缀逐字相同。AT370该壳真实展开成功34.39013186097145s；默认O0 core/W首次120s pilot只读到q0/q1约16612/16618R，child−9/timeout，保持COST_STOP，不能称回执PASS。

AT372以同生产SHA、同core TB与fixture改用独立`xelab -mt 4 --O3`构建，静态67.87822030484676s。四笔[core RTL](../attempts/AT372_SM004_rev21_core_wprep_o3_pilot_01/source_manifest.json)成功/总线/scale/混合在95.45499278604984、89.95392217300832、87.8939917255193、89.69303848408163s均child0、无Fatal/Error。每次同runtime先以无prep token的exec001得到status7/phase14/op10/detail07100005/bad全1，阻塞三拍字段稳定且零W/AUX；真实消费错误done后无reset改exec100，完成三口W冷载与完整身份、覆盖、Check、错误分类及三拍全声明回显保持。再消费W done并以epoch0发错误W命令，核status7/op80/detail07800005且零新增读取。终标的`status=7`属于**末笔错误epoch**，前一笔W成功/错误分类由终标前断言判定。此证明core局部后继与W委派，不是AT330要求的第三条合法LN_ONLY，也不是父请求W/Q同runtime。

## 精确费用与开放项

截至AT372，41笔guard按原十进制串累计static **818.12698524072765102/1800s**、RTL **1656.3998062927275925/3600s**；余static981.87301475927234898s、RTL1943.6001937072724075s。AT365–372新增19guard/132条已观测CPU0–3/nice19/idle政策均匹配，八份manifest 1191项实际冻结文件无SHA/字节失配；AT352–364的22guard/145政策由主控原审核复用，AT361过快退出的policy/RSS仍UNKNOWN。host完整累计UNKNOWN。旧修订20余额不转用；原400s父层静态计划空间仍在当前总帽内。

仍待原合同范围：continue在末B、同步pending/rsp、done未消费时真实拒绝及gamma退休/legacy交接；norm最后R、r15交叠、部分A错误/显式discard、受影响共同reset；父top实际exec100/STATE1/Q16委派与完整父请求LN128→A16同runtime。AT368已有r15正常真实串联数据检查，但不代替受阻/错误排列。旧gamma总线load_done错、store/numeric竞争优先、LN/回放在途reset与旧完整请求异常首错继续OPEN。STEP16/matrix、全RoPE/FINAL→Attention、完整模型、Host/HBM与联合物理资源/Fmax未运行。本阶段没有HLS/OOC/P&R或新gold。
