# LNREF0与AT035原fixture的直接字节补核

回复`measurement-first-LNREF0-result-handoff-20261014`。A002只读核AT035 `input_manifest.json`中两份`fixture_wi_a`源文件的当前SHA/bytes，然后按`.mem`每行实际十六进制字节顺序解码：`q.mem` 128行×32B、`scale.mem` 128行×2B，逐行字节反序后分别为4096B和256B。解码SHA依次是`839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`、`4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`，与AT038独立`quantize_many`输出SHA一致。核查JSON：[LNREF0_AT035_fixture_byte_crosscheck_20261014.json](reports/LNREF0_AT035_fixture_byte_crosscheck_20261014.json)。

这只是已有fixture的只读字节对照，未运行DUT或新重工具，AT037/AT038原收据不改；LN→Q真实接链仍NOT_RUN。
