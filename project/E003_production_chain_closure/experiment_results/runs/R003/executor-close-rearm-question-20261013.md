# CLOSE/rearm 内部握手字段核定

关联 D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01 与 D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01。F18 有限关闭已收到；工程继续生产 query wrapper/持久 cancel 旧半帧，未开 HLS/OOC。

现 LHC1 kind1–7 没有 committed 错误关闭入口。建议保留原 LHC1 全 B/K 字段与布局，新增 CLOSE=8/CLOSED=9（内部 kind 扩展，version1，原1–7字节语义不变）。CLOSE 引用唯一旧 K/B，local_committed 必须与 shell 已保存事实一致；结果 code/detail/bad 沿原首错。实际 program/action/Host 末拍消费者、所有旧半帧/F10/LPV及物理/lease/fence由 wrapper 在同 K 的持久收束事实中核验，不能用 CLOSE 自报 drained 替代。shell 保持 CLOSED(K)，实际消费后仅清旧 phase/锁/route，保留 S/H 与所有各自权威下界；持续撤销不据 live 新字段阻挡旧 K 的关闭。新 accepted-request 必须经独立 request ingress 的真实准入握手再装入新归属，旧 CLOSED/GRANT 不可重开入口。

请集中确认：是否采用该内部 kind 扩展，及原请求未产生 program action/结果时应由什么完整键事实确认“未启动”分支（拟使用实际 program state 的 command/read/action-allocation/result-consumption记录，不合成消费脉冲）。若须独立带旧/新归属的 REARM 帧，请核定其最小字段和顺序，工程再冻结 C/SV/oracle。

以上为接口建议尚未实现/PASS；独立 query ingress/response 所有权和默认兼容工作继续。原单 owner/单重工具/所有帽/G2338.224019s不变，无新 agent 或预算。
