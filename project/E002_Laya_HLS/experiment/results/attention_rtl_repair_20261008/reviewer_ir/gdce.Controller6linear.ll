define internal void @_ZN4laya4full12_GLOBAL__N_110Controller6linearENS_2OpENS_9WeightKeyERKNS0_13FullOwnerSpecEhhNS_9BufferRefEhRS5_PS5_(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this, i8 zeroext %op, %"struct.laya::WeightKey"* byval align 1 %key, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %source, i8 zeroext %stage, i8 zeroext %layer, %"struct.laya::BufferRef"* byval align 4 %dst_ref, i8 zeroext %dst_region, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %output, %"struct.laya::full::FullOwnerSpec"* %qkv_pair) #60 align 2 !dbg !17211 !type !17212 {
entry:
  %this.addr = alloca %"struct.laya::full::(anonymous namespace)::Controller"*, align 8
  %op.addr = alloca i8, align 1
  %source.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %stage.addr = alloca i8, align 1
  %layer.addr = alloca i8, align 1
  %dst_region.addr = alloca i8, align 1
  %output.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %qkv_pair.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %descriptor = alloca %"struct.laya::full::FullWeightDescriptor", align 4
  %c = alloca %"struct.laya::Check", align 8
  %agg.tmp = alloca %"struct.laya::WeightKey", align 1
  %cleanup.dest.slot = alloca i32, align 4
  %qkv = alloca i1, align 1
  %ref.tmp = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %agg.tmp2 = alloca %"struct.laya::BufferRef", align 4
  %pair = alloca [2 x %"struct.laya::full::FullOwnerSpec"], align 4
  %scorer_lease = alloca i1, align 1
  %ref.tmp19 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp21 = alloca %"struct.laya::Check", align 8
  %ref.tmp23 = alloca %"struct.laya::Check", align 8
  %rows = alloca i32, align 4
  %b = alloca i32, align 4
  %row = alloca i32, align 4
  %count = alloca i8, align 1
  %quant = alloca %"struct.laya::QuantTask", align 4
  %ref.tmp47 = alloca %"struct.laya::TaskContext", align 4
  %ref.tmp52 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp54 = alloca %"struct.laya::Check", align 8
  %ref.tmp58 = alloca %"struct.laya::Check", align 8
  %t = alloca %"struct.laya::LinearTask", align 4
  %ref.tmp66 = alloca %"struct.laya::TaskContext", align 4
  %ref.tmp73 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp81 = alloca %"struct.laya::Check", align 8
  %ref.tmp97 = alloca %"struct.laya::Check", align 8
  %ref.tmp103 = alloca %"struct.laya::Check", align 8
  store %"struct.laya::full::(anonymous namespace)::Controller"* %this, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, metadata !17214, metadata !DIExpression()), !dbg !17215
  store i8 %op, i8* %op.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %op.addr, metadata !17216, metadata !DIExpression()), !dbg !17217
  call void @llvm.dbg.declare(metadata %"struct.laya::WeightKey"* %key, metadata !17218, metadata !DIExpression()), !dbg !17219
  store %"struct.laya::full::FullOwnerSpec"* %source, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %source.addr, metadata !17220, metadata !DIExpression()), !dbg !17221
  store i8 %stage, i8* %stage.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %stage.addr, metadata !17222, metadata !DIExpression()), !dbg !17223
  store i8 %layer, i8* %layer.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %layer.addr, metadata !17224, metadata !DIExpression()), !dbg !17225
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %dst_ref, metadata !17226, metadata !DIExpression()), !dbg !17227
  store i8 %dst_region, i8* %dst_region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %dst_region.addr, metadata !17228, metadata !DIExpression()), !dbg !17229
  store %"struct.laya::full::FullOwnerSpec"* %output, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %output.addr, metadata !17230, metadata !DIExpression()), !dbg !17231
  store %"struct.laya::full::FullOwnerSpec"* %qkv_pair, %"struct.laya::full::FullOwnerSpec"** %qkv_pair.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %qkv_pair.addr, metadata !17232, metadata !DIExpression()), !dbg !17233
  %this1 = load %"struct.laya::full::(anonymous namespace)::Controller"*, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  %0 = load i8, i8* %stage.addr, align 1, !dbg !17234
  %1 = load i8, i8* %op.addr, align 1, !dbg !17235
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %0, i8 zeroext %1), !dbg !17236
  %2 = bitcast %"struct.laya::full::FullWeightDescriptor"* %descriptor to i8*, !dbg !17237
  call void @llvm.lifetime.start.p0i8(i64 160, i8* %2) #285, !dbg !17237
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullWeightDescriptor"* %descriptor, metadata !17238, metadata !DIExpression()), !dbg !17239
  call void @_ZN4laya4full20FullWeightDescriptorC2Ev(%"struct.laya::full::FullWeightDescriptor"* nonnull align 4 dereferenceable(160) %descriptor) #285, !dbg !17239
  %3 = bitcast %"struct.laya::Check"* %c to i8*, !dbg !17240
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %3) #285, !dbg !17240
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %c, metadata !17241, metadata !DIExpression()), !dbg !17242
  %4 = load %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %key, align 1, !dbg !17243
  store %"struct.laya::WeightKey" %4, %"struct.laya::WeightKey"* %agg.tmp, align 1, !dbg !17243
  %5 = load i8, i8* %stage.addr, align 1, !dbg !17244
  %6 = load i8, i8* %layer.addr, align 1, !dbg !17245
  call void @_ZN4laya4full12_GLOBAL__N_110Controller11load_weightENS_9WeightKeyEhhRNS0_20FullWeightDescriptorE(%"struct.laya::Check"* sret align 8 %c, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::WeightKey"* byval align 1 %agg.tmp, i8 zeroext %5, i8 zeroext %6, %"struct.laya::full::FullWeightDescriptor"* nonnull align 4 dereferenceable(160) %descriptor), !dbg !17246
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17247
  br i1 %call, label %if.end, label %if.then, !dbg !17249

if.then:                                          ; preds = %entry
  %7 = load %"struct.laya::Check", %"struct.laya::Check"* %c, align 8, !dbg !17250
  store %"struct.laya::Check" %7, %"struct.laya::Check"* %agg.result, align 8, !dbg !17250
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup119, !dbg !17251

if.end:                                           ; preds = %entry
  %8 = load i8, i8* %stage.addr, align 1, !dbg !17252
  %9 = load i8, i8* %op.addr, align 1, !dbg !17253
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %8, i8 zeroext %9), !dbg !17254
  %10 = bitcast i1* %qkv to i8*, !dbg !17255
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %10) #285, !dbg !17255
  call void @llvm.dbg.declare(metadata i1* %qkv, metadata !17256, metadata !DIExpression()), !dbg !17257
  %11 = load i8, i8* %op.addr, align 1, !dbg !17258
  %cmp = icmp eq i8 %11, 48, !dbg !17259
  store i1 %cmp, i1* %qkv, align 1, !dbg !17257
  %12 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp to i8*, !dbg !17260
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %12) #285, !dbg !17260
  %13 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %dst_ref, align 4, !dbg !17261
  store %"struct.laya::BufferRef" %13, %"struct.laya::BufferRef"* %agg.tmp2, align 4, !dbg !17261
  %14 = load i8, i8* %dst_region.addr, align 1, !dbg !17262
  %15 = load i8, i8* %stage.addr, align 1, !dbg !17263
  %16 = load i8, i8* %layer.addr, align 1, !dbg !17264
  %17 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17265
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %17, i32 0, i32 5, !dbg !17266
  %18 = load i8, i8* %row_space, align 4, !dbg !17266
  %19 = load i1, i1* %qkv, align 1, !dbg !17267
  br i1 %19, label %cond.true, label %cond.false, !dbg !17267

cond.true:                                        ; preds = %if.end
  br label %cond.end, !dbg !17267

cond.false:                                       ; preds = %if.end
  %N = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 3, !dbg !17268
  %20 = load i16, i16* %N, align 4, !dbg !17268
  %conv = zext i16 %20 to i32, !dbg !17269
  br label %cond.end, !dbg !17267

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 64, %cond.true ], [ %conv, %cond.false ], !dbg !17267
  %conv3 = trunc i32 %cond to i16, !dbg !17267
  %21 = load i1, i1* %qkv, align 1, !dbg !17270
  br i1 %21, label %cond.true4, label %cond.false8, !dbg !17270

cond.true4:                                       ; preds = %cond.end
  %22 = load i8, i8* %stage.addr, align 1, !dbg !17271
  %conv5 = zext i8 %22 to i32, !dbg !17271
  %cmp6 = icmp eq i32 %conv5, 4, !dbg !17272
  %23 = zext i1 %cmp6 to i64, !dbg !17271
  %cond7 = select i1 %cmp6, i8 3, i8 2, !dbg !17271
  br label %cond.end9, !dbg !17270

cond.false8:                                      ; preds = %cond.end
  br label %cond.end9, !dbg !17270

cond.end9:                                        ; preds = %cond.false8, %cond.true4
  %cond10 = phi i8 [ %cond7, %cond.true4 ], [ 1, %cond.false8 ], !dbg !17270
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller6matrixENS_9BufferRefEhhhNS_8RowSpaceEtNS_7ContentE(%"struct.laya::full::FullOwnerSpec"* sret align 4 %ref.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp2, i8 zeroext %14, i8 zeroext %15, i8 zeroext %16, i8 zeroext %18, i16 zeroext %conv3, i8 zeroext %cond10), !dbg !17260
  %24 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17273
  %25 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp, align 4, !dbg !17274
  store %"struct.laya::full::FullOwnerSpec" %25, %"struct.laya::full::FullOwnerSpec"* %24, align 4, !dbg !17274
  %26 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp to i8*, !dbg !17273
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %26) #285, !dbg !17273
  %27 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair to i8*, !dbg !17275
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %27) #285, !dbg !17275
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, metadata !17276, metadata !DIExpression()), !dbg !17277
  %array.begin = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i32 0, i32 0, !dbg !17277
  br label %arrayctor.loop, !dbg !17277

arrayctor.loop:                                   ; preds = %arrayctor.loop, %cond.end9
  %indvar = phi i32 [ 0, %cond.end9 ], [ %indvarinc, %arrayctor.loop ], !dbg !17277
  %indvarinc = add i32 %indvar, 1, !dbg !17277
  %array.src = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i32 0, i32 %indvar, !dbg !17277
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %array.src) #285, !dbg !17277
  %28 = icmp eq i32 %indvar, 1, !dbg !17277
  br i1 %28, label %cond.end912, label %arrayctor.loop, !dbg !17277

cond.end912:                                      ; preds = %arrayctor.loop
  br label %cond.end911, !dbg !17277

cond.end911:                                      ; preds = %cond.end912
  %29 = bitcast i1* %scorer_lease to i8*, !dbg !17278
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %29) #285, !dbg !17278
  call void @llvm.dbg.declare(metadata i1* %scorer_lease, metadata !17279, metadata !DIExpression()), !dbg !17280
  %30 = load i8, i8* %op.addr, align 1, !dbg !17281
  %cmp13 = icmp eq i8 %30, 54, !dbg !17282
  store i1 %cmp13, i1* %scorer_lease, align 1, !dbg !17280
  %31 = load i1, i1* %qkv, align 1, !dbg !17283
  br i1 %31, label %if.then14, label %if.else, !dbg !17285

if.then14:                                        ; preds = %cond.end911
  %32 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %qkv_pair.addr, align 8, !dbg !17286
  %tobool = icmp ne %"struct.laya::full::FullOwnerSpec"* %32, null, !dbg !17286
  br i1 %tobool, label %if.end17, label %if.then15, !dbg !17289

if.then15:                                        ; preds = %if.then14
  %code = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 0, !dbg !17290
  store i16 8, i16* %code, align 8, !dbg !17290
  %detail = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 1, !dbg !17290
  %call16 = call i32 @_ZN4laya6detailEhht(i8 zeroext 7, i8 zeroext 0, i16 zeroext 4), !dbg !17291
  store i32 %call16, i32* %detail, align 4, !dbg !17290
  %bad_element = getelementptr inbounds %"struct.laya::Check", %"struct.laya::Check"* %agg.result, i32 0, i32 2, !dbg !17290
  store i64 -1, i64* %bad_element, align 8, !dbg !17290
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup116, !dbg !17292

if.end17:                                         ; preds = %if.then14
  %33 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17293
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 0, !dbg !17294
  %34 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %33, align 4, !dbg !17295
  store %"struct.laya::full::FullOwnerSpec" %34, %"struct.laya::full::FullOwnerSpec"* %arrayidx, align 4, !dbg !17295
  %35 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17296
  %arrayidx18 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 1, !dbg !17297
  %36 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %35, align 4, !dbg !17298
  store %"struct.laya::full::FullOwnerSpec" %36, %"struct.laya::full::FullOwnerSpec"* %arrayidx18, align 4, !dbg !17298
  %37 = bitcast %"struct.laya::BufferRef"* %ref.tmp19 to i8*, !dbg !17299
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %37) #285, !dbg !17299
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %ref.tmp19, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 5, i8 zeroext 1, i8 zeroext 0), !dbg !17299
  %arrayidx20 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 1, !dbg !17300
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx20, i32 0, i32 0, !dbg !17301
  %38 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp19, align 4, !dbg !17302
  store %"struct.laya::BufferRef" %38, %"struct.laya::BufferRef"* %ref, align 4, !dbg !17302
  %39 = bitcast %"struct.laya::BufferRef"* %ref.tmp19 to i8*, !dbg !17300
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %39) #285, !dbg !17300
  %40 = bitcast %"struct.laya::Check"* %ref.tmp21 to i8*, !dbg !17303
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %40) #285, !dbg !17303
  %rt = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17304
  %41 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt, align 8, !dbg !17304
  call void @_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp21, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %41, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %pair), !dbg !17303
  %42 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp21, align 8, !dbg !17305
  store %"struct.laya::Check" %42, %"struct.laya::Check"* %c, align 8, !dbg !17305
  %43 = bitcast %"struct.laya::Check"* %ref.tmp21 to i8*, !dbg !17306
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %43) #285, !dbg !17306
  br label %if.end26, !dbg !17307

if.else:                                          ; preds = %cond.end911
  %44 = load i1, i1* %scorer_lease, align 1, !dbg !17308
  br i1 %44, label %if.end25, label %if.then22, !dbg !17310

if.then22:                                        ; preds = %if.else
  %45 = bitcast %"struct.laya::Check"* %ref.tmp23 to i8*, !dbg !17311
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %45) #285, !dbg !17311
  %rt24 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17312
  %46 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt24, align 8, !dbg !17312
  %47 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17313
  call void @_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp23, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %46, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %47), !dbg !17311
  %48 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp23, align 8, !dbg !17314
  store %"struct.laya::Check" %48, %"struct.laya::Check"* %c, align 8, !dbg !17314
  %49 = bitcast %"struct.laya::Check"* %ref.tmp23 to i8*, !dbg !17315
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %49) #285, !dbg !17315
  br label %if.end25, !dbg !17315

if.end25:                                         ; preds = %if.then22, %if.else
  br label %if.end26

if.end26:                                         ; preds = %if.end25, %if.end17
  %call27 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17316
  br i1 %call27, label %if.end29, label %if.then28, !dbg !17318

if.then28:                                        ; preds = %if.end26
  %50 = load %"struct.laya::Check", %"struct.laya::Check"* %c, align 8, !dbg !17319
  store %"struct.laya::Check" %50, %"struct.laya::Check"* %agg.result, align 8, !dbg !17319
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup116, !dbg !17320

if.end29:                                         ; preds = %if.end26
  %51 = bitcast i32* %rows to i8*, !dbg !17321
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %51) #285, !dbg !17321
  call void @llvm.dbg.declare(metadata i32* %rows, metadata !17322, metadata !DIExpression()), !dbg !17323
  %52 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17324
  %rows30 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %52, i32 0, i32 7, !dbg !17325
  %53 = load i16, i16* %rows30, align 4, !dbg !17325
  %conv31 = zext i16 %53 to i32, !dbg !17324
  store i32 %conv31, i32* %rows, align 4, !dbg !17323
  br label %VITIS_LOOP_219_1, !dbg !17321

VITIS_LOOP_219_1:                                 ; preds = %if.end29
  %54 = bitcast i32* %b to i8*, !dbg !17326
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %54) #285, !dbg !17326
  call void @llvm.dbg.declare(metadata i32* %b, metadata !17328, metadata !DIExpression()), !dbg !17329
  store i32 0, i32* %b, align 4, !dbg !17329
  br label %for.cond, !dbg !17326

for.cond:                                         ; preds = %for.inc92, %VITIS_LOOP_219_1
  %55 = load i32, i32* %b, align 4, !dbg !17330
  %rt32 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17332
  %56 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt32, align 8, !dbg !17332
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %56, i32 0, i32 0, !dbg !17333
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !17334
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 2, !dbg !17335
  %57 = load i16, i16* %B, align 8, !dbg !17335
  %conv33 = zext i16 %57 to i32, !dbg !17332
  %cmp34 = icmp ult i32 %55, %conv33, !dbg !17336
  br i1 %cmp34, label %land.rhs, label %land.end, !dbg !17337

land.rhs:                                         ; preds = %for.cond
  %call35 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17338
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %58 = phi i1 [ false, %for.cond ], [ %call35, %land.rhs ], !dbg !17339
  br i1 %58, label %for.body, label %for.cond.cleanup, !dbg !17340

for.cond.cleanup:                                 ; preds = %land.end
  store i32 3, i32* %cleanup.dest.slot, align 4
  %59 = bitcast i32* %b to i8*, !dbg !17341
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %59) #285, !dbg !17341
  br label %for.end94

for.body:                                         ; preds = %land.end
  br label %VITIS_LOOP_220_2, !dbg !17340

VITIS_LOOP_220_2:                                 ; preds = %for.body
  %60 = bitcast i32* %row to i8*, !dbg !17342
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %60) #285, !dbg !17342
  call void @llvm.dbg.declare(metadata i32* %row, metadata !17344, metadata !DIExpression()), !dbg !17345
  store i32 0, i32* %row, align 4, !dbg !17345
  br label %for.cond36, !dbg !17342

for.cond36:                                       ; preds = %for.inc, %VITIS_LOOP_220_2
  %61 = load i32, i32* %row, align 4, !dbg !17346
  %62 = load i32, i32* %rows, align 4, !dbg !17348
  %cmp37 = icmp ult i32 %61, %62, !dbg !17349
  br i1 %cmp37, label %for.body39, label %for.cond.cleanup38, !dbg !17350

for.cond.cleanup38:                               ; preds = %for.cond36
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup91, !dbg !17350

for.body39:                                       ; preds = %for.cond36
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %count) #285, !dbg !17351
  call void @llvm.dbg.declare(metadata i8* %count, metadata !17353, metadata !DIExpression()), !dbg !17354
  %63 = load i32, i32* %rows, align 4, !dbg !17355
  %64 = load i32, i32* %row, align 4, !dbg !17356
  %sub = sub i32 %63, %64, !dbg !17357
  %cmp40 = icmp ult i32 %sub, 16, !dbg !17358
  br i1 %cmp40, label %cond.true41, label %cond.false43, !dbg !17355

cond.true41:                                      ; preds = %for.body39
  %65 = load i32, i32* %rows, align 4, !dbg !17359
  %66 = load i32, i32* %row, align 4, !dbg !17360
  %sub42 = sub i32 %65, %66, !dbg !17361
  br label %cond.end44, !dbg !17355

cond.false43:                                     ; preds = %for.body39
  br label %cond.end44, !dbg !17355

cond.end44:                                       ; preds = %cond.false43, %cond.true41
  %cond45 = phi i32 [ %sub42, %cond.true41 ], [ 16, %cond.false43 ], !dbg !17355
  %conv46 = trunc i32 %cond45 to i8, !dbg !17355
  store i8 %conv46, i8* %count, align 1, !dbg !17354
  %67 = bitcast %"struct.laya::QuantTask"* %quant to i8*, !dbg !17362
  call void @llvm.lifetime.start.p0i8(i64 36, i8* %67) #285, !dbg !17362
  call void @llvm.dbg.declare(metadata %"struct.laya::QuantTask"* %quant, metadata !17363, metadata !DIExpression()), !dbg !17372
  call void @_ZN4laya9QuantTaskC2Ev(%"struct.laya::QuantTask"* nonnull align 4 dereferenceable(36) %quant) #285, !dbg !17372
  %68 = bitcast %"struct.laya::TaskContext"* %ref.tmp47 to i8*, !dbg !17373
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %68) #285, !dbg !17373
  %69 = load i8, i8* %stage.addr, align 1, !dbg !17374
  %70 = load i8, i8* %layer.addr, align 1, !dbg !17375
  %71 = load i32, i32* %b, align 4, !dbg !17376
  %conv48 = trunc i32 %71 to i8, !dbg !17376
  %72 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17377
  %row_space49 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %72, i32 0, i32 5, !dbg !17378
  %73 = load i8, i8* %row_space49, align 4, !dbg !17378
  %74 = load i32, i32* %row, align 4, !dbg !17379
  %conv50 = trunc i32 %74 to i16, !dbg !17379
  %75 = load i8, i8* %count, align 1, !dbg !17380
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller7contextENS_2OpEhhhNS_8RowSpaceEth(%"struct.laya::TaskContext"* sret align 4 %ref.tmp47, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 32, i8 zeroext %69, i8 zeroext %70, i8 zeroext %conv48, i8 zeroext %73, i16 zeroext %conv50, i8 zeroext %75), !dbg !17373
  %ctx = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 0, !dbg !17381
  %76 = load %"struct.laya::TaskContext", %"struct.laya::TaskContext"* %ref.tmp47, align 4, !dbg !17382
  store %"struct.laya::TaskContext" %76, %"struct.laya::TaskContext"* %ctx, align 4, !dbg !17382
  %77 = bitcast %"struct.laya::TaskContext"* %ref.tmp47 to i8*, !dbg !17383
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %77) #285, !dbg !17383
  %78 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17384
  %ref51 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %78, i32 0, i32 0, !dbg !17385
  %src = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 1, !dbg !17386
  %79 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref51, align 4, !dbg !17387
  store %"struct.laya::BufferRef" %79, %"struct.laya::BufferRef"* %src, align 4, !dbg !17387
  %80 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17388
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %80, i32 0, i32 1, !dbg !17389
  %81 = load i8, i8* %region, align 4, !dbg !17389
  %src_region = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 4, !dbg !17390
  store i8 %81, i8* %src_region, align 2, !dbg !17391
  %82 = bitcast %"struct.laya::BufferRef"* %ref.tmp52 to i8*, !dbg !17392
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %82) #285, !dbg !17392
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %ref.tmp52, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 34, i8 zeroext 0, i8 zeroext 0), !dbg !17392
  %a_dst = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 2, !dbg !17393
  %83 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp52, align 4, !dbg !17394
  store %"struct.laya::BufferRef" %83, %"struct.laya::BufferRef"* %a_dst, align 4, !dbg !17394
  %84 = bitcast %"struct.laya::BufferRef"* %ref.tmp52 to i8*, !dbg !17395
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %84) #285, !dbg !17395
  %K = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 2, !dbg !17396
  %85 = load i16, i16* %K, align 2, !dbg !17396
  %K53 = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 3, !dbg !17397
  store i16 %85, i16* %K53, align 4, !dbg !17398
  %86 = bitcast %"struct.laya::Check"* %ref.tmp54 to i8*, !dbg !17399
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %86) #285, !dbg !17399
  %rt55 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17400
  %87 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt55, align 8, !dbg !17400
  %88 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17401
  call void @_ZN4laya4full22full_bind_quant_sourceERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp54, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %87, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %88), !dbg !17399
  %89 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp54, align 8, !dbg !17402
  store %"struct.laya::Check" %89, %"struct.laya::Check"* %c, align 8, !dbg !17402
  %90 = bitcast %"struct.laya::Check"* %ref.tmp54 to i8*, !dbg !17403
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %90) #285, !dbg !17403
  %call56 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17404
  br i1 %call56, label %if.then57, label %if.end62, !dbg !17406

if.then57:                                        ; preds = %cond.end44
  %91 = bitcast %"struct.laya::Check"* %ref.tmp58 to i8*, !dbg !17407
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %91) #285, !dbg !17407
  %92 = load i8, i8* %count, align 1, !dbg !17408
  %conv59 = zext i8 %92 to i32, !dbg !17408
  %K60 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 2, !dbg !17409
  %93 = load i16, i16* %K60, align 2, !dbg !17409
  %conv61 = zext i16 %93 to i32, !dbg !17410
  %mul = mul i32 %conv59, %conv61, !dbg !17411
  %div = udiv i32 %mul, 32, !dbg !17412
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5issueINS_9QuantTaskEEENS_5CheckERKT_jNS_10OutputUnitE(%"struct.laya::Check"* sret align 8 %ref.tmp58, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::QuantTask"* nonnull align 4 dereferenceable(36) %quant, i32 %div, i8 zeroext 2), !dbg !17407
  %94 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp58, align 8, !dbg !17413
  store %"struct.laya::Check" %94, %"struct.laya::Check"* %c, align 8, !dbg !17413
  %95 = bitcast %"struct.laya::Check"* %ref.tmp58 to i8*, !dbg !17414
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %95) #285, !dbg !17414
  br label %if.end62, !dbg !17414

if.end62:                                         ; preds = %if.then57, %cond.end44
  %call63 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17415
  br i1 %call63, label %if.end65, label %if.then64, !dbg !17417

if.then64:                                        ; preds = %if.end62
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup89, !dbg !17418

if.end65:                                         ; preds = %if.end62
  %96 = bitcast %"struct.laya::LinearTask"* %t to i8*, !dbg !17419
  call void @llvm.lifetime.start.p0i8(i64 56, i8* %96) #285, !dbg !17419
  call void @llvm.dbg.declare(metadata %"struct.laya::LinearTask"* %t, metadata !17420, metadata !DIExpression()), !dbg !17433
  call void @_ZN4laya10LinearTaskC2Ev(%"struct.laya::LinearTask"* nonnull align 4 dereferenceable(56) %t) #285, !dbg !17433
  %97 = bitcast %"struct.laya::TaskContext"* %ref.tmp66 to i8*, !dbg !17434
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %97) #285, !dbg !17434
  %98 = load i8, i8* %op.addr, align 1, !dbg !17435
  %99 = load i8, i8* %stage.addr, align 1, !dbg !17436
  %100 = load i8, i8* %layer.addr, align 1, !dbg !17437
  %101 = load i32, i32* %b, align 4, !dbg !17438
  %conv67 = trunc i32 %101 to i8, !dbg !17438
  %102 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %source.addr, align 8, !dbg !17439
  %row_space68 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %102, i32 0, i32 5, !dbg !17440
  %103 = load i8, i8* %row_space68, align 4, !dbg !17440
  %104 = load i32, i32* %row, align 4, !dbg !17441
  %conv69 = trunc i32 %104 to i16, !dbg !17441
  %105 = load i8, i8* %count, align 1, !dbg !17442
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller7contextENS_2OpEhhhNS_8RowSpaceEth(%"struct.laya::TaskContext"* sret align 4 %ref.tmp66, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %98, i8 zeroext %99, i8 zeroext %100, i8 zeroext %conv67, i8 zeroext %103, i16 zeroext %conv69, i8 zeroext %105), !dbg !17434
  %ctx70 = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 0, !dbg !17443
  %106 = load %"struct.laya::TaskContext", %"struct.laya::TaskContext"* %ref.tmp66, align 4, !dbg !17444
  store %"struct.laya::TaskContext" %106, %"struct.laya::TaskContext"* %ctx70, align 4, !dbg !17444
  %107 = bitcast %"struct.laya::TaskContext"* %ref.tmp66 to i8*, !dbg !17445
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %107) #285, !dbg !17445
  %a_dst71 = getelementptr inbounds %"struct.laya::QuantTask", %"struct.laya::QuantTask"* %quant, i32 0, i32 2, !dbg !17446
  %a = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 1, !dbg !17447
  %108 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %a_dst71, align 4, !dbg !17448
  store %"struct.laya::BufferRef" %108, %"struct.laya::BufferRef"* %a, align 4, !dbg !17448
  %rt72 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17449
  %109 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt72, align 8, !dbg !17449
  %current_weight_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %109, i32 0, i32 4, !dbg !17450
  %w = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 2, !dbg !17451
  %110 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %current_weight_ref, align 8, !dbg !17452
  store %"struct.laya::BufferRef" %110, %"struct.laya::BufferRef"* %w, align 4, !dbg !17452
  %111 = bitcast %"struct.laya::BufferRef"* %ref.tmp73 to i8*, !dbg !17453
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %111) #285, !dbg !17453
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %ref.tmp73, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 36, i8 zeroext 0, i8 zeroext 0), !dbg !17453
  %ps = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 3, !dbg !17454
  %112 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp73, align 4, !dbg !17455
  store %"struct.laya::BufferRef" %112, %"struct.laya::BufferRef"* %ps, align 4, !dbg !17455
  %113 = bitcast %"struct.laya::BufferRef"* %ref.tmp73 to i8*, !dbg !17456
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %113) #285, !dbg !17456
  %114 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17457
  %ref74 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %114, i32 0, i32 0, !dbg !17458
  %dst = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 4, !dbg !17459
  %115 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref74, align 4, !dbg !17460
  store %"struct.laya::BufferRef" %115, %"struct.laya::BufferRef"* %dst, align 4, !dbg !17460
  %weight = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 5, !dbg !17461
  %116 = load %"struct.laya::WeightKey", %"struct.laya::WeightKey"* %key, align 1, !dbg !17462
  store %"struct.laya::WeightKey" %116, %"struct.laya::WeightKey"* %weight, align 4, !dbg !17462
  %K75 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 2, !dbg !17463
  %117 = load i16, i16* %K75, align 2, !dbg !17463
  %K76 = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 6, !dbg !17464
  store i16 %117, i16* %K76, align 2, !dbg !17465
  %N77 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 3, !dbg !17466
  %118 = load i16, i16* %N77, align 4, !dbg !17466
  %N78 = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 7, !dbg !17467
  store i16 %118, i16* %N78, align 4, !dbg !17468
  %119 = load i8, i8* %dst_region.addr, align 1, !dbg !17469
  %dst_region79 = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 8, !dbg !17470
  store i8 %119, i8* %dst_region79, align 2, !dbg !17471
  %bias_kind = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 5, !dbg !17472
  %120 = load i8, i8* %bias_kind, align 1, !dbg !17472
  %bias_kind80 = getelementptr inbounds %"struct.laya::LinearTask", %"struct.laya::LinearTask"* %t, i32 0, i32 9, !dbg !17473
  store i8 %120, i8* %bias_kind80, align 1, !dbg !17474
  %121 = bitcast %"struct.laya::Check"* %ref.tmp81 to i8*, !dbg !17475
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %121) #285, !dbg !17475
  %122 = load i8, i8* %count, align 1, !dbg !17476
  %conv82 = zext i8 %122 to i32, !dbg !17476
  %N83 = getelementptr inbounds %"struct.laya::full::FullWeightDescriptor", %"struct.laya::full::FullWeightDescriptor"* %descriptor, i32 0, i32 3, !dbg !17477
  %123 = load i16, i16* %N83, align 4, !dbg !17477
  %conv84 = zext i16 %123 to i32, !dbg !17478
  %mul85 = mul i32 %conv82, %conv84, !dbg !17479
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5issueINS_10LinearTaskEEENS_5CheckERKT_jNS_10OutputUnitE(%"struct.laya::Check"* sret align 8 %ref.tmp81, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::LinearTask"* nonnull align 4 dereferenceable(56) %t, i32 %mul85, i8 zeroext 1), !dbg !17475
  %124 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp81, align 8, !dbg !17480
  store %"struct.laya::Check" %124, %"struct.laya::Check"* %c, align 8, !dbg !17480
  %125 = bitcast %"struct.laya::Check"* %ref.tmp81 to i8*, !dbg !17481
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %125) #285, !dbg !17481
  %call86 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17482
  br i1 %call86, label %if.end88, label %if.then87, !dbg !17484

if.then87:                                        ; preds = %if.end65
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !17485

if.end88:                                         ; preds = %if.end65
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !17486
  br label %cleanup, !dbg !17486

cleanup:                                          ; preds = %if.end88, %if.then87
  %126 = bitcast %"struct.laya::LinearTask"* %t to i8*, !dbg !17486
  call void @llvm.lifetime.end.p0i8(i64 56, i8* %126) #285, !dbg !17486
  br label %cleanup89

cleanup89:                                        ; preds = %cleanup, %if.then64
  %127 = bitcast %"struct.laya::QuantTask"* %quant to i8*, !dbg !17486
  call void @llvm.lifetime.end.p0i8(i64 36, i8* %127) #285, !dbg !17486
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %count) #285, !dbg !17486
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup91 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup89
  br label %for.inc, !dbg !17487

for.inc:                                          ; preds = %cleanup.cont
  %128 = load i32, i32* %row, align 4, !dbg !17488
  %add = add i32 %128, 16, !dbg !17488
  store i32 %add, i32* %row, align 4, !dbg !17488
  br label %for.cond36, !dbg !17489, !llvm.loop !17490

cleanup91:                                        ; preds = %cleanup89, %for.cond.cleanup38
  %129 = bitcast i32* %row to i8*, !dbg !17489
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %129) #285, !dbg !17489
  br label %for.end

for.end:                                          ; preds = %cleanup91
  br label %for.inc92, !dbg !17491

for.inc92:                                        ; preds = %for.end
  %130 = load i32, i32* %b, align 4, !dbg !17493
  %inc = add i32 %130, 1, !dbg !17493
  store i32 %inc, i32* %b, align 4, !dbg !17493
  br label %for.cond, !dbg !17341, !llvm.loop !17494

for.end94:                                        ; preds = %for.cond.cleanup
  %call95 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17497
  br i1 %call95, label %land.lhs.true, label %if.else99, !dbg !17499

land.lhs.true:                                    ; preds = %for.end94
  %131 = load i1, i1* %qkv, align 1, !dbg !17500
  br i1 %131, label %if.then96, label %if.else99, !dbg !17501

if.then96:                                        ; preds = %land.lhs.true
  %132 = bitcast %"struct.laya::Check"* %ref.tmp97 to i8*, !dbg !17502
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %132) #285, !dbg !17502
  %rt98 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17503
  %133 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt98, align 8, !dbg !17503
  call void @_ZN4laya4full21full_publish_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp97, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %133, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %pair), !dbg !17502
  %134 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp97, align 8, !dbg !17504
  store %"struct.laya::Check" %134, %"struct.laya::Check"* %c, align 8, !dbg !17504
  %135 = bitcast %"struct.laya::Check"* %ref.tmp97 to i8*, !dbg !17505
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %135) #285, !dbg !17505
  br label %if.end106, !dbg !17505

if.else99:                                        ; preds = %land.lhs.true, %for.end94
  %call100 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17506
  br i1 %call100, label %land.lhs.true101, label %if.end105, !dbg !17508

land.lhs.true101:                                 ; preds = %if.else99
  %136 = load i1, i1* %scorer_lease, align 1, !dbg !17509
  br i1 %136, label %if.end105, label %if.then102, !dbg !17510

if.then102:                                       ; preds = %land.lhs.true101
  %137 = bitcast %"struct.laya::Check"* %ref.tmp103 to i8*, !dbg !17511
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %137) #285, !dbg !17511
  %rt104 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !17512
  %138 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt104, align 8, !dbg !17512
  %139 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !17513
  call void @_ZN4laya4full18full_publish_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp103, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %138, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %139), !dbg !17511
  %140 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp103, align 8, !dbg !17514
  store %"struct.laya::Check" %140, %"struct.laya::Check"* %c, align 8, !dbg !17514
  %141 = bitcast %"struct.laya::Check"* %ref.tmp103 to i8*, !dbg !17515
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %141) #285, !dbg !17515
  br label %if.end105, !dbg !17515

if.end105:                                        ; preds = %if.then102, %land.lhs.true101, %if.else99
  br label %if.end106

if.end106:                                        ; preds = %if.end105, %if.then96
  %call107 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %c), !dbg !17516
  br i1 %call107, label %land.lhs.true108, label %if.end114, !dbg !17518

land.lhs.true108:                                 ; preds = %if.end106
  %142 = load i1, i1* %qkv, align 1, !dbg !17519
  br i1 %142, label %if.then109, label %if.end114, !dbg !17520

if.then109:                                       ; preds = %land.lhs.true108
  %arrayidx110 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 0, !dbg !17521
  %143 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %qkv_pair.addr, align 8, !dbg !17523
  %arrayidx111 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %143, i64 0, !dbg !17523
  %144 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx110, align 4, !dbg !17524
  store %"struct.laya::full::FullOwnerSpec" %144, %"struct.laya::full::FullOwnerSpec"* %arrayidx111, align 4, !dbg !17524
  %arrayidx112 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %pair, i64 0, i64 1, !dbg !17525
  %145 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %qkv_pair.addr, align 8, !dbg !17526
  %arrayidx113 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %145, i64 1, !dbg !17526
  %146 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx112, align 4, !dbg !17527
  store %"struct.laya::full::FullOwnerSpec" %146, %"struct.laya::full::FullOwnerSpec"* %arrayidx113, align 4, !dbg !17527
  br label %if.end114, !dbg !17528

if.end114:                                        ; preds = %if.then109, %land.lhs.true108, %if.end106
  %147 = load %"struct.laya::Check", %"struct.laya::Check"* %c, align 8, !dbg !17529
  store %"struct.laya::Check" %147, %"struct.laya::Check"* %agg.result, align 8, !dbg !17529
  store i32 1, i32* %cleanup.dest.slot, align 4
  %148 = bitcast i32* %rows to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %148) #285, !dbg !17530
  br label %cleanup116

cleanup116:                                       ; preds = %if.end114, %if.then28, %if.then15
  %149 = bitcast i1* %scorer_lease to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %149) #285, !dbg !17530
  %150 = bitcast [2 x %"struct.laya::full::FullOwnerSpec"]* %pair to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %150) #285, !dbg !17530
  %151 = bitcast i1* %qkv to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %151) #285, !dbg !17530
  br label %cleanup119

cleanup119:                                       ; preds = %cleanup116, %if.then
  %152 = bitcast %"struct.laya::Check"* %c to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %152) #285, !dbg !17530
  %153 = bitcast %"struct.laya::full::FullWeightDescriptor"* %descriptor to i8*, !dbg !17530
  call void @llvm.lifetime.end.p0i8(i64 160, i8* %153) #285, !dbg !17530
  ret void, !dbg !17530
}
