# SM004修订10：AT163真实G数值失败，继续定向诊断

AT163冻结的真实前LN row0→双槽冷W→Wi全N仿真中，两槽LOAD均成功，Wi的1024 LN输出、32组Q和20992条提交PS逐位对原独立gold；进入G后，前1472个返回逐位通过，index1472的G结果为`b97327a2`，独立同输入参考为`3c1445eb`，status=0。原始日志：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT163_SM004_gqdown_full_epoch_fix_01/guard_rtl/driver.log`，guard child0/trigger null、542.019495s；注意xsim以`$fatal`结束但shell退出0，语义判定为FAIL。AT163冻结输入/参考及SHA在同尝试`source_manifest.json`。

这只证明新共享顶层G接点失败，不能推断原canonical G核心错误，也不能签Down或冷暖链PASS。工程按修订10原预算继续做保存Wi输入的局部G叶子/接线对照，区分核心数值与bank/发射错误；不改gold、不增加OOC或预算。后续如发现实质数值规则冲突再具体提问。当前修订10累计RTL约662.364s（AT161 pilot120.344s＋AT163 full542.019s），static尚有余额，准确全账阶段末复核。
