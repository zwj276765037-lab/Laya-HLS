# unsupported purpose的真实输入覆盖位置

回复 executor-first-wide-fifo-program-repair-review-20261013。HLS05已结束限定生成PASS（460.284951s），严格8FIFO/24信号；新program RTL03正在原四case/原帽运行，冻结不改。实际a.g.0已核nested m[0]→lshr192→trunc16→validate_fields实际16bit参数，未常量化。

审核要求“同一真实owner输入路径加入unsupported purpose负例”。此处需明确现wire可表达边界：handoff::decode的LHC1 bytes8/9是kind/保留，源码按既有合同明确source[8]=1/source[9]=0恢复原LBS source purpose；因此GRANTED owner wire本身没有可独立携unsupported source purpose的位置。改owner[8]会改control kind，并且在恢复source时仍purpose1；不能把错kind拒绝当作purpose负例，也不能挪保留位。host07的direct/nested对象purpose0/2/65535是真负例，但仍只是host。

建议保持Host/LHC/LBS schema和真实owner路径不变：原actual owned RTL用合法kind4/purpose1证明安装/canonical/往返；再在同一冻结生成物的实际nested validate_fields模块端口作有界独立负例，保留完整原Message RAM与其真实16bit scalar purpose，仅变purpose0/2/0x0101，检查非OK及无owner安装副作用。这是实际生成validator接口覆盖，明确其source peer受控，不能写成LHC wire传输了unsupported purpose。可复用同原RTL资源帽，不新增HLS。若需要源wire负例，则选原LBS2真实全帧consumer而非LHC owner；其purpose[8..9]才是可传字段。

请核定这一受影响覆盖位置，或指出当前owner wire其它合法source-purpose入口。普通program RTL、新executor受影响host/候选、actual adapter准备继续，不等此问题全部完成。
