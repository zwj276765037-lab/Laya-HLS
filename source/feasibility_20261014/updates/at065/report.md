# AT065：诊断Fatal的计量边界与阶段C影响

2026-10-14；A003；M005/SM006/E006/R001。对应工程消息 `m005-at065-research-measurement-update-20261014`。本补充保持首版及AT063记录冻结，无v4参数变更、无整模预算重跑。

**AT065新增了Down准入四态未知的动态证据，仍未提供完整代表链服务时间。** 原driver在cycle358880记录Down W发布，物理R为20992/20992/2624、scale_checks83968；随后#1观察为`cfg_valid=1 cfg_ready=1`、`static_ok=x matrix_valid=x`，在3588801ns出现`Fatal: FFN0 Down candidate/owner claim not admitted`。guard虽为child0/trigger null，runner明确FAIL且无`FFN0_CHAIN_PASS`。不能仅凭退出码判通过，也不能把TB周期或时间单位当作布线频率。

冻结TB的`g_cfg_K`仅出现于第1768行`.gate_k(g_cfg_K)`连接；本轮核对该文件bytes/SHA与source_manifest对应条目吻合，动态Fatal路径也指向该冻结文件。这支持工程提出的未驱动K来源候选。未逐项排除其它操作数、未取得修正后的动态证据，故不签唯一根因或已修复。其它342条引用及完整runtime包的复核沿用A002报告，本轮没有冒称全部重验。AT063没有本次四态观察，仍保留其原semantic_stall判定，不追写为同一Fatal。

Down cfg→退休、末残差、完整gold/保护终扫和全链cycle仍UNKNOWN。候选同top normal/反压、联合综合和route依工程消息仍NOT_RUN。v4的150MHz/10GBps等条件及6.919–8.133s预算均未得到新物理或全链校准，也没有因该准入失败得到算术性能反例。继续维持“完成原授权正确性和物理取证、暂不扩大当前串行路线投入”的建议；本次失败不证明FPGA项目理论不可行。

核查输入10份，原路径、SHA、选定日志行及检查结果见 [input_manifest.json](input_manifest.json)、[audit.json](audit.json)。三个首版审核SHA锚点不变。新增H008仅0.053285s，exit0，无分析guard trigger；A003累计H001–H008为3.266915s。极短作业只有一次RSS采样，不作为完整峰值；实际采样和child rusage见 [H008回执](../../host_runs/H008.json)，idle I/O独立采样仍UNKNOWN。未运行EDA、参考前向、GPU或新增实现。
