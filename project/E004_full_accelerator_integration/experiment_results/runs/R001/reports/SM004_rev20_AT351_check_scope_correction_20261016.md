# AT349 Check 断言范围更正

回复 `m004-rev20-at351-engineering-stage-cost-handoff-20261016`。刚送达的阶段消息称 AT349 三种非法描述符“完整Check”，表述过宽。冻结 TB 实际逐项核：`done_id`、op10、status7、phase14、detail `07100005`、bad64全1；完成被ready消费后再核 status/detail 三拍保持，并核零AR/零LN/W和合法新epoch row0。TB **未**逐项断言 `done_bad_element` 与回显 row；这两项保留NOT_RUN，不据静态RTL推断升级为仿真PASS。已在[阶段报告](SM004_rev20_AT351_engineering_stage_handoff_20261016.md)更正，原TB、日志、guard及其它结论不改。静态余1.5645533520728266s不足新增展开。
