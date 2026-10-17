# owned program第二字段生成错误与持续实施

回复 executor-first-wide-fifo-program-repair-review-20261013；承接 D-M003-OWNED-PURPOSE-COVERAGE-01。

HLS05 actual PASS_SCOPED_GENERATION，严格8FIFO/24signal；guard460.284951s/peak5422052KiB/2299samples，child0/null trigger。owned RTL03 static PASS107.679985s；success在84645ns/phase1实际isolated FAIL，guard6.214035s/child0但有DUT fatal，不把exit0记PASS；其余三case未执行，旧FAIL保留。

新诊断03在独立克隆的已编译snapshot中于84620ns只读观测，无修改DUT/断言/旧attempt：真实nested purpose0001已正确，validate_fields仍返回7。A004定位了第二具体生成错误：校验d.content==F32却从Message RAM9[7:0]取target_region=0，正确content在[199:192]=1；同word width[191:176]=1024正确。a.g.0中的content比较已复用region值，a.o.3与RTL保持；尚未定精确AMD pass根因。state10保存or_ln79=1并直接短路，后续model canonical、handoff完整equality仍NOT_MEASURED，后续寄存器X/initial0/1不能冒充执行。

root正在同一完整校验体内增加真实content标量边界修复，并先由A004只读检查后续字段，避免每次生成才发现一项。host07现有purpose负例仍有效原冻结范围；内容修复须新增direct/nested content拒绝和新受影响host、再冻结生成。executor新host05已七process PASS但在content后续live变化后不会复用为新闭包；本次先不启动马上失效的完整HLS03。旧三处byte比较修复和共享字段边界变化均如实列入新候选，不归因单个优化。

主控批准的actual nested validator独立TB负例将使用真实双512bit Message RAM版本、实际16bit purpose，1正对照与0/2/0x0101拒绝，原wire不变；先修复合法RAM仍拒绝的第二缺口，再冻结这个正负闭包，不修改已冻结RTL03。actual adapter+sidecar+portal四case有限准备独立完成并排队；同A持久FSM旧END/INVALIDATE首LTX合同继续实施。

C完整NORM先行，D/Q与完整CLOSED/rearm后置；C/D周期NOT_RUN、M003/M004未完成。单重工具及原static24GiB/1800s/120s真实停滞、有限RTL8GiB/120s、CPU0–3/nice19/idle I/O/MemAvailable门保持；G仅OOC余额，5172s不重启。
