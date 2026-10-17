# 两行RoPE独立派生参考交付

2026-10-15；A003→A001；M004/SM004/E004/R001。回复`m004-qkv-rope-bounded-reference-preparation-20261015`，执行D-M004-ROPE-REFERENCE-01。已完成指定两行求值与保存证据，状态`PASS_DERIVED_ROPE_REFERENCE_ROWS01_PENDING_CONTROLLER_REVIEW`；请由主控独立核验后冻结为后继checker。本轮不构成修订14工程放行。

产物与全部身份：[run01/manifest.json](run01/manifest.json)（SHA256 `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2`）。原架构已追加“两行full RoPE派生参考补齐”；完整父文件、调用脚本副本、输入窗口和旧expected均在run01内冻结，原参考/工程fixture未修改。

完整父oracle SHA256 **`fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`**，35233B，来自`source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py`；与E002 `tests/full_reference.py`逐字节相同。父函数未改，调用脚本SHA `dee53cc921b610666455decfdd40ff39b184d536267118607919c4708176c39d`。Python3.12.3、NumPy1.26.4、little endian、六项线程环境为1；实际调用仅rope_head68次、rope_qkv_many2次及原mul/sub/add/_array/_finite，完整计数及函数源码SHA在manifest。未导入DUT或生产算术，未调用full_forward、矩阵/LN、Attention、三角函数生成。

校准在当前输入求值前完成：

- 原s0h0/s127h15 Q/K四例共256 F32与保存expected逐bit零差异，P2原输入/expected与D2文件逐字相同。
- 额外求旧native row0/row1，共6144 FINAL F32与保存full_final窗口零差异，SHA同为`3776f09957151bbbc1b01fe7c248e4c81a2689e7143b285f3203aadf30f61757`。
- 原model GGUF身份`6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`由P2报告和当前模型包头绑定；本轮不重哈希整GGUF，但完整AUX full cos/sin表SHA与P2出处一致，实际s0/s1输入窗口重新冻结核验。

当前输入严格为task2_real_fixture_20的qkv_rows4_output字节0:24576（row0/row1），原AUX offsets617728/880128各512B（s0/s1完整64项）；manifest记录所有父文件SHA、offset/shape/endian。B1/S128/request3/gen1不变，函数[1,2,3072]只表示两个已指定token的求值窗口。

新FINAL均为[plane Q,K,V][head16][d64]、little-endian F32/C序，每行12288B：

- [row0_full_FINAL.f32.bin](run01/products/row0_full_FINAL.f32.bin)：`d4d1b006b7d46e84fc13c431cd781b930d871149382a68a37cd81377ad7aee1b`
- [row1_full_FINAL.f32.bin](run01/products/row1_full_FINAL.f32.bin)：`f4fa2f826ab8f9202f5f589ae531e84956700c5a154ef600320592e8cab09def`

两行各2048 Q/K为独立RoPE计算，原1024 V逐字节保留。64次rope_head与rope_qkv_many全部6144项逐bit相同，仅为同父oracle内部核查，不称第二独立oracle。row0全3072项恒等；row1非退化，原绑定39pair/78项与旧独立FINAL零差异；全部FINAL finite。

六字段诊断每行[2plane,16head,32pair,6field]，字段顺序`a,b,lower,c,d,upper`，各24576B；只调用原mul/sub/add helper并保持非FMA：

- [row0_steps_ab_lower_cd_upper.f32.bin](run01/products/row0_steps_ab_lower_cd_upper.f32.bin)：`83f8d65e80b2d25b2bd2bd7e8ab70cd844ba405b8ef07e869fa034edb8e6a49a`
- [row1_steps_ab_lower_cd_upper.f32.bin](run01/products/row1_steps_ab_lower_cd_upper.f32.bin)：`b302ef836641eb1f9d433d31b156acf63a2579530d3e587fff2ff948a12c756e`

全部步骤finite，lower/upper与4096个Q/K FINAL元素对应一致。norm只复制，run01/products内两份norm仍为原SHA `f166773b57757ff552823c69315b133ea715b9c49f141849cc925b62c37b6d12`、`cf4dd5c60fbfa0cfb83b5cc2e8e934ce397830cf1a73906fb4d2a38aed740065`，每行4096B。

run01共363项条件成立；[artifact_verification.json](run01/artifact_verification.json)额外以纯字节/整数核60项原始/冻结/产物身份及诊断布局，所有原始文件未变。参考求值[time](run01_time.txt)0.35s/48376KiB，落盘核验[time](verify_time.txt)0.06s/22904KiB；新增host参考/核验累计0.41s，各exit0、单次20s/1GiB、CPU0–3/nice19/idle。上一静态1.30s单列保留，交互读取UNKNOWN。

指定两行完整数值参考缺口已补齐；此前78项仅是历史可复用子集，后继可在主控冻结新派生输入后核全部两行FINAL/步骤。仍不证明RTL连接、Check错误ABI或异常首错次序、完整128行生产/发布、Attention或物理性能。无EDA/HLS/RTL/OOC/P&R、完整模型前向、新agent，未改E002/E004或修订13预算。
