# FFREF0 四行加法位型覆盖补证

2026-10-14；A002；只读解析 AT050 冻结二进制的 4096 个小端 F32 bit pattern，按指数/尾数/符号分类；各输入 SHA 与 AT050 原报告一致。没有再次运行参考模型、IP、HLS 或 RTL。

| AT050 文件 | SHA-256 | 正规正数 | 正规负数 | 次正规、±0、Inf、NaN |
| --- | --- | ---: | ---: | ---: |
| `output/enc0_skip_rows4.f32.bin` | `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9` | 2076 | 2020 | 全部0 |
| `output/enc0_down_rows4.f32.bin` | `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0` | 2100 | 1996 | 全部0 |
| `output/enc0_enc0_out_rows4.f32.bin` | `c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a` | 2094 | 2002 | 全部0 |

因此下一真实 RTL 四行逐位比较覆盖模型的这4096个正规数加法样本，但不能据此声称零符号、次正规输入/输出或全 IEEE 边界已经验证。若阶段合同需要这些边界，应在不改变原四行gold的前提下另设定向数值用例；CE/在途/背压同样需要独立检查。原 AT050 PASS_SCOPED_HOST_REFERENCE 和末残差 RTL NOT_RUN 状态不变。
