# AT018 process-monitor incident and version boundary

Owner/runtime: A008, `/root/m007_host_tail_engineering`. All times UTC.

AT018 started its owned compile wrapper PID1831031 at approximately the recorded
`child_started=2026-10-21T06:07:31.683494+00:00`. The old monitor caught
`ProcessLookupError: [Errno3] No such process` during a recursive `/proc` sample,
recorded INFRASTRUCTURE_FAILURE and released the project lock with
`finished=06:07:33.525251`. Its receipt `child_wall_s=0` is not a measurement of
the actual child lifetime. The source-identity/snapshot/stdout artifacts were
last written at06:07:42.126061/42.155238; these mtimes prove tool activity after
unlock, but do not give an exact child exit time. A later PID check found1831031
absent. Actual total child wall time remains UNKNOWN. The AT018 snapshot is not
used by later LN runs.

AT020's lightweight static ledger ran06:07:39.993240–40.200395 and overlapped this
compile tail. Its declaration arithmetic is a SCOPED_STATIC_RESULT, while its
single-heavy-tool compliance is not PASS. A001 checked the A007/A010 launch and
result records for06:07:33–43 and found no overlap from those agents. AT018 and
AT020 raw receipts/archives/logs are retained without editing.

`budget_adjustments.json` reserves120s against the static budget conservatively.
This is separate from measured static time and is never reported as an actual
120s run. Subsequent guard receipts carry measured prior wall time, conservative
debit, and combined budget debit as separate fields.

The final monitor uses `m007_ln_process_guard.py`: Linux child-subreaper, PID
start_ticks identities, tracking of this guard's descendants, and one finally
cleanup before lock release. Normal completion waits for an orphaned grandchild
after its leader exits. BaseException, sampling and receipt-write failures force
cleanup of the original owned group and verified descendants; the leader's wait
status alone does not permit unlock. Final receipt writes are nested after
cleanup and before an unconditional unlock, so a receipt-write failure cannot
skip process cleanup. Other projects' processes are never selected for signals.

Real lightweight counterexamples are recorded by
`process_guard_selftest.json` and its stdout/stderr, with per-case raw receipts,
actual leader/grandchild identities, cleanup times, and absence of surviving
owned processes. AT026–029 are the corrected four-case suite. The earlier AT022
guard proved orphan waiting, but its harness had an invalid immediate lock-win
assertion; see `guard_selftest_AT022_observation.md`. Expected injected failures
are distinguished from unexpected infrastructure failures.

AT021 had already completed a normal compile before A001's new lightweight
counterexample gate arrived. It is retained as that actual event and is not used
as evidence for exceptional cleanup. New hardware work resumes only after the
four-case suite is verified, with a fresh compliant ledger/build.
