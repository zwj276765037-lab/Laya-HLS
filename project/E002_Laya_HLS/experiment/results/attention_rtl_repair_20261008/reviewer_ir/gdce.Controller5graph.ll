define internal void @_ZN4laya4full12_GLOBAL__N_110Controller5graphERNS0_13FullOwnerSpecES4_(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %candidate, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act) #13 align 2 !dbg !13055 !type !13056 {
entry:
  %this.addr = alloca %"struct.laya::full::(anonymous namespace)::Controller"*, align 8
  %candidate.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %act.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %hidden = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %ref.tmp = alloca %"struct.laya::Check", align 8
  %normed = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp5 = alloca %"struct.laya::Check", align 8
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp10 = alloca %"struct.laya::Check", align 8
  %layer = alloca i8, align 1
  %att_source = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %normalized = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp16 = alloca %"struct.laya::Check", align 8
  %agg.tmp17 = alloca %"struct.laya::BufferRef", align 4
  %qkv = alloca [2 x %"struct.laya::full::FullOwnerSpec"], align 4
  %qkv_primary = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp24 = alloca %"struct.laya::Check", align 8
  %agg.tmp25 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp27 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp33 = alloca %"struct.laya::Check", align 8
  %attended = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp39 = alloca %"struct.laya::Check", align 8
  %projected = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp43 = alloca %"struct.laya::Check", align 8
  %agg.tmp44 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp47 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp51 = alloca %"struct.laya::Check", align 8
  %ref.tmp56 = alloca %"struct.laya::Check", align 8
  %ref.tmp60 = alloca %"struct.laya::Check", align 8
  %agg.tmp61 = alloca %"struct.laya::BufferRef", align 4
  %wide = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp65 = alloca %"struct.laya::Check", align 8
  %agg.tmp66 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp69 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp73 = alloca %"struct.laya::Check", align 8
  %gated = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp78 = alloca %"struct.laya::Check", align 8
  %agg.tmp79 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp83 = alloca %"struct.laya::Check", align 8
  %down = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp88 = alloca %"struct.laya::Check", align 8
  %agg.tmp89 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp92 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp96 = alloca %"struct.laya::Check", align 8
  %ref.tmp101 = alloca %"struct.laya::Check", align 8
  %ref.tmp117 = alloca %"struct.laya::Check", align 8
  %final_norm = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp121 = alloca %"struct.laya::Check", align 8
  %agg.tmp122 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp131 = alloca %"struct.laya::Check", align 8
  %ref.tmp136 = alloca %"struct.laya::Check", align 8
  %layer140 = alloca i8, align 1
  %normalized146 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp147 = alloca %"struct.laya::Check", align 8
  %agg.tmp148 = alloca %"struct.laya::BufferRef", align 4
  %qkv152 = alloca [2 x %"struct.laya::full::FullOwnerSpec"], align 4
  %qkv_primary160 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp161 = alloca %"struct.laya::Check", align 8
  %agg.tmp162 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp165 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp170 = alloca %"struct.laya::Check", align 8
  %attended175 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp176 = alloca %"struct.laya::Check", align 8
  %projected180 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp181 = alloca %"struct.laya::Check", align 8
  %agg.tmp182 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp185 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp189 = alloca %"struct.laya::Check", align 8
  %ref.tmp194 = alloca %"struct.laya::Check", align 8
  %ref.tmp198 = alloca %"struct.laya::Check", align 8
  %agg.tmp199 = alloca %"struct.laya::BufferRef", align 4
  %fc1 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp203 = alloca %"struct.laya::Check", align 8
  %agg.tmp204 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp207 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp211 = alloca %"struct.laya::Check", align 8
  %relu = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp216 = alloca %"struct.laya::Check", align 8
  %fc2 = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp220 = alloca %"struct.laya::Check", align 8
  %agg.tmp221 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp224 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp228 = alloca %"struct.laya::Check", align 8
  %ref.tmp233 = alloca %"struct.laya::Check", align 8
  %markers = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp254 = alloca %"struct.laya::Check", align 8
  %marker_norm = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp258 = alloca %"struct.laya::Check", align 8
  %agg.tmp259 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp263 = alloca %"struct.laya::Check", align 8
  %scorer_baked = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp269 = alloca %"struct.laya::Check", align 8
  %ref.tmp274 = alloca %"struct.laya::Check", align 8
  %agg.tmp275 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp278 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp282 = alloca %"struct.laya::Check", align 8
  %agg.tmp288 = alloca %"struct.laya::BufferRef", align 4
  %tmp = alloca %"struct.laya::Check", align 8
  %scorer_bias = alloca %"struct.laya::full::FullTensorDescriptor", align 4
  %scorer_bias_id = alloca i16, align 2
  %ref.tmp291 = alloca %"struct.laya::Check", align 8
  %scorer_hidden = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp295 = alloca %"struct.laya::Check", align 8
  %raw = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp299 = alloca %"struct.laya::Check", align 8
  %agg.tmp300 = alloca %"struct.laya::WeightKey", align 1
  %ref.tmp307 = alloca %"struct.laya::Check", align 8
  %prob = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp311 = alloca %"struct.laya::Check", align 8
  %stats = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp315 = alloca %"struct.laya::Check", align 8
  %act_input = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp319 = alloca %"struct.laya::Check", align 8
  %act_dot = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp323 = alloca %"struct.laya::Check", align 8
  %agg.tmp324 = alloca %"struct.laya::WeightKey", align 1
  %act_bias = alloca %"struct.laya::full::FullTensorDescriptor", align 4
  %act_bias_id = alloca i16, align 2
  %ref.tmp331 = alloca %"struct.laya::Check", align 8
  %act_hidden = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp335 = alloca %"struct.laya::Check", align 8
  %ref.tmp339 = alloca %"struct.laya::Check", align 8
  %agg.tmp340 = alloca %"struct.laya::WeightKey", align 1
  %agg.tmp343 = alloca %"struct.laya::BufferRef", align 4
  store %"struct.laya::full::(anonymous namespace)::Controller"* %this, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, metadata !13058, metadata !DIExpression()), !dbg !13060
  store %"struct.laya::full::FullOwnerSpec"* %candidate, %"struct.laya::full::FullOwnerSpec"** %candidate.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %candidate.addr, metadata !13061, metadata !DIExpression()), !dbg !13062
  store %"struct.laya::full::FullOwnerSpec"* %act, %"struct.laya::full::FullOwnerSpec"** %act.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %act.addr, metadata !13063, metadata !DIExpression()), !dbg !13064
  %this1 = load %"struct.laya::full::(anonymous namespace)::Controller"*, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  %0 = bitcast %"struct.laya::full::FullOwnerSpec"* %hidden to i8*, !dbg !13065
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %0) #285, !dbg !13065
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %hidden, metadata !13066, metadata !DIExpression()), !dbg !13067
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden) #285, !dbg !13067
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %agg.result, metadata !13068, metadata !DIExpression()), !dbg !13069
  call void @_ZN4laya4full12_GLOBAL__N_110Controller12embed_tokensERNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13070
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13071
  br i1 %call, label %if.end, label %if.then, !dbg !13073

if.then:                                          ; preds = %entry
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup363, !dbg !13074

if.end:                                           ; preds = %entry
  %1 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !13075
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %1) #285, !dbg !13075
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10load_gammaEh(%"struct.laya::Check"* sret align 8 %ref.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 1), !dbg !13075
  %2 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp, align 8, !dbg !13076
  store %"struct.laya::Check" %2, %"struct.laya::Check"* %agg.result, align 8, !dbg !13076
  %3 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !13077
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %3) #285, !dbg !13077
  %call2 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13078
  br i1 %call2, label %if.end4, label %if.then3, !dbg !13080

if.then3:                                         ; preds = %if.end
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup363, !dbg !13081

if.end4:                                          ; preds = %if.end
  %4 = bitcast %"struct.laya::full::FullOwnerSpec"* %normed to i8*, !dbg !13082
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %4) #285, !dbg !13082
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %normed, metadata !13083, metadata !DIExpression()), !dbg !13084
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normed) #285, !dbg !13084
  %5 = bitcast %"struct.laya::Check"* %ref.tmp5 to i8*, !dbg !13085
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %5) #285, !dbg !13085
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %hidden, i32 0, i32 0, !dbg !13086
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 1, !dbg !13087
  %6 = load i8, i8* %bank, align 1, !dbg !13087
  %conv = zext i8 %6 to i32, !dbg !13088
  %sub = sub nsw i32 1, %conv, !dbg !13089
  %conv6 = trunc i32 %sub to i8, !dbg !13090
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 1, i8 zeroext %conv6, i8 zeroext 0), !dbg !13091
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp5, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 16, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 1, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0, i8 zeroext 1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normed), !dbg !13085
  %7 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp5, align 8, !dbg !13092
  store %"struct.laya::Check" %7, %"struct.laya::Check"* %agg.result, align 8, !dbg !13092
  %8 = bitcast %"struct.laya::Check"* %ref.tmp5 to i8*, !dbg !13093
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %8) #285, !dbg !13093
  %call7 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13094
  br i1 %call7, label %if.end9, label %if.then8, !dbg !13096

if.then8:                                         ; preds = %if.end4
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup362, !dbg !13097

if.end9:                                          ; preds = %if.end4
  %9 = bitcast %"struct.laya::Check"* %ref.tmp10 to i8*, !dbg !13098
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %9) #285, !dbg !13098
  %rt = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13099
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt, align 8, !dbg !13099
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp10, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %10, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13098
  %11 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp10, align 8, !dbg !13100
  store %"struct.laya::Check" %11, %"struct.laya::Check"* %agg.result, align 8, !dbg !13100
  %12 = bitcast %"struct.laya::Check"* %ref.tmp10 to i8*, !dbg !13101
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %12) #285, !dbg !13101
  %call11 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13102
  br i1 %call11, label %if.end13, label %if.then12, !dbg !13104

if.then12:                                        ; preds = %if.end9
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup362, !dbg !13105

if.end13:                                         ; preds = %if.end9
  %13 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %normed, align 4, !dbg !13106
  store %"struct.laya::full::FullOwnerSpec" %13, %"struct.laya::full::FullOwnerSpec"* %hidden, align 4, !dbg !13106
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13107
  br label %VITIS_LOOP_564_1, !dbg !13107

VITIS_LOOP_564_1:                                 ; preds = %if.end13
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %layer) #285, !dbg !13108
  call void @llvm.dbg.declare(metadata i8* %layer, metadata !13110, metadata !DIExpression()), !dbg !13111
  store i8 0, i8* %layer, align 1, !dbg !13111
  br label %for.cond, !dbg !13108

for.cond:                                         ; preds = %for.inc, %VITIS_LOOP_564_1
  %14 = load i8, i8* %layer, align 1, !dbg !13112
  %conv14 = zext i8 %14 to i32, !dbg !13112
  %cmp = icmp slt i32 %conv14, 28, !dbg !13114
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !13115

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup115, !dbg !13115

for.body:                                         ; preds = %for.cond
  %15 = bitcast %"struct.laya::full::FullOwnerSpec"** %att_source to i8*, !dbg !13116
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %15) #285, !dbg !13116
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %att_source, metadata !13118, metadata !DIExpression()), !dbg !13119
  store %"struct.laya::full::FullOwnerSpec"* %hidden, %"struct.laya::full::FullOwnerSpec"** %att_source, align 8, !dbg !13119
  %16 = bitcast %"struct.laya::full::FullOwnerSpec"* %normalized to i8*, !dbg !13120
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %16) #285, !dbg !13120
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %normalized, metadata !13121, metadata !DIExpression()), !dbg !13122
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized) #285, !dbg !13122
  %17 = load i8, i8* %layer, align 1, !dbg !13123
  %tobool = icmp ne i8 %17, 0, !dbg !13123
  br i1 %tobool, label %if.then15, label %if.end21, !dbg !13125

if.then15:                                        ; preds = %for.body
  %18 = bitcast %"struct.laya::Check"* %ref.tmp16 to i8*, !dbg !13126
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %18) #285, !dbg !13126
  %19 = load i8, i8* %layer, align 1, !dbg !13128
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp17, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext 0, i8 zeroext 0), !dbg !13129
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp16, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 17, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 2, i8 zeroext %19, %"struct.laya::BufferRef"* byval align 4 %agg.tmp17, i8 zeroext 0, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized), !dbg !13126
  %20 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp16, align 8, !dbg !13130
  store %"struct.laya::Check" %20, %"struct.laya::Check"* %agg.result, align 8, !dbg !13130
  %21 = bitcast %"struct.laya::Check"* %ref.tmp16 to i8*, !dbg !13131
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %21) #285, !dbg !13131
  %call18 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13132
  br i1 %call18, label %if.end20, label %if.then19, !dbg !13134

if.then19:                                        ; preds = %if.then15
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup112, !dbg !13135

if.end20:                                         ; preds = %if.then15
  store %"struct.laya::full::FullOwnerSpec"* %normalized, %"struct.laya::full::FullOwnerSpec"** %att_source, align 8, !dbg !13136
  br label %if.end21, !dbg !13137

if.end21:                                         ; preds = %if.end20, %for.body
  %22 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv to i8*, !dbg !13138
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %22) #285, !dbg !13138
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv, metadata !13139, metadata !DIExpression()), !dbg !13141
  %array.begin = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv, i32 0, i32 0, !dbg !13141
  br label %arrayctor.loop, !dbg !13141

arrayctor.loop:                                   ; preds = %arrayctor.loop, %if.end21
  %indvar = phi i32 [ 0, %if.end21 ], [ %indvarinc, %arrayctor.loop ], !dbg !13141
  %indvarinc = add i32 %indvar, 1, !dbg !13141
  %array.src = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv, i32 0, i32 %indvar, !dbg !13141
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %array.src) #285, !dbg !13141
  %23 = icmp eq i32 %indvar, 1, !dbg !13141
  br i1 %23, label %if.end2123, label %arrayctor.loop, !dbg !13141

if.end2123:                                       ; preds = %arrayctor.loop
  br label %if.end2122, !dbg !13141

if.end2122:                                       ; preds = %if.end2123
  %24 = bitcast %"struct.laya::full::FullOwnerSpec"* %qkv_primary to i8*, !dbg !13142
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %24) #285, !dbg !13142
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %qkv_primary, metadata !13143, metadata !DIExpression()), !dbg !13144
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %qkv_primary) #285, !dbg !13144
  %25 = bitcast %"struct.laya::Check"* %ref.tmp24 to i8*, !dbg !13145
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %25) #285, !dbg !13145
  %family = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp25, i32 0, i32 0, !dbg !13146
  store i8 1, i8* %family, align 1, !dbg !13146
  %layer26 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp25, i32 0, i32 1, !dbg !13146
  %26 = load i8, i8* %layer, align 1, !dbg !13147
  store i8 %26, i8* %layer26, align 1, !dbg !13146
  %27 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %att_source, align 8, !dbg !13148
  %28 = load i8, i8* %layer, align 1, !dbg !13149
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp27, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 5, i8 zeroext 0, i8 zeroext 0), !dbg !13150
  %arraydecay = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv, i64 0, i64 0, !dbg !13151
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp24, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 48, %"struct.laya::WeightKey"* byval align 1 %agg.tmp25, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %27, i8 zeroext 2, i8 zeroext %28, %"struct.laya::BufferRef"* byval align 4 %agg.tmp27, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %qkv_primary, %"struct.laya::full::FullOwnerSpec"* %arraydecay), !dbg !13145
  %29 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp24, align 8, !dbg !13152
  store %"struct.laya::Check" %29, %"struct.laya::Check"* %agg.result, align 8, !dbg !13152
  %30 = bitcast %"struct.laya::Check"* %ref.tmp24 to i8*, !dbg !13153
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %30) #285, !dbg !13153
  %call28 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13154
  br i1 %call28, label %if.end30, label %if.then29, !dbg !13156

if.then29:                                        ; preds = %if.end2122
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup110, !dbg !13157

if.end30:                                         ; preds = %if.end2122
  %31 = load i8, i8* %layer, align 1, !dbg !13158
  %tobool31 = icmp ne i8 %31, 0, !dbg !13158
  br i1 %tobool31, label %if.then32, label %if.end38, !dbg !13160

if.then32:                                        ; preds = %if.end30
  %32 = bitcast %"struct.laya::Check"* %ref.tmp33 to i8*, !dbg !13161
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %32) #285, !dbg !13161
  %rt34 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13163
  %33 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt34, align 8, !dbg !13163
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp33, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %33, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized), !dbg !13161
  %34 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp33, align 8, !dbg !13164
  store %"struct.laya::Check" %34, %"struct.laya::Check"* %agg.result, align 8, !dbg !13164
  %35 = bitcast %"struct.laya::Check"* %ref.tmp33 to i8*, !dbg !13165
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %35) #285, !dbg !13165
  %call35 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13166
  br i1 %call35, label %if.end37, label %if.then36, !dbg !13168

if.then36:                                        ; preds = %if.then32
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup110, !dbg !13169

if.end37:                                         ; preds = %if.then32
  br label %if.end38, !dbg !13170

if.end38:                                         ; preds = %if.end37, %if.end30
  %36 = bitcast %"struct.laya::full::FullOwnerSpec"* %attended to i8*, !dbg !13171
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %36) #285, !dbg !13171
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %attended, metadata !13172, metadata !DIExpression()), !dbg !13173
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended) #285, !dbg !13173
  %37 = bitcast %"struct.laya::Check"* %ref.tmp39 to i8*, !dbg !13174
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %37) #285, !dbg !13174
  %38 = load i8, i8* %layer, align 1, !dbg !13175
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9attentionEhhRA2_KNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp39, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext %38, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %qkv, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended), !dbg !13174
  %39 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp39, align 8, !dbg !13176
  store %"struct.laya::Check" %39, %"struct.laya::Check"* %agg.result, align 8, !dbg !13176
  %40 = bitcast %"struct.laya::Check"* %ref.tmp39 to i8*, !dbg !13177
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %40) #285, !dbg !13177
  %call40 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13178
  br i1 %call40, label %if.end42, label %if.then41, !dbg !13180

if.then41:                                        ; preds = %if.end38
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup109, !dbg !13181

if.end42:                                         ; preds = %if.end38
  %41 = bitcast %"struct.laya::full::FullOwnerSpec"* %projected to i8*, !dbg !13182
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %41) #285, !dbg !13182
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %projected, metadata !13183, metadata !DIExpression()), !dbg !13184
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected) #285, !dbg !13184
  %42 = bitcast %"struct.laya::Check"* %ref.tmp43 to i8*, !dbg !13185
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %42) #285, !dbg !13185
  %family45 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp44, i32 0, i32 0, !dbg !13186
  store i8 2, i8* %family45, align 1, !dbg !13186
  %layer46 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp44, i32 0, i32 1, !dbg !13186
  %43 = load i8, i8* %layer, align 1, !dbg !13187
  store i8 %43, i8* %layer46, align 1, !dbg !13186
  %44 = load i8, i8* %layer, align 1, !dbg !13188
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp47, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 3, i8 zeroext 0, i8 zeroext 0), !dbg !13189
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp43, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 49, %"struct.laya::WeightKey"* byval align 1 %agg.tmp44, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended, i8 zeroext 2, i8 zeroext %44, %"struct.laya::BufferRef"* byval align 4 %agg.tmp47, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13185
  %45 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp43, align 8, !dbg !13190
  store %"struct.laya::Check" %45, %"struct.laya::Check"* %agg.result, align 8, !dbg !13190
  %46 = bitcast %"struct.laya::Check"* %ref.tmp43 to i8*, !dbg !13191
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %46) #285, !dbg !13191
  %call48 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13192
  br i1 %call48, label %if.end50, label %if.then49, !dbg !13194

if.then49:                                        ; preds = %if.end42
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup108, !dbg !13195

if.end50:                                         ; preds = %if.end42
  %47 = bitcast %"struct.laya::Check"* %ref.tmp51 to i8*, !dbg !13196
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %47) #285, !dbg !13196
  %rt52 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13197
  %48 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt52, align 8, !dbg !13197
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp51, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %48, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended), !dbg !13196
  %49 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp51, align 8, !dbg !13198
  store %"struct.laya::Check" %49, %"struct.laya::Check"* %agg.result, align 8, !dbg !13198
  %50 = bitcast %"struct.laya::Check"* %ref.tmp51 to i8*, !dbg !13199
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %50) #285, !dbg !13199
  %call53 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13200
  br i1 %call53, label %if.end55, label %if.then54, !dbg !13202

if.then54:                                        ; preds = %if.end50
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup108, !dbg !13203

if.end55:                                         ; preds = %if.end50
  %51 = bitcast %"struct.laya::Check"* %ref.tmp56 to i8*, !dbg !13204
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %51) #285, !dbg !13204
  %52 = load i8, i8* %layer, align 1, !dbg !13205
  call void @_ZN4laya4full12_GLOBAL__N_110Controller8residualEhhRKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp56, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext %52, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13204
  %53 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp56, align 8, !dbg !13206
  store %"struct.laya::Check" %53, %"struct.laya::Check"* %agg.result, align 8, !dbg !13206
  %54 = bitcast %"struct.laya::Check"* %ref.tmp56 to i8*, !dbg !13207
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %54) #285, !dbg !13207
  %call57 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13208
  br i1 %call57, label %if.end59, label %if.then58, !dbg !13210

if.then58:                                        ; preds = %if.end55
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup108, !dbg !13211

if.end59:                                         ; preds = %if.end55
  %55 = bitcast %"struct.laya::Check"* %ref.tmp60 to i8*, !dbg !13212
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %55) #285, !dbg !13212
  %56 = load i8, i8* %layer, align 1, !dbg !13213
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp61, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext 0, i8 zeroext 0), !dbg !13214
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp60, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 18, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 2, i8 zeroext %56, %"struct.laya::BufferRef"* byval align 4 %agg.tmp61, i8 zeroext 0, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized), !dbg !13212
  %57 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp60, align 8, !dbg !13215
  store %"struct.laya::Check" %57, %"struct.laya::Check"* %agg.result, align 8, !dbg !13215
  %58 = bitcast %"struct.laya::Check"* %ref.tmp60 to i8*, !dbg !13216
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %58) #285, !dbg !13216
  %call62 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13217
  br i1 %call62, label %if.end64, label %if.then63, !dbg !13219

if.then63:                                        ; preds = %if.end59
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup108, !dbg !13220

if.end64:                                         ; preds = %if.end59
  %59 = bitcast %"struct.laya::full::FullOwnerSpec"* %wide to i8*, !dbg !13221
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %59) #285, !dbg !13221
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %wide, metadata !13222, metadata !DIExpression()), !dbg !13223
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %wide) #285, !dbg !13223
  %60 = bitcast %"struct.laya::Check"* %ref.tmp65 to i8*, !dbg !13224
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %60) #285, !dbg !13224
  %family67 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp66, i32 0, i32 0, !dbg !13225
  store i8 3, i8* %family67, align 1, !dbg !13225
  %layer68 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp66, i32 0, i32 1, !dbg !13225
  %61 = load i8, i8* %layer, align 1, !dbg !13226
  store i8 %61, i8* %layer68, align 1, !dbg !13225
  %62 = load i8, i8* %layer, align 1, !dbg !13227
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp69, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 6, i8 zeroext 0, i8 zeroext 0), !dbg !13228
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp65, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 50, %"struct.laya::WeightKey"* byval align 1 %agg.tmp66, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized, i8 zeroext 2, i8 zeroext %62, %"struct.laya::BufferRef"* byval align 4 %agg.tmp69, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %wide, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13224
  %63 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp65, align 8, !dbg !13229
  store %"struct.laya::Check" %63, %"struct.laya::Check"* %agg.result, align 8, !dbg !13229
  %64 = bitcast %"struct.laya::Check"* %ref.tmp65 to i8*, !dbg !13230
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %64) #285, !dbg !13230
  %call70 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13231
  br i1 %call70, label %if.end72, label %if.then71, !dbg !13233

if.then71:                                        ; preds = %if.end64
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup107, !dbg !13234

if.end72:                                         ; preds = %if.end64
  %65 = bitcast %"struct.laya::Check"* %ref.tmp73 to i8*, !dbg !13235
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %65) #285, !dbg !13235
  %rt74 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13236
  %66 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt74, align 8, !dbg !13236
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp73, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %66, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized), !dbg !13235
  %67 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp73, align 8, !dbg !13237
  store %"struct.laya::Check" %67, %"struct.laya::Check"* %agg.result, align 8, !dbg !13237
  %68 = bitcast %"struct.laya::Check"* %ref.tmp73 to i8*, !dbg !13238
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %68) #285, !dbg !13238
  %call75 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13239
  br i1 %call75, label %if.end77, label %if.then76, !dbg !13241

if.then76:                                        ; preds = %if.end72
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup107, !dbg !13242

if.end77:                                         ; preds = %if.end72
  %69 = bitcast %"struct.laya::full::FullOwnerSpec"* %gated to i8*, !dbg !13243
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %69) #285, !dbg !13243
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %gated, metadata !13244, metadata !DIExpression()), !dbg !13245
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %gated) #285, !dbg !13245
  %70 = bitcast %"struct.laya::Check"* %ref.tmp78 to i8*, !dbg !13246
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %70) #285, !dbg !13246
  %71 = load i8, i8* %layer, align 1, !dbg !13247
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp79, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 7, i8 zeroext 0, i8 zeroext 0), !dbg !13248
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6vectorENS_2OpERKNS0_13FullOwnerSpecEPS5_hhNS_9BufferRefEhtRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp78, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 96, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %wide, %"struct.laya::full::FullOwnerSpec"* null, i8 zeroext 2, i8 zeroext %71, %"struct.laya::BufferRef"* byval align 4 %agg.tmp79, i8 zeroext 0, i16 zeroext 2624, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %gated), !dbg !13246
  %72 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp78, align 8, !dbg !13249
  store %"struct.laya::Check" %72, %"struct.laya::Check"* %agg.result, align 8, !dbg !13249
  %73 = bitcast %"struct.laya::Check"* %ref.tmp78 to i8*, !dbg !13250
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %73) #285, !dbg !13250
  %call80 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13251
  br i1 %call80, label %if.end82, label %if.then81, !dbg !13253

if.then81:                                        ; preds = %if.end77
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup106, !dbg !13254

if.end82:                                         ; preds = %if.end77
  %74 = bitcast %"struct.laya::Check"* %ref.tmp83 to i8*, !dbg !13255
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %74) #285, !dbg !13255
  %rt84 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13256
  %75 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt84, align 8, !dbg !13256
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp83, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %75, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %wide), !dbg !13255
  %76 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp83, align 8, !dbg !13257
  store %"struct.laya::Check" %76, %"struct.laya::Check"* %agg.result, align 8, !dbg !13257
  %77 = bitcast %"struct.laya::Check"* %ref.tmp83 to i8*, !dbg !13258
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %77) #285, !dbg !13258
  %call85 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13259
  br i1 %call85, label %if.end87, label %if.then86, !dbg !13261

if.then86:                                        ; preds = %if.end82
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup106, !dbg !13262

if.end87:                                         ; preds = %if.end82
  %78 = bitcast %"struct.laya::full::FullOwnerSpec"* %down to i8*, !dbg !13263
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %78) #285, !dbg !13263
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %down, metadata !13264, metadata !DIExpression()), !dbg !13265
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %down) #285, !dbg !13265
  %79 = bitcast %"struct.laya::Check"* %ref.tmp88 to i8*, !dbg !13266
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %79) #285, !dbg !13266
  %family90 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp89, i32 0, i32 0, !dbg !13267
  store i8 4, i8* %family90, align 1, !dbg !13267
  %layer91 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp89, i32 0, i32 1, !dbg !13267
  %80 = load i8, i8* %layer, align 1, !dbg !13268
  store i8 %80, i8* %layer91, align 1, !dbg !13267
  %81 = load i8, i8* %layer, align 1, !dbg !13269
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp92, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 3, i8 zeroext 0, i8 zeroext 0), !dbg !13270
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp88, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 51, %"struct.laya::WeightKey"* byval align 1 %agg.tmp89, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %gated, i8 zeroext 2, i8 zeroext %81, %"struct.laya::BufferRef"* byval align 4 %agg.tmp92, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %down, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13266
  %82 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp88, align 8, !dbg !13271
  store %"struct.laya::Check" %82, %"struct.laya::Check"* %agg.result, align 8, !dbg !13271
  %83 = bitcast %"struct.laya::Check"* %ref.tmp88 to i8*, !dbg !13272
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %83) #285, !dbg !13272
  %call93 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13273
  br i1 %call93, label %if.end95, label %if.then94, !dbg !13275

if.then94:                                        ; preds = %if.end87
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !13276

if.end95:                                         ; preds = %if.end87
  %84 = bitcast %"struct.laya::Check"* %ref.tmp96 to i8*, !dbg !13277
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %84) #285, !dbg !13277
  %rt97 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13278
  %85 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt97, align 8, !dbg !13278
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp96, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %85, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %gated), !dbg !13277
  %86 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp96, align 8, !dbg !13279
  store %"struct.laya::Check" %86, %"struct.laya::Check"* %agg.result, align 8, !dbg !13279
  %87 = bitcast %"struct.laya::Check"* %ref.tmp96 to i8*, !dbg !13280
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %87) #285, !dbg !13280
  %call98 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13281
  br i1 %call98, label %if.end100, label %if.then99, !dbg !13283

if.then99:                                        ; preds = %if.end95
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !13284

if.end100:                                        ; preds = %if.end95
  %88 = bitcast %"struct.laya::Check"* %ref.tmp101 to i8*, !dbg !13285
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %88) #285, !dbg !13285
  %89 = load i8, i8* %layer, align 1, !dbg !13286
  call void @_ZN4laya4full12_GLOBAL__N_110Controller8residualEhhRKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp101, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext %89, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %down, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13285
  %90 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp101, align 8, !dbg !13287
  store %"struct.laya::Check" %90, %"struct.laya::Check"* %agg.result, align 8, !dbg !13287
  %91 = bitcast %"struct.laya::Check"* %ref.tmp101 to i8*, !dbg !13288
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %91) #285, !dbg !13288
  %call102 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13289
  br i1 %call102, label %if.end104, label %if.then103, !dbg !13291

if.then103:                                       ; preds = %if.end100
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !13292

if.end104:                                        ; preds = %if.end100
  %rt105 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13293
  %92 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt105, align 8, !dbg !13293
  %encoder_layers_completed = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %92, i32 0, i32 29, !dbg !13294
  %93 = load i8, i8* %encoder_layers_completed, align 8, !dbg !13295
  %inc = add i8 %93, 1, !dbg !13295
  store i8 %inc, i8* %encoder_layers_completed, align 8, !dbg !13295
  %94 = load i8, i8* %layer, align 1, !dbg !13296
  call void @_ZN4laya4full12_GLOBAL__N_110Controller15checkpoint_nameEPKchRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.1, i64 0, i64 0), i8 zeroext %94, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13297
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !13298
  br label %cleanup, !dbg !13298

cleanup:                                          ; preds = %if.end104, %if.then103, %if.then99, %if.then94
  %95 = bitcast %"struct.laya::full::FullOwnerSpec"* %down to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %95) #285, !dbg !13298
  br label %cleanup106

cleanup106:                                       ; preds = %cleanup, %if.then86, %if.then81
  %96 = bitcast %"struct.laya::full::FullOwnerSpec"* %gated to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %96) #285, !dbg !13298
  br label %cleanup107

cleanup107:                                       ; preds = %cleanup106, %if.then76, %if.then71
  %97 = bitcast %"struct.laya::full::FullOwnerSpec"* %wide to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %97) #285, !dbg !13298
  br label %cleanup108

cleanup108:                                       ; preds = %cleanup107, %if.then63, %if.then58, %if.then54, %if.then49
  %98 = bitcast %"struct.laya::full::FullOwnerSpec"* %projected to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %98) #285, !dbg !13298
  br label %cleanup109

cleanup109:                                       ; preds = %cleanup108, %if.then41
  %99 = bitcast %"struct.laya::full::FullOwnerSpec"* %attended to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %99) #285, !dbg !13298
  br label %cleanup110

cleanup110:                                       ; preds = %cleanup109, %if.then36, %if.then29
  %100 = bitcast %"struct.laya::full::FullOwnerSpec"* %qkv_primary to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %100) #285, !dbg !13298
  %101 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %101) #285, !dbg !13298
  br label %cleanup112

cleanup112:                                       ; preds = %cleanup110, %if.then19
  %102 = bitcast %"struct.laya::full::FullOwnerSpec"* %normalized to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %102) #285, !dbg !13298
  %103 = bitcast %"struct.laya::full::FullOwnerSpec"** %att_source to i8*, !dbg !13298
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %103) #285, !dbg !13298
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup115 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup112
  br label %for.inc, !dbg !13299

for.inc:                                          ; preds = %cleanup.cont
  %104 = load i8, i8* %layer, align 1, !dbg !13300
  %inc114 = add i8 %104, 1, !dbg !13300
  store i8 %inc114, i8* %layer, align 1, !dbg !13300
  br label %for.cond, !dbg !13301, !llvm.loop !13302

cleanup115:                                       ; preds = %cleanup112, %for.cond.cleanup
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %layer) #285, !dbg !13301
  %cleanup.dest116 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest116, label %cleanup362 [
    i32 3, label %for.end
  ]

for.end:                                          ; preds = %cleanup115
  %105 = bitcast %"struct.laya::Check"* %ref.tmp117 to i8*, !dbg !13305
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %105) #285, !dbg !13305
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10load_gammaEh(%"struct.laya::Check"* sret align 8 %ref.tmp117, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2), !dbg !13305
  %106 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp117, align 8, !dbg !13306
  store %"struct.laya::Check" %106, %"struct.laya::Check"* %agg.result, align 8, !dbg !13306
  %107 = bitcast %"struct.laya::Check"* %ref.tmp117 to i8*, !dbg !13307
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %107) #285, !dbg !13307
  %call118 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13308
  br i1 %call118, label %if.end120, label %if.then119, !dbg !13310

if.then119:                                       ; preds = %for.end
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup362, !dbg !13311

if.end120:                                        ; preds = %for.end
  %108 = bitcast %"struct.laya::full::FullOwnerSpec"* %final_norm to i8*, !dbg !13312
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %108) #285, !dbg !13312
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %final_norm, metadata !13313, metadata !DIExpression()), !dbg !13314
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %final_norm) #285, !dbg !13314
  %109 = bitcast %"struct.laya::Check"* %ref.tmp121 to i8*, !dbg !13315
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %109) #285, !dbg !13315
  %ref123 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %hidden, i32 0, i32 0, !dbg !13316
  %bank124 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref123, i32 0, i32 1, !dbg !13317
  %110 = load i8, i8* %bank124, align 1, !dbg !13317
  %conv125 = zext i8 %110 to i32, !dbg !13318
  %sub126 = sub nsw i32 1, %conv125, !dbg !13319
  %conv127 = trunc i32 %sub126 to i8, !dbg !13320
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp122, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 1, i8 zeroext %conv127, i8 zeroext 0), !dbg !13321
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp121, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 19, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 3, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp122, i8 zeroext 0, i8 zeroext 2, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %final_norm), !dbg !13315
  %111 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp121, align 8, !dbg !13322
  store %"struct.laya::Check" %111, %"struct.laya::Check"* %agg.result, align 8, !dbg !13322
  %112 = bitcast %"struct.laya::Check"* %ref.tmp121 to i8*, !dbg !13323
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %112) #285, !dbg !13323
  %call128 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13324
  br i1 %call128, label %if.end130, label %if.then129, !dbg !13326

if.then129:                                       ; preds = %if.end120
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup361, !dbg !13327

if.end130:                                        ; preds = %if.end120
  %113 = bitcast %"struct.laya::Check"* %ref.tmp131 to i8*, !dbg !13328
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %113) #285, !dbg !13328
  %rt132 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13329
  %114 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt132, align 8, !dbg !13329
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp131, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %114, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13328
  %115 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp131, align 8, !dbg !13330
  store %"struct.laya::Check" %115, %"struct.laya::Check"* %agg.result, align 8, !dbg !13330
  %116 = bitcast %"struct.laya::Check"* %ref.tmp131 to i8*, !dbg !13331
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %116) #285, !dbg !13331
  %call133 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13332
  br i1 %call133, label %if.end135, label %if.then134, !dbg !13334

if.then134:                                       ; preds = %if.end130
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup361, !dbg !13335

if.end135:                                        ; preds = %if.end130
  %117 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %final_norm, align 4, !dbg !13336
  store %"struct.laya::full::FullOwnerSpec" %117, %"struct.laya::full::FullOwnerSpec"* %hidden, align 4, !dbg !13336
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13337
  %118 = bitcast %"struct.laya::Check"* %ref.tmp136 to i8*, !dbg !13338
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %118) #285, !dbg !13338
  call void @_ZN4laya4full12_GLOBAL__N_110Controller8type_addERNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp136, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13338
  %119 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp136, align 8, !dbg !13339
  store %"struct.laya::Check" %119, %"struct.laya::Check"* %agg.result, align 8, !dbg !13339
  %120 = bitcast %"struct.laya::Check"* %ref.tmp136 to i8*, !dbg !13340
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %120) #285, !dbg !13340
  %call137 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13341
  br i1 %call137, label %if.end139, label %if.then138, !dbg !13343

if.then138:                                       ; preds = %if.end135
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup361, !dbg !13344

if.end139:                                        ; preds = %if.end135
  br label %VITIS_LOOP_636_2, !dbg !13341

VITIS_LOOP_636_2:                                 ; preds = %if.end139
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %layer140) #285, !dbg !13345
  call void @llvm.dbg.declare(metadata i8* %layer140, metadata !13347, metadata !DIExpression()), !dbg !13348
  store i8 0, i8* %layer140, align 1, !dbg !13348
  br label %for.cond141, !dbg !13345

for.cond141:                                      ; preds = %for.inc249, %VITIS_LOOP_636_2
  %121 = load i8, i8* %layer140, align 1, !dbg !13349
  %conv142 = zext i8 %121 to i32, !dbg !13349
  %cmp143 = icmp slt i32 %conv142, 2, !dbg !13351
  br i1 %cmp143, label %for.body145, label %for.cond.cleanup144, !dbg !13352

for.cond.cleanup144:                              ; preds = %for.cond141
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup251, !dbg !13352

for.body145:                                      ; preds = %for.cond141
  %122 = bitcast %"struct.laya::full::FullOwnerSpec"* %normalized146 to i8*, !dbg !13353
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %122) #285, !dbg !13353
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %normalized146, metadata !13355, metadata !DIExpression()), !dbg !13356
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146) #285, !dbg !13356
  %123 = bitcast %"struct.laya::Check"* %ref.tmp147 to i8*, !dbg !13357
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %123) #285, !dbg !13357
  %124 = load i8, i8* %layer140, align 1, !dbg !13358
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp148, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext 0, i8 zeroext 0), !dbg !13359
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp147, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 17, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 4, i8 zeroext %124, %"struct.laya::BufferRef"* byval align 4 %agg.tmp148, i8 zeroext 0, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146), !dbg !13357
  %125 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp147, align 8, !dbg !13360
  store %"struct.laya::Check" %125, %"struct.laya::Check"* %agg.result, align 8, !dbg !13360
  %126 = bitcast %"struct.laya::Check"* %ref.tmp147 to i8*, !dbg !13361
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %126) #285, !dbg !13361
  %call149 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13362
  br i1 %call149, label %if.end151, label %if.then150, !dbg !13364

if.then150:                                       ; preds = %for.body145
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup246, !dbg !13365

if.end151:                                        ; preds = %for.body145
  %127 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152 to i8*, !dbg !13366
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %127) #285, !dbg !13366
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152, metadata !13367, metadata !DIExpression()), !dbg !13368
  %array.begin153 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152, i32 0, i32 0, !dbg !13368
  br label %arrayctor.loop156, !dbg !13368

arrayctor.loop156:                                ; preds = %arrayctor.loop156, %if.end151
  %indvar157 = phi i32 [ 0, %if.end151 ], [ %indvarinc158, %arrayctor.loop156 ], !dbg !13368
  %indvarinc158 = add i32 %indvar157, 1, !dbg !13368
  %array.src159 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152, i32 0, i32 %indvar157, !dbg !13368
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %array.src159) #285, !dbg !13368
  %128 = icmp eq i32 %indvar157, 1, !dbg !13368
  br i1 %128, label %if.end151155, label %arrayctor.loop156, !dbg !13368

if.end151155:                                     ; preds = %arrayctor.loop156
  br label %if.end151154, !dbg !13368

if.end151154:                                     ; preds = %if.end151155
  %129 = bitcast %"struct.laya::full::FullOwnerSpec"* %qkv_primary160 to i8*, !dbg !13369
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %129) #285, !dbg !13369
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %qkv_primary160, metadata !13370, metadata !DIExpression()), !dbg !13371
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %qkv_primary160) #285, !dbg !13371
  %130 = bitcast %"struct.laya::Check"* %ref.tmp161 to i8*, !dbg !13372
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %130) #285, !dbg !13372
  %family163 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp162, i32 0, i32 0, !dbg !13373
  store i8 5, i8* %family163, align 1, !dbg !13373
  %layer164 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp162, i32 0, i32 1, !dbg !13373
  %131 = load i8, i8* %layer140, align 1, !dbg !13374
  store i8 %131, i8* %layer164, align 1, !dbg !13373
  %132 = load i8, i8* %layer140, align 1, !dbg !13375
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp165, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 5, i8 zeroext 0, i8 zeroext 0), !dbg !13376
  %arraydecay166 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152, i64 0, i64 0, !dbg !13377
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp161, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 48, %"struct.laya::WeightKey"* byval align 1 %agg.tmp162, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146, i8 zeroext 4, i8 zeroext %132, %"struct.laya::BufferRef"* byval align 4 %agg.tmp165, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %qkv_primary160, %"struct.laya::full::FullOwnerSpec"* %arraydecay166), !dbg !13372
  %133 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp161, align 8, !dbg !13378
  store %"struct.laya::Check" %133, %"struct.laya::Check"* %agg.result, align 8, !dbg !13378
  %134 = bitcast %"struct.laya::Check"* %ref.tmp161 to i8*, !dbg !13379
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %134) #285, !dbg !13379
  %call167 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13380
  br i1 %call167, label %if.end169, label %if.then168, !dbg !13382

if.then168:                                       ; preds = %if.end151154
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup244, !dbg !13383

if.end169:                                        ; preds = %if.end151154
  %135 = bitcast %"struct.laya::Check"* %ref.tmp170 to i8*, !dbg !13384
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %135) #285, !dbg !13384
  %rt171 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13385
  %136 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt171, align 8, !dbg !13385
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp170, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %136, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146), !dbg !13384
  %137 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp170, align 8, !dbg !13386
  store %"struct.laya::Check" %137, %"struct.laya::Check"* %agg.result, align 8, !dbg !13386
  %138 = bitcast %"struct.laya::Check"* %ref.tmp170 to i8*, !dbg !13387
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %138) #285, !dbg !13387
  %call172 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13388
  br i1 %call172, label %if.end174, label %if.then173, !dbg !13390

if.then173:                                       ; preds = %if.end169
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup244, !dbg !13391

if.end174:                                        ; preds = %if.end169
  %139 = bitcast %"struct.laya::full::FullOwnerSpec"* %attended175 to i8*, !dbg !13392
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %139) #285, !dbg !13392
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %attended175, metadata !13393, metadata !DIExpression()), !dbg !13394
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended175) #285, !dbg !13394
  %140 = bitcast %"struct.laya::Check"* %ref.tmp176 to i8*, !dbg !13395
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %140) #285, !dbg !13395
  %141 = load i8, i8* %layer140, align 1, !dbg !13396
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9attentionEhhRA2_KNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp176, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 4, i8 zeroext %141, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %qkv152, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended175), !dbg !13395
  %142 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp176, align 8, !dbg !13397
  store %"struct.laya::Check" %142, %"struct.laya::Check"* %agg.result, align 8, !dbg !13397
  %143 = bitcast %"struct.laya::Check"* %ref.tmp176 to i8*, !dbg !13398
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %143) #285, !dbg !13398
  %call177 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13399
  br i1 %call177, label %if.end179, label %if.then178, !dbg !13401

if.then178:                                       ; preds = %if.end174
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup243, !dbg !13402

if.end179:                                        ; preds = %if.end174
  %144 = bitcast %"struct.laya::full::FullOwnerSpec"* %projected180 to i8*, !dbg !13403
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %144) #285, !dbg !13403
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %projected180, metadata !13404, metadata !DIExpression()), !dbg !13405
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected180) #285, !dbg !13405
  %145 = bitcast %"struct.laya::Check"* %ref.tmp181 to i8*, !dbg !13406
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %145) #285, !dbg !13406
  %family183 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp182, i32 0, i32 0, !dbg !13407
  store i8 6, i8* %family183, align 1, !dbg !13407
  %layer184 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp182, i32 0, i32 1, !dbg !13407
  %146 = load i8, i8* %layer140, align 1, !dbg !13408
  store i8 %146, i8* %layer184, align 1, !dbg !13407
  %147 = load i8, i8* %layer140, align 1, !dbg !13409
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp185, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 3, i8 zeroext 0, i8 zeroext 0), !dbg !13410
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp181, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 49, %"struct.laya::WeightKey"* byval align 1 %agg.tmp182, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended175, i8 zeroext 4, i8 zeroext %147, %"struct.laya::BufferRef"* byval align 4 %agg.tmp185, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected180, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13406
  %148 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp181, align 8, !dbg !13411
  store %"struct.laya::Check" %148, %"struct.laya::Check"* %agg.result, align 8, !dbg !13411
  %149 = bitcast %"struct.laya::Check"* %ref.tmp181 to i8*, !dbg !13412
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %149) #285, !dbg !13412
  %call186 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13413
  br i1 %call186, label %if.end188, label %if.then187, !dbg !13415

if.then187:                                       ; preds = %if.end179
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup242, !dbg !13416

if.end188:                                        ; preds = %if.end179
  %150 = bitcast %"struct.laya::Check"* %ref.tmp189 to i8*, !dbg !13417
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %150) #285, !dbg !13417
  %rt190 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13418
  %151 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt190, align 8, !dbg !13418
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp189, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %151, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %attended175), !dbg !13417
  %152 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp189, align 8, !dbg !13419
  store %"struct.laya::Check" %152, %"struct.laya::Check"* %agg.result, align 8, !dbg !13419
  %153 = bitcast %"struct.laya::Check"* %ref.tmp189 to i8*, !dbg !13420
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %153) #285, !dbg !13420
  %call191 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13421
  br i1 %call191, label %if.end193, label %if.then192, !dbg !13423

if.then192:                                       ; preds = %if.end188
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup242, !dbg !13424

if.end193:                                        ; preds = %if.end188
  %154 = bitcast %"struct.laya::Check"* %ref.tmp194 to i8*, !dbg !13425
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %154) #285, !dbg !13425
  %155 = load i8, i8* %layer140, align 1, !dbg !13426
  call void @_ZN4laya4full12_GLOBAL__N_110Controller8residualEhhRKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp194, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 4, i8 zeroext %155, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %projected180, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13425
  %156 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp194, align 8, !dbg !13427
  store %"struct.laya::Check" %156, %"struct.laya::Check"* %agg.result, align 8, !dbg !13427
  %157 = bitcast %"struct.laya::Check"* %ref.tmp194 to i8*, !dbg !13428
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %157) #285, !dbg !13428
  %call195 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13429
  br i1 %call195, label %if.end197, label %if.then196, !dbg !13431

if.then196:                                       ; preds = %if.end193
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup242, !dbg !13432

if.end197:                                        ; preds = %if.end193
  %158 = bitcast %"struct.laya::Check"* %ref.tmp198 to i8*, !dbg !13433
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %158) #285, !dbg !13433
  %159 = load i8, i8* %layer140, align 1, !dbg !13434
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp199, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext 0, i8 zeroext 0), !dbg !13435
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp198, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 18, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, i8 zeroext 4, i8 zeroext %159, %"struct.laya::BufferRef"* byval align 4 %agg.tmp199, i8 zeroext 0, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146), !dbg !13433
  %160 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp198, align 8, !dbg !13436
  store %"struct.laya::Check" %160, %"struct.laya::Check"* %agg.result, align 8, !dbg !13436
  %161 = bitcast %"struct.laya::Check"* %ref.tmp198 to i8*, !dbg !13437
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %161) #285, !dbg !13437
  %call200 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13438
  br i1 %call200, label %if.end202, label %if.then201, !dbg !13440

if.then201:                                       ; preds = %if.end197
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup242, !dbg !13441

if.end202:                                        ; preds = %if.end197
  %162 = bitcast %"struct.laya::full::FullOwnerSpec"* %fc1 to i8*, !dbg !13442
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %162) #285, !dbg !13442
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %fc1, metadata !13443, metadata !DIExpression()), !dbg !13444
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc1) #285, !dbg !13444
  %163 = bitcast %"struct.laya::Check"* %ref.tmp203 to i8*, !dbg !13445
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %163) #285, !dbg !13445
  %family205 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp204, i32 0, i32 0, !dbg !13446
  store i8 7, i8* %family205, align 1, !dbg !13446
  %layer206 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp204, i32 0, i32 1, !dbg !13446
  %164 = load i8, i8* %layer140, align 1, !dbg !13447
  store i8 %164, i8* %layer206, align 1, !dbg !13446
  %165 = load i8, i8* %layer140, align 1, !dbg !13448
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp207, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 9, i8 zeroext 0, i8 zeroext 0), !dbg !13449
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp203, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 52, %"struct.laya::WeightKey"* byval align 1 %agg.tmp204, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146, i8 zeroext 4, i8 zeroext %165, %"struct.laya::BufferRef"* byval align 4 %agg.tmp207, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc1, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13445
  %166 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp203, align 8, !dbg !13450
  store %"struct.laya::Check" %166, %"struct.laya::Check"* %agg.result, align 8, !dbg !13450
  %167 = bitcast %"struct.laya::Check"* %ref.tmp203 to i8*, !dbg !13451
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %167) #285, !dbg !13451
  %call208 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13452
  br i1 %call208, label %if.end210, label %if.then209, !dbg !13454

if.then209:                                       ; preds = %if.end202
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup241, !dbg !13455

if.end210:                                        ; preds = %if.end202
  %168 = bitcast %"struct.laya::Check"* %ref.tmp211 to i8*, !dbg !13456
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %168) #285, !dbg !13456
  %rt212 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13457
  %169 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt212, align 8, !dbg !13457
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp211, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %169, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %normalized146), !dbg !13456
  %170 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp211, align 8, !dbg !13458
  store %"struct.laya::Check" %170, %"struct.laya::Check"* %agg.result, align 8, !dbg !13458
  %171 = bitcast %"struct.laya::Check"* %ref.tmp211 to i8*, !dbg !13459
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %171) #285, !dbg !13459
  %call213 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13460
  br i1 %call213, label %if.end215, label %if.then214, !dbg !13462

if.then214:                                       ; preds = %if.end210
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup241, !dbg !13463

if.end215:                                        ; preds = %if.end210
  %172 = bitcast %"struct.laya::full::FullOwnerSpec"* %relu to i8*, !dbg !13464
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %172) #285, !dbg !13464
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %relu, metadata !13465, metadata !DIExpression()), !dbg !13466
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %relu) #285, !dbg !13466
  %173 = bitcast %"struct.laya::Check"* %ref.tmp216 to i8*, !dbg !13467
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %173) #285, !dbg !13467
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9transformENS_2OpERKNS0_13FullOwnerSpecEttRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp216, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 97, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc1, i16 zeroext 4096, i16 zeroext -1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %relu), !dbg !13467
  %174 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp216, align 8, !dbg !13468
  store %"struct.laya::Check" %174, %"struct.laya::Check"* %agg.result, align 8, !dbg !13468
  %175 = bitcast %"struct.laya::Check"* %ref.tmp216 to i8*, !dbg !13469
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %175) #285, !dbg !13469
  %call217 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13470
  br i1 %call217, label %if.end219, label %if.then218, !dbg !13472

if.then218:                                       ; preds = %if.end215
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup240, !dbg !13473

if.end219:                                        ; preds = %if.end215
  %176 = bitcast %"struct.laya::full::FullOwnerSpec"* %fc2 to i8*, !dbg !13474
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %176) #285, !dbg !13474
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %fc2, metadata !13475, metadata !DIExpression()), !dbg !13476
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc2) #285, !dbg !13476
  %177 = bitcast %"struct.laya::Check"* %ref.tmp220 to i8*, !dbg !13477
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %177) #285, !dbg !13477
  %family222 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp221, i32 0, i32 0, !dbg !13478
  store i8 8, i8* %family222, align 1, !dbg !13478
  %layer223 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp221, i32 0, i32 1, !dbg !13478
  %178 = load i8, i8* %layer140, align 1, !dbg !13479
  store i8 %178, i8* %layer223, align 1, !dbg !13478
  %179 = load i8, i8* %layer140, align 1, !dbg !13480
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp224, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 3, i8 zeroext 0, i8 zeroext 0), !dbg !13481
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp220, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 53, %"struct.laya::WeightKey"* byval align 1 %agg.tmp221, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %relu, i8 zeroext 4, i8 zeroext %179, %"struct.laya::BufferRef"* byval align 4 %agg.tmp224, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc2, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13477
  %180 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp220, align 8, !dbg !13482
  store %"struct.laya::Check" %180, %"struct.laya::Check"* %agg.result, align 8, !dbg !13482
  %181 = bitcast %"struct.laya::Check"* %ref.tmp220 to i8*, !dbg !13483
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %181) #285, !dbg !13483
  %call225 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13484
  br i1 %call225, label %if.end227, label %if.then226, !dbg !13486

if.then226:                                       ; preds = %if.end219
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup239, !dbg !13487

if.end227:                                        ; preds = %if.end219
  %182 = bitcast %"struct.laya::Check"* %ref.tmp228 to i8*, !dbg !13488
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %182) #285, !dbg !13488
  %rt229 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13489
  %183 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt229, align 8, !dbg !13489
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp228, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %183, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %relu), !dbg !13488
  %184 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp228, align 8, !dbg !13490
  store %"struct.laya::Check" %184, %"struct.laya::Check"* %agg.result, align 8, !dbg !13490
  %185 = bitcast %"struct.laya::Check"* %ref.tmp228 to i8*, !dbg !13491
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %185) #285, !dbg !13491
  %call230 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13492
  br i1 %call230, label %if.end232, label %if.then231, !dbg !13494

if.then231:                                       ; preds = %if.end227
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup239, !dbg !13495

if.end232:                                        ; preds = %if.end227
  %186 = bitcast %"struct.laya::Check"* %ref.tmp233 to i8*, !dbg !13496
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %186) #285, !dbg !13496
  %187 = load i8, i8* %layer140, align 1, !dbg !13497
  call void @_ZN4laya4full12_GLOBAL__N_110Controller8residualEhhRKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp233, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 4, i8 zeroext %187, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %fc2, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13496
  %188 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp233, align 8, !dbg !13498
  store %"struct.laya::Check" %188, %"struct.laya::Check"* %agg.result, align 8, !dbg !13498
  %189 = bitcast %"struct.laya::Check"* %ref.tmp233 to i8*, !dbg !13499
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %189) #285, !dbg !13499
  %call234 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13500
  br i1 %call234, label %if.end236, label %if.then235, !dbg !13502

if.then235:                                       ; preds = %if.end232
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup239, !dbg !13503

if.end236:                                        ; preds = %if.end232
  %rt237 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13504
  %190 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt237, align 8, !dbg !13504
  %decision_layers_completed = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %190, i32 0, i32 30, !dbg !13505
  %191 = load i8, i8* %decision_layers_completed, align 1, !dbg !13506
  %inc238 = add i8 %191, 1, !dbg !13506
  store i8 %inc238, i8* %decision_layers_completed, align 1, !dbg !13506
  %192 = load i8, i8* %layer140, align 1, !dbg !13507
  call void @_ZN4laya4full12_GLOBAL__N_110Controller15checkpoint_nameEPKchRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.3, i64 0, i64 0), i8 zeroext %192, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden), !dbg !13508
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !13509
  br label %cleanup239, !dbg !13509

cleanup239:                                       ; preds = %if.end236, %if.then235, %if.then231, %if.then226
  %193 = bitcast %"struct.laya::full::FullOwnerSpec"* %fc2 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %193) #285, !dbg !13509
  br label %cleanup240

cleanup240:                                       ; preds = %cleanup239, %if.then218
  %194 = bitcast %"struct.laya::full::FullOwnerSpec"* %relu to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %194) #285, !dbg !13509
  br label %cleanup241

cleanup241:                                       ; preds = %cleanup240, %if.then214, %if.then209
  %195 = bitcast %"struct.laya::full::FullOwnerSpec"* %fc1 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %195) #285, !dbg !13509
  br label %cleanup242

cleanup242:                                       ; preds = %cleanup241, %if.then201, %if.then196, %if.then192, %if.then187
  %196 = bitcast %"struct.laya::full::FullOwnerSpec"* %projected180 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %196) #285, !dbg !13509
  br label %cleanup243

cleanup243:                                       ; preds = %cleanup242, %if.then178
  %197 = bitcast %"struct.laya::full::FullOwnerSpec"* %attended175 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %197) #285, !dbg !13509
  br label %cleanup244

cleanup244:                                       ; preds = %cleanup243, %if.then173, %if.then168
  %198 = bitcast %"struct.laya::full::FullOwnerSpec"* %qkv_primary160 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %198) #285, !dbg !13509
  %199 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %qkv152 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %199) #285, !dbg !13509
  br label %cleanup246

cleanup246:                                       ; preds = %cleanup244, %if.then150
  %200 = bitcast %"struct.laya::full::FullOwnerSpec"* %normalized146 to i8*, !dbg !13509
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %200) #285, !dbg !13509
  %cleanup.dest247 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest247, label %cleanup251 [
    i32 0, label %cleanup.cont248
  ]

cleanup.cont248:                                  ; preds = %cleanup246
  br label %for.inc249, !dbg !13510

for.inc249:                                       ; preds = %cleanup.cont248
  %201 = load i8, i8* %layer140, align 1, !dbg !13511
  %inc250 = add i8 %201, 1, !dbg !13511
  store i8 %inc250, i8* %layer140, align 1, !dbg !13511
  br label %for.cond141, !dbg !13512, !llvm.loop !13513

cleanup251:                                       ; preds = %cleanup246, %for.cond.cleanup144
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %layer140) #285, !dbg !13512
  %cleanup.dest252 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest252, label %cleanup361 [
    i32 7, label %for.end253
  ]

for.end253:                                       ; preds = %cleanup251
  %202 = bitcast %"struct.laya::full::FullOwnerSpec"* %markers to i8*, !dbg !13516
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %202) #285, !dbg !13516
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %markers, metadata !13517, metadata !DIExpression()), !dbg !13518
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %markers) #285, !dbg !13518
  %203 = bitcast %"struct.laya::Check"* %ref.tmp254 to i8*, !dbg !13519
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %203) #285, !dbg !13519
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6gatherERKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp254, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %markers), !dbg !13519
  %204 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp254, align 8, !dbg !13520
  store %"struct.laya::Check" %204, %"struct.laya::Check"* %agg.result, align 8, !dbg !13520
  %205 = bitcast %"struct.laya::Check"* %ref.tmp254 to i8*, !dbg !13521
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %205) #285, !dbg !13521
  %call255 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13522
  br i1 %call255, label %if.end257, label %if.then256, !dbg !13524

if.then256:                                       ; preds = %for.end253
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup360, !dbg !13525

if.end257:                                        ; preds = %for.end253
  %206 = bitcast %"struct.laya::full::FullOwnerSpec"* %marker_norm to i8*, !dbg !13526
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %206) #285, !dbg !13526
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %marker_norm, metadata !13527, metadata !DIExpression()), !dbg !13528
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %marker_norm) #285, !dbg !13528
  %207 = bitcast %"struct.laya::Check"* %ref.tmp258 to i8*, !dbg !13529
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %207) #285, !dbg !13529
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp259, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 10, i8 zeroext 0, i8 zeroext 0), !dbg !13530
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4normENS_2OpERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhhRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp258, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 20, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %markers, i8 zeroext 5, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp259, i8 zeroext 0, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %marker_norm), !dbg !13529
  %208 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp258, align 8, !dbg !13531
  store %"struct.laya::Check" %208, %"struct.laya::Check"* %agg.result, align 8, !dbg !13531
  %209 = bitcast %"struct.laya::Check"* %ref.tmp258 to i8*, !dbg !13532
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %209) #285, !dbg !13532
  %call260 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13533
  br i1 %call260, label %if.end262, label %if.then261, !dbg !13535

if.then261:                                       ; preds = %if.end257
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup359, !dbg !13536

if.end262:                                        ; preds = %if.end257
  %210 = bitcast %"struct.laya::Check"* %ref.tmp263 to i8*, !dbg !13537
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %210) #285, !dbg !13537
  %rt264 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13538
  %211 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt264, align 8, !dbg !13538
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp263, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %211, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %markers), !dbg !13537
  %212 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp263, align 8, !dbg !13539
  store %"struct.laya::Check" %212, %"struct.laya::Check"* %agg.result, align 8, !dbg !13539
  %213 = bitcast %"struct.laya::Check"* %ref.tmp263 to i8*, !dbg !13540
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %213) #285, !dbg !13540
  %call265 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13541
  br i1 %call265, label %if.end267, label %if.then266, !dbg !13543

if.then266:                                       ; preds = %if.end262
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup359, !dbg !13544

if.end267:                                        ; preds = %if.end262
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.4, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %marker_norm), !dbg !13545
  %214 = bitcast %"struct.laya::full::FullOwnerSpec"* %scorer_baked to i8*, !dbg !13546
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %214) #285, !dbg !13546
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %scorer_baked, metadata !13547, metadata !DIExpression()), !dbg !13548
  %215 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %marker_norm, align 4, !dbg !13549
  store %"struct.laya::full::FullOwnerSpec" %215, %"struct.laya::full::FullOwnerSpec"* %scorer_baked, align 4, !dbg !13549
  %ref268 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %scorer_baked, i32 0, i32 0, !dbg !13550
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref268, i32 0, i32 2, !dbg !13551
  %216 = load i32, i32* %epoch, align 4, !dbg !13552
  %add = add i32 %216, 1, !dbg !13552
  store i32 %add, i32* %epoch, align 4, !dbg !13552
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 5, i8 zeroext 54), !dbg !13553
  %217 = bitcast %"struct.laya::Check"* %ref.tmp269 to i8*, !dbg !13554
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %217) #285, !dbg !13554
  %rt270 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13555
  %218 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt270, align 8, !dbg !13555
  call void @_ZN4laya4full24full_begin_inplace_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecES5_(%"struct.laya::Check"* sret align 8 %ref.tmp269, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %218, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %marker_norm, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_baked), !dbg !13554
  %219 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp269, align 8, !dbg !13556
  store %"struct.laya::Check" %219, %"struct.laya::Check"* %agg.result, align 8, !dbg !13556
  %220 = bitcast %"struct.laya::Check"* %ref.tmp269 to i8*, !dbg !13557
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %220) #285, !dbg !13557
  %call271 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13558
  br i1 %call271, label %if.end273, label %if.then272, !dbg !13560

if.then272:                                       ; preds = %if.end267
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup358, !dbg !13561

if.end273:                                        ; preds = %if.end267
  %221 = bitcast %"struct.laya::Check"* %ref.tmp274 to i8*, !dbg !13562
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %221) #285, !dbg !13562
  %family276 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp275, i32 0, i32 0, !dbg !13563
  store i8 9, i8* %family276, align 1, !dbg !13563
  %layer277 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp275, i32 0, i32 1, !dbg !13563
  store i8 -1, i8* %layer277, align 1, !dbg !13563
  %ref279 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %scorer_baked, i32 0, i32 0, !dbg !13564
  %222 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref279, align 4, !dbg !13565
  store %"struct.laya::BufferRef" %222, %"struct.laya::BufferRef"* %agg.tmp278, align 4, !dbg !13565
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp274, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 54, %"struct.laya::WeightKey"* byval align 1 %agg.tmp275, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %marker_norm, i8 zeroext 5, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp278, i8 zeroext 0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_baked, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13562
  %223 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp274, align 8, !dbg !13566
  store %"struct.laya::Check" %223, %"struct.laya::Check"* %agg.result, align 8, !dbg !13566
  %224 = bitcast %"struct.laya::Check"* %ref.tmp274 to i8*, !dbg !13567
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %224) #285, !dbg !13567
  %call280 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13568
  br i1 %call280, label %if.then281, label %if.end284, !dbg !13570

if.then281:                                       ; preds = %if.end273
  %225 = bitcast %"struct.laya::Check"* %ref.tmp282 to i8*, !dbg !13571
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %225) #285, !dbg !13571
  %rt283 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13572
  %226 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt283, align 8, !dbg !13572
  call void @_ZN4laya4full25full_commit_inplace_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp282, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %226, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_baked), !dbg !13571
  %227 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp282, align 8, !dbg !13573
  store %"struct.laya::Check" %227, %"struct.laya::Check"* %agg.result, align 8, !dbg !13573
  %228 = bitcast %"struct.laya::Check"* %ref.tmp282 to i8*, !dbg !13574
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %228) #285, !dbg !13574
  br label %if.end284, !dbg !13574

if.end284:                                        ; preds = %if.then281, %if.end273
  %call285 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13575
  br i1 %call285, label %if.end290, label %if.then286, !dbg !13577

if.then286:                                       ; preds = %if.end284
  %rt287 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !13578
  %229 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt287, align 8, !dbg !13578
  %ref289 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %scorer_baked, i32 0, i32 0, !dbg !13580
  %230 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref289, align 4, !dbg !13581
  store %"struct.laya::BufferRef" %230, %"struct.laya::BufferRef"* %agg.tmp288, align 4, !dbg !13581
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %scorer_baked, i32 0, i32 1, !dbg !13582
  %231 = load i8, i8* %region, align 4, !dbg !13582
  %232 = bitcast %"struct.laya::Check"* %tmp to i8*, !dbg !13583
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %232) #285, !dbg !13583
  call void @_ZN4laya4full21full_invalidate_ownerERNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::Check"* sret align 8 %tmp, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %229, %"struct.laya::BufferRef"* byval align 4 %agg.tmp288, i8 zeroext %231), !dbg !13583
  %233 = bitcast %"struct.laya::Check"* %tmp to i8*, !dbg !13583
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %233) #285, !dbg !13583
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup358, !dbg !13584

if.end290:                                        ; preds = %if.end284
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.5, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_baked), !dbg !13585
  %234 = bitcast %"struct.laya::full::FullTensorDescriptor"* %scorer_bias to i8*, !dbg !13586
  call void @llvm.lifetime.start.p0i8(i64 116, i8* %234) #285, !dbg !13586
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullTensorDescriptor"* %scorer_bias, metadata !13587, metadata !DIExpression()), !dbg !13588
  call void @_ZN4laya4full20FullTensorDescriptorC2Ev(%"struct.laya::full::FullTensorDescriptor"* nonnull align 4 dereferenceable(116) %scorer_bias) #285, !dbg !13588
  %235 = bitcast i16* %scorer_bias_id to i8*, !dbg !13589
  call void @llvm.lifetime.start.p0i8(i64 2, i8* %235) #285, !dbg !13589
  call void @llvm.dbg.declare(metadata i16* %scorer_bias_id, metadata !13590, metadata !DIExpression()), !dbg !13591
  store i16 -1, i16* %scorer_bias_id, align 2, !dbg !13591
  %236 = bitcast %"struct.laya::Check"* %ref.tmp291 to i8*, !dbg !13592
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %236) #285, !dbg !13592
  call void @_ZN4laya4full26full_lookup_tensor_indexedEPKcRNS0_20FullTensorDescriptorERt(%"struct.laya::Check"* sret align 8 %ref.tmp291, i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.6, i64 0, i64 0), %"struct.laya::full::FullTensorDescriptor"* nonnull align 4 dereferenceable(116) %scorer_bias, i16* nonnull align 2 dereferenceable(2) %scorer_bias_id), !dbg !13592
  %237 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp291, align 8, !dbg !13593
  store %"struct.laya::Check" %237, %"struct.laya::Check"* %agg.result, align 8, !dbg !13593
  %238 = bitcast %"struct.laya::Check"* %ref.tmp291 to i8*, !dbg !13594
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %238) #285, !dbg !13594
  %call292 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13595
  br i1 %call292, label %if.end294, label %if.then293, !dbg !13597

if.then293:                                       ; preds = %if.end290
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup356, !dbg !13598

if.end294:                                        ; preds = %if.end290
  %239 = bitcast %"struct.laya::full::FullOwnerSpec"* %scorer_hidden to i8*, !dbg !13599
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %239) #285, !dbg !13599
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %scorer_hidden, metadata !13600, metadata !DIExpression()), !dbg !13601
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_hidden) #285, !dbg !13601
  %240 = bitcast %"struct.laya::Check"* %ref.tmp295 to i8*, !dbg !13602
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %240) #285, !dbg !13602
  %241 = load i16, i16* %scorer_bias_id, align 2, !dbg !13603
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9transformENS_2OpERKNS0_13FullOwnerSpecEttRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp295, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 100, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_baked, i16 zeroext 1024, i16 zeroext %241, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_hidden), !dbg !13602
  %242 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp295, align 8, !dbg !13604
  store %"struct.laya::Check" %242, %"struct.laya::Check"* %agg.result, align 8, !dbg !13604
  %243 = bitcast %"struct.laya::Check"* %ref.tmp295 to i8*, !dbg !13605
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %243) #285, !dbg !13605
  %call296 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13606
  br i1 %call296, label %if.end298, label %if.then297, !dbg !13608

if.then297:                                       ; preds = %if.end294
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup355, !dbg !13609

if.end298:                                        ; preds = %if.end294
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.7, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_hidden), !dbg !13610
  %244 = bitcast %"struct.laya::full::FullOwnerSpec"* %raw to i8*, !dbg !13611
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %244) #285, !dbg !13611
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %raw, metadata !13612, metadata !DIExpression()), !dbg !13613
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %raw) #285, !dbg !13613
  %245 = bitcast %"struct.laya::Check"* %ref.tmp299 to i8*, !dbg !13614
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %245) #285, !dbg !13614
  %family301 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp300, i32 0, i32 0, !dbg !13615
  store i8 10, i8* %family301, align 1, !dbg !13615
  %layer302 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp300, i32 0, i32 1, !dbg !13615
  store i8 -1, i8* %layer302, align 1, !dbg !13615
  %region303 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %scorer_hidden, i32 0, i32 1, !dbg !13616
  %246 = load i8, i8* %region303, align 4, !dbg !13616
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9fp_linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhhttRS5_(%"struct.laya::Check"* sret align 8 %ref.tmp299, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 83, %"struct.laya::WeightKey"* byval align 1 %agg.tmp300, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %scorer_hidden, i8 zeroext 5, i8 zeroext %246, i8 zeroext 7, i16 zeroext 1024, i16 zeroext 1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %raw), !dbg !13614
  %247 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp299, align 8, !dbg !13617
  store %"struct.laya::Check" %247, %"struct.laya::Check"* %agg.result, align 8, !dbg !13617
  %248 = bitcast %"struct.laya::Check"* %ref.tmp299 to i8*, !dbg !13618
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %248) #285, !dbg !13618
  %call304 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13619
  br i1 %call304, label %if.end306, label %if.then305, !dbg !13621

if.then305:                                       ; preds = %if.end298
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup354, !dbg !13622

if.end306:                                        ; preds = %if.end298
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.8, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %raw), !dbg !13623
  %249 = bitcast %"struct.laya::Check"* %ref.tmp307 to i8*, !dbg !13624
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %249) #285, !dbg !13624
  %250 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %candidate.addr, align 8, !dbg !13625
  call void @_ZN4laya4full12_GLOBAL__N_110Controller16candidate_maskedERKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp307, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %raw, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %250), !dbg !13624
  %251 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp307, align 8, !dbg !13626
  store %"struct.laya::Check" %251, %"struct.laya::Check"* %agg.result, align 8, !dbg !13626
  %252 = bitcast %"struct.laya::Check"* %ref.tmp307 to i8*, !dbg !13627
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %252) #285, !dbg !13627
  %call308 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13628
  br i1 %call308, label %if.end310, label %if.then309, !dbg !13630

if.then309:                                       ; preds = %if.end306
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup354, !dbg !13631

if.end310:                                        ; preds = %if.end306
  %253 = bitcast %"struct.laya::full::FullOwnerSpec"* %prob to i8*, !dbg !13632
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %253) #285, !dbg !13632
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %prob, metadata !13633, metadata !DIExpression()), !dbg !13634
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %prob) #285, !dbg !13634
  %254 = bitcast %"struct.laya::Check"* %ref.tmp311 to i8*, !dbg !13635
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %254) #285, !dbg !13635
  %255 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %candidate.addr, align 8, !dbg !13636
  call void @_ZN4laya4full12_GLOBAL__N_110Controller21candidate_probabilityERKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp311, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %255, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %prob), !dbg !13635
  %256 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp311, align 8, !dbg !13637
  store %"struct.laya::Check" %256, %"struct.laya::Check"* %agg.result, align 8, !dbg !13637
  %257 = bitcast %"struct.laya::Check"* %ref.tmp311 to i8*, !dbg !13638
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %257) #285, !dbg !13638
  %call312 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13639
  br i1 %call312, label %if.end314, label %if.then313, !dbg !13641

if.then313:                                       ; preds = %if.end310
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup353, !dbg !13642

if.end314:                                        ; preds = %if.end310
  %258 = bitcast %"struct.laya::full::FullOwnerSpec"* %stats to i8*, !dbg !13643
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %258) #285, !dbg !13643
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %stats, metadata !13644, metadata !DIExpression()), !dbg !13645
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %stats) #285, !dbg !13645
  %259 = bitcast %"struct.laya::Check"* %ref.tmp315 to i8*, !dbg !13646
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %259) #285, !dbg !13646
  call void @_ZN4laya4full12_GLOBAL__N_110Controller20candidate_statisticsERKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* sret align 8 %ref.tmp315, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %prob, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %stats), !dbg !13646
  %260 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp315, align 8, !dbg !13647
  store %"struct.laya::Check" %260, %"struct.laya::Check"* %agg.result, align 8, !dbg !13647
  %261 = bitcast %"struct.laya::Check"* %ref.tmp315 to i8*, !dbg !13648
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %261) #285, !dbg !13648
  %call316 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13649
  br i1 %call316, label %if.end318, label %if.then317, !dbg !13651

if.then317:                                       ; preds = %if.end314
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup352, !dbg !13652

if.end318:                                        ; preds = %if.end314
  %262 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_input to i8*, !dbg !13653
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %262) #285, !dbg !13653
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %act_input, metadata !13654, metadata !DIExpression()), !dbg !13655
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_input) #285, !dbg !13655
  %263 = bitcast %"struct.laya::Check"* %ref.tmp319 to i8*, !dbg !13656
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %263) #285, !dbg !13656
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10act_concatERKNS0_13FullOwnerSpecES5_RS3_(%"struct.laya::Check"* sret align 8 %ref.tmp319, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %stats, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_input), !dbg !13656
  %264 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp319, align 8, !dbg !13657
  store %"struct.laya::Check" %264, %"struct.laya::Check"* %agg.result, align 8, !dbg !13657
  %265 = bitcast %"struct.laya::Check"* %ref.tmp319 to i8*, !dbg !13658
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %265) #285, !dbg !13658
  %call320 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13659
  br i1 %call320, label %if.end322, label %if.then321, !dbg !13661

if.then321:                                       ; preds = %if.end318
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup351, !dbg !13662

if.end322:                                        ; preds = %if.end318
  %266 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_dot to i8*, !dbg !13663
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %266) #285, !dbg !13663
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %act_dot, metadata !13664, metadata !DIExpression()), !dbg !13665
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_dot) #285, !dbg !13665
  %267 = bitcast %"struct.laya::Check"* %ref.tmp323 to i8*, !dbg !13666
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %267) #285, !dbg !13666
  %family325 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp324, i32 0, i32 0, !dbg !13667
  store i8 11, i8* %family325, align 1, !dbg !13667
  %layer326 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp324, i32 0, i32 1, !dbg !13667
  store i8 -1, i8* %layer326, align 1, !dbg !13667
  %region327 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %act_input, i32 0, i32 1, !dbg !13668
  %268 = load i8, i8* %region327, align 4, !dbg !13668
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9fp_linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhhttRS5_(%"struct.laya::Check"* sret align 8 %ref.tmp323, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 84, %"struct.laya::WeightKey"* byval align 1 %agg.tmp324, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_input, i8 zeroext 6, i8 zeroext %268, i8 zeroext 2, i16 zeroext 1028, i16 zeroext 256, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_dot), !dbg !13666
  %269 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp323, align 8, !dbg !13669
  store %"struct.laya::Check" %269, %"struct.laya::Check"* %agg.result, align 8, !dbg !13669
  %270 = bitcast %"struct.laya::Check"* %ref.tmp323 to i8*, !dbg !13670
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %270) #285, !dbg !13670
  %call328 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13671
  br i1 %call328, label %if.end330, label %if.then329, !dbg !13673

if.then329:                                       ; preds = %if.end322
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup350, !dbg !13674

if.end330:                                        ; preds = %if.end322
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.9, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_dot), !dbg !13675
  %271 = bitcast %"struct.laya::full::FullTensorDescriptor"* %act_bias to i8*, !dbg !13676
  call void @llvm.lifetime.start.p0i8(i64 116, i8* %271) #285, !dbg !13676
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullTensorDescriptor"* %act_bias, metadata !13677, metadata !DIExpression()), !dbg !13678
  call void @_ZN4laya4full20FullTensorDescriptorC2Ev(%"struct.laya::full::FullTensorDescriptor"* nonnull align 4 dereferenceable(116) %act_bias) #285, !dbg !13678
  %272 = bitcast i16* %act_bias_id to i8*, !dbg !13679
  call void @llvm.lifetime.start.p0i8(i64 2, i8* %272) #285, !dbg !13679
  call void @llvm.dbg.declare(metadata i16* %act_bias_id, metadata !13680, metadata !DIExpression()), !dbg !13681
  store i16 -1, i16* %act_bias_id, align 2, !dbg !13681
  %273 = bitcast %"struct.laya::Check"* %ref.tmp331 to i8*, !dbg !13682
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %273) #285, !dbg !13682
  call void @_ZN4laya4full26full_lookup_tensor_indexedEPKcRNS0_20FullTensorDescriptorERt(%"struct.laya::Check"* sret align 8 %ref.tmp331, i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.10, i64 0, i64 0), %"struct.laya::full::FullTensorDescriptor"* nonnull align 4 dereferenceable(116) %act_bias, i16* nonnull align 2 dereferenceable(2) %act_bias_id), !dbg !13682
  %274 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp331, align 8, !dbg !13683
  store %"struct.laya::Check" %274, %"struct.laya::Check"* %agg.result, align 8, !dbg !13683
  %275 = bitcast %"struct.laya::Check"* %ref.tmp331 to i8*, !dbg !13684
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %275) #285, !dbg !13684
  %call332 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13685
  br i1 %call332, label %if.end334, label %if.then333, !dbg !13687

if.then333:                                       ; preds = %if.end330
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup348, !dbg !13688

if.end334:                                        ; preds = %if.end330
  %276 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_hidden to i8*, !dbg !13689
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %276) #285, !dbg !13689
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %act_hidden, metadata !13690, metadata !DIExpression()), !dbg !13691
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_hidden) #285, !dbg !13691
  %277 = bitcast %"struct.laya::Check"* %ref.tmp335 to i8*, !dbg !13692
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %277) #285, !dbg !13692
  %278 = load i16, i16* %act_bias_id, align 2, !dbg !13693
  call void @_ZN4laya4full12_GLOBAL__N_110Controller9transformENS_2OpERKNS0_13FullOwnerSpecEttRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp335, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 101, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_dot, i16 zeroext 256, i16 zeroext %278, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_hidden), !dbg !13692
  %279 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp335, align 8, !dbg !13694
  store %"struct.laya::Check" %279, %"struct.laya::Check"* %agg.result, align 8, !dbg !13694
  %280 = bitcast %"struct.laya::Check"* %ref.tmp335 to i8*, !dbg !13695
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %280) #285, !dbg !13695
  %call336 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13696
  br i1 %call336, label %if.end338, label %if.then337, !dbg !13698

if.then337:                                       ; preds = %if.end334
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup347, !dbg !13699

if.end338:                                        ; preds = %if.end334
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.11, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_hidden), !dbg !13700
  %281 = bitcast %"struct.laya::Check"* %ref.tmp339 to i8*, !dbg !13701
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %281) #285, !dbg !13701
  %family341 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp340, i32 0, i32 0, !dbg !13702
  store i8 12, i8* %family341, align 1, !dbg !13702
  %layer342 = getelementptr inbounds %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %agg.tmp340, i32 0, i32 1, !dbg !13702
  store i8 -1, i8* %layer342, align 1, !dbg !13702
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp343, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 10, i8 zeroext 0, i8 zeroext 4), !dbg !13703
  %282 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %act.addr, align 8, !dbg !13704
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* sret align 8 %ref.tmp339, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 55, %"struct.laya::WeightKey"* byval align 1 %agg.tmp340, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %act_hidden, i8 zeroext 6, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp343, i8 zeroext 4, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %282, %"struct.laya::full::FullOwnerSpec"* null), !dbg !13701
  %283 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp339, align 8, !dbg !13705
  store %"struct.laya::Check" %283, %"struct.laya::Check"* %agg.result, align 8, !dbg !13705
  %284 = bitcast %"struct.laya::Check"* %ref.tmp339 to i8*, !dbg !13706
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %284) #285, !dbg !13706
  %call344 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !13707
  br i1 %call344, label %if.then345, label %if.end346, !dbg !13709

if.then345:                                       ; preds = %if.end338
  %285 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %act.addr, align 8, !dbg !13710
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.12, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %285), !dbg !13711
  br label %if.end346, !dbg !13711

if.end346:                                        ; preds = %if.then345, %if.end338
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup347, !dbg !13712

cleanup347:                                       ; preds = %if.end346, %if.then337
  %286 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_hidden to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %286) #285, !dbg !13713
  br label %cleanup348

cleanup348:                                       ; preds = %cleanup347, %if.then333
  %287 = bitcast i16* %act_bias_id to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 2, i8* %287) #285, !dbg !13713
  %288 = bitcast %"struct.laya::full::FullTensorDescriptor"* %act_bias to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 116, i8* %288) #285, !dbg !13713
  br label %cleanup350

cleanup350:                                       ; preds = %cleanup348, %if.then329
  %289 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_dot to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %289) #285, !dbg !13713
  br label %cleanup351

cleanup351:                                       ; preds = %cleanup350, %if.then321
  %290 = bitcast %"struct.laya::full::FullOwnerSpec"* %act_input to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %290) #285, !dbg !13713
  br label %cleanup352

cleanup352:                                       ; preds = %cleanup351, %if.then317
  %291 = bitcast %"struct.laya::full::FullOwnerSpec"* %stats to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %291) #285, !dbg !13713
  br label %cleanup353

cleanup353:                                       ; preds = %cleanup352, %if.then313
  %292 = bitcast %"struct.laya::full::FullOwnerSpec"* %prob to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %292) #285, !dbg !13713
  br label %cleanup354

cleanup354:                                       ; preds = %cleanup353, %if.then309, %if.then305
  %293 = bitcast %"struct.laya::full::FullOwnerSpec"* %raw to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %293) #285, !dbg !13713
  br label %cleanup355

cleanup355:                                       ; preds = %cleanup354, %if.then297
  %294 = bitcast %"struct.laya::full::FullOwnerSpec"* %scorer_hidden to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %294) #285, !dbg !13713
  br label %cleanup356

cleanup356:                                       ; preds = %cleanup355, %if.then293
  %295 = bitcast i16* %scorer_bias_id to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 2, i8* %295) #285, !dbg !13713
  %296 = bitcast %"struct.laya::full::FullTensorDescriptor"* %scorer_bias to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 116, i8* %296) #285, !dbg !13713
  br label %cleanup358

cleanup358:                                       ; preds = %cleanup356, %if.then286, %if.then272
  %297 = bitcast %"struct.laya::full::FullOwnerSpec"* %scorer_baked to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %297) #285, !dbg !13713
  br label %cleanup359

cleanup359:                                       ; preds = %cleanup358, %if.then266, %if.then261
  %298 = bitcast %"struct.laya::full::FullOwnerSpec"* %marker_norm to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %298) #285, !dbg !13713
  br label %cleanup360

cleanup360:                                       ; preds = %cleanup359, %if.then256
  %299 = bitcast %"struct.laya::full::FullOwnerSpec"* %markers to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %299) #285, !dbg !13713
  br label %cleanup361

cleanup361:                                       ; preds = %cleanup360, %cleanup251, %if.then138, %if.then134, %if.then129
  %300 = bitcast %"struct.laya::full::FullOwnerSpec"* %final_norm to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %300) #285, !dbg !13713
  br label %cleanup362

cleanup362:                                       ; preds = %cleanup361, %if.then119, %cleanup115, %if.then12, %if.then8
  %301 = bitcast %"struct.laya::full::FullOwnerSpec"* %normed to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %301) #285, !dbg !13713
  br label %cleanup363

cleanup363:                                       ; preds = %cleanup362, %if.then3, %if.then
  %302 = bitcast %"struct.laya::full::FullOwnerSpec"* %hidden to i8*, !dbg !13713
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %302) #285, !dbg !13713
  ret void, !dbg !13713
}
