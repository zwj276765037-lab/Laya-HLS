set new_classes [list {tanh_libm_stream_leaf_stream_div_node_0_s} {tanh_libm_stream_leaf_stream_mul_node_14_s}]
set class_sources(tanh_libm_stream_leaf_stream_add_node_0_s) [list {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_stream_add_node_0_s.v}]
set class_dcp(tanh_libm_stream_leaf_stream_add_node_0_s) {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_stream_bottomup_01/nodes/tanh_libm_stream_leaf_stream_add_node_0_s/child_synth.dcp}
set class_sources(tanh_libm_stream_leaf_stream_div_node_0_s) [list {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_17_7_32_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_25_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_27_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_9_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_stream_div_node_0_s.v}]
set class_dcp(tanh_libm_stream_leaf_stream_div_node_0_s) {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/ooc/tanh_libm_stream_leaf_stream_div_node_0_s/child_synth.dcp}
set class_sources(tanh_libm_stream_leaf_stream_mul_node_14_s) [list {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_mul_24ns_24ns_48_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_15_6_32_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_24_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_28_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_sparsemux_7_2_9_1_0.v} {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/rtl/tanh_libm_stream_leaf_stream_mul_node_14_s.v}]
set class_dcp(tanh_libm_stream_leaf_stream_mul_node_14_s) {/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/ooc/tanh_libm_stream_leaf_stream_mul_node_14_s/child_synth.dcp}
set boundary_cells [list {core/mul0_kernel} {core/mul1_kernel} {core/add0_kernel} {core/mul2_kernel} {core/mul3_kernel} {core/add1_kernel} {core/add2_kernel} {core/add3_kernel} {core/add4_kernel} {core/mul4_kernel} {core/mul5_kernel} {core/mul6_kernel} {core/add5_kernel} {core/mul7_kernel} {core/add6_kernel} {core/mul8_kernel} {core/add7_kernel} {core/mul9_kernel} {core/add8_kernel} {core/mul10_kernel} {core/add9_kernel} {core/mul11_kernel} {core/add10_kernel} {core/mul12_kernel} {core/add11_kernel} {core/add12_kernel} {core/div0_kernel} {core/mul13_kernel} {core/add13_kernel} {core/mul14_kernel} {core/add14_kernel} {core/add15_kernel} {core/add16_kernel} {core/add17_kernel} {core/add18_kernel} {core/mul15_kernel} {core/add19_kernel} {core/add20_kernel} {core/div1_kernel} {core/add21_kernel} {core/add22_kernel} {core/mul16_kernel}]
set boundary_module(core/mul0_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/mul1_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add0_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul2_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/mul3_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add1_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add2_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add3_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add4_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul4_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/mul5_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/mul6_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add5_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul7_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add6_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul8_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add7_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul9_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add8_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul10_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add9_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul11_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add10_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul12_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add11_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add12_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/div0_kernel) {tanh_libm_stream_leaf_stream_div_node_0_s}
set boundary_module(core/mul13_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add13_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul14_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add14_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add15_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add16_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add17_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add18_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul15_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
set boundary_module(core/add19_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add20_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/div1_kernel) {tanh_libm_stream_leaf_stream_div_node_0_s}
set boundary_module(core/add21_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/add22_kernel) {tanh_libm_stream_leaf_stream_add_node_0_s}
set boundary_module(core/mul16_kernel) {tanh_libm_stream_leaf_stream_mul_node_14_s}
