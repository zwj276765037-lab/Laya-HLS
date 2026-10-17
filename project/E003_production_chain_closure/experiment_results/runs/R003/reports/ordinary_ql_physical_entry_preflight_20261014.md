# 普通 Q/L 物理入口定向预核

M003/SM003/E003/R003；A002；2026-10-14。仅核现有合同、源码和旧收据；未修改 DUT，未运行工具，也未恢复暂停的生产控制排程。此表供后继有限合同选择，不是新 PASS。

| 接点 | 当前源码/证据 | 尚缺的物理证明 |
| --- | --- | --- |
| C 侧普通窗口 | `full_forward_controller.cpp:1235-1277` 每批按最多16行建 Q 和父 L，先由 `full_source_query` 取得该窗口 P，再预约 Q 与各 MATRIX view；`laya_full_owner.cpp:1101-1137` 要求来源记录已发布且所有窗口闭合。`source_provenance_06` 和 `portal_controller_25` 分别只签软件来源元数据及受控服务响应。 | 真实 typed producer 的写覆盖、末 B/END 与每窗口 P 的绑定，及这些 P 进入同一真实 Q/L 接受边沿。 |
| 物理来源 hub | `laya_generated_provenance_hub_v1.sv:349-355` 的 `source_owner_supported` 固定 layout0、F32、TOKEN row_space0、role6、全宽；`:367-406` 要求每个 END 自身为完整标准窗口。`:663-715` 的 query 又核已发布、窗口闭合、完整 P、model/Ref/K/布局和 generation。`generated_source_lease_05` 只覆盖 role6 的 B1/S64 四窗口受控 sideband。 | 多分量 ATT_OUT 的16 head、其他 BO role、MARKER/BATCH、旧 epoch，以及由实际 Q 的 AXI R 和返回排空驱动的 lease。不能由直接 query probe 代签。 |
| Q 地址解码 | `laya_gate_quant_portal_decode_v1.sv:110-135` 白名单包含 stage2/4 TOKEN 的 HIDDEN/NORM/ATT_OUT、stage2 GATE、stage4 DEC_FF、stage5 MARKER HEAD_WORK 和 stage6 BATCH HEAD_WORK；这里只是 Ref/shape/地址检查。原 `laya_memory_map.cpp:9-23` 映射 HIDDEN 为 STATE0/STATE1、NORM 为 STATE0、ATT_OUT 为 role12、GATE 为 role11、DEC_FF 为 role10、HEAD_WORK 为 STATE1。 | 解码可接受的普通来源集合明显大于物理 hub 目前能记账的集合；实际 BO role/base/span、源 producer、完整身份和 lease 必须对同一包一致核定。 |
| 已通过的有限桥 | `laya_lnq0_external_quant_admission_v1.sv:39-111` 将源锁为 STATE0+8MiB、4行、K1024、LN_FFN 0x12→QUANT 0x20→Wi 0x32，并在同边沿绑定 query/grant 与 bridge 接受；AT049 证明这个 enc0 四行链。 | 不能把该固定适配器称为普通多窗口、多 stage/role 或完整生产 caller。 |

2026-10-14 补核：此处旧建议中的“role6、NORM 窗口”混淆了 BO role 与 BufferRef。`Bo::STATE0=6` 是物理 BO role；`generated_source_lease_05/fixture/query_0..3.hex` 逐字段解码的 source_ref 是 **HIDDEN/id1、bank0、epoch100**，P opcode 为 `LN_EMB=0x10`，Q opcode0x20，K1024，四个 Q row0 分别为0/16/32/48。原 fixture 是受控 sideband 样本，不是已运行的 LN 物理 producer；不能据其四次 grant 宣称 NORM/id2 实接。普通 Q/L 首个真实样本应由主控在 HIDDEN/id1 与 NORM/id2 等原 Q 白名单来源中选择有真实 producer 写/最后B/END 的同身份窗口，明确 P/Ref 与物理 BO role6 的对应。随后各 Q 必须实际从已写 BO 读、保持/释放原窗口 lease，同一 A provenance 供父 L 的全部 view 和唯一退休使用。原 BO 容量、完整 model/generation、最后 B 与实际 R 债不缩减。ATT_OUT 多 head、跨 role、MARKER/BATCH、原地旧 epoch 和通用恢复为独立后继覆盖；实现顺序和接口由主控合同确定。

现行 `mission/M003_当前身份生产链接入与回归.md` 及 `mission/hardware_measurement_replan_20261013.md` 暂缓新生产控制生成；本预核未解除该停排。FFR0 AT053 正常局部残差结果与其错误码/语义进展缺口另行处理，不拼接为普通 Q/L 通过。
