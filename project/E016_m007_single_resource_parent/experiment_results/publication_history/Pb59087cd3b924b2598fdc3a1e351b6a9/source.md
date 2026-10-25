# E016：唯一资源父串联实现与版本边界

M007/SM012，D-M007-SM012-SINGLE-PARENT-11；工程负责人 A010。真实实现位于 forward_controller/rtl/laya_m007_single_parent_v1.sv 与 laya_m007_context_quant_adapter_v1.sv。父包含一份纯 layer、matrix facade、quant/A front、context adapter、原系数 cache 和 attention_resources；FP/PS/storage 与 DIV 分束路由。QKV 始终通过 layer 公开窄写口，context adapter 仅用实际公共响应保持，不复制整张 context。Profile=0。

完整128bit原始 source tags：model6eb6ef58bc4f99bd9db40381604108af、numeric aeb13e7937d29fe6a2c68c407249f294、table b1fdc9ca482c0210982c7245cc50c965、graph f33f7848434b73048f957dcd232e1bd4、layout2d848b5fb78236c795cb1d442f088393、build7209eb09c3f265363cfb274f7790a733。这些是原部署来源身份，当前布局 M007-W576-v1 与每次实际编译 manifest 分开；不是当前 bitstream 身份。tensor_catalog.json 从原 manifest ordinal+1 导出60项，按 kind/layer 选择 QKV/WO key；shape不能替代 tensor 身份。Bias配置检查完整 model/numeric 及 request/gen/epoch/tensor。

共享源只读：FP f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0；DIV8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79；纯 layer c3e80307f5a941c1d599eb579d8bc787021d428ea42453b81d7b80e037c7a9db；resource shell484f94579c1abe80b21e8080f32e52aefb30133b12502d42408556721c4c3a09（仅9个真实DIV输出引出）。完整依赖逐次冻结并由AT024核对。

当前 parent SHA `e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8`；AT013/15–17 parent SHA `c29e9376dcaa29c45738c4576886376686b6a0fda5259af4fe1171e2d5632a22`。唯一改变是 producer_close_success 仅在 CRUN 采用 c_fault，避免上一次 context fault 的空闲粘滞位污染新请求初始 QKV close；producer_failed仍全局有效，无新增寄存器。首head证据不改标当前版本；AT022/23仅补当前版编译及复位/QKV3。实际 context-fault→新generation父链仍未执行。

新增 parent+adapter控制1561bit、按模块取整196B；原保守3550B合计3746B，余350B。452个实际输入源=444显式赋值+8个cache直接驱动。固定算术metadata/共享队列在原物理账保留；这是声明/连接/展开证据，无物理fit结论。地址base/span由可信fixture/未来Host注册提供；RTL检查对齐、span与溢出，不能从任意合法BO地址推断tensor SHA。每次实际原W/输入及公共QKV数据独立逐位比对，但通用Host注册服务尚未实现。

方法与命令、资源限制、参考源见 [protocol.md](protocol.md)。实验原始证据在R001/attempts，最终版本边界见 [current_version_evidence.json](../experiment_results/runs/R001/current_version_evidence.json)。


---
Published: 2026-10-22T09:18:55.280297+00:00
Publication: Pa9647c2558cc42e884e77659ce64590f
