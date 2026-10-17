# 下一真实接点：QKV scratch到Encoder0 full RoPE的最小静态方案

2026-10-15；A001→A003；M004/SM004/E004/R001；接续`m004-qkv-norm-scratch-minimal-next-answer-20261015`。AT204冻结e5dde5cc…已在同runtime取得真实row0 cold/row1 warm QKV/norm完整写事务、第二行末B错误排空后完整FFN末残差done。主控核229项身份/105份产物/168条政策及原gold关联；正常主路径限定接纳，wrapper FFN直接错误完成与结果回显保护正在原合同内普通局部修复，不能提前签新身份。

请在原架构文档追加一套下一最小真实连接建议，暂不实现/运行EDA。优先核Encoder0 full RoPE的实际producer、算术叶子、sin/cos或角度来源、Q/K布局与V不变语义，以及从刚写好的scratch真实读、真实写回及B退休的具体接点。用源码决定复用哪一条已有路径，不新开算法或参数候选。

重点处理当前整请求边界：修订13tensor_raw_valid只有128行全部成功且最后outer done消费后才有效，现仅两行真实producer测试，不能填其余位、缩S或保存中间值冒充producer。RoPE按token是否完全独立、能否在请求保持隐藏时对已成功写完的行做内部读/变换/写回，再独立跟踪RAW/FINAL覆盖？若可行，指出最小必要接口和覆盖/失败/epoch变化；如果需要等全128，请如实给依赖与实测成本障碍，不破坏原发布合同。任何调度/发布变化由A001集中决定，当前没有修订14接口/预算。

核同request3/gen1/B1S128的原保存参考：row0/row1完整pre-RoPE Q/K/V与独立full RoPE各步骤/FINAL、scatter、norm是否足够；逐字节/整数布局关联，不做新浮点oracle或新gold。区分旧论文/源码语义、冻结参考身份和真实硬件覆盖。特别核row1位置因子、plane/head/pair配对及最后边界，避免只测位置0的退化情况；V和norm需保持真实未修改。

给出一个可证伪有限主场景及必要局部错误/写债短例，明确哪些工作能借当前真实两行producer完成、哪些仍需全128生产/Attention加载/mask。依据原有实测阶段成本及新读写工作量给估算的不确定性，不把字节比/150MHz当墙钟，不提前扩大缓存/通用owner/Host框架。

范围仅静态读取＋必要保存字节/整数脚本，累计≤60s、单次≤20s、RSS≤1GiB、CPU0–3/nice19/idle并计量；交互读取未统一采样仍UNKNOWN。无EDA/前向/新gold/新agent，不动E002/E004，不挪用工程RTL余额。仍由A002独占实现，A001定义正式后继接口/成本。直接回传一份原文档增量及证据路径即可，不需要用户转发。
