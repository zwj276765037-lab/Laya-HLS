# WIGQD1外部A与既有LQ0来源身份：只读接点补证

本补证未修改DUT、fixture或原AT032收据，也未运行新工具。AT028/WIGQD1的Wi输入源为原enc0 LN_FFN的batch0、row0–3，K1024；AT028的`source_manifest_local.json`记录四行源16,384B SHA256 `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`，与其记录的完整enc0 LN_FFN capture前16,384B逐字节相同。对应q 4,096B SHA256 `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`，scale 256B由同一Wi独立fixture提供。

AT014 LQ0的`fixture.json`明确producer为stage2/layer1 `LN_ATTN`、row0–15、D1024。与Wi所需前四行逐字节比较：源16,384B有14,496B不同，q 4,096B有3,964B不同，scale 256B有238B不同。因此LQ0的真实LN→Q store/re-read有限PASS可复用结构与验证方法，**不能当作此Wi四行的真实上游数值或同runtime交接证据**。下一连接需要对应enc0 LN_FFN的真实producer/量化窗口及当前完整P/Q/L/Ref/epoch来源证明；本文件不批准新阶段或重启已暂停的M003生产控制工具。

来源：[AT028 source manifest](../attempts/AT028_WI0_resident_03/work/fixtures/source_manifest_local.json)、[AT014 fixture identity](../attempts/AT014_LQ0_measurement_02/fixture/fixture.json)、[AT032冻结Wi A q](../attempts/AT032_WIGQD1_observation_01/work/fixtures/wi_a/q.mem)、[WIGQD1有限链报告](WIGQD1_observation_result_20261013.md)。原始二进制由上述manifest给出完整路径与SHA；比较只读且不把不同stage样本混用。
