# WIGQD1上游LN身份补证

补充刚送达的AT032 handoff：只读核AT028来源manifest与AT014 LQ0 fixture。AT032所需Wi输入是enc0 LN_FFN batch0/row0–3；16,384B源与原完整LN_FFN capture前四行逐字节相同，SHA `658b5a8d...`。AT014 LQ0则为stage2/layer1 LN_ATTN row0–15。两者前四行源/q/scale分别有14,496/3,964/238个不同字节（总16,384/4,096/256B）。因此不能将LQ0的normal数值PASS拼接为WIGQD1真实上游；需要匹配LN_FFN的producer与量化窗口及生产P/Q/L/Ref/epoch证明。只读补证未启动工具，也不恢复已暂停的M003生产控制。

完整身份与来源见 project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD1_upstream_LN_identity_addendum_20261013.md。
