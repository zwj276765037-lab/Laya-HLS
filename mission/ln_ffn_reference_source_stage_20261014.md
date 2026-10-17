# LNREF0：独立重建enc0 LN_FFN输入

D-M004-LN-FFN-SOURCE-01；2026-10-14；M004/SM005/E005/R001。A002唯一实现/工具owner，A001集中审核。接续[QAR0审核](../results/measurement_first_QAR0_review_20261014.md)，在既有完整模型与测量优先授权内直接执行，无需用户转发或逐项源码审批。新结果NOT_RUN。

## 本轮出口

取得原request3/generation1/B1/S128、enc0、batch0的LN_FFN之前attention residual独立参考，保存完整128×1024 F32及前四行16384B；沿原数值图计算LN输出，逐位核对既有完整capture和AT035四行外部源。来源与输出一致后，才为后继LN硬件接入建立输入/期望对。本轮只做主机独立参考前缀与只读接点设计，不运行DUT、整体CPU控制器、HLS或RTL。

原capture的source_manifest明确`numeric_gold_role: none; only actual source BO observation`。它是既有DUT的源BO观测，用于核对沿袭身份，不能当独立参考生成器，不能用归一化输出反求输入或用LQ0 LN_ATTN数据替换LN_FFN输入。

## 可执行入口

下列路径均相对本项目`project/E002_Laya_HLS/experiment`。旧绝对路径显式映射至项目复制树，历史manifest字节保持，禁止写旧baseline。

- `tests/full_reference.py` SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`：`full_forward_graph`首层QKV/RoPE/Attention→WO→`add(hidden, projected)`→`layernorm_many`。保持F32舍入、相邻树、量化、epsilon `0x3727c5ac`、mask和全部128 token依赖；只需四行输出不允许把Attention缩为S4。
- `tests/full_forward_oracle.py`的`request_inputs`与`single_request(inputs, 0)`取原五ABI输入的B1_from_b0。`tests/full_forward_dut_run.py`的原映射及`build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin`用于验证request3/generation1、五输入字节、marker重定位及模型/numeric/layout/build来源，不能只信文件名。
- `tests/full_fixture_test.py`的Evidence只从原五输入与GGUF读取前向输入/权重。模型455179648B、SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，原manifest/inventory常量SHA继续核对。模型路径若为历史绝对路径，仅在新runner中适配并记录映射/实际SHA。
- `results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/full_forward_oracle_report.json`与当前reference SHA一致；历史B1_from_b0的embedding_raw/embedding_norm/encoder_00_out为0.024/0.038/1.522s。这是成本参考，不是新工具耗时或硬件周期。
- 如使用原`tests/full_libm_batch.c`，冻结源码/编译参数/库身份及原标量与批处理逐位自检，保留`-fno-fast-math`、`-ffp-contract=off`和原libm规则，不以近似运算替代。

## 有界实现与核验

派生一个最小前缀runner，仅增加enc0 residual、LN输出观察和取得两者后正常结束的机制；数学函数及到该点的顺序保持，保存可审查diff。不得为捕获四行重跑28+2层或旧FullRuntime四持久请求，不得读取旧DUT中间capture作为前向图输入。

保存五请求输入/模型及实际权重段身份、reference/runner/libm身份、完整residual524288B及前四行16384B、独立LN输出524288B及前四行16384B、形状/finite/字节序，以及精确逐位比较计数与首差位置。旧完整LN输出capture SHA `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`、前四行SHA `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`；新独立输出的生成来源与对旧观测核对结果必须分列。

源identity及LN输出一致后，可用原独立量化函数核四行q4096B/scale256B：q SHA `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`，scale SHA `4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`。不修改既有gold；任何不一致保留原始结果/首差/已证原因或UNKNOWN，停止依赖它的LN接入。

同步做一次只读接点表：原LQ0 baseline核/所需`.v/.dat`能否逐SHA复用；LN_FFN opcode0x12、stage2/layer0、batch0/row0、rows4、gamma0及QUANT0x20；HIDDEN源、STATE0的8MiB NORM布局/BO合法容量与AT035外部Q地址的适配；最后B、响应、source lease、发布/读债与唯一状态权威。允许规划稀疏DDR模型表达合法大地址，不能缩小BO声明或伪造publish。不用LQ1/R违例候选，不预签无需新HLS。

## 成本与停止

一个参考前缀方案，最多一次有路径/观察/封装原因的修正，不扫数值算法/输入。原guard政策串行，CPU0–3/nice19/idle I/O、MemAvailable>192GiB；本入口主机计算及必要小helper编译合计≤8GiB/120s，真实语义停滞≤120s，子进程纳入owned核算。历史秒级前缀支持这个小入口；若成本不支持或同点重复停止就交付，不加帽，不以旧LQ0与AT035的RTL耗时相加预测新链成本。

脚本仅写E002/experiment授权tests/tools目录，报告/新AT仅E005/R001。原数学真源保持，派生版本保存diff；不回写旧attempt/manifest/receipt，不新增agent，保留他人修改。更新三摘要并直接交付原命令/日志/冻结输入输出/guard/policy及比较。

本出口后由主控集中选择四行LN baseline回放或实际LN→QAR0接链，本合同不自动启动HLS/RTL或生产控制。原单工具/分类帽、无新HLS/OOC/P&R/上板/预算保持；G2338.224019s仅OOC余额、5172s组合不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；M003/M004、FFN residual、全模型/请求/恢复及联合物理实现未关闭。
