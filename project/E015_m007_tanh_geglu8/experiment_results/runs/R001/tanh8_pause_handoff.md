# E015 / TANH-G8-08 暂停交接

execution_state: paused  
verdict: unassessed（E015整体）  
用户“按此收尾后暂停”由A001实际消息转达；当前八lane收尾结束后不再启动G、父级、新OOC或后继。A001 increment44已集中核对并接纳八lane限定功能范围。

AT055八lane全336262主输入（335872真实z、384边界、6非finite），42033向量、14123004主节点逐位通过；接受到实际消费153拍、每lane II1。含协议探测共338828标量消费/14231096节点，256向量满信用、flight152、held298、6种拒绝、真实17向量在途reset后64新generation向量、6错误加2masked、外部释放债屏障通过。child107.642217563秒，peak sampled RSS839737344B，86条真实推进、最长guard观测间隔8.414037240秒，owned后代/进程组零残留。

当前实际编译AT052 manifest SHA4c5b6f70579f53890d75342ce4b0b4007b1cdbc1d1e82779aef364cb3e3384ac，driver SHAa739bd6cd635a6bfe935f5890550300e2b2aace9a8e6d23e88109bd7fade1202；原152edge core+add3_e/mul4/radix4div12，恰8core+1只读vector credit。guard v3预冻结SHAc6e61e709cab196edc9386fc3c0e64dcc61fd612bcd33fabd99a53e31453e294，启动与取锁一致；AT054实际同版成本界212.7640610175秒≤300秒。全部细节及逐证据SHA见release_evidence_v1.json。

| 独立预算 | 实费秒 | 封存未转移余量秒 |
| --- | ---: | ---: |
| reference | 3.55856469200807616 | 896.44143530799192384 |
| static | 77.62085169812780926 | 1722.37914830187219074 |
| rtl | 509.154911202058440 | 2490.845088797941560 |
| ooc | 776.07547476305626 | 1023.92452523694374 |

所有53笔有收据尝试已终态；AT015等待时取消未启动/零费用，AT034从未启动。pause_budget_and_process_audit.json核当前选源匹配编译、无未终态收据/active owned guard；最后实际cleanup无后代及进程组。

小leaf OOC仅综合+opt：add3_e AT044 setup+0.098ns、527LUT/208FF/0DSP；mul4+0.332ns、div12_radix4+0.182ns。全部hold仍失败（add3_e−0.043ns/78端点），无P&R、物理300MHz、八laneOOC或联合资源/4KiB通过。SFU tag/mask真实26624bit/3328B、available256bit及其他metadata/算术流水位另计；未来A007必须复用EXP/TANH单一信用/lease，不能并入两个完整壳。

保留失败与身份边界：AT051原计数FAIL未改；AT052修复TB组合ready采样并加main精确接受/消费/节点及17向量reset断言，AT053/055实际验证。AT040是旧add3_z全单lane，AT049是当前add3_e全单lane，不互相升级。旧AT008–013 guard exact self-SHA UNKNOWN；AT048自由scope旧名按cost_scope_metadata_note.md说明，原件不改。

恢复入口：只有用户明确恢复后，先读取本交接、release_evidence_v1.json和SM011 TANH-G8-08现行合同，再由A001确认接续。当前rtl/laya_m007_g_pairs_v1.sv与tb/m007_g_pairs_tb.sv是暂停前写入的未编译草稿，已另存uncompiled_g_preparation.tar.gz；没有G attempt/实际进程，也没有纯G算术engine、全rank、335872 G输出、Wi/Down交叠或新gen恢复验证。恢复时不得从这些草稿推导PASS或直接启动长全链。接口代码保留，父级接线和联合SFU尚未实施。

E014历史交付保持冻结，本阶段不改其证据；期望gpt-6.1-sol/xhigh，实际配置未核实，runtime为/root/m007_host_tail_engineering、thread_id为空。
