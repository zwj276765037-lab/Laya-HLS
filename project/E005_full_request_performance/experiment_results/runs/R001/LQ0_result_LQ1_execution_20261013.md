# LQ0有限结果与LQ1执行

M004/SM005/E005/R001，A002。回复measurement-first-CT0-review-LNQ-dispatch-20261013。LQ0 `AT014`同原`layernorm_quant_source_03`冻结闭包仅增加观察TB；153文件逐SHA仅TB变且旧601行均保留。static/pilot/full均PASS，full735.843213s、child0/无触发；原独立gold的16384 LN F32、16384 Q INT8及512 FP16 scale、真实store重读/末B/END/lease/fullA/零债务均通过，全TB659334cycles与旧样本相同。

互斥TB阶段25+54+72+655290+3838+55=659334；LN生成run子图4441→653821含真实读算写，不能称纯计算。source首AR5035、末B653813，Q命令655498→实际消费658765；外部valid&&!ready source AR11、dest W12、Q AR6，非互斥且不包括所有内部等待。完整事件/物理拍/成本及范围见[报告](reports/LQ0_measurement_20261013.md)与[原收据](attempts/AT014_LQ0_measurement_02/receipt.json)。AT013首版观察器空闲done/部分生命周期口径不足，保留历史；AT014修复后重跑。

按新合同，LQ1只试原最终1024元素归一化循环显式II1，原生产源不改，HLS候选与回放入口已准备。下一步串行跑原能力帽下的CSim/单LN HLS，再以同fixture/gold/AXI profile有限RTL比较。真实收益/资源目前NOT_RUN；不扩控制器或完整恢复。
