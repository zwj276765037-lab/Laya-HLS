# E010 R002 result summary (frozen stage)

Full and sliding single-command head and complete generation2 reset recovery PASS: total11038cycles, QK4187/softmax2333/AV4508, firstscore90/firstrow298/tail56/rowgap16/firstcontext4251/feedback11. Each checks16384score/128max/16384prob/8192context, all arithmetic intermediates and native context readback;768actual QKV32 writes and one start, no saved score/prob injection. DONEhold3 and consumed-DONE/readheld3 preserve real debt.

AT020 legal numeric faults/finite stalls, AT023 phase3 SFU16inflight abort/no-reset newgen partial ownership, AT024 QK-inflight reset/full newgen head, AT025 physical-versus-logical error order, AT026 SFU32inflight reset/full newgen softmax all PASS. Failed attempts are preserved and charged. Functional scope only; no16head/RoPE/Decision/TANH/full parent/physical claim. Metadata3865B declaration accounting and separate payload costs remain explicit.

[Complete delivery](runs/R002/final_delivery.md), [actual versions](runs/R002/current_version_evidence.json), [source closure](runs/R002/final_source_manifest.json), [cycles](runs/R002/stage_cycles.json), [metadata](runs/R002/metadata_accounting.json), [costs](runs/R002/budget_ledger.json). R001 remains frozen.
