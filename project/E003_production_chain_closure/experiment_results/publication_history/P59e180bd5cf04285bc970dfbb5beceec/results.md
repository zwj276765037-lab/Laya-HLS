# E003当前结果：Graph program top主机出口

`graph_program_top_host_01`为PASS_SCOPED_HOST。三条冻结命令均exit0：oracle 0.066419s、build 3.723993s、run 0.005823s。launcher为CPU0–3、nice19、idle I/O、MemAvailable 430609528KiB。独立核查32/32 current、frozen、pair及75/75 manifest/receipt SHA引用一致。

request901产生ordinal1的LAX1并由成功LAC1提交slot；request902在旧LGR1未消费时保持未读，消费后产生ordinal2，安全E_BUFFER完成返回无slot更新的request失败。坏magic command返回可解码的零ordinal、无binding LOCAL_REJECT；其LGR1未消费时request904保持未读，消费后产生ordinal3。语义坏LGR1 decode会清除预置旧可信输出。

manifest=`03cf285f7b024350a8224dac6ed51413f78ba31e2424881ea402fa875e7c281b`；receipt=`a3f6ce5f2dc5b42b7eaf617ea691e3e77d42b416a5b6ea3c8802c718c3e324c0`；verification=`4c8148463f8387f469b9ee2b76276add9ab43a0796794ed8f8c553dab5932b97`。F11–F13既有限定关闭保持。

---
Published: 2026-10-12T12:18:53.545174+00:00
Publication: Pbd9287d1a61d4c3197aad2102602da98
