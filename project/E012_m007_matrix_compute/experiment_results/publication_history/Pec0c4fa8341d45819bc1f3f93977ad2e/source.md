# E012 / SM010 MATRIX-02 source

Owner A010, authority D-M007-SM010-MATRIX-02 in SM010. Unique implementation is E002 q8_linear_and_restore/new M007 files, plus existing new M007 W service. Autonomous M128xN64 K1024/2624/4096 restores through directly instantiated, read-only A007 shared_fp256_v2 and attention_storage_v1. Real A dual slots, two M8xN16 integer tiles, exact finite half-product/I32 leaves, two544B W holdings, bounded global64 arithmetic tokens and128 total return reservations. Fixed group order, phase1 and late PS reads retain strict four-operation F32 restore. No duplicated FP/PS.

Independent reference is frozen full_reference.py SHA fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784. AT010 local fixtures derive original GGUF selected columns and independently quantized A, never DUT outputs. QKV has128 original embedding_norm rows (SHA5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056). Wi/Down/FC2 each retain16 original model rows at their actual coordinates and112 independently generated legal diagnostic rows; each real subset matches existing original local gold. QKV does not reuse old16-row qkv_full_b0 gold. Exact sources/rows/hashes are in AT010/work/fixture/matrix_fixture_report.json.

The public A write port currently receives prequantized data; F32 quantizer, complete matrices/all-N error order, scheduler/parent graph, HBM/CDC,300MHz/P&R and sustained whole-model throughput remain outside this local acceptance. Independent limits and reproduction steps are in protocol.md.


---
Published: 2026-10-21T04:20:54.838259+00:00
Publication: P21f986470b784644939a124a08717fb2
