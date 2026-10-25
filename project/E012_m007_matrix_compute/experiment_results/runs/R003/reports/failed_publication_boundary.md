# Nonzero A publication terminal boundary

The pure adapter consumes an actual nonzero acfg_status response into a_failed_closed. That response denotes a failed invalid slot with no fill owner after consumption; no synthetic cancel response is produced. Final completion still waits actual quant/DIV release and a_write_debt==0. A still-open partial fill uses actual matching fill_cancel and its real held response.

For the current real row-major F32 path, descriptor validation admits only legal K; successful frozen quant words pass legal half-scale checks before A write; parent input uniqueness/order and at most128*(K/32) accepted groups imply exactly one unique write per coordinate on success. The physical cache can therefore publish status0 only. A numeric quant error suppresses at least one write, so it remains partial and requires cancel. Caller duplicates in the pure layer at this maximum input count cause missing coverage, not naturally a nonzero publication. They cannot be cited as a real failed-publication example.

The separate m007_quant_a_peer_tb legally returns a failed publication after real acknowledgements and validates bounded pure adapter termination and no-reset re-quantization with the actual frozen quantizer and real DIV. It has no physical A cache and may claim only that control-interface scope. Main F32 normal/error tests retain the real physical A cache.
