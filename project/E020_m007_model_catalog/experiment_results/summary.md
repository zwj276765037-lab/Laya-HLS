# E020 results summary

Bounded Host/reader delivery PASS. AT002: all 8 test groups,120 mapping/layout/CRC/address checks and actual CLI build/verify passed; actual 10 tensor raw bytes81088B verified.3 type rows3072F32 byte-exact to original embedding_row. Products bias73728B/gamma4096B/type12288B and704 setup chunks; no device commit claim. AT001 preparation failure retained and corrected against original metadata.

AT003: Vivado2025.2 compile/source census PASS, only2 control bits/no holding/descriptor in reader. AT004: actual AR131/R132,129 parent responses,3 faults,3drained beats,120 record scan+1 recovery commit into2 TB slots,875cycles. Targeted AR17/R17 held, bad RID/RRESP/nonlast with real drain, illegal inputs, common-peer beginning/inflight/end reset and recovery passed.132 actual checked-consume events.14 original snapshot files unchanged;4 runtime additions recorded.761 owned policy samples/0 corrections; all cleanup empty.

Actual reference2.425926574971527s/static4.197466782992706s/RTL5.2437239199643955s. Evidence:[delivery](runs/R001/independent_delivery_v1.json),[source manifest](runs/R001/production_manifest_v1.json),[budget](runs/R001/budget_closure_v1.json),[run](runs/R001/run.md). Functional/source census evidence only; OOC/P&R/timing/board and production setup/mux/DMA/full layers remain NOT_RUN.

---
Published: 2026-10-23T05:25:34.927432+00:00
Publication: Pdb04dbf6827a4ed28c794f665d580e49
