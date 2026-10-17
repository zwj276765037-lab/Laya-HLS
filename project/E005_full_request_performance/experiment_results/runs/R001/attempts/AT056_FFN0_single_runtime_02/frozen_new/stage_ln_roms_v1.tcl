# Stage the immutable generated LN ROMs before any xsim run.  The SHA values
# identify the baseline LN producer used by the four-row LN_FFN chain.
proc stage_ln_roms_v1 {source_dir xsim_dir} {
  set expected [dict create \
    laya_layernorm_producer_engine_p_anonymous_namespace_request_ok_roles_ROM_AUTO_1R.dat 15b641814d9df5b19d3e83afa0a2d7c3d2d9a8511ea49d6f58fc4e44c3b66442 \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullBuildTag_ROM_AUTO_1R.dat 6d352243f8b680dfc6f71018915888c27ef14ab61a5d7e01394bb9c88ad12da9 \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullLayoutTag_ROM_AUTO_1R.dat da6ab8d9ece7ea17f87630e54c0672722af78da8524b159c171632fb67f8eb13 \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullModelBoSizes_ROM_AUTO_1R.dat a5031a94d812f88baa020ef4d46ab8a58ae516182ac8557d79472135e781bff2 \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullModelTag_ROM_AUTO_1R.dat 93ad4d5fc95e35f6f0c7c75c404956b4ef9f5dcd4af04aaf3e6742981690a3a5 \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullNumericTag_ROM_AUTO_1R.dat c91b18a6b7f89e6e26d25a3a9f0c5449eb4841f2917c2f294d1e743e64532f4b \
    laya_layernorm_producer_engine_p_anonymous_namespace_supported_laya_full_kFullSourceSha256_ROM_AUTO_1R.dat c714fc8ddefd495fa2e7b34c74b9f920d9d8b2125d95b46621746658fb27db17]

  if {![file isdirectory $xsim_dir]} {
    error "LN ROM staging: xsim directory is absent: $xsim_dir"
  }
  # Validate every frozen source before copying anything into the run directory.
  dict for {name sha} $expected {
    set source [file join $source_dir $name]
    if {![file isfile $source]} {error "LN ROM staging: missing frozen source: $source"}
    set actual [lindex [exec sha256sum -- $source] 0]
    if {$actual ne $sha} {error "LN ROM staging: frozen source SHA mismatch: $name"}
  }
  dict for {name sha} $expected {
    set source [file join $source_dir $name]
    set target [file join $xsim_dir $name]
    file copy -force -- $source $target
    set actual [lindex [exec sha256sum -- $target] 0]
    if {$actual ne $sha} {error "LN ROM staging: staged SHA mismatch: $name"}
  }
  puts "LNQ0_ROM_STAGE_PASS count=[dict size $expected] xsim_dir=$xsim_dir"
}
