# 修订19共享LN服务阶段交付（AT307–325）

关联 D-M004-LN-SHARED-SERVICE-01 与 D-M004-REV19-AT315-01。修订19的生产抽取仍在实施，M004/SM004 保持 running/unassessed；本报告是成本与接口里程碑，不封存修订19余额，也不将局部测试升格为完整阶段验收。

## 当前生产身份与真实归属

当前 `laya_lnq_bank_service_v1.sv` SHA256 `63da9112d2a23583a652537f6ad45a84164eecce138abbb06345df567d08908e`，父core `laya_lnq_wi_gqdown_row_v1.sv` `8c799f91e4b436a78090161303efcb9cd84e69cf3f1791c4e6ed3c362e3f4667`，上层 `laya_source_norm_service_v1.sv` `c6ca8ca70322f4f0218bd3eec08b17c2d6e058071ccfc0e4d77f92551ef0acf6`，row wrapper `laya_qkv_scratch_row_v1.sv` `8294dc2f724b16f59937ecd0f885925eadd64295d2fc4db4eb9ec258009a1291`，sequencer `laya_qkv_s128_request_v1.sv` `a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4`。AT322 冻结真实父top展开这五项身份；AT323固定160µs父top前缀、AT324/325下层增量仿真沿用这些生产字节。AT325只改局部TB，未改生产RTL、FP/IP或gold。

下层现在拥有唯一LNQ与8×656×32bit final_bank、prep/token/gamma匹配、回放、LN_ONLY完整1024字norm保存、同步result视图与错误保持、release/done、Q16覆盖/窗口占有。父core的staged exec001入口为代理，legacy计算仍通过原LN_CMD/LN_WAIT路径访问同一下层；生产源码没有第二份LNQ或final_bank。上层已实际封装一套source reader、一套AUX reader和单writer及固定路由/覆盖寄存器，但其 `stage_clear/row_retire/store_fault/ready_commit` 仍由外部驱动。128行推进与16行store错误屏障仍在sequencer/wrapper，故**上层尚不是单一归属的独立LN128调度服务**。这一项是原合同待完成边界，不以TB模拟脉冲或强制bank idle代替。

## 同版已测范围

| 冻结尝试 | 原始结论 | 可接纳范围 |
|---|---|---|
| AT323 | 固定160µs真实父top前缀，child0/null，52.52832416258752s | row0在cycle15377退休；gamma256R、退休点source64R、1024个norm逐位W和64笔OKAY B。固定时间退出，无全次source总数、16行或请求完成结论。 |
| AT324 | 下层局部static38.39200748503208s、RTL30.23424639739096s，child0/null | 保存row0/1 norm交替16槽的Q16全窗4352字即时检查及最终复扫、512同步响应、r15最后输入停顿、partial ownership/abort/discard/新epoch；另以保存raw/gamma核LN_ONLY1024 norm、末tile响应保持、非法tile128的7/phase12完成保持。输入和owner由TB提供，未证明真实AXI上游16行。 |
| AT322 同SHA补测 | late raw RRESP 53.52802131511271s；last B drain 127.53202046081424s，均child0/null | 真实source晚RRESP排空后无reset新epoch恢复64B；真实末B错误后row1继续LN而B不增加，discard后epoch3 row0恢复64B。沿原AT317冻结错误TB的已编译同SHA生产闭包，非完整16行异常链。 |
| AT325 | 新局部TB static首个路径child127/0.17767055705189705s保留，正确路径32.054314862936735s；RTL30.925833882763982s child0/null | AT324局部Q16/LN检查仍通过；固定同步客户PS 16 lane、G x/gate各一次8lane读与同拍不同地址标量返回写、QD单字、ADD同步读与同拍标量写逐值通过。仅bank端口映射/采样时序，不代签matrix/G/ADD完整算术。 |

AT313首个Q16停顿TB Fatal即使child0仍为FAIL；AT317旧错误TB的语义守卫误停、AT319声明编译失败、AT320第三TB端口编译失败及AT325首次脚本路径child127均保留原guard和费用。AT321/AT320中间版局部通过不迁移为当前生产SHA结论；AT322当前父top三快照编译及AT323前缀才是当前父图依据。AT315历史里程碑报告将32.49943132698536s误配AT314 static；它实际为AT313，AT314 static为31.224050499498844s，原文件不改，本报告按原guard记账。

AT325增量编译日志明确重编局部TB并展开 `rev19_lower_ln_view_sim`。对AT324与AT325两份实际work库逐字SHA比较：下层bank service、LNQ leaf、上层source/norm、父core、原reader、原writer的六份SDB完全相同，局部TB SDB改变；AT325冻结manifest中对应生产源码也与当前工作树逐字相同。因此AT325仅继承同版已编译生产依赖，不把拷贝的旧数据库标签当新编译结论。

## 费用、缺口与下一最小边界

[逐guard账](SM004_rev19_guard_ledger_AT307_AT325_20261016.json)核 AT307–325 的19份manifest共2139个 frozen 条目，SHA/字节零不匹配；38笔原guard（17 static、21 RTL）与288条实际CPU0–3/nice19/idle政策样本零失配。static **1706.08185053430498095/1800s**，RTL **1473.825600214302521/3600s**；余额 **93.91814946569501905s / 2126.174399785697479s**，host准备完整累计UNKNOWN。AT325首次路径错误无有效RSS采样，不能记为已采样政策合规；其他记录按各原收据。没有HLS重综、OOC/P&R或新gold。

当前static余量低于已实测AT315父top展开133.11603546142578s和AT322三快照展开310.6376322116703s。上层调度归属迁移会改变父图生产字节，不能借用旧SDB宣称同版完整展开；本合同剩余静态帽也没有一次可靠父top构建及普通修复空间。因此尚未启动合法独立stage 16行pilot，也未取得16行实测成本门；真实LN128、NORM_STAGE_READY、父top同runtime 128行均 **NOT_RUN**，不能用AT323 row0或保存输入补位。此处不是数值FAIL。

下一最小可执行接口边界是把sequencer的128行循环/16行错误归并与wrapper的source/norm阶段控制迁到现上层，由旧父top只代理固定请求；保持当前唯一下层/reader/writer及所有真债路由。之后同一生产SHA分别构建父top与独立stage，先取真实16行pilot和成本估计，再依原合同条件决定LN128长例。还需定向实测真实共同reset、4KiB页界、相位pending/rsp及末B阻塞切换；旧分版证据不能拼作迁移后同版PASS。Q16父图、STEP16/matrix、全RoPE/FINAL→Attention、旧全请求首错等价、Host/HBM、物理BO与联合资源/Fmax仍开放。
