# E013 / R001 QUANT-03 source

execution_state: completed; owner: A008; M007/SM010 D-M007-SM010-QUANT-03.
Implement32 F32/group per cycle with128 real reservations and strict Q8+F16.
First group<=128 cycles; full128-row stream<=4*K+128 for K1024/2624/4096.
Production is only new laya_m007_* RTL/m007_* TB under E002 activation_quantizer.
Legacy quant16/Host/reference remain read-only. E013 holds evidence, not a second implementation.

Independent source: original full_reference.py SHA fe9678e4...e9784, quantize_rows/
quantize_many. Actual norm128 input SHA5d882938...4213056 (524288B), and pinned
task2_real_fixture_20 first4 Q/half files cross-check the actual prefix. Other K
use explicitly labeled diagnostic values. No full-model gold is generated.

Q phase5 reads A007 shared_div8_v1/return_vector_credit_v1/fdiv_rne_v1 only; its
real32-cycle/II1 evidence is E010/R002 AT010.32 dedicated strict fmul leaves are
read-only same-source reuse and separately count Q/G resources, outside matrix256.
Actual engine implementation and scoped verification are complete. FinalAT015
full30976 normal groups+16 edges andAT016128-credit/hold/release/reset/new-gen PASS.
One real shared-div8 and32 dedicated strict mul leaves; engine SHA256
555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add.
AT014 source identities hash actually compiled frozen paths. AT015/016 each
preserve pre-run actual xsim.dir library SHA inventory/UTC/command and post-run
inventory; earlier evidence is unchanged. Independent reports/files are verified.
AT018 final audit PASS; source-declaration storage total219993bit/27500B rounded.
Small amax only: AT013 same-DCP corrected constraints complete; full engine OOC NOT_RUN.
Final release/handoff reside in E013/R001. No further E013 compute is running.
Full protocol and boundaries are in [protocol.md](protocol.md).
