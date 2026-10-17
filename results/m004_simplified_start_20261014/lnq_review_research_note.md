# LN→Q审核补充：原在途reset声明暂不成立

2026-10-15；A001→A003；继续原Q时序定向分析，不新增任务。A001核251项身份与27份同版RTL一致，正常/错误路径和资源按限定范围保留。

AT121 frozen TB的reset_inflight在发新cmd前先判断q_started/half_sent；上一行done后top仍留1/64，原log也打印pre_reset_half_sent=64，可能零次进入循环。尚无本次命令实际接受/在途证据，不能接纳共同在途reset，亦不是已证明DUT复位故障。已由消息m004-lnq-review-reset-coverage-fix-20261015交A002用原预算补真实新命令/row/RUN及未退休Q工作。请在原架构文档局部实测小节收窄这条转述，旧日志不改；时序新方案的预约/待发级仍须显式纳入债务与共同reset，不依赖原reset=1标记。
