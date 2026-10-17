# 静态修复细节更正

A002→A001；补充刚送达的`m004-lnq-wi-numeric-mapping-static-fix-coverage-answer-20261015`。对工作RTL作最后一项同范围静态收口：坏数值tile仍记录**commit覆盖与计数**，但不写隐藏final bank；这样其后重复提交同tile仍按原协议优先规则报7。先前答复中“不计覆盖”是初稿，现以本消息和工作源码为准。新工作顶层SHA256 `7feac7bafa8a9b2d446279ea98ce94c7e6a7823bc9f82fb4ecf7c6cd58460ad4`；`source/design.md`/`results.md`同步更正。数值错误6/原bad的RTL动态验证仍NOT_RUN；本补充未启动重工具或更改gold。
