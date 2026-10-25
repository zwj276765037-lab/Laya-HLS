# E016/R003 当前实际结果

AT001 TB生成语法FAIL1.914082291s；AT002 build PASS46.094478799s后，AT003在8identity通过/QRUN首笔quant-A附近发生xsim kernel exception，RTL FAIL6.614362462s保留。等价显式TB分支、不改production/gold/checker后，AT004 build PASS43.694276949s、AT005 QKV3 PASS48.746615243s：原8identity、4096实际input/Awrite/Aack、768QKV32/24576原值、8364cycles、31/13反馈、strict checked155648@8955。新分支后未再观察该exception；没有单构造因果隔离结论。

AT006为相同AT004 snapshot的真实第二head退休pilot，当前正常QKV阶段、未出结果。full NOT_RUN、尚无gate。完整checker已编入但不等于完整链通过。控制/source账3746B、452输入源，无物理fit结论。

---
Published: 2026-10-22T12:24:22.768499+00:00
Publication: Pedc98174ef6342f199a07c48f5e25027
