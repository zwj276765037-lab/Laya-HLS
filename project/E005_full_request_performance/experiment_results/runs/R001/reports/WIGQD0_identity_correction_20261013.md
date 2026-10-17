# WIGQD0 派生路径计数更正

工程此前的`WIGQD0_identity_audit_20261013.json`与阶段报告误写每版“60个不同冻结路径”。从AT029/030/031各自原`input_manifest.json`的102条`files[*].frozen.path`直接去重，正确数字均为**100**。已更正两份工程派生记录；本次重新逐一读取306条冻结引用，文件bytes和SHA均与原manifest相符。历史manifest、receipt、raw和已发送消息正文保持原样，错误仅影响工程报告中的去重计数，不改变数值/COST_STOP范围。

证据：[身份核对](WIGQD0_identity_audit_20261013.json)、[阶段报告](WIGQD0_bounded_stop_20261013.md)、[AT031原manifest](../attempts/AT031_WIGQD0_chain_03/input_manifest.json)。
