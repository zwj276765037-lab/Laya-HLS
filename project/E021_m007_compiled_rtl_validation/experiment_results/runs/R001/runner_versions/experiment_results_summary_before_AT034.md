# E021：阶段结果

原严格FP/shared4同源码PASS；当前canonical父QKV1独立原gold终点PASS。完整Encoder0一次120s pilot正常推进但真实COST_STOP，完整层/30层未验。

原ADD/MUL/DIV固定191904/217304/191792向量，分别checked192077/217477/191965，8/8/32拍、II1、CE保持/36停拍、reset断言通过，原XSim完整语义行相同。有限输入域含次正规/RNE/正负零/溢出/渐进下溢，不签NaN/Infinity输入或DIV零除全排列。当前shared4五源精确对应E010/R003/AT031，4424scalar/1106物理8拍返回及lease/holding/epoch/debt/reset/CE通过。local runtime修复后AT022..025重复同完整原fixture亦全PASS、语义全同。

AT013原owner无损残差group32加载修复后fresh翻译94.855779322s、744cpp/276302770B；root头变化故全重建318.623924956s dispatcher/293.824513573s guard。首次RTL fixture_end后SIGSEGV。AT014 existing-gdb8.358059969s定位coroutine destroy/vector clear；栈耗尽不受支持，未升栈。AT015精确原EXP8×168 #0小例raw SIGSEGV(-11)；AT017仅fixed-batch修复后不再段错误，但default100真实nonconverge。失败均不覆盖。

AT020 fixed-batch+512混合时序通过，与AT021同SHA XSim13事件逐字一致，8组初始化tick0完成，非零clock/reset不变。仅签此有限原初始化/reset范围，非一般SV #0完整等价。

AT026父相同93源、原gold、172d3019…5d555 TB，512翻译50.421797747s；4生成头/PCH文本全同，742cpp全同，2TU仅3处limit常量变化。只编2TU+1patched timing对象、新archive替换两成员并新链接，build2.968448403s。exe SHA b92abf4e78cbd046711cb3e09d947ad9946f593fac2fc618b959acf79cd6963e，15039672B。QKV1 RTL16.559499569s，8192values/cycles10343原终点到达；92事件前86与原XSim实际部分前缀精确一致，仅注册EXPORT路径规范化。原XSim AT043自己仍为60s COST_STOP，无完整QKV终点。

AT027同exe、KIND5/PACKED0、全STOP0，完整pilot真实timeout120.329810056s，354语义事件，原86前缀匹配，无SV Fatal、完整terminal缺失。fixture7.621674s结束；matrix0在14.853329/c11114开始，59.323312/c62942结束，48连续块/393216原gold值；RoPE checker59.352290/c62984至60.789483/c65000，未有显式RoPE起止marker。head0..3分别10.309031/8.266757/12.882505/15.547152s，均11038cycle且HEAD_END真实到达；head4在107.824281s开始未完成。最后原checker1118273/PROB/c115428@112.231634s。QK/SM/AV仅SCORE/PROB/CONTEXT checker观测跨度，不捏造起止边界；未证明父完整退休。

当前raw guard static931.636886549s/RTL183.827658468s；已知开销计保守static982.891142837s，其余准备/预检开销UNKNOWN。见budget_current.json。AT013..027已知2495身份清理无存活/僵尸；政策新4+旧AT0122个瞬态UNKNOWN限制保留。无OOC/P&R/板卡/部署结论。
