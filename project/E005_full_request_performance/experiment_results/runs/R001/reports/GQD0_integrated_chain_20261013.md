# GQD0 四行真实 G→量化→KB1 Down 接链

2026-10-13；M004/SM005/E005/R001；`D-M004-GQD-INTEGRATION-01`。AT025为本阶段唯一完整normal样本，结论是**限定RTL数值/交接/周期PASS**；不是生产13BO、完整请求、物理资源或时序验收。

## 真实数据链及独立核对

同一仿真进程只在开头reset一次。测试台提供原四distinct行20992个Wi F32词、真实W/metadata及配置；G桥产生10496个GATE F32，物理GATE端口实际发生656 AW/W/B、15 AR/656 R，再由量化产生328组dualA。Down直接连接桥内唯一dualA的完整acquire/read/return/release口，真实读82次并释放一次；没有TB预量化A填入、q/scale回灌或第二份A存储。具体字段映射见 [连接表](GQD0_connection_map_20261013.md)。

GATE每个实际写拍的16个F32与原独立gate gold比较；每次量化半组的q/d/reciprocal及每组scale与原独立gold比较；Down每个真实A返回的四行q/scale及完整身份再次比较。原W严格加载、10496 stripes、335872 PS lane-group、512 TN8 packet及4096最终F32输出全部保留独立断言并通过。Down实际输出256 AW/W/B，16384B有效和物理W字节；末B后局部publication及一次真实done消费通过。GATE和Down为不同AXI端口，事务数没有混计。

## 周期边界

| 事件/区间 | AT025 cycles |
| --- | ---: |
| 全TB cycle0→最终零债务检查/结束 | 102660 |
| 真实G任务接受→Down实际done消费，25→102659 | 102634 |
| G任务接受→桥响应消费且A已ready，25→59403 | 59378 |
| W严格加载/验证，59404→86468 | 27064 |
| Down cfg接受→首次done有效，86469→102652 | 16183 |
| Down cfg接受→实际done消费，86469→102659 | 16190 |
| 最后PS→Down最后B，102509→102644 | 135 |
| Down最后B→首次done有效→实际消费 | 8＋7 |

真实Wi逐行完成标记在cycle5294、19454、33617、47780，分别观察到GATE已完成0、164、328、492笔B；cycle59403前全部656笔B、656拍重读及328量化组闭合。W在cycle86468发布，Down首AW/W在97717、末AW/W在102626、末B在102644，102652首次done有效，102659实际消费；原7拍完成反压和输出beat序号17＋beat%3 B响应策略保持。互斥Down状态合计16183，重叠stall见[原始log](../attempts/AT025_GQD0_chain_03/raw_full.log)，不可与区间相加。

两个测量口径需特别说明。继承的`DOWN_MEASURE_BOUNDARIES.A_fill_accept=23`采到了故意拒绝的G任务探针，**真实G接受是显式cycle25标记**；`A_publish_post_NBA=59403`在G响应被消费后采样，表示此时A已ready，早于此的确切A-bank发布边沿未单独记录。GATE首AW和末B没有逐边沿时间戳；据真实计数只能界定首笔W在cycle5294之后、19454之前，最后B在47780之后且不晚于59403。首AW可能早于首W，不能沿用W界限。这些界限不代作精确端点。冷TB的102660不能与旧独立G 59975及Down 43947直接相加或据差值宣称优化。

## 尝试、身份及成本

| 尝试 | 终态 | 依据 |
| --- | --- | --- |
| AT023 | static PASS；pilot COST_STOP | 120.341961s硬帽触发，尚无完整前缀/数值结论。 |
| AT024 | static与真实首行pilot PASS；full COST_STOP | full实际到第二行Wi完成；新进展标记未被原guard识别，127.533100s按semantic_stall停止。 |
| AT025 | static/pilot/full PASS | static81.608666s、pilot78.475066s、full747.161240s；full peak owned RSS1483444KiB、child0、trigger null。 |

AT025冻结清单80项逐SHA/bytes复核；G桥取本项目bridge04冻结源、Down取AT002 KB1冻结源，二者共同的`quant_dual_a_v1`同SHA，KB1 writer原样。G与Down的独立q/scale fixture同SHA，但最终数值由真实链验证，fixture只作比较。pilot仅到真实首行GATE 164 AW/W/B，未代签量化或Down；full启动前保守准入估计1117.692396s低于3600s，实际747.161240s。三段guard串行，CPU0–3/nice19/idle I/O、MemAvailable门及RSS/墙钟/120s语义保护保持。原始[收据](../attempts/AT025_GQD0_chain_03/receipt.json)、[清单](../attempts/AT025_GQD0_chain_03/input_manifest.json)及[复核JSON](GQD0_evidence_check_20261013.json)可独立复算。

本次只有有限诊断驱动和观察变化，无新增DUT逻辑状态；物理联合资源/Fmax仍UNKNOWN。晚错、活动reset、双任务重叠、全局恢复、完整13BO和生产唯一退休未测。KB1局部改进仍按原身份保留；GQD0只新增这条真实连接的冷样本，不关闭M003/M004。
