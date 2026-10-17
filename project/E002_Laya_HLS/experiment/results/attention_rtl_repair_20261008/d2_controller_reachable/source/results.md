# D2-I：生产Controller可达生成路径结果

2026-10-08：Astra xhigh设计细化已保存，实施/CPU/CSim/csynth/IR审核尚未完成。无生成RTL执行或性能通过结论。

I-L与I-V分别保存实际wrapper、被include的官方controller及其余生产源/hash、cfg/工具、真实fixture与独立gold、CPU/CSim数值/owner/错误结果、各阶段bitcode/解码IR及RTL成功路径映射。只对已执行范围记结果；完整top HLS仍需D2各项证据的后续独立技术放行。

## 独立设计审核

[独立审核](../../reviewer_d2_i_contract_review.json)已接受本项有界CPU/标准libm CSim/局部csynth/IR实施，决定为`ACCEPT_D2_I_CONTRACT_FOR_BOUNDED_CPU_CSIM_CSYNTH_IR_IMPLEMENTATION`。审核对应[合同精确快照](../../contract_snapshots/d2_i_reviewed_contract.md)SHA256 `935464f9b644180d6369c3528de411d838da1a83319db36ded56704c8da14e5d`，其中§7.6 SHA256 `05a447d412f605228b3a6d3e3d9cee6af973afd81dcee2ab41456333d60d2ab7`。当前源/TB与实际运行仍待实施；不放行I-L的64行QKV RTL或完整top HLS。

## 草案v1代码预审

[独立预审](../../reviewer_d2_i_draft_v1_pre_review.json)重核26项提交hash，真实controller include、24其他生产源、合法物理producer及独立R0gold路径结构接受；固定producer epoch1的连续请求缺陷与复合错误优先级测试待修正。v1源码/TB/config已存[draft快照](../draft_snapshots/v1_before_review_fixes/draft_v1_pre_review_packet.json)。当前只有语法检查，fixture生成、CPU、CSim、csynth和优化IR可达证据均未完成，不能预填通过。

## 修正草案v2，待独立复审

Sol max仅改两个隔离wrapper和线性TB：解析成功后全部producer ref使用真实`controller.fresh`，线性测试增加缺pair与坏scale、缺pair与坏header复合用例，保留单故障用例和单调request id；v1→v2[精确diff](../draft_snapshots/v2_after_review_fixes/review_fixes.diff)。生产controller和其他24份官方源未改。`make_configs.py`重新生成两份隔离配置及[source list](../source_list_manifest.json)。

在16GiB树RSS、4CPU、1800s、192GiB MemAvailable底线的串行守护下，独立[fixture/gold生成](../fixture_guard_v2/guard_result.json)与四个wrapper/TB translation unit的[仅语法检查](../syntax_guard_v2/guard_result.json)均exit0且无guard触发；语法检查不是功能执行。生成15份fixture/gold，[fixture报告](../tb/fixture_v2/fixture_report.json)包含11项`Evidence.checked`，其中真实candidate alias输入`ir_1469.bin` SHA256 `658668099f53516791f192f6641dc9819d36c0aad1ce8f6c624faaca1c8ca0f5`。新的[预审packet](../draft_v2_pre_review_packet.json)SHA256 `a464fce0a41b2620884586574cceb371dc165f8eca149ec7b6bb6cae8861d0da`绑定90项实际源、包BO、capture/GGUF范围、生成输入与日志hash；所有GGUF weight范围和原capture文件已重新核对实际字节，冻结脚本连续两次重建得到同一SHA。

此处状态仍是**待Astra代码复审的草案**；CPU功能、Vitis CSim、局部csynth、优化IR与RTL仿真均未执行，也未被本段语法/fixture结果放行。
