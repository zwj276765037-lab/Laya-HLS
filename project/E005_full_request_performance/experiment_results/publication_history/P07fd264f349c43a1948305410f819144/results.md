# E005当前结果

KB0 AT001实际PASS，四distinct K2624/N1024，335872 PS lane-group及4096 F32全部原独立gold，512实际AW/W/B及末B/一次done消费。全TB48864，cfg→done21100，cfg→consume21107，A加载666/W加载27064，故意7cycle反压保持。接口stall重叠单列，strobe50%。

KB1 rowpack普通缓冲候选只改一writer（4row pack缓存），额外1923bits字段账，不作LUT/BRAM估计；同数值/反压正在新AT002实测，尚未签收益。P3比较已获主控接纳为设计候选排序，薄HLS优先/RTL备选，具体表schema/生成目标未冻结。

---
Published: 2026-10-13T05:59:49.311849+00:00
Publication: P773e4c2f32df499f8f107d5551cb926b
