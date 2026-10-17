# WI0→GQD0：只读接点核查

2026-10-13；M004/SM005/E005/R001。此表只核当前已运行诊断与本项目现有RTL的接线条件，未生成或运行新连接。

| 接点 | 当前事实与后续验证条件 |
| --- | --- |
| Wi 写入 | AT028 writer op32、dst ref `0x0000000600000001`，在 `cfg_region_base[0]=0x100001000` 起按四行连续 20,992B/行写满 83,968B；1,312 AW/W/B 和独立 F32 gold 已过。当前配置 batch0、row0。 |
| 已有真实 Wi 读口 | `rtl/laya_wi_axi_reader_v1.sv` 当前 SHA256 `c09248fc14750a8d9fa23e2e0e2343b9bd1c047b81f44279e470105dd047c1f6` 与 E003/R003/`wi_axi_reader_03` 冻结源相同，原独立 AXI512/4KiB 切分/错误排空测试 PASS。它按 `region_base + batch*21495808 + row*20992` 发 AR，强制 source ref 类6、行步长20992B、批步长21495808B，并在真实 R 后按完整 identity/ref/row/index 提供标量及 row_done/debt。旧 PASS 未覆盖 AT028 同进程存储。 |
| 现有 GQD0 输入 | AT025 的 `gqd0_chain_tb_v1.sv` 从 `wi.mem` 直接驱动 `g_wi_valid/data/status/identity/ref/row/index`，没有实例化上述真实读口；它的 G producer context 是 batch1、row0=7，Wi ref同为类6。数值 fixture 与 Wi0 期望逐词相同，但这些坐标与 WI0 batch0/row0 不同，不能仅凭数据一致宣称生产身份衔接。 |
| 必需物理交接 | 同进程、链间无reset：Wi writer 实际 AW/W/WSTRB 修改唯一 Wi DDR 模型；实际最后 B、Wi 发布/lease 结束后由真实 `laya_wi_axi_reader_v1` 对同一地址发 AR/R；读回字节逐项与刚写数据和独立gold关联，reader 真实 valid/ready、row_done 与 debt 供 G 使用。不得用 `wi.mem` 回灌输入。 |
| 资源唯一性 | WI0 测试台和 GQD0 测试台各自包含 resident/strict W/KB1 writer；两者直接拼接会产生第二套矩阵引擎。WI0 的预填 dualA 与 GQD0 桥内量化 dualA 也各自存在；后续必须明确一个矩阵引擎分时 Wi→Down、原双槽 A/W 的唯一物理权威及 Wi 输入租约释放后 G 量化写入的顺序。 |

按原四行 fixture 的来源坐标，最小诊断身份应先统一 batch0/row0；或者主控给出有来源的实际 batch1/row7 fixture 与布局映射。改变 GQD0 现有诊断坐标会影响其身份/地址检查，需在下一阶段合同明确，不能把现有 AT025 当新坐标已通过。按当前 20992B 行大小，四行实读期望 1,312 个 AXI512 R beat；AR burst 数须由真实地址/4KiB 切分实测，不预签。

上述只是后续连接的可证伪入口。GATE、量化、Down 的原独立gold、末B/lease、发布和实际消费仍须在同一新冻结身份重验；Wi→G→Down 全冷周期也必须实际计量，不能相加 AT028 与 AT025。
