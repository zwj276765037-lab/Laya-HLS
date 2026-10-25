# E015：TANH-G8-08来源与方法

授权SM011 D-M007-SM011-TANH-G8-08。A008仅拥有vector_and_ffn新M007实现/source增量与E015证据；原canonical/gold、A007共享FP/DIV/EXP/storage和A010矩阵只读。原glibc42节点23add/17mul/2div及每次独立F32舍入、分支、常量保持。独立native SSE/RNE/FTZ0/DAZ0原运算向量；原B1 Encoder0全部128行WO→残差→LN→Wi参考，335872真实z、384边界、6非finite。AT018独立42节点参考最终全等原host libm。

当前原DAG152edge、add3_e/mul4/radix4 direct-div12，真实3/4/12拍II1；单lane先于8lane。八lane恰8core+一份只读shared vector_credit，mode1/phase1、96bit tag/mask及完整request/gen/epoch。小leaf OOC为Vivado2025.2/U55C有效3.333ns/uncertainty0.1ns/全IOdelay0.5ns，仅综合+opt，功能和物理阶段分别报告。

独立reference900/static1800/RTL3000/OOC1800秒；全部实际compute/EDA持唯一m007_heavy.lock，CPU0–3/nice19/idle I/O、MemAvailable>192GiB，RSS16/24/8/24GiB。预冻结v3实际checked-consume事件独立120秒停滞、总墙钟/RSS/预算/后代回收共同保护；长例由同版实际pilot成本门绑定。期望gpt-6.1-sol/xhigh，实际未核实。

用户2026-10-22明确“继续任务”，A001实际接续恢复E015剩余G；AT055冻结复用，不重跑。原53笔费用逐账核对余额一致，见R001/resume_20261022_audit.json。旧暂停交接保持历史原件。

G恢复：AT058逐字节整理原AT007的335872条x/gate/u/v/w/t/z/h/r/s/y/GEGLU，未新增算术gold；s-major索引映射回原128×2624行列。纯G外侧56mul/16add池及单TANH公开口；生产FSM单次全任务命令、自主跨s同步读、逐slot实际输出消费和真实债退休。验证壳只用一份原storage/TANH8/外侧池，未验状态不作通过。

当前完整G验证build AT066 manifest83bc4beb7a2defd80ed15f2f1570848fd98dd8438e0e830e880bf23451b93e2d；AT06932768中样18.41071801999351秒，原v4同版门217.58084567542684秒≤240秒后启动AT072。纯engine无物理资源实例，验证壳恰一原storage/一TANH8/56mul16add；storage SHA c36d0089与E016 AT013同名源逐字节相同，但没有据此签父组合。新错误fixture AT070仅重算每案两个scalar的原primitive/libm，未变条目复用原gold。


---
Published: 2026-10-22T09:08:58.960713+00:00
Publication: P476f1fac40864daf8a319eb37150f033
