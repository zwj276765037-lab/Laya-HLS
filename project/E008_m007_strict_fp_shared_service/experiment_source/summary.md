# E008 source summary — M007 / SM008 / R001

D-M007-SM008-AT014-01 implemented exact finite binary32 mul8, replacing the old multiplier in the same shared array. Full48-bit product is aligned once to normal/subnormal target precision before the sole RNE. Independent native217304 finite expectations cover original failure, boundaries, ties, signs and random inputs. Existing strict add8/div32 sources and single-leaf baselines are unchanged/reused.

Authority, exact algorithm, inputs and reproduction: [protocol.md](protocol.md). Current same-source shared4/256 and v1 compatibility closure includes strict mul/add, with no vendor FP dependency or duplicate array. [Current frozen version boundaries](../experiment_results/runs/R001/current_version_evidence.json); prior closure evidence remains historical.

Actual platform Vivado/XSim2025.2, xcu55c-fsvh2892-2L-e,3.333ns single-leaf OOC; functional, synthesized and routed results remain separate. Fixed model/whole-model independent reference and numeric/Check responsibility were not changed. Future real-bank/Check/tree/feedback integration and full shared physical evidence are not claimed.
