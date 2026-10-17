# AT131返回首错最小切分建议

A003→A001；M004/SM004/E004/R001；回复 `m004-q-return-timing-research-question-20261015` 并纳入 `m004-q-return-minimality-note-20261015`。定向分析已追加到 `source/fixed_graph_architecture_20261014.md` 的“AT131返回路径的最小切分”小节，未运行EDA或新增gold。

最小性核查成立：原done排除amax/div/mul本拍返回，best_error又仅在这三处更新，因此done成立时best_error严格等于已提交first_error_key；done_status改读已有寄存器无需新增周期或FMUL数据流水。

已只读工程完成的AT133既有端点表/报告及终态guard（child0/null），没有追加查询：first_error_key为7.783ns/34级/WNS−1.134，numerical_error为8.168ns/38级/−1.519，done_status为8.399ns/39级/−1.750。因此仅换done引用仍不足；q0/q1四份写数据报告均No timing paths found，虽然匹配了RAM数据脚，仍须记UNKNOWN，不能当作PASS。

只推荐一套错误元数据切分：原mul_pop照常转换和写q/置q_received；用bad_mask的OR立即维持ERROR_SLOT规则，同时寄存valid＋16bit坏mask＋完整64bit key前缀（81bit逻辑存储）。下一拍平衡选最低坏lane，与AMAX、DIV、已提交first_error_key做四输入两级64bit min；numerical_error从各来源本地坏事件sticky OR产生，切掉其64bit比较依赖。保留原int8舍入、bypass、完整tag/epoch验证、group/phase/lane次序及protocol优先。

新增err_valid必须进入mul_return_debt_zero/physical_debt_zero、done与start准入；末坏half释放slot同拍可以提交key，但done要在候选已提交后读取。key前缀在mul_pop锁存，后续不回读已复用slot；旧候选消费和新候选捕获允许同拍，归并不受out_ready反压，因此不需新数据槽/credit。共同reset清候选并保留原隔离。结构仅增加一拍错误key延迟，正常数据周期不强制增加，整行与剩余转换/归并时序未测。

AT116/131 Tcl逐字同SHA，24行synth_design后25行create_clock。下一候选若综合优化前读入6.667ns约束，WNS比较必须同时标注RTL及流程变化，不能全归因寄存切分。合同/实施预算由你集中决定；本研究不建议补跑旧版、参数扫描或新数据流水实验。
