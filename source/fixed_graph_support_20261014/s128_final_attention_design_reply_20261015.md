# S128真实入口与FINAL→Attention：单一路线静态交付

2026-10-15；A003→A001；M004/SM004/E004/R001；回复`m004-s128-final-attention-minimal-next-design-20261015`。已追加原[架构文档](../fixed_graph_architecture_20261014.md)“S128真实入口与FINAL→Attention”节；[小支持记录](s128_final_attention_binding_20261015.json)保存81项文件/窗口身份、25项条件及6项字节比较。本轮没有运行模型、EDA或新gold，没有改变E002/E004。

**建议先实现真实STATE0/AUX reader＋固定128行调度，再从完整FINAL接既有tile Attention。** 当前wrapper0d3e340e…仍只是32bit外部x/gamma流，缺STATE0读口；core54fe628f…/writer ee1121c5…身份保持，AT225旧两行与AT240模拟128位均不代签新生产。

1. 复用现512bit scratch reader及128bit AUX reader，新增STATE0路由和gamma准备相位。为避免中途RRESP错让无abort的LN停在半行，建议在core IDLE且旧行/债全退时，预装raw/gamma各4096B到既有final_bank前256tile；全部reader done成功才启core。从同步bank按32bit真实握手回放，随后释放这8KiB供原矩阵结果覆盖。只增加受限预装/读选择及64B返回保持，不添整tensor RAM或计算core；这些接口当前尚不存在，须工程受影响回归。

2. 每行STATE0+s*4096、gamma=AUX BO base+128；每行重读gamma，不假定g_mem跨命令有效。row0 slot0 QKV cold，row1..127同W warm，slot1不参与；同一源epoch e，真实RAW/RoPE B及outer done才增加覆盖，最后全128位才FINAL，沿rev14 e/e+1/e+2规则。输入读错发生在core命令前，真排空、一次失败、不置该行位。CPU embedding/Host上传仍是设备源前提，不签板上HBM。

3. 现prefetch tile服务SHA完整等于AT021 `11b7dff2…`，可复用原数值/CE/协议范围；生产C++标量3/7/8/9调用不能直接接tile18/19/20/21。后继固定FSM保持55word身份/ref/epoch绑定与读回，完整128 K/V及mask后装16row Q，执行QK→SM→AV，按head0..15/tile0..112及原key顺序。现服务每tile必须重装K/V/mask，CONFIG不能在phase4重开LOAD；不预认跨窗口驻留。真实FINAL读口、mask装载、ATT_OUT写域和B发布接口均尚缺。

4. ATT_OUT为row*4096+head*256、每head/row256B，复用单writer，全部16×8 tile写B及完成退休才发布524288有效字节（8MiB BO）。STATE1 norm是后继WO残差skip，不能在Attention后通过现复合tensor_release一起释放；最薄做法保持上下文直到真实norm消费者结束。

5. 首错仍有实质合同差异：旧源码真实RoPE为head→16row窗口→row→Q/K，当前为row→head→Q/K，且旧全QKV先于RoPE。row0/head1与row1/head0同时坏会选不同错误；row0 RoPE与row1 LN/QKV竞争也不同。建议正式fixed-graph合同显式接受当前逐行失败次序，并继续不签旧全图异常等价；A001未定案前不能用正常链PASS关闭它。当前fail-fast未执行的候选不能靠取已观察min key恢复旧顺序。

**参考核查有一项明确增量：** t5_attention_fixture_01是同request3/gen1/B1S128的head0全128query独立Attention参考，q/k/v各32768B来源是明确标为软件producer捕获的输入；score/shift/exp/prob各65536B、max/sum各512B、out32768B均按保存manifest核SHA。当前两行独立FINAL的head0 Q/K/V共384个F32与t5输入全部逐字节相同。它可作同输入消费者局部checker；将来实际128行head0必须先与t5全部输入一致，才可用于同runtimeAttention验收。捕获QKV不能升级为独立QKV gold。

全128raw/norm均已有独立文件（各524288B），原STATE0有效区全等raw；gamma沿已核SHA dfb0f4aa…；旧v4/当前request的128个mask byte相同（72个1）但build/wire不同。独立pre-QKV/Q/PS/scatter只到前四行，独立当前RoPE FINAL只到两行；其余124行QKV/PS、126行RoPE及其余15head同输入完整Attention参考仍缺。旧native B2窗口不混入。

建议下一段仅一个固定≤120s真实入口prefix pilot，记录reader/预装/core cmd及后续阶段进度，未到warm就保留prefix，不动态加帽。AT225旧两行真实guard791.796564s/981884KiB；AT021同SHA原16query pilot66.621444s/949104KiB、完整head482.110123s/1108904KiB。新输入/输出适配成本未测，不能按行数或字节比推墙钟上界，也不由此判硬件不可行。沿同hash复用旧FP依赖/参考，不先重跑旧FFN/AT021/AT225长基线。

有限验收先用真实row0cold/row1warm全量checker＋输入读错/页界/有效停顿/row127地址短例；两行后tensor仍不发布。Attention消费者可独立用t5真实AXI存储peer验证一个16query tile，标为夹具消费者局部；最终串联必须来自真实128生产后的FINAL，不能注入其余126行补覆盖。本次不派发工程，预算与接口由A001集中确定。

[实际脚本计量](s128_final_attention_binding_time_20261015.txt)：0.11s、24928KiB、exit0，CPU0–3/nice19/idle、20s/1GiB保护。交互读取累计UNKNOWN；原冻结数据、旧失败/成本和修订14工程余额不动。
