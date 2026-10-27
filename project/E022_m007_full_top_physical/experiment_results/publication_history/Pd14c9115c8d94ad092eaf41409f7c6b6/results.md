# E022 actual results and boundaries

AT001 preflight PASS20.387176117s. AT002 wrong default platform configuration COST_STOP126.709649772s; AT003 correct11generic full synth COST_STOP709.993409556s; AT005 original core COST_STOP868.242573546s, all at24GiB with no DCP. Unsupported3D operand warnings identify expansion candidates; no final FF/device-fit conclusion. Historical synthesis spent1704.945632874s remains charged.

AT009 XSim compile/elaborate PASS9.768734056s. AT010 four-state actual old/new storage comparison PASS9.683605608s,6721cycles/13442full-pool checks,2560combination/equality cases each pool,512additional high32 format/PS collision cases,64reset-all-write cases,192X cases;64slot/256lane/32bit comparisons and independent actual-read-port64slot coverage. [Actual result](../experiment_results/runs/R001/repair/equivalence_result.json), [raw XSim log](../experiment_results/runs/R001/attempts/AT010_repair_rtl/xsim.log). Source postchecks true, owned cleanup empty. Known-address storage representation only, not exhaustive values/unknown addresses or full-core waveform regression.

AT011 new core OOC is running. Full-top resources, fit, implementation and WNS/TNS/WHS/THS remain UNKNOWN/NOT_RUN until real DCPs and reports exist.

---
Published: 2026-10-25T07:45:57.139515+00:00
Publication: P03533acd6a384546b34c09350372f4ce
