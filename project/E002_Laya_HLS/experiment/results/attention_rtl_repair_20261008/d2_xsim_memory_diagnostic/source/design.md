# XSim generated memory model diagnostic

本模块由Astra xhigh依据[当前修复合同§7.8](../../repair_contract.md#78-xsim生成内存模型的有限规模独立诊断)设计，Sol max实施；2026-10-08核查。目标是区分实际TV队列构造、二维queue复制、动态mem/IsWr分配和逐字节复制的主机内存成本，不执行Attention DUT。

权威实现来源为冻结v3的[file_read_agent.sv](../../d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/verilog/file_agent/file_read_agent.sv)（read_TVIN_file_bin，552–577行）、[mem_model.sv](../../d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/verilog/file_agent/mem_model.sv)（init，34–41行；tvinload，152–180行；带offset子类，298–313行）和[reference_model](../../d2_attention_slice/runs/depth_v3/csynth_work/hls/sim/verilog/attention_slice_subsystem/attention_slice_reference_model.sv)的run_phase七口初始化。源行号仅供定位，以冻结hash和具体方法为准；执行前保存原件/hash/精确观测diff，工具安装与v3源不改。

Q只调用实际file_read_agent读队列；M调用实际mem_model.init并写入/逐字节读回同payload；F调用实际mem_model_pages_with_diffofst全初始化链及offset文件。小TV为冻结fixture前缀，depth=1024/4096/16384/65536、单事务，独立核8B数量头/8B尾/实际文件长；每depth先Q/M后F，各fresh进程，同小snapshot以plusarg选择。观测严格保留原数据/分配语义，记录header、fread数量、队列尺寸、各次分配/copy及完整读回。

阶段RSS与峰值须可归因到实际元素数，必要诊断专用短暂停顿须披露观测开销；不能把全计划payload除采样峰值当每字节成本。任一预算或一致性断言失败立即停止后续扩大。每job2GiB树RSS/120s/2CPU/nice19/idleIO/主机可用192GiB，单重任务。小规模通过与线性拟合不授权完整Attention重跑，不证明全量内存上界；预算/模式/新depth变更另按实测审核。
