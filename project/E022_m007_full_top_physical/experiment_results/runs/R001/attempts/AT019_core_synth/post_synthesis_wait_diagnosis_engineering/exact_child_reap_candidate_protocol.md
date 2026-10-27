# AT019 exact-child native wait4 feasibility and rejection

This preparation is limited to isolated small processes. No production attach, signal, wait/reap, monitor pause or supervision switch was performed.

The confirmed DG_OBJECT_20261026T104830Z_8a4d5837 binds HARTS count=1, termination flag=1 and worker PID3633734/start66420454, state Z/PPID3582995. Its existence supports an exact-child recovery hypothesis, not production safety.

Candidate: pause only the main monitor because its loaded L239 rejects guard R/S. Leave watchdog and observer online; neither rejects a merely stopped monitor by state. A proposed <=4s maintenance guard would retain RSS/host/lock protection without writing fake heartbeat and restore guard T before resuming monitor. This maintenance integration was NOT implemented or tested because the prerequisite native action failed a fault injection.

Native feasibility probe: isolated Python parent creates one real zombie, holds flock, enters nanosleep and is stopped by the test harness. Tracer uses SEIZE/INTERRUPT, saves the full x86_64 register set, derives the parent-specific libc bias and verifies syscall opcode 0f05 at ELF+0xecbdd, sets SYS_wait4(61), exact positive child PID, NULL status, WNOHANG, NULL rusage and orig_rax=-1. It drains only unchanged-RIP group-stop notifications and steps the one syscall. Normal path restores and compares all registers before SIGSTOP detach. No target code/stack writes or Python calls.

Initial probe recorded an extra group-stop event rather than an executed instruction; original failure artifacts remain in their first directory. A corrected fixture showed normal exact-PID reaping and tracer death before step / after observed step can retain T. Those partial results are superseded for safety by the nanosleep fault case below.

Decisive actual counterexample: guard_single_syscall_probe_1793012176366141368/tracer_killed_during_step/observed.json. SIGKILL after STEP was issued but before stop collection leaves guard4142907/start70182259 in S, not T. The exact zombie was gone; flock remained held; Python marker was absent at the 30ms observation. This does not prove Python did execute, but refutes the required guaranteed stopped guard on executor failure. The original stop cannot be assumed to persist across ptrace restart. No production executable recovery entry is released for this mechanism.

All attempted fixture parent/child identities were cleaned and /proc absence recorded. Remaining fault phases and maintenance integration were not run after the decisive failure. Original loaded guard, live supervision, hardware sources and AT019 remain untouched.

Follow-up dependency, separate from current recovery: future serial-stage guards need exact adopted-child collection during their active loop while preserving the Popen leader status/receipt. Do not use waitpid(-1), steal the Popen leader status, edit the currently loaded guard, or bundle an untested recurrence change into administrator recovery.
