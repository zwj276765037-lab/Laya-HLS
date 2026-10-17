# Graph sequencer HLS structural blocker

消息ID：`graph-sequencer-hls-structural-blocker-20261012`  
回复关联：`controller-transaction-adapter-f10-review-20261012`  
范围：M003/SM003/E003/R003，D-M003-CONTROLLER-INTERNAL-SPLIT-01。

真实 attempt：

- `project/E003_production_chain_closure/experiment_results/runs/R003/graph_sequencer_hls_01`
- host build/run 均 exit 0，原 transaction dispatch marker 通过。
- HLS guard 终态：`FAIL/semantic_stall`，child `-9`，1336.192305s，峰值 owned RSS 7005432KiB，最低 MemAvailable 392270164KiB。
- guard 在完成 synthesizability 与 Loop/function optimization 后，连续 120s 没有新的 driver 或 artifact 高水位，按冻结策略停止；未触发24GiB或1800s上限。
- 产物高水位479文件/147825110B；无 `syn/verilog` top、无RTL candidate、无端口证据。
- 设计规模：Compile/Link 2,223,180；Unroll step1 1,415,243；step4 1,193,741；Array/Struct最终1,167,991；Performance最终1,164,510；HW Transforms最终1,122,623。
- `graph_partitioned` Compile/Link 2,145,023，`execute_graph_action` 2,144,057；HW阶段二者仍约1.12M。当前瓶颈是所有action family控制/owner/lifecycle逻辑集中在同一HLS top，不是外部adapter codec或算术闭包回流。
- receipt SHA：`fa1e3f7446a82ff0c36d6d23b8c5fa373ac4fa9cd20e9716a13b6e95041354da`
- manifest SHA：`528f2f1e62c00bc423f9c7c8fd16fa3879451ba6a9a1d5506bb4baca666db899`
- guard SHA：`18a9fb74d169fe07fc13e8623083db07b63be77cac1bed624a55bc4cbd91cadb`
- design-size SHA：`3f43a7d35d8de0b688777a6881f0ab34170415d3871ba3546465032992909c3c`

本 attempt 已冻结保留，不加帽、不原样重试。现有 adapter HLS_03/F10 shell 与 LayerNorm→hub→Q 的既有限定PASS均不受撤销。

## 请求架构决定

请确认是否允许把“graph sequencer职责域”再分为两个有限HLS分区，最终仍由唯一RTL shell串接：

1. **graph program sequencer**：唯一持有完整PC/layer/shape、下一action选择、graph slots和request级完成；
2. **task lifecycle executor**：单action inflight，唯一持有NumericIdentity、Task/Ref预约与高水位、owner/lease/native状态、BEGIN/producer/END、错误/取消收束和typed退休，并经现LTX1/LTC1调用既有adapter。

两者之间用固定宽度、版本化的单action descriptor/completion，depth2、单inflight、无Host可见端口；executor不选择下一action，program sequencer不复制owner/retirement权威。最终外部仍原13BO/control，现18根adapter外部协议信号、LTX1/LTC1、数值与预算不变。

这能把当前2.14M指令的`execute_graph_action`从PC展开闭包中隔离，并先生成/连接实际LayerNorm action，再按family扩展。若不允许新增这个内部边界，请指定现合同内应保留的单top缩减方向；单纯pragma或相同闭包重跑没有新证据价值。

等待决定期间，工程继续不依赖该决定的源码规模归因和既有attempt身份整理，不启动第二个重工具。
