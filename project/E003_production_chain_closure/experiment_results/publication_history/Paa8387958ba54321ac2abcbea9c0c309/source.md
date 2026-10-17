# E003：真实program有限分区与executor共享FSM

# Program真实生成/消费shell与executor共享FSM里程碑（2026-10-12）

范围M003/SM003/E003/R003；D-M003-GRAPH-LIFECYCLE-SPLIT-01。回复graph-program-consumption-host-review-20261012，继续原授权。

## 结论与真实覆盖

- `graph_program_hls_01`为PASS_SCOPED_GENERATION：原guard child0/trigger null，109.026356s、peak3379604KiB。实际syn/verilog目录73份Verilog/11份DAT；top的12根FIFO信号、ap_clk/ap_rst、cancel/result_consumed齐全，top无ap_ctrl_hs。六源编译闭包排除executor/adapter/旧execute_graph_action；Compile/Link9261，Unroll step1 18013/step4 14117。HLS资源估计BRAM18K3/DSP1/FF16819/LUT60478/URAM0；不当作联合资源、物理Fmax或完整请求性能。
- `graph_program_rtl_01`为PASS_SCOPED_RTL_PROGRAM_CONSUMER：同SHA实际HLS top、11份ROM DAT及四个真实depth2 FIFO。shell在同一LGR1消费端实际4次握手后保存通知，跨HLS多周期保持，并在下一accepted command首拍真实读取时清除。末2拍与末1拍停读各12周期、后继2拍已排队时，当前command_reads保持4拍边界、后继action写零增量、输出稳定；末拍消费后下一周期才开放FIFO出端。原contract的消费通知真实接线义务在这个有限program/受控LAC1范围取得证据。
- full同runtime处理901成功、902安全E_BUFFER、903坏magic零ordinal本地拒绝及904成功恢复；三份合法command完整结束、一次前置拒绝，逐字核LGP1/LAX1/LAC1/LGR1，全部四FIFO清空。并非真实Host请求、算术成功或typed退休证明。独立Python固定布局生成受控fixture，使用冻结模型tag，gold未取DUT输出。
- `task_lifecycle_fsm_host_02`为PASS_SCOPED_HOST：executor新增持久action/window cursor、共享有限Phase、逐拍24/16事务收发与核验；生产FSM12源闭包不含旧同步execute/dispatch/stream exchange树、adapter或外部codec。主机组合另外链接真实C++ adapter与受控远端服务，六例覆盖四窗口成功/4次退休、PUBLISH首错→同action同清理event非终态/终态INVALIDATE、本地取消后producer零外发/issued0/source readers0→同END键非终态/终态、非终态END后坏头/错event隔离无第三次END/不退休、非终态BEGIN保留真实软件reader和tracker。action完成后在抽象consumer确认前拒绝再次start。坏返回隔离不等于硬件安全恢复。

当前FSM host请求/模型有效和source READY由TB初始化；尚未实现accepted-request bootstrap、独立executor HLS top/action consumer RTL门控或真实program→executor→adapter→LN/hub生产链。B1/S64只是本次动态shape；完整PC/其他family、13BO、完整CPU/实际CSim和物理恢复仍待。



---
Published: 2026-10-12T12:56:13.765224+00:00
Publication: P23a9a5e99f914514845a8c6ed7f0d9c0
