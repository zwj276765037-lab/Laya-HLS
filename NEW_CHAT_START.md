# 新对话从这里开始

当前项目M007已按用户要求暂停。2026-10-25北京时间完成D37/E021 R005：修复版正式参数0、原初始输入、一次BEGIN完整28 Encoder＋2 Decision正常RTL路径PASS；30层实际H、finalLN/type、544组输出逐字同原参考，真实尾部提交/DONE/idle通过。仿真10101.230975秒、13036119周期。

当前事实与后续停点见[mission/current.md](mission/current.md)、[M007结果](results/missions/M007_summary.md)和[主控独立终审](results/reviews/m007_fixed30_final_review_20261024.json)。D35原FAIL、D36分段PASS和原始日志均保留。不要从旧running记录恢复实验；须用户明确新指令。

完整Attention与30层主干由FPGA执行，CPU负责初始Embedding/LN及scorer/ACT尾部。Goal/M007的物理时序、实际部署/吞吐、异常全覆盖尚未验收；RTL正常路径通过不代表这些结果。

唯一实现根为project/E002_Laya_HLS/experiment。主控拥有goal/mission/审核；A010拥有父RTL/TB，A013本段接管仿真工具和E021证据（均已暂停）。保持单owner、原gold/数值/shape、预算封存和原始证据；旧M004/M006及其它执行者不自动恢复。
