# E016：有界功能交付；完整父链未验收

execution_state: completed
verdict: inconclusive
applicability: 原Encoder0、有界父前缀/首head/故障恢复与独立生产context consumer；精确版本见R001/current_version_evidence.json。

| 范围 | 实际结果 | 版本/边界 |
| --- | --- | --- |
| 唯一资源与控制账 | AT022 build PASS45.051571955s；91947实际展开scope；所需13个服务/模块路径均恰好一份；452输入源；3746B保守控制账 | 当前parent；旧AT00391923scope仅为历史TB展开 |
| 原始身份拒绝与QKV3 | AT006、AT012及当前AT023：六个完整128bit source tag高半部错误、两个跨层tensor key错误均零实际工作；243bit错误响应保持5拍；实际4096输入/量化/A写/ack，768QKV32/24576值 | 持稳已测；各回显字段与完整原graph Check期望值不是本轮全覆盖 |
| 完整QKV→首完整head | AT013 PASS782.969087822s；48块/12288QKV32/393216值，2048RoPE提交，head0 score16384/prob16384/context8192，2048softmax-bank ack；head11038拍≤11648；命令→layer.start56026拍；命令→head末69139拍 | 旧parent；一次真实layer.start；不是16head或parent DONE |
| 量化NaN取消恢复 | AT015 PASS60.229704667s；4096真实输入，0QKV/AR，1PREPcancel+1Acancel，status/raw/domain=1/2/3，显式期望tuple000001000000000011000000；无reset新gen完整输入→QKV3 | 旧parent |
| 晚W故障取消恢复 | AT016 PASS76.090052532s；1真实RRESP错前已256QKV32写，1PREPcancel、0Acancel，status/raw/domain=2/3/4；无reset新genQKV3 | 旧parent；tuple000007000000000000000000为观测值，缺独立精确tuple断言 |
| 同沿producer失败 | AT017 PASS58.860724688s；真实producer_fail_fire与q_done同沿；1实际A取消+1PREPcancel，0QKV/AR，status/raw/domain=3/3/2；tuple123456789abcdef0fedcba98显式核对；无reset新genQKV3 | 旧parent；三类错误响应完整243bit保持5拍 |
| 生产context consumer | AT021 PASS6.426384921s：117组时带真实DIV/quant债取消，118读/响应、45A写/ack、无发布；坏tag18读/17消费、坏响应仅排一次且同沿无续读；无reset后4096读/响应/量化/A写/ack、1发布；末响应保持12拍无早完成 | 实际生产adapter/front/A/DIV+合法public源peer；不能替代实际layer16/父交接 |
| 当前parent共同reset | AT023 PASS53.261602898s：4096真实输入后在FPmul9、FPadd pending及31算术债/PS忙时共同reset3拍；随后40干净周期，系数覆盖失效并真实重写512组；新gen9/epoch10完整输入→QKV3，8364拍、31/13拍被动反馈 | 当前parent；functional peer共同reset。继承generic marker的kind=quant/no_reset=1不解释为整例无reset；HBM物理reset未测 |

AT013使用原独立QKV/RoPE/score/prob/context参考。其首head终点核真实h_done握手与上述数据/周期断言；固定unfinished_parent打印不证明该长例逐拍禁止parent成功，max_checked不是独立终点断言。其wall started_at误写在接近退出处，原文件保留，仅使用单调event差值；后续driver已修正UTC起止字段。

全16head/WO成本门：1.35×(782.969087822+15×119.898432351)+10=3494.951523668s，尚未计context量化/WO，已超过单次1200s与当时扣240s恢复后的2425.271683606s。COST_STOP/NOT_RUN，未创建全16/WO子进程或attempt；不是数值FAIL。不得把独立E012/R004原context文件WO131072值/22129拍拼作真实父整链证据。

严格数值进度guard SHA76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b，RTL停滞120s，仅接收实际比较后全局递增的M007_PARENT_CHECKED；任意日志/文件增长不续命。AT008缩短2s反例验证沉默和重复计数停止、真实递增通过；AT013 checked highwater827392无trigger。AT024审计PASS6.307549500s：3032文件/3764检查；20项xsim_script.tcl/xsimkernel.log运行变化明确登记为可变文件，其余受核冻结项通过。审计数值语义仍以各TB原断言为准。

保留费用：AT001/007编排错误NOT_RUN0s，AT009声明顺序FAIL1.969928092s，AT010依赖NOT_RUN0s，AT019空闲粘滞fault测试观察器FAIL5.424140056s。AT020仅在idle排除合法粘滞fault；活跃意外fault仍断言，未改DUT/gold。最终独立累计reference0/static319.040353202/RTL1195.020926156/OOC0s；AT024已计费，AT008内部synthetic工作只计外层static一次。

证据：[最终交付](runs/R001/final_delivery.md)、[版本](runs/R001/current_version_evidence.json)、[预算核对](runs/R001/ledger_reconciliation.json)、[审计](runs/R001/attempts/AT024_final_version_aware_evidence_audit/work/evidence_audit.json)。


---
Published: 2026-10-22T09:18:55.280297+00:00
Publication: Pa9647c2558cc42e884e77659ce64590f
