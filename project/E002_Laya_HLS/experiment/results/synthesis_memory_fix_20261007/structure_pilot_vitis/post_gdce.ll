; ModuleID = 'build/structure-pilot-vitis/csynth/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.laya::full::FullRuntime" = type { %"struct.laya::full::FullInputs", %"struct.laya::full::FullOwners", %"struct.laya::full::FullCache", %"struct.laya::full::FullWeightDescriptor", %"struct.laya::BufferRef", [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"], %"struct.laya::BufferRef", %"struct.laya::BufferRef", %"struct.laya::BufferRef", %"struct.laya::BufferRef", [2 x %"struct.laya::BufferRef"], i8, i8, i8, i8, i8, i16, i1, %"struct.laya::full::FullOwnerSpec", [4 x %"struct.laya::full::FullOwnerSpec"], i8, i8, i8, i32, i32, [256 x i32], i32, i32, i8, i8, i64, i64, i64, i64, i16, i16, i1, i1, %"struct.laya::Check", %"struct.laya::Check", %"struct.laya::Check", i1, i1, i1 }
%"struct.laya::full::FullInputs" = type { %"struct.laya::NumericIdentity", [2 x [1024 x i32]], [2 x [16 x i32]], [2 x [1024 x i8]], [2 x [16 x i8]], [2 x i8] }
%"struct.laya::NumericIdentity" = type { i64, i64, i16, i16, [16 x i8], [16 x i8], [16 x i8], [16 x i8] }
%"struct.laya::full::FullOwners" = type { [32 x %"struct.laya::full::FullOwnerRecord"], [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]], [16 x [2 x [32 x i32]]], [2 x i16], [2 x i16], [3 x i1] }
%"struct.laya::full::FullOwnerRecord" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", %"struct.laya::BufferRef", i32, i8, i8, i8, i8, i8, i16, i16, i16, i8, i8, i8, [64 x i32], [64 x i32], i1 }
%"struct.laya::full::FullCache" = type { %"struct.laya::F32TileMeta", %"struct.laya::A8TileMeta" }
%"struct.laya::F32TileMeta" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", i8, i8, i8, i16, i8, i16, i8, i8, i8, [16 x [4 x i32]], i1 }
%"struct.laya::A8TileMeta" = type { %"struct.laya::NumericIdentity", %"struct.laya::BufferRef", %"struct.laya::F32TileMeta", i32, i8, i8, i8, i8, i16, i8, i16, [16 x [4 x i32]], i8, i8, i8, i1 }
%"struct.laya::full::FullWeightDescriptor" = type { [48 x i8], %"struct.laya::WeightKey", i16, i16, i8, i8, [2 x i32], [2 x i32], i32, i32, i32, i32, i32, i32, [32 x i8], [32 x i8] }
%"struct.laya::WeightKey" = type { i8, i8 }
%"struct.laya::BufferRef" = type { i8, i8, i32 }
%"struct.laya::full::FullOwnerSpec" = type { %"struct.laya::BufferRef", i8, i8, i8, i8, i8, i16, i16, i16, i8 }
%"struct.laya::Check" = type { i16, i32, i64 }
%"class.fp_struct<float>" = type { %"struct.ap_uint<1>", %"struct.ap_ufixed<8, 8, AP_TRN_ZERO, AP_WRAP, 0>", %"struct.ap_uint<23>" }
%"struct.ap_uint<1>" = type { %"struct.ap_int_base<1, false>" }
%"struct.ap_int_base<1, false>" = type { %"struct.ssdm_int<1, false>" }
%"struct.ssdm_int<1, false>" = type { i1 }
%"struct.ap_ufixed<8, 8, AP_TRN_ZERO, AP_WRAP, 0>" = type { %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>" }
%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>" = type { %"struct.ssdm_int<8, false>" }
%"struct.ssdm_int<8, false>" = type { i8 }
%"struct.ap_uint<23>" = type { %"struct.ap_int_base<23, false>" }
%"struct.ap_int_base<23, false>" = type { %"struct.ssdm_int<23, false>" }
%"struct.ssdm_int<23, false>" = type { i23 }
%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>" = type { %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>" }
%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>" = type { %"struct.ssdm_int<79, false>" }
%"struct.ssdm_int<79, false>" = type { i79 }
%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>" = type { %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>" }
%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>" = type { %"struct.ssdm_int<24, false>" }
%"struct.ssdm_int<24, false>" = type { i24 }
%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>" = type { %"struct.ap_int_base<32, true>" }
%"struct.ap_int_base<32, true>" = type { %"struct.ssdm_int<32, true>" }
%"struct.ssdm_int<32, true>" = type { i32 }
%union.single_cast = type { float }
%"struct.ap_bit_ref<32, true>" = type { %"struct.ap_int_base<32, true>"*, i32 }
%"struct.ap_bit_ref<1, false>" = type { %"struct.ap_int_base<1, false>"*, i32 }
%"struct.ap_range_ref<32, false>" = type { %"struct.ap_int_base<32, true>"*, i32, i32 }
%"struct.ap_range_ref<8, false>" = type { %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, i32, i32 }
%"struct.ap_range_ref<23, false>" = type { %"struct.ap_int_base<23, false>"*, i32, i32 }
%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>" = type { %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, i32, i32 }
%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>" = type { %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, i32 }
%"struct.ap_int<33>" = type { %"struct.ap_int_base<33, true>" }
%"struct.ap_int_base<33, true>" = type { %"struct.ssdm_int<33, true>" }
%"struct.ssdm_int<33, true>" = type { i33 }
%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>" = type { %"struct.ssdm_int<34, false>" }
%"struct.ssdm_int<34, false>" = type { i34 }

$_ZN4laya4full19full_cache_weight_qERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full23full_cache_weight_scaleERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full22full_cache_weight_biasERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full23full_cache_activation_qERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full27full_cache_activation_scaleERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full21full_cache_input_tileERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full18full_cache_ps_tileERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full16full_cache_gammaERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full21full_cache_rope_tableERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full13full_cache_kvERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full16full_cache_scoreERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full21full_cache_av_partialERNS0_11FullRuntimeE = comdat any

$_ZN4laya4full24full_cache_fp_act_weightERNS0_11FullRuntimeE = comdat any

$_Z20generic_cast_IEEE754IjfET_T0_b = comdat any

$_Z20generic_cast_IEEE754IjL9ap_q_mode6EfET_T1_bN3hls9enable_ifIXntsr3std14numeric_limitsIS1_EE9is_signedEbE4typeE = comdat any

$_ZN9fp_structIfEC2Ef = comdat any

$_ZNK9fp_structIfE8mantissaEv = comdat any

$_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZNK9fp_structIfE4expvEv = comdat any

$_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEi = comdat any

$_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN9ap_ufixedILi1ELi33EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN9ap_ufixedILi32ELi32EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZneILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EEi = comdat any

$_ZN7ap_uintILi32EEC2Ei = comdat any

$_ZNK9fp_structIfE9__signbitEv = comdat any

$_ZeqILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbiRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZneILi23ELb0EEbiRK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZeqILi8ELb0EEbRK11ap_int_baseIXT_EXT0_EEi = comdat any

$_ZNK11ap_int_baseILi32ELb0EEcvyEv = comdat any

$_ZN8ap_fixedILi32ELi32EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEcvjEv = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE7to_uintEv = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE14to_ap_int_baseEb = comdat any

$_ZNK11ap_int_baseILi32ELb1EE7to_uintEv = comdat any

$_ZN11ap_int_baseILi32ELb1EEC2Ei = comdat any

$"_ZplILi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE4plusERKS1_i" = comdat any

$_ZN11ap_int_baseILi32ELb1EEaSILi33ELb1EEERS0_RKS_IXT_EXT0_EE = comdat any

$_ZplILi32ELb1ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE4plusERKS1_RKS0_IXT1_EXT2_EE = comdat any

$_ZN11ap_int_baseILi33ELb1EEC2ILi32ELb1EEERKS_IXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi33ELb1EEC2Ei = comdat any

$_ZN6ap_intILi33EEC2ILi33ELb1EEERK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZN8ssdm_intILi33ELb1EEC2EDq33_i = comdat any

$_ZN8ssdm_intILi32ELb1EEC2Ei = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEntEv = comdat any

$_ZNK11ap_int_baseILi8ELb0EEeqILi32ELb1EEEbRKS_IXT_EXT0_EE = comdat any

$_ZNK11ap_int_baseILi32ELb1EEneILi23ELb0EEEbRKS_IXT_EXT0_EE = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEeqILi1ELi33ELb0ELS0_5ELS1_0ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN8ssdm_intILi33ELb0EEC2EDq33_j = comdat any

$_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv = comdat any

$_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEntEv = comdat any

$_ZNK11ap_int_baseILi1ELb0EE6to_intEv = comdat any

$_ZN11ap_int_baseILi32ELb0EEC2Ei = comdat any

$_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIiEEvT_ = comdat any

$_ZN8ssdm_intILi32ELb0EEC2Ej = comdat any

$_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEneILi32ELi32ELb1ELS0_5ELS1_3ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN8ssdm_intILi34ELb0EEC2EDq34_j = comdat any

$_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EE6reportEv = comdat any

$_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv = comdat any

$_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN8ssdm_intILi1ELb0EEC2EDq1_j = comdat any

$_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv = comdat any

$_ZN11ap_int_baseILi79ELb0EEC2Ei = comdat any

$_ZrsILi79ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT_EXT0_EE4arg1ERKS1_i = comdat any

$_ZNK11ap_int_baseILi79ELb0EEeqILi79ELb0EEEbRKS_IXT_EXT0_EE = comdat any

$_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE15overflow_adjustEbbbb = comdat any

$_ZN11ap_int_baseILi1ELb0EEC2Ei = comdat any

$_ZN7ap_uintILi79EEC2ILi79ELb0EEERK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZN8ssdm_intILi79ELb0EEC2EDq79_j = comdat any

$_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei = comdat any

$_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EErsEj = comdat any

$_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEj = comdat any

$_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv = comdat any

$"_ZmiILi8ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE5minusERKS1_i" = comdat any

$_ZNK11ap_int_baseILi33ELb1EEcvxEv = comdat any

$_ZmiILi8ELb0ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE5minusERKS1_RKS0_IXT1_EXT2_EE = comdat any

$_ZN11ap_int_baseILi33ELb1EEC2ILi8ELb0EEERKS_IXT_EXT0_EE = comdat any

$_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv = comdat any

$_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv = comdat any

$_ZN9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei = comdat any

$_ZNK11ap_int_baseILi23ELb0EEclEii = comdat any

$_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE2wlEv = comdat any

$_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEclEii = comdat any

$_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK12ap_range_refIXT_EXT0_EE = comdat any

$_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEixEj = comdat any

$_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSEb = comdat any

$_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEi = comdat any

$_ZN11ap_int_baseILi23ELb0EEC2ILi23ELb0EEERK12ap_range_refIXT_EXT0_EE = comdat any

$_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZNK12ap_range_refILi23ELb0EE3getEv = comdat any

$_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE5rangeEii = comdat any

$_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEii = comdat any

$_ZNK11ap_int_baseILi23ELb0EE5rangeEii = comdat any

$_ZN12ap_range_refILi23ELb0EEC2EP11ap_int_baseILi23ELb0EEii = comdat any

$_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei = comdat any

$_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE = comdat any

$_ZN7ap_uintILi32EEC2Ej = comdat any

$_ZN11ap_int_baseILi32ELb0EEixEi = comdat any

$_ZN11ap_int_baseILi1ELb0EEixEi = comdat any

$_ZN10ap_bit_refILi1ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi32ELb0EEclEii = comdat any

$_ZN11ap_int_baseILi8ELb0EEclEii = comdat any

$_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi23ELb0EEclEii = comdat any

$_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi32ELb0EEC2ILi32ELb0EEERK12ap_range_refIXT_EXT0_EE = comdat any

$_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi23ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE = comdat any

$_ZN8ssdm_intILi23ELb0EEC2EDq23_j = comdat any

$_ZNK12ap_range_refILi32ELb0EE3getEv = comdat any

$_ZN11ap_int_baseILi23ELb0EE5rangeEii = comdat any

$_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE = comdat any

$_ZN11ap_int_baseILi8ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE = comdat any

$_ZN8ssdm_intILi8ELb0EEC2Eh = comdat any

$_ZN11ap_int_baseILi8ELb0EE5rangeEii = comdat any

$_ZN12ap_range_refILi8ELb0EEC2EP11ap_int_baseILi8ELb0EEii = comdat any

$_ZN11ap_int_baseILi32ELb0EE5rangeEii = comdat any

$_ZN12ap_range_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEii = comdat any

$_ZNK10ap_bit_refILi32ELb0EEcvbEv = comdat any

$_ZN10ap_bit_refILi1ELb0EEaSEy = comdat any

$_ZN10ap_bit_refILi1ELb0EEC2EP11ap_int_baseILi1ELb0EEi = comdat any

$_ZN10ap_bit_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEi = comdat any

$_ZN11ap_int_baseILi32ELb0EEC2Ej = comdat any

$_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIjEEvT_ = comdat any

@_ZN4laya4full21g_full_cache_weight_qE = dso_local global [5373952 x i8] zeroinitializer, align 1, !dbg !0
@_ZN4laya4full25g_full_cache_weight_scaleE = dso_local global [167936 x i16] zeroinitializer, align 2, !dbg !15
@_ZN4laya4full24g_full_cache_weight_biasE = dso_local global [5248 x float] zeroinitializer, align 4, !dbg !25
@_ZN4laya4full25g_full_cache_activation_qE = dso_local global [16 x [128 x [32 x i8]]] zeroinitializer, align 1, !dbg !32
@_ZN4laya4full29g_full_cache_activation_scaleE = dso_local global [16 x [128 x i16]] zeroinitializer, align 2, !dbg !40
@_ZN4laya4full23g_full_cache_input_tileE = dso_local global [16 x [4096 x float]] zeroinitializer, align 4, !dbg !45
@_ZN4laya4full20g_full_cache_ps_tileE = dso_local global [16 x [5248 x float]] zeroinitializer, align 4, !dbg !51
@_ZN4laya4full18g_full_cache_gammaE = dso_local global [2 x [1024 x float]] zeroinitializer, align 4, !dbg !56
@_ZN4laya4full23g_full_cache_rope_tableE = dso_local global [2 x [1025 x [64 x float]]] zeroinitializer, align 4, !dbg !63
@_ZN4laya4full15g_full_cache_kvE = dso_local global [2 x [2 x [1024 x [64 x float]]]] zeroinitializer, align 4, !dbg !70
@_ZN4laya4full18g_full_cache_scoreE = dso_local global [2 x [16 x [1024 x float]]] zeroinitializer, align 4, !dbg !75
@_ZN4laya4full23g_full_cache_av_partialE = dso_local global [16 x [64 x float]] zeroinitializer, align 4, !dbg !80
@_ZN4laya4full26g_full_cache_fp_act_weightE = dso_local global [256 x [1028 x i16]] zeroinitializer, align 2, !dbg !85
@llvm.global_ctors = appending global [0 x { i32, void ()*, i8* }] zeroinitializer
@_ZZ26full_cache_structure_pilotE7runtime = internal global %"struct.laya::full::FullRuntime" { %"struct.laya::full::FullInputs" zeroinitializer, %"struct.laya::full::FullOwners" { [32 x %"struct.laya::full::FullOwnerRecord"] [%"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }, %"struct.laya::full::FullOwnerRecord" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i32 0, i8 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i16 0, i16 0, i8 0, i8 6, i8 0, [64 x i32] zeroinitializer, [64 x i32] zeroinitializer, i1 false }], [2 x [3 x [16 x [2 x [32 x i32]]]]] zeroinitializer, [2 x [2 x [16 x [2 x [32 x i32]]]]] zeroinitializer, [16 x [2 x [32 x i32]]] zeroinitializer, [2 x i16] zeroinitializer, [2 x i16] zeroinitializer, [3 x i1] zeroinitializer }, %"struct.laya::full::FullCache" { %"struct.laya::F32TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 0, i16 0, i8 0, i16 0, i8 6, i8 0, i8 0, [16 x [4 x i32]] zeroinitializer, i1 false }, %"struct.laya::A8TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::F32TileMeta" { %"struct.laya::NumericIdentity" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 0, i16 0, i8 0, i16 0, i8 6, i8 0, i8 0, [16 x [4 x i32]] zeroinitializer, i1 false }, i32 0, i8 0, i8 -1, i8 0, i8 0, i16 0, i8 0, i16 0, [16 x [4 x i32]] zeroinitializer, i8 6, i8 0, i8 0, i1 false } }, %"struct.laya::full::FullWeightDescriptor" { [48 x i8] zeroinitializer, %"struct.laya::WeightKey" { i8 0, i8 -1 }, i16 0, i16 0, i8 0, i8 0, [2 x i32] zeroinitializer, [2 x i32] zeroinitializer, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, [32 x i8] zeroinitializer, [32 x i8] zeroinitializer }, %"struct.laya::BufferRef" zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, %"struct.laya::BufferRef" zeroinitializer, [2 x %"struct.laya::BufferRef"] zeroinitializer, i8 -1, i8 0, i8 -1, i8 -1, i8 0, i16 0, i1 false, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, [4 x %"struct.laya::full::FullOwnerSpec"] [%"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }, %"struct.laya::full::FullOwnerSpec" { %"struct.laya::BufferRef" zeroinitializer, i8 0, i8 0, i8 -1, i8 -1, i8 0, i16 0, i16 0, i16 0, i8 0 }], i8 0, i8 -1, i8 -1, i32 0, i32 0, [256 x i32] zeroinitializer, i32 0, i32 0, i8 0, i8 0, i64 0, i64 0, i64 0, i64 0, i16 0, i16 0, i1 false, i1 false, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, %"struct.laya::Check" { i16 0, i32 0, i64 -1 }, i1 false, i1 false, i1 false }, align 8, !dbg !92

; Function Attrs: nounwind
define dso_local void @full_cache_structure_pilot(i8 zeroext %target, i32 %i, i32 %j, i32 %k, i32 %l, i32 %value, i1 zeroext %write_enable, i32* %result, i32* %status) #0 !dbg !94 !fpga.function.pragma !3457 {
entry:
  %target.addr = alloca i8, align 1
  %i.addr = alloca i32, align 4
  %j.addr = alloca i32, align 4
  %k.addr = alloca i32, align 4
  %l.addr = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %write_enable.addr = alloca i1, align 1
  %result.addr = alloca i32*, align 8
  %status.addr = alloca i32*, align 8
  store i8 %target, i8* %target.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %target.addr, metadata !3460, metadata !DIExpression()), !dbg !3461
  store i32 %i, i32* %i.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %i.addr, metadata !3462, metadata !DIExpression()), !dbg !3463
  store i32 %j, i32* %j.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %j.addr, metadata !3464, metadata !DIExpression()), !dbg !3465
  store i32 %k, i32* %k.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %k.addr, metadata !3466, metadata !DIExpression()), !dbg !3467
  store i32 %l, i32* %l.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %l.addr, metadata !3468, metadata !DIExpression()), !dbg !3469
  store i32 %value, i32* %value.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %value.addr, metadata !3470, metadata !DIExpression()), !dbg !3471
  store i1 %write_enable, i1* %write_enable.addr, align 1
  call void @llvm.dbg.declare(metadata i1* %write_enable.addr, metadata !3472, metadata !DIExpression()), !dbg !3473
  store i32* %result, i32** %result.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %result.addr, metadata !3474, metadata !DIExpression()), !dbg !3475
  store i32* %status, i32** %status.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %status.addr, metadata !3476, metadata !DIExpression()), !dbg !3477
  call void @llvm.sideeffect() #34 [ "xlx_s_axilite"(i8 %target, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3478
  call void @llvm.sideeffect() #35 [ "xlx_s_axilite"(i32 %i, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3480
  call void @llvm.sideeffect() #35 [ "xlx_s_axilite"(i32 %j, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3481
  call void @llvm.sideeffect() #35 [ "xlx_s_axilite"(i32 %k, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3482
  call void @llvm.sideeffect() #35 [ "xlx_s_axilite"(i32 %l, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3483
  call void @llvm.sideeffect() #35 [ "xlx_s_axilite"(i32 %value, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3484
  call void @llvm.sideeffect() #34 [ "xlx_s_axilite"(i1 %write_enable, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3485
  call void @llvm.sideeffect() #36 [ "xlx_s_axilite"(i32* %result, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3486
  call void @llvm.sideeffect() #36 [ "xlx_s_axilite"(i32* %status, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3487
  call void @llvm.sideeffect() #36 [ "xlx_s_axilite"(i8* null, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !3488
  call void @llvm.sideeffect() #37 [ "xlx_bind_storage"([5373952 x i8]* @_ZN4laya4full21g_full_cache_weight_qE, i32 666, i32 20, i32 -1, i1 false) ], !dbg !3489
  call void @llvm.sideeffect() #38 [ "xlx_bind_storage"([167936 x i16]* @_ZN4laya4full25g_full_cache_weight_scaleE, i32 666, i32 20, i32 -1, i1 false) ], !dbg !3490
  call void @llvm.sideeffect() #37 [ "xlx_array_reshape"([5373952 x i8]* @_ZN4laya4full21g_full_cache_weight_qE, i32 0, i64 8, i64 1) ], !dbg !3491
  call void @llvm.sideeffect() #38 [ "xlx_array_reshape"([167936 x i16]* @_ZN4laya4full25g_full_cache_weight_scaleE, i32 0, i64 4, i64 1) ], !dbg !3492
  %0 = load i32*, i32** %result.addr, align 8, !dbg !3493
  store i32 0, i32* %0, align 4, !dbg !3494
  %1 = load i32*, i32** %status.addr, align 8, !dbg !3495
  store i32 0, i32* %1, align 4, !dbg !3496
  %2 = load i8, i8* %target.addr, align 1, !dbg !3497
  %conv = zext i8 %2 to i32, !dbg !3497
  switch i32 %conv, label %sw.default [
    i32 0, label %sw.bb
    i32 1, label %sw.bb8
    i32 2, label %sw.bb25
    i32 3, label %sw.bb42
    i32 4, label %sw.bb70
    i32 5, label %sw.bb93
    i32 6, label %sw.bb116
    i32 7, label %sw.bb139
    i32 8, label %sw.bb162
    i32 9, label %sw.bb191
    i32 10, label %sw.bb226
    i32 11, label %sw.bb255
    i32 12, label %sw.bb278
    i32 13, label %sw.bb301
  ], !dbg !3498

sw.bb:                                            ; preds = %entry
  %3 = load i32, i32* %i.addr, align 4, !dbg !3499
  %cmp = icmp uge i32 %3, 5373952, !dbg !3502
  br i1 %cmp, label %if.then, label %if.end, !dbg !3503

if.then:                                          ; preds = %sw.bb
  br label %sw.epilog, !dbg !3504

if.end:                                           ; preds = %sw.bb
  br label %VITIS_LOOP_37_1, !dbg !3505

VITIS_LOOP_37_1:                                  ; preds = %if.end
  br label %do.body, !dbg !3506

do.body:                                          ; preds = %VITIS_LOOP_37_1
  %4 = load i1, i1* %write_enable.addr, align 1, !dbg !3507
  br i1 %4, label %if.then1, label %if.else, !dbg !3510

if.then1:                                         ; preds = %do.body
  %5 = load i32, i32* %value.addr, align 4, !dbg !3511
  %conv2 = trunc i32 %5 to i8, !dbg !3511
  %call = call nonnull align 1 dereferenceable(5373952) [5373952 x i8]* @_ZN4laya4full19full_cache_weight_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3512
  %6 = load i32, i32* %i.addr, align 4, !dbg !3513
  %idxprom = zext i32 %6 to i64, !dbg !3512
  %arrayidx = getelementptr inbounds [5373952 x i8], [5373952 x i8]* %call, i64 0, i64 %idxprom, !dbg !3512
  store i8 %conv2, i8* %arrayidx, align 1, !dbg !3514
  br label %if.end7, !dbg !3515

if.else:                                          ; preds = %do.body
  %call3 = call nonnull align 1 dereferenceable(5373952) [5373952 x i8]* @_ZN4laya4full19full_cache_weight_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3516
  %7 = load i32, i32* %i.addr, align 4, !dbg !3517
  %idxprom4 = zext i32 %7 to i64, !dbg !3516
  %arrayidx5 = getelementptr inbounds [5373952 x i8], [5373952 x i8]* %call3, i64 0, i64 %idxprom4, !dbg !3516
  %8 = load i8, i8* %arrayidx5, align 1, !dbg !3516
  %conv6 = sext i8 %8 to i32, !dbg !3516
  %9 = load i32*, i32** %result.addr, align 8, !dbg !3518
  store i32 %conv6, i32* %9, align 4, !dbg !3519
  br label %if.end7

if.end7:                                          ; preds = %if.else, %if.then1
  br label %do.end, !dbg !3520

do.end:                                           ; preds = %if.end7
  br label %return, !dbg !3521

sw.bb8:                                           ; preds = %entry
  %10 = load i32, i32* %i.addr, align 4, !dbg !3522
  %cmp9 = icmp uge i32 %10, 167936, !dbg !3524
  br i1 %cmp9, label %if.then10, label %if.end11, !dbg !3525

if.then10:                                        ; preds = %sw.bb8
  br label %sw.epilog, !dbg !3526

if.end11:                                         ; preds = %sw.bb8
  br label %VITIS_LOOP_41_2, !dbg !3527

VITIS_LOOP_41_2:                                  ; preds = %if.end11
  br label %do.body12, !dbg !3528

do.body12:                                        ; preds = %VITIS_LOOP_41_2
  %11 = load i1, i1* %write_enable.addr, align 1, !dbg !3529
  br i1 %11, label %if.then13, label %if.else18, !dbg !3532

if.then13:                                        ; preds = %do.body12
  %12 = load i32, i32* %value.addr, align 4, !dbg !3533
  %conv14 = trunc i32 %12 to i16, !dbg !3533
  %call15 = call nonnull align 2 dereferenceable(335872) [167936 x i16]* @_ZN4laya4full23full_cache_weight_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3534
  %13 = load i32, i32* %i.addr, align 4, !dbg !3535
  %idxprom16 = zext i32 %13 to i64, !dbg !3534
  %arrayidx17 = getelementptr inbounds [167936 x i16], [167936 x i16]* %call15, i64 0, i64 %idxprom16, !dbg !3534
  store i16 %conv14, i16* %arrayidx17, align 2, !dbg !3536
  br label %if.end23, !dbg !3537

if.else18:                                        ; preds = %do.body12
  %call19 = call nonnull align 2 dereferenceable(335872) [167936 x i16]* @_ZN4laya4full23full_cache_weight_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3538
  %14 = load i32, i32* %i.addr, align 4, !dbg !3539
  %idxprom20 = zext i32 %14 to i64, !dbg !3538
  %arrayidx21 = getelementptr inbounds [167936 x i16], [167936 x i16]* %call19, i64 0, i64 %idxprom20, !dbg !3538
  %15 = load i16, i16* %arrayidx21, align 2, !dbg !3538
  %conv22 = zext i16 %15 to i32, !dbg !3538
  %16 = load i32*, i32** %result.addr, align 8, !dbg !3540
  store i32 %conv22, i32* %16, align 4, !dbg !3541
  br label %if.end23

if.end23:                                         ; preds = %if.else18, %if.then13
  br label %do.end24, !dbg !3542

do.end24:                                         ; preds = %if.end23
  br label %return, !dbg !3543

sw.bb25:                                          ; preds = %entry
  %17 = load i32, i32* %i.addr, align 4, !dbg !3544
  %cmp26 = icmp uge i32 %17, 5248, !dbg !3546
  br i1 %cmp26, label %if.then27, label %if.end28, !dbg !3547

if.then27:                                        ; preds = %sw.bb25
  br label %sw.epilog, !dbg !3548

if.end28:                                         ; preds = %sw.bb25
  br label %VITIS_LOOP_45_3, !dbg !3549

VITIS_LOOP_45_3:                                  ; preds = %if.end28
  br label %do.body29, !dbg !3550

do.body29:                                        ; preds = %VITIS_LOOP_45_3
  %18 = load i1, i1* %write_enable.addr, align 1, !dbg !3551
  br i1 %18, label %if.then30, label %if.else35, !dbg !3554

if.then30:                                        ; preds = %do.body29
  %19 = load i32, i32* %value.addr, align 4, !dbg !3555
  %conv31 = uitofp i32 %19 to float, !dbg !3555
  %call32 = call nonnull align 4 dereferenceable(20992) [5248 x float]* @_ZN4laya4full22full_cache_weight_biasERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3556
  %20 = load i32, i32* %i.addr, align 4, !dbg !3557
  %idxprom33 = zext i32 %20 to i64, !dbg !3556
  %arrayidx34 = getelementptr inbounds [5248 x float], [5248 x float]* %call32, i64 0, i64 %idxprom33, !dbg !3556
  store float %conv31, float* %arrayidx34, align 4, !dbg !3558
  br label %if.end40, !dbg !3559

if.else35:                                        ; preds = %do.body29
  %call36 = call nonnull align 4 dereferenceable(20992) [5248 x float]* @_ZN4laya4full22full_cache_weight_biasERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3560
  %21 = load i32, i32* %i.addr, align 4, !dbg !3561
  %idxprom37 = zext i32 %21 to i64, !dbg !3560
  %arrayidx38 = getelementptr inbounds [5248 x float], [5248 x float]* %call36, i64 0, i64 %idxprom37, !dbg !3560
  %22 = load float, float* %arrayidx38, align 4, !dbg !3560
  %conv39 = call i32 @__hls_fptoui_float_i32(float %22), !dbg !3560
  %23 = load i32*, i32** %result.addr, align 8, !dbg !3562
  store i32 %conv39, i32* %23, align 4, !dbg !3563
  br label %if.end40

if.end40:                                         ; preds = %if.else35, %if.then30
  br label %do.end41, !dbg !3564

do.end41:                                         ; preds = %if.end40
  br label %return, !dbg !3565

sw.bb42:                                          ; preds = %entry
  %24 = load i32, i32* %i.addr, align 4, !dbg !3566
  %cmp43 = icmp uge i32 %24, 16, !dbg !3568
  br i1 %cmp43, label %if.then47, label %lor.lhs.false, !dbg !3569

lor.lhs.false:                                    ; preds = %sw.bb42
  %25 = load i32, i32* %j.addr, align 4, !dbg !3570
  %cmp44 = icmp uge i32 %25, 128, !dbg !3571
  br i1 %cmp44, label %if.then47, label %lor.lhs.false45, !dbg !3572

lor.lhs.false45:                                  ; preds = %lor.lhs.false
  %26 = load i32, i32* %k.addr, align 4, !dbg !3573
  %cmp46 = icmp uge i32 %26, 32, !dbg !3574
  br i1 %cmp46, label %if.then47, label %if.end48, !dbg !3575

if.then47:                                        ; preds = %lor.lhs.false45, %lor.lhs.false, %sw.bb42
  br label %sw.epilog, !dbg !3576

if.end48:                                         ; preds = %lor.lhs.false45
  br label %VITIS_LOOP_49_4, !dbg !3577

VITIS_LOOP_49_4:                                  ; preds = %if.end48
  br label %do.body49, !dbg !3578

do.body49:                                        ; preds = %VITIS_LOOP_49_4
  %27 = load i1, i1* %write_enable.addr, align 1, !dbg !3579
  br i1 %27, label %if.then50, label %if.else59, !dbg !3582

if.then50:                                        ; preds = %do.body49
  %28 = load i32, i32* %value.addr, align 4, !dbg !3583
  %conv51 = trunc i32 %28 to i8, !dbg !3583
  %call52 = call nonnull align 1 dereferenceable(65536) [16 x [128 x [32 x i8]]]* @_ZN4laya4full23full_cache_activation_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3584
  %29 = load i32, i32* %i.addr, align 4, !dbg !3585
  %idxprom53 = zext i32 %29 to i64, !dbg !3584
  %arrayidx54 = getelementptr inbounds [16 x [128 x [32 x i8]]], [16 x [128 x [32 x i8]]]* %call52, i64 0, i64 %idxprom53, !dbg !3584
  %30 = load i32, i32* %j.addr, align 4, !dbg !3586
  %idxprom55 = zext i32 %30 to i64, !dbg !3584
  %arrayidx56 = getelementptr inbounds [128 x [32 x i8]], [128 x [32 x i8]]* %arrayidx54, i64 0, i64 %idxprom55, !dbg !3584
  %31 = load i32, i32* %k.addr, align 4, !dbg !3587
  %idxprom57 = zext i32 %31 to i64, !dbg !3584
  %arrayidx58 = getelementptr inbounds [32 x i8], [32 x i8]* %arrayidx56, i64 0, i64 %idxprom57, !dbg !3584
  store i8 %conv51, i8* %arrayidx58, align 1, !dbg !3588
  br label %if.end68, !dbg !3589

if.else59:                                        ; preds = %do.body49
  %call60 = call nonnull align 1 dereferenceable(65536) [16 x [128 x [32 x i8]]]* @_ZN4laya4full23full_cache_activation_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3590
  %32 = load i32, i32* %i.addr, align 4, !dbg !3591
  %idxprom61 = zext i32 %32 to i64, !dbg !3590
  %arrayidx62 = getelementptr inbounds [16 x [128 x [32 x i8]]], [16 x [128 x [32 x i8]]]* %call60, i64 0, i64 %idxprom61, !dbg !3590
  %33 = load i32, i32* %j.addr, align 4, !dbg !3592
  %idxprom63 = zext i32 %33 to i64, !dbg !3590
  %arrayidx64 = getelementptr inbounds [128 x [32 x i8]], [128 x [32 x i8]]* %arrayidx62, i64 0, i64 %idxprom63, !dbg !3590
  %34 = load i32, i32* %k.addr, align 4, !dbg !3593
  %idxprom65 = zext i32 %34 to i64, !dbg !3590
  %arrayidx66 = getelementptr inbounds [32 x i8], [32 x i8]* %arrayidx64, i64 0, i64 %idxprom65, !dbg !3590
  %35 = load i8, i8* %arrayidx66, align 1, !dbg !3590
  %conv67 = sext i8 %35 to i32, !dbg !3590
  %36 = load i32*, i32** %result.addr, align 8, !dbg !3594
  store i32 %conv67, i32* %36, align 4, !dbg !3595
  br label %if.end68

if.end68:                                         ; preds = %if.else59, %if.then50
  br label %do.end69, !dbg !3596

do.end69:                                         ; preds = %if.end68
  br label %return, !dbg !3597

sw.bb70:                                          ; preds = %entry
  %37 = load i32, i32* %i.addr, align 4, !dbg !3598
  %cmp71 = icmp uge i32 %37, 16, !dbg !3600
  br i1 %cmp71, label %if.then74, label %lor.lhs.false72, !dbg !3601

lor.lhs.false72:                                  ; preds = %sw.bb70
  %38 = load i32, i32* %j.addr, align 4, !dbg !3602
  %cmp73 = icmp uge i32 %38, 128, !dbg !3603
  br i1 %cmp73, label %if.then74, label %if.end75, !dbg !3604

if.then74:                                        ; preds = %lor.lhs.false72, %sw.bb70
  br label %sw.epilog, !dbg !3605

if.end75:                                         ; preds = %lor.lhs.false72
  br label %VITIS_LOOP_53_5, !dbg !3606

VITIS_LOOP_53_5:                                  ; preds = %if.end75
  br label %do.body76, !dbg !3607

do.body76:                                        ; preds = %VITIS_LOOP_53_5
  %39 = load i1, i1* %write_enable.addr, align 1, !dbg !3608
  br i1 %39, label %if.then77, label %if.else84, !dbg !3611

if.then77:                                        ; preds = %do.body76
  %40 = load i32, i32* %value.addr, align 4, !dbg !3612
  %conv78 = trunc i32 %40 to i16, !dbg !3612
  %call79 = call nonnull align 2 dereferenceable(4096) [16 x [128 x i16]]* @_ZN4laya4full27full_cache_activation_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3613
  %41 = load i32, i32* %i.addr, align 4, !dbg !3614
  %idxprom80 = zext i32 %41 to i64, !dbg !3613
  %arrayidx81 = getelementptr inbounds [16 x [128 x i16]], [16 x [128 x i16]]* %call79, i64 0, i64 %idxprom80, !dbg !3613
  %42 = load i32, i32* %j.addr, align 4, !dbg !3615
  %idxprom82 = zext i32 %42 to i64, !dbg !3613
  %arrayidx83 = getelementptr inbounds [128 x i16], [128 x i16]* %arrayidx81, i64 0, i64 %idxprom82, !dbg !3613
  store i16 %conv78, i16* %arrayidx83, align 2, !dbg !3616
  br label %if.end91, !dbg !3617

if.else84:                                        ; preds = %do.body76
  %call85 = call nonnull align 2 dereferenceable(4096) [16 x [128 x i16]]* @_ZN4laya4full27full_cache_activation_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3618
  %43 = load i32, i32* %i.addr, align 4, !dbg !3619
  %idxprom86 = zext i32 %43 to i64, !dbg !3618
  %arrayidx87 = getelementptr inbounds [16 x [128 x i16]], [16 x [128 x i16]]* %call85, i64 0, i64 %idxprom86, !dbg !3618
  %44 = load i32, i32* %j.addr, align 4, !dbg !3620
  %idxprom88 = zext i32 %44 to i64, !dbg !3618
  %arrayidx89 = getelementptr inbounds [128 x i16], [128 x i16]* %arrayidx87, i64 0, i64 %idxprom88, !dbg !3618
  %45 = load i16, i16* %arrayidx89, align 2, !dbg !3618
  %conv90 = zext i16 %45 to i32, !dbg !3618
  %46 = load i32*, i32** %result.addr, align 8, !dbg !3621
  store i32 %conv90, i32* %46, align 4, !dbg !3622
  br label %if.end91

if.end91:                                         ; preds = %if.else84, %if.then77
  br label %do.end92, !dbg !3623

do.end92:                                         ; preds = %if.end91
  br label %return, !dbg !3624

sw.bb93:                                          ; preds = %entry
  %47 = load i32, i32* %i.addr, align 4, !dbg !3625
  %cmp94 = icmp uge i32 %47, 16, !dbg !3627
  br i1 %cmp94, label %if.then97, label %lor.lhs.false95, !dbg !3628

lor.lhs.false95:                                  ; preds = %sw.bb93
  %48 = load i32, i32* %j.addr, align 4, !dbg !3629
  %cmp96 = icmp uge i32 %48, 4096, !dbg !3630
  br i1 %cmp96, label %if.then97, label %if.end98, !dbg !3631

if.then97:                                        ; preds = %lor.lhs.false95, %sw.bb93
  br label %sw.epilog, !dbg !3632

if.end98:                                         ; preds = %lor.lhs.false95
  br label %VITIS_LOOP_57_6, !dbg !3633

VITIS_LOOP_57_6:                                  ; preds = %if.end98
  br label %do.body99, !dbg !3634

do.body99:                                        ; preds = %VITIS_LOOP_57_6
  %49 = load i1, i1* %write_enable.addr, align 1, !dbg !3635
  br i1 %49, label %if.then100, label %if.else107, !dbg !3638

if.then100:                                       ; preds = %do.body99
  %50 = load i32, i32* %value.addr, align 4, !dbg !3639
  %conv101 = uitofp i32 %50 to float, !dbg !3639
  %call102 = call nonnull align 4 dereferenceable(262144) [16 x [4096 x float]]* @_ZN4laya4full21full_cache_input_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3640
  %51 = load i32, i32* %i.addr, align 4, !dbg !3641
  %idxprom103 = zext i32 %51 to i64, !dbg !3640
  %arrayidx104 = getelementptr inbounds [16 x [4096 x float]], [16 x [4096 x float]]* %call102, i64 0, i64 %idxprom103, !dbg !3640
  %52 = load i32, i32* %j.addr, align 4, !dbg !3642
  %idxprom105 = zext i32 %52 to i64, !dbg !3640
  %arrayidx106 = getelementptr inbounds [4096 x float], [4096 x float]* %arrayidx104, i64 0, i64 %idxprom105, !dbg !3640
  store float %conv101, float* %arrayidx106, align 4, !dbg !3643
  br label %if.end114, !dbg !3644

if.else107:                                       ; preds = %do.body99
  %call108 = call nonnull align 4 dereferenceable(262144) [16 x [4096 x float]]* @_ZN4laya4full21full_cache_input_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3645
  %53 = load i32, i32* %i.addr, align 4, !dbg !3646
  %idxprom109 = zext i32 %53 to i64, !dbg !3645
  %arrayidx110 = getelementptr inbounds [16 x [4096 x float]], [16 x [4096 x float]]* %call108, i64 0, i64 %idxprom109, !dbg !3645
  %54 = load i32, i32* %j.addr, align 4, !dbg !3647
  %idxprom111 = zext i32 %54 to i64, !dbg !3645
  %arrayidx112 = getelementptr inbounds [4096 x float], [4096 x float]* %arrayidx110, i64 0, i64 %idxprom111, !dbg !3645
  %55 = load float, float* %arrayidx112, align 4, !dbg !3645
  %conv113 = call i32 @__hls_fptoui_float_i32(float %55), !dbg !3645
  %56 = load i32*, i32** %result.addr, align 8, !dbg !3648
  store i32 %conv113, i32* %56, align 4, !dbg !3649
  br label %if.end114

if.end114:                                        ; preds = %if.else107, %if.then100
  br label %do.end115, !dbg !3650

do.end115:                                        ; preds = %if.end114
  br label %return, !dbg !3651

sw.bb116:                                         ; preds = %entry
  %57 = load i32, i32* %i.addr, align 4, !dbg !3652
  %cmp117 = icmp uge i32 %57, 16, !dbg !3654
  br i1 %cmp117, label %if.then120, label %lor.lhs.false118, !dbg !3655

lor.lhs.false118:                                 ; preds = %sw.bb116
  %58 = load i32, i32* %j.addr, align 4, !dbg !3656
  %cmp119 = icmp uge i32 %58, 5248, !dbg !3657
  br i1 %cmp119, label %if.then120, label %if.end121, !dbg !3658

if.then120:                                       ; preds = %lor.lhs.false118, %sw.bb116
  br label %sw.epilog, !dbg !3659

if.end121:                                        ; preds = %lor.lhs.false118
  br label %VITIS_LOOP_61_7, !dbg !3660

VITIS_LOOP_61_7:                                  ; preds = %if.end121
  br label %do.body122, !dbg !3661

do.body122:                                       ; preds = %VITIS_LOOP_61_7
  %59 = load i1, i1* %write_enable.addr, align 1, !dbg !3662
  br i1 %59, label %if.then123, label %if.else130, !dbg !3665

if.then123:                                       ; preds = %do.body122
  %60 = load i32, i32* %value.addr, align 4, !dbg !3666
  %conv124 = uitofp i32 %60 to float, !dbg !3666
  %call125 = call nonnull align 4 dereferenceable(335872) [16 x [5248 x float]]* @_ZN4laya4full18full_cache_ps_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3667
  %61 = load i32, i32* %i.addr, align 4, !dbg !3668
  %idxprom126 = zext i32 %61 to i64, !dbg !3667
  %arrayidx127 = getelementptr inbounds [16 x [5248 x float]], [16 x [5248 x float]]* %call125, i64 0, i64 %idxprom126, !dbg !3667
  %62 = load i32, i32* %j.addr, align 4, !dbg !3669
  %idxprom128 = zext i32 %62 to i64, !dbg !3667
  %arrayidx129 = getelementptr inbounds [5248 x float], [5248 x float]* %arrayidx127, i64 0, i64 %idxprom128, !dbg !3667
  store float %conv124, float* %arrayidx129, align 4, !dbg !3670
  br label %if.end137, !dbg !3671

if.else130:                                       ; preds = %do.body122
  %call131 = call nonnull align 4 dereferenceable(335872) [16 x [5248 x float]]* @_ZN4laya4full18full_cache_ps_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3672
  %63 = load i32, i32* %i.addr, align 4, !dbg !3673
  %idxprom132 = zext i32 %63 to i64, !dbg !3672
  %arrayidx133 = getelementptr inbounds [16 x [5248 x float]], [16 x [5248 x float]]* %call131, i64 0, i64 %idxprom132, !dbg !3672
  %64 = load i32, i32* %j.addr, align 4, !dbg !3674
  %idxprom134 = zext i32 %64 to i64, !dbg !3672
  %arrayidx135 = getelementptr inbounds [5248 x float], [5248 x float]* %arrayidx133, i64 0, i64 %idxprom134, !dbg !3672
  %65 = load float, float* %arrayidx135, align 4, !dbg !3672
  %conv136 = call i32 @__hls_fptoui_float_i32(float %65), !dbg !3672
  %66 = load i32*, i32** %result.addr, align 8, !dbg !3675
  store i32 %conv136, i32* %66, align 4, !dbg !3676
  br label %if.end137

if.end137:                                        ; preds = %if.else130, %if.then123
  br label %do.end138, !dbg !3677

do.end138:                                        ; preds = %if.end137
  br label %return, !dbg !3678

sw.bb139:                                         ; preds = %entry
  %67 = load i32, i32* %i.addr, align 4, !dbg !3679
  %cmp140 = icmp uge i32 %67, 2, !dbg !3681
  br i1 %cmp140, label %if.then143, label %lor.lhs.false141, !dbg !3682

lor.lhs.false141:                                 ; preds = %sw.bb139
  %68 = load i32, i32* %j.addr, align 4, !dbg !3683
  %cmp142 = icmp uge i32 %68, 1024, !dbg !3684
  br i1 %cmp142, label %if.then143, label %if.end144, !dbg !3685

if.then143:                                       ; preds = %lor.lhs.false141, %sw.bb139
  br label %sw.epilog, !dbg !3686

if.end144:                                        ; preds = %lor.lhs.false141
  br label %VITIS_LOOP_65_8, !dbg !3687

VITIS_LOOP_65_8:                                  ; preds = %if.end144
  br label %do.body145, !dbg !3688

do.body145:                                       ; preds = %VITIS_LOOP_65_8
  %69 = load i1, i1* %write_enable.addr, align 1, !dbg !3689
  br i1 %69, label %if.then146, label %if.else153, !dbg !3692

if.then146:                                       ; preds = %do.body145
  %70 = load i32, i32* %value.addr, align 4, !dbg !3693
  %conv147 = uitofp i32 %70 to float, !dbg !3693
  %call148 = call nonnull align 4 dereferenceable(8192) [2 x [1024 x float]]* @_ZN4laya4full16full_cache_gammaERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3694
  %71 = load i32, i32* %i.addr, align 4, !dbg !3695
  %idxprom149 = zext i32 %71 to i64, !dbg !3694
  %arrayidx150 = getelementptr inbounds [2 x [1024 x float]], [2 x [1024 x float]]* %call148, i64 0, i64 %idxprom149, !dbg !3694
  %72 = load i32, i32* %j.addr, align 4, !dbg !3696
  %idxprom151 = zext i32 %72 to i64, !dbg !3694
  %arrayidx152 = getelementptr inbounds [1024 x float], [1024 x float]* %arrayidx150, i64 0, i64 %idxprom151, !dbg !3694
  store float %conv147, float* %arrayidx152, align 4, !dbg !3697
  br label %if.end160, !dbg !3698

if.else153:                                       ; preds = %do.body145
  %call154 = call nonnull align 4 dereferenceable(8192) [2 x [1024 x float]]* @_ZN4laya4full16full_cache_gammaERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3699
  %73 = load i32, i32* %i.addr, align 4, !dbg !3700
  %idxprom155 = zext i32 %73 to i64, !dbg !3699
  %arrayidx156 = getelementptr inbounds [2 x [1024 x float]], [2 x [1024 x float]]* %call154, i64 0, i64 %idxprom155, !dbg !3699
  %74 = load i32, i32* %j.addr, align 4, !dbg !3701
  %idxprom157 = zext i32 %74 to i64, !dbg !3699
  %arrayidx158 = getelementptr inbounds [1024 x float], [1024 x float]* %arrayidx156, i64 0, i64 %idxprom157, !dbg !3699
  %75 = load float, float* %arrayidx158, align 4, !dbg !3699
  %conv159 = call i32 @__hls_fptoui_float_i32(float %75), !dbg !3699
  %76 = load i32*, i32** %result.addr, align 8, !dbg !3702
  store i32 %conv159, i32* %76, align 4, !dbg !3703
  br label %if.end160

if.end160:                                        ; preds = %if.else153, %if.then146
  br label %do.end161, !dbg !3704

do.end161:                                        ; preds = %if.end160
  br label %return, !dbg !3705

sw.bb162:                                         ; preds = %entry
  %77 = load i32, i32* %i.addr, align 4, !dbg !3706
  %cmp163 = icmp uge i32 %77, 2, !dbg !3708
  br i1 %cmp163, label %if.then168, label %lor.lhs.false164, !dbg !3709

lor.lhs.false164:                                 ; preds = %sw.bb162
  %78 = load i32, i32* %j.addr, align 4, !dbg !3710
  %cmp165 = icmp uge i32 %78, 1025, !dbg !3711
  br i1 %cmp165, label %if.then168, label %lor.lhs.false166, !dbg !3712

lor.lhs.false166:                                 ; preds = %lor.lhs.false164
  %79 = load i32, i32* %k.addr, align 4, !dbg !3713
  %cmp167 = icmp uge i32 %79, 64, !dbg !3714
  br i1 %cmp167, label %if.then168, label %if.end169, !dbg !3715

if.then168:                                       ; preds = %lor.lhs.false166, %lor.lhs.false164, %sw.bb162
  br label %sw.epilog, !dbg !3716

if.end169:                                        ; preds = %lor.lhs.false166
  br label %VITIS_LOOP_69_9, !dbg !3717

VITIS_LOOP_69_9:                                  ; preds = %if.end169
  br label %do.body170, !dbg !3718

do.body170:                                       ; preds = %VITIS_LOOP_69_9
  %80 = load i1, i1* %write_enable.addr, align 1, !dbg !3719
  br i1 %80, label %if.then171, label %if.else180, !dbg !3722

if.then171:                                       ; preds = %do.body170
  %81 = load i32, i32* %value.addr, align 4, !dbg !3723
  %conv172 = uitofp i32 %81 to float, !dbg !3723
  %call173 = call nonnull align 4 dereferenceable(524800) [2 x [1025 x [64 x float]]]* @_ZN4laya4full21full_cache_rope_tableERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3724
  %82 = load i32, i32* %i.addr, align 4, !dbg !3725
  %idxprom174 = zext i32 %82 to i64, !dbg !3724
  %arrayidx175 = getelementptr inbounds [2 x [1025 x [64 x float]]], [2 x [1025 x [64 x float]]]* %call173, i64 0, i64 %idxprom174, !dbg !3724
  %83 = load i32, i32* %j.addr, align 4, !dbg !3726
  %idxprom176 = zext i32 %83 to i64, !dbg !3724
  %arrayidx177 = getelementptr inbounds [1025 x [64 x float]], [1025 x [64 x float]]* %arrayidx175, i64 0, i64 %idxprom176, !dbg !3724
  %84 = load i32, i32* %k.addr, align 4, !dbg !3727
  %idxprom178 = zext i32 %84 to i64, !dbg !3724
  %arrayidx179 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx177, i64 0, i64 %idxprom178, !dbg !3724
  store float %conv172, float* %arrayidx179, align 4, !dbg !3728
  br label %if.end189, !dbg !3729

if.else180:                                       ; preds = %do.body170
  %call181 = call nonnull align 4 dereferenceable(524800) [2 x [1025 x [64 x float]]]* @_ZN4laya4full21full_cache_rope_tableERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3730
  %85 = load i32, i32* %i.addr, align 4, !dbg !3731
  %idxprom182 = zext i32 %85 to i64, !dbg !3730
  %arrayidx183 = getelementptr inbounds [2 x [1025 x [64 x float]]], [2 x [1025 x [64 x float]]]* %call181, i64 0, i64 %idxprom182, !dbg !3730
  %86 = load i32, i32* %j.addr, align 4, !dbg !3732
  %idxprom184 = zext i32 %86 to i64, !dbg !3730
  %arrayidx185 = getelementptr inbounds [1025 x [64 x float]], [1025 x [64 x float]]* %arrayidx183, i64 0, i64 %idxprom184, !dbg !3730
  %87 = load i32, i32* %k.addr, align 4, !dbg !3733
  %idxprom186 = zext i32 %87 to i64, !dbg !3730
  %arrayidx187 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx185, i64 0, i64 %idxprom186, !dbg !3730
  %88 = load float, float* %arrayidx187, align 4, !dbg !3730
  %conv188 = call i32 @__hls_fptoui_float_i32(float %88), !dbg !3730
  %89 = load i32*, i32** %result.addr, align 8, !dbg !3734
  store i32 %conv188, i32* %89, align 4, !dbg !3735
  br label %if.end189

if.end189:                                        ; preds = %if.else180, %if.then171
  br label %do.end190, !dbg !3736

do.end190:                                        ; preds = %if.end189
  br label %return, !dbg !3737

sw.bb191:                                         ; preds = %entry
  %90 = load i32, i32* %i.addr, align 4, !dbg !3738
  %cmp192 = icmp uge i32 %90, 2, !dbg !3740
  br i1 %cmp192, label %if.then199, label %lor.lhs.false193, !dbg !3741

lor.lhs.false193:                                 ; preds = %sw.bb191
  %91 = load i32, i32* %j.addr, align 4, !dbg !3742
  %cmp194 = icmp uge i32 %91, 2, !dbg !3743
  br i1 %cmp194, label %if.then199, label %lor.lhs.false195, !dbg !3744

lor.lhs.false195:                                 ; preds = %lor.lhs.false193
  %92 = load i32, i32* %k.addr, align 4, !dbg !3745
  %cmp196 = icmp uge i32 %92, 1024, !dbg !3746
  br i1 %cmp196, label %if.then199, label %lor.lhs.false197, !dbg !3747

lor.lhs.false197:                                 ; preds = %lor.lhs.false195
  %93 = load i32, i32* %l.addr, align 4, !dbg !3748
  %cmp198 = icmp uge i32 %93, 64, !dbg !3749
  br i1 %cmp198, label %if.then199, label %if.end200, !dbg !3750

if.then199:                                       ; preds = %lor.lhs.false197, %lor.lhs.false195, %lor.lhs.false193, %sw.bb191
  br label %sw.epilog, !dbg !3751

if.end200:                                        ; preds = %lor.lhs.false197
  br label %VITIS_LOOP_73_10, !dbg !3752

VITIS_LOOP_73_10:                                 ; preds = %if.end200
  br label %do.body201, !dbg !3753

do.body201:                                       ; preds = %VITIS_LOOP_73_10
  %94 = load i1, i1* %write_enable.addr, align 1, !dbg !3754
  br i1 %94, label %if.then202, label %if.else213, !dbg !3757

if.then202:                                       ; preds = %do.body201
  %95 = load i32, i32* %value.addr, align 4, !dbg !3758
  %conv203 = uitofp i32 %95 to float, !dbg !3758
  %call204 = call nonnull align 4 dereferenceable(1048576) [2 x [2 x [1024 x [64 x float]]]]* @_ZN4laya4full13full_cache_kvERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3759
  %96 = load i32, i32* %i.addr, align 4, !dbg !3760
  %idxprom205 = zext i32 %96 to i64, !dbg !3759
  %arrayidx206 = getelementptr inbounds [2 x [2 x [1024 x [64 x float]]]], [2 x [2 x [1024 x [64 x float]]]]* %call204, i64 0, i64 %idxprom205, !dbg !3759
  %97 = load i32, i32* %j.addr, align 4, !dbg !3761
  %idxprom207 = zext i32 %97 to i64, !dbg !3759
  %arrayidx208 = getelementptr inbounds [2 x [1024 x [64 x float]]], [2 x [1024 x [64 x float]]]* %arrayidx206, i64 0, i64 %idxprom207, !dbg !3759
  %98 = load i32, i32* %k.addr, align 4, !dbg !3762
  %idxprom209 = zext i32 %98 to i64, !dbg !3759
  %arrayidx210 = getelementptr inbounds [1024 x [64 x float]], [1024 x [64 x float]]* %arrayidx208, i64 0, i64 %idxprom209, !dbg !3759
  %99 = load i32, i32* %l.addr, align 4, !dbg !3763
  %idxprom211 = zext i32 %99 to i64, !dbg !3759
  %arrayidx212 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx210, i64 0, i64 %idxprom211, !dbg !3759
  store float %conv203, float* %arrayidx212, align 4, !dbg !3764
  br label %if.end224, !dbg !3765

if.else213:                                       ; preds = %do.body201
  %call214 = call nonnull align 4 dereferenceable(1048576) [2 x [2 x [1024 x [64 x float]]]]* @_ZN4laya4full13full_cache_kvERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3766
  %100 = load i32, i32* %i.addr, align 4, !dbg !3767
  %idxprom215 = zext i32 %100 to i64, !dbg !3766
  %arrayidx216 = getelementptr inbounds [2 x [2 x [1024 x [64 x float]]]], [2 x [2 x [1024 x [64 x float]]]]* %call214, i64 0, i64 %idxprom215, !dbg !3766
  %101 = load i32, i32* %j.addr, align 4, !dbg !3768
  %idxprom217 = zext i32 %101 to i64, !dbg !3766
  %arrayidx218 = getelementptr inbounds [2 x [1024 x [64 x float]]], [2 x [1024 x [64 x float]]]* %arrayidx216, i64 0, i64 %idxprom217, !dbg !3766
  %102 = load i32, i32* %k.addr, align 4, !dbg !3769
  %idxprom219 = zext i32 %102 to i64, !dbg !3766
  %arrayidx220 = getelementptr inbounds [1024 x [64 x float]], [1024 x [64 x float]]* %arrayidx218, i64 0, i64 %idxprom219, !dbg !3766
  %103 = load i32, i32* %l.addr, align 4, !dbg !3770
  %idxprom221 = zext i32 %103 to i64, !dbg !3766
  %arrayidx222 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx220, i64 0, i64 %idxprom221, !dbg !3766
  %104 = load float, float* %arrayidx222, align 4, !dbg !3766
  %conv223 = call i32 @__hls_fptoui_float_i32(float %104), !dbg !3766
  %105 = load i32*, i32** %result.addr, align 8, !dbg !3771
  store i32 %conv223, i32* %105, align 4, !dbg !3772
  br label %if.end224

if.end224:                                        ; preds = %if.else213, %if.then202
  br label %do.end225, !dbg !3773

do.end225:                                        ; preds = %if.end224
  br label %return, !dbg !3774

sw.bb226:                                         ; preds = %entry
  %106 = load i32, i32* %i.addr, align 4, !dbg !3775
  %cmp227 = icmp uge i32 %106, 2, !dbg !3777
  br i1 %cmp227, label %if.then232, label %lor.lhs.false228, !dbg !3778

lor.lhs.false228:                                 ; preds = %sw.bb226
  %107 = load i32, i32* %j.addr, align 4, !dbg !3779
  %cmp229 = icmp uge i32 %107, 16, !dbg !3780
  br i1 %cmp229, label %if.then232, label %lor.lhs.false230, !dbg !3781

lor.lhs.false230:                                 ; preds = %lor.lhs.false228
  %108 = load i32, i32* %k.addr, align 4, !dbg !3782
  %cmp231 = icmp uge i32 %108, 1024, !dbg !3783
  br i1 %cmp231, label %if.then232, label %if.end233, !dbg !3784

if.then232:                                       ; preds = %lor.lhs.false230, %lor.lhs.false228, %sw.bb226
  br label %sw.epilog, !dbg !3785

if.end233:                                        ; preds = %lor.lhs.false230
  br label %VITIS_LOOP_77_11, !dbg !3786

VITIS_LOOP_77_11:                                 ; preds = %if.end233
  br label %do.body234, !dbg !3787

do.body234:                                       ; preds = %VITIS_LOOP_77_11
  %109 = load i1, i1* %write_enable.addr, align 1, !dbg !3788
  br i1 %109, label %if.then235, label %if.else244, !dbg !3791

if.then235:                                       ; preds = %do.body234
  %110 = load i32, i32* %value.addr, align 4, !dbg !3792
  %conv236 = uitofp i32 %110 to float, !dbg !3792
  %call237 = call nonnull align 4 dereferenceable(131072) [2 x [16 x [1024 x float]]]* @_ZN4laya4full16full_cache_scoreERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3793
  %111 = load i32, i32* %i.addr, align 4, !dbg !3794
  %idxprom238 = zext i32 %111 to i64, !dbg !3793
  %arrayidx239 = getelementptr inbounds [2 x [16 x [1024 x float]]], [2 x [16 x [1024 x float]]]* %call237, i64 0, i64 %idxprom238, !dbg !3793
  %112 = load i32, i32* %j.addr, align 4, !dbg !3795
  %idxprom240 = zext i32 %112 to i64, !dbg !3793
  %arrayidx241 = getelementptr inbounds [16 x [1024 x float]], [16 x [1024 x float]]* %arrayidx239, i64 0, i64 %idxprom240, !dbg !3793
  %113 = load i32, i32* %k.addr, align 4, !dbg !3796
  %idxprom242 = zext i32 %113 to i64, !dbg !3793
  %arrayidx243 = getelementptr inbounds [1024 x float], [1024 x float]* %arrayidx241, i64 0, i64 %idxprom242, !dbg !3793
  store float %conv236, float* %arrayidx243, align 4, !dbg !3797
  br label %if.end253, !dbg !3798

if.else244:                                       ; preds = %do.body234
  %call245 = call nonnull align 4 dereferenceable(131072) [2 x [16 x [1024 x float]]]* @_ZN4laya4full16full_cache_scoreERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3799
  %114 = load i32, i32* %i.addr, align 4, !dbg !3800
  %idxprom246 = zext i32 %114 to i64, !dbg !3799
  %arrayidx247 = getelementptr inbounds [2 x [16 x [1024 x float]]], [2 x [16 x [1024 x float]]]* %call245, i64 0, i64 %idxprom246, !dbg !3799
  %115 = load i32, i32* %j.addr, align 4, !dbg !3801
  %idxprom248 = zext i32 %115 to i64, !dbg !3799
  %arrayidx249 = getelementptr inbounds [16 x [1024 x float]], [16 x [1024 x float]]* %arrayidx247, i64 0, i64 %idxprom248, !dbg !3799
  %116 = load i32, i32* %k.addr, align 4, !dbg !3802
  %idxprom250 = zext i32 %116 to i64, !dbg !3799
  %arrayidx251 = getelementptr inbounds [1024 x float], [1024 x float]* %arrayidx249, i64 0, i64 %idxprom250, !dbg !3799
  %117 = load float, float* %arrayidx251, align 4, !dbg !3799
  %conv252 = call i32 @__hls_fptoui_float_i32(float %117), !dbg !3799
  %118 = load i32*, i32** %result.addr, align 8, !dbg !3803
  store i32 %conv252, i32* %118, align 4, !dbg !3804
  br label %if.end253

if.end253:                                        ; preds = %if.else244, %if.then235
  br label %do.end254, !dbg !3805

do.end254:                                        ; preds = %if.end253
  br label %return, !dbg !3806

sw.bb255:                                         ; preds = %entry
  %119 = load i32, i32* %i.addr, align 4, !dbg !3807
  %cmp256 = icmp uge i32 %119, 16, !dbg !3809
  br i1 %cmp256, label %if.then259, label %lor.lhs.false257, !dbg !3810

lor.lhs.false257:                                 ; preds = %sw.bb255
  %120 = load i32, i32* %j.addr, align 4, !dbg !3811
  %cmp258 = icmp uge i32 %120, 64, !dbg !3812
  br i1 %cmp258, label %if.then259, label %if.end260, !dbg !3813

if.then259:                                       ; preds = %lor.lhs.false257, %sw.bb255
  br label %sw.epilog, !dbg !3814

if.end260:                                        ; preds = %lor.lhs.false257
  br label %VITIS_LOOP_81_12, !dbg !3815

VITIS_LOOP_81_12:                                 ; preds = %if.end260
  br label %do.body261, !dbg !3816

do.body261:                                       ; preds = %VITIS_LOOP_81_12
  %121 = load i1, i1* %write_enable.addr, align 1, !dbg !3817
  br i1 %121, label %if.then262, label %if.else269, !dbg !3820

if.then262:                                       ; preds = %do.body261
  %122 = load i32, i32* %value.addr, align 4, !dbg !3821
  %conv263 = uitofp i32 %122 to float, !dbg !3821
  %call264 = call nonnull align 4 dereferenceable(4096) [16 x [64 x float]]* @_ZN4laya4full21full_cache_av_partialERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3822
  %123 = load i32, i32* %i.addr, align 4, !dbg !3823
  %idxprom265 = zext i32 %123 to i64, !dbg !3822
  %arrayidx266 = getelementptr inbounds [16 x [64 x float]], [16 x [64 x float]]* %call264, i64 0, i64 %idxprom265, !dbg !3822
  %124 = load i32, i32* %j.addr, align 4, !dbg !3824
  %idxprom267 = zext i32 %124 to i64, !dbg !3822
  %arrayidx268 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx266, i64 0, i64 %idxprom267, !dbg !3822
  store float %conv263, float* %arrayidx268, align 4, !dbg !3825
  br label %if.end276, !dbg !3826

if.else269:                                       ; preds = %do.body261
  %call270 = call nonnull align 4 dereferenceable(4096) [16 x [64 x float]]* @_ZN4laya4full21full_cache_av_partialERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3827
  %125 = load i32, i32* %i.addr, align 4, !dbg !3828
  %idxprom271 = zext i32 %125 to i64, !dbg !3827
  %arrayidx272 = getelementptr inbounds [16 x [64 x float]], [16 x [64 x float]]* %call270, i64 0, i64 %idxprom271, !dbg !3827
  %126 = load i32, i32* %j.addr, align 4, !dbg !3829
  %idxprom273 = zext i32 %126 to i64, !dbg !3827
  %arrayidx274 = getelementptr inbounds [64 x float], [64 x float]* %arrayidx272, i64 0, i64 %idxprom273, !dbg !3827
  %127 = load float, float* %arrayidx274, align 4, !dbg !3827
  %conv275 = call i32 @__hls_fptoui_float_i32(float %127), !dbg !3827
  %128 = load i32*, i32** %result.addr, align 8, !dbg !3830
  store i32 %conv275, i32* %128, align 4, !dbg !3831
  br label %if.end276

if.end276:                                        ; preds = %if.else269, %if.then262
  br label %do.end277, !dbg !3832

do.end277:                                        ; preds = %if.end276
  br label %return, !dbg !3833

sw.bb278:                                         ; preds = %entry
  %129 = load i32, i32* %i.addr, align 4, !dbg !3834
  %cmp279 = icmp uge i32 %129, 256, !dbg !3836
  br i1 %cmp279, label %if.then282, label %lor.lhs.false280, !dbg !3837

lor.lhs.false280:                                 ; preds = %sw.bb278
  %130 = load i32, i32* %j.addr, align 4, !dbg !3838
  %cmp281 = icmp uge i32 %130, 1028, !dbg !3839
  br i1 %cmp281, label %if.then282, label %if.end283, !dbg !3840

if.then282:                                       ; preds = %lor.lhs.false280, %sw.bb278
  br label %sw.epilog, !dbg !3841

if.end283:                                        ; preds = %lor.lhs.false280
  br label %VITIS_LOOP_85_13, !dbg !3842

VITIS_LOOP_85_13:                                 ; preds = %if.end283
  br label %do.body284, !dbg !3843

do.body284:                                       ; preds = %VITIS_LOOP_85_13
  %131 = load i1, i1* %write_enable.addr, align 1, !dbg !3844
  br i1 %131, label %if.then285, label %if.else292, !dbg !3847

if.then285:                                       ; preds = %do.body284
  %132 = load i32, i32* %value.addr, align 4, !dbg !3848
  %conv286 = trunc i32 %132 to i16, !dbg !3848
  %call287 = call nonnull align 2 dereferenceable(526336) [256 x [1028 x i16]]* @_ZN4laya4full24full_cache_fp_act_weightERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3849
  %133 = load i32, i32* %i.addr, align 4, !dbg !3850
  %idxprom288 = zext i32 %133 to i64, !dbg !3849
  %arrayidx289 = getelementptr inbounds [256 x [1028 x i16]], [256 x [1028 x i16]]* %call287, i64 0, i64 %idxprom288, !dbg !3849
  %134 = load i32, i32* %j.addr, align 4, !dbg !3851
  %idxprom290 = zext i32 %134 to i64, !dbg !3849
  %arrayidx291 = getelementptr inbounds [1028 x i16], [1028 x i16]* %arrayidx289, i64 0, i64 %idxprom290, !dbg !3849
  store i16 %conv286, i16* %arrayidx291, align 2, !dbg !3852
  br label %if.end299, !dbg !3853

if.else292:                                       ; preds = %do.body284
  %call293 = call nonnull align 2 dereferenceable(526336) [256 x [1028 x i16]]* @_ZN4laya4full24full_cache_fp_act_weightERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) @_ZZ26full_cache_structure_pilotE7runtime), !dbg !3854
  %135 = load i32, i32* %i.addr, align 4, !dbg !3855
  %idxprom294 = zext i32 %135 to i64, !dbg !3854
  %arrayidx295 = getelementptr inbounds [256 x [1028 x i16]], [256 x [1028 x i16]]* %call293, i64 0, i64 %idxprom294, !dbg !3854
  %136 = load i32, i32* %j.addr, align 4, !dbg !3856
  %idxprom296 = zext i32 %136 to i64, !dbg !3854
  %arrayidx297 = getelementptr inbounds [1028 x i16], [1028 x i16]* %arrayidx295, i64 0, i64 %idxprom296, !dbg !3854
  %137 = load i16, i16* %arrayidx297, align 2, !dbg !3854
  %conv298 = zext i16 %137 to i32, !dbg !3854
  %138 = load i32*, i32** %result.addr, align 8, !dbg !3857
  store i32 %conv298, i32* %138, align 4, !dbg !3858
  br label %if.end299

if.end299:                                        ; preds = %if.else292, %if.then285
  br label %do.end300, !dbg !3859

do.end300:                                        ; preds = %if.end299
  br label %return, !dbg !3860

sw.bb301:                                         ; preds = %entry
  %139 = load i32, i32* %i.addr, align 4, !dbg !3861
  %cmp302 = icmp uge i32 %139, 32, !dbg !3863
  br i1 %cmp302, label %if.then303, label %if.end304, !dbg !3864

if.then303:                                       ; preds = %sw.bb301
  br label %sw.epilog, !dbg !3865

if.end304:                                        ; preds = %sw.bb301
  %140 = load i1, i1* %write_enable.addr, align 1, !dbg !3866
  br i1 %140, label %if.then305, label %if.else309, !dbg !3868

if.then305:                                       ; preds = %if.end304
  %141 = load i32, i32* %value.addr, align 4, !dbg !3869
  %and = and i32 %141, 7, !dbg !3870
  %conv306 = trunc i32 %and to i8, !dbg !3871
  %142 = load i32, i32* %i.addr, align 4, !dbg !3872
  %idxprom307 = zext i32 %142 to i64, !dbg !3873
  %arrayidx308 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZZ26full_cache_structure_pilotE7runtime, i32 0, i32 1, i32 0), i64 0, i64 %idxprom307, !dbg !3873
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx308, i32 0, i32 13, !dbg !3874
  store i8 %conv306, i8* %state, align 1, !dbg !3875
  br label %if.end317, !dbg !3873

if.else309:                                       ; preds = %if.end304
  %143 = load i32, i32* %i.addr, align 4, !dbg !3876
  %idxprom310 = zext i32 %143 to i64, !dbg !3877
  %arrayidx311 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZZ26full_cache_structure_pilotE7runtime, i32 0, i32 1, i32 0), i64 0, i64 %idxprom310, !dbg !3877
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx311, i32 0, i32 6, !dbg !3878
  %144 = load i8, i8* %layer, align 2, !dbg !3878
  %conv312 = zext i8 %144 to i32, !dbg !3877
  %shl = shl i32 %conv312, 8, !dbg !3879
  %145 = load i32, i32* %i.addr, align 4, !dbg !3880
  %idxprom313 = zext i32 %145 to i64, !dbg !3881
  %arrayidx314 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* getelementptr inbounds (%"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* @_ZZ26full_cache_structure_pilotE7runtime, i32 0, i32 1, i32 0), i64 0, i64 %idxprom313, !dbg !3881
  %state315 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx314, i32 0, i32 13, !dbg !3882
  %146 = load i8, i8* %state315, align 1, !dbg !3882
  %conv316 = zext i8 %146 to i32, !dbg !3883
  %or = or i32 %shl, %conv316, !dbg !3884
  %147 = load i32*, i32** %result.addr, align 8, !dbg !3885
  store i32 %or, i32* %147, align 4, !dbg !3886
  br label %if.end317

if.end317:                                        ; preds = %if.else309, %if.then305
  br label %return, !dbg !3887

sw.default:                                       ; preds = %entry
  br label %sw.epilog, !dbg !3888

sw.epilog:                                        ; preds = %sw.default, %if.then303, %if.then282, %if.then259, %if.then232, %if.then199, %if.then168, %if.then143, %if.then120, %if.then97, %if.then74, %if.then47, %if.then27, %if.then10, %if.then
  %148 = load i32*, i32** %status.addr, align 8, !dbg !3889
  store i32 1, i32* %148, align 4, !dbg !3890
  br label %return, !dbg !3891

return:                                           ; preds = %sw.epilog, %if.end317, %do.end300, %do.end277, %do.end254, %do.end225, %do.end190, %do.end161, %do.end138, %do.end115, %do.end92, %do.end69, %do.end41, %do.end24, %do.end
  ret void, !dbg !3891
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: inaccessiblememonly nofree nosync nounwind willreturn
declare void @llvm.sideeffect() #2

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 1 dereferenceable(5373952) [5373952 x i8]* @_ZN4laya4full19full_cache_weight_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #3 comdat !dbg !3892 !fpga.function.pragma !3897 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3900, metadata !DIExpression()), !dbg !3901
  ret [5373952 x i8]* @_ZN4laya4full21g_full_cache_weight_qE, !dbg !3902
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 2 dereferenceable(335872) [167936 x i16]* @_ZN4laya4full23full_cache_weight_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #4 comdat !dbg !3903 !fpga.function.pragma !3907 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3910, metadata !DIExpression()), !dbg !3911
  ret [167936 x i16]* @_ZN4laya4full25g_full_cache_weight_scaleE, !dbg !3912
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(20992) [5248 x float]* @_ZN4laya4full22full_cache_weight_biasERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #5 comdat !dbg !3913 !fpga.function.pragma !3917 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3920, metadata !DIExpression()), !dbg !3921
  ret [5248 x float]* @_ZN4laya4full24g_full_cache_weight_biasE, !dbg !3922
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 1 dereferenceable(65536) [16 x [128 x [32 x i8]]]* @_ZN4laya4full23full_cache_activation_qERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #6 comdat !dbg !3923 !fpga.function.pragma !3927 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3930, metadata !DIExpression()), !dbg !3931
  ret [16 x [128 x [32 x i8]]]* @_ZN4laya4full25g_full_cache_activation_qE, !dbg !3932
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 2 dereferenceable(4096) [16 x [128 x i16]]* @_ZN4laya4full27full_cache_activation_scaleERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #7 comdat !dbg !3933 !fpga.function.pragma !3937 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3940, metadata !DIExpression()), !dbg !3941
  ret [16 x [128 x i16]]* @_ZN4laya4full29g_full_cache_activation_scaleE, !dbg !3942
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(262144) [16 x [4096 x float]]* @_ZN4laya4full21full_cache_input_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #8 comdat !dbg !3943 !fpga.function.pragma !3947 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3950, metadata !DIExpression()), !dbg !3951
  ret [16 x [4096 x float]]* @_ZN4laya4full23g_full_cache_input_tileE, !dbg !3952
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(335872) [16 x [5248 x float]]* @_ZN4laya4full18full_cache_ps_tileERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #9 comdat !dbg !3953 !fpga.function.pragma !3957 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3960, metadata !DIExpression()), !dbg !3961
  ret [16 x [5248 x float]]* @_ZN4laya4full20g_full_cache_ps_tileE, !dbg !3962
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(8192) [2 x [1024 x float]]* @_ZN4laya4full16full_cache_gammaERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #10 comdat !dbg !3963 !fpga.function.pragma !3967 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3970, metadata !DIExpression()), !dbg !3971
  ret [2 x [1024 x float]]* @_ZN4laya4full18g_full_cache_gammaE, !dbg !3972
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(524800) [2 x [1025 x [64 x float]]]* @_ZN4laya4full21full_cache_rope_tableERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #11 comdat !dbg !3973 !fpga.function.pragma !3977 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3980, metadata !DIExpression()), !dbg !3981
  ret [2 x [1025 x [64 x float]]]* @_ZN4laya4full23g_full_cache_rope_tableE, !dbg !3982
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(1048576) [2 x [2 x [1024 x [64 x float]]]]* @_ZN4laya4full13full_cache_kvERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #12 comdat !dbg !3983 !fpga.function.pragma !3987 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !3990, metadata !DIExpression()), !dbg !3991
  ret [2 x [2 x [1024 x [64 x float]]]]* @_ZN4laya4full15g_full_cache_kvE, !dbg !3992
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(131072) [2 x [16 x [1024 x float]]]* @_ZN4laya4full16full_cache_scoreERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #13 comdat !dbg !3993 !fpga.function.pragma !3997 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !4000, metadata !DIExpression()), !dbg !4001
  ret [2 x [16 x [1024 x float]]]* @_ZN4laya4full18g_full_cache_scoreE, !dbg !4002
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 4 dereferenceable(4096) [16 x [64 x float]]* @_ZN4laya4full21full_cache_av_partialERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #14 comdat !dbg !4003 !fpga.function.pragma !4007 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !4010, metadata !DIExpression()), !dbg !4011
  ret [16 x [64 x float]]* @_ZN4laya4full23g_full_cache_av_partialE, !dbg !4012
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dso_local nonnull align 2 dereferenceable(526336) [256 x [1028 x i16]]* @_ZN4laya4full24full_cache_fp_act_weightERNS0_11FullRuntimeE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0) #15 comdat !dbg !4013 !fpga.function.pragma !4017 {
entry:
  %.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  store %"struct.laya::full::FullRuntime"* %0, %"struct.laya::full::FullRuntime"** %.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %.addr, metadata !4020, metadata !DIExpression()), !dbg !4021
  ret [256 x [1028 x i16]]* @_ZN4laya4full26g_full_cache_fp_act_weightE, !dbg !4022
}

; Function Attrs: nounwind
define i32 @__hls_fptoui_float_i32(float %x) #16 !dbg !4023 {
entry:
  %x.addr = alloca float, align 4
  store float %x, float* %x.addr, align 4
  call void @llvm.dbg.declare(metadata float* %x.addr, metadata !4027, metadata !DIExpression()), !dbg !4028
  %0 = load float, float* %x.addr, align 4, !dbg !4029
  %call = call i32 @_Z20generic_cast_IEEE754IjfET_T0_b(float %0, i1 zeroext false), !dbg !4030
  ret i32 %call, !dbg !4031
}

; Function Attrs: nounwind
define linkonce_odr i32 @_Z20generic_cast_IEEE754IjfET_T0_b(float %x, i1 zeroext %detect_overflow) #17 comdat !dbg !4032 {
entry:
  %x.addr = alloca float, align 4
  %detect_overflow.addr = alloca i1, align 1
  store float %x, float* %x.addr, align 4
  call void @llvm.dbg.declare(metadata float* %x.addr, metadata !4039, metadata !DIExpression()), !dbg !4040
  store i1 %detect_overflow, i1* %detect_overflow.addr, align 1
  call void @llvm.dbg.declare(metadata i1* %detect_overflow.addr, metadata !4041, metadata !DIExpression()), !dbg !4042
  %0 = load float, float* %x.addr, align 4, !dbg !4043
  %1 = load i1, i1* %detect_overflow.addr, align 1, !dbg !4044
  %call = call i32 @_Z20generic_cast_IEEE754IjL9ap_q_mode6EfET_T1_bN3hls9enable_ifIXntsr3std14numeric_limitsIS1_EE9is_signedEbE4typeE(float %0, i1 zeroext %1, i1 zeroext true), !dbg !4045
  ret i32 %call, !dbg !4046
}

; Function Attrs: nounwind
define linkonce_odr i32 @_Z20generic_cast_IEEE754IjL9ap_q_mode6EfET_T1_bN3hls9enable_ifIXntsr3std14numeric_limitsIS1_EE9is_signedEbE4typeE(float %x, i1 zeroext %detect_overflow, i1 zeroext %0) #17 comdat !dbg !4047 {
entry:
  %retval = alloca i32, align 4
  %x.addr = alloca float, align 4
  %detect_overflow.addr = alloca i1, align 1
  %.addr = alloca i1, align 1
  %xs = alloca %"class.fp_struct<float>", align 4
  %mantissa = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>", align 16
  %ref.tmp = alloca %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>", align 4
  %smantissa = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>", align 16
  %ref.tmp1 = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  %overflow_bits = alloca %"struct.ap_uint<1>", align 1
  %val = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", align 4
  %overflow = alloca i1, align 1
  %minval = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", align 4
  %maxval = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %result = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", align 4
  store float %x, float* %x.addr, align 4
  call void @llvm.dbg.declare(metadata float* %x.addr, metadata !4058, metadata !DIExpression()), !dbg !4059
  store i1 %detect_overflow, i1* %detect_overflow.addr, align 1
  call void @llvm.dbg.declare(metadata i1* %detect_overflow.addr, metadata !4060, metadata !DIExpression()), !dbg !4061
  store i1 %0, i1* %.addr, align 1
  call void @llvm.dbg.declare(metadata i1* %.addr, metadata !4062, metadata !DIExpression()), !dbg !4063
  %1 = bitcast %"class.fp_struct<float>"* %xs to i8*, !dbg !4064
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %1) #39, !dbg !4064
  call void @llvm.dbg.declare(metadata %"class.fp_struct<float>"* %xs, metadata !4065, metadata !DIExpression()), !dbg !4066
  %2 = load float, float* %x.addr, align 4, !dbg !4067
  call void @_ZN9fp_structIfEC2Ef(%"class.fp_struct<float>"* %xs, float %2), !dbg !4066
  %3 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %mantissa to i8*, !dbg !4068
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %3) #39, !dbg !4068
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %mantissa, metadata !4069, metadata !DIExpression()), !dbg !4104
  %4 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %ref.tmp to i8*, !dbg !4105
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %4) #39, !dbg !4105
  call void @_ZNK9fp_structIfE8mantissaEv(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>") %ref.tmp, %"class.fp_struct<float>"* %xs), !dbg !4106
  %5 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %ref.tmp to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4105
  call void @_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %mantissa, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %5), !dbg !4105
  %6 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %ref.tmp to i8*, !dbg !4104
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %6) #39, !dbg !4104
  %7 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa to i8*, !dbg !4107
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %7) #39, !dbg !4107
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa, metadata !4108, metadata !DIExpression()), !dbg !4109
  %8 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %ref.tmp1 to i8*, !dbg !4110
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %8) #39, !dbg !4110
  %9 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %mantissa to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4110
  %call = call i32 @_ZNK9fp_structIfE4expvEv(%"class.fp_struct<float>"* %xs), !dbg !4111
  call void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEi(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %ref.tmp1, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %9, i32 %call), !dbg !4112
  call void @_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %ref.tmp1), !dbg !4110
  %10 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %ref.tmp1 to i8*, !dbg !4109
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %10) #39, !dbg !4109
  %11 = bitcast %"struct.ap_uint<1>"* %overflow_bits to i8*, !dbg !4113
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39, !dbg !4113
  call void @llvm.dbg.declare(metadata %"struct.ap_uint<1>"* %overflow_bits, metadata !4114, metadata !DIExpression()), !dbg !4134
  %12 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4135
  call void @_ZN9ap_ufixedILi1ELi33EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_uint<1>"* %overflow_bits, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %12), !dbg !4135
  %13 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %val to i8*, !dbg !4136
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %13) #39, !dbg !4136
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %val, metadata !4137, metadata !DIExpression()), !dbg !4158
  %14 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4159
  call void @_ZN9ap_ufixedILi32ELi32EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %val, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %14), !dbg !4159
  %15 = bitcast i1* %overflow to i8*, !dbg !4160
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %15) #39, !dbg !4160
  call void @llvm.dbg.declare(metadata i1* %overflow, metadata !4161, metadata !DIExpression()), !dbg !4162
  %call2 = call i32 @_ZNK9fp_structIfE4expvEv(%"class.fp_struct<float>"* %xs), !dbg !4163
  %cmp = icmp sge i32 %call2, 55, !dbg !4166
  br i1 %cmp, label %lor.end, label %lor.rhs, !dbg !4167

lor.rhs:                                          ; preds = %entry
  %16 = bitcast %"struct.ap_uint<1>"* %overflow_bits to %"struct.ap_int_base<1, false>"*, !dbg !4168
  %call3 = call zeroext i1 @_ZneILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EEi(%"struct.ap_int_base<1, false>"* dereferenceable(1) %16, i32 0), !dbg !4169
  br label %lor.end, !dbg !4167

lor.end:                                          ; preds = %lor.rhs, %entry
  %17 = phi i1 [ true, %entry ], [ %call3, %lor.rhs ]
  store i1 %17, i1* %overflow, align 1, !dbg !4170
  %18 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %minval to i8*, !dbg !4171
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %18) #39, !dbg !4171
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %minval, metadata !4172, metadata !DIExpression()), !dbg !4173
  call void @_ZN7ap_uintILi32EEC2Ei(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %minval, i32 0), !dbg !4174
  %19 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %maxval to i8*, !dbg !4175
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %19) #39, !dbg !4175
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %maxval, metadata !4176, metadata !DIExpression()), !dbg !4177
  call void @_ZN7ap_uintILi32EEC2Ei(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %maxval, i32 -1), !dbg !4178
  %20 = load i1, i1* %overflow, align 1, !dbg !4179
  br i1 %20, label %land.lhs.true, label %lor.lhs.false, !dbg !4181

lor.lhs.false:                                    ; preds = %lor.end
  %call4 = call i32 @_ZNK9fp_structIfE9__signbitEv(%"class.fp_struct<float>"* %xs), !dbg !4182
  %tobool = icmp ne i32 %call4, 0, !dbg !4183
  br i1 %tobool, label %land.lhs.true, label %if.end, !dbg !4184

land.lhs.true:                                    ; preds = %lor.lhs.false, %lor.end
  %21 = load i1, i1* %detect_overflow.addr, align 1, !dbg !4185
  br i1 %21, label %if.then, label %if.end, !dbg !4186

if.then:                                          ; preds = %land.lhs.true
  %22 = bitcast %"struct.ap_uint<1>"* %overflow_bits to %"struct.ap_int_base<1, false>"*, !dbg !4187
  %call5 = call zeroext i1 @_ZeqILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbiRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(i32 0, %"struct.ap_int_base<1, false>"* dereferenceable(1) %22), !dbg !4190
  br i1 %call5, label %land.lhs.true6, label %if.else, !dbg !4191

land.lhs.true6:                                   ; preds = %if.then
  %sig = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %xs, i32 0, i32 2, !dbg !4192
  %23 = bitcast %"struct.ap_uint<23>"* %sig to %"struct.ap_int_base<23, false>"*, !dbg !4193
  %call7 = call zeroext i1 @_ZneILi23ELb0EEbiRK11ap_int_baseIXT_EXT0_EE(i32 0, %"struct.ap_int_base<23, false>"* dereferenceable(4) %23), !dbg !4194
  br i1 %call7, label %land.lhs.true8, label %if.else, !dbg !4195

land.lhs.true8:                                   ; preds = %land.lhs.true6
  %exp = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %xs, i32 0, i32 1, !dbg !4196
  %24 = bitcast %"struct.ap_ufixed<8, 8, AP_TRN_ZERO, AP_WRAP, 0>"* %exp to %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, !dbg !4197
  %call9 = call zeroext i1 @_ZeqILi8ELb0EEbRK11ap_int_baseIXT_EXT0_EEi(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %24, i32 255), !dbg !4198
  br i1 %call9, label %if.then10, label %if.else, !dbg !4199

if.then10:                                        ; preds = %land.lhs.true8
  %25 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %maxval to %"struct.ap_int_base<32, true>"*, !dbg !4200
  %call11 = call i64 @_ZNK11ap_int_baseILi32ELb0EEcvyEv(%"struct.ap_int_base<32, true>"* %25), !dbg !4200
  %conv = trunc i64 %call11 to i32, !dbg !4200
  store i32 %conv, i32* %retval, align 4, !dbg !4202
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !4202

if.else:                                          ; preds = %land.lhs.true8, %land.lhs.true6, %if.then
  %call12 = call i32 @_ZNK9fp_structIfE9__signbitEv(%"class.fp_struct<float>"* %xs), !dbg !4203
  %tobool13 = icmp ne i32 %call12, 0, !dbg !4205
  br i1 %tobool13, label %cond.true, label %cond.false, !dbg !4205

cond.true:                                        ; preds = %if.else
  br label %cond.end, !dbg !4205

cond.false:                                       ; preds = %if.else
  br label %cond.end, !dbg !4205

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond-lvalue = phi %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* [ %minval, %cond.true ], [ %maxval, %cond.false ], !dbg !4205
  %26 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %cond-lvalue to %"struct.ap_int_base<32, true>"*, !dbg !4205
  %call14 = call i64 @_ZNK11ap_int_baseILi32ELb0EEcvyEv(%"struct.ap_int_base<32, true>"* %26), !dbg !4205
  %conv15 = trunc i64 %call14 to i32, !dbg !4205
  store i32 %conv15, i32* %retval, align 4, !dbg !4206
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !4206

if.end:                                           ; preds = %land.lhs.true, %lor.lhs.false
  %27 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %result to i8*, !dbg !4207
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %27) #39, !dbg !4207
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %result, metadata !4208, metadata !DIExpression()), !dbg !4220
  %28 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %val to %"struct.ap_int_base<32, true>"*, !dbg !4221
  call void @_ZN8ap_fixedILi32ELi32EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %result, %"struct.ap_int_base<32, true>"* dereferenceable(4) %28), !dbg !4221
  %29 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %result to %"struct.ap_int_base<32, true>"*, !dbg !4222
  %call16 = call i32 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEcvjEv(%"struct.ap_int_base<32, true>"* %29), !dbg !4222
  store i32 %call16, i32* %retval, align 4, !dbg !4223
  store i32 1, i32* %cleanup.dest.slot, align 4
  %30 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %result to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %30) #39, !dbg !4224
  br label %cleanup

cleanup:                                          ; preds = %if.end, %cond.end, %if.then10
  %31 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %maxval to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39, !dbg !4224
  %32 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %minval to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %32) #39, !dbg !4224
  %33 = bitcast i1* %overflow to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39, !dbg !4224
  %34 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %val to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %34) #39, !dbg !4224
  %35 = bitcast %"struct.ap_uint<1>"* %overflow_bits to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %35) #39, !dbg !4224
  %36 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %smantissa to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %36) #39, !dbg !4224
  %37 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %mantissa to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %37) #39, !dbg !4224
  %38 = bitcast %"class.fp_struct<float>"* %xs to i8*, !dbg !4224
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %38) #39, !dbg !4224
  %39 = load i32, i32* %retval, align 4, !dbg !4224
  ret i32 %39, !dbg !4224
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #18

; Function Attrs: nounwind
define linkonce_odr void @_ZN9fp_structIfEC2Ef(%"class.fp_struct<float>"* %this, float %f) unnamed_addr #19 comdat align 2 !dbg !4225 {
entry:
  %this.addr = alloca %"class.fp_struct<float>"*, align 8
  %f.addr = alloca float, align 4
  %dc = alloca %union.single_cast, align 4
  %data = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", align 4
  %ref.tmp = alloca %"struct.ap_bit_ref<32, true>", align 8
  %tmp = alloca %"struct.ap_bit_ref<1, false>", align 8
  %ref.tmp4 = alloca %"struct.ap_range_ref<32, false>", align 8
  %tmp6 = alloca %"struct.ap_range_ref<8, false>", align 8
  %ref.tmp8 = alloca %"struct.ap_range_ref<32, false>", align 8
  %tmp10 = alloca %"struct.ap_range_ref<23, false>", align 8
  store %"class.fp_struct<float>"* %this, %"class.fp_struct<float>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"class.fp_struct<float>"** %this.addr, metadata !4226, metadata !DIExpression()), !dbg !4228
  store float %f, float* %f.addr, align 4
  call void @llvm.dbg.declare(metadata float* %f.addr, metadata !4229, metadata !DIExpression()), !dbg !4230
  %this1 = load %"class.fp_struct<float>"*, %"class.fp_struct<float>"** %this.addr, align 8
  %sign = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 0, !dbg !4231
  %exp = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 1, !dbg !4231
  %sig = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 2, !dbg !4231
  %0 = bitcast %union.single_cast* %dc to i8*, !dbg !4232
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39, !dbg !4232
  call void @llvm.dbg.declare(metadata %union.single_cast* %dc, metadata !4234, metadata !DIExpression()), !dbg !4239
  %1 = load float, float* %f.addr, align 4, !dbg !4240
  %f2 = bitcast %union.single_cast* %dc to float*, !dbg !4241
  store float %1, float* %f2, align 4, !dbg !4242
  %2 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data to i8*, !dbg !4243
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39, !dbg !4243
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data, metadata !4244, metadata !DIExpression()), !dbg !4245
  %i = bitcast %union.single_cast* %dc to i32*, !dbg !4246
  %3 = load i32, i32* %i, align 4, !dbg !4246
  call void @_ZN7ap_uintILi32EEC2Ej(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data, i32 %3), !dbg !4247
  %4 = bitcast %"struct.ap_bit_ref<32, true>"* %ref.tmp to i8*, !dbg !4248
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %4) #39, !dbg !4248
  %5 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data to %"struct.ap_int_base<32, true>"*, !dbg !4248
  call void @_ZN11ap_int_baseILi32ELb0EEixEi(%"struct.ap_bit_ref<32, true>"* sret(%"struct.ap_bit_ref<32, true>") %ref.tmp, %"struct.ap_int_base<32, true>"* %5, i32 31), !dbg !4248
  %sign3 = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 0, !dbg !4249
  %6 = bitcast %"struct.ap_uint<1>"* %sign3 to %"struct.ap_int_base<1, false>"*, !dbg !4249
  call void @_ZN11ap_int_baseILi1ELb0EEixEi(%"struct.ap_bit_ref<1, false>"* sret(%"struct.ap_bit_ref<1, false>") %tmp, %"struct.ap_int_base<1, false>"* %6, i32 0), !dbg !4249
  %call = call dereferenceable(16) %"struct.ap_bit_ref<1, false>"* @_ZN10ap_bit_refILi1ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_bit_ref<1, false>"* %tmp, %"struct.ap_bit_ref<32, true>"* dereferenceable(16) %ref.tmp), !dbg !4250
  %7 = bitcast %"struct.ap_bit_ref<32, true>"* %ref.tmp to i8*, !dbg !4249
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %7) #39, !dbg !4249
  %8 = bitcast %"struct.ap_range_ref<32, false>"* %ref.tmp4 to i8*, !dbg !4251
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %8) #39, !dbg !4251
  %9 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data to %"struct.ap_int_base<32, true>"*, !dbg !4251
  call void @_ZN11ap_int_baseILi32ELb0EEclEii(%"struct.ap_range_ref<32, false>"* sret(%"struct.ap_range_ref<32, false>") %ref.tmp4, %"struct.ap_int_base<32, true>"* %9, i32 30, i32 23), !dbg !4251
  %exp5 = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 1, !dbg !4252
  %10 = bitcast %"struct.ap_ufixed<8, 8, AP_TRN_ZERO, AP_WRAP, 0>"* %exp5 to %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, !dbg !4252
  call void @_ZN11ap_int_baseILi8ELb0EEclEii(%"struct.ap_range_ref<8, false>"* sret(%"struct.ap_range_ref<8, false>") %tmp6, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %10, i32 7, i32 0), !dbg !4252
  %call7 = call dereferenceable(16) %"struct.ap_range_ref<8, false>"* @_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_range_ref<8, false>"* %tmp6, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %ref.tmp4), !dbg !4253
  %11 = bitcast %"struct.ap_range_ref<32, false>"* %ref.tmp4 to i8*, !dbg !4252
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %11) #39, !dbg !4252
  %12 = bitcast %"struct.ap_range_ref<32, false>"* %ref.tmp8 to i8*, !dbg !4254
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %12) #39, !dbg !4254
  %13 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data to %"struct.ap_int_base<32, true>"*, !dbg !4254
  call void @_ZN11ap_int_baseILi32ELb0EEclEii(%"struct.ap_range_ref<32, false>"* sret(%"struct.ap_range_ref<32, false>") %ref.tmp8, %"struct.ap_int_base<32, true>"* %13, i32 22, i32 0), !dbg !4254
  %sig9 = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 2, !dbg !4255
  %14 = bitcast %"struct.ap_uint<23>"* %sig9 to %"struct.ap_int_base<23, false>"*, !dbg !4255
  call void @_ZN11ap_int_baseILi23ELb0EEclEii(%"struct.ap_range_ref<23, false>"* sret(%"struct.ap_range_ref<23, false>") %tmp10, %"struct.ap_int_base<23, false>"* %14, i32 22, i32 0), !dbg !4255
  %call11 = call dereferenceable(16) %"struct.ap_range_ref<23, false>"* @_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_range_ref<23, false>"* %tmp10, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %ref.tmp8), !dbg !4256
  %15 = bitcast %"struct.ap_range_ref<32, false>"* %ref.tmp8 to i8*, !dbg !4255
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %15) #39, !dbg !4255
  %16 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %data to i8*, !dbg !4257
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39, !dbg !4257
  %17 = bitcast %union.single_cast* %dc to i8*, !dbg !4257
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %17) #39, !dbg !4257
  ret void, !dbg !4257
}

; Function Attrs: inlinehint nounwind
define linkonce_odr void @_ZNK9fp_structIfE8mantissaEv(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>") %agg.result, %"class.fp_struct<float>"* %this) #20 comdat align 2 !dbg !4258 {
entry:
  %this.addr = alloca %"class.fp_struct<float>"*, align 8
  %ref.tmp = alloca %"struct.ap_range_ref<23, false>", align 8
  %tmp = alloca %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", align 8
  %tmp5 = alloca %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", align 8
  store %"class.fp_struct<float>"* %this, %"class.fp_struct<float>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"class.fp_struct<float>"** %this.addr, metadata !4259, metadata !DIExpression()), !dbg !4261
  %this1 = load %"class.fp_struct<float>"*, %"class.fp_struct<float>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result, metadata !4262, metadata !DIExpression()), !dbg !4263
  call void @_ZN9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result, i32 0), !dbg !4264
  %0 = bitcast %"struct.ap_range_ref<23, false>"* %ref.tmp to i8*, !dbg !4265
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %0) #39, !dbg !4265
  %sig = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 2, !dbg !4265
  %1 = bitcast %"struct.ap_uint<23>"* %sig to %"struct.ap_int_base<23, false>"*, !dbg !4265
  call void @_ZNK11ap_int_baseILi23ELb0EEclEii(%"struct.ap_range_ref<23, false>"* sret(%"struct.ap_range_ref<23, false>") %ref.tmp, %"struct.ap_int_base<23, false>"* %1, i32 22, i32 0), !dbg !4265
  %2 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4266
  %3 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4267
  %call = call i32 @_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE2wlEv(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %3), !dbg !4268
  %sub = sub nsw i32 %call, 1, !dbg !4269
  call void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEclEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %tmp, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %2, i32 %sub, i32 0), !dbg !4266
  %call2 = call dereferenceable(16) %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK12ap_range_refIXT_EXT0_EE(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %tmp, %"struct.ap_range_ref<23, false>"* dereferenceable(16) %ref.tmp), !dbg !4270
  %4 = bitcast %"struct.ap_range_ref<23, false>"* %ref.tmp to i8*, !dbg !4266
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %4) #39, !dbg !4266
  %5 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4271
  %6 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, !dbg !4272
  %call3 = call i32 @_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE2wlEv(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %6), !dbg !4273
  %sub4 = sub nsw i32 %call3, 1, !dbg !4274
  call void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEixEj(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %tmp5, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %5, i32 %sub4), !dbg !4271
  %call6 = call dereferenceable(16) %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSEb(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %tmp5, i1 zeroext true), !dbg !4275
  ret void, !dbg !4276
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*
  %1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  call void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %0, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %1)
  ret void
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #18

; Function Attrs: inlinehint nounwind
define linkonce_odr i32 @_ZNK9fp_structIfE4expvEv(%"class.fp_struct<float>"* %this) #22 comdat align 2 !dbg !4279 {
entry:
  %this.addr = alloca %"class.fp_struct<float>"*, align 8
  %tmp = alloca %"struct.ap_int<33>", align 8
  store %"class.fp_struct<float>"* %this, %"class.fp_struct<float>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"class.fp_struct<float>"** %this.addr, metadata !4280, metadata !DIExpression()), !dbg !4281
  %this1 = load %"class.fp_struct<float>"*, %"class.fp_struct<float>"** %this.addr, align 8
  %exp = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 1, !dbg !4282
  %0 = bitcast %"struct.ap_ufixed<8, 8, AP_TRN_ZERO, AP_WRAP, 0>"* %exp to %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, !dbg !4282
  call void @"_ZmiILi8ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE5minusERKS1_i"(%"struct.ap_int<33>"* sret(%"struct.ap_int<33>") %tmp, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %0, i32 127), !dbg !4283
  %1 = bitcast %"struct.ap_int<33>"* %tmp to %"struct.ap_int_base<33, true>"*, !dbg !4282
  %call = call i64 @_ZNK11ap_int_baseILi33ELb1EEcvxEv(%"struct.ap_int_base<33, true>"* %1), !dbg !4282
  %conv = trunc i64 %call to i32, !dbg !4282
  ret i32 %conv, !dbg !4284
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEi(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %sh) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %sh.addr = alloca i32, align 4
  %r = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  %isNeg = alloca i1, align 1
  %ush = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %sh, i32* %sh.addr, align 4
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %0) #39
  call void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r, i32 0)
  %1 = bitcast i1* %isNeg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %1) #39
  %2 = load i32, i32* %sh.addr, align 4
  %cmp = icmp slt i32 %2, 0
  store i1 %cmp, i1* %isNeg, align 1
  %3 = bitcast i32* %ush to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %3) #39
  %4 = load i1, i1* %isNeg, align 1
  br i1 %4, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %5 = load i32, i32* %sh.addr, align 4
  %sub = sub nsw i32 0, %5
  br label %cond.end

cond.false:                                       ; preds = %entry
  %6 = load i32, i32* %sh.addr, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %6, %cond.false ]
  store i32 %cond, i32* %ush, align 4
  %7 = load i1, i1* %isNeg, align 1
  br i1 %7, label %if.then, label %if.else

if.then:                                          ; preds = %cond.end
  %8 = load i32, i32* %ush, align 4
  call void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EErsEj(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 %8)
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup

if.else:                                          ; preds = %cond.end
  %9 = load i32, i32* %ush, align 4
  call void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEj(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 %9)
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.else, %if.then
  %10 = bitcast i32* %ush to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %10) #39
  %11 = bitcast i1* %isNeg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %11) #39
  %12 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %12) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %2 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %1, align 16
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>" %2, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %0, align 16
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN9ap_ufixedILi1ELi33EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_uint<1>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_uint<1>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_uint<1>"* %this, %"struct.ap_uint<1>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_uint<1>"*, %"struct.ap_uint<1>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_uint<1>"* %this1 to %"struct.ap_int_base<1, false>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  call void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %0, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN9ap_ufixedILi32ELi32EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  call void @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %0, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZneILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EEi(%"struct.ap_int_base<1, false>"* dereferenceable(1) %op, i32 %i_op) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %i_op.addr = alloca i32, align 4
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  store i32 %i_op, i32* %i_op.addr, align 4
  %0 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %i_op.addr, align 4
  call void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_int_base<32, true>"* %ref.tmp, i32 %2)
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEneILi32ELi32ELb1ELS0_5ELS1_3ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %0, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %3) #39
  ret i1 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN7ap_uintILi32EEC2Ei(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, i32 %val) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %val.addr = alloca i32, align 4
  store %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  %this1 = load %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %1 = load i32, i32* %val.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb0EEC2Ei(%"struct.ap_int_base<32, true>"* %0, i32 %1)
  %2 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %3 = load i32, i32* %val.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIiEEvT_(%"struct.ap_int_base<32, true>"* %2, i32 %3)
  ret void
}

; Function Attrs: inlinehint nounwind
define linkonce_odr i32 @_ZNK9fp_structIfE9__signbitEv(%"class.fp_struct<float>"* %this) #23 comdat align 2 !dbg !4285 {
entry:
  %this.addr = alloca %"class.fp_struct<float>"*, align 8
  store %"class.fp_struct<float>"* %this, %"class.fp_struct<float>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"class.fp_struct<float>"** %this.addr, metadata !4286, metadata !DIExpression()), !dbg !4287
  %this1 = load %"class.fp_struct<float>"*, %"class.fp_struct<float>"** %this.addr, align 8
  %sign = getelementptr inbounds %"class.fp_struct<float>", %"class.fp_struct<float>"* %this1, i32 0, i32 0, !dbg !4288
  %0 = bitcast %"struct.ap_uint<1>"* %sign to %"struct.ap_int_base<1, false>"*, !dbg !4288
  %call = call i32 @_ZNK11ap_int_baseILi1ELb0EE6to_intEv(%"struct.ap_int_base<1, false>"* %0), !dbg !4289
  ret i32 %call, !dbg !4290
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZeqILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEbiRK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(i32 %i_op, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op) #21 comdat !fpga.function.pragma !4277 {
entry:
  %i_op.addr = alloca i32, align 4
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store i32 %i_op, i32* %i_op.addr, align 4
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %1 = load i32, i32* %i_op.addr, align 4
  call void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_int_base<32, true>"* %ref.tmp, i32 %1)
  %2 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEeqILi1ELi33ELb0ELS0_5ELS1_0ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %ref.tmp, %"struct.ap_int_base<1, false>"* dereferenceable(1) %2)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %3) #39
  ret i1 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZneILi23ELb0EEbiRK11ap_int_baseIXT_EXT0_EE(i32 %i_op, %"struct.ap_int_base<23, false>"* dereferenceable(4) %op) #21 comdat !fpga.function.pragma !4277 {
entry:
  %i_op.addr = alloca i32, align 4
  %op.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store i32 %i_op, i32* %i_op.addr, align 4
  store %"struct.ap_int_base<23, false>"* %op, %"struct.ap_int_base<23, false>"** %op.addr, align 8
  %0 = load i32, i32* %i_op.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %tmp, i32 %0)
  %1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK11ap_int_baseILi32ELb1EEneILi23ELb0EEEbRKS_IXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %tmp, %"struct.ap_int_base<23, false>"* dereferenceable(4) %1)
  ret i1 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZeqILi8ELb0EEbRK11ap_int_baseIXT_EXT0_EEi(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %op, i32 %op2) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op2.addr = alloca i32, align 4
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  store i32 %op2, i32* %op2.addr, align 4
  %0 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %op2.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %ref.tmp, i32 %2)
  %call = call zeroext i1 @_ZNK11ap_int_baseILi8ELb0EEeqILi32ELb1EEEbRKS_IXT_EXT0_EE(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %0, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %3) #39
  ret i1 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i64 @_ZNK11ap_int_baseILi32ELb0EEcvyEv(%"struct.ap_int_base<32, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  %conv = zext i32 %1 to i64
  ret i64 %conv
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ap_fixedILi32ELi32EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERK13ap_fixed_baseIXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  call void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %0, %"struct.ap_int_base<32, true>"* dereferenceable(4) %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i32 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEcvjEv(%"struct.ap_int_base<32, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %call = call i32 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE7to_uintEv(%"struct.ap_int_base<32, true>"* %this1)
  ret i32 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i32 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE7to_uintEv(%"struct.ap_int_base<32, true>"* %this) #24 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  call void @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE14to_ap_int_baseEb(%"struct.ap_int_base<32, true>"* sret(%"struct.ap_int_base<32, true>") %ref.tmp, %"struct.ap_int_base<32, true>"* %this1, i1 zeroext true)
  %call = call i32 @_ZNK11ap_int_baseILi32ELb1EE7to_uintEv(%"struct.ap_int_base<32, true>"* %ref.tmp)
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %1) #39
  ret i32 %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE14to_ap_int_baseEb(%"struct.ap_int_base<32, true>"* noalias sret(%"struct.ap_int_base<32, true>") %agg.result, %"struct.ap_int_base<32, true>"* %this, i1 zeroext %Cnative) #25 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %Cnative.addr = alloca i1, align 1
  %__Result__ = alloca i32, align 4
  %__Val2__ = alloca i32, align 4
  %tmp = alloca i32, align 4
  %__Val2__3 = alloca i32, align 4
  %__Result__5 = alloca i1, align 1
  %tmp6 = alloca i1, align 1
  %__Result__9 = alloca i32, align 4
  %__Val2__10 = alloca i32, align 4
  %tmp13 = alloca i32, align 4
  %ref.tmp = alloca %"struct.ap_int<33>", align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i1 %Cnative, i1* %Cnative.addr, align 1
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  call void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %agg.result, i32 0)
  %0 = bitcast i32* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %__Result__, align 4
  %1 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  store i32 %3, i32* %__Val2__, align 4
  %4 = bitcast i32* %__Result__ to i8*
  %5 = bitcast i32* %__Val2__ to i8*
  %6 = load i32, i32* %__Val2__, align 4
  %part_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %6, i32 0, i32 31)
  store i32 %part_select, i32* %__Result__, align 4
  %7 = load i32, i32* %__Result__, align 4
  store i32 %7, i32* %tmp, align 4
  %8 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %8) #39
  %9 = bitcast i32* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %9) #39
  %10 = load i32, i32* %tmp, align 4
  %11 = bitcast %"struct.ap_int_base<32, true>"* %agg.result to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %11, i32 0, i32 0
  store i32 %10, i32* %V2, align 4
  %12 = load i1, i1* %Cnative.addr, align 1
  br i1 %12, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %entry
  br i1 false, label %if.then, label %if.else

if.then:                                          ; preds = %land.lhs.true
  %13 = bitcast i32* %__Val2__3 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %13) #39
  %14 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %14, i32 0, i32 0
  %15 = load i32, i32* %V4, align 4
  store i32 %15, i32* %__Val2__3, align 4
  %16 = bitcast i1* %__Result__5 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %16) #39
  %17 = bitcast i32* %__Val2__3 to i8*
  %18 = load i32, i32* %__Val2__3, align 4
  %bit_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %18, i32 31, i32 31)
  %tobool = icmp ne i32 %bit_select, 0
  store i1 %tobool, i1* %__Result__5, align 1
  %19 = load i1, i1* %__Result__5, align 1
  store i1 %19, i1* %tmp6, align 1
  %20 = bitcast i1* %__Result__5 to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %20) #39
  %21 = bitcast i32* %__Val2__3 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %21) #39
  %22 = load i1, i1* %tmp6, align 1
  br i1 %22, label %land.lhs.true7, label %if.end

land.lhs.true7:                                   ; preds = %if.then
  br i1 false, label %land.lhs.true8, label %if.end

land.lhs.true8:                                   ; preds = %land.lhs.true7
  %23 = bitcast i32* %__Result__9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %23) #39
  store i32 0, i32* %__Result__9, align 4
  %24 = bitcast i32* %__Val2__10 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %24) #39
  %25 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V11 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %25, i32 0, i32 0
  %26 = load i32, i32* %V11, align 4
  store i32 %26, i32* %__Val2__10, align 4
  %27 = bitcast i32* %__Result__9 to i8*
  %28 = bitcast i32* %__Val2__10 to i8*
  %29 = load i32, i32* %__Val2__10, align 4
  %part_select12 = call i32 @llvm.fpga.legacy.part.select.i32(i32 %29, i32 0, i32 -1)
  store i32 %part_select12, i32* %__Result__9, align 4
  %30 = load i32, i32* %__Result__9, align 4
  store i32 %30, i32* %tmp13, align 4
  %31 = bitcast i32* %__Val2__10 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i32* %__Result__9 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %32) #39
  %33 = load i32, i32* %tmp13, align 4
  %conv = sext i32 %33 to i64
  %cmp = icmp ne i64 %conv, 0
  br i1 %cmp, label %if.then14, label %if.end

if.then14:                                        ; preds = %land.lhs.true8
  %34 = bitcast %"struct.ap_int<33>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %34) #39
  call void @"_ZplILi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE4plusERKS1_i"(%"struct.ap_int<33>"* sret(%"struct.ap_int<33>") %ref.tmp, %"struct.ap_int_base<32, true>"* dereferenceable(4) %agg.result, i32 1)
  %35 = bitcast %"struct.ap_int<33>"* %ref.tmp to %"struct.ap_int_base<33, true>"*
  %call = call dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN11ap_int_baseILi32ELb1EEaSILi33ELb1EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %agg.result, %"struct.ap_int_base<33, true>"* dereferenceable(8) %35)
  %36 = bitcast %"struct.ap_int<33>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %36) #39
  br label %if.end

if.end:                                           ; preds = %if.then14, %land.lhs.true8, %land.lhs.true7, %if.then
  br label %if.end15

if.else:                                          ; preds = %land.lhs.true, %entry
  br label %if.end15

if.end15:                                         ; preds = %if.else, %if.end
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i32 @_ZNK11ap_int_baseILi32ELb1EE7to_uintEv(%"struct.ap_int_base<32, true>"* %this) #24 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  ret i32 %1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = load i32, i32* %op.addr, align 4
  call void @_ZN8ssdm_intILi32ELb1EEC2Ei(%"struct.ssdm_int<32, true>"* %0, i32 %1)
  %2 = load i32, i32* %op.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  ret void
}

; Function Attrs: nounwind readnone willreturn
declare i32 @llvm.fpga.legacy.part.select.i32(i32, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @"_ZplILi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE4plusERKS1_i"(%"struct.ap_int<33>"* noalias sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op, i32 %i_op) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %i_op.addr = alloca i32, align 4
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  store i32 %i_op, i32* %i_op.addr, align 4
  %0 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %i_op.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %ref.tmp, i32 %2)
  call void @_ZplILi32ELb1ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE4plusERKS1_RKS0_IXT1_EXT2_EE(%"struct.ap_int<33>"* sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_int_base<32, true>"* dereferenceable(4) %0, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %3) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN11ap_int_baseILi32ELb1EEaSILi33ELb1EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<33, true>"* dereferenceable(8) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<33, true>"* %op2, %"struct.ap_int_base<33, true>"** %op2.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %op2.addr, align 8
  %1 = bitcast %"struct.ap_int_base<33, true>"* %0 to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %1, i32 0, i32 0
  %2 = load i33, i33* %V, align 8
  %conv = trunc i33 %2 to i32
  %3 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %conv, i32* %V2, align 4
  ret %"struct.ap_int_base<32, true>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZplILi32ELb1ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE4plusERKS1_RKS0_IXT1_EXT2_EE(%"struct.ap_int<33>"* noalias sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op2) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %lhs = alloca %"struct.ap_int_base<33, true>", align 8
  %rhs = alloca %"struct.ap_int_base<33, true>", align 8
  %ret = alloca %"struct.ap_int_base<33, true>", align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op2, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %lhs to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #39
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  call void @_ZN11ap_int_baseILi33ELb1EEC2ILi32ELb1EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %lhs, %"struct.ap_int_base<32, true>"* dereferenceable(4) %1)
  %2 = bitcast %"struct.ap_int_base<33, true>"* %rhs to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #39
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  call void @_ZN11ap_int_baseILi33ELb1EEC2ILi32ELb1EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %rhs, %"struct.ap_int_base<32, true>"* dereferenceable(4) %3)
  %4 = bitcast %"struct.ap_int_base<33, true>"* %ret to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %4) #39
  call void @_ZN11ap_int_baseILi33ELb1EEC2Ei(%"struct.ap_int_base<33, true>"* %ret, i32 0)
  %5 = bitcast %"struct.ap_int_base<33, true>"* %lhs to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %5, i32 0, i32 0
  %6 = load i33, i33* %V, align 8
  %7 = bitcast %"struct.ap_int_base<33, true>"* %rhs to %"struct.ssdm_int<33, true>"*
  %V1 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %7, i32 0, i32 0
  %8 = load i33, i33* %V1, align 8
  %add = add nsw i33 %6, %8
  %9 = bitcast %"struct.ap_int_base<33, true>"* %ret to %"struct.ssdm_int<33, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %9, i32 0, i32 0
  store i33 %add, i33* %V2, align 8
  call void @_ZN6ap_intILi33EEC2ILi33ELb1EEERK11ap_int_baseIXT_EXT0_EE(%"struct.ap_int<33>"* %agg.result, %"struct.ap_int_base<33, true>"* dereferenceable(8) %ret)
  %10 = bitcast %"struct.ap_int_base<33, true>"* %ret to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %10) #39
  %11 = bitcast %"struct.ap_int_base<33, true>"* %rhs to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %11) #39
  %12 = bitcast %"struct.ap_int_base<33, true>"* %lhs to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %12) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi33ELb1EEC2ILi32ELb1EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<32, true>"* %1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  %conv = sext i32 %3 to i33
  call void @_ZN8ssdm_intILi33ELb1EEC2EDq33_i(%"struct.ssdm_int<33, true>"* %0, i33 %conv)
  %4 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %5 = bitcast %"struct.ap_int_base<32, true>"* %4 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %5, i32 0, i32 0
  %6 = load i32, i32* %V2, align 4
  %conv3 = sext i32 %6 to i33
  %7 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %7, i32 0, i32 0
  store i33 %conv3, i33* %V4, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi33ELb1EEC2Ei(%"struct.ap_int_base<33, true>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %1 = load i32, i32* %op.addr, align 4
  %conv = sext i32 %1 to i33
  call void @_ZN8ssdm_intILi33ELb1EEC2EDq33_i(%"struct.ssdm_int<33, true>"* %0, i33 %conv)
  %2 = load i32, i32* %op.addr, align 4
  %conv2 = sext i32 %2 to i33
  %3 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %3, i32 0, i32 0
  store i33 %conv2, i33* %V, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN6ap_intILi33EEC2ILi33ELb1EEERK11ap_int_baseIXT_EXT0_EE(%"struct.ap_int<33>"* %this, %"struct.ap_int_base<33, true>"* dereferenceable(8) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int<33>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  store %"struct.ap_int<33>"* %this, %"struct.ap_int<33>"** %this.addr, align 8
  store %"struct.ap_int_base<33, true>"* %op, %"struct.ap_int_base<33, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_int<33>"*, %"struct.ap_int<33>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int<33>"* %this1 to %"struct.ap_int_base<33, true>"*
  %1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %op.addr, align 8
  %2 = load %"struct.ap_int_base<33, true>", %"struct.ap_int_base<33, true>"* %1, align 8
  store %"struct.ap_int_base<33, true>" %2, %"struct.ap_int_base<33, true>"* %0, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi33ELb1EEC2EDq33_i(%"struct.ssdm_int<33, true>"* %this, i33 %o) unnamed_addr #21 comdat align 2 !dbg !4291 !fpga.function.pragma !4292 {
entry:
  %this.addr = alloca %"struct.ssdm_int<33, true>"*, align 8
  %o.addr = alloca i33, align 8
  store %"struct.ssdm_int<33, true>"* %this, %"struct.ssdm_int<33, true>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<33, true>"** %this.addr, metadata !4295, metadata !DIExpression()), !dbg !4297
  store i33 %o, i33* %o.addr, align 8
  call void @llvm.dbg.declare(metadata i33* %o.addr, metadata !4298, metadata !DIExpression()), !dbg !4299
  %this1 = load %"struct.ssdm_int<33, true>"*, %"struct.ssdm_int<33, true>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %this1, i32 0, i32 0, !dbg !4300
  %0 = load i33, i33* %o.addr, align 8, !dbg !4301
  store i33 %0, i33* %V, align 8, !dbg !4300
  ret void, !dbg !4302
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi32ELb1EEC2Ei(%"struct.ssdm_int<32, true>"* %this, i32 %o) unnamed_addr #21 comdat align 2 !dbg !4303 !fpga.function.pragma !4304 {
entry:
  %this.addr = alloca %"struct.ssdm_int<32, true>"*, align 8
  %o.addr = alloca i32, align 4
  store %"struct.ssdm_int<32, true>"* %this, %"struct.ssdm_int<32, true>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<32, true>"** %this.addr, metadata !4307, metadata !DIExpression()), !dbg !4309
  store i32 %o, i32* %o.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %o.addr, metadata !4310, metadata !DIExpression()), !dbg !4311
  %this1 = load %"struct.ssdm_int<32, true>"*, %"struct.ssdm_int<32, true>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %this1, i32 0, i32 0, !dbg !4312
  %0 = load i32, i32* %o.addr, align 4, !dbg !4313
  store i32 %0, i32* %V, align 4, !dbg !4312
  ret void, !dbg !4314
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<32, true>"* %1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  call void @_ZN8ssdm_intILi32ELb1EEC2Ei(%"struct.ssdm_int<32, true>"* %0, i32 %3)
  %4 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %call = call dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this1, %"struct.ap_int_base<32, true>"* dereferenceable(4) %4)
  call void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_int_base<32, true>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb0ELS0_6ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i32, align 4
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 0, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEntEv(%"struct.ap_int_base<32, true>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %4, i32 0, i32 0
  store i32 0, i32* %V, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #39
  %8 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_int_base<32, true>"* %8 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %9, i32 0, i32 0
  %10 = load i32, i32* %V2, align 4
  store i32 %10, i32* %__Val2__, align 4
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i32* %__Val2__ to i8*
  %13 = load i32, i32* %__Val2__, align 4
  %bit_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %13, i32 31, i32 31)
  %tobool = icmp ne i32 %bit_select, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %22 = bitcast %"struct.ap_int_base<32, true>"* %21 to %"struct.ssdm_int<32, true>"*
  %V3 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %22, i32 0, i32 0
  %23 = load i32, i32* %V3, align 4
  %24 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %24, i32 0, i32 0
  store i32 %23, i32* %V4, align 4
  %25 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %25) #39
  %26 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %26) #39
  %27 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %27) #39
  %28 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %28) #39
  %29 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %29) #39
  %30 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %30) #39
  ret %"struct.ap_int_base<32, true>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_int_base<32, true>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEntEv(%"struct.ap_int_base<32, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  %conv = zext i32 %1 to i64
  %cmp = icmp eq i64 %conv, 0
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK11ap_int_baseILi8ELb0EEeqILi32ELb1EEEbRKS_IXT_EXT0_EE(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op2, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %this1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<8, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %0, i32 0, i32 0
  %1 = load i8, i8* %V, align 1
  %conv = zext i8 %1 to i32
  %2 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %3 = bitcast %"struct.ap_int_base<32, true>"* %2 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  %4 = load i32, i32* %V2, align 4
  %cmp = icmp eq i32 %conv, %4
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK11ap_int_baseILi32ELb1EEneILi23ELb0EEEbRKS_IXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<23, false>"* dereferenceable(4) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<23, false>"* %op2, %"struct.ap_int_base<23, false>"** %op2.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  %2 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %op2.addr, align 8
  %3 = bitcast %"struct.ap_int_base<23, false>"* %2 to %"struct.ssdm_int<23, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %3, i32 0, i32 0
  %4 = load i23, i23* %V2, align 4
  %conv = zext i23 %4 to i32
  %cmp = icmp eq i32 %1, %conv
  %lnot = xor i1 %cmp, true
  ret i1 %lnot
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_int_base<32, true>"* %this, i32 %x) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %x.addr = alloca i32, align 4
  %tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %x, i32* %x.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %x.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %tmp to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  %4 = load %"struct.ap_int_base<32, true>", %"struct.ap_int_base<32, true>"* %tmp, align 4
  store %"struct.ap_int_base<32, true>" %4, %"struct.ap_int_base<32, true>"* %this1, align 4
  %5 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %5) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEeqILi1ELi33ELb0ELS0_5ELS1_0ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<33, true>", align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %op2, %"struct.ap_int_base<1, false>"** %op2.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  %conv = sext i32 %1 to i33
  %2 = bitcast %"struct.ap_int_base<33, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #39
  %3 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op2.addr, align 8
  call void @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<33, true>"* %ref.tmp, %"struct.ap_int_base<1, false>"* dereferenceable(1) %3)
  %4 = bitcast %"struct.ap_int_base<33, true>"* %ref.tmp to %"struct.ssdm_int<33, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %4, i32 0, i32 0
  %5 = load i33, i33* %V2, align 8
  %cmp = icmp eq i33 %conv, %5
  %6 = bitcast %"struct.ap_int_base<33, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %6) #39
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<1, false>"* %1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %2, i32 0, i32 0
  %3 = load i1, i1* %V, align 1
  %conv = zext i1 %3 to i33
  call void @_ZN8ssdm_intILi33ELb0EEC2EDq33_j(%"struct.ssdm_int<33, true>"* %0, i33 %conv)
  %4 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %call = call dereferenceable(8) %"struct.ap_int_base<33, true>"* @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<33, true>"* %this1, %"struct.ap_int_base<1, false>"* dereferenceable(1) %4)
  call void @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_int_base<33, true>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi33ELb0EEC2EDq33_j(%"struct.ssdm_int<33, true>"* %this, i33 %o) unnamed_addr #21 comdat align 2 !dbg !4315 !fpga.function.pragma !4316 {
entry:
  %this.addr = alloca %"struct.ssdm_int<33, true>"*, align 8
  %o.addr = alloca i33, align 8
  store %"struct.ssdm_int<33, true>"* %this, %"struct.ssdm_int<33, true>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<33, true>"** %this.addr, metadata !4319, metadata !DIExpression()), !dbg !4321
  store i33 %o, i33* %o.addr, align 8
  call void @llvm.dbg.declare(metadata i33* %o.addr, metadata !4322, metadata !DIExpression()), !dbg !4323
  %this1 = load %"struct.ssdm_int<33, true>"*, %"struct.ssdm_int<33, true>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %this1, i32 0, i32 0, !dbg !4324
  %0 = load i33, i33* %o.addr, align 8, !dbg !4325
  store i33 %0, i33* %V, align 8, !dbg !4324
  ret void, !dbg !4326
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(8) %"struct.ap_int_base<33, true>"* @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i1, align 1
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 -32, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEntEv(%"struct.ap_int_base<1, false>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %4, i32 0, i32 0
  store i33 0, i33* %V, align 8
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %7) #39
  %8 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_int_base<1, false>"* %8 to %"struct.ssdm_int<1, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %9, i32 0, i32 0
  %10 = load i1, i1* %V2, align 1
  store i1 %10, i1* %__Val2__, align 1
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i1* %__Val2__ to i8*
  %13 = load i1, i1* %__Val2__, align 1
  %bit_select = call i1 @llvm.fpga.legacy.part.select.i1(i1 %13, i32 0, i32 0)
  store i1 %bit_select, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 32, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 33
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_int_base<1, false>"* %23 to %"struct.ssdm_int<1, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %24, i32 0, i32 0
  %25 = load i1, i1* %V4, align 1
  %conv = zext i1 %25 to i33
  %26 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %26, i32 0, i32 0
  store i33 %conv, i33* %V5, align 8
  %27 = load i32, i32* %sh_amt, align 4
  %28 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %28, i32 0, i32 0
  %29 = load i33, i33* %V6, align 8
  %sh_prom = zext i32 %27 to i33
  %shl = shl i33 %29, %sh_prom
  store i33 %shl, i33* %V6, align 8
  br label %if.end8

if.else:                                          ; preds = %land.end
  %30 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V7 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %30, i32 0, i32 0
  store i33 0, i33* %V7, align 8
  br label %if.end8

if.end8:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39
  %34 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %34) #39
  %35 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  %36 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %36) #39
  %37 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %37) #39
  ret %"struct.ap_int_base<33, true>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_int_base<33, true>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEntEv(%"struct.ap_int_base<1, false>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %0, i32 0, i32 0
  %1 = load i1, i1* %V, align 1
  %conv = zext i1 %1 to i64
  %cmp = icmp eq i64 %conv, 0
  ret i1 %cmp
}

; Function Attrs: nounwind readnone willreturn
declare i1 @llvm.fpga.legacy.part.select.i1(i1, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr i32 @_ZNK11ap_int_baseILi1ELb0EE6to_intEv(%"struct.ap_int_base<1, false>"* %this) #28 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %0, i32 0, i32 0
  %1 = load i1, i1* %V, align 1
  %conv = zext i1 %1 to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EEC2Ei(%"struct.ap_int_base<32, true>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = load i32, i32* %op.addr, align 4
  call void @_ZN8ssdm_intILi32ELb0EEC2Ej(%"struct.ssdm_int<32, true>"* %0, i32 %1)
  %2 = load i32, i32* %op.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIiEEvT_(%"struct.ap_int_base<32, true>"* %this, i32 %val) #29 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %val.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi32ELb0EEC2Ej(%"struct.ssdm_int<32, true>"* %this, i32 %o) unnamed_addr #21 comdat align 2 !dbg !4327 !fpga.function.pragma !4328 {
entry:
  %this.addr = alloca %"struct.ssdm_int<32, true>"*, align 8
  %o.addr = alloca i32, align 4
  store %"struct.ssdm_int<32, true>"* %this, %"struct.ssdm_int<32, true>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<32, true>"** %this.addr, metadata !4331, metadata !DIExpression()), !dbg !4333
  store i32 %o, i32* %o.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %o.addr, metadata !4334, metadata !DIExpression()), !dbg !4335
  %this1 = load %"struct.ssdm_int<32, true>"*, %"struct.ssdm_int<32, true>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %this1, i32 0, i32 0, !dbg !4336
  %0 = load i32, i32* %o.addr, align 4, !dbg !4337
  store i32 %0, i32* %V, align 4, !dbg !4336
  ret void, !dbg !4338
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEneILi32ELi32ELb1ELS0_5ELS1_3ELi0EEEbRKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %ref.tmp = alloca %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>", align 8
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op2, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #39
  call void @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %ref.tmp, %"struct.ap_int_base<1, false>"* dereferenceable(1) %this1)
  %1 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %ref.tmp to %"struct.ssdm_int<34, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %1, i32 0, i32 0
  %2 = load i34, i34* %V, align 8
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %4 = bitcast %"struct.ap_int_base<32, true>"* %3 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %4, i32 0, i32 0
  %5 = load i32, i32* %V2, align 4
  %conv = sext i32 %5 to i34
  %cmp = icmp ne i34 %2, %conv
  %6 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %6) #39
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  store %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1 to %"struct.ssdm_int<34, false>"*
  %1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<1, false>"* %1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %2, i32 0, i32 0
  %3 = load i1, i1* %V, align 1
  %conv = zext i1 %3 to i34
  call void @_ZN8ssdm_intILi34ELb0EEC2EDq34_j(%"struct.ssdm_int<34, false>"* %0, i34 %conv)
  %4 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %call = call dereferenceable(8) %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1, %"struct.ap_int_base<1, false>"* dereferenceable(1) %4)
  call void @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi34ELb0EEC2EDq34_j(%"struct.ssdm_int<34, false>"* %this, i34 %o) unnamed_addr #21 comdat align 2 !dbg !4339 !fpga.function.pragma !4340 {
entry:
  %this.addr = alloca %"struct.ssdm_int<34, false>"*, align 8
  %o.addr = alloca i34, align 8
  store %"struct.ssdm_int<34, false>"* %this, %"struct.ssdm_int<34, false>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<34, false>"** %this.addr, metadata !4343, metadata !DIExpression()), !dbg !4345
  store i34 %o, i34* %o.addr, align 8
  call void @llvm.dbg.declare(metadata i34* %o.addr, metadata !4346, metadata !DIExpression()), !dbg !4347
  %this1 = load %"struct.ssdm_int<34, false>"*, %"struct.ssdm_int<34, false>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %this1, i32 0, i32 0, !dbg !4348
  %0 = load i34, i34* %o.addr, align 8, !dbg !4349
  store i34 %0, i34* %V, align 8, !dbg !4348
  ret void, !dbg !4350
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(8) %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi1ELi33ELb0ELS0_5ELS1_0ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this, %"struct.ap_int_base<1, false>"* dereferenceable(1) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i1, align 1
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %op, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 -32, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEntEv(%"struct.ap_int_base<1, false>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1 to %"struct.ssdm_int<34, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %4, i32 0, i32 0
  store i34 0, i34* %V, align 8
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %7) #39
  %8 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_int_base<1, false>"* %8 to %"struct.ssdm_int<1, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %9, i32 0, i32 0
  %10 = load i1, i1* %V2, align 1
  store i1 %10, i1* %__Val2__, align 1
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i1* %__Val2__ to i8*
  %13 = load i1, i1* %__Val2__, align 1
  %bit_select = call i1 @llvm.fpga.legacy.part.select.i1(i1 %13, i32 0, i32 0)
  store i1 %bit_select, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 32, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 34
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_int_base<1, false>"* %23 to %"struct.ssdm_int<1, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %24, i32 0, i32 0
  %25 = load i1, i1* %V4, align 1
  %conv = zext i1 %25 to i34
  %26 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1 to %"struct.ssdm_int<34, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %26, i32 0, i32 0
  store i34 %conv, i34* %V5, align 8
  %27 = load i32, i32* %sh_amt, align 4
  %28 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1 to %"struct.ssdm_int<34, false>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %28, i32 0, i32 0
  %29 = load i34, i34* %V6, align 8
  %sh_prom = zext i32 %27 to i34
  %shl = shl i34 %29, %sh_prom
  store i34 %shl, i34* %V6, align 8
  br label %if.end8

if.else:                                          ; preds = %land.end
  %30 = bitcast %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1 to %"struct.ssdm_int<34, false>"*
  %V7 = getelementptr inbounds %"struct.ssdm_int<34, false>", %"struct.ssdm_int<34, false>"* %30, i32 0, i32 0
  store i34 0, i34* %V7, align 8
  br label %if.end8

if.end8:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39
  %34 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %34) #39
  %35 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  %36 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %36) #39
  %37 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %37) #39
  ret %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, align 8
  store %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"* %this, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  %this1 = load %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"*, %"struct.ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %2, i32 0, i32 0
  %3 = load i79, i79* %V, align 16
  %conv = trunc i79 %3 to i32
  call void @_ZN8ssdm_intILi32ELb0EEC2Ej(%"struct.ssdm_int<32, true>"* %0, i32 %conv)
  %4 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this1, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %4)
  call void @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_int_base<32, true>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(4) %"struct.ap_int_base<32, true>"* @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i79, align 16
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 24, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %4, i32 0, i32 0
  store i32 0, i32* %V, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i79* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %7) #39
  %8 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %8 to %"struct.ssdm_int<79, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %9, i32 0, i32 0
  %10 = load i79, i79* %V2, align 16
  store i79 %10, i79* %__Val2__, align 16
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i79* %__Val2__ to i8*
  %13 = load i79, i79* %__Val2__, align 16
  %bit_select = call i79 @llvm.fpga.legacy.part.select.i79(i79 %13, i32 78, i32 78)
  %cast = trunc i79 %bit_select to i32
  %tobool = icmp ne i32 %cast, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i79* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 24, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 79
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %23 to %"struct.ssdm_int<79, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %24, i32 0, i32 0
  %25 = load i79, i79* %V4, align 16
  %26 = load i32, i32* %sh_amt, align 4
  %sh_prom = zext i32 %26 to i79
  %shr = lshr i79 %25, %sh_prom
  %conv = trunc i79 %shr to i32
  %27 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %27, i32 0, i32 0
  store i32 %conv, i32* %V5, align 4
  br label %if.end7

if.else:                                          ; preds = %land.end
  %28 = load i1, i1* %isneg, align 1
  %29 = zext i1 %28 to i64
  %cond = select i1 %28, i32 -1, i32 0
  %30 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %30, i32 0, i32 0
  store i32 %cond, i32* %V6, align 4
  br label %if.end7

if.end7:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39
  %34 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %34) #39
  %35 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  %36 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %36) #39
  %37 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %37) #39
  ret %"struct.ap_int_base<32, true>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_int_base<32, true>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %0, i32 0, i32 0
  %1 = load i79, i79* %V, align 16
  %cmp = icmp eq i79 %1, 0
  ret i1 %cmp
}

; Function Attrs: nounwind readnone willreturn
declare i79 @llvm.fpga.legacy.part.select.i79(i79, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEC2ILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %2, i32 0, i32 0
  %3 = load i79, i79* %V, align 16
  %conv = trunc i79 %3 to i1
  call void @_ZN8ssdm_intILi1ELb0EEC2EDq1_j(%"struct.ssdm_int<1, false>"* %0, i1 %conv)
  %4 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call dereferenceable(1) %"struct.ap_int_base<1, false>"* @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %this1, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %4)
  call void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_int_base<1, false>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi1ELb0EEC2EDq1_j(%"struct.ssdm_int<1, false>"* %this, i1 %o) unnamed_addr #21 comdat align 2 !dbg !4351 !fpga.function.pragma !4352 {
entry:
  %this.addr = alloca %"struct.ssdm_int<1, false>"*, align 8
  %o.addr = alloca i1, align 1
  store %"struct.ssdm_int<1, false>"* %this, %"struct.ssdm_int<1, false>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<1, false>"** %this.addr, metadata !4355, metadata !DIExpression()), !dbg !4357
  store i1 %o, i1* %o.addr, align 1
  call void @llvm.dbg.declare(metadata i1* %o.addr, metadata !4358, metadata !DIExpression()), !dbg !4359
  %this1 = load %"struct.ssdm_int<1, false>"*, %"struct.ssdm_int<1, false>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %this1, i32 0, i32 0, !dbg !4360
  %0 = load i1, i1* %o.addr, align 1, !dbg !4361
  store i1 %0, i1* %V, align 1, !dbg !4360
  ret void, !dbg !4362
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(1) %"struct.ap_int_base<1, false>"* @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSILi79ELi55ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_int_base<1, false>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i79, align 16
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  %deleted_zeros = alloca i1, align 1
  %deleted_ones = alloca i1, align 1
  %neg_src = alloca i1, align 1
  %newsignbit = alloca i1, align 1
  %__Val2__9 = alloca i1, align 1
  %__Result__11 = alloca i1, align 1
  %tmp14 = alloca i1, align 1
  %lD = alloca i1, align 1
  %__Val2__15 = alloca i79, align 16
  %__Result__17 = alloca i1, align 1
  %tmp21 = alloca i1, align 1
  %Range1_all_ones = alloca i1, align 1
  %Range1_all_zeros = alloca i1, align 1
  %Range2_all_ones = alloca i1, align 1
  %all_ones = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  %Range2 = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  %__Result__22 = alloca i79, align 16
  %__Val2__23 = alloca i79, align 16
  %tmp25 = alloca i79, align 16
  %ref.tmp = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>", align 16
  %Range1 = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  %__Result__28 = alloca i79, align 16
  %__Val2__29 = alloca i79, align 16
  %tmp32 = alloca i79, align 16
  %ref.tmp34 = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>", align 16
  %neg_trg = alloca i1, align 1
  %overflow = alloca i1, align 1
  %underflow = alloca i1, align 1
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 -32, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 24, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %4, i32 0, i32 0
  store i1 false, i1* %V, align 1
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i79* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %7) #39
  %8 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %8 to %"struct.ssdm_int<79, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %9, i32 0, i32 0
  %10 = load i79, i79* %V2, align 16
  store i79 %10, i79* %__Val2__, align 16
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i79* %__Val2__ to i8*
  %13 = load i79, i79* %__Val2__, align 16
  %bit_select = call i79 @llvm.fpga.legacy.part.select.i79(i79 %13, i32 78, i32 78)
  %cast = trunc i79 %bit_select to i32
  %tobool = icmp ne i32 %cast, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i79* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 56, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 79
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %23 to %"struct.ssdm_int<79, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %24, i32 0, i32 0
  %25 = load i79, i79* %V4, align 16
  %26 = load i32, i32* %sh_amt, align 4
  %sh_prom = zext i32 %26 to i79
  %shr = lshr i79 %25, %sh_prom
  %conv = trunc i79 %shr to i1
  %27 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %27, i32 0, i32 0
  store i1 %conv, i1* %V5, align 1
  br label %if.end8

if.else:                                          ; preds = %land.end
  %28 = load i1, i1* %isneg, align 1
  %29 = zext i1 %28 to i64
  %cond = select i1 %28, i32 -1, i32 0
  %conv6 = trunc i32 %cond to i1
  %30 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V7 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %30, i32 0, i32 0
  store i1 %conv6, i1* %V7, align 1
  br label %if.end8

if.end8:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %deleted_zeros to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %32) #39
  %33 = load i1, i1* %carry, align 1
  %lnot = xor i1 %33, true
  store i1 %lnot, i1* %deleted_zeros, align 1
  %34 = bitcast i1* %deleted_ones to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %34) #39
  store i1 true, i1* %deleted_ones, align 1
  %35 = bitcast i1* %neg_src to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %35) #39
  %36 = load i1, i1* %isneg, align 1
  store i1 %36, i1* %neg_src, align 1
  %37 = bitcast i1* %newsignbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %37) #39
  %38 = bitcast i1* %__Val2__9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %38) #39
  %39 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V10 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %39, i32 0, i32 0
  %40 = load i1, i1* %V10, align 1
  store i1 %40, i1* %__Val2__9, align 1
  %41 = bitcast i1* %__Result__11 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %41) #39
  %42 = bitcast i1* %__Val2__9 to i8*
  %43 = load i1, i1* %__Val2__9, align 1
  %bit_select12 = call i1 @llvm.fpga.legacy.part.select.i1(i1 %43, i32 0, i32 0)
  store i1 %bit_select12, i1* %__Result__11, align 1
  %44 = load i1, i1* %__Result__11, align 1
  store i1 %44, i1* %tmp14, align 1
  %45 = bitcast i1* %__Result__11 to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %45) #39
  %46 = bitcast i1* %__Val2__9 to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %46) #39
  %47 = load i1, i1* %tmp14, align 1
  store i1 %47, i1* %newsignbit, align 1
  %48 = bitcast i1* %lD to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %48) #39
  %49 = bitcast i79* %__Val2__15 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %49) #39
  %50 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %51 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %50 to %"struct.ssdm_int<79, false>"*
  %V16 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %51, i32 0, i32 0
  %52 = load i79, i79* %V16, align 16
  store i79 %52, i79* %__Val2__15, align 16
  %53 = bitcast i1* %__Result__17 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %53) #39
  %54 = bitcast i79* %__Val2__15 to i8*
  %55 = load i79, i79* %__Val2__15, align 16
  %bit_select18 = call i79 @llvm.fpga.legacy.part.select.i79(i79 %55, i32 57, i32 57)
  %cast19 = trunc i79 %bit_select18 to i32
  %tobool20 = icmp ne i32 %cast19, 0
  store i1 %tobool20, i1* %__Result__17, align 1
  %56 = load i1, i1* %__Result__17, align 1
  store i1 %56, i1* %tmp21, align 1
  %57 = bitcast i1* %__Result__17 to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %57) #39
  %58 = bitcast i79* %__Val2__15 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %58) #39
  %59 = load i1, i1* %tmp21, align 1
  store i1 %59, i1* %lD, align 1
  %60 = bitcast i1* %Range1_all_ones to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %60) #39
  store i1 true, i1* %Range1_all_ones, align 1
  %61 = bitcast i1* %Range1_all_zeros to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %61) #39
  store i1 true, i1* %Range1_all_zeros, align 1
  %62 = bitcast i1* %Range2_all_ones to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %62) #39
  store i1 true, i1* %Range2_all_ones, align 1
  %63 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %all_ones to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %63) #39
  call void @_ZN11ap_int_baseILi79ELb0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %all_ones, i32 -1)
  %64 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %64) #39
  call void @_ZN11ap_int_baseILi79ELb0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range2, i32 0)
  %65 = bitcast i79* %__Result__22 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %65) #39
  store i79 0, i79* %__Result__22, align 16
  %66 = bitcast i79* %__Val2__23 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %66) #39
  %67 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %68 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %67 to %"struct.ssdm_int<79, false>"*
  %V24 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %68, i32 0, i32 0
  %69 = load i79, i79* %V24, align 16
  store i79 %69, i79* %__Val2__23, align 16
  %70 = bitcast i79* %__Result__22 to i8*
  %71 = bitcast i79* %__Val2__23 to i8*
  %72 = load i79, i79* %__Val2__23, align 16
  %part_select = call i79 @llvm.fpga.legacy.part.select.i79(i79 %72, i32 58, i32 78)
  store i79 %part_select, i79* %__Result__22, align 16
  %73 = load i79, i79* %__Result__22, align 16
  store i79 %73, i79* %tmp25, align 16
  %74 = bitcast i79* %__Val2__23 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %74) #39
  %75 = bitcast i79* %__Result__22 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %75) #39
  %76 = load i79, i79* %tmp25, align 16
  %77 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range2 to %"struct.ssdm_int<79, false>"*
  %V26 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %77, i32 0, i32 0
  store i79 %76, i79* %V26, align 16
  %78 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %78) #39
  call void @_ZrsILi79ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT_EXT0_EE4arg1ERKS1_i(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>") %ref.tmp, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %all_ones, i32 58)
  %79 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*
  %call27 = call zeroext i1 @_ZNK11ap_int_baseILi79ELb0EEeqILi79ELb0EEEbRKS_IXT_EXT0_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range2, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %79)
  store i1 %call27, i1* %Range2_all_ones, align 1
  %80 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %80) #39
  %81 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %81) #39
  %82 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %82) #39
  call void @_ZN11ap_int_baseILi79ELb0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1, i32 0)
  %83 = bitcast i79* %__Result__28 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %83) #39
  store i79 0, i79* %__Result__28, align 16
  %84 = bitcast i79* %__Val2__29 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %84) #39
  %85 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %86 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %85 to %"struct.ssdm_int<79, false>"*
  %V30 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %86, i32 0, i32 0
  %87 = load i79, i79* %V30, align 16
  store i79 %87, i79* %__Val2__29, align 16
  %88 = bitcast i79* %__Result__28 to i8*
  %89 = bitcast i79* %__Val2__29 to i8*
  %90 = load i79, i79* %__Val2__29, align 16
  %part_select31 = call i79 @llvm.fpga.legacy.part.select.i79(i79 %90, i32 57, i32 78)
  store i79 %part_select31, i79* %__Result__28, align 16
  %91 = load i79, i79* %__Result__28, align 16
  store i79 %91, i79* %tmp32, align 16
  %92 = bitcast i79* %__Val2__29 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %92) #39
  %93 = bitcast i79* %__Result__28 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %93) #39
  %94 = load i79, i79* %tmp32, align 16
  %95 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1 to %"struct.ssdm_int<79, false>"*
  %V33 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %95, i32 0, i32 0
  store i79 %94, i79* %V33, align 16
  %96 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp34 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %96) #39
  call void @_ZrsILi79ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT_EXT0_EE4arg1ERKS1_i(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* sret(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>") %ref.tmp34, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %all_ones, i32 57)
  %97 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp34 to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*
  %call35 = call zeroext i1 @_ZNK11ap_int_baseILi79ELb0EEeqILi79ELb0EEEbRKS_IXT_EXT0_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %97)
  store i1 %call35, i1* %Range1_all_ones, align 1
  %98 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %ref.tmp34 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %98) #39
  %99 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1 to %"struct.ssdm_int<79, false>"*
  %V36 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %99, i32 0, i32 0
  %100 = load i79, i79* %V36, align 16
  %tobool37 = icmp ne i79 %100, 0
  %lnot38 = xor i1 %tobool37, true
  store i1 %lnot38, i1* %Range1_all_zeros, align 1
  %101 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %Range1 to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %101) #39
  %102 = load i1, i1* %deleted_zeros, align 1
  br i1 %102, label %land.rhs39, label %land.end41

land.rhs39:                                       ; preds = %if.end8
  %103 = load i1, i1* %carry, align 1
  br i1 %103, label %cond.true, label %cond.false

cond.true:                                        ; preds = %land.rhs39
  %104 = load i1, i1* %Range1_all_ones, align 1
  br label %cond.end

cond.false:                                       ; preds = %land.rhs39
  %105 = load i1, i1* %Range1_all_zeros, align 1
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond40 = phi i1 [ %104, %cond.true ], [ %105, %cond.false ]
  br label %land.end41

land.end41:                                       ; preds = %cond.end, %if.end8
  %106 = phi i1 [ false, %if.end8 ], [ %cond40, %cond.end ]
  store i1 %106, i1* %deleted_zeros, align 1
  %107 = load i1, i1* %carry, align 1
  br i1 %107, label %cond.true42, label %cond.false46

cond.true42:                                      ; preds = %land.end41
  %108 = load i1, i1* %Range2_all_ones, align 1
  br i1 %108, label %land.rhs43, label %land.end45

land.rhs43:                                       ; preds = %cond.true42
  %109 = load i1, i1* %lD, align 1
  %lnot44 = xor i1 %109, true
  br label %land.end45

land.end45:                                       ; preds = %land.rhs43, %cond.true42
  %110 = phi i1 [ false, %cond.true42 ], [ %lnot44, %land.rhs43 ]
  br label %cond.end47

cond.false46:                                     ; preds = %land.end41
  %111 = load i1, i1* %Range1_all_ones, align 1
  br label %cond.end47

cond.end47:                                       ; preds = %cond.false46, %land.end45
  %cond48 = phi i1 [ %110, %land.end45 ], [ %111, %cond.false46 ]
  store i1 %cond48, i1* %deleted_ones, align 1
  %112 = load i1, i1* %isneg, align 1
  br i1 %112, label %land.rhs49, label %land.end53

land.rhs49:                                       ; preds = %cond.end47
  %113 = load i1, i1* %carry, align 1
  br i1 %113, label %land.rhs50, label %land.end51

land.rhs50:                                       ; preds = %land.rhs49
  %114 = load i1, i1* %Range1_all_ones, align 1
  br label %land.end51

land.end51:                                       ; preds = %land.rhs50, %land.rhs49
  %115 = phi i1 [ false, %land.rhs49 ], [ %114, %land.rhs50 ]
  %lnot52 = xor i1 %115, true
  br label %land.end53

land.end53:                                       ; preds = %land.end51, %cond.end47
  %116 = phi i1 [ false, %cond.end47 ], [ %lnot52, %land.end51 ]
  store i1 %116, i1* %neg_src, align 1
  %117 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %all_ones to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %117) #39
  %118 = bitcast i1* %Range2_all_ones to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %118) #39
  %119 = bitcast i1* %Range1_all_zeros to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %119) #39
  %120 = bitcast i1* %Range1_all_ones to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %120) #39
  %121 = bitcast i1* %neg_trg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %121) #39
  store i1 false, i1* %neg_trg, align 1
  %122 = bitcast i1* %overflow to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %122) #39
  %123 = load i1, i1* %neg_trg, align 1
  br i1 %123, label %land.rhs54, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %land.end53
  %124 = load i1, i1* %deleted_zeros, align 1
  br i1 %124, label %land.end56, label %land.rhs54

land.rhs54:                                       ; preds = %lor.lhs.false, %land.end53
  %125 = load i1, i1* %isneg, align 1
  %lnot55 = xor i1 %125, true
  br label %land.end56

land.end56:                                       ; preds = %land.rhs54, %lor.lhs.false
  %126 = phi i1 [ false, %lor.lhs.false ], [ %lnot55, %land.rhs54 ]
  store i1 %126, i1* %overflow, align 1
  %127 = bitcast i1* %underflow to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %127) #39
  %128 = load i1, i1* %neg_trg, align 1
  br i1 %128, label %lor.lhs.false57, label %land.rhs58

lor.lhs.false57:                                  ; preds = %land.end56
  %129 = load i1, i1* %deleted_ones, align 1
  br i1 %129, label %land.end59, label %land.rhs58

land.rhs58:                                       ; preds = %lor.lhs.false57, %land.end56
  %130 = load i1, i1* %neg_src, align 1
  br label %land.end59

land.end59:                                       ; preds = %land.rhs58, %lor.lhs.false57
  %131 = phi i1 [ false, %lor.lhs.false57 ], [ %130, %land.rhs58 ]
  store i1 %131, i1* %underflow, align 1
  %132 = load i1, i1* %underflow, align 1
  %133 = load i1, i1* %overflow, align 1
  %134 = load i1, i1* %lD, align 1
  %135 = load i1, i1* %neg_src, align 1
  call void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE15overflow_adjustEbbbb(%"struct.ap_int_base<1, false>"* %this1, i1 zeroext %132, i1 zeroext %133, i1 zeroext %134, i1 zeroext %135)
  %136 = bitcast i1* %underflow to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %136) #39
  %137 = bitcast i1* %overflow to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %137) #39
  %138 = bitcast i1* %neg_trg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %138) #39
  %139 = bitcast i1* %lD to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %139) #39
  %140 = bitcast i1* %newsignbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %140) #39
  %141 = bitcast i1* %neg_src to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %141) #39
  %142 = bitcast i1* %deleted_ones to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %142) #39
  %143 = bitcast i1* %deleted_zeros to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %143) #39
  %144 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %144) #39
  %145 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %145) #39
  %146 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %146) #39
  %147 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %147) #39
  %148 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %148) #39
  %149 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %149) #39
  ret %"struct.ap_int_base<1, false>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE6reportEv(%"struct.ap_int_base<1, false>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi79ELb0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %1 = load i32, i32* %op.addr, align 4
  %conv = sext i32 %1 to i79
  call void @_ZN8ssdm_intILi79ELb0EEC2EDq79_j(%"struct.ssdm_int<79, false>"* %0, i79 %conv)
  %2 = load i32, i32* %op.addr, align 4
  %conv2 = sext i32 %2 to i79
  %3 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %3, i32 0, i32 0
  store i79 %conv2, i79* %V, align 16
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZrsILi79ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT_EXT0_EE4arg1ERKS1_i(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op, i32 %op2) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op2.addr = alloca i32, align 4
  %r = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", align 16
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  store i32 %op2, i32* %op2.addr, align 4
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %0) #39
  call void @_ZN11ap_int_baseILi79ELb0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r, i32 0)
  %1 = load i32, i32* %op2.addr, align 4
  %cmp = icmp sge i32 %1, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %2 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %3 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %2 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %3, i32 0, i32 0
  %4 = load i79, i79* %V, align 16
  %5 = load i32, i32* %op2.addr, align 4
  %sh_prom = zext i32 %5 to i79
  %shr = lshr i79 %4, %sh_prom
  br label %cond.end

cond.false:                                       ; preds = %entry
  %6 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %7 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %6 to %"struct.ssdm_int<79, false>"*
  %V1 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %7, i32 0, i32 0
  %8 = load i79, i79* %V1, align 16
  %9 = load i32, i32* %op2.addr, align 4
  %sub = sub nsw i32 0, %9
  %sh_prom2 = zext i32 %sub to i79
  %shl = shl i79 %8, %sh_prom2
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i79 [ %shr, %cond.true ], [ %shl, %cond.false ]
  %10 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r to %"struct.ssdm_int<79, false>"*
  %V3 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %10, i32 0, i32 0
  store i79 %cond, i79* %V3, align 16
  call void @_ZN7ap_uintILi79EEC2ILi79ELb0EEERK11ap_int_baseIXT_EXT0_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %r)
  %11 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %r to i8*
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %11) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK11ap_int_baseILi79ELb0EEeqILi79ELb0EEEbRKS_IXT_EXT0_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op2) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op2.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op2, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op2.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %0, i32 0, i32 0
  %1 = load i79, i79* %V, align 16
  %2 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op2.addr, align 8
  %3 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %2 to %"struct.ssdm_int<79, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %3, i32 0, i32 0
  %4 = load i79, i79* %V2, align 16
  %cmp = icmp eq i79 %1, %4
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE15overflow_adjustEbbbb(%"struct.ap_int_base<1, false>"* %this, i1 zeroext %underflow, i1 zeroext %overflow, i1 zeroext %lD, i1 zeroext %sign) #30 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %underflow.addr = alloca i1, align 1
  %overflow.addr = alloca i1, align 1
  %lD.addr = alloca i1, align 1
  %sign.addr = alloca i1, align 1
  %ref.tmp = alloca %"struct.ap_int_base<1, false>", align 1
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store i1 %underflow, i1* %underflow.addr, align 1
  store i1 %overflow, i1* %overflow.addr, align 1
  store i1 %lD, i1* %lD.addr, align 1
  store i1 %sign, i1* %sign.addr, align 1
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = load i1, i1* %underflow.addr, align 1
  br i1 %0, label %if.end, label %land.lhs.true

land.lhs.true:                                    ; preds = %entry
  %1 = load i1, i1* %overflow.addr, align 1
  br i1 %1, label %if.end, label %if.then

if.then:                                          ; preds = %land.lhs.true
  br label %if.end8

if.end:                                           ; preds = %land.lhs.true, %entry
  %2 = load i1, i1* %overflow.addr, align 1
  br i1 %2, label %if.then2, label %if.else

if.then2:                                         ; preds = %if.end
  %3 = bitcast %"struct.ap_int_base<1, false>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %3) #39
  call void @_ZN11ap_int_baseILi1ELb0EEC2Ei(%"struct.ap_int_base<1, false>"* %ref.tmp, i32 0)
  %4 = bitcast %"struct.ap_int_base<1, false>"* %ref.tmp to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %4, i32 0, i32 0
  %5 = load i1, i1* %V, align 1
  %conv = zext i1 %5 to i32
  %neg = xor i32 %conv, -1
  %conv3 = trunc i32 %neg to i1
  %6 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %6, i32 0, i32 0
  store i1 %conv3, i1* %V4, align 1
  %7 = bitcast %"struct.ap_int_base<1, false>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %7) #39
  br label %if.end8

if.else:                                          ; preds = %if.end
  %8 = load i1, i1* %underflow.addr, align 1
  br i1 %8, label %if.then5, label %if.end7

if.then5:                                         ; preds = %if.else
  %9 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %9, i32 0, i32 0
  store i1 false, i1* %V6, align 1
  br label %if.end7

if.end7:                                          ; preds = %if.then5, %if.else
  br label %if.end8

if.end8:                                          ; preds = %if.end7, %if.then2, %if.then
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi1ELb0EEC2Ei(%"struct.ap_int_base<1, false>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %1 = load i32, i32* %op.addr, align 4
  %conv = trunc i32 %1 to i1
  call void @_ZN8ssdm_intILi1ELb0EEC2EDq1_j(%"struct.ssdm_int<1, false>"* %0, i1 %conv)
  %2 = load i32, i32* %op.addr, align 4
  %conv2 = trunc i32 %2 to i1
  %3 = bitcast %"struct.ap_int_base<1, false>"* %this1 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %3, i32 0, i32 0
  store i1 %conv2, i1* %V, align 1
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN7ap_uintILi79EEC2ILi79ELb0EEERK11ap_int_baseIXT_EXT0_EE(%"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(16) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*
  %1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %2 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %1, align 16
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>" %2, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %0, align 16
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi79ELb0EEC2EDq79_j(%"struct.ssdm_int<79, false>"* %this, i79 %o) unnamed_addr #21 comdat align 2 !dbg !4363 !fpga.function.pragma !4364 {
entry:
  %this.addr = alloca %"struct.ssdm_int<79, false>"*, align 8
  %o.addr = alloca i79, align 16
  store %"struct.ssdm_int<79, false>"* %this, %"struct.ssdm_int<79, false>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<79, false>"** %this.addr, metadata !4367, metadata !DIExpression()), !dbg !4369
  store i79 %o, i79* %o.addr, align 16
  call void @llvm.dbg.declare(metadata i79* %o.addr, metadata !4370, metadata !DIExpression()), !dbg !4371
  %this1 = load %"struct.ssdm_int<79, false>"*, %"struct.ssdm_int<79, false>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %this1, i32 0, i32 0, !dbg !4372
  %0 = load i79, i79* %o.addr, align 16, !dbg !4373
  store i79 %0, i79* %V, align 16, !dbg !4372
  ret void, !dbg !4374
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %x) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %x.addr = alloca i32, align 4
  %tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %x, i32* %x.addr, align 4
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %1 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %x.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %tmp to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  %call = call dereferenceable(16) %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1, %"struct.ap_int_base<32, true>"* dereferenceable(4) %tmp)
  %4 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %4) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EErsEj(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %sh) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %sh.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %sh, i32* %sh.addr, align 4
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  call void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %agg.result, i32 0)
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %0, i32 0, i32 0
  %1 = load i79, i79* %V, align 16
  %2 = load i32, i32* %sh.addr, align 4
  %sh_prom = zext i32 %2 to i79
  %shr = lshr i79 %1, %sh_prom
  %3 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ssdm_int<79, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %3, i32 0, i32 0
  store i79 %shr, i79* %V2, align 16
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EElsEj(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %sh) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %sh.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %sh, i32* %sh.addr, align 4
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  call void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %agg.result, i32 0)
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %0, i32 0, i32 0
  %1 = load i79, i79* %V, align 16
  %2 = load i32, i32* %sh.addr, align 4
  %sh_prom = zext i32 %2 to i79
  %shl = shl i79 %1, %sh_prom
  %3 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %agg.result to %"struct.ssdm_int<79, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %3, i32 0, i32 0
  store i79 %shl, i79* %V2, align 16
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i32, align 4
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 24, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 0, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_int_base<32, true>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %4, i32 0, i32 0
  store i79 0, i79* %V, align 16
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #39
  %8 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_int_base<32, true>"* %8 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %9, i32 0, i32 0
  %10 = load i32, i32* %V2, align 4
  store i32 %10, i32* %__Val2__, align 4
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i32* %__Val2__ to i8*
  %13 = load i32, i32* %__Val2__, align 4
  %bit_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %13, i32 31, i32 31)
  %tobool = icmp ne i32 %bit_select, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ true, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 24, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 79
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_int_base<32, true>"* %23 to %"struct.ssdm_int<32, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %24, i32 0, i32 0
  %25 = load i32, i32* %V4, align 4
  %conv = sext i32 %25 to i79
  %26 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %26, i32 0, i32 0
  store i79 %conv, i79* %V5, align 16
  %27 = load i32, i32* %sh_amt, align 4
  %28 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %28, i32 0, i32 0
  %29 = load i79, i79* %V6, align 16
  %sh_prom = zext i32 %27 to i79
  %shl = shl i79 %29, %sh_prom
  store i79 %shl, i79* %V6, align 16
  br label %if.end8

if.else:                                          ; preds = %land.end
  %30 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V7 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %30, i32 0, i32 0
  store i79 0, i79* %V7, align 16
  br label %if.end8

if.end8:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39
  %34 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %34) #39
  %35 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  %36 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %36) #39
  %37 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %37) #39
  ret %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_int_base<32, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %0, i32 0, i32 0
  %1 = load i32, i32* %V, align 4
  %conv = sext i32 %1 to i64
  %cmp = icmp eq i64 %conv, 0
  ret i1 %cmp
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @"_ZmiILi8ELb0EEN11ap_int_baseIXT_EXT0_EE5RTypeIXL3$_032EEXLb1EEE5minusERKS1_i"(%"struct.ap_int<33>"* noalias sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %op, i32 %i_op) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %i_op.addr = alloca i32, align 4
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  store i32 %i_op, i32* %i_op.addr, align 4
  %0 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %i_op.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb1EEC2Ei(%"struct.ap_int_base<32, true>"* %ref.tmp, i32 %2)
  call void @_ZmiILi8ELb0ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE5minusERKS1_RKS0_IXT1_EXT2_EE(%"struct.ap_int<33>"* sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %0, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %3) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i64 @_ZNK11ap_int_baseILi33ELb1EEcvxEv(%"struct.ap_int_base<33, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %0, i32 0, i32 0
  %1 = load i33, i33* %V, align 8
  %conv = sext i33 %1 to i64
  ret i64 %conv
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZmiILi8ELb0ELi32ELb1EEN11ap_int_baseIXT_EXT0_EE5RTypeIXT1_EXT2_EE5minusERKS1_RKS0_IXT1_EXT2_EE(%"struct.ap_int<33>"* noalias sret(%"struct.ap_int<33>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %op, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op2) #21 comdat !fpga.function.pragma !4277 {
entry:
  %op.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op2.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %lhs = alloca %"struct.ap_int_base<33, true>", align 8
  %rhs = alloca %"struct.ap_int_base<33, true>", align 8
  %ret = alloca %"struct.ap_int_base<33, true>", align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op2, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %lhs to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %0) #39
  %1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  call void @_ZN11ap_int_baseILi33ELb1EEC2ILi8ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %lhs, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %1)
  %2 = bitcast %"struct.ap_int_base<33, true>"* %rhs to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %2) #39
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op2.addr, align 8
  call void @_ZN11ap_int_baseILi33ELb1EEC2ILi32ELb1EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %rhs, %"struct.ap_int_base<32, true>"* dereferenceable(4) %3)
  %4 = bitcast %"struct.ap_int_base<33, true>"* %ret to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %4) #39
  call void @_ZN11ap_int_baseILi33ELb1EEC2Ei(%"struct.ap_int_base<33, true>"* %ret, i32 0)
  %5 = bitcast %"struct.ap_int_base<33, true>"* %lhs to %"struct.ssdm_int<33, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %5, i32 0, i32 0
  %6 = load i33, i33* %V, align 8
  %7 = bitcast %"struct.ap_int_base<33, true>"* %rhs to %"struct.ssdm_int<33, true>"*
  %V1 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %7, i32 0, i32 0
  %8 = load i33, i33* %V1, align 8
  %sub = sub nsw i33 %6, %8
  %9 = bitcast %"struct.ap_int_base<33, true>"* %ret to %"struct.ssdm_int<33, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %9, i32 0, i32 0
  store i33 %sub, i33* %V2, align 8
  call void @_ZN6ap_intILi33EEC2ILi33ELb1EEERK11ap_int_baseIXT_EXT0_EE(%"struct.ap_int<33>"* %agg.result, %"struct.ap_int_base<33, true>"* dereferenceable(8) %ret)
  %10 = bitcast %"struct.ap_int_base<33, true>"* %ret to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %10) #39
  %11 = bitcast %"struct.ap_int_base<33, true>"* %rhs to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %11) #39
  %12 = bitcast %"struct.ap_int_base<33, true>"* %lhs to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %12) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi33ELb1EEC2ILi8ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<33, true>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* dereferenceable(1) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<33, true>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  store %"struct.ap_int_base<33, true>"* %this, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<33, true>"*, %"struct.ap_int_base<33, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %1 to %"struct.ssdm_int<8, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %2, i32 0, i32 0
  %3 = load i8, i8* %V, align 1
  %conv = zext i8 %3 to i33
  call void @_ZN8ssdm_intILi33ELb1EEC2EDq33_i(%"struct.ssdm_int<33, true>"* %0, i33 %conv)
  %4 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %op.addr, align 8
  %5 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %4 to %"struct.ssdm_int<8, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %5, i32 0, i32 0
  %6 = load i8, i8* %V2, align 1
  %conv3 = zext i8 %6 to i33
  %7 = bitcast %"struct.ap_int_base<33, true>"* %this1 to %"struct.ssdm_int<33, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<33, true>", %"struct.ssdm_int<33, true>"* %7, i32 0, i32 0
  store i33 %conv3, i33* %V4, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2ILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %1 to %"struct.ssdm_int<24, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %2, i32 0, i32 0
  %3 = load i24, i24* %V, align 4
  %conv = zext i24 %3 to i79
  call void @_ZN8ssdm_intILi79ELb0EEC2EDq79_j(%"struct.ssdm_int<79, false>"* %0, i79 %conv)
  %4 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call dereferenceable(16) %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %4)
  call void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi24ELi1ELb0ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* dereferenceable(4) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i24, align 4
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %op, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 24, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 23, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %4, i32 0, i32 0
  store i79 0, i79* %V, align 16
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #39
  %8 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %8 to %"struct.ssdm_int<24, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %9, i32 0, i32 0
  %10 = load i24, i24* %V2, align 4
  store i24 %10, i24* %__Val2__, align 4
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i24* %__Val2__ to i8*
  %13 = load i24, i24* %__Val2__, align 4
  %bit_select = call i24 @llvm.fpga.legacy.part.select.i24(i24 %13, i32 23, i32 23)
  %cast = zext i24 %bit_select to i32
  %tobool = icmp ne i32 %cast, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ false, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 1, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 79
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %23 to %"struct.ssdm_int<24, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %24, i32 0, i32 0
  %25 = load i24, i24* %V4, align 4
  %conv = zext i24 %25 to i79
  %26 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %26, i32 0, i32 0
  store i79 %conv, i79* %V5, align 16
  %27 = load i32, i32* %sh_amt, align 4
  %28 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %28, i32 0, i32 0
  %29 = load i79, i79* %V6, align 16
  %sh_prom = zext i32 %27 to i79
  %shl = shl i79 %29, %sh_prom
  store i79 %shl, i79* %V6, align 16
  br label %if.end8

if.else:                                          ; preds = %land.end
  %30 = bitcast %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<79, false>"*
  %V7 = getelementptr inbounds %"struct.ssdm_int<79, false>", %"struct.ssdm_int<79, false>"* %30, i32 0, i32 0
  store i79 0, i79* %V7, align 16
  br label %if.end8

if.end8:                                          ; preds = %if.else, %if.then3
  %31 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %31) #39
  %32 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %33) #39
  %34 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %34) #39
  %35 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  %36 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %36) #39
  %37 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %37) #39
  ret %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE6reportEv(%"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this) #27 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %this1 = load %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<24, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %0, i32 0, i32 0
  %1 = load i24, i24* %V, align 4
  %conv = zext i24 %1 to i64
  %cmp = icmp eq i64 %conv, 0
  ret i1 %cmp
}

; Function Attrs: nounwind readnone willreturn
declare i24 @llvm.fpga.legacy.part.select.i24(i24, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %this, i32 %v) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"*, align 8
  %v.addr = alloca i32, align 4
  store %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %v, i32* %v.addr, align 4
  %this1 = load %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*
  %1 = load i32, i32* %v.addr, align 4
  call void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK11ap_int_baseILi23ELb0EEclEii(%"struct.ap_range_ref<23, false>"* noalias sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this, i32 %Hi, i32 %Lo) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZNK11ap_int_baseILi23ELb0EE5rangeEii(%"struct.ap_range_ref<23, false>"* sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr i32 @_ZNK13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE2wlEv(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this) #31 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  ret i32 24
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEclEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %Hi, i32 %Lo) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE5rangeEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* sret(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK12ap_range_refIXT_EXT0_EE(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_range_ref<23, false>"* dereferenceable(16) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %val.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %tmp = alloca %"struct.ap_int_base<23, false>", align 4
  store %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_range_ref<23, false>"* %val, %"struct.ap_range_ref<23, false>"** %val.addr, align 8
  %this1 = load %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<23, false>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %1 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %val.addr, align 8
  call void @_ZN11ap_int_baseILi23ELb0EEC2ILi23ELb0EEERK12ap_range_refIXT_EXT0_EE(%"struct.ap_int_base<23, false>"* %tmp, %"struct.ap_range_ref<23, false>"* dereferenceable(16) %1)
  %call = call dereferenceable(16) %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK11ap_int_baseIXT_EXT0_EE(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, %"struct.ap_int_base<23, false>"* dereferenceable(4) %tmp)
  %2 = bitcast %"struct.ap_int_base<23, false>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %2) #39
  ret %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEixEj(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %index) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = load i32, i32* %index.addr, align 4
  call void @_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEi(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 %0)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSEb(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, i1 zeroext %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %val.addr = alloca i1, align 1
  %__Result__ = alloca i24, align 4
  %__Val2__ = alloca i24, align 4
  %__Repl2__ = alloca i1, align 1
  %tmp = alloca i24, align 4
  store %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i1 %val, i1* %val.addr, align 1
  %this1 = load %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast i24* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i24 0, i24* %__Result__, align 4
  %1 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %d_bv = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %2 to %"struct.ssdm_int<24, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %3, i32 0, i32 0
  %4 = load i24, i24* %V, align 4
  store i24 %4, i24* %__Val2__, align 4
  %5 = bitcast i1* %__Repl2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  %6 = load i1, i1* %val.addr, align 1
  %lnot = xor i1 %6, true
  %lnot2 = xor i1 %lnot, true
  store i1 %lnot2, i1* %__Repl2__, align 1
  %7 = bitcast i24* %__Result__ to i8*
  %8 = bitcast i24* %__Val2__ to i8*
  %9 = bitcast i1* %__Repl2__ to i8*
  %d_index = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 1
  %10 = load i32, i32* %d_index, align 8
  %d_index3 = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 1
  %11 = load i32, i32* %d_index3, align 8
  %12 = load i24, i24* %__Val2__, align 4
  %13 = load i1, i1* %__Repl2__, align 1
  %part_set = call i24 @llvm.fpga.legacy.part.set.i24.i1(i24 %12, i1 %13, i32 %10, i32 %11)
  store i24 %part_set, i24* %__Result__, align 4
  %14 = load i24, i24* %__Result__, align 4
  store i24 %14, i24* %tmp, align 4
  %15 = bitcast i1* %__Repl2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39
  %17 = bitcast i24* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %17) #39
  %18 = load i24, i24* %tmp, align 4
  %d_bv4 = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %19 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv4, align 8
  %20 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %19 to %"struct.ssdm_int<24, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %20, i32 0, i32 0
  store i24 %18, i24* %V5, align 4
  ret %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1
}

; Function Attrs: nounwind readnone willreturn
declare i24 @llvm.fpga.legacy.part.set.i24.i1(i24, i1, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN10af_bit_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEi(%"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %bv, i32 %index) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %bv.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %bv, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %bv.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %bv.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %0, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv, align 8
  %d_index = getelementptr inbounds %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_bit_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %index.addr, align 4
  store i32 %1, i32* %d_index, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi23ELb0EEC2ILi23ELb0EEERK12ap_range_refIXT_EXT0_EE(%"struct.ap_int_base<23, false>"* %this, %"struct.ap_range_ref<23, false>"* dereferenceable(16) %ref) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %ref.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<23, false>", align 4
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store %"struct.ap_range_ref<23, false>"* %ref, %"struct.ap_range_ref<23, false>"** %ref.addr, align 8
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<23, false>"* %this1 to %"struct.ssdm_int<23, false>"*
  %1 = bitcast %"struct.ap_int_base<23, false>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %ref.addr, align 8
  call void @_ZNK12ap_range_refILi23ELb0EE3getEv(%"struct.ap_int_base<23, false>"* sret(%"struct.ap_int_base<23, false>") %ref.tmp, %"struct.ap_range_ref<23, false>"* %2)
  %3 = bitcast %"struct.ap_int_base<23, false>"* %ref.tmp to %"struct.ssdm_int<23, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %3, i32 0, i32 0
  %4 = load i23, i23* %V, align 4
  %5 = bitcast %"struct.ap_int_base<23, false>"* %this1 to %"struct.ssdm_int<23, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %5, i32 0, i32 0
  store i23 %4, i23* %V2, align 4
  %6 = bitcast %"struct.ap_int_base<23, false>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %6) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi23ELb0EEERS2_RK11ap_int_baseIXT_EXT0_EE(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_int_base<23, false>"* dereferenceable(4) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %val.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %__Result__ = alloca i24, align 4
  %__Val2__ = alloca i24, align 4
  %__Repl2__ = alloca i23, align 4
  %tmp = alloca i24, align 4
  store %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<23, false>"* %val, %"struct.ap_int_base<23, false>"** %val.addr, align 8
  %this1 = load %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast i24* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i24 0, i24* %__Result__, align 4
  %1 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %d_bv = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %2 to %"struct.ssdm_int<24, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %3, i32 0, i32 0
  %4 = load i24, i24* %V, align 4
  store i24 %4, i24* %__Val2__, align 4
  %5 = bitcast i23* %__Repl2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %5) #39
  %6 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %val.addr, align 8
  %7 = bitcast %"struct.ap_int_base<23, false>"* %6 to %"struct.ssdm_int<23, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %7, i32 0, i32 0
  %8 = load i23, i23* %V2, align 4
  store i23 %8, i23* %__Repl2__, align 4
  %9 = bitcast i24* %__Result__ to i8*
  %10 = bitcast i24* %__Val2__ to i8*
  %11 = bitcast i23* %__Repl2__ to i8*
  %l_index = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 1
  %12 = load i32, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 2
  %13 = load i32, i32* %h_index, align 4
  %14 = load i24, i24* %__Val2__, align 4
  %15 = load i23, i23* %__Repl2__, align 4
  %part_set = call i24 @llvm.fpga.legacy.part.set.i24.i23(i24 %14, i23 %15, i32 %12, i32 %13)
  store i24 %part_set, i24* %__Result__, align 4
  %16 = load i24, i24* %__Result__, align 4
  store i24 %16, i24* %tmp, align 4
  %17 = bitcast i23* %__Repl2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %17) #39
  %18 = bitcast i24* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %18) #39
  %19 = bitcast i24* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %19) #39
  %20 = load i24, i24* %tmp, align 4
  %d_bv3 = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %21 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv3, align 8
  %22 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %21 to %"struct.ssdm_int<24, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %22, i32 0, i32 0
  store i24 %20, i24* %V4, align 4
  ret %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1
}

; Function Attrs: nounwind readnone willreturn
declare i24 @llvm.fpga.legacy.part.set.i24.i23(i24, i23, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK12ap_range_refILi23ELb0EE3getEv(%"struct.ap_int_base<23, false>"* noalias sret(%"struct.ap_int_base<23, false>") %agg.result, %"struct.ap_range_ref<23, false>"* %this) #32 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %__Result__ = alloca i23, align 4
  %__Val2__ = alloca i23, align 4
  %tmp = alloca i23, align 4
  store %"struct.ap_range_ref<23, false>"* %this, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  %this1 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  %0 = bitcast i23* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i23 0, i23* %__Result__, align 4
  %1 = bitcast i23* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_int_base<23, false>"* %2 to %"struct.ssdm_int<23, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %3, i32 0, i32 0
  %4 = load i23, i23* %V, align 4
  store i23 %4, i23* %__Val2__, align 4
  %5 = bitcast i23* %__Result__ to i8*
  %6 = bitcast i23* %__Val2__ to i8*
  %l_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 1
  %7 = load i32, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 2
  %8 = load i32, i32* %h_index, align 4
  %9 = load i23, i23* %__Val2__, align 4
  %part_select = call i23 @llvm.fpga.legacy.part.select.i23(i23 %9, i32 %7, i32 %8)
  store i23 %part_select, i23* %__Result__, align 4
  %10 = load i23, i23* %__Result__, align 4
  store i23 %10, i23* %tmp, align 4
  %11 = bitcast i23* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %11) #39
  %12 = bitcast i23* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %12) #39
  %13 = load i23, i23* %tmp, align 4
  %14 = bitcast %"struct.ap_int_base<23, false>"* %agg.result to %"struct.ssdm_int<23, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %14, i32 0, i32 0
  store i23 %13, i23* %V2, align 4
  ret void
}

; Function Attrs: nounwind readnone willreturn
declare i23 @llvm.fpga.legacy.part.select.i23(i23, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE5rangeEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* noalias sret(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>") %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %Hi, i32 %Lo) #33 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %agg.result, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN12af_range_refILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2EP13ap_fixed_baseILi24ELi1ELb0ELS0_5ELS1_3ELi0EEii(%"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %bv, i32 %h, i32 %l) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %bv.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %h.addr = alloca i32, align 4
  %l.addr = alloca i32, align 4
  store %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %bv, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %bv.addr, align 8
  store i32 %h, i32* %h.addr, align 4
  store i32 %l, i32* %l.addr, align 4
  %this1 = load %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %bv.addr, align 8
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %0, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %d_bv, align 8
  %l_index = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %l.addr, align 4
  store i32 %1, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>", %"struct.af_range_ref<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, i32 0, i32 2
  %2 = load i32, i32* %h.addr, align 4
  store i32 %2, i32* %h_index, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK11ap_int_baseILi23ELb0EE5rangeEii(%"struct.ap_range_ref<23, false>"* noalias sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this, i32 %Hi, i32 %Lo) #33 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN12ap_range_refILi23ELb0EEC2EP11ap_int_baseILi23ELb0EEii(%"struct.ap_range_ref<23, false>"* %agg.result, %"struct.ap_int_base<23, false>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN12ap_range_refILi23ELb0EEC2EP11ap_int_baseILi23ELb0EEii(%"struct.ap_range_ref<23, false>"* %this, %"struct.ap_int_base<23, false>"* %bv, i32 %h, i32 %l) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %bv.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %h.addr = alloca i32, align 4
  %l.addr = alloca i32, align 4
  store %"struct.ap_range_ref<23, false>"* %this, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  store %"struct.ap_int_base<23, false>"* %bv, %"struct.ap_int_base<23, false>"** %bv.addr, align 8
  store i32 %h, i32* %h.addr, align 4
  store i32 %l, i32* %l.addr, align 4
  %this1 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %bv.addr, align 8
  store %"struct.ap_int_base<23, false>"* %0, %"struct.ap_int_base<23, false>"** %d_bv, align 8
  %l_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %l.addr, align 4
  store i32 %1, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 2
  %2 = load i32, i32* %h.addr, align 4
  store i32 %2, i32* %h_index, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEC2Ei(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, i32 %x) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %x.addr = alloca i32, align 4
  %tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %x, i32* %x.addr, align 4
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<24, false>"*
  %1 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load i32, i32* %x.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %tmp to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  %call = call dereferenceable(4) %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1, %"struct.ap_int_base<32, true>"* dereferenceable(4) %tmp)
  %4 = bitcast %"struct.ap_int_base<32, true>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %4) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(4) %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* @_ZN13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSILi32ELi32ELb1ELS0_5ELS1_3ELi0EEERS2_RKS_IXT_EXT0_EXT1_EXT2_EXT3_EXT4_EE(%"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %_AP_F = alloca i32, align 4
  %F2 = alloca i32, align 4
  %QUAN_INC = alloca i32, align 4
  %carry = alloca i1, align 1
  %signbit = alloca i1, align 1
  %__Val2__ = alloca i32, align 4
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  %isneg = alloca i1, align 1
  %sh_amt = alloca i32, align 4
  store %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"*, %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 23, i32* %_AP_F, align 4
  %1 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  store i32 0, i32* %F2, align 4
  %2 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i32 0, i32* %QUAN_INC, align 4
  %3 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %call = call zeroext i1 @_ZNK13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EEntEv(%"struct.ap_int_base<32, true>"* %3)
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<24, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %4, i32 0, i32 0
  store i24 0, i24* %V, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  %5 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %5) #39
  store i1 false, i1* %carry, align 1
  %6 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %6) #39
  %7 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #39
  %8 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %9 = bitcast %"struct.ap_int_base<32, true>"* %8 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %9, i32 0, i32 0
  %10 = load i32, i32* %V2, align 4
  store i32 %10, i32* %__Val2__, align 4
  %11 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %11) #39
  %12 = bitcast i32* %__Val2__ to i8*
  %13 = load i32, i32* %__Val2__, align 4
  %bit_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %13, i32 31, i32 31)
  %tobool = icmp ne i32 %bit_select, 0
  store i1 %tobool, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  %16 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %16) #39
  %17 = load i1, i1* %tmp, align 1
  store i1 %17, i1* %signbit, align 1
  %18 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %18) #39
  %19 = load i1, i1* %signbit, align 1
  br i1 %19, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %if.end
  br label %land.end

land.end:                                         ; preds = %land.rhs, %if.end
  %20 = phi i1 [ false, %if.end ], [ true, %land.rhs ]
  store i1 %20, i1* %isneg, align 1
  %21 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %21) #39
  store i32 23, i32* %sh_amt, align 4
  %22 = load i32, i32* %sh_amt, align 4
  %cmp = icmp ult i32 %22, 24
  br i1 %cmp, label %if.then3, label %if.else

if.then3:                                         ; preds = %land.end
  %23 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %24 = bitcast %"struct.ap_int_base<32, true>"* %23 to %"struct.ssdm_int<32, true>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %24, i32 0, i32 0
  %25 = load i32, i32* %V4, align 4
  %26 = load i32, i32* %sh_amt, align 4
  %shl = shl i32 %25, %26
  %conv = trunc i32 %shl to i24
  %27 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<24, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %27, i32 0, i32 0
  store i24 %conv, i24* %V5, align 4
  br label %if.end7

if.else:                                          ; preds = %land.end
  %28 = bitcast %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<24, false>"*
  %V6 = getelementptr inbounds %"struct.ssdm_int<24, false>", %"struct.ssdm_int<24, false>"* %28, i32 0, i32 0
  store i24 0, i24* %V6, align 4
  br label %if.end7

if.end7:                                          ; preds = %if.else, %if.then3
  %29 = bitcast i32* %sh_amt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %29) #39
  %30 = bitcast i1* %isneg to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %30) #39
  %31 = bitcast i1* %signbit to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %31) #39
  %32 = bitcast i1* %carry to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %32) #39
  %33 = bitcast i32* %QUAN_INC to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %33) #39
  %34 = bitcast i32* %F2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %34) #39
  %35 = bitcast i32* %_AP_F to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %35) #39
  ret %"struct.ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN7ap_uintILi32EEC2Ej(%"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, i32 %val) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %val.addr = alloca i32, align 4
  store %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  %this1 = load %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %1 = load i32, i32* %val.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb0EEC2Ej(%"struct.ap_int_base<32, true>"* %0, i32 %1)
  %2 = bitcast %"struct.ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ap_int_base<32, true>"*
  %3 = load i32, i32* %val.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIjEEvT_(%"struct.ap_int_base<32, true>"* %2, i32 %3)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EEixEi(%"struct.ap_bit_ref<32, true>"* noalias sret(%"struct.ap_bit_ref<32, true>") %agg.result, %"struct.ap_int_base<32, true>"* %this, i32 %index) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = load i32, i32* %index.addr, align 4
  call void @_ZN10ap_bit_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEi(%"struct.ap_bit_ref<32, true>"* %agg.result, %"struct.ap_int_base<32, true>"* %this1, i32 %0)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi1ELb0EEixEi(%"struct.ap_bit_ref<1, false>"* noalias sret(%"struct.ap_bit_ref<1, false>") %agg.result, %"struct.ap_int_base<1, false>"* %this, i32 %index) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.ap_int_base<1, false>"* %this, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %this.addr, align 8
  %0 = load i32, i32* %index.addr, align 4
  call void @_ZN10ap_bit_refILi1ELb0EEC2EP11ap_int_baseILi1ELb0EEi(%"struct.ap_bit_ref<1, false>"* %agg.result, %"struct.ap_int_base<1, false>"* %this1, i32 %0)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_bit_ref<1, false>"* @_ZN10ap_bit_refILi1ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_bit_ref<1, false>"* %this, %"struct.ap_bit_ref<32, true>"* dereferenceable(16) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_bit_ref<1, false>"*, align 8
  %val.addr = alloca %"struct.ap_bit_ref<32, true>"*, align 8
  store %"struct.ap_bit_ref<1, false>"* %this, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  store %"struct.ap_bit_ref<32, true>"* %val, %"struct.ap_bit_ref<32, true>"** %val.addr, align 8
  %this1 = load %"struct.ap_bit_ref<1, false>"*, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  %0 = load %"struct.ap_bit_ref<32, true>"*, %"struct.ap_bit_ref<32, true>"** %val.addr, align 8
  %call = call zeroext i1 @_ZNK10ap_bit_refILi32ELb0EEcvbEv(%"struct.ap_bit_ref<32, true>"* %0)
  %conv = zext i1 %call to i64
  %call2 = call dereferenceable(16) %"struct.ap_bit_ref<1, false>"* @_ZN10ap_bit_refILi1ELb0EEaSEy(%"struct.ap_bit_ref<1, false>"* %this1, i64 %conv)
  ret %"struct.ap_bit_ref<1, false>"* %call2
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EEclEii(%"struct.ap_range_ref<32, false>"* noalias sret(%"struct.ap_range_ref<32, false>") %agg.result, %"struct.ap_int_base<32, true>"* %this, i32 %Hi, i32 %Lo) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN11ap_int_baseILi32ELb0EE5rangeEii(%"struct.ap_range_ref<32, false>"* sret(%"struct.ap_range_ref<32, false>") %agg.result, %"struct.ap_int_base<32, true>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi8ELb0EEclEii(%"struct.ap_range_ref<8, false>"* noalias sret(%"struct.ap_range_ref<8, false>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, i32 %Hi, i32 %Lo) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN11ap_int_baseILi8ELb0EE5rangeEii(%"struct.ap_range_ref<8, false>"* sret(%"struct.ap_range_ref<8, false>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_range_ref<8, false>"* @_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_range_ref<8, false>"* %this, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<8, false>"*, align 8
  %val.addr = alloca %"struct.ap_range_ref<32, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_range_ref<8, false>"* %this, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  store %"struct.ap_range_ref<32, false>"* %val, %"struct.ap_range_ref<32, false>"** %val.addr, align 8
  %this1 = load %"struct.ap_range_ref<8, false>"*, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %1 = load %"struct.ap_range_ref<32, false>"*, %"struct.ap_range_ref<32, false>"** %val.addr, align 8
  call void @_ZN11ap_int_baseILi32ELb0EEC2ILi32ELb0EEERK12ap_range_refIXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %ref.tmp, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %1)
  %call = call dereferenceable(16) %"struct.ap_range_ref<8, false>"* @_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE(%"struct.ap_range_ref<8, false>"* %this1, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %2 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %2) #39
  ret %"struct.ap_range_ref<8, false>"* %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi23ELb0EEclEii(%"struct.ap_range_ref<23, false>"* noalias sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this, i32 %Hi, i32 %Lo) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN11ap_int_baseILi23ELb0EE5rangeEii(%"struct.ap_range_ref<23, false>"* sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_range_ref<23, false>"* @_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RKS_IXT_EXT0_EE(%"struct.ap_range_ref<23, false>"* %this, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %val.addr = alloca %"struct.ap_range_ref<32, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_range_ref<23, false>"* %this, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  store %"struct.ap_range_ref<32, false>"* %val, %"struct.ap_range_ref<32, false>"** %val.addr, align 8
  %this1 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %1 = load %"struct.ap_range_ref<32, false>"*, %"struct.ap_range_ref<32, false>"** %val.addr, align 8
  call void @_ZN11ap_int_baseILi32ELb0EEC2ILi32ELb0EEERK12ap_range_refIXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %ref.tmp, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %1)
  %call = call dereferenceable(16) %"struct.ap_range_ref<23, false>"* @_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE(%"struct.ap_range_ref<23, false>"* %this1, %"struct.ap_int_base<32, true>"* dereferenceable(4) %ref.tmp)
  %2 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %2) #39
  ret %"struct.ap_range_ref<23, false>"* %call
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EEC2ILi32ELb0EEERK12ap_range_refIXT_EXT0_EE(%"struct.ap_int_base<32, true>"* %this, %"struct.ap_range_ref<32, false>"* dereferenceable(16) %ref) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %ref.addr = alloca %"struct.ap_range_ref<32, false>"*, align 8
  %ref.tmp = alloca %"struct.ap_int_base<32, true>", align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store %"struct.ap_range_ref<32, false>"* %ref, %"struct.ap_range_ref<32, false>"** %ref.addr, align 8
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %2 = load %"struct.ap_range_ref<32, false>"*, %"struct.ap_range_ref<32, false>"** %ref.addr, align 8
  call void @_ZNK12ap_range_refILi32ELb0EE3getEv(%"struct.ap_int_base<32, true>"* sret(%"struct.ap_int_base<32, true>") %ref.tmp, %"struct.ap_range_ref<32, false>"* %2)
  %3 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  %4 = load i32, i32* %V, align 4
  %5 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %5, i32 0, i32 0
  store i32 %4, i32* %V2, align 4
  %6 = bitcast %"struct.ap_int_base<32, true>"* %ref.tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %6) #39
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_range_ref<23, false>"* @_ZN12ap_range_refILi23ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE(%"struct.ap_range_ref<23, false>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<23, false>"*, align 8
  %val.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %tmp = alloca %"struct.ap_int_base<23, false>", align 4
  %__Result__ = alloca i23, align 4
  %__Val2__ = alloca i23, align 4
  %__Repl2__ = alloca i23, align 4
  %tmp3 = alloca i23, align 4
  store %"struct.ap_range_ref<23, false>"* %this, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %val, %"struct.ap_int_base<32, true>"** %val.addr, align 8
  %this1 = load %"struct.ap_range_ref<23, false>"*, %"struct.ap_range_ref<23, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<23, false>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %val.addr, align 8
  call void @_ZN11ap_int_baseILi23ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<23, false>"* %tmp, %"struct.ap_int_base<32, true>"* dereferenceable(4) %1)
  %2 = bitcast i23* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #39
  store i23 0, i23* %__Result__, align 4
  %3 = bitcast i23* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %3) #39
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 0
  %4 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %d_bv, align 8
  %5 = bitcast %"struct.ap_int_base<23, false>"* %4 to %"struct.ssdm_int<23, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %5, i32 0, i32 0
  %6 = load i23, i23* %V, align 4
  store i23 %6, i23* %__Val2__, align 4
  %7 = bitcast i23* %__Repl2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #39
  %8 = bitcast %"struct.ap_int_base<23, false>"* %tmp to %"struct.ssdm_int<23, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %8, i32 0, i32 0
  %9 = load i23, i23* %V2, align 4
  store i23 %9, i23* %__Repl2__, align 4
  %10 = bitcast i23* %__Result__ to i8*
  %11 = bitcast i23* %__Val2__ to i8*
  %12 = bitcast i23* %__Repl2__ to i8*
  %l_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 1
  %13 = load i32, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 2
  %14 = load i32, i32* %h_index, align 4
  %15 = load i23, i23* %__Val2__, align 4
  %16 = load i23, i23* %__Repl2__, align 4
  %part_set = call i23 @llvm.fpga.legacy.part.set.i23.i23(i23 %15, i23 %16, i32 %13, i32 %14)
  store i23 %part_set, i23* %__Result__, align 4
  %17 = load i23, i23* %__Result__, align 4
  store i23 %17, i23* %tmp3, align 4
  %18 = bitcast i23* %__Repl2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %18) #39
  %19 = bitcast i23* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %19) #39
  %20 = bitcast i23* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %20) #39
  %21 = load i23, i23* %tmp3, align 4
  %d_bv4 = getelementptr inbounds %"struct.ap_range_ref<23, false>", %"struct.ap_range_ref<23, false>"* %this1, i32 0, i32 0
  %22 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %d_bv4, align 8
  %23 = bitcast %"struct.ap_int_base<23, false>"* %22 to %"struct.ssdm_int<23, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %23, i32 0, i32 0
  store i23 %21, i23* %V5, align 4
  %24 = bitcast %"struct.ap_int_base<23, false>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %24) #39
  ret %"struct.ap_range_ref<23, false>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi23ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<23, false>"* %this1 to %"struct.ssdm_int<23, false>"*
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<32, true>"* %1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  %conv = trunc i32 %3 to i23
  call void @_ZN8ssdm_intILi23ELb0EEC2EDq23_j(%"struct.ssdm_int<23, false>"* %0, i23 %conv)
  %4 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %5 = bitcast %"struct.ap_int_base<32, true>"* %4 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %5, i32 0, i32 0
  %6 = load i32, i32* %V2, align 4
  %conv3 = trunc i32 %6 to i23
  %7 = bitcast %"struct.ap_int_base<23, false>"* %this1 to %"struct.ssdm_int<23, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %7, i32 0, i32 0
  store i23 %conv3, i23* %V4, align 4
  ret void
}

; Function Attrs: nounwind readnone willreturn
declare i23 @llvm.fpga.legacy.part.set.i23.i23(i23, i23, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi23ELb0EEC2EDq23_j(%"struct.ssdm_int<23, false>"* %this, i23 %o) unnamed_addr #21 comdat align 2 !dbg !4375 !fpga.function.pragma !4376 {
entry:
  %this.addr = alloca %"struct.ssdm_int<23, false>"*, align 8
  %o.addr = alloca i23, align 4
  store %"struct.ssdm_int<23, false>"* %this, %"struct.ssdm_int<23, false>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<23, false>"** %this.addr, metadata !4379, metadata !DIExpression()), !dbg !4381
  store i23 %o, i23* %o.addr, align 4
  call void @llvm.dbg.declare(metadata i23* %o.addr, metadata !4382, metadata !DIExpression()), !dbg !4383
  %this1 = load %"struct.ssdm_int<23, false>"*, %"struct.ssdm_int<23, false>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<23, false>", %"struct.ssdm_int<23, false>"* %this1, i32 0, i32 0, !dbg !4384
  %0 = load i23, i23* %o.addr, align 4, !dbg !4385
  store i23 %0, i23* %V, align 4, !dbg !4384
  ret void, !dbg !4386
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZNK12ap_range_refILi32ELb0EE3getEv(%"struct.ap_int_base<32, true>"* noalias sret(%"struct.ap_int_base<32, true>") %agg.result, %"struct.ap_range_ref<32, false>"* %this) #32 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<32, false>"*, align 8
  %__Result__ = alloca i32, align 4
  %__Val2__ = alloca i32, align 4
  %tmp = alloca i32, align 4
  store %"struct.ap_range_ref<32, false>"* %this, %"struct.ap_range_ref<32, false>"** %this.addr, align 8
  %this1 = load %"struct.ap_range_ref<32, false>"*, %"struct.ap_range_ref<32, false>"** %this.addr, align 8
  %0 = bitcast i32* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  store i32 0, i32* %__Result__, align 4
  %1 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %1) #39
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_int_base<32, true>"* %2 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  %4 = load i32, i32* %V, align 4
  store i32 %4, i32* %__Val2__, align 4
  %5 = bitcast i32* %__Result__ to i8*
  %6 = bitcast i32* %__Val2__ to i8*
  %l_index = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 1
  %7 = load i32, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 2
  %8 = load i32, i32* %h_index, align 4
  %9 = load i32, i32* %__Val2__, align 4
  %part_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %9, i32 %7, i32 %8)
  store i32 %part_select, i32* %__Result__, align 4
  %10 = load i32, i32* %__Result__, align 4
  store i32 %10, i32* %tmp, align 4
  %11 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %11) #39
  %12 = bitcast i32* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %12) #39
  %13 = load i32, i32* %tmp, align 4
  %14 = bitcast %"struct.ap_int_base<32, true>"* %agg.result to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %14, i32 0, i32 0
  store i32 %13, i32* %V2, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi23ELb0EE5rangeEii(%"struct.ap_range_ref<23, false>"* noalias sret(%"struct.ap_range_ref<23, false>") %agg.result, %"struct.ap_int_base<23, false>"* %this, i32 %Hi, i32 %Lo) #33 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<23, false>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<23, false>"* %this, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<23, false>"*, %"struct.ap_int_base<23, false>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN12ap_range_refILi23ELb0EEC2EP11ap_int_baseILi23ELb0EEii(%"struct.ap_range_ref<23, false>"* %agg.result, %"struct.ap_int_base<23, false>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_range_ref<8, false>"* @_ZN12ap_range_refILi8ELb0EEaSILi32ELb0EEERS0_RK11ap_int_baseIXT_EXT0_EE(%"struct.ap_range_ref<8, false>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<8, false>"*, align 8
  %val.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %tmp = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>", align 1
  %__Result__ = alloca i8, align 1
  %__Val2__ = alloca i8, align 1
  %__Repl2__ = alloca i8, align 1
  %tmp3 = alloca i8, align 1
  store %"struct.ap_range_ref<8, false>"* %this, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %val, %"struct.ap_int_base<32, true>"** %val.addr, align 8
  %this1 = load %"struct.ap_range_ref<8, false>"*, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %tmp to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %0) #39
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %val.addr, align 8
  call void @_ZN11ap_int_baseILi8ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %tmp, %"struct.ap_int_base<32, true>"* dereferenceable(4) %1)
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %__Result__) #39
  store i8 0, i8* %__Result__, align 1
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %__Val2__) #39
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %2 to %"struct.ssdm_int<8, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %3, i32 0, i32 0
  %4 = load i8, i8* %V, align 1
  store i8 %4, i8* %__Val2__, align 1
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %__Repl2__) #39
  %5 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %tmp to %"struct.ssdm_int<8, false>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %5, i32 0, i32 0
  %6 = load i8, i8* %V2, align 1
  store i8 %6, i8* %__Repl2__, align 1
  %l_index = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 1
  %7 = load i32, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 2
  %8 = load i32, i32* %h_index, align 4
  %9 = load i8, i8* %__Val2__, align 1
  %10 = load i8, i8* %__Repl2__, align 1
  %part_set = call i8 @llvm.fpga.legacy.part.set.i8.i8(i8 %9, i8 %10, i32 %7, i32 %8)
  store i8 %part_set, i8* %__Result__, align 1
  %11 = load i8, i8* %__Result__, align 1
  store i8 %11, i8* %tmp3, align 1
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %__Repl2__) #39
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %__Val2__) #39
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %__Result__) #39
  %12 = load i8, i8* %tmp3, align 1
  %d_bv4 = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 0
  %13 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %d_bv4, align 8
  %14 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %13 to %"struct.ssdm_int<8, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %14, i32 0, i32 0
  store i8 %12, i8* %V5, align 1
  %15 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %tmp to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %15) #39
  ret %"struct.ap_range_ref<8, false>"* %this1
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi8ELb0EEC2ILi32ELb0EEERKS_IXT_EXT0_EE(%"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_int_base<32, true>"* dereferenceable(4) %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %op.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %op, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %this1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<8, false>"*
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %2 = bitcast %"struct.ap_int_base<32, true>"* %1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  %conv = trunc i32 %3 to i8
  call void @_ZN8ssdm_intILi8ELb0EEC2Eh(%"struct.ssdm_int<8, false>"* %0, i8 zeroext %conv)
  %4 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %op.addr, align 8
  %5 = bitcast %"struct.ap_int_base<32, true>"* %4 to %"struct.ssdm_int<32, true>"*
  %V2 = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %5, i32 0, i32 0
  %6 = load i32, i32* %V2, align 4
  %conv3 = trunc i32 %6 to i8
  %7 = bitcast %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this1 to %"struct.ssdm_int<8, false>"*
  %V4 = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %7, i32 0, i32 0
  store i8 %conv3, i8* %V4, align 1
  ret void
}

; Function Attrs: nounwind readnone willreturn
declare i8 @llvm.fpga.legacy.part.set.i8.i8(i8, i8, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN8ssdm_intILi8ELb0EEC2Eh(%"struct.ssdm_int<8, false>"* %this, i8 zeroext %o) unnamed_addr #21 comdat align 2 !dbg !4387 !fpga.function.pragma !4388 {
entry:
  %this.addr = alloca %"struct.ssdm_int<8, false>"*, align 8
  %o.addr = alloca i8, align 1
  store %"struct.ssdm_int<8, false>"* %this, %"struct.ssdm_int<8, false>"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.ssdm_int<8, false>"** %this.addr, metadata !4391, metadata !DIExpression()), !dbg !4393
  store i8 %o, i8* %o.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %o.addr, metadata !4394, metadata !DIExpression()), !dbg !4395
  %this1 = load %"struct.ssdm_int<8, false>"*, %"struct.ssdm_int<8, false>"** %this.addr, align 8
  %V = getelementptr inbounds %"struct.ssdm_int<8, false>", %"struct.ssdm_int<8, false>"* %this1, i32 0, i32 0, !dbg !4396
  %0 = load i8, i8* %o.addr, align 1, !dbg !4397
  store i8 %0, i8* %V, align 1, !dbg !4396
  ret void, !dbg !4398
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi8ELb0EE5rangeEii(%"struct.ap_range_ref<8, false>"* noalias sret(%"struct.ap_range_ref<8, false>") %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, i32 %Hi, i32 %Lo) #33 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN12ap_range_refILi8ELb0EEC2EP11ap_int_baseILi8ELb0EEii(%"struct.ap_range_ref<8, false>"* %agg.result, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN12ap_range_refILi8ELb0EEC2EP11ap_int_baseILi8ELb0EEii(%"struct.ap_range_ref<8, false>"* %this, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %bv, i32 %h, i32 %l) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<8, false>"*, align 8
  %bv.addr = alloca %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, align 8
  %h.addr = alloca i32, align 4
  %l.addr = alloca i32, align 4
  store %"struct.ap_range_ref<8, false>"* %this, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %bv, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %bv.addr, align 8
  store i32 %h, i32* %h.addr, align 4
  store i32 %l, i32* %l.addr, align 4
  %this1 = load %"struct.ap_range_ref<8, false>"*, %"struct.ap_range_ref<8, false>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"*, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %bv.addr, align 8
  store %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"* %0, %"struct.ap_fixed_base<8, 8, false, AP_TRN_ZERO, AP_WRAP, 0>"** %d_bv, align 8
  %l_index = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %l.addr, align 4
  store i32 %1, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<8, false>", %"struct.ap_range_ref<8, false>"* %this1, i32 0, i32 2
  %2 = load i32, i32* %h.addr, align 4
  store i32 %2, i32* %h_index, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EE5rangeEii(%"struct.ap_range_ref<32, false>"* noalias sret(%"struct.ap_range_ref<32, false>") %agg.result, %"struct.ap_int_base<32, true>"* %this, i32 %Hi, i32 %Lo) #33 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %Hi.addr = alloca i32, align 4
  %Lo.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %Hi, i32* %Hi.addr, align 4
  store i32 %Lo, i32* %Lo.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = load i32, i32* %Hi.addr, align 4
  %1 = load i32, i32* %Lo.addr, align 4
  call void @_ZN12ap_range_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEii(%"struct.ap_range_ref<32, false>"* %agg.result, %"struct.ap_int_base<32, true>"* %this1, i32 %0, i32 %1)
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN12ap_range_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEii(%"struct.ap_range_ref<32, false>"* %this, %"struct.ap_int_base<32, true>"* %bv, i32 %h, i32 %l) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_range_ref<32, false>"*, align 8
  %bv.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %h.addr = alloca i32, align 4
  %l.addr = alloca i32, align 4
  store %"struct.ap_range_ref<32, false>"* %this, %"struct.ap_range_ref<32, false>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %bv, %"struct.ap_int_base<32, true>"** %bv.addr, align 8
  store i32 %h, i32* %h.addr, align 4
  store i32 %l, i32* %l.addr, align 4
  %this1 = load %"struct.ap_range_ref<32, false>"*, %"struct.ap_range_ref<32, false>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %bv.addr, align 8
  store %"struct.ap_int_base<32, true>"* %0, %"struct.ap_int_base<32, true>"** %d_bv, align 8
  %l_index = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %l.addr, align 4
  store i32 %1, i32* %l_index, align 8
  %h_index = getelementptr inbounds %"struct.ap_range_ref<32, false>", %"struct.ap_range_ref<32, false>"* %this1, i32 0, i32 2
  %2 = load i32, i32* %h.addr, align 4
  store i32 %2, i32* %h_index, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr zeroext i1 @_ZNK10ap_bit_refILi32ELb0EEcvbEv(%"struct.ap_bit_ref<32, true>"* %this) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_bit_ref<32, true>"*, align 8
  %__Val2__ = alloca i32, align 4
  %__Result__ = alloca i1, align 1
  %tmp = alloca i1, align 1
  store %"struct.ap_bit_ref<32, true>"* %this, %"struct.ap_bit_ref<32, true>"** %this.addr, align 8
  %this1 = load %"struct.ap_bit_ref<32, true>"*, %"struct.ap_bit_ref<32, true>"** %this.addr, align 8
  %0 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #39
  %d_bv = getelementptr inbounds %"struct.ap_bit_ref<32, true>", %"struct.ap_bit_ref<32, true>"* %this1, i32 0, i32 0
  %1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %d_bv, align 8
  %2 = bitcast %"struct.ap_int_base<32, true>"* %1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %2, i32 0, i32 0
  %3 = load i32, i32* %V, align 4
  store i32 %3, i32* %__Val2__, align 4
  %4 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %4) #39
  %5 = bitcast i32* %__Val2__ to i8*
  %d_index = getelementptr inbounds %"struct.ap_bit_ref<32, true>", %"struct.ap_bit_ref<32, true>"* %this1, i32 0, i32 1
  %6 = load i32, i32* %d_index, align 8
  %7 = load i32, i32* %__Val2__, align 4
  %bit_select = call i32 @llvm.fpga.legacy.part.select.i32(i32 %7, i32 %6, i32 %6)
  %tobool = icmp ne i32 %bit_select, 0
  store i1 %tobool, i1* %__Result__, align 1
  %8 = load i1, i1* %__Result__, align 1
  store i1 %8, i1* %tmp, align 1
  %9 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %9) #39
  %10 = bitcast i32* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %10) #39
  %11 = load i1, i1* %tmp, align 1
  ret i1 %11
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr dereferenceable(16) %"struct.ap_bit_ref<1, false>"* @_ZN10ap_bit_refILi1ELb0EEaSEy(%"struct.ap_bit_ref<1, false>"* %this, i64 %val) #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_bit_ref<1, false>"*, align 8
  %val.addr = alloca i64, align 8
  %__Result__ = alloca i1, align 1
  %__Val2__ = alloca i1, align 1
  %__Repl2__ = alloca i64, align 8
  %tmp = alloca i1, align 1
  store %"struct.ap_bit_ref<1, false>"* %this, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  store i64 %val, i64* %val.addr, align 8
  %this1 = load %"struct.ap_bit_ref<1, false>"*, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  %0 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %0) #39
  store i1 false, i1* %__Result__, align 1
  %1 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %1) #39
  %d_bv = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 0
  %2 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %d_bv, align 8
  %3 = bitcast %"struct.ap_int_base<1, false>"* %2 to %"struct.ssdm_int<1, false>"*
  %V = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %3, i32 0, i32 0
  %4 = load i1, i1* %V, align 1
  store i1 %4, i1* %__Val2__, align 1
  %5 = bitcast i64* %__Repl2__ to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %5) #39
  %6 = load i64, i64* %val.addr, align 8
  %tobool = icmp ne i64 %6, 0
  %lnot = xor i1 %tobool, true
  %lnot2 = xor i1 %lnot, true
  %conv = zext i1 %lnot2 to i64
  store i64 %conv, i64* %__Repl2__, align 8
  %7 = bitcast i1* %__Result__ to i8*
  %8 = bitcast i1* %__Val2__ to i8*
  %9 = bitcast i64* %__Repl2__ to i8*
  %d_index = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 1
  %10 = load i32, i32* %d_index, align 8
  %d_index3 = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 1
  %11 = load i32, i32* %d_index3, align 8
  %12 = load i1, i1* %__Val2__, align 1
  %13 = load i64, i64* %__Repl2__, align 8
  %part_set = call i1 @llvm.fpga.legacy.part.set.i1.i64(i1 %12, i64 %13, i32 %10, i32 %11)
  store i1 %part_set, i1* %__Result__, align 1
  %14 = load i1, i1* %__Result__, align 1
  store i1 %14, i1* %tmp, align 1
  %15 = bitcast i64* %__Repl2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %15) #39
  %16 = bitcast i1* %__Val2__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %16) #39
  %17 = bitcast i1* %__Result__ to i8*
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %17) #39
  %18 = load i1, i1* %tmp, align 1
  %d_bv4 = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 0
  %19 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %d_bv4, align 8
  %20 = bitcast %"struct.ap_int_base<1, false>"* %19 to %"struct.ssdm_int<1, false>"*
  %V5 = getelementptr inbounds %"struct.ssdm_int<1, false>", %"struct.ssdm_int<1, false>"* %20, i32 0, i32 0
  store i1 %18, i1* %V5, align 1
  ret %"struct.ap_bit_ref<1, false>"* %this1
}

; Function Attrs: nounwind readnone willreturn
declare i1 @llvm.fpga.legacy.part.set.i1.i64(i1, i64, i32, i32) #26

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN10ap_bit_refILi1ELb0EEC2EP11ap_int_baseILi1ELb0EEi(%"struct.ap_bit_ref<1, false>"* %this, %"struct.ap_int_base<1, false>"* %bv, i32 %index) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_bit_ref<1, false>"*, align 8
  %bv.addr = alloca %"struct.ap_int_base<1, false>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.ap_bit_ref<1, false>"* %this, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  store %"struct.ap_int_base<1, false>"* %bv, %"struct.ap_int_base<1, false>"** %bv.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.ap_bit_ref<1, false>"*, %"struct.ap_bit_ref<1, false>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_int_base<1, false>"*, %"struct.ap_int_base<1, false>"** %bv.addr, align 8
  store %"struct.ap_int_base<1, false>"* %0, %"struct.ap_int_base<1, false>"** %d_bv, align 8
  %d_index = getelementptr inbounds %"struct.ap_bit_ref<1, false>", %"struct.ap_bit_ref<1, false>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %index.addr, align 4
  store i32 %1, i32* %d_index, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN10ap_bit_refILi32ELb0EEC2EP11ap_int_baseILi32ELb0EEi(%"struct.ap_bit_ref<32, true>"* %this, %"struct.ap_int_base<32, true>"* %bv, i32 %index) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_bit_ref<32, true>"*, align 8
  %bv.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %index.addr = alloca i32, align 4
  store %"struct.ap_bit_ref<32, true>"* %this, %"struct.ap_bit_ref<32, true>"** %this.addr, align 8
  store %"struct.ap_int_base<32, true>"* %bv, %"struct.ap_int_base<32, true>"** %bv.addr, align 8
  store i32 %index, i32* %index.addr, align 4
  %this1 = load %"struct.ap_bit_ref<32, true>"*, %"struct.ap_bit_ref<32, true>"** %this.addr, align 8
  %d_bv = getelementptr inbounds %"struct.ap_bit_ref<32, true>", %"struct.ap_bit_ref<32, true>"* %this1, i32 0, i32 0
  %0 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %bv.addr, align 8
  store %"struct.ap_int_base<32, true>"* %0, %"struct.ap_int_base<32, true>"** %d_bv, align 8
  %d_index = getelementptr inbounds %"struct.ap_bit_ref<32, true>", %"struct.ap_bit_ref<32, true>"* %this1, i32 0, i32 1
  %1 = load i32, i32* %index.addr, align 4
  store i32 %1, i32* %d_index, align 8
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EEC2Ej(%"struct.ap_int_base<32, true>"* %this, i32 %op) unnamed_addr #21 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %op.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %op, i32* %op.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  %0 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %1 = load i32, i32* %op.addr, align 4
  call void @_ZN8ssdm_intILi32ELb0EEC2Ej(%"struct.ssdm_int<32, true>"* %0, i32 %1)
  %2 = load i32, i32* %op.addr, align 4
  %3 = bitcast %"struct.ap_int_base<32, true>"* %this1 to %"struct.ssdm_int<32, true>"*
  %V = getelementptr inbounds %"struct.ssdm_int<32, true>", %"struct.ssdm_int<32, true>"* %3, i32 0, i32 0
  store i32 %2, i32* %V, align 4
  ret void
}

; Function Attrs: alwaysinline nounwind
define linkonce_odr void @_ZN11ap_int_baseILi32ELb0EE18checkOverflowBaseCIjEEvT_(%"struct.ap_int_base<32, true>"* %this, i32 %val) #29 comdat align 2 !fpga.function.pragma !4277 {
entry:
  %this.addr = alloca %"struct.ap_int_base<32, true>"*, align 8
  %val.addr = alloca i32, align 4
  store %"struct.ap_int_base<32, true>"* %this, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  %this1 = load %"struct.ap_int_base<32, true>"*, %"struct.ap_int_base<32, true>"** %this.addr, align 8
  ret void
}

attributes #0 = { nounwind "fpga.demangled.name"="full_cache_structure_pilot" "fpga.top.func"="full_cache_structure_pilot" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { inaccessiblememonly nofree nosync nounwind willreturn }
attributes #3 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_weight_q" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #4 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_weight_scale" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #5 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_weight_bias" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #6 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_activation_q" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #7 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_activation_scale" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #8 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_input_tile" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #9 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_ps_tile" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #10 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_gamma" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #11 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_rope_table" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #12 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_kv" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #13 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_score" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #14 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_av_partial" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #15 = { alwaysinline nounwind "fpga.demangled.name"="full_cache_fp_act_weight" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #16 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="__hls_fptoui_float_i32" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #17 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="generic_cast_IEEE754" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #18 = { argmemonly nofree nosync nounwind willreturn }
attributes #19 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #20 = { inlinehint nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="mantissa" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #21 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #22 = { inlinehint nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="expv" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #23 = { inlinehint nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="__signbit" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #24 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="to_uint" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #25 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="to_ap_int_base" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #26 = { nounwind readnone willreturn }
attributes #27 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="report" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #28 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="to_int" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #29 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="checkOverflowBaseC" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #30 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="overflow_adjust" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #31 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="wl" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #32 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="get" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #33 = { alwaysinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "fpga.demangled.name"="range" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #34 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="8" "xlx.source"="user" }
attributes #35 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="32" "xlx.source"="user" }
attributes #36 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="0" "xlx.source"="user" }
attributes #37 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="42991616" "xlx.source"="user" }
attributes #38 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="2686976" "xlx.source"="user" }
attributes #39 = { nounwind }

!llvm.dbg.cu = !{!106, !1270}
!llvm.ident = !{!3452, !3452, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453, !3453}
!llvm.module.flags = !{!3454, !3455, !3456}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g_full_cache_weight_q", linkageName: "_ZN4laya4full21g_full_cache_weight_qE", scope: !2, file: !4, line: 6, type: !5, isLocal: false, isDefinition: true)
!2 = !DINamespace(name: "full", scope: !3)
!3 = !DINamespace(name: "laya", scope: null)
!4 = !DIFile(filename: "hls/platform/full_cache_storage.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheWeightQ", scope: !2, file: !6, line: 7, baseType: !7)
!6 = !DIFile(filename: "include/laya_full_cache_storage.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!7 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 42991616, elements: !13)
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !9, line: 24, baseType: !10)
!9 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h", directory: "")
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int8_t", file: !11, line: 37, baseType: !12)
!11 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!12 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!13 = !{!14}
!14 = !DISubrange(count: 5373952, lowerBound: 0)
!15 = !DIGlobalVariableExpression(var: !16, expr: !DIExpression())
!16 = distinct !DIGlobalVariable(name: "g_full_cache_weight_scale", linkageName: "_ZN4laya4full25g_full_cache_weight_scaleE", scope: !2, file: !4, line: 7, type: !17, isLocal: false, isDefinition: true)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheWeightScale", scope: !2, file: !6, line: 8, baseType: !18)
!18 = !DICompositeType(tag: DW_TAG_array_type, baseType: !19, size: 2686976, elements: !23)
!19 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !20, line: 25, baseType: !21)
!20 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!21 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !11, line: 40, baseType: !22)
!22 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!23 = !{!24}
!24 = !DISubrange(count: 167936, lowerBound: 0)
!25 = !DIGlobalVariableExpression(var: !26, expr: !DIExpression())
!26 = distinct !DIGlobalVariable(name: "g_full_cache_weight_bias", linkageName: "_ZN4laya4full24g_full_cache_weight_biasE", scope: !2, file: !4, line: 8, type: !27, isLocal: false, isDefinition: true)
!27 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheWeightBias", scope: !2, file: !6, line: 9, baseType: !28)
!28 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 167936, elements: !30)
!29 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!30 = !{!31}
!31 = !DISubrange(count: 5248, lowerBound: 0)
!32 = !DIGlobalVariableExpression(var: !33, expr: !DIExpression())
!33 = distinct !DIGlobalVariable(name: "g_full_cache_activation_q", linkageName: "_ZN4laya4full25g_full_cache_activation_qE", scope: !2, file: !4, line: 9, type: !34, isLocal: false, isDefinition: true)
!34 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheActivationQ", scope: !2, file: !6, line: 10, baseType: !35)
!35 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 524288, elements: !36)
!36 = !{!37, !38, !39}
!37 = !DISubrange(count: 16, lowerBound: 0)
!38 = !DISubrange(count: 128, lowerBound: 0)
!39 = !DISubrange(count: 32, lowerBound: 0)
!40 = !DIGlobalVariableExpression(var: !41, expr: !DIExpression())
!41 = distinct !DIGlobalVariable(name: "g_full_cache_activation_scale", linkageName: "_ZN4laya4full29g_full_cache_activation_scaleE", scope: !2, file: !4, line: 10, type: !42, isLocal: false, isDefinition: true)
!42 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheActivationScale", scope: !2, file: !6, line: 11, baseType: !43)
!43 = !DICompositeType(tag: DW_TAG_array_type, baseType: !19, size: 32768, elements: !44)
!44 = !{!37, !38}
!45 = !DIGlobalVariableExpression(var: !46, expr: !DIExpression())
!46 = distinct !DIGlobalVariable(name: "g_full_cache_input_tile", linkageName: "_ZN4laya4full23g_full_cache_input_tileE", scope: !2, file: !4, line: 11, type: !47, isLocal: false, isDefinition: true)
!47 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheInputTile", scope: !2, file: !6, line: 12, baseType: !48)
!48 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 2097152, elements: !49)
!49 = !{!37, !50}
!50 = !DISubrange(count: 4096, lowerBound: 0)
!51 = !DIGlobalVariableExpression(var: !52, expr: !DIExpression())
!52 = distinct !DIGlobalVariable(name: "g_full_cache_ps_tile", linkageName: "_ZN4laya4full20g_full_cache_ps_tileE", scope: !2, file: !4, line: 12, type: !53, isLocal: false, isDefinition: true)
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCachePsTile", scope: !2, file: !6, line: 13, baseType: !54)
!54 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 2686976, elements: !55)
!55 = !{!37, !31}
!56 = !DIGlobalVariableExpression(var: !57, expr: !DIExpression())
!57 = distinct !DIGlobalVariable(name: "g_full_cache_gamma", linkageName: "_ZN4laya4full18g_full_cache_gammaE", scope: !2, file: !4, line: 13, type: !58, isLocal: false, isDefinition: true)
!58 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheGamma", scope: !2, file: !6, line: 14, baseType: !59)
!59 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 65536, elements: !60)
!60 = !{!61, !62}
!61 = !DISubrange(count: 2, lowerBound: 0)
!62 = !DISubrange(count: 1024, lowerBound: 0)
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression())
!64 = distinct !DIGlobalVariable(name: "g_full_cache_rope_table", linkageName: "_ZN4laya4full23g_full_cache_rope_tableE", scope: !2, file: !4, line: 14, type: !65, isLocal: false, isDefinition: true)
!65 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheRopeTable", scope: !2, file: !6, line: 15, baseType: !66)
!66 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 4198400, elements: !67)
!67 = !{!61, !68, !69}
!68 = !DISubrange(count: 1025, lowerBound: 0)
!69 = !DISubrange(count: 64, lowerBound: 0)
!70 = !DIGlobalVariableExpression(var: !71, expr: !DIExpression())
!71 = distinct !DIGlobalVariable(name: "g_full_cache_kv", linkageName: "_ZN4laya4full15g_full_cache_kvE", scope: !2, file: !4, line: 15, type: !72, isLocal: false, isDefinition: true)
!72 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheKv", scope: !2, file: !6, line: 16, baseType: !73)
!73 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 8388608, elements: !74)
!74 = !{!61, !61, !62, !69}
!75 = !DIGlobalVariableExpression(var: !76, expr: !DIExpression())
!76 = distinct !DIGlobalVariable(name: "g_full_cache_score", linkageName: "_ZN4laya4full18g_full_cache_scoreE", scope: !2, file: !4, line: 16, type: !77, isLocal: false, isDefinition: true)
!77 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheScore", scope: !2, file: !6, line: 17, baseType: !78)
!78 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 1048576, elements: !79)
!79 = !{!61, !37, !62}
!80 = !DIGlobalVariableExpression(var: !81, expr: !DIExpression())
!81 = distinct !DIGlobalVariable(name: "g_full_cache_av_partial", linkageName: "_ZN4laya4full23g_full_cache_av_partialE", scope: !2, file: !4, line: 17, type: !82, isLocal: false, isDefinition: true)
!82 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheAvPartial", scope: !2, file: !6, line: 18, baseType: !83)
!83 = !DICompositeType(tag: DW_TAG_array_type, baseType: !29, size: 32768, elements: !84)
!84 = !{!37, !69}
!85 = !DIGlobalVariableExpression(var: !86, expr: !DIExpression())
!86 = distinct !DIGlobalVariable(name: "g_full_cache_fp_act_weight", linkageName: "_ZN4laya4full26g_full_cache_fp_act_weightE", scope: !2, file: !4, line: 18, type: !87, isLocal: false, isDefinition: true)
!87 = !DIDerivedType(tag: DW_TAG_typedef, name: "FullCacheFpActWeight", scope: !2, file: !6, line: 19, baseType: !88)
!88 = !DICompositeType(tag: DW_TAG_array_type, baseType: !19, size: 4210688, elements: !89)
!89 = !{!90, !91}
!90 = !DISubrange(count: 256, lowerBound: 0)
!91 = !DISubrange(count: 1028, lowerBound: 0)
!92 = !DIGlobalVariableExpression(var: !93, expr: !DIExpression())
!93 = distinct !DIGlobalVariable(name: "runtime", scope: !94, file: !95, line: 24, type: !1054, isLocal: true, isDefinition: true)
!94 = distinct !DISubprogram(name: "full_cache_structure_pilot", scope: !95, file: !95, line: 3, type: !96, scopeLine: 5, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!95 = !DIFile(filename: "tests/full_cache_structure_pilot.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!96 = !DISubroutineType(types: !97)
!97 = !{null, !98, !101, !101, !101, !101, !101, !104, !105, !105}
!98 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !20, line: 24, baseType: !99)
!99 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !11, line: 38, baseType: !100)
!100 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!101 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !20, line: 26, baseType: !102)
!102 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !11, line: 42, baseType: !103)
!103 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!104 = !DIBasicType(name: "bool", size: 8, encoding: DW_ATE_boolean)
!105 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 64)
!106 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !107, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !108, retainedTypes: !171, globals: !172, imports: !173, splitDebugInlining: false, nameTableKind: GNU)
!107 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/structure-pilot-vitis/csynth/hls/.autopilot/db/full_cache_structure_pilot.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/structure-pilot-vitis", checksumkind: CSK_MD5, checksum: "1f7bd6f26ce12f1aa715ec4feef240d9")
!108 = !{!109, !136, !141, !151, !160}
!109 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Buffer", scope: !3, file: !110, line: 13, baseType: !98, size: 8, elements: !111, identifier: "_ZTSN4laya6BufferE")
!110 = !DIFile(filename: "include/laya_types.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!111 = !{!112, !113, !114, !115, !116, !117, !118, !119, !120, !121, !122, !123, !124, !125, !126, !127, !128, !129, !130, !131, !132, !133, !134, !135}
!112 = !DIEnumerator(name: "NONE", value: 0)
!113 = !DIEnumerator(name: "HIDDEN", value: 1)
!114 = !DIEnumerator(name: "NORM", value: 2)
!115 = !DIEnumerator(name: "TMP", value: 3)
!116 = !DIEnumerator(name: "MARKER", value: 4)
!117 = !DIEnumerator(name: "QKV", value: 5)
!118 = !DIEnumerator(name: "WI", value: 6)
!119 = !DIEnumerator(name: "GATE", value: 7)
!120 = !DIEnumerator(name: "ATT_OUT", value: 8)
!121 = !DIEnumerator(name: "DEC_FF", value: 9)
!122 = !DIEnumerator(name: "HEAD_WORK", value: 10)
!123 = !DIEnumerator(name: "TYPE_ROWS", value: 11)
!124 = !DIEnumerator(name: "LN_ROW", value: 32)
!125 = !DIEnumerator(name: "QUANT_INPUT", value: 33)
!126 = !DIEnumerator(name: "A8", value: 34)
!127 = !DIEnumerator(name: "WEIGHT", value: 35)
!128 = !DIEnumerator(name: "PS", value: 36)
!129 = !DIEnumerator(name: "KV", value: 37)
!130 = !DIEnumerator(name: "SCORE_PROB", value: 38)
!131 = !DIEnumerator(name: "Q_TILE", value: 39)
!132 = !DIEnumerator(name: "AV_PARTIAL", value: 40)
!133 = !DIEnumerator(name: "ROPE_HEAD", value: 41)
!134 = !DIEnumerator(name: "LN_GAMMA", value: 42)
!135 = !DIEnumerator(name: "ROPE_TABLE", value: 43)
!136 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "RowSpace", scope: !3, file: !110, line: 15, baseType: !98, size: 8, elements: !137, identifier: "_ZTSN4laya8RowSpaceE")
!137 = !{!138, !139, !140}
!138 = !DIEnumerator(name: "TOKEN", value: 0)
!139 = !DIEnumerator(name: "MARKER", value: 1)
!140 = !DIEnumerator(name: "BATCH", value: 2)
!141 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Content", scope: !3, file: !110, line: 17, baseType: !98, size: 8, elements: !142, identifier: "_ZTSN4laya7ContentE")
!142 = !{!143, !144, !145, !146, !147, !148, !149, !150}
!143 = !DIEnumerator(name: "UNDEFINED", value: 0)
!144 = !DIEnumerator(name: "F32", value: 1)
!145 = !DIEnumerator(name: "QKV_RAW", value: 2)
!146 = !DIEnumerator(name: "QKV_FINAL", value: 3)
!147 = !DIEnumerator(name: "Q8_TILE", value: 4)
!148 = !DIEnumerator(name: "Q8_WEIGHT", value: 5)
!149 = !DIEnumerator(name: "SCORE", value: 6)
!150 = !DIEnumerator(name: "PROB", value: 7)
!151 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "CacheState", scope: !3, file: !110, line: 16, baseType: !98, size: 8, elements: !152, identifier: "_ZTSN4laya10CacheStateE")
!152 = !{!153, !154, !155, !156, !157, !158, !159}
!153 = !DIEnumerator(name: "FREE", value: 0)
!154 = !DIEnumerator(name: "FILL", value: 1)
!155 = !DIEnumerator(name: "READY", value: 2)
!156 = !DIEnumerator(name: "READ", value: 3)
!157 = !DIEnumerator(name: "EXCLUSIVE_RW", value: 4)
!158 = !DIEnumerator(name: "DRAIN", value: 5)
!159 = !DIEnumerator(name: "INVALID", value: 6)
!160 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "Status", scope: !3, file: !110, line: 8, baseType: !19, size: 16, elements: !161, identifier: "_ZTSN4laya6StatusE")
!161 = !{!162, !163, !164, !165, !166, !167, !168, !169, !170}
!162 = !DIEnumerator(name: "OK", value: 0)
!163 = !DIEnumerator(name: "E_ABI", value: 1)
!164 = !DIEnumerator(name: "E_MODEL", value: 2)
!165 = !DIEnumerator(name: "E_SHAPE", value: 3)
!166 = !DIEnumerator(name: "E_INDEX", value: 4)
!167 = !DIEnumerator(name: "E_BUFFER", value: 5)
!168 = !DIEnumerator(name: "E_NUMERICAL", value: 6)
!169 = !DIEnumerator(name: "E_PROTOCOL", value: 7)
!170 = !DIEnumerator(name: "E_INTERNAL", value: 8)
!171 = !{!8, !101, !19, !29, !151}
!172 = !{!92}
!173 = !{!174, !177, !181, !185, !189, !192, !194, !196, !198, !202, !205, !208, !211, !214, !216, !217, !218, !219, !223, !225, !227, !229, !231, !234, !237, !240, !243, !246, !248, !357, !361, !365, !382, !385, !390, !398, !406, !410, !417, !421, !425, !427, !429, !433, !442, !446, !452, !458, !460, !464, !468, !472, !476, !484, !486, !490, !494, !498, !500, !506, !510, !514, !516, !518, !522, !530, !534, !538, !542, !544, !550, !552, !559, !563, !567, !571, !575, !579, !583, !585, !587, !591, !595, !599, !601, !605, !609, !611, !613, !617, !623, !628, !633, !634, !635, !636, !637, !638, !639, !640, !641, !642, !643, !645, !647, !651, !655, !660, !666, !668, !670, !672, !674, !676, !678, !680, !682, !684, !686, !688, !690, !692, !696, !700, !706, !710, !714, !719, !721, !725, !729, !733, !743, !745, !749, !753, !757, !761, !765, !769, !773, !777, !781, !785, !789, !791, !793, !797, !801, !807, !811, !815, !817, !821, !825, !831, !833, !837, !841, !845, !849, !853, !857, !861, !862, !863, !864, !866, !867, !868, !869, !870, !871, !872, !876, !882, !887, !891, !893, !895, !897, !899, !906, !910, !914, !918, !922, !926, !931, !935, !937, !941, !947, !951, !956, !958, !960, !964, !968, !970, !972, !974, !976, !980, !982, !984, !988, !992, !996, !1000, !1004, !1008, !1010, !1014, !1018, !1022, !1026, !1028, !1030, !1034, !1038, !1039, !1040, !1041, !1042, !1043, !1048, !1051}
!174 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !8, file: !176, line: 48)
!175 = !DINamespace(name: "std", scope: null)
!176 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdint", directory: "/home/user/EDA-202")
!177 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !178, file: !176, line: 49)
!178 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !9, line: 25, baseType: !179)
!179 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int16_t", file: !11, line: 39, baseType: !180)
!180 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!181 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !182, file: !176, line: 50)
!182 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !9, line: 26, baseType: !183)
!183 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int32_t", file: !11, line: 41, baseType: !184)
!184 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!185 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !186, file: !176, line: 51)
!186 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !9, line: 27, baseType: !187)
!187 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !11, line: 44, baseType: !188)
!188 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!189 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !190, file: !176, line: 53)
!190 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast8_t", file: !191, line: 47, baseType: !12)
!191 = !DIFile(filename: "/usr/include/stdint.h", directory: "")
!192 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !193, file: !176, line: 54)
!193 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast16_t", file: !191, line: 49, baseType: !188)
!194 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !195, file: !176, line: 55)
!195 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast32_t", file: !191, line: 50, baseType: !188)
!196 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !197, file: !176, line: 56)
!197 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast64_t", file: !191, line: 51, baseType: !188)
!198 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !199, file: !176, line: 58)
!199 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least8_t", file: !200, line: 25, baseType: !201)
!200 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-least.h", directory: "")
!201 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least8_t", file: !11, line: 52, baseType: !10)
!202 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !203, file: !176, line: 59)
!203 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least16_t", file: !200, line: 26, baseType: !204)
!204 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least16_t", file: !11, line: 54, baseType: !179)
!205 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !206, file: !176, line: 60)
!206 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least32_t", file: !200, line: 27, baseType: !207)
!207 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least32_t", file: !11, line: 56, baseType: !183)
!208 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !209, file: !176, line: 61)
!209 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least64_t", file: !200, line: 28, baseType: !210)
!210 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least64_t", file: !11, line: 58, baseType: !187)
!211 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !212, file: !176, line: 63)
!212 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !191, line: 90, baseType: !213)
!213 = !DIDerivedType(tag: DW_TAG_typedef, name: "__intmax_t", file: !11, line: 72, baseType: !188)
!214 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !215, file: !176, line: 64)
!215 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !191, line: 76, baseType: !188)
!216 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !98, file: !176, line: 66)
!217 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !19, file: !176, line: 67)
!218 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !101, file: !176, line: 68)
!219 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !220, file: !176, line: 69)
!220 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !20, line: 27, baseType: !221)
!221 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !11, line: 45, baseType: !222)
!222 = !DIBasicType(name: "unsigned long", size: 64, encoding: DW_ATE_unsigned)
!223 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !224, file: !176, line: 71)
!224 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast8_t", file: !191, line: 60, baseType: !100)
!225 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !226, file: !176, line: 72)
!226 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast16_t", file: !191, line: 62, baseType: !222)
!227 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !228, file: !176, line: 73)
!228 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast32_t", file: !191, line: 63, baseType: !222)
!229 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !230, file: !176, line: 74)
!230 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast64_t", file: !191, line: 64, baseType: !222)
!231 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !232, file: !176, line: 76)
!232 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least8_t", file: !200, line: 31, baseType: !233)
!233 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least8_t", file: !11, line: 53, baseType: !99)
!234 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !235, file: !176, line: 77)
!235 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least16_t", file: !200, line: 32, baseType: !236)
!236 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least16_t", file: !11, line: 55, baseType: !21)
!237 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !238, file: !176, line: 78)
!238 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least32_t", file: !200, line: 33, baseType: !239)
!239 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least32_t", file: !11, line: 57, baseType: !102)
!240 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !241, file: !176, line: 79)
!241 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least64_t", file: !200, line: 34, baseType: !242)
!242 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least64_t", file: !11, line: 59, baseType: !221)
!243 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !244, file: !176, line: 81)
!244 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintmax_t", file: !191, line: 91, baseType: !245)
!245 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintmax_t", file: !11, line: 73, baseType: !222)
!246 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !247, file: !176, line: 82)
!247 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !191, line: 79, baseType: !222)
!248 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !249, file: !250, line: 57)
!249 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "exception_ptr", scope: !251, file: !250, line: 79, size: 64, flags: DIFlagTypePassByReference, elements: !252, identifier: "_ZTSNSt15__exception_ptr13exception_ptrE")
!250 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/exception_ptr.h", directory: "/home/user/EDA-202")
!251 = !DINamespace(name: "__exception_ptr", scope: !175)
!252 = !{!253, !255, !259, !262, !263, !268, !269, !273, !279, !283, !287, !290, !291, !294, !297}
!253 = !DIDerivedType(tag: DW_TAG_member, name: "_M_exception_object", scope: !249, file: !250, line: 81, baseType: !254, size: 64)
!254 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!255 = !DISubprogram(name: "exception_ptr", scope: !249, file: !250, line: 83, type: !256, scopeLine: 83, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!256 = !DISubroutineType(types: !257)
!257 = !{null, !258, !254}
!258 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !249, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!259 = !DISubprogram(name: "_M_addref", linkageName: "_ZNSt15__exception_ptr13exception_ptr9_M_addrefEv", scope: !249, file: !250, line: 85, type: !260, scopeLine: 85, flags: DIFlagPrototyped, spFlags: 0)
!260 = !DISubroutineType(types: !261)
!261 = !{null, !258}
!262 = !DISubprogram(name: "_M_release", linkageName: "_ZNSt15__exception_ptr13exception_ptr10_M_releaseEv", scope: !249, file: !250, line: 86, type: !260, scopeLine: 86, flags: DIFlagPrototyped, spFlags: 0)
!263 = !DISubprogram(name: "_M_get", linkageName: "_ZNKSt15__exception_ptr13exception_ptr6_M_getEv", scope: !249, file: !250, line: 88, type: !264, scopeLine: 88, flags: DIFlagPrototyped, spFlags: 0)
!264 = !DISubroutineType(types: !265)
!265 = !{!254, !266}
!266 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !267, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!267 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !249)
!268 = !DISubprogram(name: "exception_ptr", scope: !249, file: !250, line: 96, type: !260, scopeLine: 96, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!269 = !DISubprogram(name: "exception_ptr", scope: !249, file: !250, line: 98, type: !270, scopeLine: 98, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!270 = !DISubroutineType(types: !271)
!271 = !{null, !258, !272}
!272 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !267, size: 64)
!273 = !DISubprogram(name: "exception_ptr", scope: !249, file: !250, line: 101, type: !274, scopeLine: 101, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!274 = !DISubroutineType(types: !275)
!275 = !{null, !258, !276}
!276 = !DIDerivedType(tag: DW_TAG_typedef, name: "nullptr_t", scope: !175, file: !277, line: 242, baseType: !278)
!277 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h", directory: "/home/user/EDA-202")
!278 = !DIBasicType(tag: DW_TAG_unspecified_type, name: "decltype(nullptr)")
!279 = !DISubprogram(name: "exception_ptr", scope: !249, file: !250, line: 105, type: !280, scopeLine: 105, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!280 = !DISubroutineType(types: !281)
!281 = !{null, !258, !282}
!282 = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: !249, size: 64)
!283 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSERKS0_", scope: !249, file: !250, line: 118, type: !284, scopeLine: 118, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!284 = !DISubroutineType(types: !285)
!285 = !{!286, !258, !272}
!286 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !249, size: 64)
!287 = !DISubprogram(name: "operator=", linkageName: "_ZNSt15__exception_ptr13exception_ptraSEOS0_", scope: !249, file: !250, line: 122, type: !288, scopeLine: 122, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!288 = !DISubroutineType(types: !289)
!289 = !{!286, !258, !282}
!290 = !DISubprogram(name: "~exception_ptr", scope: !249, file: !250, line: 129, type: !260, scopeLine: 129, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!291 = !DISubprogram(name: "swap", linkageName: "_ZNSt15__exception_ptr13exception_ptr4swapERS0_", scope: !249, file: !250, line: 132, type: !292, scopeLine: 132, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!292 = !DISubroutineType(types: !293)
!293 = !{null, !258, !286}
!294 = !DISubprogram(name: "operator bool", linkageName: "_ZNKSt15__exception_ptr13exception_ptrcvbEv", scope: !249, file: !250, line: 144, type: !295, scopeLine: 144, flags: DIFlagPublic | DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!295 = !DISubroutineType(types: !296)
!296 = !{!104, !266}
!297 = !DISubprogram(name: "__cxa_exception_type", linkageName: "_ZNKSt15__exception_ptr13exception_ptr20__cxa_exception_typeEv", scope: !249, file: !250, line: 153, type: !298, scopeLine: 153, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!298 = !DISubroutineType(types: !299)
!299 = !{!300, !266}
!300 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !301, size: 64)
!301 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !302)
!302 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "type_info", scope: !175, file: !303, line: 88, size: 128, flags: DIFlagTypePassByReference, elements: !304, vtableHolder: !302)
!303 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/typeinfo", directory: "/home/user/EDA-202")
!304 = !{!305, !310, !314, !318, !322, !326, !327, !328, !332, !335, !336, !340, !347, !350, !354}
!305 = !DIDerivedType(tag: DW_TAG_member, name: "_vptr$type_info", scope: !303, file: !303, baseType: !306, size: 64, flags: DIFlagArtificial)
!306 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !307, size: 64)
!307 = !DIDerivedType(tag: DW_TAG_pointer_type, name: "__vtbl_ptr_type", baseType: !308, size: 64)
!308 = !DISubroutineType(types: !309)
!309 = !{!184}
!310 = !DIDerivedType(tag: DW_TAG_member, name: "__name", scope: !302, file: !303, line: 171, baseType: !311, size: 64, offset: 64, flags: DIFlagProtected)
!311 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !312, size: 64)
!312 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !313)
!313 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!314 = !DISubprogram(name: "~type_info", scope: !302, file: !303, line: 95, type: !315, scopeLine: 95, containingType: !302, virtualIndex: 0, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!315 = !DISubroutineType(types: !316)
!316 = !{null, !317}
!317 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !302, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!318 = !DISubprogram(name: "name", linkageName: "_ZNKSt9type_info4nameEv", scope: !302, file: !303, line: 99, type: !319, scopeLine: 99, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!319 = !DISubroutineType(types: !320)
!320 = !{!311, !321}
!321 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !301, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!322 = !DISubprogram(name: "before", linkageName: "_ZNKSt9type_info6beforeERKS_", scope: !302, file: !303, line: 115, type: !323, scopeLine: 115, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!323 = !DISubroutineType(types: !324)
!324 = !{!104, !321, !325}
!325 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !301, size: 64)
!326 = !DISubprogram(name: "operator==", linkageName: "_ZNKSt9type_infoeqERKS_", scope: !302, file: !303, line: 120, type: !323, scopeLine: 120, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!327 = !DISubprogram(name: "operator!=", linkageName: "_ZNKSt9type_infoneERKS_", scope: !302, file: !303, line: 136, type: !323, scopeLine: 136, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!328 = !DISubprogram(name: "hash_code", linkageName: "_ZNKSt9type_info9hash_codeEv", scope: !302, file: !303, line: 140, type: !329, scopeLine: 140, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!329 = !DISubroutineType(types: !330)
!330 = !{!331, !321}
!331 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", scope: !175, file: !277, line: 238, baseType: !222)
!332 = !DISubprogram(name: "__is_pointer_p", linkageName: "_ZNKSt9type_info14__is_pointer_pEv", scope: !302, file: !303, line: 152, type: !333, scopeLine: 152, containingType: !302, virtualIndex: 2, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!333 = !DISubroutineType(types: !334)
!334 = !{!104, !321}
!335 = !DISubprogram(name: "__is_function_p", linkageName: "_ZNKSt9type_info15__is_function_pEv", scope: !302, file: !303, line: 155, type: !333, scopeLine: 155, containingType: !302, virtualIndex: 3, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!336 = !DISubprogram(name: "__do_catch", linkageName: "_ZNKSt9type_info10__do_catchEPKS_PPvj", scope: !302, file: !303, line: 163, type: !337, scopeLine: 163, containingType: !302, virtualIndex: 4, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!337 = !DISubroutineType(types: !338)
!338 = !{!104, !321, !300, !339, !103}
!339 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !254, size: 64)
!340 = !DISubprogram(name: "__do_upcast", linkageName: "_ZNKSt9type_info11__do_upcastEPKN10__cxxabiv117__class_type_infoEPPv", scope: !302, file: !303, line: 167, type: !341, scopeLine: 167, containingType: !302, virtualIndex: 5, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagVirtual)
!341 = !DISubroutineType(types: !342)
!342 = !{!104, !321, !343, !339}
!343 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !344, size: 64)
!344 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !345)
!345 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "__class_type_info", scope: !346, file: !303, line: 45, flags: DIFlagFwdDecl, identifier: "_ZTSN10__cxxabiv117__class_type_infoE")
!346 = !DINamespace(name: "__cxxabiv1", scope: null)
!347 = !DISubprogram(name: "type_info", scope: !302, file: !303, line: 173, type: !348, scopeLine: 173, flags: DIFlagProtected | DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!348 = !DISubroutineType(types: !349)
!349 = !{null, !317, !311}
!350 = !DISubprogram(name: "operator=", linkageName: "_ZNSt9type_infoaSERKS_", scope: !302, file: !303, line: 177, type: !351, scopeLine: 177, flags: DIFlagPrototyped, spFlags: 0)
!351 = !DISubroutineType(types: !352)
!352 = !{!353, !317, !325}
!353 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !302, size: 64)
!354 = !DISubprogram(name: "type_info", scope: !302, file: !303, line: 178, type: !355, scopeLine: 178, flags: DIFlagPrototyped, spFlags: 0)
!355 = !DISubroutineType(types: !356)
!356 = !{null, !317, !325}
!357 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !251, entity: !358, file: !250, line: 73)
!358 = !DISubprogram(name: "rethrow_exception", linkageName: "_ZSt17rethrow_exceptionNSt15__exception_ptr13exception_ptrE", scope: !175, file: !250, line: 69, type: !359, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!359 = !DISubroutineType(types: !360)
!360 = !{null, !249}
!361 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !362, entity: !363, file: !364, line: 58)
!362 = !DINamespace(name: "__gnu_debug", scope: null)
!363 = !DINamespace(name: "__debug", scope: !175)
!364 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/debug/debug.h", directory: "/home/user/EDA-202")
!365 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !366, file: !381, line: 64)
!366 = !DIDerivedType(tag: DW_TAG_typedef, name: "mbstate_t", file: !367, line: 6, baseType: !368)
!367 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/mbstate_t.h", directory: "")
!368 = !DIDerivedType(tag: DW_TAG_typedef, name: "__mbstate_t", file: !369, line: 21, baseType: !370)
!369 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h", directory: "")
!370 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !369, line: 13, size: 64, flags: DIFlagTypePassByValue, elements: !371, identifier: "_ZTS11__mbstate_t")
!371 = !{!372, !373}
!372 = !DIDerivedType(tag: DW_TAG_member, name: "__count", scope: !370, file: !369, line: 15, baseType: !184, size: 32)
!373 = !DIDerivedType(tag: DW_TAG_member, name: "__value", scope: !370, file: !369, line: 20, baseType: !374, size: 32, offset: 32)
!374 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !370, file: !369, line: 16, size: 32, flags: DIFlagTypePassByValue, elements: !375, identifier: "_ZTSN11__mbstate_tUt_E")
!375 = !{!376, !377}
!376 = !DIDerivedType(tag: DW_TAG_member, name: "__wch", scope: !374, file: !369, line: 18, baseType: !103, size: 32)
!377 = !DIDerivedType(tag: DW_TAG_member, name: "__wchb", scope: !374, file: !369, line: 19, baseType: !378, size: 32)
!378 = !DICompositeType(tag: DW_TAG_array_type, baseType: !313, size: 32, elements: !379)
!379 = !{!380}
!380 = !DISubrange(count: 4, lowerBound: 0)
!381 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cwchar", directory: "/home/user/EDA-202")
!382 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !383, file: !381, line: 139)
!383 = !DIDerivedType(tag: DW_TAG_typedef, name: "wint_t", file: !384, line: 20, baseType: !103)
!384 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/wint_t.h", directory: "")
!385 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !386, file: !381, line: 141)
!386 = !DISubprogram(name: "btowc", scope: !387, file: !387, line: 309, type: !388, flags: DIFlagPrototyped, spFlags: 0)
!387 = !DIFile(filename: "/usr/include/wchar.h", directory: "")
!388 = !DISubroutineType(types: !389)
!389 = !{!383, !184}
!390 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !391, file: !381, line: 142)
!391 = !DISubprogram(name: "fgetwc", scope: !387, file: !387, line: 935, type: !392, flags: DIFlagPrototyped, spFlags: 0)
!392 = !DISubroutineType(types: !393)
!393 = !{!383, !394}
!394 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !395, size: 64)
!395 = !DIDerivedType(tag: DW_TAG_typedef, name: "__FILE", file: !396, line: 5, baseType: !397)
!396 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__FILE.h", directory: "")
!397 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !396, line: 4, flags: DIFlagFwdDecl, identifier: "_ZTS8_IO_FILE")
!398 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !399, file: !381, line: 143)
!399 = !DISubprogram(name: "fgetws", scope: !387, file: !387, line: 964, type: !400, flags: DIFlagPrototyped, spFlags: 0)
!400 = !DISubroutineType(types: !401)
!401 = !{!402, !404, !184, !405}
!402 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !403, size: 64)
!403 = !DIBasicType(name: "wchar_t", size: 32, encoding: DW_ATE_signed)
!404 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !402)
!405 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !394)
!406 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !407, file: !381, line: 144)
!407 = !DISubprogram(name: "fputwc", scope: !387, file: !387, line: 949, type: !408, flags: DIFlagPrototyped, spFlags: 0)
!408 = !DISubroutineType(types: !409)
!409 = !{!383, !403, !394}
!410 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !411, file: !381, line: 145)
!411 = !DISubprogram(name: "fputws", scope: !387, file: !387, line: 971, type: !412, flags: DIFlagPrototyped, spFlags: 0)
!412 = !DISubroutineType(types: !413)
!413 = !{!184, !414, !405}
!414 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !415)
!415 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !416, size: 64)
!416 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !403)
!417 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !418, file: !381, line: 146)
!418 = !DISubprogram(name: "fwide", scope: !387, file: !387, line: 725, type: !419, flags: DIFlagPrototyped, spFlags: 0)
!419 = !DISubroutineType(types: !420)
!420 = !{!184, !394, !184}
!421 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !422, file: !381, line: 147)
!422 = !DISubprogram(name: "fwprintf", scope: !387, file: !387, line: 732, type: !423, flags: DIFlagPrototyped, spFlags: 0)
!423 = !DISubroutineType(types: !424)
!424 = !{!184, !405, !414, null}
!425 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !426, file: !381, line: 148)
!426 = !DISubprogram(name: "fwscanf", linkageName: "__isoc23_fwscanf", scope: !387, file: !387, line: 795, type: !423, flags: DIFlagPrototyped, spFlags: 0)
!427 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !428, file: !381, line: 149)
!428 = !DISubprogram(name: "getwc", scope: !387, file: !387, line: 936, type: !392, flags: DIFlagPrototyped, spFlags: 0)
!429 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !430, file: !381, line: 150)
!430 = !DISubprogram(name: "getwchar", scope: !387, file: !387, line: 942, type: !431, flags: DIFlagPrototyped, spFlags: 0)
!431 = !DISubroutineType(types: !432)
!432 = !{!383}
!433 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !434, file: !381, line: 151)
!434 = !DISubprogram(name: "mbrlen", scope: !387, file: !387, line: 332, type: !435, flags: DIFlagPrototyped, spFlags: 0)
!435 = !DISubroutineType(types: !436)
!436 = !{!437, !439, !437, !440}
!437 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !438, line: 46, baseType: !222)
!438 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/stddef.h", directory: "/home/user/EDA-202")
!439 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !311)
!440 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !441)
!441 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !366, size: 64)
!442 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !443, file: !381, line: 152)
!443 = !DISubprogram(name: "mbrtowc", scope: !387, file: !387, line: 321, type: !444, flags: DIFlagPrototyped, spFlags: 0)
!444 = !DISubroutineType(types: !445)
!445 = !{!437, !404, !439, !437, !440}
!446 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !447, file: !381, line: 153)
!447 = !DISubprogram(name: "mbsinit", scope: !387, file: !387, line: 317, type: !448, flags: DIFlagPrototyped, spFlags: 0)
!448 = !DISubroutineType(types: !449)
!449 = !{!184, !450}
!450 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !451, size: 64)
!451 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !366)
!452 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !453, file: !381, line: 154)
!453 = !DISubprogram(name: "mbsrtowcs", scope: !387, file: !387, line: 362, type: !454, flags: DIFlagPrototyped, spFlags: 0)
!454 = !DISubroutineType(types: !455)
!455 = !{!437, !404, !456, !437, !440}
!456 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !457)
!457 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !311, size: 64)
!458 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !459, file: !381, line: 155)
!459 = !DISubprogram(name: "putwc", scope: !387, file: !387, line: 950, type: !408, flags: DIFlagPrototyped, spFlags: 0)
!460 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !461, file: !381, line: 156)
!461 = !DISubprogram(name: "putwchar", scope: !387, file: !387, line: 956, type: !462, flags: DIFlagPrototyped, spFlags: 0)
!462 = !DISubroutineType(types: !463)
!463 = !{!383, !403}
!464 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !465, file: !381, line: 158)
!465 = !DISubprogram(name: "swprintf", scope: !387, file: !387, line: 742, type: !466, flags: DIFlagPrototyped, spFlags: 0)
!466 = !DISubroutineType(types: !467)
!467 = !{!184, !404, !437, !414, null}
!468 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !469, file: !381, line: 160)
!469 = !DISubprogram(name: "swscanf", linkageName: "__isoc23_swscanf", scope: !387, file: !387, line: 802, type: !470, flags: DIFlagPrototyped, spFlags: 0)
!470 = !DISubroutineType(types: !471)
!471 = !{!184, !414, !414, null}
!472 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !473, file: !381, line: 161)
!473 = !DISubprogram(name: "ungetwc", scope: !387, file: !387, line: 979, type: !474, flags: DIFlagPrototyped, spFlags: 0)
!474 = !DISubroutineType(types: !475)
!475 = !{!383, !383, !394}
!476 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !477, file: !381, line: 162)
!477 = !DISubprogram(name: "vfwprintf", scope: !387, file: !387, line: 750, type: !478, flags: DIFlagPrototyped, spFlags: 0)
!478 = !DISubroutineType(types: !479)
!479 = !{!184, !405, !414, !480}
!480 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !481, line: 14, baseType: !482)
!481 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/stdarg.h", directory: "/home/user/EDA-202")
!482 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !483, baseType: !254)
!483 = !DIFile(filename: "csynth/hls/.autopilot/db/full_cache_structure_pilot.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/structure-pilot-vitis")
!484 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !485, file: !381, line: 164)
!485 = !DISubprogram(name: "vfwscanf", linkageName: "__isoc23_vfwscanf", scope: !387, file: !387, line: 875, type: !478, flags: DIFlagPrototyped, spFlags: 0)
!486 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !487, file: !381, line: 167)
!487 = !DISubprogram(name: "vswprintf", scope: !387, file: !387, line: 763, type: !488, flags: DIFlagPrototyped, spFlags: 0)
!488 = !DISubroutineType(types: !489)
!489 = !{!184, !404, !437, !414, !480}
!490 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !491, file: !381, line: 170)
!491 = !DISubprogram(name: "vswscanf", linkageName: "__isoc23_vswscanf", scope: !387, file: !387, line: 882, type: !492, flags: DIFlagPrototyped, spFlags: 0)
!492 = !DISubroutineType(types: !493)
!493 = !{!184, !414, !414, !480}
!494 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !495, file: !381, line: 172)
!495 = !DISubprogram(name: "vwprintf", scope: !387, file: !387, line: 758, type: !496, flags: DIFlagPrototyped, spFlags: 0)
!496 = !DISubroutineType(types: !497)
!497 = !{!184, !414, !480}
!498 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !499, file: !381, line: 174)
!499 = !DISubprogram(name: "vwscanf", linkageName: "__isoc23_vwscanf", scope: !387, file: !387, line: 879, type: !496, flags: DIFlagPrototyped, spFlags: 0)
!500 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !501, file: !381, line: 176)
!501 = !DISubprogram(name: "wcrtomb", scope: !387, file: !387, line: 326, type: !502, flags: DIFlagPrototyped, spFlags: 0)
!502 = !DISubroutineType(types: !503)
!503 = !{!437, !504, !403, !440}
!504 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !505)
!505 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !313, size: 64)
!506 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !507, file: !381, line: 177)
!507 = !DISubprogram(name: "wcscat", scope: !387, file: !387, line: 121, type: !508, flags: DIFlagPrototyped, spFlags: 0)
!508 = !DISubroutineType(types: !509)
!509 = !{!402, !404, !414}
!510 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !511, file: !381, line: 178)
!511 = !DISubprogram(name: "wcscmp", scope: !387, file: !387, line: 130, type: !512, flags: DIFlagPrototyped, spFlags: 0)
!512 = !DISubroutineType(types: !513)
!513 = !{!184, !415, !415}
!514 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !515, file: !381, line: 179)
!515 = !DISubprogram(name: "wcscoll", scope: !387, file: !387, line: 155, type: !512, flags: DIFlagPrototyped, spFlags: 0)
!516 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !517, file: !381, line: 180)
!517 = !DISubprogram(name: "wcscpy", scope: !387, file: !387, line: 98, type: !508, flags: DIFlagPrototyped, spFlags: 0)
!518 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !519, file: !381, line: 181)
!519 = !DISubprogram(name: "wcscspn", scope: !387, file: !387, line: 212, type: !520, flags: DIFlagPrototyped, spFlags: 0)
!520 = !DISubroutineType(types: !521)
!521 = !{!437, !415, !415}
!522 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !523, file: !381, line: 182)
!523 = !DISubprogram(name: "wcsftime", scope: !387, file: !387, line: 1043, type: !524, flags: DIFlagPrototyped, spFlags: 0)
!524 = !DISubroutineType(types: !525)
!525 = !{!437, !404, !437, !414, !526}
!526 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !527)
!527 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !528, size: 64)
!528 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !529)
!529 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tm", file: !387, line: 94, flags: DIFlagFwdDecl, identifier: "_ZTS2tm")
!530 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !531, file: !381, line: 183)
!531 = !DISubprogram(name: "wcslen", scope: !387, file: !387, line: 247, type: !532, flags: DIFlagPrototyped, spFlags: 0)
!532 = !DISubroutineType(types: !533)
!533 = !{!437, !415}
!534 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !535, file: !381, line: 184)
!535 = !DISubprogram(name: "wcsncat", scope: !387, file: !387, line: 125, type: !536, flags: DIFlagPrototyped, spFlags: 0)
!536 = !DISubroutineType(types: !537)
!537 = !{!402, !404, !414, !437}
!538 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !539, file: !381, line: 185)
!539 = !DISubprogram(name: "wcsncmp", scope: !387, file: !387, line: 133, type: !540, flags: DIFlagPrototyped, spFlags: 0)
!540 = !DISubroutineType(types: !541)
!541 = !{!184, !415, !415, !437}
!542 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !543, file: !381, line: 186)
!543 = !DISubprogram(name: "wcsncpy", scope: !387, file: !387, line: 103, type: !536, flags: DIFlagPrototyped, spFlags: 0)
!544 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !545, file: !381, line: 187)
!545 = !DISubprogram(name: "wcsrtombs", scope: !387, file: !387, line: 368, type: !546, flags: DIFlagPrototyped, spFlags: 0)
!546 = !DISubroutineType(types: !547)
!547 = !{!437, !504, !548, !437, !440}
!548 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !549)
!549 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !415, size: 64)
!550 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !551, file: !381, line: 188)
!551 = !DISubprogram(name: "wcsspn", scope: !387, file: !387, line: 216, type: !520, flags: DIFlagPrototyped, spFlags: 0)
!552 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !553, file: !381, line: 189)
!553 = !DISubprogram(name: "wcstod", scope: !387, file: !387, line: 402, type: !554, flags: DIFlagPrototyped, spFlags: 0)
!554 = !DISubroutineType(types: !555)
!555 = !{!556, !414, !557}
!556 = !DIBasicType(name: "double", size: 64, encoding: DW_ATE_float)
!557 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !558)
!558 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !402, size: 64)
!559 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !560, file: !381, line: 191)
!560 = !DISubprogram(name: "wcstof", scope: !387, file: !387, line: 407, type: !561, flags: DIFlagPrototyped, spFlags: 0)
!561 = !DISubroutineType(types: !562)
!562 = !{!29, !414, !557}
!563 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !564, file: !381, line: 193)
!564 = !DISubprogram(name: "wcstok", scope: !387, file: !387, line: 242, type: !565, flags: DIFlagPrototyped, spFlags: 0)
!565 = !DISubroutineType(types: !566)
!566 = !{!402, !404, !414, !557}
!567 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !568, file: !381, line: 194)
!568 = !DISubprogram(name: "wcstol", linkageName: "__isoc23_wcstol", scope: !387, file: !387, line: 500, type: !569, flags: DIFlagPrototyped, spFlags: 0)
!569 = !DISubroutineType(types: !570)
!570 = !{!188, !414, !557, !184}
!571 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !572, file: !381, line: 195)
!572 = !DISubprogram(name: "wcstoul", linkageName: "__isoc23_wcstoul", scope: !387, file: !387, line: 503, type: !573, flags: DIFlagPrototyped, spFlags: 0)
!573 = !DISubroutineType(types: !574)
!574 = !{!222, !414, !557, !184}
!575 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !576, file: !381, line: 196)
!576 = !DISubprogram(name: "wcsxfrm", scope: !387, file: !387, line: 159, type: !577, flags: DIFlagPrototyped, spFlags: 0)
!577 = !DISubroutineType(types: !578)
!578 = !{!437, !404, !414, !437}
!579 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !580, file: !381, line: 197)
!580 = !DISubprogram(name: "wctob", scope: !387, file: !387, line: 313, type: !581, flags: DIFlagPrototyped, spFlags: 0)
!581 = !DISubroutineType(types: !582)
!582 = !{!184, !383}
!583 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !584, file: !381, line: 198)
!584 = !DISubprogram(name: "wmemcmp", scope: !387, file: !387, line: 283, type: !540, flags: DIFlagPrototyped, spFlags: 0)
!585 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !586, file: !381, line: 199)
!586 = !DISubprogram(name: "wmemcpy", scope: !387, file: !387, line: 287, type: !536, flags: DIFlagPrototyped, spFlags: 0)
!587 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !588, file: !381, line: 200)
!588 = !DISubprogram(name: "wmemmove", scope: !387, file: !387, line: 292, type: !589, flags: DIFlagPrototyped, spFlags: 0)
!589 = !DISubroutineType(types: !590)
!590 = !{!402, !402, !415, !437}
!591 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !592, file: !381, line: 201)
!592 = !DISubprogram(name: "wmemset", scope: !387, file: !387, line: 296, type: !593, flags: DIFlagPrototyped, spFlags: 0)
!593 = !DISubroutineType(types: !594)
!594 = !{!402, !402, !403, !437}
!595 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !596, file: !381, line: 202)
!596 = !DISubprogram(name: "wprintf", scope: !387, file: !387, line: 739, type: !597, flags: DIFlagPrototyped, spFlags: 0)
!597 = !DISubroutineType(types: !598)
!598 = !{!184, !414, null}
!599 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !600, file: !381, line: 203)
!600 = !DISubprogram(name: "wscanf", linkageName: "__isoc23_wscanf", scope: !387, file: !387, line: 799, type: !597, flags: DIFlagPrototyped, spFlags: 0)
!601 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !602, file: !381, line: 204)
!602 = !DISubprogram(name: "wcschr", scope: !387, file: !387, line: 189, type: !603, flags: DIFlagPrototyped, spFlags: 0)
!603 = !DISubroutineType(types: !604)
!604 = !{!402, !415, !403}
!605 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !606, file: !381, line: 205)
!606 = !DISubprogram(name: "wcspbrk", scope: !387, file: !387, line: 226, type: !607, flags: DIFlagPrototyped, spFlags: 0)
!607 = !DISubroutineType(types: !608)
!608 = !{!402, !415, !415}
!609 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !610, file: !381, line: 206)
!610 = !DISubprogram(name: "wcsrchr", scope: !387, file: !387, line: 199, type: !603, flags: DIFlagPrototyped, spFlags: 0)
!611 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !612, file: !381, line: 207)
!612 = !DISubprogram(name: "wcsstr", scope: !387, file: !387, line: 237, type: !607, flags: DIFlagPrototyped, spFlags: 0)
!613 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !614, file: !381, line: 208)
!614 = !DISubprogram(name: "wmemchr", scope: !387, file: !387, line: 278, type: !615, flags: DIFlagPrototyped, spFlags: 0)
!615 = !DISubroutineType(types: !616)
!616 = !{!402, !415, !403, !437}
!617 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !619, file: !381, line: 248)
!618 = !DINamespace(name: "__gnu_cxx", scope: null)
!619 = !DISubprogram(name: "wcstold", scope: !387, file: !387, line: 409, type: !620, flags: DIFlagPrototyped, spFlags: 0)
!620 = !DISubroutineType(types: !621)
!621 = !{!622, !414, !557}
!622 = !DIBasicType(name: "long double", size: 64, encoding: DW_ATE_float)
!623 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !624, file: !381, line: 257)
!624 = !DISubprogram(name: "wcstoll", linkageName: "__isoc23_wcstoll", scope: !387, file: !387, line: 508, type: !625, flags: DIFlagPrototyped, spFlags: 0)
!625 = !DISubroutineType(types: !626)
!626 = !{!627, !414, !557, !184}
!627 = !DIBasicType(name: "long long", size: 64, encoding: DW_ATE_signed)
!628 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !629, file: !381, line: 258)
!629 = !DISubprogram(name: "wcstoull", linkageName: "__isoc23_wcstoull", scope: !387, file: !387, line: 513, type: !630, flags: DIFlagPrototyped, spFlags: 0)
!630 = !DISubroutineType(types: !631)
!631 = !{!632, !414, !557, !184}
!632 = !DIBasicType(name: "unsigned long long", size: 64, encoding: DW_ATE_unsigned)
!633 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !619, file: !381, line: 264)
!634 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !624, file: !381, line: 265)
!635 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !629, file: !381, line: 266)
!636 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !560, file: !381, line: 280)
!637 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !485, file: !381, line: 283)
!638 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !491, file: !381, line: 286)
!639 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !499, file: !381, line: 289)
!640 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !619, file: !381, line: 293)
!641 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !624, file: !381, line: 294)
!642 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !629, file: !381, line: 295)
!643 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !331, file: !644, line: 44)
!644 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/ext/new_allocator.h", directory: "/home/user/EDA-202")
!645 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !646, file: !644, line: 45)
!646 = !DIDerivedType(tag: DW_TAG_typedef, name: "ptrdiff_t", scope: !175, file: !277, line: 239, baseType: !188)
!647 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !648, file: !650, line: 53)
!648 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "lconv", file: !649, line: 51, size: 768, flags: DIFlagFwdDecl, identifier: "_ZTS5lconv")
!649 = !DIFile(filename: "/usr/include/locale.h", directory: "")
!650 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/clocale", directory: "/home/user/EDA-202")
!651 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !652, file: !650, line: 54)
!652 = !DISubprogram(name: "setlocale", scope: !649, file: !649, line: 122, type: !653, flags: DIFlagPrototyped, spFlags: 0)
!653 = !DISubroutineType(types: !654)
!654 = !{!505, !184, !311}
!655 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !656, file: !650, line: 55)
!656 = !DISubprogram(name: "localeconv", scope: !649, file: !649, line: 125, type: !657, flags: DIFlagPrototyped, spFlags: 0)
!657 = !DISubroutineType(types: !658)
!658 = !{!659}
!659 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !648, size: 64)
!660 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !661, file: !665, line: 64)
!661 = !DISubprogram(name: "isalnum", scope: !662, file: !662, line: 108, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!662 = !DIFile(filename: "/usr/include/ctype.h", directory: "")
!663 = !DISubroutineType(types: !664)
!664 = !{!184, !184}
!665 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cctype", directory: "/home/user/EDA-202")
!666 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !667, file: !665, line: 65)
!667 = !DISubprogram(name: "isalpha", scope: !662, file: !662, line: 109, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!668 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !669, file: !665, line: 66)
!669 = !DISubprogram(name: "iscntrl", scope: !662, file: !662, line: 110, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!670 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !671, file: !665, line: 67)
!671 = !DISubprogram(name: "isdigit", scope: !662, file: !662, line: 111, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!672 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !673, file: !665, line: 68)
!673 = !DISubprogram(name: "isgraph", scope: !662, file: !662, line: 113, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!674 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !675, file: !665, line: 69)
!675 = !DISubprogram(name: "islower", scope: !662, file: !662, line: 112, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!676 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !677, file: !665, line: 70)
!677 = !DISubprogram(name: "isprint", scope: !662, file: !662, line: 114, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!678 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !679, file: !665, line: 71)
!679 = !DISubprogram(name: "ispunct", scope: !662, file: !662, line: 115, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!680 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !681, file: !665, line: 72)
!681 = !DISubprogram(name: "isspace", scope: !662, file: !662, line: 116, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!682 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !683, file: !665, line: 73)
!683 = !DISubprogram(name: "isupper", scope: !662, file: !662, line: 117, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!684 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !685, file: !665, line: 74)
!685 = !DISubprogram(name: "isxdigit", scope: !662, file: !662, line: 118, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!686 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !687, file: !665, line: 75)
!687 = !DISubprogram(name: "tolower", scope: !662, file: !662, line: 122, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!688 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !689, file: !665, line: 76)
!689 = !DISubprogram(name: "toupper", scope: !662, file: !662, line: 125, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!690 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !691, file: !665, line: 87)
!691 = !DISubprogram(name: "isblank", scope: !662, file: !662, line: 130, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!692 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !693, file: !695, line: 52)
!693 = !DISubprogram(name: "abs", scope: !694, file: !694, line: 980, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!694 = !DIFile(filename: "/usr/include/stdlib.h", directory: "")
!695 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/std_abs.h", directory: "/home/user/EDA-202")
!696 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !697, file: !699, line: 127)
!697 = !DIDerivedType(tag: DW_TAG_typedef, name: "div_t", file: !694, line: 63, baseType: !698)
!698 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !694, line: 59, size: 64, flags: DIFlagFwdDecl, identifier: "_ZTS5div_t")
!699 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdlib", directory: "/home/user/EDA-202")
!700 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !701, file: !699, line: 128)
!701 = !DIDerivedType(tag: DW_TAG_typedef, name: "ldiv_t", file: !694, line: 71, baseType: !702)
!702 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !694, line: 67, size: 128, flags: DIFlagTypePassByValue, elements: !703, identifier: "_ZTS6ldiv_t")
!703 = !{!704, !705}
!704 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !702, file: !694, line: 69, baseType: !188, size: 64)
!705 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !702, file: !694, line: 70, baseType: !188, size: 64, offset: 64)
!706 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !707, file: !699, line: 130)
!707 = !DISubprogram(name: "abort", scope: !694, file: !694, line: 730, type: !708, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!708 = !DISubroutineType(types: !709)
!709 = !{null}
!710 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !711, file: !699, line: 132)
!711 = !DISubprogram(name: "aligned_alloc", scope: !694, file: !694, line: 724, type: !712, flags: DIFlagPrototyped, spFlags: 0)
!712 = !DISubroutineType(types: !713)
!713 = !{!254, !437, !437}
!714 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !715, file: !699, line: 134)
!715 = !DISubprogram(name: "atexit", scope: !694, file: !694, line: 734, type: !716, flags: DIFlagPrototyped, spFlags: 0)
!716 = !DISubroutineType(types: !717)
!717 = !{!184, !718}
!718 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !708, size: 64)
!719 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !720, file: !699, line: 137)
!720 = !DISubprogram(name: "at_quick_exit", scope: !694, file: !694, line: 739, type: !716, flags: DIFlagPrototyped, spFlags: 0)
!721 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !722, file: !699, line: 140)
!722 = !DISubprogram(name: "atof", scope: !694, file: !694, line: 102, type: !723, flags: DIFlagPrototyped, spFlags: 0)
!723 = !DISubroutineType(types: !724)
!724 = !{!556, !311}
!725 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !726, file: !699, line: 141)
!726 = !DISubprogram(name: "atoi", scope: !694, file: !694, line: 105, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!727 = !DISubroutineType(types: !728)
!728 = !{!184, !311}
!729 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !730, file: !699, line: 142)
!730 = !DISubprogram(name: "atol", scope: !694, file: !694, line: 108, type: !731, flags: DIFlagPrototyped, spFlags: 0)
!731 = !DISubroutineType(types: !732)
!732 = !{!188, !311}
!733 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !734, file: !699, line: 143)
!734 = !DISubprogram(name: "bsearch", scope: !694, file: !694, line: 960, type: !735, flags: DIFlagPrototyped, spFlags: 0)
!735 = !DISubroutineType(types: !736)
!736 = !{!254, !737, !737, !437, !437, !739}
!737 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !738, size: 64)
!738 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!739 = !DIDerivedType(tag: DW_TAG_typedef, name: "__compar_fn_t", file: !694, line: 948, baseType: !740)
!740 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !741, size: 64)
!741 = !DISubroutineType(types: !742)
!742 = !{!184, !737, !737}
!743 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !744, file: !699, line: 144)
!744 = !DISubprogram(name: "calloc", scope: !694, file: !694, line: 675, type: !712, flags: DIFlagPrototyped, spFlags: 0)
!745 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !746, file: !699, line: 145)
!746 = !DISubprogram(name: "div", scope: !694, file: !694, line: 992, type: !747, flags: DIFlagPrototyped, spFlags: 0)
!747 = !DISubroutineType(types: !748)
!748 = !{!697, !184, !184}
!749 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !750, file: !699, line: 146)
!750 = !DISubprogram(name: "exit", scope: !694, file: !694, line: 756, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!751 = !DISubroutineType(types: !752)
!752 = !{null, !184}
!753 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !754, file: !699, line: 147)
!754 = !DISubprogram(name: "free", scope: !694, file: !694, line: 687, type: !755, flags: DIFlagPrototyped, spFlags: 0)
!755 = !DISubroutineType(types: !756)
!756 = !{null, !254}
!757 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !758, file: !699, line: 148)
!758 = !DISubprogram(name: "getenv", scope: !694, file: !694, line: 773, type: !759, flags: DIFlagPrototyped, spFlags: 0)
!759 = !DISubroutineType(types: !760)
!760 = !{!505, !311}
!761 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !762, file: !699, line: 149)
!762 = !DISubprogram(name: "labs", scope: !694, file: !694, line: 981, type: !763, flags: DIFlagPrototyped, spFlags: 0)
!763 = !DISubroutineType(types: !764)
!764 = !{!188, !188}
!765 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !766, file: !699, line: 150)
!766 = !DISubprogram(name: "ldiv", scope: !694, file: !694, line: 994, type: !767, flags: DIFlagPrototyped, spFlags: 0)
!767 = !DISubroutineType(types: !768)
!768 = !{!701, !188, !188}
!769 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !770, file: !699, line: 151)
!770 = !DISubprogram(name: "malloc", scope: !694, file: !694, line: 672, type: !771, flags: DIFlagPrototyped, spFlags: 0)
!771 = !DISubroutineType(types: !772)
!772 = !{!254, !437}
!773 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !774, file: !699, line: 153)
!774 = !DISubprogram(name: "mblen", scope: !694, file: !694, line: 1062, type: !775, flags: DIFlagPrototyped, spFlags: 0)
!775 = !DISubroutineType(types: !776)
!776 = !{!184, !311, !437}
!777 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !778, file: !699, line: 154)
!778 = !DISubprogram(name: "mbstowcs", scope: !694, file: !694, line: 1073, type: !779, flags: DIFlagPrototyped, spFlags: 0)
!779 = !DISubroutineType(types: !780)
!780 = !{!437, !404, !439, !437}
!781 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !782, file: !699, line: 155)
!782 = !DISubprogram(name: "mbtowc", scope: !694, file: !694, line: 1065, type: !783, flags: DIFlagPrototyped, spFlags: 0)
!783 = !DISubroutineType(types: !784)
!784 = !{!184, !404, !439, !437}
!785 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !786, file: !699, line: 157)
!786 = !DISubprogram(name: "qsort", scope: !694, file: !694, line: 970, type: !787, flags: DIFlagPrototyped, spFlags: 0)
!787 = !DISubroutineType(types: !788)
!788 = !{null, !254, !437, !437, !739}
!789 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !790, file: !699, line: 160)
!790 = !DISubprogram(name: "quick_exit", scope: !694, file: !694, line: 762, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!791 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !792, file: !699, line: 163)
!792 = !DISubprogram(name: "rand", scope: !694, file: !694, line: 573, type: !308, flags: DIFlagPrototyped, spFlags: 0)
!793 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !794, file: !699, line: 164)
!794 = !DISubprogram(name: "realloc", scope: !694, file: !694, line: 683, type: !795, flags: DIFlagPrototyped, spFlags: 0)
!795 = !DISubroutineType(types: !796)
!796 = !{!254, !254, !437}
!797 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !798, file: !699, line: 165)
!798 = !DISubprogram(name: "srand", scope: !694, file: !694, line: 575, type: !799, flags: DIFlagPrototyped, spFlags: 0)
!799 = !DISubroutineType(types: !800)
!800 = !{null, !103}
!801 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !802, file: !699, line: 166)
!802 = !DISubprogram(name: "strtod", scope: !694, file: !694, line: 118, type: !803, flags: DIFlagPrototyped, spFlags: 0)
!803 = !DISubroutineType(types: !804)
!804 = !{!556, !439, !805}
!805 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !806)
!806 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !505, size: 64)
!807 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !808, file: !699, line: 167)
!808 = !DISubprogram(name: "strtol", linkageName: "__isoc23_strtol", scope: !694, file: !694, line: 215, type: !809, flags: DIFlagPrototyped, spFlags: 0)
!809 = !DISubroutineType(types: !810)
!810 = !{!188, !439, !805, !184}
!811 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !812, file: !699, line: 168)
!812 = !DISubprogram(name: "strtoul", linkageName: "__isoc23_strtoul", scope: !694, file: !694, line: 219, type: !813, flags: DIFlagPrototyped, spFlags: 0)
!813 = !DISubroutineType(types: !814)
!814 = !{!222, !439, !805, !184}
!815 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !816, file: !699, line: 169)
!816 = !DISubprogram(name: "system", scope: !694, file: !694, line: 923, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!817 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !818, file: !699, line: 171)
!818 = !DISubprogram(name: "wcstombs", scope: !694, file: !694, line: 1077, type: !819, flags: DIFlagPrototyped, spFlags: 0)
!819 = !DISubroutineType(types: !820)
!820 = !{!437, !504, !414, !437}
!821 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !822, file: !699, line: 172)
!822 = !DISubprogram(name: "wctomb", scope: !694, file: !694, line: 1069, type: !823, flags: DIFlagPrototyped, spFlags: 0)
!823 = !DISubroutineType(types: !824)
!824 = !{!184, !505, !403}
!825 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !826, file: !699, line: 200)
!826 = !DIDerivedType(tag: DW_TAG_typedef, name: "lldiv_t", file: !694, line: 81, baseType: !827)
!827 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !694, line: 77, size: 128, flags: DIFlagTypePassByValue, elements: !828, identifier: "_ZTS7lldiv_t")
!828 = !{!829, !830}
!829 = !DIDerivedType(tag: DW_TAG_member, name: "quot", scope: !827, file: !694, line: 79, baseType: !627, size: 64)
!830 = !DIDerivedType(tag: DW_TAG_member, name: "rem", scope: !827, file: !694, line: 80, baseType: !627, size: 64, offset: 64)
!831 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !832, file: !699, line: 206)
!832 = !DISubprogram(name: "_Exit", scope: !694, file: !694, line: 768, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!833 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !834, file: !699, line: 210)
!834 = !DISubprogram(name: "llabs", scope: !694, file: !694, line: 984, type: !835, flags: DIFlagPrototyped, spFlags: 0)
!835 = !DISubroutineType(types: !836)
!836 = !{!627, !627}
!837 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !838, file: !699, line: 216)
!838 = !DISubprogram(name: "lldiv", scope: !694, file: !694, line: 998, type: !839, flags: DIFlagPrototyped, spFlags: 0)
!839 = !DISubroutineType(types: !840)
!840 = !{!826, !627, !627}
!841 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !842, file: !699, line: 227)
!842 = !DISubprogram(name: "atoll", scope: !694, file: !694, line: 113, type: !843, flags: DIFlagPrototyped, spFlags: 0)
!843 = !DISubroutineType(types: !844)
!844 = !{!627, !311}
!845 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !846, file: !699, line: 228)
!846 = !DISubprogram(name: "strtoll", linkageName: "__isoc23_strtoll", scope: !694, file: !694, line: 238, type: !847, flags: DIFlagPrototyped, spFlags: 0)
!847 = !DISubroutineType(types: !848)
!848 = !{!627, !439, !805, !184}
!849 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !850, file: !699, line: 229)
!850 = !DISubprogram(name: "strtoull", linkageName: "__isoc23_strtoull", scope: !694, file: !694, line: 243, type: !851, flags: DIFlagPrototyped, spFlags: 0)
!851 = !DISubroutineType(types: !852)
!852 = !{!632, !439, !805, !184}
!853 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !854, file: !699, line: 231)
!854 = !DISubprogram(name: "strtof", scope: !694, file: !694, line: 124, type: !855, flags: DIFlagPrototyped, spFlags: 0)
!855 = !DISubroutineType(types: !856)
!856 = !{!29, !439, !805}
!857 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !858, file: !699, line: 232)
!858 = !DISubprogram(name: "strtold", scope: !694, file: !694, line: 127, type: !859, flags: DIFlagPrototyped, spFlags: 0)
!859 = !DISubroutineType(types: !860)
!860 = !{!622, !439, !805}
!861 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !826, file: !699, line: 240)
!862 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !832, file: !699, line: 242)
!863 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !834, file: !699, line: 244)
!864 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !865, file: !699, line: 245)
!865 = !DISubprogram(name: "div", linkageName: "_ZN9__gnu_cxx3divExx", scope: !618, file: !699, line: 213, type: !839, flags: DIFlagPrototyped, spFlags: 0)
!866 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !838, file: !699, line: 246)
!867 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !842, file: !699, line: 248)
!868 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !854, file: !699, line: 249)
!869 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !846, file: !699, line: 250)
!870 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !850, file: !699, line: 251)
!871 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !858, file: !699, line: 252)
!872 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !873, file: !875, line: 98)
!873 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !874, line: 7, baseType: !397)
!874 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/FILE.h", directory: "")
!875 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdio", directory: "/home/user/EDA-202")
!876 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !877, file: !875, line: 99)
!877 = !DIDerivedType(tag: DW_TAG_typedef, name: "fpos_t", file: !878, line: 85, baseType: !879)
!878 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!879 = !DIDerivedType(tag: DW_TAG_typedef, name: "__fpos_t", file: !880, line: 14, baseType: !881)
!880 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h", directory: "")
!881 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_G_fpos_t", file: !880, line: 10, size: 128, flags: DIFlagFwdDecl, identifier: "_ZTS9_G_fpos_t")
!882 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !883, file: !875, line: 101)
!883 = !DISubprogram(name: "clearerr", scope: !878, file: !878, line: 860, type: !884, flags: DIFlagPrototyped, spFlags: 0)
!884 = !DISubroutineType(types: !885)
!885 = !{null, !886}
!886 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !873, size: 64)
!887 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !888, file: !875, line: 102)
!888 = !DISubprogram(name: "fclose", scope: !878, file: !878, line: 184, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!889 = !DISubroutineType(types: !890)
!890 = !{!184, !886}
!891 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !892, file: !875, line: 103)
!892 = !DISubprogram(name: "feof", scope: !878, file: !878, line: 862, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!893 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !894, file: !875, line: 104)
!894 = !DISubprogram(name: "ferror", scope: !878, file: !878, line: 864, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!895 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !896, file: !875, line: 105)
!896 = !DISubprogram(name: "fflush", scope: !878, file: !878, line: 236, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!897 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !898, file: !875, line: 106)
!898 = !DISubprogram(name: "fgetc", scope: !878, file: !878, line: 575, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!899 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !900, file: !875, line: 107)
!900 = !DISubprogram(name: "fgetpos", scope: !878, file: !878, line: 829, type: !901, flags: DIFlagPrototyped, spFlags: 0)
!901 = !DISubroutineType(types: !902)
!902 = !{!184, !903, !904}
!903 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !886)
!904 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !905)
!905 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !877, size: 64)
!906 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !907, file: !875, line: 108)
!907 = !DISubprogram(name: "fgets", scope: !878, file: !878, line: 654, type: !908, flags: DIFlagPrototyped, spFlags: 0)
!908 = !DISubroutineType(types: !909)
!909 = !{!505, !504, !184, !903}
!910 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !911, file: !875, line: 109)
!911 = !DISubprogram(name: "fopen", scope: !878, file: !878, line: 264, type: !912, flags: DIFlagPrototyped, spFlags: 0)
!912 = !DISubroutineType(types: !913)
!913 = !{!886, !439, !439}
!914 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !915, file: !875, line: 110)
!915 = !DISubprogram(name: "fprintf", scope: !878, file: !878, line: 357, type: !916, flags: DIFlagPrototyped, spFlags: 0)
!916 = !DISubroutineType(types: !917)
!917 = !{!184, !903, !439, null}
!918 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !919, file: !875, line: 111)
!919 = !DISubprogram(name: "fputc", scope: !878, file: !878, line: 611, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!920 = !DISubroutineType(types: !921)
!921 = !{!184, !184, !886}
!922 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !923, file: !875, line: 112)
!923 = !DISubprogram(name: "fputs", scope: !878, file: !878, line: 717, type: !924, flags: DIFlagPrototyped, spFlags: 0)
!924 = !DISubroutineType(types: !925)
!925 = !{!184, !439, !903}
!926 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !927, file: !875, line: 113)
!927 = !DISubprogram(name: "fread", scope: !878, file: !878, line: 738, type: !928, flags: DIFlagPrototyped, spFlags: 0)
!928 = !DISubroutineType(types: !929)
!929 = !{!437, !930, !437, !437, !903}
!930 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !254)
!931 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !932, file: !875, line: 114)
!932 = !DISubprogram(name: "freopen", scope: !878, file: !878, line: 271, type: !933, flags: DIFlagPrototyped, spFlags: 0)
!933 = !DISubroutineType(types: !934)
!934 = !{!886, !439, !439, !903}
!935 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !936, file: !875, line: 115)
!936 = !DISubprogram(name: "fscanf", linkageName: "__isoc23_fscanf", scope: !878, file: !878, line: 442, type: !916, flags: DIFlagPrototyped, spFlags: 0)
!937 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !938, file: !875, line: 116)
!938 = !DISubprogram(name: "fseek", scope: !878, file: !878, line: 779, type: !939, flags: DIFlagPrototyped, spFlags: 0)
!939 = !DISubroutineType(types: !940)
!940 = !{!184, !886, !188, !184}
!941 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !942, file: !875, line: 117)
!942 = !DISubprogram(name: "fsetpos", scope: !878, file: !878, line: 835, type: !943, flags: DIFlagPrototyped, spFlags: 0)
!943 = !DISubroutineType(types: !944)
!944 = !{!184, !886, !945}
!945 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !946, size: 64)
!946 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !877)
!947 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !948, file: !875, line: 118)
!948 = !DISubprogram(name: "ftell", scope: !878, file: !878, line: 785, type: !949, flags: DIFlagPrototyped, spFlags: 0)
!949 = !DISubroutineType(types: !950)
!950 = !{!188, !886}
!951 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !952, file: !875, line: 119)
!952 = !DISubprogram(name: "fwrite", scope: !878, file: !878, line: 745, type: !953, flags: DIFlagPrototyped, spFlags: 0)
!953 = !DISubroutineType(types: !954)
!954 = !{!437, !955, !437, !437, !903}
!955 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !737)
!956 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !957, file: !875, line: 120)
!957 = !DISubprogram(name: "getc", scope: !878, file: !878, line: 576, type: !889, flags: DIFlagPrototyped, spFlags: 0)
!958 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !959, file: !875, line: 121)
!959 = !DISubprogram(name: "getchar", scope: !878, file: !878, line: 582, type: !308, flags: DIFlagPrototyped, spFlags: 0)
!960 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !961, file: !875, line: 126)
!961 = !DISubprogram(name: "perror", scope: !878, file: !878, line: 878, type: !962, flags: DIFlagPrototyped, spFlags: 0)
!962 = !DISubroutineType(types: !963)
!963 = !{null, !311}
!964 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !965, file: !875, line: 127)
!965 = !DISubprogram(name: "printf", scope: !878, file: !878, line: 363, type: !966, flags: DIFlagPrototyped, spFlags: 0)
!966 = !DISubroutineType(types: !967)
!967 = !{!184, !439, null}
!968 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !969, file: !875, line: 128)
!969 = !DISubprogram(name: "putc", scope: !878, file: !878, line: 612, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!970 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !971, file: !875, line: 129)
!971 = !DISubprogram(name: "putchar", scope: !878, file: !878, line: 618, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!972 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !973, file: !875, line: 130)
!973 = !DISubprogram(name: "puts", scope: !878, file: !878, line: 724, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!974 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !975, file: !875, line: 131)
!975 = !DISubprogram(name: "remove", scope: !878, file: !878, line: 158, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!976 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !977, file: !875, line: 132)
!977 = !DISubprogram(name: "rename", scope: !878, file: !878, line: 160, type: !978, flags: DIFlagPrototyped, spFlags: 0)
!978 = !DISubroutineType(types: !979)
!979 = !{!184, !311, !311}
!980 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !981, file: !875, line: 133)
!981 = !DISubprogram(name: "rewind", scope: !878, file: !878, line: 790, type: !884, flags: DIFlagPrototyped, spFlags: 0)
!982 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !983, file: !875, line: 134)
!983 = !DISubprogram(name: "scanf", linkageName: "__isoc23_scanf", scope: !878, file: !878, line: 445, type: !966, flags: DIFlagPrototyped, spFlags: 0)
!984 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !985, file: !875, line: 135)
!985 = !DISubprogram(name: "setbuf", scope: !878, file: !878, line: 334, type: !986, flags: DIFlagPrototyped, spFlags: 0)
!986 = !DISubroutineType(types: !987)
!987 = !{null, !903, !504}
!988 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !989, file: !875, line: 136)
!989 = !DISubprogram(name: "setvbuf", scope: !878, file: !878, line: 339, type: !990, flags: DIFlagPrototyped, spFlags: 0)
!990 = !DISubroutineType(types: !991)
!991 = !{!184, !903, !504, !184, !437}
!992 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !993, file: !875, line: 137)
!993 = !DISubprogram(name: "sprintf", scope: !878, file: !878, line: 365, type: !994, flags: DIFlagPrototyped, spFlags: 0)
!994 = !DISubroutineType(types: !995)
!995 = !{!184, !504, !439, null}
!996 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !997, file: !875, line: 138)
!997 = !DISubprogram(name: "sscanf", linkageName: "__isoc23_sscanf", scope: !878, file: !878, line: 447, type: !998, flags: DIFlagPrototyped, spFlags: 0)
!998 = !DISubroutineType(types: !999)
!999 = !{!184, !439, !439, null}
!1000 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1001, file: !875, line: 139)
!1001 = !DISubprogram(name: "tmpfile", scope: !878, file: !878, line: 194, type: !1002, flags: DIFlagPrototyped, spFlags: 0)
!1002 = !DISubroutineType(types: !1003)
!1003 = !{!886}
!1004 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1005, file: !875, line: 141)
!1005 = !DISubprogram(name: "tmpnam", scope: !878, file: !878, line: 211, type: !1006, flags: DIFlagPrototyped, spFlags: 0)
!1006 = !DISubroutineType(types: !1007)
!1007 = !{!505, !505}
!1008 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1009, file: !875, line: 143)
!1009 = !DISubprogram(name: "ungetc", scope: !878, file: !878, line: 731, type: !920, flags: DIFlagPrototyped, spFlags: 0)
!1010 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1011, file: !875, line: 144)
!1011 = !DISubprogram(name: "vfprintf", scope: !878, file: !878, line: 372, type: !1012, flags: DIFlagPrototyped, spFlags: 0)
!1012 = !DISubroutineType(types: !1013)
!1013 = !{!184, !903, !439, !480}
!1014 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1015, file: !875, line: 145)
!1015 = !DISubprogram(name: "vprintf", scope: !878, file: !878, line: 378, type: !1016, flags: DIFlagPrototyped, spFlags: 0)
!1016 = !DISubroutineType(types: !1017)
!1017 = !{!184, !439, !480}
!1018 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1019, file: !875, line: 146)
!1019 = !DISubprogram(name: "vsprintf", scope: !878, file: !878, line: 380, type: !1020, flags: DIFlagPrototyped, spFlags: 0)
!1020 = !DISubroutineType(types: !1021)
!1021 = !{!184, !504, !439, !480}
!1022 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !1023, file: !875, line: 175)
!1023 = !DISubprogram(name: "snprintf", scope: !878, file: !878, line: 385, type: !1024, flags: DIFlagPrototyped, spFlags: 0)
!1024 = !DISubroutineType(types: !1025)
!1025 = !{!184, !504, !437, !439, null}
!1026 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !1027, file: !875, line: 176)
!1027 = !DISubprogram(name: "vfscanf", linkageName: "__isoc23_vfscanf", scope: !878, file: !878, line: 511, type: !1012, flags: DIFlagPrototyped, spFlags: 0)
!1028 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !1029, file: !875, line: 177)
!1029 = !DISubprogram(name: "vscanf", linkageName: "__isoc23_vscanf", scope: !878, file: !878, line: 516, type: !1016, flags: DIFlagPrototyped, spFlags: 0)
!1030 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !1031, file: !875, line: 178)
!1031 = !DISubprogram(name: "vsnprintf", scope: !878, file: !878, line: 389, type: !1032, flags: DIFlagPrototyped, spFlags: 0)
!1032 = !DISubroutineType(types: !1033)
!1033 = !{!184, !504, !437, !439, !480}
!1034 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !1035, file: !875, line: 179)
!1035 = !DISubprogram(name: "vsscanf", linkageName: "__isoc23_vsscanf", scope: !878, file: !878, line: 519, type: !1036, flags: DIFlagPrototyped, spFlags: 0)
!1036 = !DISubroutineType(types: !1037)
!1037 = !{!184, !439, !439, !480}
!1038 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1023, file: !875, line: 185)
!1039 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1027, file: !875, line: 186)
!1040 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1029, file: !875, line: 187)
!1041 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1031, file: !875, line: 188)
!1042 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1035, file: !875, line: 189)
!1043 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !1044, file: !1047, line: 56)
!1044 = !DIDerivedType(tag: DW_TAG_typedef, name: "max_align_t", file: !1045, line: 24, baseType: !1046)
!1045 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/lnx64/tools/clang-16/lib/clang/16/include/__stddef_max_align_t.h", directory: "/home/user/EDA-202")
!1046 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1045, line: 19, size: 128, flags: DIFlagFwdDecl, identifier: "_ZTS11max_align_t")
!1047 = !DIFile(filename: "vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstddef", directory: "/home/user/EDA-202")
!1048 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !1049, entity: !1050, file: !95, line: 7)
!1049 = !DILexicalBlockFile(scope: !94, file: !6, discriminator: 0)
!1050 = !DIGlobalVariable(name: "g_full_cache_weight_q", linkageName: "_ZN4laya4full21g_full_cache_weight_qE", scope: !2, file: !6, line: 23, type: !5, isLocal: false, isDefinition: false)
!1051 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !1049, entity: !1052, file: !95, line: 8)
!1052 = !DIGlobalVariable(name: "g_full_cache_weight_scale", linkageName: "_ZN4laya4full25g_full_cache_weight_scaleE", scope: !2, file: !6, line: 24, type: !17, isLocal: false, isDefinition: false)
!1053 = !{}
!1054 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullRuntime", scope: !2, file: !1055, line: 122, size: 629632, flags: DIFlagTypePassByValue, elements: !1056, identifier: "_ZTSN4laya4full11FullRuntimeE")
!1055 = !DIFile(filename: "include/laya_full_runtime.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1056 = !{!1057, !1086, !1135, !1175, !1203, !1204, !1206, !1207, !1208, !1209, !1210, !1211, !1212, !1213, !1214, !1215, !1216, !1217, !1218, !1219, !1232, !1234, !1235, !1236, !1237, !1238, !1239, !1242, !1243, !1244, !1245, !1246, !1247, !1248, !1249, !1250, !1251, !1252, !1253, !1254, !1265, !1266, !1267, !1268, !1269}
!1057 = !DIDerivedType(tag: DW_TAG_member, name: "inputs", scope: !1054, file: !1055, line: 128, baseType: !1058, size: 83968)
!1058 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullInputs", scope: !2, file: !1055, line: 29, size: 83968, flags: DIFlagTypePassByValue, elements: !1059, identifier: "_ZTSN4laya4full10FullInputsE")
!1059 = !{!1060, !1074, !1076, !1079, !1081, !1083}
!1060 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1058, file: !1055, line: 30, baseType: !1061, size: 704)
!1061 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "NumericIdentity", scope: !3, file: !1062, line: 10, size: 704, flags: DIFlagTypePassByValue, elements: !1063, identifier: "_ZTSN4laya15NumericIdentityE")
!1062 = !DIFile(filename: "include/laya_numeric_tasks.h", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007")
!1063 = !{!1064, !1065, !1066, !1067, !1068, !1071, !1072, !1073}
!1064 = !DIDerivedType(tag: DW_TAG_member, name: "request_id", scope: !1061, file: !1062, line: 11, baseType: !220, size: 64)
!1065 = !DIDerivedType(tag: DW_TAG_member, name: "generation", scope: !1061, file: !1062, line: 12, baseType: !220, size: 64, offset: 64)
!1066 = !DIDerivedType(tag: DW_TAG_member, name: "B", scope: !1061, file: !1062, line: 13, baseType: !19, size: 16, offset: 128)
!1067 = !DIDerivedType(tag: DW_TAG_member, name: "S", scope: !1061, file: !1062, line: 13, baseType: !19, size: 16, offset: 144)
!1068 = !DIDerivedType(tag: DW_TAG_member, name: "model_tag", scope: !1061, file: !1062, line: 14, baseType: !1069, size: 128, offset: 160)
!1069 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 128, elements: !1070)
!1070 = !{!37}
!1071 = !DIDerivedType(tag: DW_TAG_member, name: "numeric_tag", scope: !1061, file: !1062, line: 15, baseType: !1069, size: 128, offset: 288)
!1072 = !DIDerivedType(tag: DW_TAG_member, name: "layout_tag", scope: !1061, file: !1062, line: 16, baseType: !1069, size: 128, offset: 416)
!1073 = !DIDerivedType(tag: DW_TAG_member, name: "build_tag", scope: !1061, file: !1062, line: 17, baseType: !1069, size: 128, offset: 544)
!1074 = !DIDerivedType(tag: DW_TAG_member, name: "token_ids", scope: !1058, file: !1055, line: 31, baseType: !1075, size: 65536, offset: 704)
!1075 = !DICompositeType(tag: DW_TAG_array_type, baseType: !182, size: 65536, elements: !60)
!1076 = !DIDerivedType(tag: DW_TAG_member, name: "marker_positions", scope: !1058, file: !1055, line: 32, baseType: !1077, size: 1024, offset: 66240)
!1077 = !DICompositeType(tag: DW_TAG_array_type, baseType: !182, size: 1024, elements: !1078)
!1078 = !{!61, !37}
!1079 = !DIDerivedType(tag: DW_TAG_member, name: "attention_mask", scope: !1058, file: !1055, line: 33, baseType: !1080, size: 16384, offset: 67264)
!1080 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 16384, elements: !60)
!1081 = !DIDerivedType(tag: DW_TAG_member, name: "marker_mask", scope: !1058, file: !1055, line: 34, baseType: !1082, size: 256, offset: 83648)
!1082 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 256, elements: !1078)
!1083 = !DIDerivedType(tag: DW_TAG_member, name: "qtype", scope: !1058, file: !1055, line: 35, baseType: !1084, size: 16, offset: 83904)
!1084 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 16, elements: !1085)
!1085 = !{!61}
!1086 = !DIDerivedType(tag: DW_TAG_member, name: "owners", scope: !1054, file: !1055, line: 129, baseType: !1087, size: 524416, offset: 83968)
!1087 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwners", scope: !2, file: !1055, line: 90, size: 524416, flags: DIFlagTypePassByValue, elements: !1088, identifier: "_ZTSN4laya4full10FullOwnersE")
!1088 = !{!1089, !1119, !1123, !1126, !1129, !1131, !1132}
!1089 = !DIDerivedType(tag: DW_TAG_member, name: "record", scope: !1087, file: !1055, line: 91, baseType: !1090, size: 163840)
!1090 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1091, size: 163840, elements: !1118)
!1091 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwnerRecord", scope: !2, file: !1055, line: 64, size: 5120, flags: DIFlagTypePassByValue, elements: !1092, identifier: "_ZTSN4laya4full15FullOwnerRecordE")
!1092 = !{!1093, !1094, !1100, !1101, !1102, !1103, !1104, !1105, !1106, !1107, !1108, !1109, !1110, !1111, !1112, !1113, !1116, !1117}
!1093 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1091, file: !1055, line: 65, baseType: !1061, size: 704)
!1094 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1091, file: !1055, line: 66, baseType: !1095, size: 64, offset: 704)
!1095 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "BufferRef", scope: !3, file: !110, line: 19, size: 64, flags: DIFlagTypePassByValue, elements: !1096, identifier: "_ZTSN4laya9BufferRefE")
!1096 = !{!1097, !1098, !1099}
!1097 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !1095, file: !110, line: 19, baseType: !109, size: 8)
!1098 = !DIDerivedType(tag: DW_TAG_member, name: "bank", scope: !1095, file: !110, line: 19, baseType: !98, size: 8, offset: 8)
!1099 = !DIDerivedType(tag: DW_TAG_member, name: "epoch", scope: !1095, file: !110, line: 19, baseType: !101, size: 32, offset: 32)
!1100 = !DIDerivedType(tag: DW_TAG_member, name: "lease_old_ref", scope: !1091, file: !1055, line: 67, baseType: !1095, size: 64, offset: 768)
!1101 = !DIDerivedType(tag: DW_TAG_member, name: "max_claimed_epoch", scope: !1091, file: !1055, line: 68, baseType: !101, size: 32, offset: 832)
!1102 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1091, file: !1055, line: 69, baseType: !98, size: 8, offset: 864)
!1103 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1091, file: !1055, line: 69, baseType: !98, size: 8, offset: 872)
!1104 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1091, file: !1055, line: 69, baseType: !98, size: 8, offset: 880)
!1105 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1091, file: !1055, line: 69, baseType: !98, size: 8, offset: 888)
!1106 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1091, file: !1055, line: 70, baseType: !136, size: 8, offset: 896)
!1107 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1091, file: !1055, line: 71, baseType: !19, size: 16, offset: 912)
!1108 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1091, file: !1055, line: 71, baseType: !19, size: 16, offset: 928)
!1109 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1091, file: !1055, line: 71, baseType: !19, size: 16, offset: 944)
!1110 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1091, file: !1055, line: 72, baseType: !141, size: 8, offset: 960)
!1111 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1091, file: !1055, line: 73, baseType: !151, size: 8, offset: 968)
!1112 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1091, file: !1055, line: 74, baseType: !98, size: 8, offset: 976)
!1113 = !DIDerivedType(tag: DW_TAG_member, name: "covered_rows", scope: !1091, file: !1055, line: 75, baseType: !1114, size: 2048, offset: 992)
!1114 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 2048, elements: !1115)
!1115 = !{!69}
!1116 = !DIDerivedType(tag: DW_TAG_member, name: "old_consumed_rows", scope: !1091, file: !1055, line: 76, baseType: !1114, size: 2048, offset: 3040)
!1117 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1091, file: !1055, line: 77, baseType: !104, size: 8, offset: 5088)
!1118 = !{!39}
!1119 = !DIDerivedType(tag: DW_TAG_member, name: "qkv_plane_head_rows", scope: !1087, file: !1055, line: 92, baseType: !1120, size: 196608, offset: 163840)
!1120 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 196608, elements: !1121)
!1121 = !{!61, !1122, !37, !61, !39}
!1122 = !DISubrange(count: 3, lowerBound: 0)
!1123 = !DIDerivedType(tag: DW_TAG_member, name: "qkv_rope_rows", scope: !1087, file: !1055, line: 93, baseType: !1124, size: 131072, offset: 360448)
!1124 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 131072, elements: !1125)
!1125 = !{!61, !61, !37, !61, !39}
!1126 = !DIDerivedType(tag: DW_TAG_member, name: "att_head_rows", scope: !1087, file: !1055, line: 94, baseType: !1127, size: 32768, offset: 491520)
!1127 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 32768, elements: !1128)
!1128 = !{!37, !61, !39}
!1129 = !DIDerivedType(tag: DW_TAG_member, name: "scorer_old_consumed", scope: !1087, file: !1055, line: 95, baseType: !1130, size: 32, offset: 524288)
!1130 = !DICompositeType(tag: DW_TAG_array_type, baseType: !19, size: 32, elements: !1085)
!1131 = !DIDerivedType(tag: DW_TAG_member, name: "scorer_new_written", scope: !1087, file: !1055, line: 96, baseType: !1130, size: 32, offset: 524320)
!1132 = !DIDerivedType(tag: DW_TAG_member, name: "type_valid", scope: !1087, file: !1055, line: 97, baseType: !1133, size: 24, offset: 524352)
!1133 = !DICompositeType(tag: DW_TAG_array_type, baseType: !104, size: 24, elements: !1134)
!1134 = !{!1122}
!1135 = !DIDerivedType(tag: DW_TAG_member, name: "cache", scope: !1054, file: !1055, line: 130, baseType: !1136, size: 9024, offset: 608384)
!1136 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullCache", scope: !2, file: !1055, line: 102, size: 9024, flags: DIFlagTypePassByValue, elements: !1137, identifier: "_ZTSN4laya4full9FullCacheE")
!1137 = !{!1138, !1156}
!1138 = !DIDerivedType(tag: DW_TAG_member, name: "activation_source_ledger", scope: !1136, file: !1055, line: 118, baseType: !1139, size: 3008)
!1139 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "F32TileMeta", scope: !3, file: !1062, line: 20, size: 3008, flags: DIFlagTypePassByValue, elements: !1140, identifier: "_ZTSN4laya11F32TileMetaE")
!1140 = !{!1141, !1142, !1143, !1144, !1145, !1146, !1147, !1148, !1149, !1150, !1151, !1152, !1155}
!1141 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1139, file: !1062, line: 21, baseType: !1061, size: 704)
!1142 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1139, file: !1062, line: 22, baseType: !1095, size: 64, offset: 704)
!1143 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1139, file: !1062, line: 23, baseType: !98, size: 8, offset: 768)
!1144 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1139, file: !1062, line: 24, baseType: !136, size: 8, offset: 776)
!1145 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1139, file: !1062, line: 25, baseType: !98, size: 8, offset: 784)
!1146 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1139, file: !1062, line: 26, baseType: !19, size: 16, offset: 800)
!1147 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1139, file: !1062, line: 27, baseType: !98, size: 8, offset: 816)
!1148 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1139, file: !1062, line: 28, baseType: !19, size: 16, offset: 832)
!1149 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1139, file: !1062, line: 29, baseType: !151, size: 8, offset: 848)
!1150 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1139, file: !1062, line: 30, baseType: !141, size: 8, offset: 856)
!1151 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1139, file: !1062, line: 31, baseType: !98, size: 8, offset: 864)
!1152 = !DIDerivedType(tag: DW_TAG_member, name: "covered_groups", scope: !1139, file: !1062, line: 33, baseType: !1153, size: 2048, offset: 896)
!1153 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 2048, elements: !1154)
!1154 = !{!37, !380}
!1155 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1139, file: !1062, line: 34, baseType: !104, size: 8, offset: 2944)
!1156 = !DIDerivedType(tag: DW_TAG_member, name: "activation_meta", scope: !1136, file: !1055, line: 119, baseType: !1157, size: 6016, offset: 3008)
!1157 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "A8TileMeta", scope: !3, file: !1062, line: 47, size: 6016, flags: DIFlagTypePassByValue, elements: !1158, identifier: "_ZTSN4laya10A8TileMetaE")
!1158 = !{!1159, !1160, !1161, !1162, !1163, !1164, !1165, !1166, !1167, !1168, !1169, !1170, !1171, !1172, !1173, !1174}
!1159 = !DIDerivedType(tag: DW_TAG_member, name: "identity", scope: !1157, file: !1062, line: 48, baseType: !1061, size: 704)
!1160 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1157, file: !1062, line: 49, baseType: !1095, size: 64, offset: 704)
!1161 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !1157, file: !1062, line: 50, baseType: !1139, size: 3008, offset: 768)
!1162 = !DIDerivedType(tag: DW_TAG_member, name: "producer_task_id", scope: !1157, file: !1062, line: 51, baseType: !101, size: 32, offset: 3776)
!1163 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1157, file: !1062, line: 52, baseType: !98, size: 8, offset: 3808)
!1164 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1157, file: !1062, line: 52, baseType: !98, size: 8, offset: 3816)
!1165 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1157, file: !1062, line: 53, baseType: !136, size: 8, offset: 3824)
!1166 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1157, file: !1062, line: 54, baseType: !98, size: 8, offset: 3832)
!1167 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1157, file: !1062, line: 55, baseType: !19, size: 16, offset: 3840)
!1168 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1157, file: !1062, line: 56, baseType: !98, size: 8, offset: 3856)
!1169 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1157, file: !1062, line: 57, baseType: !19, size: 16, offset: 3872)
!1170 = !DIDerivedType(tag: DW_TAG_member, name: "covered_groups", scope: !1157, file: !1062, line: 58, baseType: !1153, size: 2048, offset: 3904)
!1171 = !DIDerivedType(tag: DW_TAG_member, name: "state", scope: !1157, file: !1062, line: 59, baseType: !151, size: 8, offset: 5952)
!1172 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1157, file: !1062, line: 60, baseType: !141, size: 8, offset: 5960)
!1173 = !DIDerivedType(tag: DW_TAG_member, name: "readers", scope: !1157, file: !1062, line: 61, baseType: !98, size: 8, offset: 5968)
!1174 = !DIDerivedType(tag: DW_TAG_member, name: "valid", scope: !1157, file: !1062, line: 62, baseType: !104, size: 8, offset: 5976)
!1175 = !DIDerivedType(tag: DW_TAG_member, name: "current_weight", scope: !1054, file: !1055, line: 131, baseType: !1176, size: 1280, offset: 617408)
!1176 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullWeightDescriptor", scope: !2, file: !1055, line: 51, size: 1280, flags: DIFlagTypePassByValue, elements: !1177, identifier: "_ZTSN4laya4full20FullWeightDescriptorE")
!1177 = !{!1178, !1182, !1187, !1188, !1189, !1190, !1191, !1193, !1194, !1195, !1196, !1197, !1198, !1199, !1200, !1202}
!1178 = !DIDerivedType(tag: DW_TAG_member, name: "name", scope: !1176, file: !1055, line: 52, baseType: !1179, size: 384)
!1179 = !DICompositeType(tag: DW_TAG_array_type, baseType: !313, size: 384, elements: !1180)
!1180 = !{!1181}
!1181 = !DISubrange(count: 48, lowerBound: 0)
!1182 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !1176, file: !1055, line: 53, baseType: !1183, size: 16, offset: 384)
!1183 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "WeightKey", scope: !3, file: !110, line: 23, size: 16, flags: DIFlagTypePassByValue, elements: !1184, identifier: "_ZTSN4laya9WeightKeyE")
!1184 = !{!1185, !1186}
!1185 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !1183, file: !110, line: 23, baseType: !98, size: 8)
!1186 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1183, file: !110, line: 23, baseType: !98, size: 8, offset: 8)
!1187 = !DIDerivedType(tag: DW_TAG_member, name: "K", scope: !1176, file: !1055, line: 54, baseType: !19, size: 16, offset: 400)
!1188 = !DIDerivedType(tag: DW_TAG_member, name: "N", scope: !1176, file: !1055, line: 54, baseType: !19, size: 16, offset: 416)
!1189 = !DIDerivedType(tag: DW_TAG_member, name: "dtype", scope: !1176, file: !1055, line: 55, baseType: !98, size: 8, offset: 432)
!1190 = !DIDerivedType(tag: DW_TAG_member, name: "bias_kind", scope: !1176, file: !1055, line: 55, baseType: !98, size: 8, offset: 440)
!1191 = !DIDerivedType(tag: DW_TAG_member, name: "q_base", scope: !1176, file: !1055, line: 56, baseType: !1192, size: 64, offset: 448)
!1192 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 64, elements: !1085)
!1193 = !DIDerivedType(tag: DW_TAG_member, name: "q_span", scope: !1176, file: !1055, line: 56, baseType: !1192, size: 64, offset: 512)
!1194 = !DIDerivedType(tag: DW_TAG_member, name: "scale_base", scope: !1176, file: !1055, line: 57, baseType: !101, size: 32, offset: 576)
!1195 = !DIDerivedType(tag: DW_TAG_member, name: "scale_span", scope: !1176, file: !1055, line: 57, baseType: !101, size: 32, offset: 608)
!1196 = !DIDerivedType(tag: DW_TAG_member, name: "aux_base", scope: !1176, file: !1055, line: 58, baseType: !101, size: 32, offset: 640)
!1197 = !DIDerivedType(tag: DW_TAG_member, name: "aux_span", scope: !1176, file: !1055, line: 58, baseType: !101, size: 32, offset: 672)
!1198 = !DIDerivedType(tag: DW_TAG_member, name: "bias_base", scope: !1176, file: !1055, line: 59, baseType: !101, size: 32, offset: 704)
!1199 = !DIDerivedType(tag: DW_TAG_member, name: "bias_span", scope: !1176, file: !1055, line: 59, baseType: !101, size: 32, offset: 736)
!1200 = !DIDerivedType(tag: DW_TAG_member, name: "source_sha256", scope: !1176, file: !1055, line: 60, baseType: !1201, size: 256, offset: 768)
!1201 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 256, elements: !1118)
!1202 = !DIDerivedType(tag: DW_TAG_member, name: "bias_sha256", scope: !1176, file: !1055, line: 61, baseType: !1201, size: 256, offset: 1024)
!1203 = !DIDerivedType(tag: DW_TAG_member, name: "current_weight_ref", scope: !1054, file: !1055, line: 132, baseType: !1095, size: 64, offset: 618688)
!1204 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_gamma_ref", scope: !1054, file: !1055, line: 133, baseType: !1205, size: 128, offset: 618752)
!1205 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1095, size: 128, elements: !1085)
!1206 = !DIDerivedType(tag: DW_TAG_member, name: "final_qkv_ref", scope: !1054, file: !1055, line: 134, baseType: !1205, size: 128, offset: 618880)
!1207 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_kv_ref", scope: !1054, file: !1055, line: 135, baseType: !1095, size: 64, offset: 619008)
!1208 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_rope_ref", scope: !1054, file: !1055, line: 135, baseType: !1095, size: 64, offset: 619072)
!1209 = !DIDerivedType(tag: DW_TAG_member, name: "score_ref", scope: !1054, file: !1055, line: 136, baseType: !1095, size: 64, offset: 619136)
!1210 = !DIDerivedType(tag: DW_TAG_member, name: "score_kv_ref", scope: !1054, file: !1055, line: 136, baseType: !1095, size: 64, offset: 619200)
!1211 = !DIDerivedType(tag: DW_TAG_member, name: "score_qkv_ref", scope: !1054, file: !1055, line: 136, baseType: !1205, size: 128, offset: 619264)
!1212 = !DIDerivedType(tag: DW_TAG_member, name: "score_head", scope: !1054, file: !1055, line: 137, baseType: !98, size: 8, offset: 619392)
!1213 = !DIDerivedType(tag: DW_TAG_member, name: "score_stage", scope: !1054, file: !1055, line: 137, baseType: !98, size: 8, offset: 619400)
!1214 = !DIDerivedType(tag: DW_TAG_member, name: "score_layer", scope: !1054, file: !1055, line: 137, baseType: !98, size: 8, offset: 619408)
!1215 = !DIDerivedType(tag: DW_TAG_member, name: "score_batch", scope: !1054, file: !1055, line: 138, baseType: !98, size: 8, offset: 619416)
!1216 = !DIDerivedType(tag: DW_TAG_member, name: "score_rows", scope: !1054, file: !1055, line: 138, baseType: !98, size: 8, offset: 619424)
!1217 = !DIDerivedType(tag: DW_TAG_member, name: "score_row0", scope: !1054, file: !1055, line: 139, baseType: !19, size: 16, offset: 619440)
!1218 = !DIDerivedType(tag: DW_TAG_member, name: "score_valid", scope: !1054, file: !1055, line: 140, baseType: !104, size: 8, offset: 619456)
!1219 = !DIDerivedType(tag: DW_TAG_member, name: "expected_quant_source", scope: !1054, file: !1055, line: 141, baseType: !1220, size: 192, offset: 619488)
!1220 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "FullOwnerSpec", scope: !2, file: !1055, line: 80, size: 192, flags: DIFlagTypePassByValue, elements: !1221, identifier: "_ZTSN4laya4full13FullOwnerSpecE")
!1221 = !{!1222, !1223, !1224, !1225, !1226, !1227, !1228, !1229, !1230, !1231}
!1222 = !DIDerivedType(tag: DW_TAG_member, name: "ref", scope: !1220, file: !1055, line: 81, baseType: !1095, size: 64)
!1223 = !DIDerivedType(tag: DW_TAG_member, name: "region", scope: !1220, file: !1055, line: 82, baseType: !98, size: 8, offset: 64)
!1224 = !DIDerivedType(tag: DW_TAG_member, name: "stage", scope: !1220, file: !1055, line: 82, baseType: !98, size: 8, offset: 72)
!1225 = !DIDerivedType(tag: DW_TAG_member, name: "layer", scope: !1220, file: !1055, line: 82, baseType: !98, size: 8, offset: 80)
!1226 = !DIDerivedType(tag: DW_TAG_member, name: "batch", scope: !1220, file: !1055, line: 83, baseType: !98, size: 8, offset: 88)
!1227 = !DIDerivedType(tag: DW_TAG_member, name: "row_space", scope: !1220, file: !1055, line: 84, baseType: !136, size: 8, offset: 96)
!1228 = !DIDerivedType(tag: DW_TAG_member, name: "row0", scope: !1220, file: !1055, line: 85, baseType: !19, size: 16, offset: 112)
!1229 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !1220, file: !1055, line: 85, baseType: !19, size: 16, offset: 128)
!1230 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1220, file: !1055, line: 86, baseType: !19, size: 16, offset: 144)
!1231 = !DIDerivedType(tag: DW_TAG_member, name: "content", scope: !1220, file: !1055, line: 87, baseType: !141, size: 8, offset: 160)
!1232 = !DIDerivedType(tag: DW_TAG_member, name: "expected_task_source", scope: !1054, file: !1055, line: 142, baseType: !1233, size: 768, offset: 619680)
!1233 = !DICompositeType(tag: DW_TAG_array_type, baseType: !1220, size: 768, elements: !379)
!1234 = !DIDerivedType(tag: DW_TAG_member, name: "expected_task_source_count", scope: !1054, file: !1055, line: 143, baseType: !98, size: 8, offset: 620448)
!1235 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_rope_mode", scope: !1054, file: !1055, line: 144, baseType: !98, size: 8, offset: 620456)
!1236 = !DIDerivedType(tag: DW_TAG_member, name: "loaded_kv_head", scope: !1054, file: !1055, line: 144, baseType: !98, size: 8, offset: 620464)
!1237 = !DIDerivedType(tag: DW_TAG_member, name: "last_task_id", scope: !1054, file: !1055, line: 145, baseType: !101, size: 32, offset: 620480)
!1238 = !DIDerivedType(tag: DW_TAG_member, name: "tasks_retired", scope: !1054, file: !1055, line: 145, baseType: !101, size: 32, offset: 620512)
!1239 = !DIDerivedType(tag: DW_TAG_member, name: "op_calls", scope: !1054, file: !1055, line: 146, baseType: !1240, size: 8192, offset: 620544)
!1240 = !DICompositeType(tag: DW_TAG_array_type, baseType: !101, size: 8192, elements: !1241)
!1241 = !{!90}
!1242 = !DIDerivedType(tag: DW_TAG_member, name: "owner_claims", scope: !1054, file: !1055, line: 147, baseType: !101, size: 32, offset: 628736)
!1243 = !DIDerivedType(tag: DW_TAG_member, name: "owner_leases", scope: !1054, file: !1055, line: 147, baseType: !101, size: 32, offset: 628768)
!1244 = !DIDerivedType(tag: DW_TAG_member, name: "encoder_layers_completed", scope: !1054, file: !1055, line: 148, baseType: !98, size: 8, offset: 628800)
!1245 = !DIDerivedType(tag: DW_TAG_member, name: "decision_layers_completed", scope: !1054, file: !1055, line: 148, baseType: !98, size: 8, offset: 628808)
!1246 = !DIDerivedType(tag: DW_TAG_member, name: "session_generation", scope: !1054, file: !1055, line: 149, baseType: !220, size: 64, offset: 628864)
!1247 = !DIDerivedType(tag: DW_TAG_member, name: "last_accepted_request_id", scope: !1054, file: !1055, line: 149, baseType: !220, size: 64, offset: 628928)
!1248 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_request_id", scope: !1054, file: !1055, line: 150, baseType: !220, size: 64, offset: 628992)
!1249 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_generation", scope: !1054, file: !1055, line: 150, baseType: !220, size: 64, offset: 629056)
!1250 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_B", scope: !1054, file: !1055, line: 151, baseType: !19, size: 16, offset: 629120)
!1251 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_S", scope: !1054, file: !1055, line: 151, baseType: !19, size: 16, offset: 629136)
!1252 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_identity_valid", scope: !1054, file: !1055, line: 152, baseType: !104, size: 8, offset: 629152)
!1253 = !DIDerivedType(tag: DW_TAG_member, name: "diagnostic_shape_valid", scope: !1054, file: !1055, line: 152, baseType: !104, size: 8, offset: 629160)
!1254 = !DIDerivedType(tag: DW_TAG_member, name: "last_execution_error", scope: !1054, file: !1055, line: 153, baseType: !1255, size: 128, offset: 629184)
!1255 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "Check", scope: !3, file: !110, line: 9, size: 128, flags: DIFlagTypePassByValue, elements: !1256, identifier: "_ZTSN4laya5CheckE")
!1256 = !{!1257, !1258, !1259, !1260}
!1257 = !DIDerivedType(tag: DW_TAG_member, name: "code", scope: !1255, file: !110, line: 9, baseType: !160, size: 16)
!1258 = !DIDerivedType(tag: DW_TAG_member, name: "detail", scope: !1255, file: !110, line: 9, baseType: !101, size: 32, offset: 32)
!1259 = !DIDerivedType(tag: DW_TAG_member, name: "bad_element", scope: !1255, file: !110, line: 9, baseType: !220, size: 64, offset: 64)
!1260 = !DISubprogram(name: "operator bool", linkageName: "_ZNK4laya5CheckcvbEv", scope: !1255, file: !110, line: 9, type: !1261, scopeLine: 9, flags: DIFlagExplicit | DIFlagPrototyped, spFlags: 0)
!1261 = !DISubroutineType(types: !1262)
!1262 = !{!104, !1263}
!1263 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1264, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1264 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1255)
!1265 = !DIDerivedType(tag: DW_TAG_member, name: "last_cleanup_error", scope: !1054, file: !1055, line: 153, baseType: !1255, size: 128, offset: 629312)
!1266 = !DIDerivedType(tag: DW_TAG_member, name: "last_commit_error", scope: !1054, file: !1055, line: 154, baseType: !1255, size: 128, offset: 629440)
!1267 = !DIDerivedType(tag: DW_TAG_member, name: "request_valid", scope: !1054, file: !1055, line: 155, baseType: !104, size: 8, offset: 629568)
!1268 = !DIDerivedType(tag: DW_TAG_member, name: "model_header_valid", scope: !1054, file: !1055, line: 155, baseType: !104, size: 8, offset: 629576)
!1269 = !DIDerivedType(tag: DW_TAG_member, name: "expected_quant_source_valid", scope: !1054, file: !1055, line: 156, baseType: !104, size: 8, offset: 629584)
!1270 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1271, producer: "clang version 7.0.0 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !1272, retainedTypes: !1290, imports: !2439)
!1271 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/build/hls_clib/lnx64/hlsmath_csyn_floatconversion/objs/src/lib_floatconversion.pp.cpp", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1272 = !{!1273, !1283}
!1273 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "ap_q_mode", file: !1274, line: 51, size: 32, elements: !1275, identifier: "_ZTS9ap_q_mode")
!1274 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/etc/ap_decl.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1275 = !{!1276, !1277, !1278, !1279, !1280, !1281, !1282}
!1276 = !DIEnumerator(name: "AP_RND", value: 0)
!1277 = !DIEnumerator(name: "AP_RND_ZERO", value: 1)
!1278 = !DIEnumerator(name: "AP_RND_MIN_INF", value: 2)
!1279 = !DIEnumerator(name: "AP_RND_INF", value: 3)
!1280 = !DIEnumerator(name: "AP_RND_CONV", value: 4)
!1281 = !DIEnumerator(name: "AP_TRN", value: 5)
!1282 = !DIEnumerator(name: "AP_TRN_ZERO", value: 6)
!1283 = distinct !DICompositeType(tag: DW_TAG_enumeration_type, name: "ap_o_mode", file: !1274, line: 73, size: 32, elements: !1284, identifier: "_ZTS9ap_o_mode")
!1284 = !{!1285, !1286, !1287, !1288, !1289}
!1285 = !DIEnumerator(name: "AP_SAT", value: 0)
!1286 = !DIEnumerator(name: "AP_SAT_ZERO", value: 1)
!1287 = !DIEnumerator(name: "AP_SAT_SYM", value: 2)
!1288 = !DIEnumerator(name: "AP_WRAP", value: 3)
!1289 = !DIEnumerator(name: "AP_WRAP_SM", value: 4)
!1290 = !{!1291, !104, !254, !1293, !1324, !1325, !1353, !1380, !1414, !1441, !1456, !1480, !1501, !184, !12, !1525, !1548, !1557, !180, !1582, !1603, !1622, !1623, !1646, !1668, !1675, !1412, !1694, !1707, !1735, !1748, !1776, !1785, !100, !103, !1801, !1824, !22, !1825, !1848, !1849, !1872, !1873, !2077, !2225}
!1291 = !DIDerivedType(tag: DW_TAG_typedef, name: "ap_ulong", file: !1274, line: 185, baseType: !1292)
!1292 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!1293 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1294)
!1294 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<16, false>", file: !1295, line: 121, size: 16, flags: DIFlagTypePassByValue, elements: !1296, templateParams: !1322, identifier: "_ZTS11ap_int_baseILi16ELb0EE")
!1295 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/etc/ap_int_base.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1296 = !{!1297, !1312, !1314, !1316}
!1297 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1294, baseType: !1298)
!1298 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<16, false>", file: !1299, line: 523, size: 16, flags: DIFlagTypePassByValue, elements: !1300, templateParams: !1309, identifier: "_ZTS8ssdm_intILi16ELb0EE")
!1299 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/etc/ap_common.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1300 = !{!1301, !1302, !1306}
!1301 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1298, file: !1299, line: 525, baseType: !22, size: 16)
!1302 = !DISubprogram(name: "ssdm_int", scope: !1298, file: !1299, line: 526, type: !1303, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1303 = !DISubroutineType(types: !1304)
!1304 = !{null, !1305}
!1305 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1298, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1306 = !DISubprogram(name: "ssdm_int", scope: !1298, file: !1299, line: 527, type: !1307, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1307 = !DISubroutineType(types: !1308)
!1308 = !{null, !1305, !22}
!1309 = !{!1310, !1311}
!1310 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 16)
!1311 = !DITemplateValueParameter(name: "_AP_S", type: !104, value: i8 0)
!1312 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1294, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 16)
!1313 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !184)
!1314 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1294, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1315 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !104)
!1316 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi16ELb0EEaSERKS0_", scope: !1294, file: !1295, line: 476, type: !1317, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1317 = !DISubroutineType(types: !1318)
!1318 = !{!1319, !1320, !1321}
!1319 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1294, size: 64)
!1320 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1294, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1321 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1293, size: 64)
!1322 = !{!1323, !1311}
!1323 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 16)
!1324 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!1325 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1326, size: 64)
!1326 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<10, false>", file: !1295, line: 121, size: 16, flags: DIFlagTypePassByValue, elements: !1327, templateParams: !1351, identifier: "_ZTS11ap_int_baseILi10ELb0EE")
!1327 = !{!1328, !1342, !1343, !1344}
!1328 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1326, baseType: !1329)
!1329 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<10, false>", file: !1299, line: 523, size: 16, flags: DIFlagTypePassByValue, elements: !1330, templateParams: !1340, identifier: "_ZTS8ssdm_intILi10ELb0EE")
!1330 = !{!1331, !1333, !1337}
!1331 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1329, file: !1299, line: 525, baseType: !1332, size: 10, align: 16)
!1332 = !DIBasicType(name: "uint10", size: 10, encoding: DW_ATE_unsigned)
!1333 = !DISubprogram(name: "ssdm_int", scope: !1329, file: !1299, line: 526, type: !1334, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1334 = !DISubroutineType(types: !1335)
!1335 = !{null, !1336}
!1336 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1329, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1337 = !DISubprogram(name: "ssdm_int", scope: !1329, file: !1299, line: 527, type: !1338, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1338 = !DISubroutineType(types: !1339)
!1339 = !{null, !1336, !1332}
!1340 = !{!1341, !1311}
!1341 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 10)
!1342 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1326, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 10)
!1343 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1326, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1344 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi10ELb0EEaSERKS0_", scope: !1326, file: !1295, line: 476, type: !1345, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1345 = !DISubroutineType(types: !1346)
!1346 = !{!1347, !1348, !1349}
!1347 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1326, size: 64)
!1348 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1326, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1349 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1350, size: 64)
!1350 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1326)
!1351 = !{!1352, !1311}
!1352 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 10)
!1353 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<32, true>", file: !1295, line: 121, size: 32, flags: DIFlagTypePassByValue, elements: !1354, templateParams: !1378, identifier: "_ZTS11ap_int_baseILi32ELb1EE")
!1354 = !{!1355, !1369, !1370, !1371}
!1355 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1353, baseType: !1356)
!1356 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<32, true>", file: !1299, line: 515, size: 32, flags: DIFlagTypePassByValue, elements: !1357, templateParams: !1366, identifier: "_ZTS8ssdm_intILi32ELb1EE")
!1357 = !{!1358, !1359, !1363}
!1358 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1356, file: !1299, line: 517, baseType: !184, size: 32)
!1359 = !DISubprogram(name: "ssdm_int", scope: !1356, file: !1299, line: 518, type: !1360, scopeLine: 518, flags: DIFlagPrototyped, spFlags: 0)
!1360 = !DISubroutineType(types: !1361)
!1361 = !{null, !1362}
!1362 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1356, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1363 = !DISubprogram(name: "ssdm_int", scope: !1356, file: !1299, line: 519, type: !1364, scopeLine: 519, flags: DIFlagPrototyped, spFlags: 0)
!1364 = !DISubroutineType(types: !1365)
!1365 = !{null, !1362, !184}
!1366 = !{!1367, !1368}
!1367 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 32)
!1368 = !DITemplateValueParameter(name: "_AP_S", type: !104, value: i8 1)
!1369 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1353, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1370 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1353, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 true)
!1371 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi32ELb1EEaSERKS0_", scope: !1353, file: !1295, line: 476, type: !1372, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1372 = !DISubroutineType(types: !1373)
!1373 = !{!1374, !1375, !1376}
!1374 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1353, size: 64)
!1375 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1353, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1376 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1377, size: 64)
!1377 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1353)
!1378 = !{!1379, !1368}
!1379 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 32)
!1380 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1381, file: !1295, line: 143, baseType: !1408)
!1381 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<33, true>", file: !1295, line: 121, size: 64, flags: DIFlagTypePassByValue, elements: !1382, templateParams: !1406, identifier: "_ZTS11ap_int_baseILi33ELb1EE")
!1382 = !{!1383, !1397, !1398, !1399}
!1383 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1381, baseType: !1384)
!1384 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<33, true>", file: !1299, line: 515, size: 64, flags: DIFlagTypePassByValue, elements: !1385, templateParams: !1395, identifier: "_ZTS8ssdm_intILi33ELb1EE")
!1385 = !{!1386, !1388, !1392}
!1386 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1384, file: !1299, line: 517, baseType: !1387, size: 33, align: 64)
!1387 = !DIBasicType(name: "int33", size: 33, encoding: DW_ATE_signed)
!1388 = !DISubprogram(name: "ssdm_int", scope: !1384, file: !1299, line: 518, type: !1389, scopeLine: 518, flags: DIFlagPrototyped, spFlags: 0)
!1389 = !DISubroutineType(types: !1390)
!1390 = !{null, !1391}
!1391 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1384, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1392 = !DISubprogram(name: "ssdm_int", scope: !1384, file: !1299, line: 519, type: !1393, scopeLine: 519, flags: DIFlagPrototyped, spFlags: 0)
!1393 = !DISubroutineType(types: !1394)
!1394 = !{null, !1391, !1387}
!1395 = !{!1396, !1368}
!1396 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 33)
!1397 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1381, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 33)
!1398 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1381, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 true)
!1399 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi33ELb1EEaSERKS0_", scope: !1381, file: !1295, line: 476, type: !1400, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1400 = !DISubroutineType(types: !1401)
!1401 = !{!1402, !1403, !1404}
!1402 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1381, size: 64)
!1403 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1381, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1404 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1405, size: 64)
!1405 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1381)
!1406 = !{!1407, !1368}
!1407 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 33)
!1408 = !DIDerivedType(tag: DW_TAG_typedef, name: "Type", scope: !1409, file: !1295, line: 59, baseType: !1412)
!1409 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "retval<8, true>", file: !1295, line: 58, size: 8, flags: DIFlagTypePassByValue, elements: !1053, templateParams: !1410, identifier: "_ZTS6retvalILi8ELb1EE")
!1410 = !{!1411, !1368}
!1411 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 8)
!1412 = !DIDerivedType(tag: DW_TAG_typedef, name: "ap_slong", file: !1274, line: 184, baseType: !1413)
!1413 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!1414 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<1, false>", file: !1295, line: 121, size: 8, flags: DIFlagTypePassByValue, elements: !1415, templateParams: !1439, identifier: "_ZTS11ap_int_baseILi1ELb0EE")
!1415 = !{!1416, !1430, !1431, !1432}
!1416 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1414, baseType: !1417)
!1417 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<1, false>", file: !1299, line: 523, size: 8, flags: DIFlagTypePassByValue, elements: !1418, templateParams: !1428, identifier: "_ZTS8ssdm_intILi1ELb0EE")
!1418 = !{!1419, !1421, !1425}
!1419 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1417, file: !1299, line: 525, baseType: !1420, size: 1, align: 8)
!1420 = !DIBasicType(name: "uint1", size: 1, encoding: DW_ATE_unsigned)
!1421 = !DISubprogram(name: "ssdm_int", scope: !1417, file: !1299, line: 526, type: !1422, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1422 = !DISubroutineType(types: !1423)
!1423 = !{null, !1424}
!1424 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1417, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1425 = !DISubprogram(name: "ssdm_int", scope: !1417, file: !1299, line: 527, type: !1426, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1426 = !DISubroutineType(types: !1427)
!1427 = !{null, !1424, !1420}
!1428 = !{!1429, !1311}
!1429 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 1)
!1430 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1414, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 1)
!1431 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1414, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1432 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi1ELb0EEaSERKS0_", scope: !1414, file: !1295, line: 476, type: !1433, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1433 = !DISubroutineType(types: !1434)
!1434 = !{!1435, !1436, !1437}
!1435 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1414, size: 64)
!1436 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1414, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1437 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1438, size: 64)
!1438 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1414)
!1439 = !{!1440, !1311}
!1440 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 1)
!1441 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<32, 32, true, AP_TRN, AP_WRAP, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !1443, templateParams: !1451, identifier: "_ZTS13ap_fixed_baseILi32ELi32ELb1EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!1442 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/etc/ap_fixed_base.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1443 = !{!1444, !1445, !1446, !1447, !1449}
!1444 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1441, baseType: !1356)
!1445 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1441, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1446 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1441, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1447 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1441, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1448 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1273)
!1449 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1441, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!1450 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1283)
!1451 = !{!1379, !1452, !1368, !1453, !1454, !1455}
!1452 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 32)
!1453 = !DITemplateValueParameter(name: "_AP_Q", type: !1273, value: i32 5)
!1454 = !DITemplateValueParameter(name: "_AP_O", type: !1283, value: i32 3)
!1455 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 0)
!1456 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<9, 9, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 16, flags: DIFlagTypePassByValue, elements: !1457, templateParams: !1476, identifier: "_ZTS13ap_fixed_baseILi9ELi9ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1457 = !{!1458, !1472, !1473, !1474, !1475}
!1458 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1456, baseType: !1459)
!1459 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<9, false>", file: !1299, line: 523, size: 16, flags: DIFlagTypePassByValue, elements: !1460, templateParams: !1470, identifier: "_ZTS8ssdm_intILi9ELb0EE")
!1460 = !{!1461, !1463, !1467}
!1461 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1459, file: !1299, line: 525, baseType: !1462, size: 9, align: 16)
!1462 = !DIBasicType(name: "uint9", size: 9, encoding: DW_ATE_unsigned)
!1463 = !DISubprogram(name: "ssdm_int", scope: !1459, file: !1299, line: 526, type: !1464, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1464 = !DISubroutineType(types: !1465)
!1465 = !{null, !1466}
!1466 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1459, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1467 = !DISubprogram(name: "ssdm_int", scope: !1459, file: !1299, line: 527, type: !1468, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1468 = !DISubroutineType(types: !1469)
!1469 = !{null, !1466, !1462}
!1470 = !{!1471, !1311}
!1471 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 9)
!1472 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1456, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 9)
!1473 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1456, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 9)
!1474 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1456, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1475 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1456, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1476 = !{!1477, !1478, !1311, !1453, !1479, !1455}
!1477 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 9)
!1478 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 9)
!1479 = !DITemplateValueParameter(name: "_AP_O", type: !1283, value: i32 0)
!1480 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<8, 8, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 8, flags: DIFlagTypePassByValue, elements: !1481, templateParams: !1498, identifier: "_ZTS13ap_fixed_baseILi8ELi8ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1481 = !{!1482, !1494, !1495, !1496, !1497}
!1482 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1480, baseType: !1483)
!1483 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<8, false>", file: !1299, line: 523, size: 8, flags: DIFlagTypePassByValue, elements: !1484, templateParams: !1493, identifier: "_ZTS8ssdm_intILi8ELb0EE")
!1484 = !{!1485, !1486, !1490}
!1485 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1483, file: !1299, line: 525, baseType: !100, size: 8)
!1486 = !DISubprogram(name: "ssdm_int", scope: !1483, file: !1299, line: 526, type: !1487, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1487 = !DISubroutineType(types: !1488)
!1488 = !{null, !1489}
!1489 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1483, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1490 = !DISubprogram(name: "ssdm_int", scope: !1483, file: !1299, line: 527, type: !1491, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1491 = !DISubroutineType(types: !1492)
!1492 = !{null, !1489, !100}
!1493 = !{!1411, !1311}
!1494 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1480, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 8)
!1495 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1480, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 8)
!1496 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1480, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1497 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1480, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1498 = !{!1499, !1500, !1311, !1453, !1479, !1455}
!1499 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 8)
!1500 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 8)
!1501 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1502, file: !1295, line: 143, baseType: !1408)
!1502 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<8, true>", file: !1295, line: 121, size: 8, flags: DIFlagTypePassByValue, elements: !1503, templateParams: !1524, identifier: "_ZTS11ap_int_baseILi8ELb1EE")
!1503 = !{!1504, !1515, !1516, !1517}
!1504 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1502, baseType: !1505)
!1505 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<8, true>", file: !1299, line: 515, size: 8, flags: DIFlagTypePassByValue, elements: !1506, templateParams: !1410, identifier: "_ZTS8ssdm_intILi8ELb1EE")
!1506 = !{!1507, !1508, !1512}
!1507 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1505, file: !1299, line: 517, baseType: !12, size: 8)
!1508 = !DISubprogram(name: "ssdm_int", scope: !1505, file: !1299, line: 518, type: !1509, scopeLine: 518, flags: DIFlagPrototyped, spFlags: 0)
!1509 = !DISubroutineType(types: !1510)
!1510 = !{null, !1511}
!1511 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1505, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1512 = !DISubprogram(name: "ssdm_int", scope: !1505, file: !1299, line: 519, type: !1513, scopeLine: 519, flags: DIFlagPrototyped, spFlags: 0)
!1513 = !DISubroutineType(types: !1514)
!1514 = !{null, !1511, !12}
!1515 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1502, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 8)
!1516 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1502, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 true)
!1517 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi8ELb1EEaSERKS0_", scope: !1502, file: !1295, line: 476, type: !1518, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1518 = !DISubroutineType(types: !1519)
!1519 = !{!1520, !1521, !1522}
!1520 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1502, size: 64)
!1521 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1502, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1522 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1523, size: 64)
!1523 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1502)
!1524 = !{!1499, !1368}
!1525 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<17, 17, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !1526, templateParams: !1545, identifier: "_ZTS13ap_fixed_baseILi17ELi17ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1526 = !{!1527, !1541, !1542, !1543, !1544}
!1527 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1525, baseType: !1528)
!1528 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<17, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !1529, templateParams: !1539, identifier: "_ZTS8ssdm_intILi17ELb0EE")
!1529 = !{!1530, !1532, !1536}
!1530 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1528, file: !1299, line: 525, baseType: !1531, size: 17, align: 32)
!1531 = !DIBasicType(name: "uint17", size: 17, encoding: DW_ATE_unsigned)
!1532 = !DISubprogram(name: "ssdm_int", scope: !1528, file: !1299, line: 526, type: !1533, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1533 = !DISubroutineType(types: !1534)
!1534 = !{null, !1535}
!1535 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1528, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1536 = !DISubprogram(name: "ssdm_int", scope: !1528, file: !1299, line: 527, type: !1537, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1537 = !DISubroutineType(types: !1538)
!1538 = !{null, !1535, !1531}
!1539 = !{!1540, !1311}
!1540 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 17)
!1541 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1525, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 17)
!1542 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1525, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 17)
!1543 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1525, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1544 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1525, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1545 = !{!1546, !1547, !1311, !1453, !1479, !1455}
!1546 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 17)
!1547 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 17)
!1548 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<16, 16, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 16, flags: DIFlagTypePassByValue, elements: !1549, templateParams: !1555, identifier: "_ZTS13ap_fixed_baseILi16ELi16ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1549 = !{!1550, !1551, !1552, !1553, !1554}
!1550 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1548, baseType: !1298)
!1551 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1548, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 16)
!1552 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1548, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 16)
!1553 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1548, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1554 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1548, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1555 = !{!1323, !1556, !1311, !1453, !1479, !1455}
!1556 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 16)
!1557 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1558, file: !1295, line: 143, baseType: !1408)
!1558 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<16, true>", file: !1295, line: 121, size: 16, flags: DIFlagTypePassByValue, elements: !1559, templateParams: !1581, identifier: "_ZTS11ap_int_baseILi16ELb1EE")
!1559 = !{!1560, !1572, !1573, !1574}
!1560 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1558, baseType: !1561)
!1561 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<16, true>", file: !1299, line: 515, size: 16, flags: DIFlagTypePassByValue, elements: !1562, templateParams: !1571, identifier: "_ZTS8ssdm_intILi16ELb1EE")
!1562 = !{!1563, !1564, !1568}
!1563 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1561, file: !1299, line: 517, baseType: !180, size: 16)
!1564 = !DISubprogram(name: "ssdm_int", scope: !1561, file: !1299, line: 518, type: !1565, scopeLine: 518, flags: DIFlagPrototyped, spFlags: 0)
!1565 = !DISubroutineType(types: !1566)
!1566 = !{null, !1567}
!1567 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1561, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1568 = !DISubprogram(name: "ssdm_int", scope: !1561, file: !1299, line: 519, type: !1569, scopeLine: 519, flags: DIFlagPrototyped, spFlags: 0)
!1569 = !DISubroutineType(types: !1570)
!1570 = !{null, !1567, !180}
!1571 = !{!1310, !1368}
!1572 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1558, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 16)
!1573 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1558, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 true)
!1574 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi16ELb1EEaSERKS0_", scope: !1558, file: !1295, line: 476, type: !1575, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1575 = !DISubroutineType(types: !1576)
!1576 = !{!1577, !1578, !1579}
!1577 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1558, size: 64)
!1578 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1558, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1579 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1580, size: 64)
!1580 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1558)
!1581 = !{!1323, !1368}
!1582 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<33, 33, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 64, flags: DIFlagTypePassByValue, elements: !1583, templateParams: !1601, identifier: "_ZTS13ap_fixed_baseILi33ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1583 = !{!1584, !1597, !1598, !1599, !1600}
!1584 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1582, baseType: !1585)
!1585 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<33, false>", file: !1299, line: 523, size: 64, flags: DIFlagTypePassByValue, elements: !1586, templateParams: !1596, identifier: "_ZTS8ssdm_intILi33ELb0EE")
!1586 = !{!1587, !1589, !1593}
!1587 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1585, file: !1299, line: 525, baseType: !1588, size: 33, align: 64)
!1588 = !DIBasicType(name: "uint33", size: 33, encoding: DW_ATE_unsigned)
!1589 = !DISubprogram(name: "ssdm_int", scope: !1585, file: !1299, line: 526, type: !1590, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1590 = !DISubroutineType(types: !1591)
!1591 = !{null, !1592}
!1592 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1585, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1593 = !DISubprogram(name: "ssdm_int", scope: !1585, file: !1299, line: 527, type: !1594, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1594 = !DISubroutineType(types: !1595)
!1595 = !{null, !1592, !1588}
!1596 = !{!1396, !1311}
!1597 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1582, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 33)
!1598 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1582, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 33)
!1599 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1582, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1600 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1582, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1601 = !{!1407, !1602, !1311, !1453, !1479, !1455}
!1602 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 33)
!1603 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<32, 32, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !1604, templateParams: !1621, identifier: "_ZTS13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1604 = !{!1605, !1617, !1618, !1619, !1620}
!1605 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1603, baseType: !1606)
!1606 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<32, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !1607, templateParams: !1616, identifier: "_ZTS8ssdm_intILi32ELb0EE")
!1607 = !{!1608, !1609, !1613}
!1608 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1606, file: !1299, line: 525, baseType: !103, size: 32)
!1609 = !DISubprogram(name: "ssdm_int", scope: !1606, file: !1299, line: 526, type: !1610, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1610 = !DISubroutineType(types: !1611)
!1611 = !{null, !1612}
!1612 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1606, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1613 = !DISubprogram(name: "ssdm_int", scope: !1606, file: !1299, line: 527, type: !1614, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1614 = !DISubroutineType(types: !1615)
!1615 = !{null, !1612, !103}
!1616 = !{!1367, !1311}
!1617 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1603, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1618 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1603, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1619 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1603, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1620 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1603, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1621 = !{!1379, !1452, !1311, !1453, !1479, !1455}
!1622 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1353, file: !1295, line: 143, baseType: !1408)
!1623 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<65, 65, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 128, flags: DIFlagTypePassByValue, elements: !1624, templateParams: !1643, identifier: "_ZTS13ap_fixed_baseILi65ELi65ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1624 = !{!1625, !1639, !1640, !1641, !1642}
!1625 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1623, baseType: !1626)
!1626 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<65, false>", file: !1299, line: 523, size: 128, flags: DIFlagTypePassByValue, elements: !1627, templateParams: !1637, identifier: "_ZTS8ssdm_intILi65ELb0EE")
!1627 = !{!1628, !1630, !1634}
!1628 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1626, file: !1299, line: 525, baseType: !1629, size: 65, align: 128)
!1629 = !DIBasicType(name: "uint65", size: 65, encoding: DW_ATE_unsigned)
!1630 = !DISubprogram(name: "ssdm_int", scope: !1626, file: !1299, line: 526, type: !1631, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1631 = !DISubroutineType(types: !1632)
!1632 = !{null, !1633}
!1633 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1626, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1634 = !DISubprogram(name: "ssdm_int", scope: !1626, file: !1299, line: 527, type: !1635, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1635 = !DISubroutineType(types: !1636)
!1636 = !{null, !1633, !1629}
!1637 = !{!1638, !1311}
!1638 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 65)
!1639 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1623, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 65)
!1640 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1623, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 65)
!1641 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1623, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1642 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1623, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1643 = !{!1644, !1645, !1311, !1453, !1479, !1455}
!1644 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 65)
!1645 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 65)
!1646 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<64, 64, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 64, flags: DIFlagTypePassByValue, elements: !1647, templateParams: !1665, identifier: "_ZTS13ap_fixed_baseILi64ELi64ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1647 = !{!1648, !1661, !1662, !1663, !1664}
!1648 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1646, baseType: !1649)
!1649 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<64, false>", file: !1299, line: 523, size: 64, flags: DIFlagTypePassByValue, elements: !1650, templateParams: !1659, identifier: "_ZTS8ssdm_intILi64ELb0EE")
!1650 = !{!1651, !1652, !1656}
!1651 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1649, file: !1299, line: 525, baseType: !1324, size: 64)
!1652 = !DISubprogram(name: "ssdm_int", scope: !1649, file: !1299, line: 526, type: !1653, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1653 = !DISubroutineType(types: !1654)
!1654 = !{null, !1655}
!1655 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1649, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1656 = !DISubprogram(name: "ssdm_int", scope: !1649, file: !1299, line: 527, type: !1657, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1657 = !DISubroutineType(types: !1658)
!1658 = !{null, !1655, !1324}
!1659 = !{!1660, !1311}
!1660 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 64)
!1661 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1646, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 64)
!1662 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1646, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 64)
!1663 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1646, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1664 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1646, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1665 = !{!1666, !1667, !1311, !1453, !1479, !1455}
!1666 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 64)
!1667 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 64)
!1668 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1669, file: !1295, line: 143, baseType: !1408)
!1669 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<64, true>", file: !1295, line: 121, size: 64, flags: DIFlagTypePassByValue, elements: !1670, templateParams: !1693, identifier: "_ZTS11ap_int_baseILi64ELb1EE")
!1670 = !{!1671, !1684, !1685, !1686}
!1671 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1669, baseType: !1672)
!1672 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<64, true>", file: !1299, line: 515, size: 64, flags: DIFlagTypePassByValue, elements: !1673, templateParams: !1683, identifier: "_ZTS8ssdm_intILi64ELb1EE")
!1673 = !{!1674, !1676, !1680}
!1674 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1672, file: !1299, line: 517, baseType: !1675, size: 64)
!1675 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!1676 = !DISubprogram(name: "ssdm_int", scope: !1672, file: !1299, line: 518, type: !1677, scopeLine: 518, flags: DIFlagPrototyped, spFlags: 0)
!1677 = !DISubroutineType(types: !1678)
!1678 = !{null, !1679}
!1679 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1672, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1680 = !DISubprogram(name: "ssdm_int", scope: !1672, file: !1299, line: 519, type: !1681, scopeLine: 519, flags: DIFlagPrototyped, spFlags: 0)
!1681 = !DISubroutineType(types: !1682)
!1682 = !{null, !1679, !1675}
!1683 = !{!1660, !1368}
!1684 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1669, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 64)
!1685 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1669, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 true)
!1686 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi64ELb1EEaSERKS0_", scope: !1669, file: !1295, line: 476, type: !1687, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1687 = !DISubroutineType(types: !1688)
!1688 = !{!1689, !1690, !1691}
!1689 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1669, size: 64)
!1690 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1669, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1691 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1692, size: 64)
!1692 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1669)
!1693 = !{!1666, !1368}
!1694 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1695)
!1695 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<32, false>", file: !1295, line: 121, size: 32, flags: DIFlagTypePassByValue, elements: !1696, templateParams: !1706, identifier: "_ZTS11ap_int_baseILi32ELb0EE")
!1696 = !{!1697, !1698, !1699, !1700}
!1697 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1695, baseType: !1606)
!1698 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1695, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!1699 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1695, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1700 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi32ELb0EEaSERKS0_", scope: !1695, file: !1295, line: 476, type: !1701, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1701 = !DISubroutineType(types: !1702)
!1702 = !{!1703, !1704, !1705}
!1703 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1695, size: 64)
!1704 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1695, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1705 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1694, size: 64)
!1706 = !{!1379, !1311}
!1707 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1708, size: 64)
!1708 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<23, false>", file: !1295, line: 121, size: 32, flags: DIFlagTypePassByValue, elements: !1709, templateParams: !1733, identifier: "_ZTS11ap_int_baseILi23ELb0EE")
!1709 = !{!1710, !1724, !1725, !1726}
!1710 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1708, baseType: !1711)
!1711 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<23, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !1712, templateParams: !1722, identifier: "_ZTS8ssdm_intILi23ELb0EE")
!1712 = !{!1713, !1715, !1719}
!1713 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1711, file: !1299, line: 525, baseType: !1714, size: 23, align: 32)
!1714 = !DIBasicType(name: "uint23", size: 23, encoding: DW_ATE_unsigned)
!1715 = !DISubprogram(name: "ssdm_int", scope: !1711, file: !1299, line: 526, type: !1716, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1716 = !DISubroutineType(types: !1717)
!1717 = !{null, !1718}
!1718 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1711, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1719 = !DISubprogram(name: "ssdm_int", scope: !1711, file: !1299, line: 527, type: !1720, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1720 = !DISubroutineType(types: !1721)
!1721 = !{null, !1718, !1714}
!1722 = !{!1723, !1311}
!1723 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 23)
!1724 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1708, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 23)
!1725 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1708, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1726 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi23ELb0EEaSERKS0_", scope: !1708, file: !1295, line: 476, type: !1727, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1727 = !DISubroutineType(types: !1728)
!1728 = !{!1729, !1730, !1731}
!1729 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1708, size: 64)
!1730 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1708, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1731 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1732, size: 64)
!1732 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1708)
!1733 = !{!1734, !1311}
!1734 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 23)
!1735 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1736)
!1736 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<64, false>", file: !1295, line: 121, size: 64, flags: DIFlagTypePassByValue, elements: !1737, templateParams: !1747, identifier: "_ZTS11ap_int_baseILi64ELb0EE")
!1737 = !{!1738, !1739, !1740, !1741}
!1738 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1736, baseType: !1649)
!1739 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1736, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 64)
!1740 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1736, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1741 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi64ELb0EEaSERKS0_", scope: !1736, file: !1295, line: 476, type: !1742, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1742 = !DISubroutineType(types: !1743)
!1743 = !{!1744, !1745, !1746}
!1744 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1736, size: 64)
!1745 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1736, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1746 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1735, size: 64)
!1747 = !{!1666, !1311}
!1748 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1749, size: 64)
!1749 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<52, false>", file: !1295, line: 121, size: 64, flags: DIFlagTypePassByValue, elements: !1750, templateParams: !1774, identifier: "_ZTS11ap_int_baseILi52ELb0EE")
!1750 = !{!1751, !1765, !1766, !1767}
!1751 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1749, baseType: !1752)
!1752 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<52, false>", file: !1299, line: 523, size: 64, flags: DIFlagTypePassByValue, elements: !1753, templateParams: !1763, identifier: "_ZTS8ssdm_intILi52ELb0EE")
!1753 = !{!1754, !1756, !1760}
!1754 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1752, file: !1299, line: 525, baseType: !1755, size: 52, align: 64)
!1755 = !DIBasicType(name: "uint52", size: 52, encoding: DW_ATE_unsigned)
!1756 = !DISubprogram(name: "ssdm_int", scope: !1752, file: !1299, line: 526, type: !1757, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1757 = !DISubroutineType(types: !1758)
!1758 = !{null, !1759}
!1759 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1752, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1760 = !DISubprogram(name: "ssdm_int", scope: !1752, file: !1299, line: 527, type: !1761, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1761 = !DISubroutineType(types: !1762)
!1762 = !{null, !1759, !1755}
!1763 = !{!1764, !1311}
!1764 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 52)
!1765 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1749, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 52)
!1766 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1749, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1767 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi52ELb0EEaSERKS0_", scope: !1749, file: !1295, line: 476, type: !1768, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1768 = !DISubroutineType(types: !1769)
!1769 = !{!1770, !1771, !1772}
!1770 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1749, size: 64)
!1771 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1749, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1772 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1773, size: 64)
!1773 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1749)
!1774 = !{!1775, !1311}
!1775 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 52)
!1776 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<10, 10, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 16, flags: DIFlagTypePassByValue, elements: !1777, templateParams: !1783, identifier: "_ZTS13ap_fixed_baseILi10ELi10ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1777 = !{!1778, !1779, !1780, !1781, !1782}
!1778 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1776, baseType: !1329)
!1779 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1776, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 10)
!1780 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1776, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 10)
!1781 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1776, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1782 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1776, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1783 = !{!1352, !1784, !1311, !1453, !1479, !1455}
!1784 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 10)
!1785 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1786, file: !1295, line: 143, baseType: !1799)
!1786 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<8, false>", file: !1295, line: 121, size: 8, flags: DIFlagTypePassByValue, elements: !1787, templateParams: !1798, identifier: "_ZTS11ap_int_baseILi8ELb0EE")
!1787 = !{!1788, !1789, !1790, !1791}
!1788 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1786, baseType: !1483)
!1789 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1786, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 8)
!1790 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1786, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1791 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi8ELb0EEaSERKS0_", scope: !1786, file: !1295, line: 476, type: !1792, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1792 = !DISubroutineType(types: !1793)
!1793 = !{!1794, !1795, !1796}
!1794 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1786, size: 64)
!1795 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1786, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1796 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1797, size: 64)
!1797 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1786)
!1798 = !{!1499, !1311}
!1799 = !DIDerivedType(tag: DW_TAG_typedef, name: "Type", scope: !1800, file: !1295, line: 64, baseType: !1291)
!1800 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "retval<8, false>", file: !1295, line: 63, size: 8, flags: DIFlagTypePassByValue, elements: !1053, templateParams: !1493, identifier: "_ZTS6retvalILi8ELb0EE")
!1801 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<18, 18, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !1802, templateParams: !1821, identifier: "_ZTS13ap_fixed_baseILi18ELi18ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1802 = !{!1803, !1817, !1818, !1819, !1820}
!1803 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1801, baseType: !1804)
!1804 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<18, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !1805, templateParams: !1815, identifier: "_ZTS8ssdm_intILi18ELb0EE")
!1805 = !{!1806, !1808, !1812}
!1806 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1804, file: !1299, line: 525, baseType: !1807, size: 18, align: 32)
!1807 = !DIBasicType(name: "uint18", size: 18, encoding: DW_ATE_unsigned)
!1808 = !DISubprogram(name: "ssdm_int", scope: !1804, file: !1299, line: 526, type: !1809, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1809 = !DISubroutineType(types: !1810)
!1810 = !{null, !1811}
!1811 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1804, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1812 = !DISubprogram(name: "ssdm_int", scope: !1804, file: !1299, line: 527, type: !1813, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1813 = !DISubroutineType(types: !1814)
!1814 = !{null, !1811, !1807}
!1815 = !{!1816, !1311}
!1816 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 18)
!1817 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1801, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 18)
!1818 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1801, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 18)
!1819 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1801, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1820 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1801, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1821 = !{!1822, !1823, !1311, !1453, !1479, !1455}
!1822 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 18)
!1823 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 18)
!1824 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1294, file: !1295, line: 143, baseType: !1799)
!1825 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<34, 34, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 64, flags: DIFlagTypePassByValue, elements: !1826, templateParams: !1845, identifier: "_ZTS13ap_fixed_baseILi34ELi34ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1826 = !{!1827, !1841, !1842, !1843, !1844}
!1827 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1825, baseType: !1828)
!1828 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<34, false>", file: !1299, line: 523, size: 64, flags: DIFlagTypePassByValue, elements: !1829, templateParams: !1839, identifier: "_ZTS8ssdm_intILi34ELb0EE")
!1829 = !{!1830, !1832, !1836}
!1830 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1828, file: !1299, line: 525, baseType: !1831, size: 34, align: 64)
!1831 = !DIBasicType(name: "uint34", size: 34, encoding: DW_ATE_unsigned)
!1832 = !DISubprogram(name: "ssdm_int", scope: !1828, file: !1299, line: 526, type: !1833, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1833 = !DISubroutineType(types: !1834)
!1834 = !{null, !1835}
!1835 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1828, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1836 = !DISubprogram(name: "ssdm_int", scope: !1828, file: !1299, line: 527, type: !1837, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1837 = !DISubroutineType(types: !1838)
!1838 = !{null, !1835, !1831}
!1839 = !{!1840, !1311}
!1840 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 34)
!1841 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1825, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 34)
!1842 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1825, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 34)
!1843 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1825, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1844 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1825, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1845 = !{!1846, !1847, !1311, !1453, !1479, !1455}
!1846 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 34)
!1847 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 34)
!1848 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1695, file: !1295, line: 143, baseType: !1799)
!1849 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<66, 66, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 128, flags: DIFlagTypePassByValue, elements: !1850, templateParams: !1869, identifier: "_ZTS13ap_fixed_baseILi66ELi66ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!1850 = !{!1851, !1865, !1866, !1867, !1868}
!1851 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1849, baseType: !1852)
!1852 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<66, false>", file: !1299, line: 523, size: 128, flags: DIFlagTypePassByValue, elements: !1853, templateParams: !1863, identifier: "_ZTS8ssdm_intILi66ELb0EE")
!1853 = !{!1854, !1856, !1860}
!1854 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1852, file: !1299, line: 525, baseType: !1855, size: 66, align: 128)
!1855 = !DIBasicType(name: "uint66", size: 66, encoding: DW_ATE_unsigned)
!1856 = !DISubprogram(name: "ssdm_int", scope: !1852, file: !1299, line: 526, type: !1857, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1857 = !DISubroutineType(types: !1858)
!1858 = !{null, !1859}
!1859 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1852, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1860 = !DISubprogram(name: "ssdm_int", scope: !1852, file: !1299, line: 527, type: !1861, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1861 = !DISubroutineType(types: !1862)
!1862 = !{null, !1859, !1855}
!1863 = !{!1864, !1311}
!1864 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 66)
!1865 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1849, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 66)
!1866 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !1849, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 66)
!1867 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !1849, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!1868 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !1849, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!1869 = !{!1870, !1871, !1311, !1453, !1479, !1455}
!1870 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 66)
!1871 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 66)
!1872 = !DIDerivedType(tag: DW_TAG_typedef, name: "RetType", scope: !1736, file: !1295, line: 143, baseType: !1799)
!1873 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "fp_struct<__fp16>", file: !1874, line: 609, size: 32, flags: DIFlagTypePassByValue, elements: !1875, templateParams: !2075, identifier: "_ZTS9fp_structIDhE")
!1874 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/src/hls/utils/x_hls_utils.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1875 = !{!1876, !1877, !1878, !1879, !1880, !1881, !1905, !1953, !1974, !1978, !1981, !2004, !2011, !2016, !2019, !2025, !2028, !2066, !2069, !2070, !2071, !2074}
!1876 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_INFNAN", scope: !1873, file: !1874, line: 612, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 31)
!1877 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BIAS", scope: !1873, file: !1874, line: 613, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 15)
!1878 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BITS", scope: !1873, file: !1874, line: 614, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 5)
!1879 = !DIDerivedType(tag: DW_TAG_member, name: "SIG_BITS", scope: !1873, file: !1874, line: 615, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 10)
!1880 = !DIDerivedType(tag: DW_TAG_member, name: "BITS", scope: !1873, file: !1874, line: 616, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 16)
!1881 = !DIDerivedType(tag: DW_TAG_member, name: "sign", scope: !1873, file: !1874, line: 702, baseType: !1882, size: 8, flags: DIFlagPublic)
!1882 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<1>", file: !1883, line: 181, size: 8, flags: DIFlagTypePassByValue, elements: !1884, templateParams: !1904, identifier: "_ZTS7ap_uintILi1EE")
!1883 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/ap_int.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!1884 = !{!1885, !1886, !1890, !1893, !1898}
!1885 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1882, baseType: !1414)
!1886 = !DISubprogram(name: "ap_uint", scope: !1882, file: !1883, line: 296, type: !1887, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!1887 = !DISubroutineType(types: !1888)
!1888 = !{null, !1889, !556}
!1889 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1882, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1890 = !DISubprogram(name: "ap_uint", scope: !1882, file: !1883, line: 297, type: !1891, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!1891 = !DISubroutineType(types: !1892)
!1892 = !{null, !1889, !29}
!1893 = !DISubprogram(name: "ap_uint", scope: !1882, file: !1883, line: 298, type: !1894, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!1894 = !DISubroutineType(types: !1895)
!1895 = !{null, !1889, !1896}
!1896 = !DIDerivedType(tag: DW_TAG_typedef, name: "half", file: !1299, line: 620, baseType: !1897)
!1897 = !DIBasicType(name: "__fp16", size: 16, encoding: DW_ATE_float)
!1898 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi1EEaSERKS0_", scope: !1882, file: !1883, line: 309, type: !1899, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!1899 = !DISubroutineType(types: !1900)
!1900 = !{!1901, !1889, !1902}
!1901 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1882, size: 64)
!1902 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1903, size: 64)
!1903 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1882)
!1904 = !{!1440}
!1905 = !DIDerivedType(tag: DW_TAG_member, name: "exp", scope: !1873, file: !1874, line: 703, baseType: !1906, size: 8, offset: 8, flags: DIFlagPublic)
!1906 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<5>", file: !1883, line: 181, size: 8, flags: DIFlagTypePassByValue, elements: !1907, templateParams: !1952, identifier: "_ZTS7ap_uintILi5EE")
!1907 = !{!1908, !1936, !1940, !1943, !1946}
!1908 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1906, baseType: !1909)
!1909 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<5, false>", file: !1295, line: 121, size: 8, flags: DIFlagTypePassByValue, elements: !1910, templateParams: !1934, identifier: "_ZTS11ap_int_baseILi5ELb0EE")
!1910 = !{!1911, !1925, !1926, !1927}
!1911 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1909, baseType: !1912)
!1912 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<5, false>", file: !1299, line: 523, size: 8, flags: DIFlagTypePassByValue, elements: !1913, templateParams: !1923, identifier: "_ZTS8ssdm_intILi5ELb0EE")
!1913 = !{!1914, !1916, !1920}
!1914 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !1912, file: !1299, line: 525, baseType: !1915, size: 5, align: 8)
!1915 = !DIBasicType(name: "uint5", size: 5, encoding: DW_ATE_unsigned)
!1916 = !DISubprogram(name: "ssdm_int", scope: !1912, file: !1299, line: 526, type: !1917, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!1917 = !DISubroutineType(types: !1918)
!1918 = !{null, !1919}
!1919 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1912, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1920 = !DISubprogram(name: "ssdm_int", scope: !1912, file: !1299, line: 527, type: !1921, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!1921 = !DISubroutineType(types: !1922)
!1922 = !{null, !1919, !1915}
!1923 = !{!1924, !1311}
!1924 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 5)
!1925 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !1909, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 5)
!1926 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !1909, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!1927 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi5ELb0EEaSERKS0_", scope: !1909, file: !1295, line: 476, type: !1928, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!1928 = !DISubroutineType(types: !1929)
!1929 = !{!1930, !1931, !1932}
!1930 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1909, size: 64)
!1931 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1909, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1932 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1933, size: 64)
!1933 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1909)
!1934 = !{!1935, !1311}
!1935 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 5)
!1936 = !DISubprogram(name: "ap_uint", scope: !1906, file: !1883, line: 296, type: !1937, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!1937 = !DISubroutineType(types: !1938)
!1938 = !{null, !1939, !556}
!1939 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1906, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1940 = !DISubprogram(name: "ap_uint", scope: !1906, file: !1883, line: 297, type: !1941, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!1941 = !DISubroutineType(types: !1942)
!1942 = !{null, !1939, !29}
!1943 = !DISubprogram(name: "ap_uint", scope: !1906, file: !1883, line: 298, type: !1944, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!1944 = !DISubroutineType(types: !1945)
!1945 = !{null, !1939, !1896}
!1946 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi5EEaSERKS0_", scope: !1906, file: !1883, line: 309, type: !1947, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!1947 = !DISubroutineType(types: !1948)
!1948 = !{!1949, !1939, !1950}
!1949 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1906, size: 64)
!1950 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1951, size: 64)
!1951 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1906)
!1952 = !{!1935}
!1953 = !DIDerivedType(tag: DW_TAG_member, name: "sig", scope: !1873, file: !1874, line: 704, baseType: !1954, size: 16, offset: 16, flags: DIFlagPublic)
!1954 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<10>", file: !1883, line: 181, size: 16, flags: DIFlagTypePassByValue, elements: !1955, templateParams: !1973, identifier: "_ZTS7ap_uintILi10EE")
!1955 = !{!1956, !1957, !1961, !1964, !1967}
!1956 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1954, baseType: !1326)
!1957 = !DISubprogram(name: "ap_uint", scope: !1954, file: !1883, line: 296, type: !1958, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!1958 = !DISubroutineType(types: !1959)
!1959 = !{null, !1960, !556}
!1960 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1954, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1961 = !DISubprogram(name: "ap_uint", scope: !1954, file: !1883, line: 297, type: !1962, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!1962 = !DISubroutineType(types: !1963)
!1963 = !{null, !1960, !29}
!1964 = !DISubprogram(name: "ap_uint", scope: !1954, file: !1883, line: 298, type: !1965, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!1965 = !DISubroutineType(types: !1966)
!1966 = !{null, !1960, !1896}
!1967 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi10EEaSERKS0_", scope: !1954, file: !1883, line: 309, type: !1968, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!1968 = !DISubroutineType(types: !1969)
!1969 = !{!1970, !1960, !1971}
!1970 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1954, size: 64)
!1971 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1972, size: 64)
!1972 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1954)
!1973 = !{!1352}
!1974 = !DISubprogram(name: "fp_struct", scope: !1873, file: !1874, line: 618, type: !1975, scopeLine: 618, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!1975 = !DISubroutineType(types: !1976)
!1976 = !{null, !1977}
!1977 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1873, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1978 = !DISubprogram(name: "fp_struct", scope: !1873, file: !1874, line: 620, type: !1979, scopeLine: 620, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!1979 = !DISubroutineType(types: !1980)
!1980 = !{null, !1977, !1896}
!1981 = !DISubprogram(name: "fp_struct", scope: !1873, file: !1874, line: 632, type: !1982, scopeLine: 632, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!1982 = !DISubroutineType(types: !1983)
!1983 = !{null, !1977, !1984}
!1984 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<16>", file: !1883, line: 181, size: 16, flags: DIFlagTypePassByValue, elements: !1985, templateParams: !2003, identifier: "_ZTS7ap_uintILi16EE")
!1985 = !{!1986, !1987, !1991, !1994, !1997}
!1986 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !1984, baseType: !1294)
!1987 = !DISubprogram(name: "ap_uint", scope: !1984, file: !1883, line: 296, type: !1988, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!1988 = !DISubroutineType(types: !1989)
!1989 = !{null, !1990, !556}
!1990 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1984, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!1991 = !DISubprogram(name: "ap_uint", scope: !1984, file: !1883, line: 297, type: !1992, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!1992 = !DISubroutineType(types: !1993)
!1993 = !{null, !1990, !29}
!1994 = !DISubprogram(name: "ap_uint", scope: !1984, file: !1883, line: 298, type: !1995, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!1995 = !DISubroutineType(types: !1996)
!1996 = !{null, !1990, !1896}
!1997 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi16EEaSERKS0_", scope: !1984, file: !1883, line: 309, type: !1998, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!1998 = !DISubroutineType(types: !1999)
!1999 = !{!2000, !1990, !2001}
!2000 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1984, size: 64)
!2001 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2002, size: 64)
!2002 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1984)
!2003 = !{!1323}
!2004 = !DISubprogram(name: "fp_struct", scope: !1873, file: !1874, line: 637, type: !2005, scopeLine: 637, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2005 = !DISubroutineType(types: !2006)
!2006 = !{null, !1977, !2007}
!2007 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !2008, line: 25, baseType: !2009)
!2008 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2009 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !2010, line: 39, baseType: !22)
!2010 = !DIFile(filename: "/usr/include/bits/types.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2011 = !DISubprogram(name: "data", linkageName: "_ZNK9fp_structIDhE4dataEv", scope: !1873, file: !1874, line: 643, type: !2012, scopeLine: 643, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2012 = !DISubroutineType(types: !2013)
!2013 = !{!1984, !2014}
!2014 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2015, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2015 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !1873)
!2016 = !DISubprogram(name: "expv", linkageName: "_ZNK9fp_structIDhE4expvEv", scope: !1873, file: !1874, line: 650, type: !2017, scopeLine: 650, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2017 = !DISubroutineType(types: !2018)
!2018 = !{!184, !2014}
!2019 = !DISubprogram(name: "to_int", linkageName: "_ZNK9fp_structIDhE6to_intEv", scope: !1873, file: !1874, line: 653, type: !2020, scopeLine: 653, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2020 = !DISubroutineType(types: !2021)
!2021 = !{!2022, !2014}
!2022 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !2023, line: 25, baseType: !2024)
!2023 = !DIFile(filename: "/usr/include/bits/stdint-intn.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2024 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int16_t", file: !2010, line: 38, baseType: !180)
!2025 = !DISubprogram(name: "to_half", linkageName: "_ZNK9fp_structIDhE7to_halfEv", scope: !1873, file: !1874, line: 656, type: !2026, scopeLine: 656, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2026 = !DISubroutineType(types: !2027)
!2027 = !{!1896, !2014}
!2028 = !DISubprogram(name: "set_mantissa", linkageName: "_ZN9fp_structIDhE12set_mantissaE9ap_ufixedILi11ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE", scope: !1873, file: !1874, line: 667, type: !2029, scopeLine: 667, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2029 = !DISubroutineType(types: !2030)
!2030 = !{null, !1977, !2031}
!2031 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<11, 1, AP_TRN, AP_WRAP, 0>", file: !2032, line: 191, size: 16, flags: DIFlagTypePassByValue, elements: !2033, templateParams: !2065, identifier: "_ZTS9ap_ufixedILi11ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2032 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/include/header_files/ap_fixed.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2033 = !{!2034, !2058}
!2034 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2031, baseType: !2035)
!2035 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<11, 1, false, AP_TRN, AP_WRAP, 0>", file: !1442, line: 107, size: 16, flags: DIFlagTypePassByValue, elements: !2036, templateParams: !2055, identifier: "_ZTS13ap_fixed_baseILi11ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2036 = !{!2037, !2051, !2052, !2053, !2054}
!2037 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2035, baseType: !2038)
!2038 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<11, false>", file: !1299, line: 523, size: 16, flags: DIFlagTypePassByValue, elements: !2039, templateParams: !2049, identifier: "_ZTS8ssdm_intILi11ELb0EE")
!2039 = !{!2040, !2042, !2046}
!2040 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !2038, file: !1299, line: 525, baseType: !2041, size: 11, align: 16)
!2041 = !DIBasicType(name: "uint11", size: 11, encoding: DW_ATE_unsigned)
!2042 = !DISubprogram(name: "ssdm_int", scope: !2038, file: !1299, line: 526, type: !2043, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!2043 = !DISubroutineType(types: !2044)
!2044 = !{null, !2045}
!2045 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2038, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2046 = !DISubprogram(name: "ssdm_int", scope: !2038, file: !1299, line: 527, type: !2047, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!2047 = !DISubroutineType(types: !2048)
!2048 = !{null, !2045, !2041}
!2049 = !{!2050, !1311}
!2050 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 11)
!2051 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !2035, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 11)
!2052 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !2035, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 1)
!2053 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !2035, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!2054 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !2035, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!2055 = !{!2056, !2057, !1311, !1453, !1454, !1455}
!2056 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 11)
!2057 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 1)
!2058 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi11ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSERKS2_", scope: !2031, file: !2032, line: 321, type: !2059, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!2059 = !DISubroutineType(types: !2060)
!2060 = !{!2061, !2062, !2063}
!2061 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2031, size: 64)
!2062 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2031, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2063 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2064, size: 64)
!2064 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2031)
!2065 = !{!2056, !2057, !1453, !1454, !1455}
!2066 = !DISubprogram(name: "mantissa", linkageName: "_ZNK9fp_structIDhE8mantissaEv", scope: !1873, file: !1874, line: 671, type: !2067, scopeLine: 671, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2067 = !DISubroutineType(types: !2068)
!2068 = !{!2031, !2014}
!2069 = !DISubprogram(name: "to_ieee", linkageName: "_ZNK9fp_structIDhE7to_ieeeEv", scope: !1873, file: !1874, line: 677, type: !2026, scopeLine: 677, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2070 = !DISubprogram(name: "__signbit", linkageName: "_ZNK9fp_structIDhE9__signbitEv", scope: !1873, file: !1874, line: 680, type: !2017, scopeLine: 680, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2071 = !DISubprogram(name: "infinity", linkageName: "_ZN9fp_structIDhE8infinityEv", scope: !1873, file: !1874, line: 684, type: !2072, scopeLine: 684, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2072 = !DISubroutineType(types: !2073)
!2073 = !{!1896}
!2074 = !DISubprogram(name: "minus_infinity", linkageName: "_ZN9fp_structIDhE14minus_infinityEv", scope: !1873, file: !1874, line: 692, type: !2072, scopeLine: 692, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2075 = !{!2076}
!2076 = !DITemplateTypeParameter(name: "T", type: !1897)
!2077 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "fp_struct<float>", file: !1874, line: 272, size: 64, flags: DIFlagTypePassByValue, elements: !2078, templateParams: !2223, identifier: "_ZTS9fp_structIfE")
!2078 = !{!2079, !2080, !2081, !2082, !2083, !2084, !2085, !2106, !2127, !2131, !2134, !2157, !2162, !2167, !2170, !2175, !2178, !2214, !2217, !2218, !2219, !2222}
!2079 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_INFNAN", scope: !2077, file: !1874, line: 275, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 255)
!2080 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BIAS", scope: !2077, file: !1874, line: 276, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 127)
!2081 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BITS", scope: !2077, file: !1874, line: 277, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 8)
!2082 = !DIDerivedType(tag: DW_TAG_member, name: "SIG_BITS", scope: !2077, file: !1874, line: 278, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 23)
!2083 = !DIDerivedType(tag: DW_TAG_member, name: "BITS", scope: !2077, file: !1874, line: 279, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 32)
!2084 = !DIDerivedType(tag: DW_TAG_member, name: "sign", scope: !2077, file: !1874, line: 371, baseType: !1882, size: 8, flags: DIFlagPublic)
!2085 = !DIDerivedType(tag: DW_TAG_member, name: "exp", scope: !2077, file: !1874, line: 372, baseType: !2086, size: 8, offset: 8, flags: DIFlagPublic)
!2086 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<8>", file: !1883, line: 181, size: 8, flags: DIFlagTypePassByValue, elements: !2087, templateParams: !2105, identifier: "_ZTS7ap_uintILi8EE")
!2087 = !{!2088, !2089, !2093, !2096, !2099}
!2088 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2086, baseType: !1786)
!2089 = !DISubprogram(name: "ap_uint", scope: !2086, file: !1883, line: 296, type: !2090, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2090 = !DISubroutineType(types: !2091)
!2091 = !{null, !2092, !556}
!2092 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2086, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2093 = !DISubprogram(name: "ap_uint", scope: !2086, file: !1883, line: 297, type: !2094, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2094 = !DISubroutineType(types: !2095)
!2095 = !{null, !2092, !29}
!2096 = !DISubprogram(name: "ap_uint", scope: !2086, file: !1883, line: 298, type: !2097, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2097 = !DISubroutineType(types: !2098)
!2098 = !{null, !2092, !1896}
!2099 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi8EEaSERKS0_", scope: !2086, file: !1883, line: 309, type: !2100, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2100 = !DISubroutineType(types: !2101)
!2101 = !{!2102, !2092, !2103}
!2102 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2086, size: 64)
!2103 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2104, size: 64)
!2104 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2086)
!2105 = !{!1499}
!2106 = !DIDerivedType(tag: DW_TAG_member, name: "sig", scope: !2077, file: !1874, line: 373, baseType: !2107, size: 32, offset: 32, flags: DIFlagPublic)
!2107 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<23>", file: !1883, line: 181, size: 32, flags: DIFlagTypePassByValue, elements: !2108, templateParams: !2126, identifier: "_ZTS7ap_uintILi23EE")
!2108 = !{!2109, !2110, !2114, !2117, !2120}
!2109 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2107, baseType: !1708)
!2110 = !DISubprogram(name: "ap_uint", scope: !2107, file: !1883, line: 296, type: !2111, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2111 = !DISubroutineType(types: !2112)
!2112 = !{null, !2113, !556}
!2113 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2107, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2114 = !DISubprogram(name: "ap_uint", scope: !2107, file: !1883, line: 297, type: !2115, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2115 = !DISubroutineType(types: !2116)
!2116 = !{null, !2113, !29}
!2117 = !DISubprogram(name: "ap_uint", scope: !2107, file: !1883, line: 298, type: !2118, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2118 = !DISubroutineType(types: !2119)
!2119 = !{null, !2113, !1896}
!2120 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi23EEaSERKS0_", scope: !2107, file: !1883, line: 309, type: !2121, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2121 = !DISubroutineType(types: !2122)
!2122 = !{!2123, !2113, !2124}
!2123 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2107, size: 64)
!2124 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2125, size: 64)
!2125 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2107)
!2126 = !{!1734}
!2127 = !DISubprogram(name: "fp_struct", scope: !2077, file: !1874, line: 281, type: !2128, scopeLine: 281, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2128 = !DISubroutineType(types: !2129)
!2129 = !{null, !2130}
!2130 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2077, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2131 = !DISubprogram(name: "fp_struct", scope: !2077, file: !1874, line: 283, type: !2132, scopeLine: 283, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2132 = !DISubroutineType(types: !2133)
!2133 = !{null, !2130, !29}
!2134 = !DISubprogram(name: "fp_struct", scope: !2077, file: !1874, line: 298, type: !2135, scopeLine: 298, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2135 = !DISubroutineType(types: !2136)
!2136 = !{null, !2130, !2137}
!2137 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<32>", file: !1883, line: 181, size: 32, flags: DIFlagTypePassByValue, elements: !2138, templateParams: !2156, identifier: "_ZTS7ap_uintILi32EE")
!2138 = !{!2139, !2140, !2144, !2147, !2150}
!2139 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2137, baseType: !1695)
!2140 = !DISubprogram(name: "ap_uint", scope: !2137, file: !1883, line: 296, type: !2141, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2141 = !DISubroutineType(types: !2142)
!2142 = !{null, !2143, !556}
!2143 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2137, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2144 = !DISubprogram(name: "ap_uint", scope: !2137, file: !1883, line: 297, type: !2145, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2145 = !DISubroutineType(types: !2146)
!2146 = !{null, !2143, !29}
!2147 = !DISubprogram(name: "ap_uint", scope: !2137, file: !1883, line: 298, type: !2148, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2148 = !DISubroutineType(types: !2149)
!2149 = !{null, !2143, !1896}
!2150 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi32EEaSERKS0_", scope: !2137, file: !1883, line: 309, type: !2151, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2151 = !DISubroutineType(types: !2152)
!2152 = !{!2153, !2143, !2154}
!2153 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2137, size: 64)
!2154 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2155, size: 64)
!2155 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2137)
!2156 = !{!1379}
!2157 = !DISubprogram(name: "fp_struct", scope: !2077, file: !1874, line: 303, type: !2158, scopeLine: 303, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2158 = !DISubroutineType(types: !2159)
!2159 = !{null, !2130, !2160}
!2160 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !2008, line: 26, baseType: !2161)
!2161 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !2010, line: 41, baseType: !103)
!2162 = !DISubprogram(name: "data", linkageName: "_ZNK9fp_structIfE4dataEv", scope: !2077, file: !1874, line: 309, type: !2163, scopeLine: 309, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2163 = !DISubroutineType(types: !2164)
!2164 = !{!2137, !2165}
!2165 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2166, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2166 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2077)
!2167 = !DISubprogram(name: "expv", linkageName: "_ZNK9fp_structIfE4expvEv", scope: !2077, file: !1874, line: 316, type: !2168, scopeLine: 316, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2168 = !DISubroutineType(types: !2169)
!2169 = !{!184, !2165}
!2170 = !DISubprogram(name: "to_int", linkageName: "_ZNK9fp_structIfE6to_intEv", scope: !2077, file: !1874, line: 319, type: !2171, scopeLine: 319, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2171 = !DISubroutineType(types: !2172)
!2172 = !{!2173, !2165}
!2173 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !2023, line: 26, baseType: !2174)
!2174 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int32_t", file: !2010, line: 40, baseType: !184)
!2175 = !DISubprogram(name: "to_float", linkageName: "_ZNK9fp_structIfE8to_floatEv", scope: !2077, file: !1874, line: 322, type: !2176, scopeLine: 322, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2176 = !DISubroutineType(types: !2177)
!2177 = !{!29, !2165}
!2178 = !DISubprogram(name: "set_mantissa", linkageName: "_ZN9fp_structIfE12set_mantissaE9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE", scope: !2077, file: !1874, line: 336, type: !2179, scopeLine: 336, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2179 = !DISubroutineType(types: !2180)
!2180 = !{null, !2130, !2181}
!2181 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<24, 1, AP_TRN, AP_WRAP, 0>", file: !2032, line: 191, size: 32, flags: DIFlagTypePassByValue, elements: !2182, templateParams: !2213, identifier: "_ZTS9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2182 = !{!2183, !2206}
!2183 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2181, baseType: !2184)
!2184 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<24, 1, false, AP_TRN, AP_WRAP, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !2185, templateParams: !2204, identifier: "_ZTS13ap_fixed_baseILi24ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2185 = !{!2186, !2200, !2201, !2202, !2203}
!2186 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2184, baseType: !2187)
!2187 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<24, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !2188, templateParams: !2198, identifier: "_ZTS8ssdm_intILi24ELb0EE")
!2188 = !{!2189, !2191, !2195}
!2189 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !2187, file: !1299, line: 525, baseType: !2190, size: 24, align: 32)
!2190 = !DIBasicType(name: "uint24", size: 24, encoding: DW_ATE_unsigned)
!2191 = !DISubprogram(name: "ssdm_int", scope: !2187, file: !1299, line: 526, type: !2192, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!2192 = !DISubroutineType(types: !2193)
!2193 = !{null, !2194}
!2194 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2187, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2195 = !DISubprogram(name: "ssdm_int", scope: !2187, file: !1299, line: 527, type: !2196, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!2196 = !DISubroutineType(types: !2197)
!2197 = !{null, !2194, !2190}
!2198 = !{!2199, !1311}
!2199 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 24)
!2200 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !2184, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 24)
!2201 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !2184, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 1)
!2202 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !2184, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!2203 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !2184, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!2204 = !{!2205, !2057, !1311, !1453, !1454, !1455}
!2205 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 24)
!2206 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi24ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSERKS2_", scope: !2181, file: !2032, line: 321, type: !2207, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!2207 = !DISubroutineType(types: !2208)
!2208 = !{!2209, !2210, !2211}
!2209 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2181, size: 64)
!2210 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2181, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2211 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2212, size: 64)
!2212 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2181)
!2213 = !{!2205, !2057, !1453, !1454, !1455}
!2214 = !DISubprogram(name: "mantissa", linkageName: "_ZNK9fp_structIfE8mantissaEv", scope: !2077, file: !1874, line: 340, type: !2215, scopeLine: 340, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2215 = !DISubroutineType(types: !2216)
!2216 = !{!2181, !2165}
!2217 = !DISubprogram(name: "to_ieee", linkageName: "_ZNK9fp_structIfE7to_ieeeEv", scope: !2077, file: !1874, line: 346, type: !2176, scopeLine: 346, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2218 = !DISubprogram(name: "__signbit", linkageName: "_ZNK9fp_structIfE9__signbitEv", scope: !2077, file: !1874, line: 349, type: !2168, scopeLine: 349, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2219 = !DISubprogram(name: "infinity", linkageName: "_ZN9fp_structIfE8infinityEv", scope: !2077, file: !1874, line: 353, type: !2220, scopeLine: 353, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2220 = !DISubroutineType(types: !2221)
!2221 = !{!29}
!2222 = !DISubprogram(name: "minus_infinity", linkageName: "_ZN9fp_structIfE14minus_infinityEv", scope: !2077, file: !1874, line: 361, type: !2220, scopeLine: 361, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2223 = !{!2224}
!2224 = !DITemplateTypeParameter(name: "T", type: !29)
!2225 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "fp_struct<double>", file: !1874, line: 445, size: 128, flags: DIFlagTypePassByValue, elements: !2226, templateParams: !2437, identifier: "_ZTS9fp_structIdE")
!2226 = !{!2227, !2228, !2229, !2230, !2231, !2232, !2233, !2267, !2288, !2292, !2295, !2318, !2323, !2328, !2333, !2336, !2386, !2389, !2392, !2428, !2431, !2432, !2433, !2436}
!2227 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_INFNAN", scope: !2225, file: !1874, line: 448, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 2047)
!2228 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BIAS", scope: !2225, file: !1874, line: 449, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 1023)
!2229 = !DIDerivedType(tag: DW_TAG_member, name: "EXP_BITS", scope: !2225, file: !1874, line: 450, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 11)
!2230 = !DIDerivedType(tag: DW_TAG_member, name: "SIG_BITS", scope: !2225, file: !1874, line: 451, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 52)
!2231 = !DIDerivedType(tag: DW_TAG_member, name: "BITS", scope: !2225, file: !1874, line: 452, baseType: !1313, flags: DIFlagPublic | DIFlagStaticMember, extraData: i32 64)
!2232 = !DIDerivedType(tag: DW_TAG_member, name: "sign", scope: !2225, file: !1874, line: 534, baseType: !1882, size: 8, flags: DIFlagPublic)
!2233 = !DIDerivedType(tag: DW_TAG_member, name: "exp", scope: !2225, file: !1874, line: 535, baseType: !2234, size: 16, offset: 16, flags: DIFlagPublic)
!2234 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<11>", file: !1883, line: 181, size: 16, flags: DIFlagTypePassByValue, elements: !2235, templateParams: !2266, identifier: "_ZTS7ap_uintILi11EE")
!2235 = !{!2236, !2250, !2254, !2257, !2260}
!2236 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2234, baseType: !2237)
!2237 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<11, false>", file: !1295, line: 121, size: 16, flags: DIFlagTypePassByValue, elements: !2238, templateParams: !2249, identifier: "_ZTS11ap_int_baseILi11ELb0EE")
!2238 = !{!2239, !2240, !2241, !2242}
!2239 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2237, baseType: !2038)
!2240 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !2237, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 11)
!2241 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !2237, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!2242 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi11ELb0EEaSERKS0_", scope: !2237, file: !1295, line: 476, type: !2243, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!2243 = !DISubroutineType(types: !2244)
!2244 = !{!2245, !2246, !2247}
!2245 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2237, size: 64)
!2246 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2237, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2247 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2248, size: 64)
!2248 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2237)
!2249 = !{!2056, !1311}
!2250 = !DISubprogram(name: "ap_uint", scope: !2234, file: !1883, line: 296, type: !2251, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2251 = !DISubroutineType(types: !2252)
!2252 = !{null, !2253, !556}
!2253 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2234, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2254 = !DISubprogram(name: "ap_uint", scope: !2234, file: !1883, line: 297, type: !2255, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2255 = !DISubroutineType(types: !2256)
!2256 = !{null, !2253, !29}
!2257 = !DISubprogram(name: "ap_uint", scope: !2234, file: !1883, line: 298, type: !2258, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2258 = !DISubroutineType(types: !2259)
!2259 = !{null, !2253, !1896}
!2260 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi11EEaSERKS0_", scope: !2234, file: !1883, line: 309, type: !2261, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2261 = !DISubroutineType(types: !2262)
!2262 = !{!2263, !2253, !2264}
!2263 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2234, size: 64)
!2264 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2265, size: 64)
!2265 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2234)
!2266 = !{!2056}
!2267 = !DIDerivedType(tag: DW_TAG_member, name: "sig", scope: !2225, file: !1874, line: 536, baseType: !2268, size: 64, offset: 64, flags: DIFlagPublic)
!2268 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<52>", file: !1883, line: 181, size: 64, flags: DIFlagTypePassByValue, elements: !2269, templateParams: !2287, identifier: "_ZTS7ap_uintILi52EE")
!2269 = !{!2270, !2271, !2275, !2278, !2281}
!2270 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2268, baseType: !1749)
!2271 = !DISubprogram(name: "ap_uint", scope: !2268, file: !1883, line: 296, type: !2272, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2272 = !DISubroutineType(types: !2273)
!2273 = !{null, !2274, !556}
!2274 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2268, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2275 = !DISubprogram(name: "ap_uint", scope: !2268, file: !1883, line: 297, type: !2276, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2276 = !DISubroutineType(types: !2277)
!2277 = !{null, !2274, !29}
!2278 = !DISubprogram(name: "ap_uint", scope: !2268, file: !1883, line: 298, type: !2279, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2279 = !DISubroutineType(types: !2280)
!2280 = !{null, !2274, !1896}
!2281 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi52EEaSERKS0_", scope: !2268, file: !1883, line: 309, type: !2282, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2282 = !DISubroutineType(types: !2283)
!2283 = !{!2284, !2274, !2285}
!2284 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2268, size: 64)
!2285 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2286, size: 64)
!2286 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2268)
!2287 = !{!1775}
!2288 = !DISubprogram(name: "fp_struct", scope: !2225, file: !1874, line: 454, type: !2289, scopeLine: 454, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2289 = !DISubroutineType(types: !2290)
!2290 = !{null, !2291}
!2291 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2225, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2292 = !DISubprogram(name: "fp_struct", scope: !2225, file: !1874, line: 456, type: !2293, scopeLine: 456, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2293 = !DISubroutineType(types: !2294)
!2294 = !{null, !2291, !556}
!2295 = !DISubprogram(name: "fp_struct", scope: !2225, file: !1874, line: 464, type: !2296, scopeLine: 464, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2296 = !DISubroutineType(types: !2297)
!2297 = !{null, !2291, !2298}
!2298 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<64>", file: !1883, line: 181, size: 64, flags: DIFlagTypePassByValue, elements: !2299, templateParams: !2317, identifier: "_ZTS7ap_uintILi64EE")
!2299 = !{!2300, !2301, !2305, !2308, !2311}
!2300 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2298, baseType: !1736)
!2301 = !DISubprogram(name: "ap_uint", scope: !2298, file: !1883, line: 296, type: !2302, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2302 = !DISubroutineType(types: !2303)
!2303 = !{null, !2304, !556}
!2304 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2298, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2305 = !DISubprogram(name: "ap_uint", scope: !2298, file: !1883, line: 297, type: !2306, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2306 = !DISubroutineType(types: !2307)
!2307 = !{null, !2304, !29}
!2308 = !DISubprogram(name: "ap_uint", scope: !2298, file: !1883, line: 298, type: !2309, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2309 = !DISubroutineType(types: !2310)
!2310 = !{null, !2304, !1896}
!2311 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi64EEaSERKS0_", scope: !2298, file: !1883, line: 309, type: !2312, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2312 = !DISubroutineType(types: !2313)
!2313 = !{!2314, !2304, !2315}
!2314 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2298, size: 64)
!2315 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2316, size: 64)
!2316 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2298)
!2317 = !{!1666}
!2318 = !DISubprogram(name: "fp_struct", scope: !2225, file: !1874, line: 469, type: !2319, scopeLine: 469, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2319 = !DISubroutineType(types: !2320)
!2320 = !{null, !2291, !2321}
!2321 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !2008, line: 27, baseType: !2322)
!2322 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !2010, line: 44, baseType: !1324)
!2323 = !DISubprogram(name: "data", linkageName: "_ZNK9fp_structIdE4dataEv", scope: !2225, file: !1874, line: 475, type: !2324, scopeLine: 475, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2324 = !DISubroutineType(types: !2325)
!2325 = !{!2298, !2326}
!2326 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2327, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2327 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2225)
!2328 = !DISubprogram(name: "to_int", linkageName: "_ZNK9fp_structIdE6to_intEv", scope: !2225, file: !1874, line: 482, type: !2329, scopeLine: 482, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2329 = !DISubroutineType(types: !2330)
!2330 = !{!2331, !2326}
!2331 = !DIDerivedType(tag: DW_TAG_typedef, name: "int64_t", file: !2023, line: 27, baseType: !2332)
!2332 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !2010, line: 43, baseType: !1675)
!2333 = !DISubprogram(name: "expv", linkageName: "_ZNK9fp_structIdE4expvEv", scope: !2225, file: !1874, line: 485, type: !2334, scopeLine: 485, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2334 = !DISubroutineType(types: !2335)
!2335 = !{!184, !2326}
!2336 = !DISubprogram(name: "sig_msb", linkageName: "_ZNK9fp_structIdE7sig_msbEv", scope: !2225, file: !1874, line: 488, type: !2337, scopeLine: 488, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2337 = !DISubroutineType(types: !2338)
!2338 = !{!2339, !2326}
!2339 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_uint<20>", file: !1883, line: 181, size: 32, flags: DIFlagTypePassByValue, elements: !2340, templateParams: !2385, identifier: "_ZTS7ap_uintILi20EE")
!2340 = !{!2341, !2369, !2373, !2376, !2379}
!2341 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2339, baseType: !2342)
!2342 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_int_base<20, false>", file: !1295, line: 121, size: 32, flags: DIFlagTypePassByValue, elements: !2343, templateParams: !2367, identifier: "_ZTS11ap_int_baseILi20ELb0EE")
!2343 = !{!2344, !2358, !2359, !2360}
!2344 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2342, baseType: !2345)
!2345 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<20, false>", file: !1299, line: 523, size: 32, flags: DIFlagTypePassByValue, elements: !2346, templateParams: !2356, identifier: "_ZTS8ssdm_intILi20ELb0EE")
!2346 = !{!2347, !2349, !2353}
!2347 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !2345, file: !1299, line: 525, baseType: !2348, size: 20, align: 32)
!2348 = !DIBasicType(name: "uint20", size: 20, encoding: DW_ATE_unsigned)
!2349 = !DISubprogram(name: "ssdm_int", scope: !2345, file: !1299, line: 526, type: !2350, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!2350 = !DISubroutineType(types: !2351)
!2351 = !{null, !2352}
!2352 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2345, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2353 = !DISubprogram(name: "ssdm_int", scope: !2345, file: !1299, line: 527, type: !2354, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!2354 = !DISubroutineType(types: !2355)
!2355 = !{null, !2352, !2348}
!2356 = !{!2357, !1311}
!2357 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 20)
!2358 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !2342, file: !1295, line: 145, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 20)
!2359 = !DIDerivedType(tag: DW_TAG_member, name: "sign_flag", scope: !2342, file: !1295, line: 146, baseType: !1315, flags: DIFlagStaticMember, extraData: i1 false)
!2360 = !DISubprogram(name: "operator=", linkageName: "_ZN11ap_int_baseILi20ELb0EEaSERKS0_", scope: !2342, file: !1295, line: 476, type: !2361, scopeLine: 476, flags: DIFlagPrototyped, spFlags: 0)
!2361 = !DISubroutineType(types: !2362)
!2362 = !{!2363, !2364, !2365}
!2363 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2342, size: 64)
!2364 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2342, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2365 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2366, size: 64)
!2366 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2342)
!2367 = !{!2368, !1311}
!2368 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 20)
!2369 = !DISubprogram(name: "ap_uint", scope: !2339, file: !1883, line: 296, type: !2370, scopeLine: 296, flags: DIFlagPrototyped, spFlags: 0)
!2370 = !DISubroutineType(types: !2371)
!2371 = !{null, !2372, !556}
!2372 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2339, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2373 = !DISubprogram(name: "ap_uint", scope: !2339, file: !1883, line: 297, type: !2374, scopeLine: 297, flags: DIFlagPrototyped, spFlags: 0)
!2374 = !DISubroutineType(types: !2375)
!2375 = !{null, !2372, !29}
!2376 = !DISubprogram(name: "ap_uint", scope: !2339, file: !1883, line: 298, type: !2377, scopeLine: 298, flags: DIFlagPrototyped, spFlags: 0)
!2377 = !DISubroutineType(types: !2378)
!2378 = !{null, !2372, !1896}
!2379 = !DISubprogram(name: "operator=", linkageName: "_ZN7ap_uintILi20EEaSERKS0_", scope: !2339, file: !1883, line: 309, type: !2380, scopeLine: 309, flags: DIFlagPrototyped, spFlags: 0)
!2380 = !DISubroutineType(types: !2381)
!2381 = !{!2382, !2372, !2383}
!2382 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2339, size: 64)
!2383 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2384, size: 64)
!2384 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2339)
!2385 = !{!2368}
!2386 = !DISubprogram(name: "sig_lsb", linkageName: "_ZNK9fp_structIdE7sig_lsbEv", scope: !2225, file: !1874, line: 491, type: !2387, scopeLine: 491, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2387 = !DISubroutineType(types: !2388)
!2388 = !{!2137, !2326}
!2389 = !DISubprogram(name: "to_double", linkageName: "_ZNK9fp_structIdE9to_doubleEv", scope: !2225, file: !1874, line: 494, type: !2390, scopeLine: 494, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2390 = !DISubroutineType(types: !2391)
!2391 = !{!556, !2326}
!2392 = !DISubprogram(name: "set_mantissa", linkageName: "_ZN9fp_structIdE12set_mantissaE9ap_ufixedILi53ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE", scope: !2225, file: !1874, line: 499, type: !2393, scopeLine: 499, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2393 = !DISubroutineType(types: !2394)
!2394 = !{null, !2291, !2395}
!2395 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<53, 1, AP_TRN, AP_WRAP, 0>", file: !2032, line: 191, size: 64, flags: DIFlagTypePassByValue, elements: !2396, templateParams: !2427, identifier: "_ZTS9ap_ufixedILi53ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2396 = !{!2397, !2420}
!2397 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2395, baseType: !2398)
!2398 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<53, 1, false, AP_TRN, AP_WRAP, 0>", file: !1442, line: 107, size: 64, flags: DIFlagTypePassByValue, elements: !2399, templateParams: !2418, identifier: "_ZTS13ap_fixed_baseILi53ELi1ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!2399 = !{!2400, !2414, !2415, !2416, !2417}
!2400 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !2398, baseType: !2401)
!2401 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<53, false>", file: !1299, line: 523, size: 64, flags: DIFlagTypePassByValue, elements: !2402, templateParams: !2412, identifier: "_ZTS8ssdm_intILi53ELb0EE")
!2402 = !{!2403, !2405, !2409}
!2403 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !2401, file: !1299, line: 525, baseType: !2404, size: 53, align: 64)
!2404 = !DIBasicType(name: "uint53", size: 53, encoding: DW_ATE_unsigned)
!2405 = !DISubprogram(name: "ssdm_int", scope: !2401, file: !1299, line: 526, type: !2406, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!2406 = !DISubroutineType(types: !2407)
!2407 = !{null, !2408}
!2408 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2401, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2409 = !DISubprogram(name: "ssdm_int", scope: !2401, file: !1299, line: 527, type: !2410, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!2410 = !DISubroutineType(types: !2411)
!2411 = !{null, !2408, !2404}
!2412 = !{!2413, !1311}
!2413 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 53)
!2414 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !2398, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 53)
!2415 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !2398, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 1)
!2416 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !2398, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!2417 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !2398, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!2418 = !{!2419, !2057, !1311, !1453, !1454, !1455}
!2419 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 53)
!2420 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi53ELi1EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSERKS2_", scope: !2395, file: !2032, line: 321, type: !2421, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!2421 = !DISubroutineType(types: !2422)
!2422 = !{!2423, !2424, !2425}
!2423 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2395, size: 64)
!2424 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2395, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!2425 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !2426, size: 64)
!2426 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2395)
!2427 = !{!2419, !2057, !1453, !1454, !1455}
!2428 = !DISubprogram(name: "mantissa", linkageName: "_ZNK9fp_structIdE8mantissaEv", scope: !2225, file: !1874, line: 503, type: !2429, scopeLine: 503, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2429 = !DISubroutineType(types: !2430)
!2430 = !{!2395, !2326}
!2431 = !DISubprogram(name: "to_ieee", linkageName: "_ZNK9fp_structIdE7to_ieeeEv", scope: !2225, file: !1874, line: 509, type: !2390, scopeLine: 509, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2432 = !DISubprogram(name: "__signbit", linkageName: "_ZNK9fp_structIdE9__signbitEv", scope: !2225, file: !1874, line: 512, type: !2334, scopeLine: 512, flags: DIFlagPublic | DIFlagPrototyped, spFlags: 0)
!2433 = !DISubprogram(name: "infinity", linkageName: "_ZN9fp_structIdE8infinityEv", scope: !2225, file: !1874, line: 516, type: !2434, scopeLine: 516, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2434 = !DISubroutineType(types: !2435)
!2435 = !{!556}
!2436 = !DISubprogram(name: "minus_infinity", linkageName: "_ZN9fp_structIdE14minus_infinityEv", scope: !2225, file: !1874, line: 524, type: !2434, scopeLine: 524, flags: DIFlagPublic | DIFlagPrototyped | DIFlagStaticMember, spFlags: 0)
!2437 = !{!2438}
!2438 = !DITemplateTypeParameter(name: "T", type: !556)
!2439 = !{!2440, !2442, !2446, !2449, !2451, !2453, !2455, !2457, !2459, !2461, !2465, !2472, !2476, !2480, !2482, !2484, !2486, !2490, !2494, !2498, !2502, !2506, !2510, !2514, !2516, !2518, !2522, !2524, !2526, !2530, !2534, !2536, !2540, !2542, !2544, !2546, !2550, !2554, !2558, !2562, !2566, !2568, !2570, !2571, !2572, !2573, !2575, !2576, !2577, !2578, !2579, !2580, !2581, !2583, !2585, !2591, !2593, !2595, !2599, !2601, !2603, !2605, !2607, !2609, !2611, !2613, !2618, !2622, !2624, !2626, !2631, !2633, !2635, !2637, !2639, !2641, !2643, !2646, !2648, !2650, !2654, !2658, !2660, !2662, !2664, !2666, !2668, !2670, !2672, !2674, !2676, !2678, !2682, !2686, !2688, !2690, !2692, !2694, !2696, !2698, !2700, !2702, !2704, !2706, !2708, !2710, !2712, !2714, !2716, !2720, !2724, !2728, !2730, !2732, !2734, !2736, !2738, !2740, !2742, !2744, !2746, !2750, !2754, !2758, !2760, !2762, !2764, !2768, !2772, !2776, !2778, !2780, !2782, !2784, !2786, !2788, !2790, !2792, !2794, !2796, !2798, !2800, !2804, !2808, !2812, !2814, !2816, !2818, !2820, !2824, !2828, !2830, !2832, !2834, !2836, !2838, !2840, !2844, !2848, !2850, !2852, !2854, !2856, !2860, !2864, !2868, !2870, !2872, !2874, !2876, !2878, !2880, !2884, !2888, !2892, !2894, !2898, !2902, !2904, !2906, !2908, !2910, !2912, !2914, !2920, !2923, !2928, !2935, !2940, !2944, !2948, !2952, !2956, !2958, !2960, !2964, !2970, !2974, !2980, !2984, !2986, !2990, !2994, !2996, !3000, !3007, !3009, !3013, !3017, !3021, !3023, !3027, !3029, !3031, !3033, !3035, !3039, !3043, !3047, !3051, !3055, !3057, !3061, !3063, !3065, !3067, !3069, !3073, !3077, !3081, !3085, !3087, !3089, !3093, !3097, !3099, !3101, !3103, !3105, !3107, !3109, !3113, !3115, !3119, !3123, !3124, !3125, !3126, !3127, !3128, !3129, !3130, !3131, !3132, !3133, !3137, !3138, !3139, !3140, !3143, !3145, !3147, !3149, !3152, !3155, !3158, !3161, !3164, !3166, !3169, !3170, !3171, !3172, !3174, !3176, !3178, !3180, !3183, !3186, !3189, !3192, !3195, !3197, !3199, !3202, !3204, !3208, !3210, !3212, !3214, !3216, !3218, !3220, !3222, !3224, !3226, !3228, !3230, !3232, !3234, !3238, !3240, !3244, !3249, !3254, !3258, !3260, !3262, !3264, !3266, !3273, !3277, !3281, !3285, !3289, !3293, !3297, !3301, !3303, !3307, !3313, !3317, !3321, !3323, !3325, !3327, !3329, !3331, !3333, !3335, !3337, !3339, !3341, !3343, !3347, !3351, !3353, !3355, !3359, !3361, !3363, !3367, !3371, !3375, !3379, !3381, !3383, !3387, !3391, !3392, !3393, !3394, !3395, !3396, !3402, !3405, !3406, !3408, !3410, !3412, !3414, !3418, !3420, !3422, !3424, !3426, !3428, !3430, !3432, !3434, !3438, !3442, !3444, !3448}
!2440 = !DIImportedEntity(tag: DW_TAG_imported_module, scope: !362, entity: !363, file: !2441, line: 58)
!2441 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/debug/debug.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2442 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2443, file: !2445, line: 52)
!2443 = !DISubprogram(name: "abs", scope: !2444, file: !2444, line: 837, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!2444 = !DIFile(filename: "/usr/include/stdlib.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2445 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/std_abs.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2446 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2447, file: !2448, line: 127)
!2447 = !DIDerivedType(tag: DW_TAG_typedef, name: "div_t", file: !2444, line: 62, baseType: !698)
!2448 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdlib", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2449 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2450, file: !2448, line: 128)
!2450 = !DIDerivedType(tag: DW_TAG_typedef, name: "ldiv_t", file: !2444, line: 70, baseType: !702)
!2451 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2452, file: !2448, line: 130)
!2452 = !DISubprogram(name: "abort", scope: !2444, file: !2444, line: 588, type: !708, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!2453 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2454, file: !2448, line: 134)
!2454 = !DISubprogram(name: "atexit", scope: !2444, file: !2444, line: 592, type: !716, flags: DIFlagPrototyped, spFlags: 0)
!2455 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2456, file: !2448, line: 137)
!2456 = !DISubprogram(name: "at_quick_exit", scope: !2444, file: !2444, line: 597, type: !716, flags: DIFlagPrototyped, spFlags: 0)
!2457 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2458, file: !2448, line: 140)
!2458 = !DISubprogram(name: "atof", scope: !2444, file: !2444, line: 101, type: !723, flags: DIFlagPrototyped, spFlags: 0)
!2459 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2460, file: !2448, line: 141)
!2460 = !DISubprogram(name: "atoi", scope: !2444, file: !2444, line: 104, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!2461 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2462, file: !2448, line: 142)
!2462 = !DISubprogram(name: "atol", scope: !2444, file: !2444, line: 107, type: !2463, flags: DIFlagPrototyped, spFlags: 0)
!2463 = !DISubroutineType(types: !2464)
!2464 = !{!1675, !311}
!2465 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2466, file: !2448, line: 143)
!2466 = !DISubprogram(name: "bsearch", scope: !2444, file: !2444, line: 817, type: !2467, flags: DIFlagPrototyped, spFlags: 0)
!2467 = !DISubroutineType(types: !2468)
!2468 = !{!254, !737, !737, !2469, !2469, !2471}
!2469 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !2470, line: 62, baseType: !1324)
!2470 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/build/hls_clib/lnx64/tools/hls_llvm_fe/lib/clang/7.0.0/include/stddef.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2471 = !DIDerivedType(tag: DW_TAG_typedef, name: "__compar_fn_t", file: !2444, line: 805, baseType: !740)
!2472 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2473, file: !2448, line: 144)
!2473 = !DISubprogram(name: "calloc", scope: !2444, file: !2444, line: 541, type: !2474, flags: DIFlagPrototyped, spFlags: 0)
!2474 = !DISubroutineType(types: !2475)
!2475 = !{!254, !2469, !2469}
!2476 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2477, file: !2448, line: 145)
!2477 = !DISubprogram(name: "div", scope: !2444, file: !2444, line: 849, type: !2478, flags: DIFlagPrototyped, spFlags: 0)
!2478 = !DISubroutineType(types: !2479)
!2479 = !{!2447, !184, !184}
!2480 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2481, file: !2448, line: 146)
!2481 = !DISubprogram(name: "exit", scope: !2444, file: !2444, line: 614, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!2482 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2483, file: !2448, line: 147)
!2483 = !DISubprogram(name: "free", scope: !2444, file: !2444, line: 563, type: !755, flags: DIFlagPrototyped, spFlags: 0)
!2484 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2485, file: !2448, line: 148)
!2485 = !DISubprogram(name: "getenv", scope: !2444, file: !2444, line: 631, type: !759, flags: DIFlagPrototyped, spFlags: 0)
!2486 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2487, file: !2448, line: 149)
!2487 = !DISubprogram(name: "labs", scope: !2444, file: !2444, line: 838, type: !2488, flags: DIFlagPrototyped, spFlags: 0)
!2488 = !DISubroutineType(types: !2489)
!2489 = !{!1675, !1675}
!2490 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2491, file: !2448, line: 150)
!2491 = !DISubprogram(name: "ldiv", scope: !2444, file: !2444, line: 851, type: !2492, flags: DIFlagPrototyped, spFlags: 0)
!2492 = !DISubroutineType(types: !2493)
!2493 = !{!2450, !1675, !1675}
!2494 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2495, file: !2448, line: 151)
!2495 = !DISubprogram(name: "malloc", scope: !2444, file: !2444, line: 539, type: !2496, flags: DIFlagPrototyped, spFlags: 0)
!2496 = !DISubroutineType(types: !2497)
!2497 = !{!254, !2469}
!2498 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2499, file: !2448, line: 153)
!2499 = !DISubprogram(name: "mblen", scope: !2444, file: !2444, line: 919, type: !2500, flags: DIFlagPrototyped, spFlags: 0)
!2500 = !DISubroutineType(types: !2501)
!2501 = !{!184, !311, !2469}
!2502 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2503, file: !2448, line: 154)
!2503 = !DISubprogram(name: "mbstowcs", scope: !2444, file: !2444, line: 930, type: !2504, flags: DIFlagPrototyped, spFlags: 0)
!2504 = !DISubroutineType(types: !2505)
!2505 = !{!2469, !404, !439, !2469}
!2506 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2507, file: !2448, line: 155)
!2507 = !DISubprogram(name: "mbtowc", scope: !2444, file: !2444, line: 922, type: !2508, flags: DIFlagPrototyped, spFlags: 0)
!2508 = !DISubroutineType(types: !2509)
!2509 = !{!184, !404, !439, !2469}
!2510 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2511, file: !2448, line: 157)
!2511 = !DISubprogram(name: "qsort", scope: !2444, file: !2444, line: 827, type: !2512, flags: DIFlagPrototyped, spFlags: 0)
!2512 = !DISubroutineType(types: !2513)
!2513 = !{null, !254, !2469, !2469, !2471}
!2514 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2515, file: !2448, line: 160)
!2515 = !DISubprogram(name: "quick_exit", scope: !2444, file: !2444, line: 620, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!2516 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2517, file: !2448, line: 163)
!2517 = !DISubprogram(name: "rand", scope: !2444, file: !2444, line: 453, type: !308, flags: DIFlagPrototyped, spFlags: 0)
!2518 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2519, file: !2448, line: 164)
!2519 = !DISubprogram(name: "realloc", scope: !2444, file: !2444, line: 549, type: !2520, flags: DIFlagPrototyped, spFlags: 0)
!2520 = !DISubroutineType(types: !2521)
!2521 = !{!254, !254, !2469}
!2522 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2523, file: !2448, line: 165)
!2523 = !DISubprogram(name: "srand", scope: !2444, file: !2444, line: 455, type: !799, flags: DIFlagPrototyped, spFlags: 0)
!2524 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2525, file: !2448, line: 166)
!2525 = !DISubprogram(name: "strtod", scope: !2444, file: !2444, line: 117, type: !803, flags: DIFlagPrototyped, spFlags: 0)
!2526 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2527, file: !2448, line: 167)
!2527 = !DISubprogram(name: "strtol", scope: !2444, file: !2444, line: 176, type: !2528, flags: DIFlagPrototyped, spFlags: 0)
!2528 = !DISubroutineType(types: !2529)
!2529 = !{!1675, !439, !805, !184}
!2530 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2531, file: !2448, line: 168)
!2531 = !DISubprogram(name: "strtoul", scope: !2444, file: !2444, line: 180, type: !2532, flags: DIFlagPrototyped, spFlags: 0)
!2532 = !DISubroutineType(types: !2533)
!2533 = !{!1324, !439, !805, !184}
!2534 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2535, file: !2448, line: 169)
!2535 = !DISubprogram(name: "system", scope: !2444, file: !2444, line: 781, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!2536 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2537, file: !2448, line: 171)
!2537 = !DISubprogram(name: "wcstombs", scope: !2444, file: !2444, line: 933, type: !2538, flags: DIFlagPrototyped, spFlags: 0)
!2538 = !DISubroutineType(types: !2539)
!2539 = !{!2469, !504, !414, !2469}
!2540 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2541, file: !2448, line: 172)
!2541 = !DISubprogram(name: "wctomb", scope: !2444, file: !2444, line: 926, type: !823, flags: DIFlagPrototyped, spFlags: 0)
!2542 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2543, file: !2448, line: 200)
!2543 = !DIDerivedType(tag: DW_TAG_typedef, name: "lldiv_t", file: !2444, line: 80, baseType: !827)
!2544 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2545, file: !2448, line: 206)
!2545 = !DISubprogram(name: "_Exit", scope: !2444, file: !2444, line: 626, type: !751, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!2546 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2547, file: !2448, line: 210)
!2547 = !DISubprogram(name: "llabs", scope: !2444, file: !2444, line: 841, type: !2548, flags: DIFlagPrototyped, spFlags: 0)
!2548 = !DISubroutineType(types: !2549)
!2549 = !{!1413, !1413}
!2550 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2551, file: !2448, line: 216)
!2551 = !DISubprogram(name: "lldiv", scope: !2444, file: !2444, line: 855, type: !2552, flags: DIFlagPrototyped, spFlags: 0)
!2552 = !DISubroutineType(types: !2553)
!2553 = !{!2543, !1413, !1413}
!2554 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2555, file: !2448, line: 227)
!2555 = !DISubprogram(name: "atoll", scope: !2444, file: !2444, line: 112, type: !2556, flags: DIFlagPrototyped, spFlags: 0)
!2556 = !DISubroutineType(types: !2557)
!2557 = !{!1413, !311}
!2558 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2559, file: !2448, line: 228)
!2559 = !DISubprogram(name: "strtoll", scope: !2444, file: !2444, line: 200, type: !2560, flags: DIFlagPrototyped, spFlags: 0)
!2560 = !DISubroutineType(types: !2561)
!2561 = !{!1413, !439, !805, !184}
!2562 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2563, file: !2448, line: 229)
!2563 = !DISubprogram(name: "strtoull", scope: !2444, file: !2444, line: 205, type: !2564, flags: DIFlagPrototyped, spFlags: 0)
!2564 = !DISubroutineType(types: !2565)
!2565 = !{!1292, !439, !805, !184}
!2566 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2567, file: !2448, line: 231)
!2567 = !DISubprogram(name: "strtof", scope: !2444, file: !2444, line: 123, type: !855, flags: DIFlagPrototyped, spFlags: 0)
!2568 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !2569, file: !2448, line: 232)
!2569 = !DISubprogram(name: "strtold", scope: !2444, file: !2444, line: 126, type: !859, flags: DIFlagPrototyped, spFlags: 0)
!2570 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2543, file: !2448, line: 240)
!2571 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2545, file: !2448, line: 242)
!2572 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2547, file: !2448, line: 244)
!2573 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2574, file: !2448, line: 245)
!2574 = !DISubprogram(name: "div", linkageName: "_ZN9__gnu_cxx3divExx", scope: !618, file: !2448, line: 213, type: !2552, flags: DIFlagPrototyped, spFlags: 0)
!2575 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2551, file: !2448, line: 246)
!2576 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2555, file: !2448, line: 248)
!2577 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2567, file: !2448, line: 249)
!2578 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2559, file: !2448, line: 250)
!2579 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2563, file: !2448, line: 251)
!2580 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2569, file: !2448, line: 252)
!2581 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !249, file: !2582, line: 57)
!2582 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/bits/exception_ptr.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2583 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !251, entity: !2584, file: !2582, line: 73)
!2584 = !DISubprogram(name: "rethrow_exception", linkageName: "_ZSt17rethrow_exceptionNSt15__exception_ptr13exception_ptrE", scope: !175, file: !2582, line: 69, type: !359, flags: DIFlagPrototyped | DIFlagNoReturn, spFlags: 0)
!2585 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2586, file: !2590, line: 83)
!2586 = !DISubprogram(name: "acos", scope: !2587, file: !2587, line: 53, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2587 = !DIFile(filename: "/usr/include/bits/mathcalls.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2588 = !DISubroutineType(types: !2589)
!2589 = !{!556, !556}
!2590 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cmath", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2591 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2592, file: !2590, line: 102)
!2592 = !DISubprogram(name: "asin", scope: !2587, file: !2587, line: 55, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2593 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2594, file: !2590, line: 121)
!2594 = !DISubprogram(name: "atan", scope: !2587, file: !2587, line: 57, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2595 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2596, file: !2590, line: 140)
!2596 = !DISubprogram(name: "atan2", scope: !2587, file: !2587, line: 59, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2597 = !DISubroutineType(types: !2598)
!2598 = !{!556, !556, !556}
!2599 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2600, file: !2590, line: 161)
!2600 = !DISubprogram(name: "ceil", scope: !2587, file: !2587, line: 159, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2601 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2602, file: !2590, line: 180)
!2602 = !DISubprogram(name: "cos", scope: !2587, file: !2587, line: 62, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2603 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2604, file: !2590, line: 199)
!2604 = !DISubprogram(name: "cosh", scope: !2587, file: !2587, line: 71, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2605 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2606, file: !2590, line: 218)
!2606 = !DISubprogram(name: "exp", scope: !2587, file: !2587, line: 95, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2607 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2608, file: !2590, line: 237)
!2608 = !DISubprogram(name: "fabs", scope: !2587, file: !2587, line: 162, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2609 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2610, file: !2590, line: 256)
!2610 = !DISubprogram(name: "floor", scope: !2587, file: !2587, line: 165, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2611 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2612, file: !2590, line: 275)
!2612 = !DISubprogram(name: "fmod", scope: !2587, file: !2587, line: 168, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2613 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2614, file: !2590, line: 296)
!2614 = !DISubprogram(name: "frexp", scope: !2587, file: !2587, line: 98, type: !2615, flags: DIFlagPrototyped, spFlags: 0)
!2615 = !DISubroutineType(types: !2616)
!2616 = !{!556, !556, !2617}
!2617 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !184, size: 64)
!2618 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2619, file: !2590, line: 315)
!2619 = !DISubprogram(name: "ldexp", scope: !2587, file: !2587, line: 101, type: !2620, flags: DIFlagPrototyped, spFlags: 0)
!2620 = !DISubroutineType(types: !2621)
!2621 = !{!556, !556, !184}
!2622 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2623, file: !2590, line: 334)
!2623 = !DISubprogram(name: "log", scope: !2587, file: !2587, line: 104, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2624 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2625, file: !2590, line: 353)
!2625 = !DISubprogram(name: "log10", scope: !2587, file: !2587, line: 107, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2626 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2627, file: !2590, line: 372)
!2627 = !DISubprogram(name: "modf", scope: !2587, file: !2587, line: 110, type: !2628, flags: DIFlagPrototyped, spFlags: 0)
!2628 = !DISubroutineType(types: !2629)
!2629 = !{!556, !556, !2630}
!2630 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !556, size: 64)
!2631 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2632, file: !2590, line: 384)
!2632 = !DISubprogram(name: "pow", scope: !2587, file: !2587, line: 140, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2633 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2634, file: !2590, line: 421)
!2634 = !DISubprogram(name: "sin", scope: !2587, file: !2587, line: 64, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2635 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2636, file: !2590, line: 440)
!2636 = !DISubprogram(name: "sinh", scope: !2587, file: !2587, line: 73, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2637 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2638, file: !2590, line: 459)
!2638 = !DISubprogram(name: "sqrt", scope: !2587, file: !2587, line: 143, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2639 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2640, file: !2590, line: 478)
!2640 = !DISubprogram(name: "tan", scope: !2587, file: !2587, line: 66, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2641 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2642, file: !2590, line: 497)
!2642 = !DISubprogram(name: "tanh", scope: !2587, file: !2587, line: 75, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2643 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2644, file: !2590, line: 1065)
!2644 = !DIDerivedType(tag: DW_TAG_typedef, name: "double_t", file: !2645, line: 150, baseType: !556)
!2645 = !DIFile(filename: "/usr/include/math.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2646 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2647, file: !2590, line: 1066)
!2647 = !DIDerivedType(tag: DW_TAG_typedef, name: "float_t", file: !2645, line: 149, baseType: !29)
!2648 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2649, file: !2590, line: 1069)
!2649 = !DISubprogram(name: "acosh", scope: !2587, file: !2587, line: 85, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2650 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2651, file: !2590, line: 1070)
!2651 = !DISubprogram(name: "acoshf", scope: !2587, file: !2587, line: 85, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2652 = !DISubroutineType(types: !2653)
!2653 = !{!29, !29}
!2654 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2655, file: !2590, line: 1071)
!2655 = !DISubprogram(name: "acoshl", scope: !2587, file: !2587, line: 85, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2656 = !DISubroutineType(types: !2657)
!2657 = !{!622, !622}
!2658 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2659, file: !2590, line: 1073)
!2659 = !DISubprogram(name: "asinh", scope: !2587, file: !2587, line: 87, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2660 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2661, file: !2590, line: 1074)
!2661 = !DISubprogram(name: "asinhf", scope: !2587, file: !2587, line: 87, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2662 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2663, file: !2590, line: 1075)
!2663 = !DISubprogram(name: "asinhl", scope: !2587, file: !2587, line: 87, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2664 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2665, file: !2590, line: 1077)
!2665 = !DISubprogram(name: "atanh", scope: !2587, file: !2587, line: 89, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2666 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2667, file: !2590, line: 1078)
!2667 = !DISubprogram(name: "atanhf", scope: !2587, file: !2587, line: 89, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2668 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2669, file: !2590, line: 1079)
!2669 = !DISubprogram(name: "atanhl", scope: !2587, file: !2587, line: 89, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2670 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2671, file: !2590, line: 1081)
!2671 = !DISubprogram(name: "cbrt", scope: !2587, file: !2587, line: 152, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2672 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2673, file: !2590, line: 1082)
!2673 = !DISubprogram(name: "cbrtf", scope: !2587, file: !2587, line: 152, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2674 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2675, file: !2590, line: 1083)
!2675 = !DISubprogram(name: "cbrtl", scope: !2587, file: !2587, line: 152, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2676 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2677, file: !2590, line: 1085)
!2677 = !DISubprogram(name: "copysign", scope: !2587, file: !2587, line: 196, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2678 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2679, file: !2590, line: 1086)
!2679 = !DISubprogram(name: "copysignf", scope: !2587, file: !2587, line: 196, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2680 = !DISubroutineType(types: !2681)
!2681 = !{!29, !29, !29}
!2682 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2683, file: !2590, line: 1087)
!2683 = !DISubprogram(name: "copysignl", scope: !2587, file: !2587, line: 196, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2684 = !DISubroutineType(types: !2685)
!2685 = !{!622, !622, !622}
!2686 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2687, file: !2590, line: 1089)
!2687 = !DISubprogram(name: "erf", scope: !2587, file: !2587, line: 228, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2688 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2689, file: !2590, line: 1090)
!2689 = !DISubprogram(name: "erff", scope: !2587, file: !2587, line: 228, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2690 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2691, file: !2590, line: 1091)
!2691 = !DISubprogram(name: "erfl", scope: !2587, file: !2587, line: 228, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2692 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2693, file: !2590, line: 1093)
!2693 = !DISubprogram(name: "erfc", scope: !2587, file: !2587, line: 229, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2694 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2695, file: !2590, line: 1094)
!2695 = !DISubprogram(name: "erfcf", scope: !2587, file: !2587, line: 229, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2696 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2697, file: !2590, line: 1095)
!2697 = !DISubprogram(name: "erfcl", scope: !2587, file: !2587, line: 229, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2698 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2699, file: !2590, line: 1097)
!2699 = !DISubprogram(name: "exp2", scope: !2587, file: !2587, line: 130, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2700 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2701, file: !2590, line: 1098)
!2701 = !DISubprogram(name: "exp2f", scope: !2587, file: !2587, line: 130, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2702 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2703, file: !2590, line: 1099)
!2703 = !DISubprogram(name: "exp2l", scope: !2587, file: !2587, line: 130, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2704 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2705, file: !2590, line: 1101)
!2705 = !DISubprogram(name: "expm1", scope: !2587, file: !2587, line: 119, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2706 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2707, file: !2590, line: 1102)
!2707 = !DISubprogram(name: "expm1f", scope: !2587, file: !2587, line: 119, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2708 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2709, file: !2590, line: 1103)
!2709 = !DISubprogram(name: "expm1l", scope: !2587, file: !2587, line: 119, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2710 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2711, file: !2590, line: 1105)
!2711 = !DISubprogram(name: "fdim", scope: !2587, file: !2587, line: 326, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2712 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2713, file: !2590, line: 1106)
!2713 = !DISubprogram(name: "fdimf", scope: !2587, file: !2587, line: 326, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2714 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2715, file: !2590, line: 1107)
!2715 = !DISubprogram(name: "fdiml", scope: !2587, file: !2587, line: 326, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2716 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2717, file: !2590, line: 1109)
!2717 = !DISubprogram(name: "fma", scope: !2587, file: !2587, line: 335, type: !2718, flags: DIFlagPrototyped, spFlags: 0)
!2718 = !DISubroutineType(types: !2719)
!2719 = !{!556, !556, !556, !556}
!2720 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2721, file: !2590, line: 1110)
!2721 = !DISubprogram(name: "fmaf", scope: !2587, file: !2587, line: 335, type: !2722, flags: DIFlagPrototyped, spFlags: 0)
!2722 = !DISubroutineType(types: !2723)
!2723 = !{!29, !29, !29, !29}
!2724 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2725, file: !2590, line: 1111)
!2725 = !DISubprogram(name: "fmal", scope: !2587, file: !2587, line: 335, type: !2726, flags: DIFlagPrototyped, spFlags: 0)
!2726 = !DISubroutineType(types: !2727)
!2727 = !{!622, !622, !622, !622}
!2728 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2729, file: !2590, line: 1113)
!2729 = !DISubprogram(name: "fmax", scope: !2587, file: !2587, line: 329, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2730 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2731, file: !2590, line: 1114)
!2731 = !DISubprogram(name: "fmaxf", scope: !2587, file: !2587, line: 329, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2732 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2733, file: !2590, line: 1115)
!2733 = !DISubprogram(name: "fmaxl", scope: !2587, file: !2587, line: 329, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2734 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2735, file: !2590, line: 1117)
!2735 = !DISubprogram(name: "fmin", scope: !2587, file: !2587, line: 332, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2736 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2737, file: !2590, line: 1118)
!2737 = !DISubprogram(name: "fminf", scope: !2587, file: !2587, line: 332, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2738 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2739, file: !2590, line: 1119)
!2739 = !DISubprogram(name: "fminl", scope: !2587, file: !2587, line: 332, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2740 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2741, file: !2590, line: 1121)
!2741 = !DISubprogram(name: "hypot", scope: !2587, file: !2587, line: 147, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2742 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2743, file: !2590, line: 1122)
!2743 = !DISubprogram(name: "hypotf", scope: !2587, file: !2587, line: 147, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2744 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2745, file: !2590, line: 1123)
!2745 = !DISubprogram(name: "hypotl", scope: !2587, file: !2587, line: 147, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2746 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2747, file: !2590, line: 1125)
!2747 = !DISubprogram(name: "ilogb", scope: !2587, file: !2587, line: 280, type: !2748, flags: DIFlagPrototyped, spFlags: 0)
!2748 = !DISubroutineType(types: !2749)
!2749 = !{!184, !556}
!2750 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2751, file: !2590, line: 1126)
!2751 = !DISubprogram(name: "ilogbf", scope: !2587, file: !2587, line: 280, type: !2752, flags: DIFlagPrototyped, spFlags: 0)
!2752 = !DISubroutineType(types: !2753)
!2753 = !{!184, !29}
!2754 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2755, file: !2590, line: 1127)
!2755 = !DISubprogram(name: "ilogbl", scope: !2587, file: !2587, line: 280, type: !2756, flags: DIFlagPrototyped, spFlags: 0)
!2756 = !DISubroutineType(types: !2757)
!2757 = !{!184, !622}
!2758 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2759, file: !2590, line: 1129)
!2759 = !DISubprogram(name: "lgamma", scope: !2587, file: !2587, line: 230, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2760 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2761, file: !2590, line: 1130)
!2761 = !DISubprogram(name: "lgammaf", scope: !2587, file: !2587, line: 230, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2762 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2763, file: !2590, line: 1131)
!2763 = !DISubprogram(name: "lgammal", scope: !2587, file: !2587, line: 230, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2764 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2765, file: !2590, line: 1134)
!2765 = !DISubprogram(name: "llrint", scope: !2587, file: !2587, line: 316, type: !2766, flags: DIFlagPrototyped, spFlags: 0)
!2766 = !DISubroutineType(types: !2767)
!2767 = !{!1413, !556}
!2768 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2769, file: !2590, line: 1135)
!2769 = !DISubprogram(name: "llrintf", scope: !2587, file: !2587, line: 316, type: !2770, flags: DIFlagPrototyped, spFlags: 0)
!2770 = !DISubroutineType(types: !2771)
!2771 = !{!1413, !29}
!2772 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2773, file: !2590, line: 1136)
!2773 = !DISubprogram(name: "llrintl", scope: !2587, file: !2587, line: 316, type: !2774, flags: DIFlagPrototyped, spFlags: 0)
!2774 = !DISubroutineType(types: !2775)
!2775 = !{!1413, !622}
!2776 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2777, file: !2590, line: 1138)
!2777 = !DISubprogram(name: "llround", scope: !2587, file: !2587, line: 322, type: !2766, flags: DIFlagPrototyped, spFlags: 0)
!2778 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2779, file: !2590, line: 1139)
!2779 = !DISubprogram(name: "llroundf", scope: !2587, file: !2587, line: 322, type: !2770, flags: DIFlagPrototyped, spFlags: 0)
!2780 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2781, file: !2590, line: 1140)
!2781 = !DISubprogram(name: "llroundl", scope: !2587, file: !2587, line: 322, type: !2774, flags: DIFlagPrototyped, spFlags: 0)
!2782 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2783, file: !2590, line: 1143)
!2783 = !DISubprogram(name: "log1p", scope: !2587, file: !2587, line: 122, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2784 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2785, file: !2590, line: 1144)
!2785 = !DISubprogram(name: "log1pf", scope: !2587, file: !2587, line: 122, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2786 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2787, file: !2590, line: 1145)
!2787 = !DISubprogram(name: "log1pl", scope: !2587, file: !2587, line: 122, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2788 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2789, file: !2590, line: 1147)
!2789 = !DISubprogram(name: "log2", scope: !2587, file: !2587, line: 133, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2790 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2791, file: !2590, line: 1148)
!2791 = !DISubprogram(name: "log2f", scope: !2587, file: !2587, line: 133, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2792 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2793, file: !2590, line: 1149)
!2793 = !DISubprogram(name: "log2l", scope: !2587, file: !2587, line: 133, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2794 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2795, file: !2590, line: 1151)
!2795 = !DISubprogram(name: "logb", scope: !2587, file: !2587, line: 125, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2796 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2797, file: !2590, line: 1152)
!2797 = !DISubprogram(name: "logbf", scope: !2587, file: !2587, line: 125, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2798 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2799, file: !2590, line: 1153)
!2799 = !DISubprogram(name: "logbl", scope: !2587, file: !2587, line: 125, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2800 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2801, file: !2590, line: 1155)
!2801 = !DISubprogram(name: "lrint", scope: !2587, file: !2587, line: 314, type: !2802, flags: DIFlagPrototyped, spFlags: 0)
!2802 = !DISubroutineType(types: !2803)
!2803 = !{!1675, !556}
!2804 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2805, file: !2590, line: 1156)
!2805 = !DISubprogram(name: "lrintf", scope: !2587, file: !2587, line: 314, type: !2806, flags: DIFlagPrototyped, spFlags: 0)
!2806 = !DISubroutineType(types: !2807)
!2807 = !{!1675, !29}
!2808 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2809, file: !2590, line: 1157)
!2809 = !DISubprogram(name: "lrintl", scope: !2587, file: !2587, line: 314, type: !2810, flags: DIFlagPrototyped, spFlags: 0)
!2810 = !DISubroutineType(types: !2811)
!2811 = !{!1675, !622}
!2812 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2813, file: !2590, line: 1159)
!2813 = !DISubprogram(name: "lround", scope: !2587, file: !2587, line: 320, type: !2802, flags: DIFlagPrototyped, spFlags: 0)
!2814 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2815, file: !2590, line: 1160)
!2815 = !DISubprogram(name: "lroundf", scope: !2587, file: !2587, line: 320, type: !2806, flags: DIFlagPrototyped, spFlags: 0)
!2816 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2817, file: !2590, line: 1161)
!2817 = !DISubprogram(name: "lroundl", scope: !2587, file: !2587, line: 320, type: !2810, flags: DIFlagPrototyped, spFlags: 0)
!2818 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2819, file: !2590, line: 1163)
!2819 = !DISubprogram(name: "nan", scope: !2587, file: !2587, line: 201, type: !723, flags: DIFlagPrototyped, spFlags: 0)
!2820 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2821, file: !2590, line: 1164)
!2821 = !DISubprogram(name: "nanf", scope: !2587, file: !2587, line: 201, type: !2822, flags: DIFlagPrototyped, spFlags: 0)
!2822 = !DISubroutineType(types: !2823)
!2823 = !{!29, !311}
!2824 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2825, file: !2590, line: 1165)
!2825 = !DISubprogram(name: "nanl", scope: !2587, file: !2587, line: 201, type: !2826, flags: DIFlagPrototyped, spFlags: 0)
!2826 = !DISubroutineType(types: !2827)
!2827 = !{!622, !311}
!2828 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2829, file: !2590, line: 1167)
!2829 = !DISubprogram(name: "nearbyint", scope: !2587, file: !2587, line: 294, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2830 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2831, file: !2590, line: 1168)
!2831 = !DISubprogram(name: "nearbyintf", scope: !2587, file: !2587, line: 294, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2832 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2833, file: !2590, line: 1169)
!2833 = !DISubprogram(name: "nearbyintl", scope: !2587, file: !2587, line: 294, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2834 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2835, file: !2590, line: 1171)
!2835 = !DISubprogram(name: "nextafter", scope: !2587, file: !2587, line: 259, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2836 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2837, file: !2590, line: 1172)
!2837 = !DISubprogram(name: "nextafterf", scope: !2587, file: !2587, line: 259, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2838 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2839, file: !2590, line: 1173)
!2839 = !DISubprogram(name: "nextafterl", scope: !2587, file: !2587, line: 259, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2840 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2841, file: !2590, line: 1175)
!2841 = !DISubprogram(name: "nexttoward", scope: !2587, file: !2587, line: 261, type: !2842, flags: DIFlagPrototyped, spFlags: 0)
!2842 = !DISubroutineType(types: !2843)
!2843 = !{!556, !556, !622}
!2844 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2845, file: !2590, line: 1176)
!2845 = !DISubprogram(name: "nexttowardf", scope: !2587, file: !2587, line: 261, type: !2846, flags: DIFlagPrototyped, spFlags: 0)
!2846 = !DISubroutineType(types: !2847)
!2847 = !{!29, !29, !622}
!2848 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2849, file: !2590, line: 1177)
!2849 = !DISubprogram(name: "nexttowardl", scope: !2587, file: !2587, line: 261, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2850 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2851, file: !2590, line: 1179)
!2851 = !DISubprogram(name: "remainder", scope: !2587, file: !2587, line: 272, type: !2597, flags: DIFlagPrototyped, spFlags: 0)
!2852 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2853, file: !2590, line: 1180)
!2853 = !DISubprogram(name: "remainderf", scope: !2587, file: !2587, line: 272, type: !2680, flags: DIFlagPrototyped, spFlags: 0)
!2854 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2855, file: !2590, line: 1181)
!2855 = !DISubprogram(name: "remainderl", scope: !2587, file: !2587, line: 272, type: !2684, flags: DIFlagPrototyped, spFlags: 0)
!2856 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2857, file: !2590, line: 1183)
!2857 = !DISubprogram(name: "remquo", scope: !2587, file: !2587, line: 307, type: !2858, flags: DIFlagPrototyped, spFlags: 0)
!2858 = !DISubroutineType(types: !2859)
!2859 = !{!556, !556, !556, !2617}
!2860 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2861, file: !2590, line: 1184)
!2861 = !DISubprogram(name: "remquof", scope: !2587, file: !2587, line: 307, type: !2862, flags: DIFlagPrototyped, spFlags: 0)
!2862 = !DISubroutineType(types: !2863)
!2863 = !{!29, !29, !29, !2617}
!2864 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2865, file: !2590, line: 1185)
!2865 = !DISubprogram(name: "remquol", scope: !2587, file: !2587, line: 307, type: !2866, flags: DIFlagPrototyped, spFlags: 0)
!2866 = !DISubroutineType(types: !2867)
!2867 = !{!622, !622, !622, !2617}
!2868 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2869, file: !2590, line: 1187)
!2869 = !DISubprogram(name: "rint", scope: !2587, file: !2587, line: 256, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2870 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2871, file: !2590, line: 1188)
!2871 = !DISubprogram(name: "rintf", scope: !2587, file: !2587, line: 256, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2872 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2873, file: !2590, line: 1189)
!2873 = !DISubprogram(name: "rintl", scope: !2587, file: !2587, line: 256, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2874 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2875, file: !2590, line: 1191)
!2875 = !DISubprogram(name: "round", scope: !2587, file: !2587, line: 298, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2876 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2877, file: !2590, line: 1192)
!2877 = !DISubprogram(name: "roundf", scope: !2587, file: !2587, line: 298, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2878 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2879, file: !2590, line: 1193)
!2879 = !DISubprogram(name: "roundl", scope: !2587, file: !2587, line: 298, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2880 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2881, file: !2590, line: 1195)
!2881 = !DISubprogram(name: "scalbln", scope: !2587, file: !2587, line: 290, type: !2882, flags: DIFlagPrototyped, spFlags: 0)
!2882 = !DISubroutineType(types: !2883)
!2883 = !{!556, !556, !1675}
!2884 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2885, file: !2590, line: 1196)
!2885 = !DISubprogram(name: "scalblnf", scope: !2587, file: !2587, line: 290, type: !2886, flags: DIFlagPrototyped, spFlags: 0)
!2886 = !DISubroutineType(types: !2887)
!2887 = !{!29, !29, !1675}
!2888 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2889, file: !2590, line: 1197)
!2889 = !DISubprogram(name: "scalblnl", scope: !2587, file: !2587, line: 290, type: !2890, flags: DIFlagPrototyped, spFlags: 0)
!2890 = !DISubroutineType(types: !2891)
!2891 = !{!622, !622, !1675}
!2892 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2893, file: !2590, line: 1199)
!2893 = !DISubprogram(name: "scalbn", scope: !2587, file: !2587, line: 276, type: !2620, flags: DIFlagPrototyped, spFlags: 0)
!2894 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2895, file: !2590, line: 1200)
!2895 = !DISubprogram(name: "scalbnf", scope: !2587, file: !2587, line: 276, type: !2896, flags: DIFlagPrototyped, spFlags: 0)
!2896 = !DISubroutineType(types: !2897)
!2897 = !{!29, !29, !184}
!2898 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2899, file: !2590, line: 1201)
!2899 = !DISubprogram(name: "scalbnl", scope: !2587, file: !2587, line: 276, type: !2900, flags: DIFlagPrototyped, spFlags: 0)
!2900 = !DISubroutineType(types: !2901)
!2901 = !{!622, !622, !184}
!2902 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2903, file: !2590, line: 1203)
!2903 = !DISubprogram(name: "tgamma", scope: !2587, file: !2587, line: 235, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2904 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2905, file: !2590, line: 1204)
!2905 = !DISubprogram(name: "tgammaf", scope: !2587, file: !2587, line: 235, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2906 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2907, file: !2590, line: 1205)
!2907 = !DISubprogram(name: "tgammal", scope: !2587, file: !2587, line: 235, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2908 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2909, file: !2590, line: 1207)
!2909 = !DISubprogram(name: "trunc", scope: !2587, file: !2587, line: 302, type: !2588, flags: DIFlagPrototyped, spFlags: 0)
!2910 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2911, file: !2590, line: 1208)
!2911 = !DISubprogram(name: "truncf", scope: !2587, file: !2587, line: 302, type: !2652, flags: DIFlagPrototyped, spFlags: 0)
!2912 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2913, file: !2590, line: 1209)
!2913 = !DISubprogram(name: "truncl", scope: !2587, file: !2587, line: 302, type: !2656, flags: DIFlagPrototyped, spFlags: 0)
!2914 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2915, file: !2919, line: 64)
!2915 = !DIDerivedType(tag: DW_TAG_typedef, name: "mbstate_t", file: !2916, line: 6, baseType: !2917)
!2916 = !DIFile(filename: "/usr/include/bits/types/mbstate_t.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2917 = !DIDerivedType(tag: DW_TAG_typedef, name: "__mbstate_t", file: !2918, line: 21, baseType: !370)
!2918 = !DIFile(filename: "/usr/include/bits/types/__mbstate_t.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2919 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cwchar", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2920 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2921, file: !2919, line: 139)
!2921 = !DIDerivedType(tag: DW_TAG_typedef, name: "wint_t", file: !2922, line: 20, baseType: !103)
!2922 = !DIFile(filename: "/usr/include/bits/types/wint_t.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2923 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2924, file: !2919, line: 141)
!2924 = !DISubprogram(name: "btowc", scope: !2925, file: !2925, line: 284, type: !2926, flags: DIFlagPrototyped, spFlags: 0)
!2925 = !DIFile(filename: "/usr/include/wchar.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2926 = !DISubroutineType(types: !2927)
!2927 = !{!2921, !184}
!2928 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2929, file: !2919, line: 142)
!2929 = !DISubprogram(name: "fgetwc", scope: !2925, file: !2925, line: 727, type: !2930, flags: DIFlagPrototyped, spFlags: 0)
!2930 = !DISubroutineType(types: !2931)
!2931 = !{!2921, !2932}
!2932 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2933, size: 64)
!2933 = !DIDerivedType(tag: DW_TAG_typedef, name: "__FILE", file: !2934, line: 5, baseType: !397)
!2934 = !DIFile(filename: "/usr/include/bits/types/__FILE.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!2935 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2936, file: !2919, line: 143)
!2936 = !DISubprogram(name: "fgetws", scope: !2925, file: !2925, line: 756, type: !2937, flags: DIFlagPrototyped, spFlags: 0)
!2937 = !DISubroutineType(types: !2938)
!2938 = !{!402, !404, !184, !2939}
!2939 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !2932)
!2940 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2941, file: !2919, line: 144)
!2941 = !DISubprogram(name: "fputwc", scope: !2925, file: !2925, line: 741, type: !2942, flags: DIFlagPrototyped, spFlags: 0)
!2942 = !DISubroutineType(types: !2943)
!2943 = !{!2921, !403, !2932}
!2944 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2945, file: !2919, line: 145)
!2945 = !DISubprogram(name: "fputws", scope: !2925, file: !2925, line: 763, type: !2946, flags: DIFlagPrototyped, spFlags: 0)
!2946 = !DISubroutineType(types: !2947)
!2947 = !{!184, !414, !2939}
!2948 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2949, file: !2919, line: 146)
!2949 = !DISubprogram(name: "fwide", scope: !2925, file: !2925, line: 573, type: !2950, flags: DIFlagPrototyped, spFlags: 0)
!2950 = !DISubroutineType(types: !2951)
!2951 = !{!184, !2932, !184}
!2952 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2953, file: !2919, line: 147)
!2953 = !DISubprogram(name: "fwprintf", scope: !2925, file: !2925, line: 580, type: !2954, flags: DIFlagPrototyped, spFlags: 0)
!2954 = !DISubroutineType(types: !2955)
!2955 = !{!184, !2939, !414, null}
!2956 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2957, file: !2919, line: 148)
!2957 = !DISubprogram(name: "fwscanf", scope: !2925, file: !2925, line: 621, type: !2954, flags: DIFlagPrototyped, spFlags: 0)
!2958 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2959, file: !2919, line: 149)
!2959 = !DISubprogram(name: "getwc", scope: !2925, file: !2925, line: 728, type: !2930, flags: DIFlagPrototyped, spFlags: 0)
!2960 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2961, file: !2919, line: 150)
!2961 = !DISubprogram(name: "getwchar", scope: !2925, file: !2925, line: 734, type: !2962, flags: DIFlagPrototyped, spFlags: 0)
!2962 = !DISubroutineType(types: !2963)
!2963 = !{!2921}
!2964 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2965, file: !2919, line: 151)
!2965 = !DISubprogram(name: "mbrlen", scope: !2925, file: !2925, line: 307, type: !2966, flags: DIFlagPrototyped, spFlags: 0)
!2966 = !DISubroutineType(types: !2967)
!2967 = !{!2469, !439, !2469, !2968}
!2968 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !2969)
!2969 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2915, size: 64)
!2970 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2971, file: !2919, line: 152)
!2971 = !DISubprogram(name: "mbrtowc", scope: !2925, file: !2925, line: 296, type: !2972, flags: DIFlagPrototyped, spFlags: 0)
!2972 = !DISubroutineType(types: !2973)
!2973 = !{!2469, !404, !439, !2469, !2968}
!2974 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2975, file: !2919, line: 153)
!2975 = !DISubprogram(name: "mbsinit", scope: !2925, file: !2925, line: 292, type: !2976, flags: DIFlagPrototyped, spFlags: 0)
!2976 = !DISubroutineType(types: !2977)
!2977 = !{!184, !2978}
!2978 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2979, size: 64)
!2979 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2915)
!2980 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2981, file: !2919, line: 154)
!2981 = !DISubprogram(name: "mbsrtowcs", scope: !2925, file: !2925, line: 337, type: !2982, flags: DIFlagPrototyped, spFlags: 0)
!2982 = !DISubroutineType(types: !2983)
!2983 = !{!2469, !404, !456, !2469, !2968}
!2984 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2985, file: !2919, line: 155)
!2985 = !DISubprogram(name: "putwc", scope: !2925, file: !2925, line: 742, type: !2942, flags: DIFlagPrototyped, spFlags: 0)
!2986 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2987, file: !2919, line: 156)
!2987 = !DISubprogram(name: "putwchar", scope: !2925, file: !2925, line: 748, type: !2988, flags: DIFlagPrototyped, spFlags: 0)
!2988 = !DISubroutineType(types: !2989)
!2989 = !{!2921, !403}
!2990 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2991, file: !2919, line: 158)
!2991 = !DISubprogram(name: "swprintf", scope: !2925, file: !2925, line: 590, type: !2992, flags: DIFlagPrototyped, spFlags: 0)
!2992 = !DISubroutineType(types: !2993)
!2993 = !{!184, !404, !2469, !414, null}
!2994 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2995, file: !2919, line: 160)
!2995 = !DISubprogram(name: "swscanf", scope: !2925, file: !2925, line: 631, type: !470, flags: DIFlagPrototyped, spFlags: 0)
!2996 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2997, file: !2919, line: 161)
!2997 = !DISubprogram(name: "ungetwc", scope: !2925, file: !2925, line: 771, type: !2998, flags: DIFlagPrototyped, spFlags: 0)
!2998 = !DISubroutineType(types: !2999)
!2999 = !{!2921, !2921, !2932}
!3000 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3001, file: !2919, line: 162)
!3001 = !DISubprogram(name: "vfwprintf", scope: !2925, file: !2925, line: 598, type: !3002, flags: DIFlagPrototyped, spFlags: 0)
!3002 = !DISubroutineType(types: !3003)
!3003 = !{!184, !2939, !414, !3004}
!3004 = !DIDerivedType(tag: DW_TAG_typedef, name: "__gnuc_va_list", file: !3005, line: 48, baseType: !3006)
!3005 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/build/hls_clib/lnx64/tools/hls_llvm_fe/lib/clang/7.0.0/include/stdarg.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3006 = !DIDerivedType(tag: DW_TAG_typedef, name: "__builtin_va_list", file: !1271, baseType: !254)
!3007 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3008, file: !2919, line: 164)
!3008 = !DISubprogram(name: "vfwscanf", scope: !2925, file: !2925, line: 673, type: !3002, flags: DIFlagPrototyped, spFlags: 0)
!3009 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3010, file: !2919, line: 167)
!3010 = !DISubprogram(name: "vswprintf", scope: !2925, file: !2925, line: 611, type: !3011, flags: DIFlagPrototyped, spFlags: 0)
!3011 = !DISubroutineType(types: !3012)
!3012 = !{!184, !404, !2469, !414, !3004}
!3013 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3014, file: !2919, line: 170)
!3014 = !DISubprogram(name: "vswscanf", scope: !2925, file: !2925, line: 685, type: !3015, flags: DIFlagPrototyped, spFlags: 0)
!3015 = !DISubroutineType(types: !3016)
!3016 = !{!184, !414, !414, !3004}
!3017 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3018, file: !2919, line: 172)
!3018 = !DISubprogram(name: "vwprintf", scope: !2925, file: !2925, line: 606, type: !3019, flags: DIFlagPrototyped, spFlags: 0)
!3019 = !DISubroutineType(types: !3020)
!3020 = !{!184, !414, !3004}
!3021 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3022, file: !2919, line: 174)
!3022 = !DISubprogram(name: "vwscanf", scope: !2925, file: !2925, line: 681, type: !3019, flags: DIFlagPrototyped, spFlags: 0)
!3023 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3024, file: !2919, line: 176)
!3024 = !DISubprogram(name: "wcrtomb", scope: !2925, file: !2925, line: 301, type: !3025, flags: DIFlagPrototyped, spFlags: 0)
!3025 = !DISubroutineType(types: !3026)
!3026 = !{!2469, !504, !403, !2968}
!3027 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3028, file: !2919, line: 177)
!3028 = !DISubprogram(name: "wcscat", scope: !2925, file: !2925, line: 97, type: !508, flags: DIFlagPrototyped, spFlags: 0)
!3029 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3030, file: !2919, line: 178)
!3030 = !DISubprogram(name: "wcscmp", scope: !2925, file: !2925, line: 106, type: !512, flags: DIFlagPrototyped, spFlags: 0)
!3031 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3032, file: !2919, line: 179)
!3032 = !DISubprogram(name: "wcscoll", scope: !2925, file: !2925, line: 131, type: !512, flags: DIFlagPrototyped, spFlags: 0)
!3033 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3034, file: !2919, line: 180)
!3034 = !DISubprogram(name: "wcscpy", scope: !2925, file: !2925, line: 87, type: !508, flags: DIFlagPrototyped, spFlags: 0)
!3035 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3036, file: !2919, line: 181)
!3036 = !DISubprogram(name: "wcscspn", scope: !2925, file: !2925, line: 187, type: !3037, flags: DIFlagPrototyped, spFlags: 0)
!3037 = !DISubroutineType(types: !3038)
!3038 = !{!2469, !415, !415}
!3039 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3040, file: !2919, line: 182)
!3040 = !DISubprogram(name: "wcsftime", scope: !2925, file: !2925, line: 835, type: !3041, flags: DIFlagPrototyped, spFlags: 0)
!3041 = !DISubroutineType(types: !3042)
!3042 = !{!2469, !404, !2469, !414, !526}
!3043 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3044, file: !2919, line: 183)
!3044 = !DISubprogram(name: "wcslen", scope: !2925, file: !2925, line: 222, type: !3045, flags: DIFlagPrototyped, spFlags: 0)
!3045 = !DISubroutineType(types: !3046)
!3046 = !{!2469, !415}
!3047 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3048, file: !2919, line: 184)
!3048 = !DISubprogram(name: "wcsncat", scope: !2925, file: !2925, line: 101, type: !3049, flags: DIFlagPrototyped, spFlags: 0)
!3049 = !DISubroutineType(types: !3050)
!3050 = !{!402, !404, !414, !2469}
!3051 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3052, file: !2919, line: 185)
!3052 = !DISubprogram(name: "wcsncmp", scope: !2925, file: !2925, line: 109, type: !3053, flags: DIFlagPrototyped, spFlags: 0)
!3053 = !DISubroutineType(types: !3054)
!3054 = !{!184, !415, !415, !2469}
!3055 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3056, file: !2919, line: 186)
!3056 = !DISubprogram(name: "wcsncpy", scope: !2925, file: !2925, line: 92, type: !3049, flags: DIFlagPrototyped, spFlags: 0)
!3057 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3058, file: !2919, line: 187)
!3058 = !DISubprogram(name: "wcsrtombs", scope: !2925, file: !2925, line: 343, type: !3059, flags: DIFlagPrototyped, spFlags: 0)
!3059 = !DISubroutineType(types: !3060)
!3060 = !{!2469, !504, !548, !2469, !2968}
!3061 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3062, file: !2919, line: 188)
!3062 = !DISubprogram(name: "wcsspn", scope: !2925, file: !2925, line: 191, type: !3037, flags: DIFlagPrototyped, spFlags: 0)
!3063 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3064, file: !2919, line: 189)
!3064 = !DISubprogram(name: "wcstod", scope: !2925, file: !2925, line: 377, type: !554, flags: DIFlagPrototyped, spFlags: 0)
!3065 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3066, file: !2919, line: 191)
!3066 = !DISubprogram(name: "wcstof", scope: !2925, file: !2925, line: 382, type: !561, flags: DIFlagPrototyped, spFlags: 0)
!3067 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3068, file: !2919, line: 193)
!3068 = !DISubprogram(name: "wcstok", scope: !2925, file: !2925, line: 217, type: !565, flags: DIFlagPrototyped, spFlags: 0)
!3069 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3070, file: !2919, line: 194)
!3070 = !DISubprogram(name: "wcstol", scope: !2925, file: !2925, line: 428, type: !3071, flags: DIFlagPrototyped, spFlags: 0)
!3071 = !DISubroutineType(types: !3072)
!3072 = !{!1675, !414, !557, !184}
!3073 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3074, file: !2919, line: 195)
!3074 = !DISubprogram(name: "wcstoul", scope: !2925, file: !2925, line: 433, type: !3075, flags: DIFlagPrototyped, spFlags: 0)
!3075 = !DISubroutineType(types: !3076)
!3076 = !{!1324, !414, !557, !184}
!3077 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3078, file: !2919, line: 196)
!3078 = !DISubprogram(name: "wcsxfrm", scope: !2925, file: !2925, line: 135, type: !3079, flags: DIFlagPrototyped, spFlags: 0)
!3079 = !DISubroutineType(types: !3080)
!3080 = !{!2469, !404, !414, !2469}
!3081 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3082, file: !2919, line: 197)
!3082 = !DISubprogram(name: "wctob", scope: !2925, file: !2925, line: 288, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3083 = !DISubroutineType(types: !3084)
!3084 = !{!184, !2921}
!3085 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3086, file: !2919, line: 198)
!3086 = !DISubprogram(name: "wmemcmp", scope: !2925, file: !2925, line: 258, type: !3053, flags: DIFlagPrototyped, spFlags: 0)
!3087 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3088, file: !2919, line: 199)
!3088 = !DISubprogram(name: "wmemcpy", scope: !2925, file: !2925, line: 262, type: !3049, flags: DIFlagPrototyped, spFlags: 0)
!3089 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3090, file: !2919, line: 200)
!3090 = !DISubprogram(name: "wmemmove", scope: !2925, file: !2925, line: 267, type: !3091, flags: DIFlagPrototyped, spFlags: 0)
!3091 = !DISubroutineType(types: !3092)
!3092 = !{!402, !402, !415, !2469}
!3093 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3094, file: !2919, line: 201)
!3094 = !DISubprogram(name: "wmemset", scope: !2925, file: !2925, line: 271, type: !3095, flags: DIFlagPrototyped, spFlags: 0)
!3095 = !DISubroutineType(types: !3096)
!3096 = !{!402, !402, !403, !2469}
!3097 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3098, file: !2919, line: 202)
!3098 = !DISubprogram(name: "wprintf", scope: !2925, file: !2925, line: 587, type: !597, flags: DIFlagPrototyped, spFlags: 0)
!3099 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3100, file: !2919, line: 203)
!3100 = !DISubprogram(name: "wscanf", scope: !2925, file: !2925, line: 628, type: !597, flags: DIFlagPrototyped, spFlags: 0)
!3101 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3102, file: !2919, line: 204)
!3102 = !DISubprogram(name: "wcschr", scope: !2925, file: !2925, line: 164, type: !603, flags: DIFlagPrototyped, spFlags: 0)
!3103 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3104, file: !2919, line: 205)
!3104 = !DISubprogram(name: "wcspbrk", scope: !2925, file: !2925, line: 201, type: !607, flags: DIFlagPrototyped, spFlags: 0)
!3105 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3106, file: !2919, line: 206)
!3106 = !DISubprogram(name: "wcsrchr", scope: !2925, file: !2925, line: 174, type: !603, flags: DIFlagPrototyped, spFlags: 0)
!3107 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3108, file: !2919, line: 207)
!3108 = !DISubprogram(name: "wcsstr", scope: !2925, file: !2925, line: 212, type: !607, flags: DIFlagPrototyped, spFlags: 0)
!3109 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3110, file: !2919, line: 208)
!3110 = !DISubprogram(name: "wmemchr", scope: !2925, file: !2925, line: 253, type: !3111, flags: DIFlagPrototyped, spFlags: 0)
!3111 = !DISubroutineType(types: !3112)
!3112 = !{!402, !415, !403, !2469}
!3113 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3114, file: !2919, line: 248)
!3114 = !DISubprogram(name: "wcstold", scope: !2925, file: !2925, line: 384, type: !620, flags: DIFlagPrototyped, spFlags: 0)
!3115 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3116, file: !2919, line: 257)
!3116 = !DISubprogram(name: "wcstoll", scope: !2925, file: !2925, line: 441, type: !3117, flags: DIFlagPrototyped, spFlags: 0)
!3117 = !DISubroutineType(types: !3118)
!3118 = !{!1413, !414, !557, !184}
!3119 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3120, file: !2919, line: 258)
!3120 = !DISubprogram(name: "wcstoull", scope: !2925, file: !2925, line: 448, type: !3121, flags: DIFlagPrototyped, spFlags: 0)
!3121 = !DISubroutineType(types: !3122)
!3122 = !{!1292, !414, !557, !184}
!3123 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3114, file: !2919, line: 264)
!3124 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3116, file: !2919, line: 265)
!3125 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3120, file: !2919, line: 266)
!3126 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3066, file: !2919, line: 280)
!3127 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3008, file: !2919, line: 283)
!3128 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3014, file: !2919, line: 286)
!3129 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3022, file: !2919, line: 289)
!3130 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3114, file: !2919, line: 293)
!3131 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3116, file: !2919, line: 294)
!3132 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3120, file: !2919, line: 295)
!3133 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3134, file: !3136, line: 48)
!3134 = !DIDerivedType(tag: DW_TAG_typedef, name: "int8_t", file: !2023, line: 24, baseType: !3135)
!3135 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int8_t", file: !2010, line: 36, baseType: !12)
!3136 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdint", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3137 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2022, file: !3136, line: 49)
!3138 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2173, file: !3136, line: 50)
!3139 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2331, file: !3136, line: 51)
!3140 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3141, file: !3136, line: 53)
!3141 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast8_t", file: !3142, line: 58, baseType: !12)
!3142 = !DIFile(filename: "/usr/include/stdint.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3143 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3144, file: !3136, line: 54)
!3144 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast16_t", file: !3142, line: 60, baseType: !1675)
!3145 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3146, file: !3136, line: 55)
!3146 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast32_t", file: !3142, line: 61, baseType: !1675)
!3147 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3148, file: !3136, line: 56)
!3148 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_fast64_t", file: !3142, line: 62, baseType: !1675)
!3149 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3150, file: !3136, line: 58)
!3150 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least8_t", file: !3142, line: 43, baseType: !3151)
!3151 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least8_t", file: !2010, line: 51, baseType: !3135)
!3152 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3153, file: !3136, line: 59)
!3153 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least16_t", file: !3142, line: 44, baseType: !3154)
!3154 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least16_t", file: !2010, line: 53, baseType: !2024)
!3155 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3156, file: !3136, line: 60)
!3156 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least32_t", file: !3142, line: 45, baseType: !3157)
!3157 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least32_t", file: !2010, line: 55, baseType: !2174)
!3158 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3159, file: !3136, line: 61)
!3159 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_least64_t", file: !3142, line: 46, baseType: !3160)
!3160 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int_least64_t", file: !2010, line: 57, baseType: !2332)
!3161 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3162, file: !3136, line: 63)
!3162 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !3142, line: 101, baseType: !3163)
!3163 = !DIDerivedType(tag: DW_TAG_typedef, name: "__intmax_t", file: !2010, line: 71, baseType: !1675)
!3164 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3165, file: !3136, line: 64)
!3165 = !DIDerivedType(tag: DW_TAG_typedef, name: "intptr_t", file: !3142, line: 87, baseType: !1675)
!3166 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3167, file: !3136, line: 66)
!3167 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !2008, line: 24, baseType: !3168)
!3168 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !2010, line: 37, baseType: !100)
!3169 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2007, file: !3136, line: 67)
!3170 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2160, file: !3136, line: 68)
!3171 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2321, file: !3136, line: 69)
!3172 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3173, file: !3136, line: 71)
!3173 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast8_t", file: !3142, line: 71, baseType: !100)
!3174 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3175, file: !3136, line: 72)
!3175 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast16_t", file: !3142, line: 73, baseType: !1324)
!3176 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3177, file: !3136, line: 73)
!3177 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast32_t", file: !3142, line: 74, baseType: !1324)
!3178 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3179, file: !3136, line: 74)
!3179 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_fast64_t", file: !3142, line: 75, baseType: !1324)
!3180 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3181, file: !3136, line: 76)
!3181 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least8_t", file: !3142, line: 49, baseType: !3182)
!3182 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least8_t", file: !2010, line: 52, baseType: !3168)
!3183 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3184, file: !3136, line: 77)
!3184 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least16_t", file: !3142, line: 50, baseType: !3185)
!3185 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least16_t", file: !2010, line: 54, baseType: !2009)
!3186 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3187, file: !3136, line: 78)
!3187 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least32_t", file: !3142, line: 51, baseType: !3188)
!3188 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least32_t", file: !2010, line: 56, baseType: !2161)
!3189 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3190, file: !3136, line: 79)
!3190 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint_least64_t", file: !3142, line: 52, baseType: !3191)
!3191 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint_least64_t", file: !2010, line: 58, baseType: !2322)
!3192 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3193, file: !3136, line: 81)
!3193 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintmax_t", file: !3142, line: 102, baseType: !3194)
!3194 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintmax_t", file: !2010, line: 72, baseType: !1324)
!3195 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3196, file: !3136, line: 82)
!3196 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !3142, line: 90, baseType: !1324)
!3197 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !648, file: !3198, line: 53)
!3198 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/clocale", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3199 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3200, file: !3198, line: 54)
!3200 = !DISubprogram(name: "setlocale", scope: !3201, file: !3201, line: 122, type: !653, flags: DIFlagPrototyped, spFlags: 0)
!3201 = !DIFile(filename: "/usr/include/locale.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3202 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3203, file: !3198, line: 55)
!3203 = !DISubprogram(name: "localeconv", scope: !3201, file: !3201, line: 125, type: !657, flags: DIFlagPrototyped, spFlags: 0)
!3204 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3205, file: !3207, line: 64)
!3205 = !DISubprogram(name: "isalnum", scope: !3206, file: !3206, line: 108, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3206 = !DIFile(filename: "/usr/include/ctype.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3207 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cctype", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3208 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3209, file: !3207, line: 65)
!3209 = !DISubprogram(name: "isalpha", scope: !3206, file: !3206, line: 109, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3210 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3211, file: !3207, line: 66)
!3211 = !DISubprogram(name: "iscntrl", scope: !3206, file: !3206, line: 110, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3212 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3213, file: !3207, line: 67)
!3213 = !DISubprogram(name: "isdigit", scope: !3206, file: !3206, line: 111, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3214 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3215, file: !3207, line: 68)
!3215 = !DISubprogram(name: "isgraph", scope: !3206, file: !3206, line: 113, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3216 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3217, file: !3207, line: 69)
!3217 = !DISubprogram(name: "islower", scope: !3206, file: !3206, line: 112, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3218 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3219, file: !3207, line: 70)
!3219 = !DISubprogram(name: "isprint", scope: !3206, file: !3206, line: 114, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3220 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3221, file: !3207, line: 71)
!3221 = !DISubprogram(name: "ispunct", scope: !3206, file: !3206, line: 115, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3222 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3223, file: !3207, line: 72)
!3223 = !DISubprogram(name: "isspace", scope: !3206, file: !3206, line: 116, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3224 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3225, file: !3207, line: 73)
!3225 = !DISubprogram(name: "isupper", scope: !3206, file: !3206, line: 117, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3226 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3227, file: !3207, line: 74)
!3227 = !DISubprogram(name: "isxdigit", scope: !3206, file: !3206, line: 118, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3228 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3229, file: !3207, line: 75)
!3229 = !DISubprogram(name: "tolower", scope: !3206, file: !3206, line: 122, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3230 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3231, file: !3207, line: 76)
!3231 = !DISubprogram(name: "toupper", scope: !3206, file: !3206, line: 125, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3232 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3233, file: !3207, line: 87)
!3233 = !DISubprogram(name: "isblank", scope: !3206, file: !3206, line: 130, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3234 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3235, file: !3237, line: 44)
!3235 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", scope: !175, file: !3236, line: 238, baseType: !1324)
!3236 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/x86_64-pc-linux-gnu/bits/c++config.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3237 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/ext/new_allocator.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3238 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3239, file: !3237, line: 45)
!3239 = !DIDerivedType(tag: DW_TAG_typedef, name: "ptrdiff_t", scope: !175, file: !3236, line: 239, baseType: !1675)
!3240 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3241, file: !3243, line: 98)
!3241 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !3242, line: 7, baseType: !397)
!3242 = !DIFile(filename: "/usr/include/bits/types/FILE.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3243 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cstdio", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3244 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3245, file: !3243, line: 99)
!3245 = !DIDerivedType(tag: DW_TAG_typedef, name: "fpos_t", file: !3246, line: 84, baseType: !3247)
!3246 = !DIFile(filename: "/usr/include/stdio.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3247 = !DIDerivedType(tag: DW_TAG_typedef, name: "__fpos_t", file: !3248, line: 14, baseType: !881)
!3248 = !DIFile(filename: "/usr/include/bits/types/__fpos_t.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3249 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3250, file: !3243, line: 101)
!3250 = !DISubprogram(name: "clearerr", scope: !3246, file: !3246, line: 763, type: !3251, flags: DIFlagPrototyped, spFlags: 0)
!3251 = !DISubroutineType(types: !3252)
!3252 = !{null, !3253}
!3253 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3241, size: 64)
!3254 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3255, file: !3243, line: 102)
!3255 = !DISubprogram(name: "fclose", scope: !3246, file: !3246, line: 213, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3256 = !DISubroutineType(types: !3257)
!3257 = !{!184, !3253}
!3258 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3259, file: !3243, line: 103)
!3259 = !DISubprogram(name: "feof", scope: !3246, file: !3246, line: 765, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3260 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3261, file: !3243, line: 104)
!3261 = !DISubprogram(name: "ferror", scope: !3246, file: !3246, line: 767, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3262 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3263, file: !3243, line: 105)
!3263 = !DISubprogram(name: "fflush", scope: !3246, file: !3246, line: 218, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3264 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3265, file: !3243, line: 106)
!3265 = !DISubprogram(name: "fgetc", scope: !3246, file: !3246, line: 491, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3266 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3267, file: !3243, line: 107)
!3267 = !DISubprogram(name: "fgetpos", scope: !3246, file: !3246, line: 737, type: !3268, flags: DIFlagPrototyped, spFlags: 0)
!3268 = !DISubroutineType(types: !3269)
!3269 = !{!184, !3270, !3271}
!3270 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3253)
!3271 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !3272)
!3272 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3245, size: 64)
!3273 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3274, file: !3243, line: 108)
!3274 = !DISubprogram(name: "fgets", scope: !3246, file: !3246, line: 570, type: !3275, flags: DIFlagPrototyped, spFlags: 0)
!3275 = !DISubroutineType(types: !3276)
!3276 = !{!505, !504, !184, !3270}
!3277 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3278, file: !3243, line: 109)
!3278 = !DISubprogram(name: "fopen", scope: !3246, file: !3246, line: 246, type: !3279, flags: DIFlagPrototyped, spFlags: 0)
!3279 = !DISubroutineType(types: !3280)
!3280 = !{!3253, !439, !439}
!3281 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3282, file: !3243, line: 110)
!3282 = !DISubprogram(name: "fprintf", scope: !3246, file: !3246, line: 326, type: !3283, flags: DIFlagPrototyped, spFlags: 0)
!3283 = !DISubroutineType(types: !3284)
!3284 = !{!184, !3270, !439, null}
!3285 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3286, file: !3243, line: 111)
!3286 = !DISubprogram(name: "fputc", scope: !3246, file: !3246, line: 527, type: !3287, flags: DIFlagPrototyped, spFlags: 0)
!3287 = !DISubroutineType(types: !3288)
!3288 = !{!184, !184, !3253}
!3289 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3290, file: !3243, line: 112)
!3290 = !DISubprogram(name: "fputs", scope: !3246, file: !3246, line: 632, type: !3291, flags: DIFlagPrototyped, spFlags: 0)
!3291 = !DISubroutineType(types: !3292)
!3292 = !{!184, !439, !3270}
!3293 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3294, file: !3243, line: 113)
!3294 = !DISubprogram(name: "fread", scope: !3246, file: !3246, line: 652, type: !3295, flags: DIFlagPrototyped, spFlags: 0)
!3295 = !DISubroutineType(types: !3296)
!3296 = !{!2469, !930, !2469, !2469, !3270}
!3297 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3298, file: !3243, line: 114)
!3298 = !DISubprogram(name: "freopen", scope: !3246, file: !3246, line: 252, type: !3299, flags: DIFlagPrototyped, spFlags: 0)
!3299 = !DISubroutineType(types: !3300)
!3300 = !{!3253, !439, !439, !3270}
!3301 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3302, file: !3243, line: 115)
!3302 = !DISubprogram(name: "fscanf", scope: !3246, file: !3246, line: 391, type: !3283, flags: DIFlagPrototyped, spFlags: 0)
!3303 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3304, file: !3243, line: 116)
!3304 = !DISubprogram(name: "fseek", scope: !3246, file: !3246, line: 690, type: !3305, flags: DIFlagPrototyped, spFlags: 0)
!3305 = !DISubroutineType(types: !3306)
!3306 = !{!184, !3253, !1675, !184}
!3307 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3308, file: !3243, line: 117)
!3308 = !DISubprogram(name: "fsetpos", scope: !3246, file: !3246, line: 742, type: !3309, flags: DIFlagPrototyped, spFlags: 0)
!3309 = !DISubroutineType(types: !3310)
!3310 = !{!184, !3253, !3311}
!3311 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3312, size: 64)
!3312 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !3245)
!3313 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3314, file: !3243, line: 118)
!3314 = !DISubprogram(name: "ftell", scope: !3246, file: !3246, line: 695, type: !3315, flags: DIFlagPrototyped, spFlags: 0)
!3315 = !DISubroutineType(types: !3316)
!3316 = !{!1675, !3253}
!3317 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3318, file: !3243, line: 119)
!3318 = !DISubprogram(name: "fwrite", scope: !3246, file: !3246, line: 658, type: !3319, flags: DIFlagPrototyped, spFlags: 0)
!3319 = !DISubroutineType(types: !3320)
!3320 = !{!2469, !955, !2469, !2469, !3270}
!3321 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3322, file: !3243, line: 120)
!3322 = !DISubprogram(name: "getc", scope: !3246, file: !3246, line: 492, type: !3256, flags: DIFlagPrototyped, spFlags: 0)
!3323 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3324, file: !3243, line: 121)
!3324 = !DISubprogram(name: "getchar", scope: !3246, file: !3246, line: 498, type: !308, flags: DIFlagPrototyped, spFlags: 0)
!3325 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3326, file: !3243, line: 126)
!3326 = !DISubprogram(name: "perror", scope: !3246, file: !3246, line: 781, type: !962, flags: DIFlagPrototyped, spFlags: 0)
!3327 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3328, file: !3243, line: 127)
!3328 = !DISubprogram(name: "printf", scope: !3246, file: !3246, line: 332, type: !966, flags: DIFlagPrototyped, spFlags: 0)
!3329 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3330, file: !3243, line: 128)
!3330 = !DISubprogram(name: "putc", scope: !3246, file: !3246, line: 528, type: !3287, flags: DIFlagPrototyped, spFlags: 0)
!3331 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3332, file: !3243, line: 129)
!3332 = !DISubprogram(name: "putchar", scope: !3246, file: !3246, line: 534, type: !663, flags: DIFlagPrototyped, spFlags: 0)
!3333 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3334, file: !3243, line: 130)
!3334 = !DISubprogram(name: "puts", scope: !3246, file: !3246, line: 638, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!3335 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3336, file: !3243, line: 131)
!3336 = !DISubprogram(name: "remove", scope: !3246, file: !3246, line: 146, type: !727, flags: DIFlagPrototyped, spFlags: 0)
!3337 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3338, file: !3243, line: 132)
!3338 = !DISubprogram(name: "rename", scope: !3246, file: !3246, line: 148, type: !978, flags: DIFlagPrototyped, spFlags: 0)
!3339 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3340, file: !3243, line: 133)
!3340 = !DISubprogram(name: "rewind", scope: !3246, file: !3246, line: 700, type: !3251, flags: DIFlagPrototyped, spFlags: 0)
!3341 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3342, file: !3243, line: 134)
!3342 = !DISubprogram(name: "scanf", scope: !3246, file: !3246, line: 397, type: !966, flags: DIFlagPrototyped, spFlags: 0)
!3343 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3344, file: !3243, line: 135)
!3344 = !DISubprogram(name: "setbuf", scope: !3246, file: !3246, line: 304, type: !3345, flags: DIFlagPrototyped, spFlags: 0)
!3345 = !DISubroutineType(types: !3346)
!3346 = !{null, !3270, !504}
!3347 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3348, file: !3243, line: 136)
!3348 = !DISubprogram(name: "setvbuf", scope: !3246, file: !3246, line: 308, type: !3349, flags: DIFlagPrototyped, spFlags: 0)
!3349 = !DISubroutineType(types: !3350)
!3350 = !{!184, !3270, !504, !184, !2469}
!3351 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3352, file: !3243, line: 137)
!3352 = !DISubprogram(name: "sprintf", scope: !3246, file: !3246, line: 334, type: !994, flags: DIFlagPrototyped, spFlags: 0)
!3353 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3354, file: !3243, line: 138)
!3354 = !DISubprogram(name: "sscanf", scope: !3246, file: !3246, line: 399, type: !998, flags: DIFlagPrototyped, spFlags: 0)
!3355 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3356, file: !3243, line: 139)
!3356 = !DISubprogram(name: "tmpfile", scope: !3246, file: !3246, line: 173, type: !3357, flags: DIFlagPrototyped, spFlags: 0)
!3357 = !DISubroutineType(types: !3358)
!3358 = !{!3253}
!3359 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3360, file: !3243, line: 141)
!3360 = !DISubprogram(name: "tmpnam", scope: !3246, file: !3246, line: 187, type: !1006, flags: DIFlagPrototyped, spFlags: 0)
!3361 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3362, file: !3243, line: 143)
!3362 = !DISubprogram(name: "ungetc", scope: !3246, file: !3246, line: 645, type: !3287, flags: DIFlagPrototyped, spFlags: 0)
!3363 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3364, file: !3243, line: 144)
!3364 = !DISubprogram(name: "vfprintf", scope: !3246, file: !3246, line: 341, type: !3365, flags: DIFlagPrototyped, spFlags: 0)
!3365 = !DISubroutineType(types: !3366)
!3366 = !{!184, !3270, !439, !3004}
!3367 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3368, file: !3243, line: 145)
!3368 = !DISubprogram(name: "vprintf", scope: !3246, file: !3246, line: 347, type: !3369, flags: DIFlagPrototyped, spFlags: 0)
!3369 = !DISubroutineType(types: !3370)
!3370 = !{!184, !439, !3004}
!3371 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3372, file: !3243, line: 146)
!3372 = !DISubprogram(name: "vsprintf", scope: !3246, file: !3246, line: 349, type: !3373, flags: DIFlagPrototyped, spFlags: 0)
!3373 = !DISubroutineType(types: !3374)
!3374 = !{!184, !504, !439, !3004}
!3375 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3376, file: !3243, line: 175)
!3376 = !DISubprogram(name: "snprintf", scope: !3246, file: !3246, line: 354, type: !3377, flags: DIFlagPrototyped, spFlags: 0)
!3377 = !DISubroutineType(types: !3378)
!3378 = !{!184, !504, !2469, !439, null}
!3379 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3380, file: !3243, line: 176)
!3380 = !DISubprogram(name: "vfscanf", scope: !3246, file: !3246, line: 434, type: !3365, flags: DIFlagPrototyped, spFlags: 0)
!3381 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3382, file: !3243, line: 177)
!3382 = !DISubprogram(name: "vscanf", scope: !3246, file: !3246, line: 442, type: !3369, flags: DIFlagPrototyped, spFlags: 0)
!3383 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3384, file: !3243, line: 178)
!3384 = !DISubprogram(name: "vsnprintf", scope: !3246, file: !3246, line: 358, type: !3385, flags: DIFlagPrototyped, spFlags: 0)
!3385 = !DISubroutineType(types: !3386)
!3386 = !{!184, !504, !2469, !439, !3004}
!3387 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !618, entity: !3388, file: !3243, line: 179)
!3388 = !DISubprogram(name: "vsscanf", scope: !3246, file: !3246, line: 446, type: !3389, flags: DIFlagPrototyped, spFlags: 0)
!3389 = !DISubroutineType(types: !3390)
!3390 = !{!184, !439, !439, !3004}
!3391 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3376, file: !3243, line: 185)
!3392 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3380, file: !3243, line: 186)
!3393 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3382, file: !3243, line: 187)
!3394 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3384, file: !3243, line: 188)
!3395 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3388, file: !3243, line: 189)
!3396 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3397, file: !3401, line: 82)
!3397 = !DIDerivedType(tag: DW_TAG_typedef, name: "wctrans_t", file: !3398, line: 48, baseType: !3399)
!3398 = !DIFile(filename: "/usr/include/wctype.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3399 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3400, size: 64)
!3400 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !2174)
!3401 = !DIFile(filename: "/tools/batonroot/rodin/devkits/lnx64/gcc-8.3.0/lib/gcc/x86_64-pc-linux-gnu/8.3.0/../../../../include/c++/8.3.0/cwctype", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3402 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3403, file: !3401, line: 83)
!3403 = !DIDerivedType(tag: DW_TAG_typedef, name: "wctype_t", file: !3404, line: 38, baseType: !1324)
!3404 = !DIFile(filename: "/usr/include/bits/wctype-wchar.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!3405 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !2921, file: !3401, line: 84)
!3406 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3407, file: !3401, line: 86)
!3407 = !DISubprogram(name: "iswalnum", scope: !3404, file: !3404, line: 95, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3408 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3409, file: !3401, line: 87)
!3409 = !DISubprogram(name: "iswalpha", scope: !3404, file: !3404, line: 101, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3410 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3411, file: !3401, line: 89)
!3411 = !DISubprogram(name: "iswblank", scope: !3404, file: !3404, line: 146, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3412 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3413, file: !3401, line: 91)
!3413 = !DISubprogram(name: "iswcntrl", scope: !3404, file: !3404, line: 104, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3414 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3415, file: !3401, line: 92)
!3415 = !DISubprogram(name: "iswctype", scope: !3404, file: !3404, line: 159, type: !3416, flags: DIFlagPrototyped, spFlags: 0)
!3416 = !DISubroutineType(types: !3417)
!3417 = !{!184, !2921, !3403}
!3418 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3419, file: !3401, line: 93)
!3419 = !DISubprogram(name: "iswdigit", scope: !3404, file: !3404, line: 108, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3420 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3421, file: !3401, line: 94)
!3421 = !DISubprogram(name: "iswgraph", scope: !3404, file: !3404, line: 112, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3422 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3423, file: !3401, line: 95)
!3423 = !DISubprogram(name: "iswlower", scope: !3404, file: !3404, line: 117, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3424 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3425, file: !3401, line: 96)
!3425 = !DISubprogram(name: "iswprint", scope: !3404, file: !3404, line: 120, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3426 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3427, file: !3401, line: 97)
!3427 = !DISubprogram(name: "iswpunct", scope: !3404, file: !3404, line: 125, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3428 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3429, file: !3401, line: 98)
!3429 = !DISubprogram(name: "iswspace", scope: !3404, file: !3404, line: 130, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3430 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3431, file: !3401, line: 99)
!3431 = !DISubprogram(name: "iswupper", scope: !3404, file: !3404, line: 135, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3432 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3433, file: !3401, line: 100)
!3433 = !DISubprogram(name: "iswxdigit", scope: !3404, file: !3404, line: 140, type: !3083, flags: DIFlagPrototyped, spFlags: 0)
!3434 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3435, file: !3401, line: 101)
!3435 = !DISubprogram(name: "towctrans", scope: !3398, file: !3398, line: 55, type: !3436, flags: DIFlagPrototyped, spFlags: 0)
!3436 = !DISubroutineType(types: !3437)
!3437 = !{!2921, !2921, !3397}
!3438 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3439, file: !3401, line: 102)
!3439 = !DISubprogram(name: "towlower", scope: !3404, file: !3404, line: 166, type: !3440, flags: DIFlagPrototyped, spFlags: 0)
!3440 = !DISubroutineType(types: !3441)
!3441 = !{!2921, !2921}
!3442 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3443, file: !3401, line: 103)
!3443 = !DISubprogram(name: "towupper", scope: !3404, file: !3404, line: 169, type: !3440, flags: DIFlagPrototyped, spFlags: 0)
!3444 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3445, file: !3401, line: 104)
!3445 = !DISubprogram(name: "wctrans", scope: !3398, file: !3398, line: 52, type: !3446, flags: DIFlagPrototyped, spFlags: 0)
!3446 = !DISubroutineType(types: !3447)
!3447 = !{!3397, !311}
!3448 = !DIImportedEntity(tag: DW_TAG_imported_declaration, scope: !175, entity: !3449, file: !3401, line: 105)
!3449 = !DISubprogram(name: "wctype", scope: !3404, file: !3404, line: 155, type: !3450, flags: DIFlagPrototyped, spFlags: 0)
!3450 = !DISubroutineType(types: !3451)
!3451 = !{!3403, !311}
!3452 = !{!"AMD/Xilinx clang version 16.0.6"}
!3453 = !{!"clang version 7.0.0 "}
!3454 = !{i32 2, !"Dwarf Version", i32 4}
!3455 = !{i32 2, !"Debug Info Version", i32 3}
!3456 = !{i32 1, !"wchar_size", i32 4}
!3457 = !{!3458}
!3458 = !{!"fpga.top", !"user", !3459}
!3459 = !DILocation(line: 3, column: 27, scope: !94)
!3460 = !DILocalVariable(name: "target", arg: 1, scope: !94, file: !95, line: 4, type: !98)
!3461 = !DILocation(line: 4, column: 13, scope: !94)
!3462 = !DILocalVariable(name: "i", arg: 2, scope: !94, file: !95, line: 4, type: !101)
!3463 = !DILocation(line: 4, column: 30, scope: !94)
!3464 = !DILocalVariable(name: "j", arg: 3, scope: !94, file: !95, line: 4, type: !101)
!3465 = !DILocation(line: 4, column: 42, scope: !94)
!3466 = !DILocalVariable(name: "k", arg: 4, scope: !94, file: !95, line: 4, type: !101)
!3467 = !DILocation(line: 4, column: 54, scope: !94)
!3468 = !DILocalVariable(name: "l", arg: 5, scope: !94, file: !95, line: 4, type: !101)
!3469 = !DILocation(line: 4, column: 66, scope: !94)
!3470 = !DILocalVariable(name: "value", arg: 6, scope: !94, file: !95, line: 5, type: !101)
!3471 = !DILocation(line: 5, column: 14, scope: !94)
!3472 = !DILocalVariable(name: "write_enable", arg: 7, scope: !94, file: !95, line: 5, type: !104)
!3473 = !DILocation(line: 5, column: 26, scope: !94)
!3474 = !DILocalVariable(name: "result", arg: 8, scope: !94, file: !95, line: 5, type: !105)
!3475 = !DILocation(line: 5, column: 50, scope: !94)
!3476 = !DILocalVariable(name: "status", arg: 9, scope: !94, file: !95, line: 5, type: !105)
!3477 = !DILocation(line: 5, column: 68, scope: !94)
!3478 = !DILocation(line: 9, column: 1, scope: !3479)
!3479 = !DILexicalBlockFile(scope: !94, file: !95, discriminator: 0)
!3480 = !DILocation(line: 10, column: 1, scope: !3479)
!3481 = !DILocation(line: 11, column: 1, scope: !3479)
!3482 = !DILocation(line: 12, column: 1, scope: !3479)
!3483 = !DILocation(line: 13, column: 1, scope: !3479)
!3484 = !DILocation(line: 14, column: 1, scope: !3479)
!3485 = !DILocation(line: 15, column: 1, scope: !3479)
!3486 = !DILocation(line: 16, column: 1, scope: !3479)
!3487 = !DILocation(line: 17, column: 1, scope: !3479)
!3488 = !DILocation(line: 18, column: 1, scope: !3479)
!3489 = !DILocation(line: 19, column: 1, scope: !3479)
!3490 = !DILocation(line: 20, column: 1, scope: !3479)
!3491 = !DILocation(line: 21, column: 1, scope: !3479)
!3492 = !DILocation(line: 22, column: 1, scope: !3479)
!3493 = !DILocation(line: 25, column: 4, scope: !3479)
!3494 = !DILocation(line: 25, column: 11, scope: !3479)
!3495 = !DILocation(line: 26, column: 4, scope: !3479)
!3496 = !DILocation(line: 26, column: 11, scope: !3479)
!3497 = !DILocation(line: 34, column: 11, scope: !3479)
!3498 = !DILocation(line: 34, column: 3, scope: !3479)
!3499 = !DILocation(line: 36, column: 9, scope: !3500)
!3500 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 36, column: 9)
!3501 = distinct !DILexicalBlock(scope: !3479, file: !95, line: 34, column: 19)
!3502 = !DILocation(line: 36, column: 11, scope: !3500)
!3503 = !DILocation(line: 36, column: 9, scope: !3501)
!3504 = !DILocation(line: 36, column: 24, scope: !3500)
!3505 = !DILocation(line: 36, column: 14, scope: !3500)
!3506 = !DILocation(line: 37, column: 22, scope: !3501)
!3507 = !DILocation(line: 37, column: 31, scope: !3508)
!3508 = distinct !DILexicalBlock(scope: !3509, file: !95, line: 37, column: 31)
!3509 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 37, column: 25)
!3510 = !DILocation(line: 37, column: 31, scope: !3509)
!3511 = !DILocation(line: 37, column: 113, scope: !3508)
!3512 = !DILocation(line: 37, column: 46, scope: !3508)
!3513 = !DILocation(line: 37, column: 87, scope: !3508)
!3514 = !DILocation(line: 37, column: 91, scope: !3508)
!3515 = !DILocation(line: 37, column: 45, scope: !3508)
!3516 = !DILocation(line: 37, column: 158, scope: !3508)
!3517 = !DILocation(line: 37, column: 199, scope: !3508)
!3518 = !DILocation(line: 37, column: 127, scope: !3508)
!3519 = !DILocation(line: 37, column: 134, scope: !3508)
!3520 = !DILocation(line: 37, column: 204, scope: !3509)
!3521 = !DILocation(line: 38, column: 5, scope: !3501)
!3522 = !DILocation(line: 40, column: 9, scope: !3523)
!3523 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 40, column: 9)
!3524 = !DILocation(line: 40, column: 11, scope: !3523)
!3525 = !DILocation(line: 40, column: 9, scope: !3501)
!3526 = !DILocation(line: 40, column: 23, scope: !3523)
!3527 = !DILocation(line: 40, column: 14, scope: !3523)
!3528 = !DILocation(line: 41, column: 22, scope: !3501)
!3529 = !DILocation(line: 41, column: 31, scope: !3530)
!3530 = distinct !DILexicalBlock(scope: !3531, file: !95, line: 41, column: 31)
!3531 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 41, column: 25)
!3532 = !DILocation(line: 41, column: 31, scope: !3531)
!3533 = !DILocation(line: 41, column: 119, scope: !3530)
!3534 = !DILocation(line: 41, column: 46, scope: !3530)
!3535 = !DILocation(line: 41, column: 91, scope: !3530)
!3536 = !DILocation(line: 41, column: 95, scope: !3530)
!3537 = !DILocation(line: 41, column: 45, scope: !3530)
!3538 = !DILocation(line: 41, column: 164, scope: !3530)
!3539 = !DILocation(line: 41, column: 209, scope: !3530)
!3540 = !DILocation(line: 41, column: 133, scope: !3530)
!3541 = !DILocation(line: 41, column: 140, scope: !3530)
!3542 = !DILocation(line: 41, column: 214, scope: !3531)
!3543 = !DILocation(line: 42, column: 5, scope: !3501)
!3544 = !DILocation(line: 44, column: 9, scope: !3545)
!3545 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 44, column: 9)
!3546 = !DILocation(line: 44, column: 11, scope: !3545)
!3547 = !DILocation(line: 44, column: 9, scope: !3501)
!3548 = !DILocation(line: 44, column: 21, scope: !3545)
!3549 = !DILocation(line: 44, column: 14, scope: !3545)
!3550 = !DILocation(line: 45, column: 22, scope: !3501)
!3551 = !DILocation(line: 45, column: 31, scope: !3552)
!3552 = distinct !DILexicalBlock(scope: !3553, file: !95, line: 45, column: 31)
!3553 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 45, column: 25)
!3554 = !DILocation(line: 45, column: 31, scope: !3553)
!3555 = !DILocation(line: 45, column: 115, scope: !3552)
!3556 = !DILocation(line: 45, column: 46, scope: !3552)
!3557 = !DILocation(line: 45, column: 90, scope: !3552)
!3558 = !DILocation(line: 45, column: 94, scope: !3552)
!3559 = !DILocation(line: 45, column: 45, scope: !3552)
!3560 = !DILocation(line: 45, column: 160, scope: !3552)
!3561 = !DILocation(line: 45, column: 204, scope: !3552)
!3562 = !DILocation(line: 45, column: 129, scope: !3552)
!3563 = !DILocation(line: 45, column: 136, scope: !3552)
!3564 = !DILocation(line: 45, column: 209, scope: !3553)
!3565 = !DILocation(line: 46, column: 5, scope: !3501)
!3566 = !DILocation(line: 48, column: 9, scope: !3567)
!3567 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 48, column: 9)
!3568 = !DILocation(line: 48, column: 11, scope: !3567)
!3569 = !DILocation(line: 48, column: 18, scope: !3567)
!3570 = !DILocation(line: 48, column: 21, scope: !3567)
!3571 = !DILocation(line: 48, column: 23, scope: !3567)
!3572 = !DILocation(line: 48, column: 31, scope: !3567)
!3573 = !DILocation(line: 48, column: 34, scope: !3567)
!3574 = !DILocation(line: 48, column: 36, scope: !3567)
!3575 = !DILocation(line: 48, column: 9, scope: !3501)
!3576 = !DILocation(line: 48, column: 44, scope: !3567)
!3577 = !DILocation(line: 48, column: 39, scope: !3567)
!3578 = !DILocation(line: 49, column: 22, scope: !3501)
!3579 = !DILocation(line: 49, column: 31, scope: !3580)
!3580 = distinct !DILexicalBlock(scope: !3581, file: !95, line: 49, column: 31)
!3581 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 49, column: 25)
!3582 = !DILocation(line: 49, column: 31, scope: !3581)
!3583 = !DILocation(line: 49, column: 123, scope: !3580)
!3584 = !DILocation(line: 49, column: 46, scope: !3580)
!3585 = !DILocation(line: 49, column: 91, scope: !3580)
!3586 = !DILocation(line: 49, column: 94, scope: !3580)
!3587 = !DILocation(line: 49, column: 97, scope: !3580)
!3588 = !DILocation(line: 49, column: 101, scope: !3580)
!3589 = !DILocation(line: 49, column: 45, scope: !3580)
!3590 = !DILocation(line: 49, column: 168, scope: !3580)
!3591 = !DILocation(line: 49, column: 213, scope: !3580)
!3592 = !DILocation(line: 49, column: 216, scope: !3580)
!3593 = !DILocation(line: 49, column: 219, scope: !3580)
!3594 = !DILocation(line: 49, column: 137, scope: !3580)
!3595 = !DILocation(line: 49, column: 144, scope: !3580)
!3596 = !DILocation(line: 49, column: 224, scope: !3581)
!3597 = !DILocation(line: 50, column: 5, scope: !3501)
!3598 = !DILocation(line: 52, column: 9, scope: !3599)
!3599 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 52, column: 9)
!3600 = !DILocation(line: 52, column: 11, scope: !3599)
!3601 = !DILocation(line: 52, column: 18, scope: !3599)
!3602 = !DILocation(line: 52, column: 21, scope: !3599)
!3603 = !DILocation(line: 52, column: 23, scope: !3599)
!3604 = !DILocation(line: 52, column: 9, scope: !3501)
!3605 = !DILocation(line: 52, column: 32, scope: !3599)
!3606 = !DILocation(line: 52, column: 26, scope: !3599)
!3607 = !DILocation(line: 53, column: 22, scope: !3501)
!3608 = !DILocation(line: 53, column: 31, scope: !3609)
!3609 = distinct !DILexicalBlock(scope: !3610, file: !95, line: 53, column: 31)
!3610 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 53, column: 25)
!3611 = !DILocation(line: 53, column: 31, scope: !3610)
!3612 = !DILocation(line: 53, column: 126, scope: !3609)
!3613 = !DILocation(line: 53, column: 46, scope: !3609)
!3614 = !DILocation(line: 53, column: 95, scope: !3609)
!3615 = !DILocation(line: 53, column: 98, scope: !3609)
!3616 = !DILocation(line: 53, column: 102, scope: !3609)
!3617 = !DILocation(line: 53, column: 45, scope: !3609)
!3618 = !DILocation(line: 53, column: 171, scope: !3609)
!3619 = !DILocation(line: 53, column: 220, scope: !3609)
!3620 = !DILocation(line: 53, column: 223, scope: !3609)
!3621 = !DILocation(line: 53, column: 140, scope: !3609)
!3622 = !DILocation(line: 53, column: 147, scope: !3609)
!3623 = !DILocation(line: 53, column: 228, scope: !3610)
!3624 = !DILocation(line: 54, column: 5, scope: !3501)
!3625 = !DILocation(line: 56, column: 9, scope: !3626)
!3626 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 56, column: 9)
!3627 = !DILocation(line: 56, column: 11, scope: !3626)
!3628 = !DILocation(line: 56, column: 18, scope: !3626)
!3629 = !DILocation(line: 56, column: 21, scope: !3626)
!3630 = !DILocation(line: 56, column: 23, scope: !3626)
!3631 = !DILocation(line: 56, column: 9, scope: !3501)
!3632 = !DILocation(line: 56, column: 33, scope: !3626)
!3633 = !DILocation(line: 56, column: 26, scope: !3626)
!3634 = !DILocation(line: 57, column: 22, scope: !3501)
!3635 = !DILocation(line: 57, column: 31, scope: !3636)
!3636 = distinct !DILexicalBlock(scope: !3637, file: !95, line: 57, column: 31)
!3637 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 57, column: 25)
!3638 = !DILocation(line: 57, column: 31, scope: !3637)
!3639 = !DILocation(line: 57, column: 117, scope: !3636)
!3640 = !DILocation(line: 57, column: 46, scope: !3636)
!3641 = !DILocation(line: 57, column: 89, scope: !3636)
!3642 = !DILocation(line: 57, column: 92, scope: !3636)
!3643 = !DILocation(line: 57, column: 96, scope: !3636)
!3644 = !DILocation(line: 57, column: 45, scope: !3636)
!3645 = !DILocation(line: 57, column: 162, scope: !3636)
!3646 = !DILocation(line: 57, column: 205, scope: !3636)
!3647 = !DILocation(line: 57, column: 208, scope: !3636)
!3648 = !DILocation(line: 57, column: 131, scope: !3636)
!3649 = !DILocation(line: 57, column: 138, scope: !3636)
!3650 = !DILocation(line: 57, column: 213, scope: !3637)
!3651 = !DILocation(line: 58, column: 5, scope: !3501)
!3652 = !DILocation(line: 60, column: 9, scope: !3653)
!3653 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 60, column: 9)
!3654 = !DILocation(line: 60, column: 11, scope: !3653)
!3655 = !DILocation(line: 60, column: 18, scope: !3653)
!3656 = !DILocation(line: 60, column: 21, scope: !3653)
!3657 = !DILocation(line: 60, column: 23, scope: !3653)
!3658 = !DILocation(line: 60, column: 9, scope: !3501)
!3659 = !DILocation(line: 60, column: 33, scope: !3653)
!3660 = !DILocation(line: 60, column: 26, scope: !3653)
!3661 = !DILocation(line: 61, column: 22, scope: !3501)
!3662 = !DILocation(line: 61, column: 31, scope: !3663)
!3663 = distinct !DILexicalBlock(scope: !3664, file: !95, line: 61, column: 31)
!3664 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 61, column: 25)
!3665 = !DILocation(line: 61, column: 31, scope: !3664)
!3666 = !DILocation(line: 61, column: 114, scope: !3663)
!3667 = !DILocation(line: 61, column: 46, scope: !3663)
!3668 = !DILocation(line: 61, column: 86, scope: !3663)
!3669 = !DILocation(line: 61, column: 89, scope: !3663)
!3670 = !DILocation(line: 61, column: 93, scope: !3663)
!3671 = !DILocation(line: 61, column: 45, scope: !3663)
!3672 = !DILocation(line: 61, column: 159, scope: !3663)
!3673 = !DILocation(line: 61, column: 199, scope: !3663)
!3674 = !DILocation(line: 61, column: 202, scope: !3663)
!3675 = !DILocation(line: 61, column: 128, scope: !3663)
!3676 = !DILocation(line: 61, column: 135, scope: !3663)
!3677 = !DILocation(line: 61, column: 207, scope: !3664)
!3678 = !DILocation(line: 62, column: 5, scope: !3501)
!3679 = !DILocation(line: 64, column: 9, scope: !3680)
!3680 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 64, column: 9)
!3681 = !DILocation(line: 64, column: 11, scope: !3680)
!3682 = !DILocation(line: 64, column: 17, scope: !3680)
!3683 = !DILocation(line: 64, column: 20, scope: !3680)
!3684 = !DILocation(line: 64, column: 22, scope: !3680)
!3685 = !DILocation(line: 64, column: 9, scope: !3501)
!3686 = !DILocation(line: 64, column: 32, scope: !3680)
!3687 = !DILocation(line: 64, column: 25, scope: !3680)
!3688 = !DILocation(line: 65, column: 22, scope: !3501)
!3689 = !DILocation(line: 65, column: 31, scope: !3690)
!3690 = distinct !DILexicalBlock(scope: !3691, file: !95, line: 65, column: 31)
!3691 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 65, column: 25)
!3692 = !DILocation(line: 65, column: 31, scope: !3691)
!3693 = !DILocation(line: 65, column: 112, scope: !3690)
!3694 = !DILocation(line: 65, column: 46, scope: !3690)
!3695 = !DILocation(line: 65, column: 84, scope: !3690)
!3696 = !DILocation(line: 65, column: 87, scope: !3690)
!3697 = !DILocation(line: 65, column: 91, scope: !3690)
!3698 = !DILocation(line: 65, column: 45, scope: !3690)
!3699 = !DILocation(line: 65, column: 157, scope: !3690)
!3700 = !DILocation(line: 65, column: 195, scope: !3690)
!3701 = !DILocation(line: 65, column: 198, scope: !3690)
!3702 = !DILocation(line: 65, column: 126, scope: !3690)
!3703 = !DILocation(line: 65, column: 133, scope: !3690)
!3704 = !DILocation(line: 65, column: 203, scope: !3691)
!3705 = !DILocation(line: 66, column: 5, scope: !3501)
!3706 = !DILocation(line: 68, column: 9, scope: !3707)
!3707 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 68, column: 9)
!3708 = !DILocation(line: 68, column: 11, scope: !3707)
!3709 = !DILocation(line: 68, column: 17, scope: !3707)
!3710 = !DILocation(line: 68, column: 20, scope: !3707)
!3711 = !DILocation(line: 68, column: 22, scope: !3707)
!3712 = !DILocation(line: 68, column: 31, scope: !3707)
!3713 = !DILocation(line: 68, column: 34, scope: !3707)
!3714 = !DILocation(line: 68, column: 36, scope: !3707)
!3715 = !DILocation(line: 68, column: 9, scope: !3501)
!3716 = !DILocation(line: 68, column: 44, scope: !3707)
!3717 = !DILocation(line: 68, column: 39, scope: !3707)
!3718 = !DILocation(line: 69, column: 22, scope: !3501)
!3719 = !DILocation(line: 69, column: 31, scope: !3720)
!3720 = distinct !DILexicalBlock(scope: !3721, file: !95, line: 69, column: 31)
!3721 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 69, column: 25)
!3722 = !DILocation(line: 69, column: 31, scope: !3721)
!3723 = !DILocation(line: 69, column: 120, scope: !3720)
!3724 = !DILocation(line: 69, column: 46, scope: !3720)
!3725 = !DILocation(line: 69, column: 89, scope: !3720)
!3726 = !DILocation(line: 69, column: 92, scope: !3720)
!3727 = !DILocation(line: 69, column: 95, scope: !3720)
!3728 = !DILocation(line: 69, column: 99, scope: !3720)
!3729 = !DILocation(line: 69, column: 45, scope: !3720)
!3730 = !DILocation(line: 69, column: 165, scope: !3720)
!3731 = !DILocation(line: 69, column: 208, scope: !3720)
!3732 = !DILocation(line: 69, column: 211, scope: !3720)
!3733 = !DILocation(line: 69, column: 214, scope: !3720)
!3734 = !DILocation(line: 69, column: 134, scope: !3720)
!3735 = !DILocation(line: 69, column: 141, scope: !3720)
!3736 = !DILocation(line: 69, column: 219, scope: !3721)
!3737 = !DILocation(line: 70, column: 5, scope: !3501)
!3738 = !DILocation(line: 72, column: 9, scope: !3739)
!3739 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 72, column: 9)
!3740 = !DILocation(line: 72, column: 11, scope: !3739)
!3741 = !DILocation(line: 72, column: 17, scope: !3739)
!3742 = !DILocation(line: 72, column: 20, scope: !3739)
!3743 = !DILocation(line: 72, column: 22, scope: !3739)
!3744 = !DILocation(line: 72, column: 28, scope: !3739)
!3745 = !DILocation(line: 72, column: 31, scope: !3739)
!3746 = !DILocation(line: 72, column: 33, scope: !3739)
!3747 = !DILocation(line: 72, column: 42, scope: !3739)
!3748 = !DILocation(line: 72, column: 45, scope: !3739)
!3749 = !DILocation(line: 72, column: 47, scope: !3739)
!3750 = !DILocation(line: 72, column: 9, scope: !3501)
!3751 = !DILocation(line: 72, column: 55, scope: !3739)
!3752 = !DILocation(line: 72, column: 50, scope: !3739)
!3753 = !DILocation(line: 73, column: 23, scope: !3501)
!3754 = !DILocation(line: 73, column: 32, scope: !3755)
!3755 = distinct !DILexicalBlock(scope: !3756, file: !95, line: 73, column: 32)
!3756 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 73, column: 26)
!3757 = !DILocation(line: 73, column: 32, scope: !3756)
!3758 = !DILocation(line: 73, column: 116, scope: !3755)
!3759 = !DILocation(line: 73, column: 47, scope: !3755)
!3760 = !DILocation(line: 73, column: 82, scope: !3755)
!3761 = !DILocation(line: 73, column: 85, scope: !3755)
!3762 = !DILocation(line: 73, column: 88, scope: !3755)
!3763 = !DILocation(line: 73, column: 91, scope: !3755)
!3764 = !DILocation(line: 73, column: 95, scope: !3755)
!3765 = !DILocation(line: 73, column: 46, scope: !3755)
!3766 = !DILocation(line: 73, column: 161, scope: !3755)
!3767 = !DILocation(line: 73, column: 196, scope: !3755)
!3768 = !DILocation(line: 73, column: 199, scope: !3755)
!3769 = !DILocation(line: 73, column: 202, scope: !3755)
!3770 = !DILocation(line: 73, column: 205, scope: !3755)
!3771 = !DILocation(line: 73, column: 130, scope: !3755)
!3772 = !DILocation(line: 73, column: 137, scope: !3755)
!3773 = !DILocation(line: 73, column: 210, scope: !3756)
!3774 = !DILocation(line: 74, column: 5, scope: !3501)
!3775 = !DILocation(line: 76, column: 9, scope: !3776)
!3776 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 76, column: 9)
!3777 = !DILocation(line: 76, column: 11, scope: !3776)
!3778 = !DILocation(line: 76, column: 17, scope: !3776)
!3779 = !DILocation(line: 76, column: 20, scope: !3776)
!3780 = !DILocation(line: 76, column: 22, scope: !3776)
!3781 = !DILocation(line: 76, column: 29, scope: !3776)
!3782 = !DILocation(line: 76, column: 32, scope: !3776)
!3783 = !DILocation(line: 76, column: 34, scope: !3776)
!3784 = !DILocation(line: 76, column: 9, scope: !3501)
!3785 = !DILocation(line: 76, column: 44, scope: !3776)
!3786 = !DILocation(line: 76, column: 37, scope: !3776)
!3787 = !DILocation(line: 77, column: 23, scope: !3501)
!3788 = !DILocation(line: 77, column: 32, scope: !3789)
!3789 = distinct !DILexicalBlock(scope: !3790, file: !95, line: 77, column: 32)
!3790 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 77, column: 26)
!3791 = !DILocation(line: 77, column: 32, scope: !3790)
!3792 = !DILocation(line: 77, column: 116, scope: !3789)
!3793 = !DILocation(line: 77, column: 47, scope: !3789)
!3794 = !DILocation(line: 77, column: 85, scope: !3789)
!3795 = !DILocation(line: 77, column: 88, scope: !3789)
!3796 = !DILocation(line: 77, column: 91, scope: !3789)
!3797 = !DILocation(line: 77, column: 95, scope: !3789)
!3798 = !DILocation(line: 77, column: 46, scope: !3789)
!3799 = !DILocation(line: 77, column: 161, scope: !3789)
!3800 = !DILocation(line: 77, column: 199, scope: !3789)
!3801 = !DILocation(line: 77, column: 202, scope: !3789)
!3802 = !DILocation(line: 77, column: 205, scope: !3789)
!3803 = !DILocation(line: 77, column: 130, scope: !3789)
!3804 = !DILocation(line: 77, column: 137, scope: !3789)
!3805 = !DILocation(line: 77, column: 210, scope: !3790)
!3806 = !DILocation(line: 78, column: 5, scope: !3501)
!3807 = !DILocation(line: 80, column: 9, scope: !3808)
!3808 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 80, column: 9)
!3809 = !DILocation(line: 80, column: 11, scope: !3808)
!3810 = !DILocation(line: 80, column: 18, scope: !3808)
!3811 = !DILocation(line: 80, column: 21, scope: !3808)
!3812 = !DILocation(line: 80, column: 23, scope: !3808)
!3813 = !DILocation(line: 80, column: 9, scope: !3501)
!3814 = !DILocation(line: 80, column: 31, scope: !3808)
!3815 = !DILocation(line: 80, column: 26, scope: !3808)
!3816 = !DILocation(line: 81, column: 23, scope: !3501)
!3817 = !DILocation(line: 81, column: 32, scope: !3818)
!3818 = distinct !DILexicalBlock(scope: !3819, file: !95, line: 81, column: 32)
!3819 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 81, column: 26)
!3820 = !DILocation(line: 81, column: 32, scope: !3819)
!3821 = !DILocation(line: 81, column: 118, scope: !3818)
!3822 = !DILocation(line: 81, column: 47, scope: !3818)
!3823 = !DILocation(line: 81, column: 90, scope: !3818)
!3824 = !DILocation(line: 81, column: 93, scope: !3818)
!3825 = !DILocation(line: 81, column: 97, scope: !3818)
!3826 = !DILocation(line: 81, column: 46, scope: !3818)
!3827 = !DILocation(line: 81, column: 163, scope: !3818)
!3828 = !DILocation(line: 81, column: 206, scope: !3818)
!3829 = !DILocation(line: 81, column: 209, scope: !3818)
!3830 = !DILocation(line: 81, column: 132, scope: !3818)
!3831 = !DILocation(line: 81, column: 139, scope: !3818)
!3832 = !DILocation(line: 81, column: 214, scope: !3819)
!3833 = !DILocation(line: 82, column: 5, scope: !3501)
!3834 = !DILocation(line: 84, column: 9, scope: !3835)
!3835 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 84, column: 9)
!3836 = !DILocation(line: 84, column: 11, scope: !3835)
!3837 = !DILocation(line: 84, column: 19, scope: !3835)
!3838 = !DILocation(line: 84, column: 22, scope: !3835)
!3839 = !DILocation(line: 84, column: 24, scope: !3835)
!3840 = !DILocation(line: 84, column: 9, scope: !3501)
!3841 = !DILocation(line: 84, column: 34, scope: !3835)
!3842 = !DILocation(line: 84, column: 27, scope: !3835)
!3843 = !DILocation(line: 85, column: 23, scope: !3501)
!3844 = !DILocation(line: 85, column: 32, scope: !3845)
!3845 = distinct !DILexicalBlock(scope: !3846, file: !95, line: 85, column: 32)
!3846 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 85, column: 26)
!3847 = !DILocation(line: 85, column: 32, scope: !3846)
!3848 = !DILocation(line: 85, column: 124, scope: !3845)
!3849 = !DILocation(line: 85, column: 47, scope: !3845)
!3850 = !DILocation(line: 85, column: 93, scope: !3845)
!3851 = !DILocation(line: 85, column: 96, scope: !3845)
!3852 = !DILocation(line: 85, column: 100, scope: !3845)
!3853 = !DILocation(line: 85, column: 46, scope: !3845)
!3854 = !DILocation(line: 85, column: 169, scope: !3845)
!3855 = !DILocation(line: 85, column: 215, scope: !3845)
!3856 = !DILocation(line: 85, column: 218, scope: !3845)
!3857 = !DILocation(line: 85, column: 138, scope: !3845)
!3858 = !DILocation(line: 85, column: 145, scope: !3845)
!3859 = !DILocation(line: 85, column: 223, scope: !3846)
!3860 = !DILocation(line: 86, column: 5, scope: !3501)
!3861 = !DILocation(line: 88, column: 9, scope: !3862)
!3862 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 88, column: 9)
!3863 = !DILocation(line: 88, column: 11, scope: !3862)
!3864 = !DILocation(line: 88, column: 9, scope: !3501)
!3865 = !DILocation(line: 88, column: 19, scope: !3862)
!3866 = !DILocation(line: 89, column: 9, scope: !3867)
!3867 = distinct !DILexicalBlock(scope: !3501, file: !95, line: 89, column: 9)
!3868 = !DILocation(line: 89, column: 9, scope: !3501)
!3869 = !DILocation(line: 91, column: 41, scope: !3867)
!3870 = !DILocation(line: 91, column: 47, scope: !3867)
!3871 = !DILocation(line: 91, column: 11, scope: !3867)
!3872 = !DILocation(line: 90, column: 29, scope: !3867)
!3873 = !DILocation(line: 90, column: 7, scope: !3867)
!3874 = !DILocation(line: 90, column: 32, scope: !3867)
!3875 = !DILocation(line: 90, column: 38, scope: !3867)
!3876 = !DILocation(line: 93, column: 49, scope: !3867)
!3877 = !DILocation(line: 93, column: 27, scope: !3867)
!3878 = !DILocation(line: 93, column: 52, scope: !3867)
!3879 = !DILocation(line: 93, column: 59, scope: !3867)
!3880 = !DILocation(line: 94, column: 48, scope: !3867)
!3881 = !DILocation(line: 94, column: 26, scope: !3867)
!3882 = !DILocation(line: 94, column: 51, scope: !3867)
!3883 = !DILocation(line: 94, column: 17, scope: !3867)
!3884 = !DILocation(line: 93, column: 65, scope: !3867)
!3885 = !DILocation(line: 93, column: 8, scope: !3867)
!3886 = !DILocation(line: 93, column: 15, scope: !3867)
!3887 = !DILocation(line: 95, column: 5, scope: !3501)
!3888 = !DILocation(line: 97, column: 5, scope: !3501)
!3889 = !DILocation(line: 99, column: 4, scope: !3479)
!3890 = !DILocation(line: 99, column: 11, scope: !3479)
!3891 = !DILocation(line: 101, column: 1, scope: !3479)
!3892 = distinct !DISubprogram(name: "full_cache_weight_q", linkageName: "_ZN4laya4full19full_cache_weight_qERNS0_11FullRuntimeE", scope: !2, file: !6, line: 57, type: !3893, scopeLine: 57, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3893 = !DISubroutineType(types: !3894)
!3894 = !{!3895, !3896}
!3895 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5, size: 64)
!3896 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !1054, size: 64)
!3897 = !{!3898}
!3898 = !{!"fpga.inline", !"user", !3899}
!3899 = !DILocation(line: 57, column: 1, scope: !3892)
!3900 = !DILocalVariable(arg: 1, scope: !3892, file: !6, line: 57, type: !3896)
!3901 = !DILocation(line: 57, column: 58, scope: !3892)
!3902 = !DILocation(line: 57, column: 2, scope: !3892)
!3903 = distinct !DISubprogram(name: "full_cache_weight_scale", linkageName: "_ZN4laya4full23full_cache_weight_scaleERNS0_11FullRuntimeE", scope: !2, file: !6, line: 58, type: !3904, scopeLine: 58, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3904 = !DISubroutineType(types: !3905)
!3905 = !{!3906, !3896}
!3906 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !17, size: 64)
!3907 = !{!3908}
!3908 = !{!"fpga.inline", !"user", !3909}
!3909 = !DILocation(line: 58, column: 1, scope: !3903)
!3910 = !DILocalVariable(arg: 1, scope: !3903, file: !6, line: 58, type: !3896)
!3911 = !DILocation(line: 58, column: 66, scope: !3903)
!3912 = !DILocation(line: 58, column: 2, scope: !3903)
!3913 = distinct !DISubprogram(name: "full_cache_weight_bias", linkageName: "_ZN4laya4full22full_cache_weight_biasERNS0_11FullRuntimeE", scope: !2, file: !6, line: 59, type: !3914, scopeLine: 59, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3914 = !DISubroutineType(types: !3915)
!3915 = !{!3916, !3896}
!3916 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !27, size: 64)
!3917 = !{!3918}
!3918 = !{!"fpga.inline", !"user", !3919}
!3919 = !DILocation(line: 59, column: 1, scope: !3913)
!3920 = !DILocalVariable(arg: 1, scope: !3913, file: !6, line: 59, type: !3896)
!3921 = !DILocation(line: 59, column: 64, scope: !3913)
!3922 = !DILocation(line: 59, column: 2, scope: !3913)
!3923 = distinct !DISubprogram(name: "full_cache_activation_q", linkageName: "_ZN4laya4full23full_cache_activation_qERNS0_11FullRuntimeE", scope: !2, file: !6, line: 60, type: !3924, scopeLine: 60, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3924 = !DISubroutineType(types: !3925)
!3925 = !{!3926, !3896}
!3926 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !34, size: 64)
!3927 = !{!3928}
!3928 = !{!"fpga.inline", !"user", !3929}
!3929 = !DILocation(line: 60, column: 1, scope: !3923)
!3930 = !DILocalVariable(arg: 1, scope: !3923, file: !6, line: 60, type: !3896)
!3931 = !DILocation(line: 60, column: 66, scope: !3923)
!3932 = !DILocation(line: 60, column: 2, scope: !3923)
!3933 = distinct !DISubprogram(name: "full_cache_activation_scale", linkageName: "_ZN4laya4full27full_cache_activation_scaleERNS0_11FullRuntimeE", scope: !2, file: !6, line: 61, type: !3934, scopeLine: 61, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3934 = !DISubroutineType(types: !3935)
!3935 = !{!3936, !3896}
!3936 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !42, size: 64)
!3937 = !{!3938}
!3938 = !{!"fpga.inline", !"user", !3939}
!3939 = !DILocation(line: 61, column: 1, scope: !3933)
!3940 = !DILocalVariable(arg: 1, scope: !3933, file: !6, line: 61, type: !3896)
!3941 = !DILocation(line: 61, column: 74, scope: !3933)
!3942 = !DILocation(line: 61, column: 2, scope: !3933)
!3943 = distinct !DISubprogram(name: "full_cache_input_tile", linkageName: "_ZN4laya4full21full_cache_input_tileERNS0_11FullRuntimeE", scope: !2, file: !6, line: 62, type: !3944, scopeLine: 62, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3944 = !DISubroutineType(types: !3945)
!3945 = !{!3946, !3896}
!3946 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !47, size: 64)
!3947 = !{!3948}
!3948 = !{!"fpga.inline", !"user", !3949}
!3949 = !DILocation(line: 62, column: 1, scope: !3943)
!3950 = !DILocalVariable(arg: 1, scope: !3943, file: !6, line: 62, type: !3896)
!3951 = !DILocation(line: 62, column: 62, scope: !3943)
!3952 = !DILocation(line: 62, column: 2, scope: !3943)
!3953 = distinct !DISubprogram(name: "full_cache_ps_tile", linkageName: "_ZN4laya4full18full_cache_ps_tileERNS0_11FullRuntimeE", scope: !2, file: !6, line: 63, type: !3954, scopeLine: 63, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3954 = !DISubroutineType(types: !3955)
!3955 = !{!3956, !3896}
!3956 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !53, size: 64)
!3957 = !{!3958}
!3958 = !{!"fpga.inline", !"user", !3959}
!3959 = !DILocation(line: 63, column: 1, scope: !3953)
!3960 = !DILocalVariable(arg: 1, scope: !3953, file: !6, line: 63, type: !3896)
!3961 = !DILocation(line: 63, column: 56, scope: !3953)
!3962 = !DILocation(line: 63, column: 2, scope: !3953)
!3963 = distinct !DISubprogram(name: "full_cache_gamma", linkageName: "_ZN4laya4full16full_cache_gammaERNS0_11FullRuntimeE", scope: !2, file: !6, line: 64, type: !3964, scopeLine: 64, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3964 = !DISubroutineType(types: !3965)
!3965 = !{!3966, !3896}
!3966 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !58, size: 64)
!3967 = !{!3968}
!3968 = !{!"fpga.inline", !"user", !3969}
!3969 = !DILocation(line: 64, column: 1, scope: !3963)
!3970 = !DILocalVariable(arg: 1, scope: !3963, file: !6, line: 64, type: !3896)
!3971 = !DILocation(line: 64, column: 53, scope: !3963)
!3972 = !DILocation(line: 64, column: 2, scope: !3963)
!3973 = distinct !DISubprogram(name: "full_cache_rope_table", linkageName: "_ZN4laya4full21full_cache_rope_tableERNS0_11FullRuntimeE", scope: !2, file: !6, line: 65, type: !3974, scopeLine: 65, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3974 = !DISubroutineType(types: !3975)
!3975 = !{!3976, !3896}
!3976 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !65, size: 64)
!3977 = !{!3978}
!3978 = !{!"fpga.inline", !"user", !3979}
!3979 = !DILocation(line: 65, column: 1, scope: !3973)
!3980 = !DILocalVariable(arg: 1, scope: !3973, file: !6, line: 65, type: !3896)
!3981 = !DILocation(line: 65, column: 62, scope: !3973)
!3982 = !DILocation(line: 65, column: 2, scope: !3973)
!3983 = distinct !DISubprogram(name: "full_cache_kv", linkageName: "_ZN4laya4full13full_cache_kvERNS0_11FullRuntimeE", scope: !2, file: !6, line: 66, type: !3984, scopeLine: 66, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3984 = !DISubroutineType(types: !3985)
!3985 = !{!3986, !3896}
!3986 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !72, size: 64)
!3987 = !{!3988}
!3988 = !{!"fpga.inline", !"user", !3989}
!3989 = !DILocation(line: 66, column: 1, scope: !3983)
!3990 = !DILocalVariable(arg: 1, scope: !3983, file: !6, line: 66, type: !3896)
!3991 = !DILocation(line: 66, column: 47, scope: !3983)
!3992 = !DILocation(line: 66, column: 2, scope: !3983)
!3993 = distinct !DISubprogram(name: "full_cache_score", linkageName: "_ZN4laya4full16full_cache_scoreERNS0_11FullRuntimeE", scope: !2, file: !6, line: 67, type: !3994, scopeLine: 67, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!3994 = !DISubroutineType(types: !3995)
!3995 = !{!3996, !3896}
!3996 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !77, size: 64)
!3997 = !{!3998}
!3998 = !{!"fpga.inline", !"user", !3999}
!3999 = !DILocation(line: 67, column: 1, scope: !3993)
!4000 = !DILocalVariable(arg: 1, scope: !3993, file: !6, line: 67, type: !3896)
!4001 = !DILocation(line: 67, column: 53, scope: !3993)
!4002 = !DILocation(line: 67, column: 2, scope: !3993)
!4003 = distinct !DISubprogram(name: "full_cache_av_partial", linkageName: "_ZN4laya4full21full_cache_av_partialERNS0_11FullRuntimeE", scope: !2, file: !6, line: 68, type: !4004, scopeLine: 68, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!4004 = !DISubroutineType(types: !4005)
!4005 = !{!4006, !3896}
!4006 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !82, size: 64)
!4007 = !{!4008}
!4008 = !{!"fpga.inline", !"user", !4009}
!4009 = !DILocation(line: 68, column: 1, scope: !4003)
!4010 = !DILocalVariable(arg: 1, scope: !4003, file: !6, line: 68, type: !3896)
!4011 = !DILocation(line: 68, column: 62, scope: !4003)
!4012 = !DILocation(line: 68, column: 2, scope: !4003)
!4013 = distinct !DISubprogram(name: "full_cache_fp_act_weight", linkageName: "_ZN4laya4full24full_cache_fp_act_weightERNS0_11FullRuntimeE", scope: !2, file: !6, line: 69, type: !4014, scopeLine: 69, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !106, retainedNodes: !1053)
!4014 = !DISubroutineType(types: !4015)
!4015 = !{!4016, !3896}
!4016 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !87, size: 64)
!4017 = !{!4018}
!4018 = !{!"fpga.inline", !"user", !4019}
!4019 = !DILocation(line: 69, column: 1, scope: !4013)
!4020 = !DILocalVariable(arg: 1, scope: !4013, file: !6, line: 69, type: !3896)
!4021 = !DILocation(line: 69, column: 67, scope: !4013)
!4022 = !DILocation(line: 69, column: 2, scope: !4013)
!4023 = distinct !DISubprogram(name: "__hls_fptoui_float_i32", scope: !4024, file: !4024, line: 65, type: !4025, scopeLine: 65, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, retainedNodes: !1053)
!4024 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath/src/lib_floatconversion.cpp", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!4025 = !DISubroutineType(types: !4026)
!4026 = !{!2160, !29}
!4027 = !DILocalVariable(name: "x", arg: 1, scope: !4023, file: !4024, line: 65, type: !29)
!4028 = !DILocation(line: 65, column: 43, scope: !4023)
!4029 = !DILocation(line: 65, column: 86, scope: !4023)
!4030 = !DILocation(line: 65, column: 55, scope: !4023)
!4031 = !DILocation(line: 65, column: 48, scope: !4023)
!4032 = distinct !DISubprogram(name: "generic_cast_IEEE754<unsigned int, float>", linkageName: "_Z20generic_cast_IEEE754IjfET_T0_b", scope: !4033, file: !4033, line: 116, type: !4034, scopeLine: 116, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, templateParams: !4036, retainedNodes: !1053)
!4033 = !DIFile(filename: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath/include/FloatingPoint/hls_case_IEEE754.h", directory: "/wrk/ci/prod/2025.2/hls_product/continuous/666/2025.2/src/shared/hls/clib/hlsmath")
!4034 = !DISubroutineType(types: !4035)
!4035 = !{!103, !29, !104}
!4036 = !{!4037, !4038}
!4037 = !DITemplateTypeParameter(name: "T", type: !103)
!4038 = !DITemplateTypeParameter(name: "FP", type: !29)
!4039 = !DILocalVariable(name: "x", arg: 1, scope: !4032, file: !4033, line: 116, type: !29)
!4040 = !DILocation(line: 116, column: 27, scope: !4032)
!4041 = !DILocalVariable(name: "detect_overflow", arg: 2, scope: !4032, file: !4033, line: 116, type: !104)
!4042 = !DILocation(line: 116, column: 35, scope: !4032)
!4043 = !DILocation(line: 117, column: 47, scope: !4032)
!4044 = !DILocation(line: 117, column: 50, scope: !4032)
!4045 = !DILocation(line: 117, column: 10, scope: !4032)
!4046 = !DILocation(line: 117, column: 3, scope: !4032)
!4047 = distinct !DISubprogram(name: "generic_cast_IEEE754<unsigned int, AP_TRN_ZERO, float>", linkageName: "_Z20generic_cast_IEEE754IjL9ap_q_mode6EfET_T1_bN3hls9enable_ifIXntsr3std14numeric_limitsIS1_EE9is_signedEbE4typeE", scope: !4033, file: !4033, line: 65, type: !4048, scopeLine: 65, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, templateParams: !4056, retainedNodes: !1053)
!4048 = !DISubroutineType(types: !4049)
!4049 = !{!103, !29, !104, !4050}
!4050 = !DIDerivedType(tag: DW_TAG_typedef, name: "type", scope: !4051, file: !1874, line: 963, baseType: !104)
!4051 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "enable_if<true, bool>", scope: !4052, file: !1874, line: 963, size: 8, flags: DIFlagTypePassByValue, elements: !1053, templateParams: !4053, identifier: "_ZTSN3hls9enable_ifILb1EbEE")
!4052 = !DINamespace(name: "hls", scope: null)
!4053 = !{!4054, !4055}
!4054 = !DITemplateValueParameter(name: "B", type: !104, value: i8 1)
!4055 = !DITemplateTypeParameter(name: "T", type: !104)
!4056 = !{!4037, !4057, !4038}
!4057 = !DITemplateValueParameter(name: "ROUNDING", type: !1273, value: i32 6)
!4058 = !DILocalVariable(name: "x", arg: 1, scope: !4047, file: !4033, line: 65, type: !29)
!4059 = !DILocation(line: 65, column: 27, scope: !4047)
!4060 = !DILocalVariable(name: "detect_overflow", arg: 2, scope: !4047, file: !4033, line: 65, type: !104)
!4061 = !DILocation(line: 65, column: 35, scope: !4047)
!4062 = !DILocalVariable(arg: 3, scope: !4047, file: !4033, line: 65, type: !4050)
!4063 = !DILocation(line: 65, column: 132, scope: !4047)
!4064 = !DILocation(line: 66, column: 3, scope: !4047)
!4065 = !DILocalVariable(name: "xs", scope: !4047, file: !4033, line: 66, type: !2077)
!4066 = !DILocation(line: 66, column: 17, scope: !4047)
!4067 = !DILocation(line: 66, column: 20, scope: !4047)
!4068 = !DILocation(line: 67, column: 3, scope: !4047)
!4069 = !DILocalVariable(name: "mantissa", scope: !4047, file: !4033, line: 68, type: !4070)
!4070 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<79, 55, AP_TRN, AP_WRAP, 0>", file: !2032, line: 191, size: 128, flags: DIFlagTypePassByValue, elements: !4071, templateParams: !4103, identifier: "_ZTS9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!4071 = !{!4072, !4096}
!4072 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4070, baseType: !4073)
!4073 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<79, 55, false, AP_TRN, AP_WRAP, 0>", file: !1442, line: 107, size: 128, flags: DIFlagTypePassByValue, elements: !4074, templateParams: !4093, identifier: "_ZTS13ap_fixed_baseILi79ELi55ELb0EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!4074 = !{!4075, !4089, !4090, !4091, !4092}
!4075 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4073, baseType: !4076)
!4076 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ssdm_int<79, false>", file: !1299, line: 523, size: 128, flags: DIFlagTypePassByValue, elements: !4077, templateParams: !4087, identifier: "_ZTS8ssdm_intILi79ELb0EE")
!4077 = !{!4078, !4080, !4084}
!4078 = !DIDerivedType(tag: DW_TAG_member, name: "V", scope: !4076, file: !1299, line: 525, baseType: !4079, size: 79, align: 128)
!4079 = !DIBasicType(name: "uint79", size: 79, encoding: DW_ATE_unsigned)
!4080 = !DISubprogram(name: "ssdm_int", scope: !4076, file: !1299, line: 526, type: !4081, scopeLine: 526, flags: DIFlagPrototyped, spFlags: 0)
!4081 = !DISubroutineType(types: !4082)
!4082 = !{null, !4083}
!4083 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4076, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!4084 = !DISubprogram(name: "ssdm_int", scope: !4076, file: !1299, line: 527, type: !4085, scopeLine: 527, flags: DIFlagPrototyped, spFlags: 0)
!4085 = !DISubroutineType(types: !4086)
!4086 = !{null, !4083, !4079}
!4087 = !{!4088, !1311}
!4088 = !DITemplateValueParameter(name: "_AP_N", type: !184, value: i32 79)
!4089 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !4073, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 79)
!4090 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !4073, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 55)
!4091 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !4073, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!4092 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !4073, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!4093 = !{!4094, !4095, !1311, !1453, !1454, !1455}
!4094 = !DITemplateValueParameter(name: "_AP_W", type: !184, value: i32 79)
!4095 = !DITemplateValueParameter(name: "_AP_I", type: !184, value: i32 55)
!4096 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi79ELi55EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSERKS2_", scope: !4070, file: !2032, line: 321, type: !4097, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!4097 = !DISubroutineType(types: !4098)
!4098 = !{!4099, !4100, !4101}
!4099 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4070, size: 64)
!4100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4070, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!4101 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4102, size: 64)
!4102 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4070)
!4103 = !{!4094, !4095, !1453, !1454, !1455}
!4104 = !DILocation(line: 68, column: 43, scope: !4047)
!4105 = !DILocation(line: 68, column: 54, scope: !4047)
!4106 = !DILocation(line: 68, column: 57, scope: !4047)
!4107 = !DILocation(line: 70, column: 1, scope: !4047)
!4108 = !DILocalVariable(name: "smantissa", scope: !4047, file: !4033, line: 71, type: !4070)
!4109 = !DILocation(line: 71, column: 52, scope: !4047)
!4110 = !DILocation(line: 71, column: 64, scope: !4047)
!4111 = !DILocation(line: 71, column: 79, scope: !4047)
!4112 = !DILocation(line: 71, column: 73, scope: !4047)
!4113 = !DILocation(line: 73, column: 2, scope: !4047)
!4114 = !DILocalVariable(name: "overflow_bits", scope: !4047, file: !4033, line: 73, type: !4115)
!4115 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<1, 33, AP_TRN, AP_SAT, 0>", file: !2032, line: 191, size: 8, flags: DIFlagTypePassByValue, elements: !4116, templateParams: !4133, identifier: "_ZTS9ap_ufixedILi1ELi33EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!4116 = !{!4117, !4126}
!4117 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4115, baseType: !4118)
!4118 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<1, 33, false, AP_TRN, AP_SAT, 0>", file: !1442, line: 107, size: 8, flags: DIFlagTypePassByValue, elements: !4119, templateParams: !4125, identifier: "_ZTS13ap_fixed_baseILi1ELi33ELb0EL9ap_q_mode5EL9ap_o_mode0ELi0EE")
!4119 = !{!4120, !4121, !4122, !4123, !4124}
!4120 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4118, baseType: !1417)
!4121 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !4118, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 1)
!4122 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !4118, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 33)
!4123 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !4118, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 5)
!4124 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !4118, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 0)
!4125 = !{!1440, !1602, !1311, !1453, !1479, !1455}
!4126 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi1ELi33EL9ap_q_mode5EL9ap_o_mode0ELi0EEaSERKS2_", scope: !4115, file: !2032, line: 321, type: !4127, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!4127 = !DISubroutineType(types: !4128)
!4128 = !{!4129, !4130, !4131}
!4129 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4115, size: 64)
!4130 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4115, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!4131 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4132, size: 64)
!4132 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4115)
!4133 = !{!1440, !1602, !1453, !1479, !1455}
!4134 = !DILocation(line: 73, column: 49, scope: !4047)
!4135 = !DILocation(line: 73, column: 65, scope: !4047)
!4136 = !DILocation(line: 74, column: 2, scope: !4047)
!4137 = !DILocalVariable(name: "val", scope: !4047, file: !4033, line: 74, type: !4138)
!4138 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_ufixed<32, 32, AP_TRN_ZERO, AP_WRAP, 0>", file: !2032, line: 191, size: 32, flags: DIFlagTypePassByValue, elements: !4139, templateParams: !4157, identifier: "_ZTS9ap_ufixedILi32ELi32EL9ap_q_mode6EL9ap_o_mode3ELi0EE")
!4139 = !{!4140, !4150}
!4140 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4138, baseType: !4141)
!4141 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed_base<32, 32, false, AP_TRN_ZERO, AP_WRAP, 0>", file: !1442, line: 107, size: 32, flags: DIFlagTypePassByValue, elements: !4142, templateParams: !4148, identifier: "_ZTS13ap_fixed_baseILi32ELi32ELb0EL9ap_q_mode6EL9ap_o_mode3ELi0EE")
!4142 = !{!4143, !4144, !4145, !4146, !4147}
!4143 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4141, baseType: !1606)
!4144 = !DIDerivedType(tag: DW_TAG_member, name: "width", scope: !4141, file: !1442, line: 112, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!4145 = !DIDerivedType(tag: DW_TAG_member, name: "iwidth", scope: !4141, file: !1442, line: 113, baseType: !1313, flags: DIFlagStaticMember, extraData: i32 32)
!4146 = !DIDerivedType(tag: DW_TAG_member, name: "qmode", scope: !4141, file: !1442, line: 114, baseType: !1448, flags: DIFlagStaticMember, extraData: i32 6)
!4147 = !DIDerivedType(tag: DW_TAG_member, name: "omode", scope: !4141, file: !1442, line: 115, baseType: !1450, flags: DIFlagStaticMember, extraData: i32 3)
!4148 = !{!1379, !1452, !1311, !4149, !1454, !1455}
!4149 = !DITemplateValueParameter(name: "_AP_Q", type: !1273, value: i32 6)
!4150 = !DISubprogram(name: "operator=", linkageName: "_ZN9ap_ufixedILi32ELi32EL9ap_q_mode6EL9ap_o_mode3ELi0EEaSERKS2_", scope: !4138, file: !2032, line: 321, type: !4151, scopeLine: 321, flags: DIFlagPrototyped, spFlags: 0)
!4151 = !DISubroutineType(types: !4152)
!4152 = !{!4153, !4154, !4155}
!4153 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4138, size: 64)
!4154 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4138, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!4155 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4156, size: 64)
!4156 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4138)
!4157 = !{!1379, !1452, !4149, !1454, !1455}
!4158 = !DILocation(line: 74, column: 54, scope: !4047)
!4159 = !DILocation(line: 74, column: 60, scope: !4047)
!4160 = !DILocation(line: 77, column: 2, scope: !4047)
!4161 = !DILocalVariable(name: "overflow", scope: !4047, file: !4033, line: 77, type: !104)
!4162 = !DILocation(line: 77, column: 7, scope: !4047)
!4163 = !DILocation(line: 86, column: 18, scope: !4164)
!4164 = distinct !DILexicalBlock(scope: !4165, file: !4033, line: 83, column: 9)
!4165 = distinct !DILexicalBlock(scope: !4047, file: !4033, line: 78, column: 5)
!4166 = !DILocation(line: 86, column: 25, scope: !4164)
!4167 = !DILocation(line: 86, column: 78, scope: !4164)
!4168 = !DILocation(line: 86, column: 82, scope: !4164)
!4169 = !DILocation(line: 86, column: 96, scope: !4164)
!4170 = !DILocation(line: 86, column: 13, scope: !4164)
!4171 = !DILocation(line: 89, column: 2, scope: !4047)
!4172 = !DILocalVariable(name: "minval", scope: !4047, file: !4033, line: 89, type: !2137)
!4173 = !DILocation(line: 89, column: 23, scope: !4047)
!4174 = !DILocation(line: 89, column: 32, scope: !4047)
!4175 = !DILocation(line: 90, column: 2, scope: !4047)
!4176 = !DILocalVariable(name: "maxval", scope: !4047, file: !4033, line: 90, type: !2137)
!4177 = !DILocation(line: 90, column: 23, scope: !4047)
!4178 = !DILocation(line: 90, column: 32, scope: !4047)
!4179 = !DILocation(line: 91, column: 6, scope: !4180)
!4180 = distinct !DILexicalBlock(scope: !4047, file: !4033, line: 91, column: 5)
!4181 = !DILocation(line: 91, column: 15, scope: !4180)
!4182 = !DILocation(line: 91, column: 21, scope: !4180)
!4183 = !DILocation(line: 91, column: 18, scope: !4180)
!4184 = !DILocation(line: 91, column: 34, scope: !4180)
!4185 = !DILocation(line: 91, column: 37, scope: !4180)
!4186 = !DILocation(line: 91, column: 5, scope: !4047)
!4187 = !DILocation(line: 94, column: 15, scope: !4188)
!4188 = distinct !DILexicalBlock(scope: !4189, file: !4033, line: 94, column: 9)
!4189 = distinct !DILexicalBlock(scope: !4180, file: !4033, line: 92, column: 2)
!4190 = !DILocation(line: 94, column: 12, scope: !4188)
!4191 = !DILocation(line: 94, column: 29, scope: !4188)
!4192 = !DILocation(line: 94, column: 40, scope: !4188)
!4193 = !DILocation(line: 94, column: 37, scope: !4188)
!4194 = !DILocation(line: 94, column: 34, scope: !4188)
!4195 = !DILocation(line: 94, column: 44, scope: !4188)
!4196 = !DILocation(line: 94, column: 50, scope: !4188)
!4197 = !DILocation(line: 94, column: 47, scope: !4188)
!4198 = !DILocation(line: 94, column: 54, scope: !4188)
!4199 = !DILocation(line: 94, column: 9, scope: !4189)
!4200 = !DILocation(line: 96, column: 17, scope: !4201)
!4201 = distinct !DILexicalBlock(scope: !4188, file: !4033, line: 94, column: 85)
!4202 = !DILocation(line: 96, column: 10, scope: !4201)
!4203 = !DILocation(line: 99, column: 20, scope: !4204)
!4204 = distinct !DILexicalBlock(scope: !4188, file: !4033, line: 98, column: 11)
!4205 = !DILocation(line: 99, column: 17, scope: !4204)
!4206 = !DILocation(line: 99, column: 10, scope: !4204)
!4207 = !DILocation(line: 110, column: 2, scope: !4047)
!4208 = !DILocalVariable(name: "result", scope: !4047, file: !4033, line: 110, type: !4209)
!4209 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ap_fixed<32, 32, AP_TRN, AP_WRAP, 0>", file: !2032, line: 17, size: 32, flags: DIFlagTypePassByValue, elements: !4210, templateParams: !4219, identifier: "_ZTS8ap_fixedILi32ELi32EL9ap_q_mode5EL9ap_o_mode3ELi0EE")
!4210 = !{!4211, !4212}
!4211 = !DIDerivedType(tag: DW_TAG_inheritance, scope: !4209, baseType: !1441)
!4212 = !DISubprogram(name: "operator=", linkageName: "_ZN8ap_fixedILi32ELi32EL9ap_q_mode5EL9ap_o_mode3ELi0EEaSERKS2_", scope: !4209, file: !2032, line: 160, type: !4213, scopeLine: 160, flags: DIFlagPrototyped, spFlags: 0)
!4213 = !DISubroutineType(types: !4214)
!4214 = !{!4215, !4216, !4217}
!4215 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4209, size: 64)
!4216 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4209, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!4217 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !4218, size: 64)
!4218 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4209)
!4219 = !{!1379, !1452, !1453, !1454, !1455}
!4220 = !DILocation(line: 110, column: 40, scope: !4047)
!4221 = !DILocation(line: 110, column: 49, scope: !4047)
!4222 = !DILocation(line: 112, column: 9, scope: !4047)
!4223 = !DILocation(line: 112, column: 2, scope: !4047)
!4224 = !DILocation(line: 113, column: 1, scope: !4047)
!4225 = distinct !DISubprogram(name: "fp_struct", linkageName: "_ZN9fp_structIfEC2Ef", scope: !2077, file: !1874, line: 283, type: !2132, scopeLine: 283, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !2131, retainedNodes: !1053)
!4226 = !DILocalVariable(name: "this", arg: 1, scope: !4225, type: !4227, flags: DIFlagArtificial | DIFlagObjectPointer)
!4227 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2077, size: 64)
!4228 = !DILocation(line: 0, scope: !4225)
!4229 = !DILocalVariable(name: "f", arg: 2, scope: !4225, file: !1874, line: 283, type: !29)
!4230 = !DILocation(line: 283, column: 21, scope: !4225)
!4231 = !DILocation(line: 283, column: 5, scope: !4225)
!4232 = !DILocation(line: 286, column: 9, scope: !4233)
!4233 = distinct !DILexicalBlock(scope: !4225, file: !1874, line: 283, column: 24)
!4234 = !DILocalVariable(name: "dc", scope: !4233, file: !1874, line: 286, type: !4235)
!4235 = distinct !DICompositeType(tag: DW_TAG_union_type, name: "single_cast", file: !1874, line: 266, size: 32, flags: DIFlagTypePassByValue, elements: !4236, identifier: "_ZTS11single_cast")
!4236 = !{!4237, !4238}
!4237 = !DIDerivedType(tag: DW_TAG_member, name: "f", scope: !4235, file: !1874, line: 267, baseType: !29, size: 32)
!4238 = !DIDerivedType(tag: DW_TAG_member, name: "i", scope: !4235, file: !1874, line: 268, baseType: !2160, size: 32)
!4239 = !DILocation(line: 286, column: 27, scope: !4233)
!4240 = !DILocation(line: 287, column: 16, scope: !4233)
!4241 = !DILocation(line: 287, column: 12, scope: !4233)
!4242 = !DILocation(line: 287, column: 14, scope: !4233)
!4243 = !DILocation(line: 288, column: 9, scope: !4233)
!4244 = !DILocalVariable(name: "data", scope: !4233, file: !1874, line: 288, type: !2137)
!4245 = !DILocation(line: 288, column: 21, scope: !4233)
!4246 = !DILocation(line: 288, column: 31, scope: !4233)
!4247 = !DILocation(line: 288, column: 28, scope: !4233)
!4248 = !DILocation(line: 294, column: 19, scope: !4233)
!4249 = !DILocation(line: 294, column: 9, scope: !4233)
!4250 = !DILocation(line: 294, column: 17, scope: !4233)
!4251 = !DILocation(line: 295, column: 19, scope: !4233)
!4252 = !DILocation(line: 295, column: 9, scope: !4233)
!4253 = !DILocation(line: 295, column: 17, scope: !4233)
!4254 = !DILocation(line: 296, column: 20, scope: !4233)
!4255 = !DILocation(line: 296, column: 9, scope: !4233)
!4256 = !DILocation(line: 296, column: 18, scope: !4233)
!4257 = !DILocation(line: 297, column: 5, scope: !4225)
!4258 = distinct !DISubprogram(name: "mantissa", linkageName: "_ZNK9fp_structIfE8mantissaEv", scope: !2077, file: !1874, line: 340, type: !2215, scopeLine: 340, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !2214, retainedNodes: !1053)
!4259 = !DILocalVariable(name: "this", arg: 1, scope: !4258, type: !4260, flags: DIFlagArtificial | DIFlagObjectPointer)
!4260 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !2166, size: 64)
!4261 = !DILocation(line: 0, scope: !4258)
!4262 = !DILocalVariable(name: "y", scope: !4258, file: !1874, line: 341, type: !2181)
!4263 = !DILocation(line: 341, column: 33, scope: !4258)
!4264 = !DILocation(line: 341, column: 37, scope: !4258)
!4265 = !DILocation(line: 342, column: 25, scope: !4258)
!4266 = !DILocation(line: 342, column: 9, scope: !4258)
!4267 = !DILocation(line: 342, column: 11, scope: !4258)
!4268 = !DILocation(line: 342, column: 13, scope: !4258)
!4269 = !DILocation(line: 342, column: 17, scope: !4258)
!4270 = !DILocation(line: 342, column: 23, scope: !4258)
!4271 = !DILocation(line: 343, column: 9, scope: !4258)
!4272 = !DILocation(line: 343, column: 11, scope: !4258)
!4273 = !DILocation(line: 343, column: 13, scope: !4258)
!4274 = !DILocation(line: 343, column: 17, scope: !4258)
!4275 = !DILocation(line: 343, column: 21, scope: !4258)
!4276 = !DILocation(line: 344, column: 9, scope: !4258)
!4277 = !{!4278}
!4278 = !{!"fpga.inline", !"user", null}
!4279 = distinct !DISubprogram(name: "expv", linkageName: "_ZNK9fp_structIfE4expvEv", scope: !2077, file: !1874, line: 316, type: !2168, scopeLine: 316, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !2167, retainedNodes: !1053)
!4280 = !DILocalVariable(name: "this", arg: 1, scope: !4279, type: !4260, flags: DIFlagArtificial | DIFlagObjectPointer)
!4281 = !DILocation(line: 0, scope: !4279)
!4282 = !DILocation(line: 317, column: 16, scope: !4279)
!4283 = !DILocation(line: 317, column: 19, scope: !4279)
!4284 = !DILocation(line: 317, column: 9, scope: !4279)
!4285 = distinct !DISubprogram(name: "__signbit", linkageName: "_ZNK9fp_structIfE9__signbitEv", scope: !2077, file: !1874, line: 349, type: !2168, scopeLine: 349, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !2218, retainedNodes: !1053)
!4286 = !DILocalVariable(name: "this", arg: 1, scope: !4285, type: !4260, flags: DIFlagArtificial | DIFlagObjectPointer)
!4287 = !DILocation(line: 0, scope: !4285)
!4288 = !DILocation(line: 350, column: 16, scope: !4285)
!4289 = !DILocation(line: 350, column: 21, scope: !4285)
!4290 = !DILocation(line: 350, column: 9, scope: !4285)
!4291 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi33ELb1EEC2EDq33_i", scope: !1384, file: !1299, line: 519, type: !1393, scopeLine: 519, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1392, retainedNodes: !1053)
!4292 = !{!4293}
!4293 = !{!"fpga.inline", !"user", !4294}
!4294 = !DILocation(line: 519, column: 39, scope: !4291)
!4295 = !DILocalVariable(name: "this", arg: 1, scope: !4291, type: !4296, flags: DIFlagArtificial | DIFlagObjectPointer)
!4296 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1384, size: 64)
!4297 = !DILocation(line: 0, scope: !4291)
!4298 = !DILocalVariable(name: "o", arg: 2, scope: !4291, file: !1299, line: 519, type: !1387)
!4299 = !DILocation(line: 519, column: 81, scope: !4291)
!4300 = !DILocation(line: 519, column: 117, scope: !4291)
!4301 = !DILocation(line: 519, column: 119, scope: !4291)
!4302 = !DILocation(line: 519, column: 122, scope: !4291)
!4303 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi32ELb1EEC2Ei", scope: !1356, file: !1299, line: 519, type: !1364, scopeLine: 519, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1363, retainedNodes: !1053)
!4304 = !{!4305}
!4305 = !{!"fpga.inline", !"user", !4306}
!4306 = !DILocation(line: 519, column: 39, scope: !4303)
!4307 = !DILocalVariable(name: "this", arg: 1, scope: !4303, type: !4308, flags: DIFlagArtificial | DIFlagObjectPointer)
!4308 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1356, size: 64)
!4309 = !DILocation(line: 0, scope: !4303)
!4310 = !DILocalVariable(name: "o", arg: 2, scope: !4303, file: !1299, line: 519, type: !184)
!4311 = !DILocation(line: 519, column: 81, scope: !4303)
!4312 = !DILocation(line: 519, column: 117, scope: !4303)
!4313 = !DILocation(line: 519, column: 119, scope: !4303)
!4314 = !DILocation(line: 519, column: 122, scope: !4303)
!4315 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi33ELb0EEC2EDq33_j", scope: !1585, file: !1299, line: 527, type: !1594, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1593, retainedNodes: !1053)
!4316 = !{!4317}
!4317 = !{!"fpga.inline", !"user", !4318}
!4318 = !DILocation(line: 527, column: 39, scope: !4315)
!4319 = !DILocalVariable(name: "this", arg: 1, scope: !4315, type: !4320, flags: DIFlagArtificial | DIFlagObjectPointer)
!4320 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1585, size: 64)
!4321 = !DILocation(line: 0, scope: !4315)
!4322 = !DILocalVariable(name: "o", arg: 2, scope: !4315, file: !1299, line: 527, type: !1588)
!4323 = !DILocation(line: 527, column: 87, scope: !4315)
!4324 = !DILocation(line: 527, column: 123, scope: !4315)
!4325 = !DILocation(line: 527, column: 125, scope: !4315)
!4326 = !DILocation(line: 527, column: 128, scope: !4315)
!4327 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi32ELb0EEC2Ej", scope: !1606, file: !1299, line: 527, type: !1614, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1613, retainedNodes: !1053)
!4328 = !{!4329}
!4329 = !{!"fpga.inline", !"user", !4330}
!4330 = !DILocation(line: 527, column: 39, scope: !4327)
!4331 = !DILocalVariable(name: "this", arg: 1, scope: !4327, type: !4332, flags: DIFlagArtificial | DIFlagObjectPointer)
!4332 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1606, size: 64)
!4333 = !DILocation(line: 0, scope: !4327)
!4334 = !DILocalVariable(name: "o", arg: 2, scope: !4327, file: !1299, line: 527, type: !103)
!4335 = !DILocation(line: 527, column: 87, scope: !4327)
!4336 = !DILocation(line: 527, column: 123, scope: !4327)
!4337 = !DILocation(line: 527, column: 125, scope: !4327)
!4338 = !DILocation(line: 527, column: 128, scope: !4327)
!4339 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi34ELb0EEC2EDq34_j", scope: !1828, file: !1299, line: 527, type: !1837, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1836, retainedNodes: !1053)
!4340 = !{!4341}
!4341 = !{!"fpga.inline", !"user", !4342}
!4342 = !DILocation(line: 527, column: 39, scope: !4339)
!4343 = !DILocalVariable(name: "this", arg: 1, scope: !4339, type: !4344, flags: DIFlagArtificial | DIFlagObjectPointer)
!4344 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1828, size: 64)
!4345 = !DILocation(line: 0, scope: !4339)
!4346 = !DILocalVariable(name: "o", arg: 2, scope: !4339, file: !1299, line: 527, type: !1831)
!4347 = !DILocation(line: 527, column: 87, scope: !4339)
!4348 = !DILocation(line: 527, column: 123, scope: !4339)
!4349 = !DILocation(line: 527, column: 125, scope: !4339)
!4350 = !DILocation(line: 527, column: 128, scope: !4339)
!4351 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi1ELb0EEC2EDq1_j", scope: !1417, file: !1299, line: 527, type: !1426, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1425, retainedNodes: !1053)
!4352 = !{!4353}
!4353 = !{!"fpga.inline", !"user", !4354}
!4354 = !DILocation(line: 527, column: 39, scope: !4351)
!4355 = !DILocalVariable(name: "this", arg: 1, scope: !4351, type: !4356, flags: DIFlagArtificial | DIFlagObjectPointer)
!4356 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1417, size: 64)
!4357 = !DILocation(line: 0, scope: !4351)
!4358 = !DILocalVariable(name: "o", arg: 2, scope: !4351, file: !1299, line: 527, type: !1420)
!4359 = !DILocation(line: 527, column: 87, scope: !4351)
!4360 = !DILocation(line: 527, column: 123, scope: !4351)
!4361 = !DILocation(line: 527, column: 125, scope: !4351)
!4362 = !DILocation(line: 527, column: 128, scope: !4351)
!4363 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi79ELb0EEC2EDq79_j", scope: !4076, file: !1299, line: 527, type: !4085, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !4084, retainedNodes: !1053)
!4364 = !{!4365}
!4365 = !{!"fpga.inline", !"user", !4366}
!4366 = !DILocation(line: 527, column: 39, scope: !4363)
!4367 = !DILocalVariable(name: "this", arg: 1, scope: !4363, type: !4368, flags: DIFlagArtificial | DIFlagObjectPointer)
!4368 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4076, size: 64)
!4369 = !DILocation(line: 0, scope: !4363)
!4370 = !DILocalVariable(name: "o", arg: 2, scope: !4363, file: !1299, line: 527, type: !4079)
!4371 = !DILocation(line: 527, column: 87, scope: !4363)
!4372 = !DILocation(line: 527, column: 123, scope: !4363)
!4373 = !DILocation(line: 527, column: 125, scope: !4363)
!4374 = !DILocation(line: 527, column: 128, scope: !4363)
!4375 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi23ELb0EEC2EDq23_j", scope: !1711, file: !1299, line: 527, type: !1720, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1719, retainedNodes: !1053)
!4376 = !{!4377}
!4377 = !{!"fpga.inline", !"user", !4378}
!4378 = !DILocation(line: 527, column: 39, scope: !4375)
!4379 = !DILocalVariable(name: "this", arg: 1, scope: !4375, type: !4380, flags: DIFlagArtificial | DIFlagObjectPointer)
!4380 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1711, size: 64)
!4381 = !DILocation(line: 0, scope: !4375)
!4382 = !DILocalVariable(name: "o", arg: 2, scope: !4375, file: !1299, line: 527, type: !1714)
!4383 = !DILocation(line: 527, column: 87, scope: !4375)
!4384 = !DILocation(line: 527, column: 123, scope: !4375)
!4385 = !DILocation(line: 527, column: 125, scope: !4375)
!4386 = !DILocation(line: 527, column: 128, scope: !4375)
!4387 = distinct !DISubprogram(name: "ssdm_int", linkageName: "_ZN8ssdm_intILi8ELb0EEC2Eh", scope: !1483, file: !1299, line: 527, type: !1491, scopeLine: 527, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !1270, declaration: !1490, retainedNodes: !1053)
!4388 = !{!4389}
!4389 = !{!"fpga.inline", !"user", !4390}
!4390 = !DILocation(line: 527, column: 39, scope: !4387)
!4391 = !DILocalVariable(name: "this", arg: 1, scope: !4387, type: !4392, flags: DIFlagArtificial | DIFlagObjectPointer)
!4392 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !1483, size: 64)
!4393 = !DILocation(line: 0, scope: !4387)
!4394 = !DILocalVariable(name: "o", arg: 2, scope: !4387, file: !1299, line: 527, type: !100)
!4395 = !DILocation(line: 527, column: 87, scope: !4387)
!4396 = !DILocation(line: 527, column: 123, scope: !4387)
!4397 = !DILocation(line: 527, column: 125, scope: !4387)
!4398 = !DILocation(line: 527, column: 128, scope: !4387)
