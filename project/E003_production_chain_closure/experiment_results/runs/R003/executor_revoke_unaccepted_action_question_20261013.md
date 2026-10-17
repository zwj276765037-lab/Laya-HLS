# 生产错误收束：已发command但未接受action的残帧

范围M003/SM003/E003/R003，沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01，F17 host范围已关闭。真实wrapper与绑定关闭/rearm实施继续，无需逐项审批。

具体缺口：当前actor发完LGP1进入RUN_ACTION后，F17锁存撤销并在port READ_ACTION/beat0禁止读取新LAX1首拍。这是已核的正确启动门。但program可能已经将完整8拍LAX1置入FIFO、等待LAC1；结果安全消费和rearm必须实际收束这个残帧，不能清FIFO/reset/谎称没有产生action。原45例故意留下8拍，其PASS不签请求错误收束。

提出受限取消收束路径：在同K撤销已确认、command确实已送到program且唯一旧action尚未正常准入时，另走显式cancel-drain consumer，收齐并完整解码原LAX1，核当前identity/PC/source/目标与原program command归属；只产生匹配安全错误LOCAL_REJECT LAC1（retired_tasks/first/last=0），不调用lifecycle start/CLAIM/producer、无task/Ref/LPV预约，不清旧物理债务。program正常消费后形成错误LGR1，Host真实消费且物理/各半帧排空后，再绑定CLOSE/rearm。若program尚未产生action且返回本地LGR1，则按真实未启动分支，不虚构LAC1消费。部分已读LAX1及已有active任务沿旧port/FSM清理，不走此新分支。

需要主控明确两点：该取消drain是否作为合法原action终态路径接纳；可信取消帧的ordinal是否仅推进接收校验下界（保持program分配权），而不计业务准入或退休。工程建议记录可信消耗ordinal，以隔离随后同ordinal重放；不更改program高水位分配或typed统计。

本问题不影响已提交但尚未外发LGP1时的本地错误结果、现有活动任务cleanup或独立wrapper/关闭/rearm实现。等待该窄边界答复时继续独立工作，不扩大F17关闭或完整请求PASS，无新预算/agent/HLS/OOC/P&R/上板。
