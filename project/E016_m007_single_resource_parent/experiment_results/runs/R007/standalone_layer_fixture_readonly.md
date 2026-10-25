# 独立层入口/TB（只读，旧8b55/f4d）
生产ABI支持kind5/L0..27、kind6/L0/1。505e固定layer0和全部Encoder0中间gold，无LAYER参数；8b55仅接6/7，不能参数启动后续Encoder。最小缺口是合法BEGIN层号、上一层H整数打包及相应终点检查；不能沿用Encoder0中间gold。

Decision输入/期望齐全；但8b55:460给kind6也设qtype2/markers23,33/mask0003/count2，违反parent:1581要求非7全0；故当前exe不能仅参数合法启动。需普通TB修复并后继编译，不强state；runner终端也须由kind7改匹配kind6。独立样本不证明其前驱或一次BEGIN30层。

根R=project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/。输入R/<名>.f32.bin，524288B：
encoder_00_out=9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b
encoder_02_out=717132db6417ea942586a99441e98dd8fd03f808f38c26ae7d4160b0278e1e0c
type_add=9f1eb1d4a057d36454a5c23a6a7c682798a857f3b3b589fad59a193f34f11f67
decision_00_out=44ea5ccbea5e2cbcee8c5a4cc79ecadf31482798b5d71b5f301c393faeb90546
L>0输入encoder_(L-1)_out→期望encoder_L_out；Decision0:type_add→decision_00_out；1:decision_00_out→decision_01_out。全部原路径/完整SHA在本目录fullgraph_original_input_binding.json的original_checkpoints_47。已有AT044/work/fixture/decision{0,1}_input.hex及checkpoints.hex（索引30/31），精确路径/SHA见其products。

固定B1,S128,H1024,16head×64；QKV K1024/N3072、WO1024/1024。Encoder:L%3=0 full，否则sliding±64；均算128×128，区别mask/RoPE，不能按窗口比例估时；L0省preLN，后续多preLN。FFN Wi1024/5248→GEGLU2624→Down2624/1024，Wi/G/quant重叠。Decision无RoPE、full attention、2LN/2残差；带bias FC1 1024/4096与ReLU/quant重叠，A1=16384write/ACK后FC2 4096/1024，4矩阵，无GEGLU。依据parent:1706–1841/1931–34、layer_engine:1176、qk_av:519、TB:442–445/282。无运行/新gold/预算转移。
