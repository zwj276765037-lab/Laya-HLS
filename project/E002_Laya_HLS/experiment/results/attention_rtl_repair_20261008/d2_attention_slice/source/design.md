# D2真实Attention数值/owner切片：设计

设计：GPT-6 Astra xhigh；唯一实现：GPT-6 Sol max。详细合同为[repair_contract.md §7](../../repair_contract.md)。本小top从真实模型中间QKV张量边界开始，经实际字节写入、生产owner领取/coverage/publish与真实typed LOAD/RoPE/QK/Softmax/AV任务验证成功和失败路径。不得直接手写READY/loaded_kv/score状态；不得把输入生产器称为真实Q8投影。

首批B1/S64 Decision、head0、rows1；后续覆盖按实际成本逐步增加S128/Encoder/全16行/B2。S64若来自S128前64行，仅是算子切片；独立gold须按S64重算QK/Softmax/AV。生产Controller完整CPU/CSim和D1控制RTL证据另列，局部通过不等于整网RTL通过。

工具/part/时钟请求沿D1；先CPU/CSim，再actual csynth报告审核，再有限RTL。初始RTL上限5e7cycles/30min，16GiB树RSS/192GiB主机MemAvailable、4CPU/nice19/idleIO、单重任务。具体可达cache、时序和资源以实际报告为准，不能沿用旧恒错误特化的3–5cycles。

本设计已获独立Astra xhigh原则审核，允许按§7边界准备和执行局部验证；生产源码更改仍须D1验收。AV基本运算oracle以实际RTL prob作为同输入独立重算，同时另报相对完整独立参考的端到端误差；不得混用两种判据。D2-I必须让修正生产方法在top实际可达。

## 首例实际映射（实现事实）

首例[attention_slice.cpp](attention_slice.cpp)使用7个诊断AXI参数：完整QKV fixture、io、aux、qkv0、qkv1、att_out与observed；这不是生产13口接口替换。内部只读入B1/S64 Decision0的真实QKV，通过生产parse、claim、full_write、cover、publish及4个typed任务完成head0/query0。observed导出64 score、64实际prob和64 AV，TB用实际prob独立重算AV，另比较全独立gold容差。末尾尝试完整ATT_OUT发布，必须因缺其余head/行覆盖而E_BUFFER。

当前配置不含可达生产controller，故其成功仅归D2-R的软件/后续局部RTL列，D2-I必须另建实际可达检查。后续head15/末行、Encoder RAW→RoPE、B2/S128及负例尚须扩展并逐项实测，不能由此首例推定完成。D2正式设计审核对应[精确合同快照](../../contract_snapshots/d2_reviewed_contract.md)；最新主合同的性能原型追加不改变此边界。

## v3诊断序列化范围

v2两次XSim触发8GiB/16GiB RSS守护，未完成事务。按[独立v3设计审核](../../reviewer_d2_r_depth_v3_design_review.json)，仅将AUX诊断depth改为128B、两QKV各10240064B、ATT_OUT4100B，fixture/io/observed不变。生产FullMemory字节容量和完整host数组保留；两QKV最大实际exclusive地址10240000后额外64B A5哨兵进入实际序列化范围。新源/TB只改变四个depth与新增哨兵，仍先CSim/csynth/setup及绑定审核，随后才有限RTL。

完整host数组不等于完整RTL回传。v3只对实际序列化的返回前缀作RTL验证，depth以上host初始化高尾不作为硬件未破坏证据；raw-TV独立核对与原C postcheck并行使用，证明边界见[results.md](results.md)。资源预算保持16GiB/192GiB可用/4CPU/30min/5e7cycles，不保证缩depth后一定能运行完成。


v3实现已冻结于[runs/depth_v3/source_freeze](../runs/depth_v3/source_freeze/snapshot_hashes.sha256)；CSim、局部csynth、cosim setup及xelab已完成，[实际生成绑定门禁](../../reviewer_d2_r_depth_v3_rtl_gate.json)曾放行一次受控XSim，现已因16GiB树RSS预算结束且无完成事务；实际资源/准备向量证据见[results.md](results.md)。运行门禁不增加数值RTL的已验证范围，仍需实际返回TV与独立数值审核。
