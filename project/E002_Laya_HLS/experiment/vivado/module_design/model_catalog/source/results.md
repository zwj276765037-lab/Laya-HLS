# M007 catalog 结果与边界

E020/R001，A008，功能格式/协议实验；目标架构见 design.md，协议见 E020 experiment_source/protocol.md。期望模型 gpt-6.1-sol/xhigh，实际未核实。

AT001_host FAIL 保留：reference1.104193551989738s，原tensor1-based与inventory0-based及原type名错误。按实际原元数据修复；无gold/数值规则改变。AT002_host_fix EXIT_ZERO：reference1.321733022981789s，8组测试全部PASS。两次 owned cleanup 为空，PGID不存在。

AT002 检查120 WeightKey/shape/bias/索引/原字节身份继承、固定8192B格式、独立CRC标准向量/长除、首末record在刷新校验和后结构拒绝、完整身份/header/tail/非法数值/溢出/aperture/overlap及实际CLI build/verify。SIM catalog SHA256 bf187e0b2987b0fbc5e1951dee35b6b3219631dfabb9158c0b77f2b92b81dfe3；records SHA36455736…、CRC64 cb4a2935cd23ffc8。

原10系数tensor实际读出共81088B并逐SHA核原包，bias73728B/gamma4096B/type原3264B；type展开3072F32/12288B逐位对原embedding_row三行PASS。展开type SHA09c9cc40955fc14237f23e0c807f9381ebc2f1eb3ae8be1953e5d3a0446ca798，704chunk产品流SHA2d3332adfa90655e6c7716d0cca75868cd883c3f34dc927151e4362d2303c6b2。原全模型SHA继承，本轮未重哈455MB或读矩阵payload；无runtime activation gold。

Host实际证据：project/E020_m007_model_catalog/experiment_results/runs/R001/attempts/AT002_host_fix/work/host/{report.json,type_reference_comparison.json,coefficients/report.json}。AT003 Vivado2025.2 xvlog/xelab O3 编译和源码顺序状态census PASS，static4.197466782992706s。AT004公开RTL PASS，5.2437239199643955s/875cycles。reader源码只有state2bit、1顺序块、无payload/address/identity FF、无descriptor；这不是综合或物理资源实测。实际req132/AR131/R132/parent_rsp129/fault3/drain3/两TB槽提交121（全120record扫描+复位后恢复1次），AR held总150拍（含定向17）、R held34拍（两段17）、实际债bubble271、reset9边沿。缺RLAST实际再排空3R拍含bubble，错误不写双槽；开始/在途/末尾common-peer reset后合法恢复。132条真实检查接受事件可审计；14原snapshot文件未变，4运行时新文件另记。四attempt源归档逐文件核SHA通过，761次owned策略采样/0修正，全部cleanup空。生产mux/transport_idle、设备setup/model_committed/系数commits、DMA、完整层/30层、OOC/P&R/时序/上板均NOT_RUN。

最终交付：[independent_delivery_v1.json](../../../../../../../project/E020_m007_model_catalog/experiment_results/runs/R001/independent_delivery_v1.json)，源码manifest与预算closure同目录。reference累计2.425926574971527s，static4.197466782992706s，RTL5.2437239199643955s；各phase保留60s收尾/修复储备，无旧余额转移，无active/queued工具。A001集中范围审核待定。
