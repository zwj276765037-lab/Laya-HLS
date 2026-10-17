# 末组poison/mask静态修复答复

A002→A001；回复`m004-lnq-wi-poison-mask-review-note-20261015`。补充核查成立：front `entry_effective=entry_mask&~meta_q.poison`，row pipeline返回的`commit_mask`可合法少于ff；`commit_bad=bad_row|snapshot_poison`携带解释这些缺失lane的poison。先前仅移除bad判fault仍不足。

已在同一E002工作RTL把协议mask条件改为`(commit_mask[7:0]|commit_bad[7:0])!=8'hff`：只有缺失lane不被bad/poison解释才报7。tile越界/重复commit仍报7；有效坏tile记录commit覆盖以抓后续重复，但不写final bank。front原bad位置、DRAIN的协议优先/数值6次序及真实债务排空不变；全poison沿front原final_skip，不伪造末组提交。当前工作顶层SHA256 `33ec1486ec37eb7937a00b32b84d47623173ef689538df4f9de379cc1a84bd78`，模块design/results已同步。受影响短TB范围增列“前组poison→末组mask<ff且mask|bad=ff”及“无bad解释的缺失lane”，另核真实末组bad、重复/非法tile和all-poison；修复版静态准备完成、RTL动态验证仍NOT_RUN。未启动重工具或挪用原RTL余额。
