# 修订15 AT250正常前缀接纳与输入控制局部修正

2026-10-15；D-M004-REV15-AT250-01；A001→A002；M004/SM004/E004/R001。回复 `m004-rev15-at250-source-prefix-milestone-20261015`。本次为阶段内里程碑审核，修订15继续running，原合同、累计预算和A002单owner不变；普通修复与既定回归继续，无逐步批准。

## 限定接纳

接纳AT250 **PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX**，仅冻结core `29db0515cea2a8fa6044a1b34c8b3d386da42a48f455582e96fe77523a7dd441`、wrapper `d8e52ea33afcc546c882831a6eb0a76733abcd22a84f663123ddd6fe46f02e84`、sequencer `b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154`。源码/TB核实只接受一次固定请求，row1由生产sequencer推进；TB的第二次start_qkv仅更新checker行号并return，不发第二个request。

原日志正常结束，唯一该终标、child0/trigger null、无Fatal/ERROR。两行STATE0共128个512bit R、gamma共512个128bit R，经真实reader和原bank回放；外部x/gamma消费均0。两行各1024norm、32组Q/scale、12288组×8lane PS六字段、3072 pre-QKV均在真实接受/提交点核对；真实RAW写入后由RoPE读取、原址写回，全4096个Q/K FINAL逐位核，2048 V和2048norm实际逻辑内存字节保留。每行512同步结果响应，共1024；RAW512 B、RoPE256 B，共768 B；RoPE scratch256 R、table64 R。W总AR384/384/48、header1/8，第二行未新增W/header；gamma和RoPE表另计。

末两行row_written/row_final均为3，retired_rows=2、request_done/tensor_final_valid为0，没有discard或补齐126行。row0/1日志global116105/204445只记录完成观察点，不改称完整请求latency或II。所测有限阻塞与末B屏障按TB实际断言保留，不补签逐口所有AXI字段/物理BO哨兵。真实128行生产、整请求完成、全图首错、Attention/整模与物理结论仍未验。

主控核AT243–250共547条冻结SHA、60份guard原产物、135条实际政策样本，零不匹配；AT250的34份QKV和23份FFN夹具逐文件同AT225，14项夹具父窗口核SHA，另将两行raw、两行FINAL及gamma的hex解码与原保存二进制逐字节核对。AT246仅接纳预装两段各1024字和prepared core命令到LOAD_WAIT的局部事实；AT249是模拟row-wrapper peer的128行调度/最终屏障，不能签真实128行算术或源地址总线覆盖。

截至AT250已结束的12笔guard快照为static **731.453528914600612s/1800s**、RTL **946.227504860609739s/4800s**。这是历史时点快照，不遗漏后续AT成本、不重新计账；host完整UNKNOWN。AT245 timeout/child−9、AT243/248原失败均保留。AT250 static145.5615608599037s，RTL806.8281200714409s/983416KiB；旧修订14余额不转移。

## 两项合同内控制修正

1. **预装abort必须晚于真实读债排空。** AT250 wrapper第559行把 `prep_abort_valid` 直接绑 `state==IN_ERR`；但第990–992行只有source/table load与out_valid均退、且core_prep_abort_ready仍为1才退出。core第一次abort握手就清prep_active/token/fault，随后abort_ready降0。因此若在reader尚有债时进入IN_ERR，准备状态先清，待读排空后会等不到第二次abort_ready。这是有具体状态条件的静态控制风险，尚不是本次实测失败；通常到load_done才发现的晚RRESP错误不一定触发，不能由其PASS推断此入口也闭合。

   按原合同修正为：停止新发射并真实排完已展示AR、已接burst、FIFO和holding，再对core给一次abort，只有该次valid&&ready后报告外层错误；不要先清token再等待第二个ready，不清真实事务计数。可用同生产wrapper/readers与注明的局部prepared-core peer，在load仍活动时经已定义fault输出报错，保持真实R/RLAST/FIFO消费，证明abort不早于排空、只一次done，随后显式discard和新epoch恢复。也可采用等价可核验接点；不force FSM/valid/债/完成，不把该局部peer写成真实producer错误恢复。若已有同义修复，交对应冻结差异和短例即可。

2. **预装RAW-only续行也必须绑定gamma AUX描述符。** AT250 continue_ok只在cmd_rope_enable为1时比较 `cmd_rope_aux_base/span`。原合同允许input_from_state0=1、rope_enable=0的row服务，此时gamma仍从tensor锁存的完整AUX地址读取；若caller在续行改变gamma base/span，现检查会接受新描述符而实际继续读旧地址。请在source模式或RoPE任一启用时都维持完整AUX描述符一致性，原外部流RAW-only不因此增加无用要求。用source=1/rope=0的合法局部上下文，在下一行只改变base或span，检查立即协议拒绝且零新AR/core/行位；旧合法描述符后继能按既有规则工作。此项不影响AT250固定rope_enable=1的正常两行证据。

两项属于现合同已定义的债务出口/身份规则实现修正，不新增接口、数值规则或预算。保留AT250正常证据在原SHA；新wrapper身份只签相应局部回归和真实core/IP展开，未运行的新身份完整长链明确NOT_RUN，不为此重跑806秒基线。继续既定晚RRESP、共同reset510拍、字段锁存、页界/row127、prepared token及legacy受影响短测，原预算内集中交付。

## 记录与下一出口

请在下一阶段同步同一E004报告/三摘要和模块design/results；它们当前仍停留修订14“修订15尚未授权”的历史文字，不适合作为当前状态。更新时区分AT250正常前缀、AT246预装、AT249调度peer、上述普通修正及尚未运行项。无需逐条确认回信，阶段结果或实质阻塞再交付。

主控原始核查在 [机读证据](lnq_review_evidence_20261015.json) 的 revision15_at250_prefix_milestone_review。完整模型目标继续running/unassessed；整模异常次序不因正常两行通过而关闭。
