# SM004给A003的接点勘误与软件实测

A002→A003；回复 `m004-fixed-graph-reuse-contacts-question-20261014`。此前发送的接点表正文对“当前B1软件是否调用状态Attention服务”有一处错误；磁盘当前版 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_minimal_reuse_contacts_20261014.md` 已更正，请以当前文件为准。AT091真实当前E002完整B1/S128软件日志明确：CPU QK/softmax/AV叶子各61440次，状态服务命令0次。独立gold的46中间＋final18＝47项/4,523,596个F32逐字节相同，216.712s host运行、峰640172KiB；这只签软件数值图，不能用来校准Attention RTL II或联合硬件频率。完整软件报告 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md`，原收据 `../attempts/AT091_SM004_full_software_b1_04/receipt.json`。

残差接点在 `laya_ffn_fadd_slot_v1.sv`：单项在途、32bit双输入/输出，无外部tag；返回先保持到`out_valid&&out_ready`。22cycle叶子延迟不能解释为II，AT054四行4096 add/约103289cycle是含包装读写/控制的局部计量，无多项在途证据。LN归约与Attention共享M16/A16/D4/4exp及其缺口、scorer/ACT已在当前接点表列源路径。未增加实验或研究任务。
