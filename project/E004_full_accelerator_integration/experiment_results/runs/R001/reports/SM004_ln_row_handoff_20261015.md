# SM004 LN 单行段集中交付（A002→A001）

回复 `m004-vector-accepted-ln-row-implementation-dispatch-20261014`。M004/SM004/E004/R001；无新合同或预算请求。

AT104 固定 CE 16 组连续 MUL/DIV/SQRT 独立位模式 PASS，观测 lag14/12/6、所测 II1。AT107 同一 RTL `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40` 的完整 1024 维单行九例 PASS：真实 gamma0 8482cycle；真实 embedding gamma1 含反压 11792cycle、阻塞820cycle；mean/variance/inverse 和各1024个输出对 P1 保存的独立核验夹具逐位相同。两棵相邻树各10层，峰 ADD占用7/MUL在途15。gamma2 仅复用 gamma1 数据；真实 final gamma 仍缺。前列 gamma 错与后列 normalize 错竞争通过受控 TB force 注入，不能作实际叶子产生该错误的证据。在途 MUL 发射至少8项后局部reset，随后新 gamma0 全行通过；日志的 `pre_reset_mul_issued=0` 为复位后清零计数器读数。

AT108 唯一同版 U55C 6.667ns OOC 152.791918s、峰 owned RSS4314552KiB、child0/trigger null，DCP 生成、blackbox0。综合14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM；14KiB逻辑行payload未映射BRAM/URAM。综合内部 WNS+1.967ns、WHS+0.036ns；72输入/179输出无外部delay、未布线，不是物理Fmax。`Synth 8-9873` 唯一critical warning来自两个字节相同的 ADD 定义重复读入，现版清单警告保留，后续连接时去重。

AT106 guard child0但 `LN_GOLD id=8` Fatal，语义FAIL，AT107改正 TB gold 映射；AT102/103依赖准备失败原样保留。AT104/107/108冻结清单分别65/20/22文件与AT107/108各7份fixture当前逐bytes/SHA核验无差异；守卫累计host0.373702s（仅已测下界）、static106.040047s、RTL29.865697s、OOC152.791918s，policy全匹配。未启动第二OOC或整图/旧FFN。

现有[阶段报告](SM004_ln_row_stage_result_20261015.md)、[机读证据](SM004_ln_row_stage_evidence_20261015.json)、模块 `layernorm_engine/source/{design,results}.md`、E004三摘要和A002 console已更新。请按本段限定范围集中审核并在同M004安排下一共享服务/连接任务。外部AXI/HBM、真实final gamma、完整硬件图、连续请求、联合资源/布线和上板均未验证；单行结果不代签整图性能。
