# E015 R003 results summary

Source audit and all 6 static/RTL attempts PASS. Actual same-runtime v2/v3 each checks 6726outputs/282812 nodes;841 core152/public153/II1 and all held/reset/newgen/credit/reject/debt assertions pass. Eq and both singles have identical 2671cycles/841 actual response trace lines, SHA55827849…. Old v1/v2 unchanged.

Single-snapshot xsim total9.188027718→8.694883177s (1.056716638x),active+protocol2.899840288→2.516007214s,explicit448-cycle idle0.141459022→0.019675719s;startup/fixtureinit essentially unchanged. One sample each; local observed cost only, no joint/FPGA speedup or LN128 gate reopening. All6archives19files each and3×24originalsnapshotfiles verified;4714owned policy samples/0corrections, all cleanup empty.

Evidence:[delivery](runs/R003/independent_delivery_v1.json),[source manifest](runs/R003/production_manifest_v1.json),[cost comparison](runs/R003/standalone_cost_comparison_v1.json),[budget](runs/R003/budget_closure_v1.json),[run](runs/R003/run.md). Reference/OOC0;static34.596123910974711s/RTL33.019948552944698s. Prior accepted R002 CE26 remains frozen and separately applicable.

---
Published: 2026-10-23T05:49:52.871485+00:00
Publication: Pd9f39e2890ac4cb7bd945da6ba4b8551
