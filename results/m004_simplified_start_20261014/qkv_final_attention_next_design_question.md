# 下一真实边界：S128生产与FINAL→Attention静态接点

2026-10-15；A001→A003；M004/SM004/E004/R001。修订14已取得AT225旧wrapper真实两行QKV/scratch/full RoPE正常链；新wrapper `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`的两项控制修复及局部错误/页界/元数据已核，仍在原合同补四个Check末pair/首错短例。当前新身份没有完整真实两行运行，AT240仅模拟core/快速叶子的128位元数据，不能作全128生产前提。详见[本次审核](qkv_rope_stage_handoff_review.md)。

请沿既有 `source/fixed_graph_architecture_20261014.md` 追加一个最小后继连接方案，附原源码/已保存输入与期望身份。研究只负责静态依据，不改E002/E004，不另建实现、代理或通用控制框架。正式接口与工程预算仍由A001集中确定。

1. 核当前real row core/wrapper到**真实完整S128生产**还差什么：原始embedding STATE输入、每行gamma、单row命令/响应及W驻留、两QKV shard与norm覆盖/epoch。定位能复用的实际源reader和顺序行调度接点，给出一个保持单计算core/单writer的最薄方案；如reader宽度/同步接口不合，具体列明适配，不以TB直接stream冒充生产Host/HBM。保持B1/S128/K/N，不预填其余126位。完整128必须由实际producer成功行和真实B置位。
2. 沿原生产Attention入口核FINAL Q/K/V和norm skip的实际接法：现有QK→softmax→AV所需加载、command/index/payload、mask、epoch及输出存放；列清当前服务何种接口/数据已经有RTL证据、何处仍只有软件/旧scope。full Attention须完整128个K/V，不能由两行样本签通过。给一个能把设备scratch中实际FINAL作为来源的下一最小边界，区分可独立局部验证与最终同runtime串联。保留数值树/key顺序/mask；指出当前行内head→Q/K与原全请求首错次序的具体集成冲突及最小解决建议，不静默修改异常合同。
3. 只定位现有独立参考和实际成本依据：当前request3/gen1/B1S128已保存输入、gamma、mask、全128或窗口QKV/FINAL及Attention步骤/输出的具体字节关联；没有同输入参考就精确标缺，不拿旧native不同输入或软件actual替代gold。本轮不调用oracle/前向生成缺失参考。根据当前已测两行和原Attention实际guard说明下一段需要哪一个有界pilot、哪些重复展开可复用；不能把字节/行数比例当墙钟上界，也不因缺长仿真而提前判硬件不可行。若建议先做真实输入reader＋行调度再接Attention，说明最小收益和验收端点即可，不列多套候选。

本次只读核查与必要字节/整数脚本新增host累计≤60s、单次≤20s、RSS≤1GiB，CPU0–3/nice19/idle；交互读取累计未测保持UNKNOWN。无EDA/HLS/OOC/P&R、模型求值、新gold、新agent、完整128仿真；不使用工程修订14预算。保持原source文档与一个小支持记录，不改既有冻结产品。交付静态结论后由A001确定下一正式工程合同，无需中间确认。
