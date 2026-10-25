# E012 / SM010 MATRIX-02 results

AT001 independent proof covers16777216 signed packed-pair combinations,274688 RTL pairs,1142784 finite half-product/I32 vectors, and1024x256 diagnostic dots. AT003 leaves PASS; AT005 full256dot PASS at II1 for1024 issues/262144 scalar dots; AT007 real dual A slots PASS (2258 public records,43265 writes,256 overlapped fill/read records,64 actual reservations). These unchanged component tests retain their frozen source identities.

AT008 overall OOC COST_STOP120.238844s; only pair/half-product substages completed (oneDSP each,zero blackboxes). AT009 isolated A bank OOC PASS62.305528s,7BRAM36+2BRAM18,zeroDSP/URAM/blackboxes. These are local capacity checks; no whole-array timing claim.

AT012 actual QKV M128xN64/K1024 joint RTL PASS with current A/W/sharedFP/PS closure built in AT011. Checks every real A/W issue,256 dot/conversion/scale-product/term/PS-ack lane values and all8192 outputs against AT010 independent original-source reference. Continuous issue1024cycles; warm last output1317/done1320 versus1408 cap; W service735 and cold last output2056; max issue-to-real-PS-ack31cycles, PS feedback13cycles, output bubbles0, peak return reservations50. Includes held done and wrong-generation zero-arithmetic rejection. Guard19.031899s, no Fatal/ERROR; receipt/source/snapshot/fixture hashes retained under attempts/AT012_actual_qkv_superblock.

Other shapes, deterministic stalls, matrix entrance negative W scale and in-flight common-reset/new-generation integration remain pending. This is functional simulation under declared AXI peer40+2*(7-ID) initial delay and one512b beat/2cycles/port; no implementation timing or real HBM proof.
