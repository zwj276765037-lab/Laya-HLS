# E016/R003 FULL-PARENT-15

正式合同SM012末节。独立reference0/static600/RTL6000/OOC0秒；static单次120、QKV3同snapshot120、同snapshot真实第二head pilot1200；至少600s短恢复/审计保留。完整单次不超过3600，固定成本门E=1.10*(P2+14*Hmax+Q)+10，余≥E+600且E≤3600才自动一次完整例。P2是本snapshot启动到真实head1退休，Hmax取两个真实head begin/end较大wall；Q是启动至末QKV实际提交wall，作为context+WO的显式保守可证伪占位，非实测。原E012 standaloneWO203.558494425s只作背景，不拼实测。系数不改，不延长旧attempt，完整失败不自动再跑长前缀。

原项目锁覆盖全部子进程，CPU0–3/nice19/idle、MemAvailable>192GiB，static≤24GiB/RTL≤8GiB、40Mcycle、严格实际数值比较递增标记停滞120s。生产先冻结，实际缺陷暴露前不改RTL，不复制私有服务；TB/peer使用原独立QKV/RoPE/16head/context/WO参考，不生成新gold。全部fixture复制一次并绑定SHA，完整TB在所有scope初始化同一套数据。

同一m007_full_parent_tb/snapshot：PREFIX3为短前缀；PREFIX0 STOP_AFTER_HEAD2仅在第二head实际退休结束；STOP_AFTER_HEAD0全链继续至独立预期243bit成功回执保持5拍并真实消费。保留全部原8身份拒绝、原checker频度、实际W/A/prebias/QKV/score/prob/context/PS反馈/连续issue检查。head统计独立，maximum128每head必须比较；真实公共context4096→同quant/A4096写ack并发布；WO16块/4096响应/131072值独立gold。AR接受时按地址锁定QKV/WO来源与base，每ID返回使用该锁定值，不按后来全局phase改旧事务。

仅原out_ready驱动中WO保持8拍/末WO保持12拍；原done_ready保持5拍。逐拍拒绝真实全链前提前DONE；首次正常DONE精确期待status/source/domain/tuple全0和原cmd request/gen/epoch。有限外部停顿与原始总周期均记录，保持QKV57344/layer188544/WO22528、dispatch16/合计128、Attention父段268416帽。数值完整通过但周期失败独立标记，不能叫完整Encoder/FFN/30层或物理/板上通过。
