define internal void @_ZN4laya4full12_GLOBAL__N_110Controller6vectorENS_2OpERKNS0_13FullOwnerSpecEPS5_hhNS_9BufferRefEhtRS4_(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this, i8 zeroext %op, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %src0, %"struct.laya::full::FullOwnerSpec"* %src1, i8 zeroext %stage, i8 zeroext %layer, %"struct.laya::BufferRef"* byval align 4 %dst_ref, i8 zeroext %dst_region, i16 zeroext %length, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %output) #63 align 2 !dbg !18240 !type !18241 {
entry:
  %this.addr = alloca %"struct.laya::full::(anonymous namespace)::Controller"*, align 8
  %op.addr = alloca i8, align 1
  %src0.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %src1.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %stage.addr = alloca i8, align 1
  %layer.addr = alloca i8, align 1
  %dst_region.addr = alloca i8, align 1
  %length.addr = alloca i16, align 2
  %output.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %ref.tmp = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %rows = alloca i32, align 4
  %b = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %row = alloca i32, align 4
  %t = alloca %"struct.laya::VectorTask", align 4
  %ref.tmp11 = alloca %"struct.laya::TaskContext", align 4
  %ref.tmp23 = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp40 = alloca %"struct.laya::Check", align 8
  %ref.tmp44 = alloca %"struct.laya::Check", align 8
  %ref.tmp48 = alloca %"struct.laya::Check", align 8
  %ref.tmp63 = alloca %"struct.laya::Check", align 8
  store %"struct.laya::full::(anonymous namespace)::Controller"* %this, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, metadata !18243, metadata !DIExpression()), !dbg !18244
  store i8 %op, i8* %op.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %op.addr, metadata !18245, metadata !DIExpression()), !dbg !18246
  store %"struct.laya::full::FullOwnerSpec"* %src0, %"struct.laya::full::FullOwnerSpec"** %src0.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %src0.addr, metadata !18247, metadata !DIExpression()), !dbg !18248
  store %"struct.laya::full::FullOwnerSpec"* %src1, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %src1.addr, metadata !18249, metadata !DIExpression()), !dbg !18250
  store i8 %stage, i8* %stage.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %stage.addr, metadata !18251, metadata !DIExpression()), !dbg !18252
  store i8 %layer, i8* %layer.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %layer.addr, metadata !18253, metadata !DIExpression()), !dbg !18254
  call void @llvm.dbg.declare(metadata %"struct.laya::BufferRef"* %dst_ref, metadata !18255, metadata !DIExpression()), !dbg !18256
  store i8 %dst_region, i8* %dst_region.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %dst_region.addr, metadata !18257, metadata !DIExpression()), !dbg !18258
  store i16 %length, i16* %length.addr, align 2
  call void @llvm.dbg.declare(metadata i16* %length.addr, metadata !18259, metadata !DIExpression()), !dbg !18260
  store %"struct.laya::full::FullOwnerSpec"* %output, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %output.addr, metadata !18261, metadata !DIExpression()), !dbg !18262
  %this1 = load %"struct.laya::full::(anonymous namespace)::Controller"*, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  %0 = load i8, i8* %stage.addr, align 1, !dbg !18263
  %1 = load i8, i8* %op.addr, align 1, !dbg !18264
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %0, i8 zeroext %1), !dbg !18265
  %2 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp to i8*, !dbg !18266
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %2) #285, !dbg !18266
  %3 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %dst_ref, align 4, !dbg !18267
  store %"struct.laya::BufferRef" %3, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !18267
  %4 = load i8, i8* %dst_region.addr, align 1, !dbg !18268
  %5 = load i8, i8* %stage.addr, align 1, !dbg !18269
  %6 = load i8, i8* %layer.addr, align 1, !dbg !18270
  %7 = load i8, i8* %op.addr, align 1, !dbg !18271
  %cmp = icmp eq i8 %7, 102, !dbg !18272
  br i1 %cmp, label %cond.true, label %cond.false, !dbg !18271

cond.true:                                        ; preds = %entry
  br label %cond.end, !dbg !18271

cond.false:                                       ; preds = %entry
  %8 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src0.addr, align 8, !dbg !18273
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %8, i32 0, i32 5, !dbg !18274
  %9 = load i8, i8* %row_space, align 4, !dbg !18274
  br label %cond.end, !dbg !18271

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i8 [ 2, %cond.true ], [ %9, %cond.false ], !dbg !18271
  %10 = load i16, i16* %length.addr, align 2, !dbg !18275
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller6matrixENS_9BufferRefEhhhNS_8RowSpaceEtNS_7ContentE(%"struct.laya::full::FullOwnerSpec"* sret align 4 %ref.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext %4, i8 zeroext %5, i8 zeroext %6, i8 zeroext %cond, i16 zeroext %10, i8 zeroext 1), !dbg !18266
  %11 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18276
  %12 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %ref.tmp, align 4, !dbg !18277
  store %"struct.laya::full::FullOwnerSpec" %12, %"struct.laya::full::FullOwnerSpec"* %11, align 4, !dbg !18277
  %13 = bitcast %"struct.laya::full::FullOwnerSpec"* %ref.tmp to i8*, !dbg !18276
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %13) #285, !dbg !18276
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %agg.result, metadata !18278, metadata !DIExpression()), !dbg !18279
  %rt = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18280
  %14 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt, align 8, !dbg !18280
  %15 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18281
  call void @_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %14, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %15), !dbg !18282
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18283
  br i1 %call, label %if.end, label %if.then, !dbg !18285

if.then:                                          ; preds = %cond.end
  br label %return, !dbg !18286

if.end:                                           ; preds = %cond.end
  %16 = bitcast i32* %rows to i8*, !dbg !18287
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %16) #285, !dbg !18287
  call void @llvm.dbg.declare(metadata i32* %rows, metadata !18288, metadata !DIExpression()), !dbg !18289
  %17 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18290
  %rows2 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %17, i32 0, i32 7, !dbg !18291
  %18 = load i16, i16* %rows2, align 4, !dbg !18291
  %conv = zext i16 %18 to i32, !dbg !18290
  store i32 %conv, i32* %rows, align 4, !dbg !18289
  br label %VITIS_LOOP_175_1, !dbg !18287

VITIS_LOOP_175_1:                                 ; preds = %if.end
  %19 = bitcast i32* %b to i8*, !dbg !18292
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %19) #285, !dbg !18292
  call void @llvm.dbg.declare(metadata i32* %b, metadata !18294, metadata !DIExpression()), !dbg !18295
  store i32 0, i32* %b, align 4, !dbg !18295
  br label %for.cond, !dbg !18292

for.cond:                                         ; preds = %for.inc58, %VITIS_LOOP_175_1
  %20 = load i32, i32* %b, align 4, !dbg !18296
  %rt3 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18298
  %21 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt3, align 8, !dbg !18298
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %21, i32 0, i32 0, !dbg !18299
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !18300
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 2, !dbg !18301
  %22 = load i16, i16* %B, align 8, !dbg !18301
  %conv4 = zext i16 %22 to i32, !dbg !18298
  %cmp5 = icmp ult i32 %20, %conv4, !dbg !18302
  br i1 %cmp5, label %land.rhs, label %land.end, !dbg !18303

land.rhs:                                         ; preds = %for.cond
  %call6 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18304
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %23 = phi i1 [ false, %for.cond ], [ %call6, %land.rhs ], !dbg !18305
  br i1 %23, label %for.body, label %for.cond.cleanup, !dbg !18306

for.cond.cleanup:                                 ; preds = %land.end
  store i32 3, i32* %cleanup.dest.slot, align 4
  %24 = bitcast i32* %b to i8*, !dbg !18307
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %24) #285, !dbg !18307
  br label %for.end60

for.body:                                         ; preds = %land.end
  br label %VITIS_LOOP_176_2, !dbg !18306

VITIS_LOOP_176_2:                                 ; preds = %for.body
  %25 = bitcast i32* %row to i8*, !dbg !18308
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %25) #285, !dbg !18308
  call void @llvm.dbg.declare(metadata i32* %row, metadata !18310, metadata !DIExpression()), !dbg !18311
  store i32 0, i32* %row, align 4, !dbg !18311
  br label %for.cond7, !dbg !18308

for.cond7:                                        ; preds = %for.inc, %VITIS_LOOP_176_2
  %26 = load i32, i32* %row, align 4, !dbg !18312
  %27 = load i32, i32* %rows, align 4, !dbg !18314
  %cmp8 = icmp ult i32 %26, %27, !dbg !18315
  br i1 %cmp8, label %for.body10, label %for.cond.cleanup9, !dbg !18316

for.cond.cleanup9:                                ; preds = %for.cond7
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup57, !dbg !18316

for.body10:                                       ; preds = %for.cond7
  %28 = bitcast %"struct.laya::VectorTask"* %t to i8*, !dbg !18317
  call void @llvm.lifetime.start.p0i8(i64 48, i8* %28) #285, !dbg !18317
  call void @llvm.dbg.declare(metadata %"struct.laya::VectorTask"* %t, metadata !18319, metadata !DIExpression()), !dbg !18331
  call void @_ZN4laya10VectorTaskC2Ev(%"struct.laya::VectorTask"* nonnull align 4 dereferenceable(48) %t) #285, !dbg !18331
  %29 = bitcast %"struct.laya::TaskContext"* %ref.tmp11 to i8*, !dbg !18332
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %29) #285, !dbg !18332
  %30 = load i8, i8* %op.addr, align 1, !dbg !18333
  %31 = load i8, i8* %stage.addr, align 1, !dbg !18334
  %32 = load i8, i8* %layer.addr, align 1, !dbg !18335
  %33 = load i32, i32* %b, align 4, !dbg !18336
  %conv12 = trunc i32 %33 to i8, !dbg !18336
  %34 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18337
  %row_space13 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %34, i32 0, i32 5, !dbg !18338
  %35 = load i8, i8* %row_space13, align 4, !dbg !18338
  %36 = load i32, i32* %row, align 4, !dbg !18339
  %conv14 = trunc i32 %36 to i16, !dbg !18339
  %37 = load i32, i32* %rows, align 4, !dbg !18340
  %38 = load i32, i32* %row, align 4, !dbg !18341
  %sub = sub i32 %37, %38, !dbg !18342
  %cmp15 = icmp ult i32 %sub, 16, !dbg !18343
  br i1 %cmp15, label %cond.true16, label %cond.false18, !dbg !18340

cond.true16:                                      ; preds = %for.body10
  %39 = load i32, i32* %rows, align 4, !dbg !18344
  %40 = load i32, i32* %row, align 4, !dbg !18345
  %sub17 = sub i32 %39, %40, !dbg !18346
  br label %cond.end19, !dbg !18340

cond.false18:                                     ; preds = %for.body10
  br label %cond.end19, !dbg !18340

cond.end19:                                       ; preds = %cond.false18, %cond.true16
  %cond20 = phi i32 [ %sub17, %cond.true16 ], [ 16, %cond.false18 ], !dbg !18340
  %conv21 = trunc i32 %cond20 to i8, !dbg !18340
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller7contextENS_2OpEhhhNS_8RowSpaceEth(%"struct.laya::TaskContext"* sret align 4 %ref.tmp11, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %30, i8 zeroext %31, i8 zeroext %32, i8 zeroext %conv12, i8 zeroext %35, i16 zeroext %conv14, i8 zeroext %conv21), !dbg !18332
  %ctx = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 0, !dbg !18347
  %41 = load %"struct.laya::TaskContext", %"struct.laya::TaskContext"* %ref.tmp11, align 4, !dbg !18348
  store %"struct.laya::TaskContext" %41, %"struct.laya::TaskContext"* %ctx, align 4, !dbg !18348
  %42 = bitcast %"struct.laya::TaskContext"* %ref.tmp11 to i8*, !dbg !18349
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %42) #285, !dbg !18349
  %43 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src0.addr, align 8, !dbg !18350
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %43, i32 0, i32 0, !dbg !18351
  %src022 = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 1, !dbg !18352
  %44 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !18353
  store %"struct.laya::BufferRef" %44, %"struct.laya::BufferRef"* %src022, align 4, !dbg !18353
  %45 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src0.addr, align 8, !dbg !18354
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %45, i32 0, i32 1, !dbg !18355
  %46 = load i8, i8* %region, align 4, !dbg !18355
  %src0_region = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 5, !dbg !18356
  store i8 %46, i8* %src0_region, align 2, !dbg !18357
  %47 = bitcast %"struct.laya::BufferRef"* %ref.tmp23 to i8*, !dbg !18358
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %47) #285, !dbg !18358
  %48 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18358
  %tobool = icmp ne %"struct.laya::full::FullOwnerSpec"* %48, null, !dbg !18358
  br i1 %tobool, label %cond.true24, label %cond.false26, !dbg !18358

cond.true24:                                      ; preds = %cond.end19
  %49 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18359
  %ref25 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %49, i32 0, i32 0, !dbg !18360
  %50 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref25, align 4, !dbg !18359
  store %"struct.laya::BufferRef" %50, %"struct.laya::BufferRef"* %ref.tmp23, align 4, !dbg !18359
  br label %cond.end27, !dbg !18358

cond.false26:                                     ; preds = %cond.end19
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret align 4 %ref.tmp23), !dbg !18361
  br label %cond.end27, !dbg !18358

cond.end27:                                       ; preds = %cond.false26, %cond.true24
  %src128 = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 2, !dbg !18362
  %51 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp23, align 4, !dbg !18363
  store %"struct.laya::BufferRef" %51, %"struct.laya::BufferRef"* %src128, align 4, !dbg !18363
  %52 = bitcast %"struct.laya::BufferRef"* %ref.tmp23 to i8*, !dbg !18364
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %52) #285, !dbg !18364
  %53 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18365
  %tobool29 = icmp ne %"struct.laya::full::FullOwnerSpec"* %53, null, !dbg !18365
  br i1 %tobool29, label %cond.true30, label %cond.false33, !dbg !18365

cond.true30:                                      ; preds = %cond.end27
  %54 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18366
  %region31 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %54, i32 0, i32 1, !dbg !18367
  %55 = load i8, i8* %region31, align 4, !dbg !18367
  %conv32 = zext i8 %55 to i32, !dbg !18366
  br label %cond.end34, !dbg !18365

cond.false33:                                     ; preds = %cond.end27
  br label %cond.end34, !dbg !18365

cond.end34:                                       ; preds = %cond.false33, %cond.true30
  %cond35 = phi i32 [ %conv32, %cond.true30 ], [ 0, %cond.false33 ], !dbg !18365
  %conv36 = trunc i32 %cond35 to i8, !dbg !18365
  %src1_region = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 6, !dbg !18368
  store i8 %conv36, i8* %src1_region, align 1, !dbg !18369
  %56 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18370
  %ref37 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %56, i32 0, i32 0, !dbg !18371
  %dst = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 3, !dbg !18372
  %57 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref37, align 4, !dbg !18373
  store %"struct.laya::BufferRef" %57, %"struct.laya::BufferRef"* %dst, align 4, !dbg !18373
  %58 = load i8, i8* %dst_region.addr, align 1, !dbg !18374
  %dst_region38 = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 7, !dbg !18375
  store i8 %58, i8* %dst_region38, align 4, !dbg !18376
  %59 = load i16, i16* %length.addr, align 2, !dbg !18377
  %length39 = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 4, !dbg !18378
  store i16 %59, i16* %length39, align 4, !dbg !18379
  %60 = bitcast %"struct.laya::Check"* %ref.tmp40 to i8*, !dbg !18380
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %60) #285, !dbg !18380
  %61 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src0.addr, align 8, !dbg !18381
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp40, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %61), !dbg !18380
  %62 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp40, align 8, !dbg !18382
  store %"struct.laya::Check" %62, %"struct.laya::Check"* %agg.result, align 8, !dbg !18382
  %63 = bitcast %"struct.laya::Check"* %ref.tmp40 to i8*, !dbg !18383
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %63) #285, !dbg !18383
  %call41 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18384
  br i1 %call41, label %land.lhs.true, label %if.end45, !dbg !18386

land.lhs.true:                                    ; preds = %cond.end34
  %64 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18387
  %tobool42 = icmp ne %"struct.laya::full::FullOwnerSpec"* %64, null, !dbg !18387
  br i1 %tobool42, label %if.then43, label %if.end45, !dbg !18388

if.then43:                                        ; preds = %land.lhs.true
  %65 = bitcast %"struct.laya::Check"* %ref.tmp44 to i8*, !dbg !18389
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %65) #285, !dbg !18389
  %66 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %src1.addr, align 8, !dbg !18390
  call void @_ZN4laya4full12_GLOBAL__N_110Controller4bindERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp44, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %66), !dbg !18389
  %67 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp44, align 8, !dbg !18391
  store %"struct.laya::Check" %67, %"struct.laya::Check"* %agg.result, align 8, !dbg !18391
  %68 = bitcast %"struct.laya::Check"* %ref.tmp44 to i8*, !dbg !18392
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %68) #285, !dbg !18392
  br label %if.end45, !dbg !18392

if.end45:                                         ; preds = %if.then43, %land.lhs.true, %cond.end34
  %call46 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18393
  br i1 %call46, label %if.then47, label %if.end53, !dbg !18395

if.then47:                                        ; preds = %if.end45
  %69 = bitcast %"struct.laya::Check"* %ref.tmp48 to i8*, !dbg !18396
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %69) #285, !dbg !18396
  %ctx49 = getelementptr inbounds %"struct.laya::VectorTask", %"struct.laya::VectorTask"* %t, i32 0, i32 0, !dbg !18397
  %rows50 = getelementptr inbounds %"struct.laya::TaskContext", %"struct.laya::TaskContext"* %ctx49, i32 0, i32 7, !dbg !18398
  %70 = load i8, i8* %rows50, align 4, !dbg !18398
  %conv51 = zext i8 %70 to i32, !dbg !18399
  %71 = load i16, i16* %length.addr, align 2, !dbg !18400
  %conv52 = zext i16 %71 to i32, !dbg !18400
  %mul = mul i32 %conv51, %conv52, !dbg !18401
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5issueINS_10VectorTaskEEENS_5CheckERKT_jNS_10OutputUnitE(%"struct.laya::Check"* sret align 8 %ref.tmp48, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::VectorTask"* nonnull align 4 dereferenceable(48) %t, i32 %mul, i8 zeroext 1), !dbg !18396
  %72 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp48, align 8, !dbg !18402
  store %"struct.laya::Check" %72, %"struct.laya::Check"* %agg.result, align 8, !dbg !18402
  %73 = bitcast %"struct.laya::Check"* %ref.tmp48 to i8*, !dbg !18403
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %73) #285, !dbg !18403
  br label %if.end53, !dbg !18403

if.end53:                                         ; preds = %if.then47, %if.end45
  %call54 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18404
  br i1 %call54, label %if.end56, label %if.then55, !dbg !18406

if.then55:                                        ; preds = %if.end53
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !18407

if.end56:                                         ; preds = %if.end53
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !18408
  br label %cleanup, !dbg !18408

cleanup:                                          ; preds = %if.end56, %if.then55
  %74 = bitcast %"struct.laya::VectorTask"* %t to i8*, !dbg !18408
  call void @llvm.lifetime.end.p0i8(i64 48, i8* %74) #285, !dbg !18408
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup57 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %for.inc, !dbg !18409

for.inc:                                          ; preds = %cleanup.cont
  %75 = load i32, i32* %row, align 4, !dbg !18410
  %add = add i32 %75, 16, !dbg !18410
  store i32 %add, i32* %row, align 4, !dbg !18410
  br label %for.cond7, !dbg !18411, !llvm.loop !18412

cleanup57:                                        ; preds = %cleanup, %for.cond.cleanup9
  %76 = bitcast i32* %row to i8*, !dbg !18411
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %76) #285, !dbg !18411
  br label %for.end

for.end:                                          ; preds = %cleanup57
  br label %for.inc58, !dbg !18413

for.inc58:                                        ; preds = %for.end
  %77 = load i32, i32* %b, align 4, !dbg !18415
  %inc = add i32 %77, 1, !dbg !18415
  store i32 %inc, i32* %b, align 4, !dbg !18415
  br label %for.cond, !dbg !18307, !llvm.loop !18416

for.end60:                                        ; preds = %for.cond.cleanup
  %call61 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18419
  br i1 %call61, label %if.then62, label %if.end65, !dbg !18421

if.then62:                                        ; preds = %for.end60
  %78 = bitcast %"struct.laya::Check"* %ref.tmp63 to i8*, !dbg !18422
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %78) #285, !dbg !18422
  %rt64 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18423
  %79 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt64, align 8, !dbg !18423
  %80 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %output.addr, align 8, !dbg !18424
  call void @_ZN4laya4full18full_publish_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp63, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %79, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %80), !dbg !18422
  %81 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp63, align 8, !dbg !18425
  store %"struct.laya::Check" %81, %"struct.laya::Check"* %agg.result, align 8, !dbg !18425
  %82 = bitcast %"struct.laya::Check"* %ref.tmp63 to i8*, !dbg !18426
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %82) #285, !dbg !18426
  br label %if.end65, !dbg !18426

if.end65:                                         ; preds = %if.then62, %for.end60
  store i32 1, i32* %cleanup.dest.slot, align 4
  %83 = bitcast i32* %rows to i8*, !dbg !18427
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %83) #285, !dbg !18427
  br label %return

return:                                           ; preds = %if.end65, %if.then
  ret void, !dbg !18427
}
