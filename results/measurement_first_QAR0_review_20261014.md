# QAR0有限仲裁修复接纳，转LN_FFN独立源闭合

R-SM005-QAR0-20261014；M004/SM005/E005/R001。回复`measurement-first-QAR0-scoped-result-handoff-20261014`，合并`measurement-first-QAR0-default-static-addendum-20261014`。主控只读审核，没有运行DUT工具。

**接纳AT035正常四行实链及三组定向入口竞争；接纳AT036默认EXT_QUANT=0真实compile/elaborate。原双valid互锁已由统一G优先选择修复。后继直接执行[D-M004-LN-FFN-SOURCE-01](../mission/ln_ffn_reference_source_stage_20261014.md)：原request3独立参考前缀捕获LN前residual及输出身份核对，再给出baseline LN只读接点表。无需新用户批准，不启动LN DUT或全局控制。**

## 修复和覆盖

AT034→AT035冻结diff只改bridge RTL、TB、runner三项；106manifest行/104不同冻结路径，其余103行保持。新增组合select_ext_quant统一ready/accept/payload选择，IDLE同时valid时G优先；原ext_quant_active维持已受理外部任务至拒绝或实际响应消费且债务清零。无新增持久状态、队列、量化器、矩阵引擎或缓存。

full在cycle23唯一接收owner拒绝G探针，external保持至cycle24接受；真实外部Q及七拍响应保持期间等待G，消费后G零工作拒绝；真实G及七拍响应保持期间等待external，消费后external零工作拒绝且epoch2 A/656笔GATE写读保持。后两组由冻结TB断言及随后完成的full佐证，无单独接受/拒绝周期打印，不虚构边沿，不扩写为所有逐拍交错的形式证明。固定G优先不承诺无限G流公平性，活动取消/恢复未验。

新Context对齐原include/laya_tasks.h：LN_FFN0x12、QUANT0x20、Wi0x32、G0x60、Down0x33；局部不透明键保持不代签生产opcode权限。AT036同SHA bridge作为实际simulation top、默认EXT_QUANT=0且无参数覆盖，日志确认compile/elaborate完成；G-only独立动态回放仍NOT_RUN。

## 数值、存储和周期

原LN_FFN四行F32外部源→真实Q4096INT8/128scale→dualA epoch1→Wi20992F32/671744 PS/1312 AW-W-B→实际DDR reader1312R→G10496F32/656 AW-W-B→同Q读取656R/328组→dualA epoch2→同resident Down335872 PS/4096F32/256 AW-W-B，全原独立gold通过。两段末B、A/W lease/读债、七拍保持及各一次实际消费闭合。393216B DDR终检先于CHAIN_PASS：只读源16384B、输出142336B、未写哨兵234496B。

源Q接受24→A发布1103=1079cycles；4 AR/256请求beat/256真实R，首末AR27/712、R31/938。Wi cfg55239→首次done102148=46909、→消费102155=46916；G接受102160，新A发布162865。Down cfg189944→首次done206128=16184、→消费206135=16191。全冷TB206136；AT034→AT035多3拍是诊断探针/响应相位变化，不是性能优化。互斥状态和46909/16184吻合；旧A_fill_accept标签包含拒绝探针，不当合法发布。

AT035 static/pilot/full为83.022106/29.197961/1782.005508s、full峰1505004KiB；AT036 static53.105357s/2212056KiB，均是工具成本。合计224条文件身份引用逐SHA/bytes核对，4guard串行/76实际policy符合原CPU0–3/nice19/idle，child0/trigger null。AT035自身3guard/45policy、full准入2726.021088s<3600s。审核脚本第一次默认参数正则过窄，按源码并列parameter语法修正后通过，不涉及DUT变更。

## 后继依据与范围

原capture明确只是源BO观察，缺LN前residual；LQ0 layer1 LN_ATTN不是enc0 LN_FFN同一输入。独立full_reference SHA与旧官方oracle一致；B1_from_b0的encoder0完整输出历史参考成本1.522s，支持有界计算至residual/LN输出即结束。LNREF0用原五输入/GGUF，保留完整S128依赖和数学图，保存完整128行及前四行LN输入，独立LN输出与旧capture/AT035源/q/scale分开生成、逐位核对。主机入口≤8GiB/120s，单方案及最多一次有因封装修正，详见合同。

LN baseline生成物复用、真实BO/地址、最后B/发布/lease与Q接线本轮只读核定。真实LN producer、FFN residual、28+2层/122矩阵、生产13BO请求/恢复、联合资源/物理时序/上板未验，M003/M004仍开放。KB1/ATN1限定收益保留，LQ1不生产采用；整体executor/冷INIT/CLOSE-rearm/cleanup停排，G仅OOC余额与5172s不重启保持。

证据：[主控核验](measurement_first_QAR0_review_20261014/verification.json)、[bridge差异](measurement_first_QAR0_review_20261014/bridge_diff.txt)、[TB差异](measurement_first_QAR0_review_20261014/TB_diff.txt)、[工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md)、[AT035收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json)、[AT036收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json)。
