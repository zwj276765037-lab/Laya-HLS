# AT019 exact-child native self-stop recovery preparation

Production recovery has NOT been executed by engineering. This is the reviewable administrator entry and isolated evidence package. Original failed no-write single-step evidence remains unchanged in guard_single_syscall_probe_1793012176366141368/test_result.json and must not be used for production.

Fixed administrator command:

/usr/bin/python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/physical_d38/admin_exact_child_reap_d38.py --execute

Default command without --execute is read-only plan, no attach. Optimized Python is refused before imports. Administrator entry SHA c3bedb2648eb5b2724ccf999902434f66b5b6a14e5fe7afa5b798cb976afea9f; dependency identities and final plan are exact_child_recovery_ready_receipt.json.

## Preconditions and bounded mutation

The actual administrator DG_OBJECT_20261026T104830Z_8a4d5837 established HARTS count1, flag1, sole worker3633734/start66420454/Z/PPID3582995, exit0. Entry verifies the original raw evidence hashes, same Vivado3583093/start66052106, guard3582995/start66052065/T/TracerPid0, three original supervisors, held original lock, current no-deadline policy and serial waiting. No Vivado attach, call, memory write or signal.

Guard must be single-threaded. Same libc full SHA/inode/device/PT_LOAD and guard-specific RX map are checked. RX PT_LOAD ends ELF+0x1b0039, next RO starts0x1b1000; the mapped page tail is zero padding. Only guard-private ELF+0x1b0040..0x1b0070 (48B) is borrowed. It is read from the actual target and must be48 zero bytes, saved durably with all original x86_64 registers before monitor pause or modification. Disk libc and other processes are not written.

44B fixed native stub performs wait4(3633734,NULL,WNOHANG,NULL) exactly once, stores raw return inr12, then kill(3582995,SIGSTOP); the final unconditional branch repeats only self-stop, including after unexpected CONT. No call/ret, stack access, Python execution, mmap or mprotect. Four trailing zero bytes are preserved. Full48B and every original register are restored and read back in a fresh attach from confirmed real job-controlT, without restart, then detached with SIGSTOP.

## Maintenance and failure scope

Only main monitor3595603 is paused. Watchdog3595604 and observer3595805 remain live. Original heartbeat is never fabricated or written. Independent coordinator and maintenance worker sample actual owned RSS, host availability, CPU policy and original lock. Resource enumeration ps has<=0.2s timeout.

A durable maintenance intent with one monotonic deadline is written before SIGSTOP; budget starts before actual pause and cannot be refreshed by a missing marker. Native helper receives0.6s; absent restoration triggers coordinator takeover at intent+1s. Cleanup waits use remaining budget and monitor CONT has a final budget check. Both normal and backup paths record/assert the same4s total deadline. Final five tested windows were0.139,0.306,0.847,0.486,0.182s.

The native helper and worker are dedicated short processes. On executor loss, the independent owner terminates only new helper identities, freezes guard, confirms T/untraced, restores exact context and bytes, then resumes monitor and verifies actual heartbeat. If context/deadline restoration fails, it does not blindly resume monitor/old guard; failed_closed/error receipts preserve identities and available restore evidence. Existing watchdog/observer retain their original heartbeat-failure fallback, which can stop owned workload on catastrophic maintenance failure. Four seconds is a governed and tested recovery budget, not an arbitrary OS/kernel/filesystem real-time guarantee.

The outer7s timeout terminates only the newly launched coordinator; separately launched worker retains its own deadline. An error receipt records worker/tracer/monitor/guard identities and restoration/failed_closed state. No second wait4, retry, oldguard CONT or production restart is attempted. A seven-second timeout is an exceptional failed-closed outcome requiring inspection, not proof of complete restoration.

Restoration receipt establishes T/untraced/regs/48B before monitor CONT. Once original supervision is handed back, Vivado may finish naturally and original guard/serial flow may advance. The entry does not rerun the old strict diagnostic preflight or require the original guard to remain T forever; subsequent observations and actual original receipts remain distinct from recovery/hardware acceptance.

## Actual isolated verification and version boundaries

- Native core89cd5cfa91888f2e8cc0bc4329fc793a4429ff712ae146e806fa3d0fff556577:9 real guard/zombie/leader/lock cases, including SIGKILL during native execution, stop delivery, partial restore and restored-register window; unexpected CONT self-stops again. Original registers and48 bytes restored, real T/untraced, lock and unrelated leader retained. Receipt guard_selfstop_tests_1793012624052245119/test_result.json. The toy60s marker's absence in short tests is auxiliary observation only; closed native control flow, real stop and exact-context evidence support the safety conclusion.
- Maintenance5a52d2d3cfc657920ad57532926ecfb60417554a13e3bf47d2074be481356003: final5 cases use exact original handoff_guard/watchdog/observer sources and an already-expired toy guard limit. Normal, after-pause/before-write fault, after-register timeout, native execution death and maintenance worker death all restored before monitor handback; immediate oldguard counter stayed unchanged, no old fallback.40 recorded fixture identities have actual/proc-absence audit. Receipt reap_maintenance_tests_1793013667619000659/test_result.json. No pre-pause injected failure is claimed.

## Future-stage recurrence prevention

Canonical run_physical_d38.py SHA42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89 now reaps only identified known/start-matched Z children with PPID equal to this guard, excluding Popen leader and all supplied managed PIDs, by one waitpid(pid,WNOHANG) per eligible child. Active and finally paths record actual raw wait status/exit code in JSONL and receipt; no waitpid(-1). Actual orphan exit11 was collected, Popen leader7 and managed13 retained their real status; nonownedZ, wrong-startZ and live child were skipped. Receipt adopted_reap_tests_1793013134986611194/test_result.json.

AT019 frozen/loaded guard remains unchanged, SHA f8c1886ab93b9925c683a79c11653cc9eb69673eea4a8ff0e317b8edd314ab61. Actual verify_inputs/active_paths are structurally unchanged and current verified identity still equals AT019 source_identity; canonical runner is not an identity input. Evidence reap_prevention_source/AT019_identity_compatibility.json. Existing serial L132 launches a fresh canonical runner per future stage and freezes its exact bytes. Serial was not signalled/restarted, and no EDA was launched by this preparation.
