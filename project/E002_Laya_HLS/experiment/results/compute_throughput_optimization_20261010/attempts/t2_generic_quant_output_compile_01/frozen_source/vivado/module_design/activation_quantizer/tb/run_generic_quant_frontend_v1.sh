#!/usr/bin/env bash
set -euo pipefail
work=$(realpath "$1")
root=$(realpath "$(dirname "$0")/../../../..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$work"
m="$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"
q="$root/vivado/module_design/activation_quantizer"
"$xbin/xvlog" --sv -work xil_defaultlib \
 "$root/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv" \
 "$q/rtl/quant16_slot_banks.sv" "$q/rtl/quant16_amax16.sv" "$q/rtl/quant16_half_rne.sv" "$q/rtl/quant16_tiny_div127.sv" "$q/rtl/quant16_divider_service.sv" "$q/rtl/quant16_stream_row.sv" \
 "$q/rtl/quant_a_row_bank_v1.sv" "$q/rtl/quant_dual_a_v1.sv" "$q/rtl/quant_f32_row_bank_v1.sv" "$q/rtl/quant_f32_two_row_feeder_v1.sv" "$q/rtl/quant_task_to_dual_a_v1.sv" "$q/rtl/geglu_gate_writer_ledger_v1.sv" \
 "$m/rtl/tm4tn8_bias_bits_v1.sv" "$m/rtl/tm4tn8_bias_output_v1.sv" "$m/rtl/tm4tn8_final_ps_adapter_v1.sv" "$m/rtl/tm4tn8_axi512_writer_v1.sv" -log xvlog.log
if rg -q 'ERROR:' xvlog.log; then exit 1; fi
echo GENERIC_QUANT_AND_OUTPUT_FRONTEND_PASS
