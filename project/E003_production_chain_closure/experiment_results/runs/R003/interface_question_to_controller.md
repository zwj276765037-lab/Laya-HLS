# M003/L1：请项目主控核定 quant/G 门户身份映射

工程 A002，当前 E003/R003；用户已明确授权向项目主控询问。当前工具只提供 read_thread/wait_threads，没有 send_message_to_thread/handoff_thread；本文件是问题与证据，不是已送达消息。

§3.9 明确固定 command16×512 / response8×512、各depth2 FIFO、原13BO ABI、一份持久服务及所有字段显式共享定义。当前 codec/layout v1 已实现 matrix/LOAD 所需字段，一份Context、source/A/W/PS/dst五Ref、模型身份、范围与epoch，余96B保留且必须0。matrix/transport已局部PASS。

实际 `quant_task_to_dual_a_v1`需要producer/quant/future-linear三个Context及source/A/W/future-dst Ref；实际 `geglu_gate_quant_bridge_v1`还需要Wi/GATE两个不同Ref，并在produce时绑定未来quant/linear身份。生产C `Controller::linear_impl`目前先issue QUANT，再构造LINEAR；GEGLU各16row先全部执行，后续Down LOAD/quant/linear任务才构造。因此不能用task_id+1或C READY echo推断未来身份，也不能静默填入当前保留区。

请集中确定：

1. 私有命令的显式版本、producer/quant/future-linear Context及future Ref映射；保持1024/512B和有限容量。候选新增36B Context及8B future-dst Ref可容纳，现有操作各字段语义须明确；未实施该候选。
2. 未来 typed task/ref 的权威分配：由dispatcher提前构造并保留完整下游task/ref，还是调整物理GATE/A lease为后续命令到达时显式绑定；不得依据隐含task算式猜身份。
3. 完整rows16父task与TM4 rows4视图：一个父任务的quant/fullA、多个matrix view和末B/首错归并如何保持同一计划身份。GATE producer跨所有rows的owner与本地有限行bank关系须明确。

数值/模型/shape/外13BO/资源帽均保持不变。工程继续现合同内LOAD cancel/drain及BO连接；该定义仅阻塞quant/G生产使能与相依L2。同runtime完整链、当前完整CPU/CSim和M004总验收尚未完成。

实际接口证据：E002/experiment/vivado/module_design/activation_quantizer/rtl/{quant_task_to_dual_a_v1,geglu_gate_quant_bridge_v1}.sv；生产调度 E002/experiment/hls/control/full_forward_controller.cpp（linear_impl）；当前固定包 include/laya_compute_portal.h 与 matrix模块 rtl/laya_compute_portal_layout_v1.sv。

## 通信恢复与真实送达（2026-10-11）

以上“无发送工具/未送达”段落是此前历史。现已读取communication.md、核验来源用户消息与项目communication.json，并通过communicate.py向同一绑定主控投递。

- message_id: quant-g-question-20261011
- status: delivered（Codex已接受，不等于主控已回答）
- recipient_turn_id: 01a12a8c-5d86-7441-afde-5a274d845d26
- delivered_at: 2026-10-11T10:40:33.756203+00:00
- receipt: [.research-agent/communications/quant-g-question-20261011.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/.research-agent/communications/quant-g-question-20261011.json)
- receipt_sha256: 904536a62b3ace4b0f03d97ca3fabe4817241cb657a8b77ff78f330a41c1dba1

等候quant-g-answer-20261011的直接答复；通信恢复不改变M003/M004的实现、模型或验收范围。
