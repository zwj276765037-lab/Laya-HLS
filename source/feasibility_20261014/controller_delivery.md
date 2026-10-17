# M005阶段C第一份实质研究交付

回复 `m005-feasibility-research-dispatch-20261014`。A003已完成第一版可复算分析并收到A002容量答复；未等待AT063结束，未运行EDA/GPU/参考前向或新代理。

主报告：`source/feasibility_20261014/report.md`；正式数据：`source/feasibility_20261014/v4/`（budget.json、matrices.csv、operations.csv、traffic.csv、scenarios.csv、serial_timeline…csv、input_manifest.json）；脚本和实际host回执在同目录。

1. 当前production-v2 B1/S128帧SHA `87fc82b1…`及四tags已核，五payload与AT038独立输入相同：72有效token、16 scorer槽但仅2有效候选。122次Q8完整源图为47,160,754,688 MAC；Attention QK/AV各503,316,480 FP MAC、LN 8,011,776元素、残差7,864,320元素等已分别列入。未将源图调用数写成RTL实测。
2. 150MHz/10GBps/未测速率显式假设的串行服务预算：跨128行W复用约6.919s，仅四行复用约8.133s；100MHz为10.359–11.573s，200MHz为5.199–6.413s。不是实际整模性能或有保证区间，host/完整控制与布线频率仍UNKNOWN；单request slot下条件II=L，未把最大单级耗时当当前流水吞吐。
3. 主要风险是LN约2.20s、Attention1.86s、残差1.32s（150MHz），matrix仅0.638s；只把matrix快10倍的整模条件收益约1.09×。一次Q8权重392.45MB之外还有约651.61MB建模外部流量；丢失跨窗口复用时Q8＋bias加载可达12.53GB/请求。
4. 修正了一个易重计的边界：AT049“G cfg→最终consume”103979cycle含Q/Down LOAD/Down；真正G→最后GATE B为57993。细分区间严格还原同runtime375074cycle；AT054残差仍单列，未拼成新链PASS。
5. 独立建议：完成已授权代表核A/B物理证据，但不扩大当前串行路线的大规模投入；先评估LN/残差吞吐结构。旧LQ1/LQ1R时序问题已纳入，不能把低cycle候选直接按150MHz使用。无匹配CPU/GPU对照，不宣称优于GPU；当前架构吸引力不足证据≠项目理论不可行。

40份输入快照SHA核验及独立重放一致，962个Q窗口/3845个matrix view容量/顺序检查通过。受控分析H001–H006累计3.1602s，峰采样RSS47100KiB；I/O实际采样缺失如实记UNKNOWN。完整报告保留所有参数、限制及下一步证据需求。后续A002新计量/资源/route到达后可直接替换参数，本报告不关闭M005/M004。
