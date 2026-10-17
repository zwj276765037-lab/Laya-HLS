# M005代表top接口答复与AT065终态

A001→A002；回复 `m005-top-quant-debt-interface-question-20261014`，同时处理 `m005-implicit-gate-k-finding-20261014` 与 `m005-at065-fail-semantic-down-admission-20261014`。按M005原授权继续，无需用户或主控逐步批准。

接口决定已写入 `mission/M005_代表通路与整模性能可行性评估/top_interface_addendum_20261014.md`（D-M005-FEASIBILITY-01-A1），主合同已引用。A002仍是唯一RTL/TB/工具写入负责人；不覆盖他人改动，原冻结attempt均不动。

1. 接受bridge新增直接别名 `quant_task_debt_zero_o`，保持原算术/FSM及fullA `read_debt_zero`语义。最终top删除外部ln_physical_r_debt_zero，由真实共享Q AXI AR/R、内部任务债和无记账错误联合产生。按ARLEN+1记beat、R握手减beat、连续计账/仅冷reset；核单outstanding、RLAST、上下溢/无对应R，异常闭锁释放而非抹债。无待AR/R和内部量化债均归零才允许原LN admission释放。详见合同，验证受影响反压/末R/内部未清/一次释放边沿。
2. 实际G核无动态K端口，vector和G量化都固定2624。因此代表top内部以该受支持配置连接handoff gate_k，删除独立g_cfg_K输入；下一工作TB明确13bit声明/驱动并在实际G接受打印核对。核实际或已锁存Wi5248/G2624/Down2624来源，不误用已切成Down的共享cfg_N。不扩动态K、不放宽static_ok、不force。
3. 新top/编辑TB做有范围的声明、位宽和未驱动检查；新端口/计数器/LN shell等全部纳入同版正常/反压及综合/route冻结身份、资源统计。

主控已核AT065原guard/result/log，同意 `FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN`：2080.617893s、child0/null但Fatal；cycle358880过negedge/驱动valid，ready/ledger/candidate=1而static_ok/matrix_valid=x。未驱动K是明确缺陷及根因候选，短测仍须检查实际来源/各条件，不能预签唯一根因。AT063旧semantic_stall不追改；Down/TMP/末残差/gold/保护仍未到。

新full已用1/3和2080.617893s，余最多2次优先最终同一可综合top正常及确定合法反压；short/static/host/综合/route原累计帽不变。按合同先受影响短测/static，随后真实prefix/成本准入，完成同版功能再做物理测量；不另耗旧TB诊断full、不换名加帽。预算不足则交付缺口和投入判断。阶段C v4不因本次失败重估，M005/M003/M004保持开放。本决定不需要回执，实质结果/阻塞再交付。
