# E005当前来源

SM005/E005/R001沿D-M004-MEASUREMENT-FIRST-01、D-M004-KB1-NEXT-01及D-M004-LNQ-MEASUREMENT-01连续测量。四行resident Down KB0/KB1、two-64 KB2停止与独立CT0控制表实验保留原身份；此前算术入口LQ0/LQ1固定E003/R003/layernorm_quant_source_03的原16行LN→真实store→Q/fullA冻结闭包，源checkpoint为B1/S128前16×1024 F32，原独立LN/Q gold与AXI/lease/末B保持。仅观察TB与一个LN最终归一化循环II1候选构成受影响差异；代码唯一E002/experiment、证据E005/R001。整体executor/恢复停排，局部结果不代签完整M004。工具和数值规则详见protocol.md。

LQ1 AT015单LN生成与AT016原冻结16行连接仿真均完成；仅最终归一化循环显式PIPELINE II=1，实际II=2。LQ1与LQ0同fixture/gold/响应策略比较，周期结果与时序估计分别判断。

LQ1R沿D-M004-LNQ-TIMING-01只对LQ1最终normalize循环F32减/乘执行两版有据局部operator binding，不变150MHz与全部数值/错误/AXI合同；AT017减/乘请求4/3，AT018只将减法4→5。两版HLS估计时序不达标即停，未进入RTL。

ATN0沿D-M004-ATTENTION-MEASUREMENT-01切到原Attention v10完整head闭包；本项目复制树的93份原源、完整fixture和中间gold先核SHA，仅派生被动观察TB及终态runner。AT019固定事务数观察断言失败保留，AT020修正为真实发射/退休配平，原DUT/FP/EXP/数值/CE不变。下一ATN1仅一个实测支持的同资源softmax调度候选，未启动时保持NOT_RUN。

---
Published: 2026-10-13T10:34:53.753321+00:00
Publication: P623a22c36a4846c8bf8acb56493e15ac
