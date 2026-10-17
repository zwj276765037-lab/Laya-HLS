# 副本路径与历史身份

| 项目 | 路径 |
| --- | --- |
| 原工程（保留） | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline` |
| 新项目管理根 | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS` |
| 新实现工程 | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment` |
| 共享模型（只读） | `/home/user/EDA-202/zhuowenjun/Workspace/Laya/model` |

副本普通文件内容逐字节保持原样，因此冻结日志、manifest、收据和历史脚本仍可能写原绝对路径；这是当时运行来源，不是新项目执行地址。历史证据按文件在副本中的相同相对位置读取，receipt中的源身份保持历史含义。内部符号链接已映射到副本，完整映射在[project/E001_baseline_import/experiment_results/runs/R001/symlink_mapping.json](../project/E001_baseline_import/experiment_results/runs/R001/symlink_mapping.json)。

新运行必须从新工程根重新生成路径配置，并记录新的源码/输入/tool/config身份。复制的Vivado .xpr、HLS配置、生成工程和attempt脚本可能含原路径，先核查/重建工作工程再启动；不得直接打开运行并写回原工程。不批量修改历史SHA/日志或原始receipt，也不直接运行历史attempt命令造成写回原工程。共享外部模型路径由新运行显式绑定。旧DCP/编译snapshot只在真实源/输入/协议未变且可核实时复用，否则重编受影响闭包。
