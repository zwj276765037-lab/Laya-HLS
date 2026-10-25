# Actual F32 full-run cost projection

The complete F32 service cap already includes all input quantization, real A config/write/ack/publication/release and cold W. The TB never prefills A. Therefore projected TB cycles are joint cap + N/32 coefficient-load allowance +128 bounded command/preparation/done-hold cycles; adding another2*128*(K/32) A-fill term inherited from the old prequantized runner would double-count work absent from this TB.

Admission still requires actual same-version prefix PASS, the largest applicable actual complete-checker cost floor (explicit previous-DUT baseline labeled separately),1.35 safety factor and10s fixed reserve. Estimate must fit both requested single timeout<=1200 and independent remaining RTL budget after directed reserve. A cost gate never substitutes a performance PASS or permits timeout extension.
