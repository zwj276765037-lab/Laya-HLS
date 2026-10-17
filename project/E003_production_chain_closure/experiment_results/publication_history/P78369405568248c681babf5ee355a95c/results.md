# E003：R003当前结果

`graph_sequencer_host_02`为PASS_SCOPED_HOST：20个生产源、55项冻结文件全部current/frozen一致，六个禁止的外部codec/exchange均未进入闭包；build+run 14.241875s。marker覆盖compute成功、stale completion flags清零、cleanup flag、未排空非终态、producer local reject、graph top和两条transaction FIFO/6根信号。manifest=`7821638bb603945bb122c0f0977721df3136397ef27092e7571ed784f5e183b7`，receipt=`783ba3f6d1a81d1e14d1be45169da293d219447eddc2dcb50efff38391d1b385`。

`controller_transaction_adapter_09`为PASS_SCOPED_HOST：49项冻结文件全部current/frozen一致，7条命令总用时10.174794s。C++ codec、独立Python byte oracle、adapter和sequencer-only codec通过；覆盖18根外部协议信号、partial response cancel、cancel local reject、cleanup END及4类rejected completion清零。manifest=`17d5adf55c2e7e1f55efc6d47fb73743d0f59aa5a5cb6ef4cee17196ae06054d`，receipt=`6002a91c477960097a0462591f256eb8a0d979784e68db3bdb2593fec4c3cfc5`。

`controller_transaction_adapter_07`保留FAIL：旧测试仍要求拒绝后的错误raw key可见，与completion整份清零安全规则冲突，进程exit -6；受影响测试修正为核可信flags/binding字段归零，未改协议、成功路径或工作量。`_08`及`graph_sequencer_host_01`保留登记更新前PASS身份。生产分区registry与模块design/results已同步。

本批未启动Vivado/HLS，不证明生成RTL、真实depth2并发反压、production AXI/store helper、adapter fence、完整请求、联合资源、时序或性能。

---
Published: 2026-10-12T04:34:29.449450+00:00
Publication: Pf7a29e53bf584d0596c2c56ef032df6c
