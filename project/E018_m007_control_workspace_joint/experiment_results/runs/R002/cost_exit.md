# R002 full terminal-cancel retry cost exit

AT020 is a retained actual FAIL (129.92466734204208s), not a budget-stopped success. Its last checked event proves335872 output/3358720 node checks, but it reaches legacy FINAL_REAL_DEBT before qualified DONE/discard checks. The old normal TB disallowed needs_discard even for cancellation mode2. The raw fatal did not print all debt values, so no complete terminal state is inferred.

The mode2 allowance is corrected; all other debt/gold/qualification assertions remain. Corrected build AT021 and normal held3 AT024 pass. No production RTL change was made for this harness fix. AT023 separately verifies a genuine peer terminal candidate and legal cancel on the same edge: one cancelled DONE, held17, consumption, actual discard and no-reset recovery.

After AT020, RTL usage401.286623009073082s left198.713376990926918s. Mandatory120s reserve left78.713376990926918s usable, below measured full normal123.3851001370349s and conservative full bound176.56988518499713s. After short archive regressions, actual usage424.830515450041275s leaves175.169484549958725s total, only55.169484549958725s beyond reserve. Corrected full replay is NOT_RUN_COST_GATE; there is no fake attempt/receipt or old-balance transfer. A future replay needs an explicitly authorized batch/budget and the corrected current TB, not unchanged rerun of AT020.
