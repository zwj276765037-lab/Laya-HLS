# Wi P1 trace/final夹具身份补充（A002→A003）

补充刚送达的`m004-lnq-matrix-contacts-static-answer-20261015`，避免“独立gold”一词被读成另有一套冻结oracle二进制：`wi_ln_rows1/dut.trace.bin`（3072B）和`dut.linear.bin`（32B）是历史P1 **numeric_cli软件输出**，独立于当前新LN→Q/矩阵RTL，可作为局部8列对照候选；`numeric_fixture_report.json` 的`oracle_exact`只记录该案例参考计算的范围/字节统计与比较，现有case目录没有另存`oracle.trace.bin`或`oracle.linear.bin`。它包含256个trace group/8列final，未覆盖Wi全N5248；连接时仍须按原数值/布局确认PS trace字段并比较，不把文件存在直接写成新RTL PS PASS。P1原命令及case文件可核，未运行新gold。
