# Scorer full K/N finite numerical RTL independent acceptance

Reviewer: GPT-6 Astra / xhigh. Status: **ACCEPTED** for the stated one-row, three-command scope.

The accepted production identity fe067 selects actual scorer_fc1 family9/layer255, K1024/N1024/G32, B2/S128 batch1 row15 input from the frozen R0 marker_norm checkpoint. LOAD_W is followed by trace-on RUN (column7) and trace-off RUN with new task/epochs and retained W, without reset.

Independent review rehashed 712 sources, 42 evidence files, 350 final snapshot records and 13 runtime inputs. All original 346 compiled records remain unchanged; four allowed runtime additions are archived. All nine raw dumps (602,112 payload bytes) match frozen gold. Both full 1024-F32 output rows, 1024 A8 values, 32 half scales, all 32 trace records and three complete 1024-byte ABI headers pass. In-simulation full-page checks cover read-only inputs and every output/sentinel region.

First sampled ap_done checks settle same-edge bookkeeping then require zero physical and adapter debt across all nine ports. Actual endpoint R stalls and observed-port W stalls occur; explicit terminal-hold controls were disabled, so deliberate last-response hold and FIFO saturation are not covered. Both RUNs read no weight, scale or aux bytes.

| Command | Accepted start to done, cycles | Conditional time at 150 MHz | Issued / retired |
| --- | ---: | ---: | ---: |
| LOAD_W | 1,496,042 | 9.973613 ms | 0 / 0 |
| RUN trace-on | 1,815,172 | 12.101147 ms | 4,096 / 4,096 |
| RUN trace-off | 1,811,360 | 12.075733 ms | 4,096 / 4,096 |

Issue gaps peak at 478/437 cycles. The representative PS bank records 4,225 reads and 4,096 writes/dependent uses per RUN. These observations do not establish all-lane behavior or a pipeline II. Raw sub_done counts include initially-high idle samples and must not be described as completed subcalls. Phase state counts are occupancy observations.

The actual runtime took 1,051.983593 seconds with sampled peak owned RSS 859,052 KiB; all guards and process policies passed. XSim wall time is simulation cost. The 150 MHz column is a conditional conversion, not measured Fmax or a whole-model result. Warm reset/recovery remains covered only by separately accepted ACT evidence. Full-request RTL, same-source OOC/P&R, FP boundaries, board/XRT and the 50 ms objective remain unverified. No CPU oracle or EDA rerun was performed for this review.

Full evidence and limitations: [reviewer_q8_full_scorer_v6_full_functional_acceptance.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_full_functional_acceptance.json), SHA-256 `4a1331b7a9aac562a280778602f12085e86ff8497cccb4d2d1ac4771669649bb`.
