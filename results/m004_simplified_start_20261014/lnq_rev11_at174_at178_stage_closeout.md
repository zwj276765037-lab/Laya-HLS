# 修订11 AT174–178 阶段交付：短探针与成本出口

M004/SM004/E004/R001；A002→A001；2026-10-15。回复 m004-at173-scoped-evidence-short-probe-decision-20261015。AT173原整次FAIL和其Fatal前主控限定接纳均不改。

- AT174 AUX_STALL_PROBE_PASS：真实首个AUX ARVALID下ARREADY连续两拍低，2次阻塞、1次真实AR、8次R，Wi slot0 LOAD_DONE；static128.378862s、RTL129.358357s，child0/null。只签AUX冷载短探针。
- AT175 AXI_INFLIGHT_RESET_PROBE_PASS：真实W q0首AR已接受、R0/64/left64时共同reset DUT与总线模型；510拍无旧AR/R、行、done或债务；下一cmd真实slot0 cold重载完成，三W口AR656/656/82、R41984/41984/5248，AUX AR/R1/8。static127.566341s、RTL129.176531s，child0/null。只签该AXI边界及重冷载，不签复位后完整FFN。
- AT176外部Wi末scale half +Inf在cache LOAD先行拒绝，LOAD_DONE error1/status7/phase0/bad167935，Wi PS0；原终态FAIL_PROBE_NOT_REACH_FRONT，static127.064749s、RTL120.644968s。
- AT177拟在真实末W返回单half注入，但group0/tile0首次W返回已触发TB W_BANK_MISMATCH，注入点未到；原终态FAIL_TB_BEFORE_INJECTION，static126.962831s、RTL206.639684s。
- AT178拟在真实末组front issue前注入已锁存的单个F32 scale，原normal gold不变；450.400088s真实墙钟timeout，停于约cycle115000/group21、已核前缀约13779个Wi PS，末组注入未到；COST_STOP_TIMEOUT，static126.665515s。不能推断状态6、poison传播、首错或排空。

AT174–178各95项冻结文件逐bytes/SHA零差异，合计95条实际CPU/nice/idle政策检查全匹配；当前顶层RTL均SHA92941815b70e58df6f6d27edb988e9d318abfe566dda5f588775480c00dcd463，23份fixture与AT173相同。RSS在24/8GiB帽下，最低MemAvailable超过192GiB。AT173局部残差和Fatal前完整cold/warm、两算术在途共同reset、标签错分项仍按主控已签范围；整体依然FAIL_TB_AUX_STALL_COVERAGE_ZERO。AT174只补AUX AR覆盖，不回写AT173原FAIL。

原AT170–173账加AT174–178后，修订11累计static1142.969832/1800s，RTL4724.407606/4800s，余75.592394s。真实cold至Wi数值末组远超余量，停止新长仿真，不重置旧账。host准备仅部分自采样，完整总量UNKNOWN。Wi/Down bad/poison状态6与协议7区分、内部主动反压、部分R后reset仍NOT_RUN；完整图及本顶层联合资源/时序未知。

权威逐项报告：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md。E002模块source/results.md与E004三份摘要已更新；五次原guard/log/manifest留各自AT目录。请主控按实际证据收束本修订并决定后续固定图连接，不将局部短测升级为完整硬件PASS。
