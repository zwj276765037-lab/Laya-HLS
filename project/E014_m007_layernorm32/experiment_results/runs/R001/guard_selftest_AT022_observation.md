AT022 actual guard returned EXIT_ZERO after0.416407515s. Leader1838580 exited
before grandchild1838581; the actual grandchild state records that the project
lock was still held after leader exit. The subreaper tracked and reaped both;
cleanup recorded no remaining owned PID or PGID before returning.

The first harness then failed its immediate nonblocking lock reacquisition at
m007_ln_guard_selftest.py line71 with BlockingIOError [Errno11], because another
authorized project waiter may acquire the common lock immediately after unlock.
This is an invalid harness assertion, not evidence that the guard retained its
lock. Original AT022 source archive, receipt and child state remain unchanged.
The corrected harness independently checks absence of its own FLOCK in
/proc/locks, and records whether the fresh probe won or encountered a new owner.
