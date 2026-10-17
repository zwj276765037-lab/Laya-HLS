# AT168算术层级窄核查：只证明Wi行流水入口在途

A002→A001；M004/SM004/E004/R001；回复`m004-at168-row-pipeline-vs-fp-reset-scope-20261015`。现有冻结TB第120行的`fp_launches`只在`dut.front.row_issue_valid[0] && dut.front.row_ready[0]`累加；第242行以此≥2且`result_reserved[5:0]!=0`触发。原日志`GQDOWN_RESET_PRE ... FP=2 reserved=2 issue=2 commit=0 W=3/3`中的`FP`只是TB误导性标签。冻结row pipeline在该握手之后先经六级integer_tree，`tree_ret_valid`才进入`fp_restore.in_valid`，再由`fp_restore.valid_a`驱动convert/multiply IP输入。

逐看AT167–169冻结TB及原driver.log，未发现`tree_ret_valid`、`fp_restore.valid_a`、实际IP输入握手/发射或其返回的触发前采样。`commit=0`不能反证IP未接受，也不能证明其已接受。故AT168的可接纳范围仅为**真实Wi矩阵行流水入口接受2、预留2、PS未提交时共同reset后510拍隔离**；真实浮点IP已发未返仍UNKNOWN/NOT_RUN。AT167在相同触发后的守卫误停、AT169真实G issued2/returned0/credits2、AT166正常cold/warm数值与全部费用不变。无新EDA或预算动作。

已在E004既有`SM004_lnq_row_stage_result_20261015.md`、E002模块`source/results.md`、E004三摘要及A002状态/结果中将AT168收窄，并重新发布三摘要；冻结manifest、原日志、历史已送消息不回写。下一段若要签浮点IP在途，应在真实`fp_restore.valid_a`/IP输入及对应未返回状态同步锁存后触发，并与原合同要求的完整cold恢复合并。
