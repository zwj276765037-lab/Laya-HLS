# M003 F5、真实fence、来源切换与production HLS阻塞里程碑

交付ID：`production-source-switch-hls-blocker-20261012`  
范围：M003/SM003/E003/R003，当前普通source ledger、generated store monitor、共享G/QUANT/fullA实例及production Controller HLS生成入口。  
结论：F5标准窗口闭合、END早于首个AW时的真实fence、GATE→普通QUANT无复位切换在两个row-space/shape下取得限定PASS；production Controller完整HLS生成在当前单体profile达到13,223,459条Compile/Link instructions后连续三次真实停滞，成为C009生产generated master闭合的结构性阻塞。M003/M004总体状态不变。

## 当前实现与限定PASS

`laya_generated_provenance_hub_v1`修复F5：单全宽producer只有`rows == min(16, owner_end-row0)`才能关闭标准窗口。非尾rows1、四个稀疏单行及不足标准窗口的贡献均不能置完整位或发布整tensor；完整四个rows16仍能发布，并保持导致完整覆盖的真实P Context。

`laya_generated_provenance_axi_portal_v1`增加END issued-store bytes与真实观察WSTRB bytes守恒。END在写入尚未到达引脚时保持非终态，直到实际AW/W/B及显式adapter fence收束；`generated_store_monitor_07`覆盖END早于首AW、W-before-AW、末B、活动取消及恢复。

共享实例新增两项无复位切换运行：

- `gate_quant_source_switch_04`：先执行一行真实GEGLU/GATE并保留partial GATE owner，再执行stage6、role6/ref10、row-space2、K256普通QUANT。普通命令产生1个AR/16个R beat，检查8个fullA group；G路径保持6个WI AR/328个R、164个GATE AW/W/B及12周期末B反压。普通Q没有取得或消费GATE lease。
- `gate_quant_source_switch_b2_03`：同样先执行一行G，随后在同一实例执行B2/S64、batch1、row48、stage2、role6/ref1、row-space0、K1024、rows16普通QUANT。地址原点为`0x300431000`，实际16个AR/1024个R beat；检查128个四行fullA视图、全部16,384个INT8元素及512个FP16 scale。数值由八个独立冻结group跨四个group block和16行重复，不能表述为16,384个独立向量。

F5受影响入口`generated_source_lease_04`、`gate_quant_source_lease_04`，协议回归`generated_provenance_portal_16`，当前C++ Controller回归`portal_controller_31`均保留限定PASS。`portal_controller_32`冻结了后续已撤回的临时pragma源码，只是实验观察，不作为当前源码PASS；当前`full_forward_controller.cpp`已恢复到`portal_controller_31`及HLS `_05`身份，SHA256=`aabf451f828159d6f090e9d2d9ebfa72d8a4246071c90e9d3319b442c0ad5447`。

| attempt | 结果 | 关键数据 | manifest SHA256 | receipt SHA256 |
| --- | --- | --- | --- | --- |
| `generated_source_lease_04` | PASS | 26.835888s，1,495,776KiB；4个稀疏rows1拒绝、4个完整窗口发布 | `8cf46226b0f78395966e0386eac2071f501682fc18b6a180b3f707fae42dbad6` | `3f899bfe894b7d43fb76f980aa54ba3003b52f49b1cc50dd5230d81c838122ec` |
| `gate_quant_source_lease_04` | static/pilot PASS | 57.251185/12.554886s；4493cycles；16 AR/1024 R | `815166645ea9972e9517ae560e41561b7e7663cd4ba1b916d09a64166abf118e` | `dfe47ca33b65ab692e7be97ee9a4735f6c8da9b8627461bd2d2d9c91fac65ddf` |
| `generated_store_monitor_07` | PASS | 26.378370s，1,531,076KiB；END-before-first-AW与adapter fence | `1907ad16f7f809b30013ecbf7465c9b0d8118285f201d32218dabdabd7881326` | `87b78d76af87ae2b335bdfce1dfffbedf06b6d624d88f2dc05a0122cded0e8ca` |
| `generated_provenance_portal_16` | PASS | 26.581123s；148 accepted、152 retired、35 terminal | `ee481439e7c8ef1cc7a7c26f6d7a323b5b4c5bb117d0c53438dd9d97a059b0ca` | `9c64b8938e669bf7ed59ceea6c0fe4c3123ce1d8570f05835234c58e0f77a05f` |
| `portal_controller_31` | PASS | 当前C++ terminality/retirement回归 | `fc304513154cf641dd4300ae24db4754209df94f4f6adb6cbc6f723056914293` | `12033b85e4e8ab31deb7f652003bde54c9b002272d3dcd9ee84743ecc1f4d387` |
| `gate_quant_source_switch_04` | static/pilot PASS | 53.445391/21.776526s；12270cycles | `75f934579df5d06dbc0d541fec89f59863ef1bd6c15fa5458c349f9e9a4cda1d` | `787f4c8348d192d058e106e0e7333f87b2f83470df65d358782f23d9b41d891f` |
| `gate_quant_source_switch_b2_03` | static/pilot PASS | 54.103059/27.772653s；15889cycles | `526adc88803fe2f64463e1b92eb37ab4502e2c67ebef5fa21656169ed0cedf68` | `51852904ad5372efde2b57fa6c67a3d15f49a960900fd5683d07c7945c48885f` |
| `hls_artifact_progress_guard_01` | PASS | 不变/缩小不刷新，增长/新文件刷新 | `19bb07ccd17815806c6ecd3166e5690bbbf70f838e98ef7a042001a87a26e58d` | `6617371ab7697ebe0c0460f0132c45f5cdfe81062d64c4e63c56c246929d5761` |

核查记录：`production_source_switch_stage_20261012/verification.json`，SHA256=`2178c37ce652b9b70b9efb34b1fd7a3a9b2e5e23e337be7d0ee0bbe8db3f82d8`。八项当前限定PASS共有268组original/frozen pair，268/268当前、268/268冻结、268/268声明pair匹配；881项manifest引用中877匹配。四项差异均是较早运行直接引用的同一live `production_guard.py`，其后增加HLS artifact-progress检测；DUT/TB pair与所有冻结运行产物无差异。新guard分类已由独立冻结`hls_artifact_progress_guard_01`验证。

## Production HLS阻塞

入口`run_generated_production_controller_hls.py`已冻结递归include，使用CPU0–3、nice19、idle I/O、MemAvailable门、24GiB/1800s及120s语义停滞保护，并检查四个private FIFO的12个生成信号和八个可写m_axi bundle的AW/W/B。历史attempt全部保留：

1. `_01`为launcher打包错误，工具未启动。
2. `_02`发现blackbox私有头`laya_tm4_group_service.h`漏冻结。
3. `_03`发现跨目录`attention_service.h`漏冻结。
4. `_04`完整源码分析通过，Compile/Link后设计为13,223,459 instructions；旧guard只看日志，产物仍增长时误触发semantic stall。
5. `_05`加入artifact目录文件数/总字节高水位后，产物增长至约108MiB再真实停止120s，375.506907s触发semantic stall。当前production源码与该attempt的115/115 source pair完全一致。
6. `_06`的`#pragma HLS INLINE off`与`_07`的GNU `noinline`均未改变13,223,459条指令或停滞位置，分别380.544045s和375.533350s停止。两项临时pragma已撤回，失败身份保留。

七项HLS attempt的779/779 frozen文件与779/779声明pair匹配；769/779 live引用仍相同。十项live差异由入口/guard后续修正八项及已撤回pragma两项构成。`_05`当前身份全部匹配，因此阻塞不是由后续源码漂移推断。没有生成候选RTL、12信号或m_axi证据，C009 production generated master/adapter causal fence保持未闭合。禁止以相同profile继续无区分重跑。

## 保留失败与边界

来源切换`_01`错误使用A epoch2、`_02`诊断符号编译错误、`_03`虽功能PASS但derived fixture覆盖旧冻结记录造成两项manifest漂移；B2 `_01`缺BO role镜像、`_02`误用wire SOURCE_ROLE=1，均原样保留。最终有效证据为`gate_quant_source_switch_04`与`gate_quant_source_switch_b2_03`。

两项切换bench的source query grant仍由TB控制，不能代签同一runtime持久hub的完整身份准入。generated store monitor的物理写由TB驱动，不能代签production generated-HLS master实际store helper与adapter pending因果。row-space1、multi-role/QKV、LOAD、其余Q/L、matrix、L2/L3、当前完整CPU/实际CSim和完整请求仍待实现。

## 需要主控决定的结构边界

请主控判定是否允许在保持13BO、四private FIFO、portal wire v2、typed任务、数值和对外ABI不变的前提下，将当前13.2M-instruction单体production HLS生成闭包拆成可独立生成的Controller caller/shell与既有service模块边界，再在最终top连接并核12信号、m_axi、真实store计量/fence。若必须继续单一HLS top，请给出允许的替代结构方向；单纯重跑、加帽或重复inline pragma没有新证据。

不依赖该决定的row-space1、QKV、LOAD/其余Q/L和hub侧工作继续。L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成；本轮无OOC、P&R或上板，G余额不变。
