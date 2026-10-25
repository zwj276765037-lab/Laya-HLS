# QUANT-03 frozen production handoff

Applicable engine `laya_m007_quant_group32_v1.sv` SHA256
`555ac5492af12929112d5f513538f205a1607021d602356083956c909e955add`.
The implementation lives only in E002 activation_quantizer; E013 stores evidence.
Old quant16, full_reference.py, models, Host/E009 and the other owners' files were
read-only. Desired gpt-6.1-sol/xhigh; actual model/effort remain unverified.

AT014 actually compiled frozen source paths and records `source_identity.json`,
`source_binding.json`, `snapshot_build_sha256.json`. AT015/016 each preserve a
pre-run inventory of actual xsim.dir library files including xsimk, work.sdb and
other compiled tables, plus command/UTC, and a post-run inventory. Only .log
files are excluded. Earlier runs remain at their original evidence boundary;
they are not retroactively given a compiled-snapshot identity.
The pre/post inventories also include generated control files. First execution
adds xsimSettings.ini/xsim_script.tcl, and switching MODE=full to protocol changes
the generated xsim_script.tcl. These expected control-file differences are
preserved in the original manifests; the21 actual build artifacts remain
identical before/after both runs. They do not indicate compiled-library drift.

Full128-row results use one real shared_div8 and32 original strict fmul leaves:

| K/input | groups | first real output inclusive cycles | first input to final real output inclusive cycles | cap |
| --- | ---: | ---: | ---: | ---: |
|1024 original enc0 norm128|4096|85|4180|4224|
|2624 independent diagnostic|10496|85|10580|10624|
|4096 independent diagnostic|16384|85|16468|16512|

Every normal group checks Q/half and actual amax/d_full/inverse/all32 products
against the original independent arithmetic. Input and output II1 are asserted
at every no-stall handshake, max84 reservations. Actual lease wait is1 cycle;
the peer starts input2 cycles after lease acceptance. Initial common reset has4
observed rising edges; these are separately reported and not hidden in stream
cycle totals. Full source/Q/half of first4 rows match the original frozen fixture.
Only K1024 is an actual model checkpoint; the other K values are diagnostics.

Sixteen independent edge groups preserve d_full==0 and signed/subnormal data,
full-F32 inverse rather than half-rounded scale, local source element and actual
operation stage.13 scale divisions/6 inverse divisions/7 group multiplications
are measured, so earlier input/half/inverse errors do not run later arithmetic.
Error records retire normally with data0 and status/stage/source_element; they
are never valid A-cache publication. The original references have different
exception-check ordering, so this does not sign global parent first-error order.

Protocol tests observe128 actual occupied slots, hold the129th for150 cycles,
then consume/reuse the head while preserving order. Held entire output records
are stable;256 groups with finite input/output stalls are exact. Release waits
for16 unconsumed records and all real shared debts;8 identity/coordinate/lease
rejects take no group reservation. Common reset occurs with24 accepted groups
and actual divider work in flight; generation2 waits100 cycles without stale
returns, then128 new normal groups pass.

The registered-declaration storage ledger totals219993bit=27500B rounded up:
raw16384B, packed4352B, per-slot metadata4016B,32 multiplier pipelines2420B,
amax1031bit, raw read1064bit, mul tags64bit, divide holding81bit and global377bit.
All storage other than raw/packed is54105bit=6764B rounded up, within8192B;
total is within32768B. This is a source declaration audit, not synthesis mapping.
The engine does not store a full tensor or duplicate shared divider state.
AT017 release audit failed because the earlier manual leaf sum said705bit while
the listed register fields actually sum605bit. This conservative400B overcount
is corrected here; AT017 raw FAIL/cost remain, with no DUT or independent gold change.

AT009 synthesized only the small amax leaf:1634 LUT/988 FF/0 blackbox. Its XDC
used an unsupported command, so1001 inputs lacked delay constraints; its emitted
overall timing PASS is invalid. Raw output is retained. AT013 opens the same
DCP, applies corrected input/output0.5ns constraints and actual3.333ns clock:
WNS+0.958ns, all input/output/internal constraint coverage checks0. No resynthesis,
P&R, engine resource mapping, or full-engine300MHz claim follows from this.

Integration ports: lease request64/gen32/source_epoch32/K13; input and output
row8/group8/tag96. `out_data[255:0]` has Q element0 in low8bit, element31 high;
`out_data[271:256]` is scale F16. Keep output ready low until the legitimate peer
can accept that record. For errors, cancel the parent A slot through the future
joint protocol; A010 remains sole owner of cache publication/cancellation.
Connect the d_* bundle to the unique A007 shared_div8 phase5/head0; lane0 scale
and lane1 inverse may refer to different slot tags. Common reset must include
engine/service; release-ready waits all actual output and arithmetic debts.

Remaining boundaries: actual A-cache write/read association, full-slot cancellation,
global parent Check/first-error order, Q/G or idle_Q physical sharing, full-engine
BRAM/resource/timing, full LN→Q→matrix and complete model/board tests. A010 has
acknowledged the packed mapping and will keep error data unpublished.
