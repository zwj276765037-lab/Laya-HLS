define internal void @_ZN4laya4full12_GLOBAL__N_110Controller8type_addERNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden) #65 align 2 !dbg !18441 !type !16752 {
entry:
  %this.addr = alloca %"struct.laya::full::(anonymous namespace)::Controller"*, align 8
  %hidden.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %types = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %type = alloca i8, align 1
  %used = alloca i1, align 1
  %b = alloca i32, align 4
  %t = alloca %"struct.laya::EmbeddingTask", align 4
  %ref.tmp = alloca %"struct.laya::TaskContext", align 4
  %ref.tmp19 = alloca %"struct.laya::Check", align 8
  %next = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %ref.tmp27 = alloca %"struct.laya::Check", align 8
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp33 = alloca %"struct.laya::Check", align 8
  %ref.tmp38 = alloca %"struct.laya::Check", align 8
  store %"struct.laya::full::(anonymous namespace)::Controller"* %this, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, metadata !18442, metadata !DIExpression()), !dbg !18443
  store %"struct.laya::full::FullOwnerSpec"* %hidden, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %hidden.addr, metadata !18444, metadata !DIExpression()), !dbg !18445
  %this1 = load %"struct.laya::full::(anonymous namespace)::Controller"*, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 3, i8 zeroext 2), !dbg !18446
  %0 = bitcast %"struct.laya::full::FullOwnerSpec"* %types to i8*, !dbg !18447
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %0) #285, !dbg !18447
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %types, metadata !18448, metadata !DIExpression()), !dbg !18449
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 0, !dbg !18450
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %ref, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 11, i8 zeroext 0, i8 zeroext 0), !dbg !18451
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 1, !dbg !18450
  store i8 0, i8* %region, align 4, !dbg !18450
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 2, !dbg !18450
  store i8 3, i8* %stage, align 1, !dbg !18450
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 3, !dbg !18450
  store i8 -1, i8* %layer, align 2, !dbg !18450
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 4, !dbg !18450
  store i8 0, i8* %batch, align 1, !dbg !18450
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 5, !dbg !18450
  store i8 2, i8* %row_space, align 4, !dbg !18450
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 6, !dbg !18450
  store i16 0, i16* %row0, align 2, !dbg !18450
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 7, !dbg !18450
  store i16 3, i16* %rows, align 4, !dbg !18450
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 8, !dbg !18450
  store i16 1024, i16* %width, align 2, !dbg !18450
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 9, !dbg !18450
  store i8 1, i8* %content, align 4, !dbg !18450
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %agg.result, metadata !18452, metadata !DIExpression()), !dbg !18453
  %rt = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18454
  %1 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt, align 8, !dbg !18454
  call void @_ZN4laya4full16full_claim_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %1, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %types), !dbg !18455
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18456
  br i1 %call, label %if.end, label %if.then, !dbg !18458

if.then:                                          ; preds = %entry
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup45, !dbg !18459

if.end:                                           ; preds = %entry
  br label %VITIS_LOOP_400_1, !dbg !18456

VITIS_LOOP_400_1:                                 ; preds = %if.end
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %type) #285, !dbg !18460
  call void @llvm.dbg.declare(metadata i8* %type, metadata !18462, metadata !DIExpression()), !dbg !18463
  store i8 0, i8* %type, align 1, !dbg !18463
  br label %for.cond, !dbg !18460

for.cond:                                         ; preds = %for.inc20, %VITIS_LOOP_400_1
  %2 = load i8, i8* %type, align 1, !dbg !18464
  %conv = zext i8 %2 to i32, !dbg !18464
  %cmp = icmp slt i32 %conv, 3, !dbg !18466
  br i1 %cmp, label %land.rhs, label %land.end, !dbg !18467

land.rhs:                                         ; preds = %for.cond
  %call2 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18468
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %3 = phi i1 [ false, %for.cond ], [ %call2, %land.rhs ], !dbg !18469
  br i1 %3, label %for.body, label %for.cond.cleanup, !dbg !18470

for.cond.cleanup:                                 ; preds = %land.end
  store i32 3, i32* %cleanup.dest.slot, align 4
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %type) #285, !dbg !18471
  br label %for.end23

for.body:                                         ; preds = %land.end
  %4 = bitcast i1* %used to i8*, !dbg !18472
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %4) #285, !dbg !18472
  call void @llvm.dbg.declare(metadata i1* %used, metadata !18474, metadata !DIExpression()), !dbg !18475
  store i1 false, i1* %used, align 1, !dbg !18475
  br label %VITIS_LOOP_402_2, !dbg !18472

VITIS_LOOP_402_2:                                 ; preds = %for.body
  %5 = bitcast i32* %b to i8*, !dbg !18476
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %5) #285, !dbg !18476
  call void @llvm.dbg.declare(metadata i32* %b, metadata !18478, metadata !DIExpression()), !dbg !18479
  store i32 0, i32* %b, align 4, !dbg !18479
  br label %for.cond3, !dbg !18476

for.cond3:                                        ; preds = %for.inc, %VITIS_LOOP_402_2
  %6 = load i32, i32* %b, align 4, !dbg !18480
  %rt4 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18482
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt4, align 8, !dbg !18482
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %7, i32 0, i32 0, !dbg !18483
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !18484
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 2, !dbg !18485
  %8 = load i16, i16* %B, align 8, !dbg !18485
  %conv5 = zext i16 %8 to i32, !dbg !18482
  %cmp6 = icmp ult i32 %6, %conv5, !dbg !18486
  br i1 %cmp6, label %for.body8, label %for.cond.cleanup7, !dbg !18487

for.cond.cleanup7:                                ; preds = %for.cond3
  store i32 7, i32* %cleanup.dest.slot, align 4
  %9 = bitcast i32* %b to i8*, !dbg !18488
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %9) #285, !dbg !18488
  br label %for.end

for.body8:                                        ; preds = %for.cond3
  %rt9 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18489
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt9, align 8, !dbg !18489
  %inputs10 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %10, i32 0, i32 0, !dbg !18491
  %qtype = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs10, i32 0, i32 5, !dbg !18492
  %11 = load i32, i32* %b, align 4, !dbg !18493
  %idxprom = zext i32 %11 to i64, !dbg !18489
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* %qtype, i64 0, i64 %idxprom, !dbg !18489
  %12 = load i8, i8* %arrayidx, align 1, !dbg !18489
  %conv11 = zext i8 %12 to i32, !dbg !18489
  %13 = load i8, i8* %type, align 1, !dbg !18494
  %conv12 = zext i8 %13 to i32, !dbg !18494
  %cmp13 = icmp eq i32 %conv11, %conv12, !dbg !18495
  br i1 %cmp13, label %if.then14, label %if.end15, !dbg !18496

if.then14:                                        ; preds = %for.body8
  store i1 true, i1* %used, align 1, !dbg !18497
  br label %if.end15, !dbg !18498

if.end15:                                         ; preds = %if.then14, %for.body8
  br label %for.inc, !dbg !18494

for.inc:                                          ; preds = %if.end15
  %14 = load i32, i32* %b, align 4, !dbg !18499
  %inc = add i32 %14, 1, !dbg !18499
  store i32 %inc, i32* %b, align 4, !dbg !18499
  br label %for.cond3, !dbg !18488, !llvm.loop !18500

for.end:                                          ; preds = %for.cond.cleanup7
  %15 = load i1, i1* %used, align 1, !dbg !18503
  br i1 %15, label %if.end17, label %if.then16, !dbg !18505

if.then16:                                        ; preds = %for.end
  store i32 5, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !18506

if.end17:                                         ; preds = %for.end
  %16 = bitcast %"struct.laya::EmbeddingTask"* %t to i8*, !dbg !18507
  call void @llvm.lifetime.start.p0i8(i64 32, i8* %16) #285, !dbg !18507
  call void @llvm.dbg.declare(metadata %"struct.laya::EmbeddingTask"* %t, metadata !18508, metadata !DIExpression()), !dbg !18509
  call void @_ZN4laya13EmbeddingTaskC2Ev(%"struct.laya::EmbeddingTask"* nonnull align 4 dereferenceable(32) %t) #285, !dbg !18509
  %17 = bitcast %"struct.laya::TaskContext"* %ref.tmp to i8*, !dbg !18510
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %17) #285, !dbg !18510
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller7contextENS_2OpEhhhNS_8RowSpaceEth(%"struct.laya::TaskContext"* sret align 4 %ref.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 2, i8 zeroext 3, i8 zeroext -1, i8 zeroext 0, i8 zeroext 2, i16 zeroext 0, i8 zeroext 1), !dbg !18510
  %ctx = getelementptr inbounds %"struct.laya::EmbeddingTask", %"struct.laya::EmbeddingTask"* %t, i32 0, i32 0, !dbg !18511
  %18 = load %"struct.laya::TaskContext", %"struct.laya::TaskContext"* %ref.tmp, align 4, !dbg !18512
  store %"struct.laya::TaskContext" %18, %"struct.laya::TaskContext"* %ctx, align 4, !dbg !18512
  %19 = bitcast %"struct.laya::TaskContext"* %ref.tmp to i8*, !dbg !18513
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %19) #285, !dbg !18513
  %table = getelementptr inbounds %"struct.laya::EmbeddingTask", %"struct.laya::EmbeddingTask"* %t, i32 0, i32 1, !dbg !18514
  store i8 1, i8* %table, align 4, !dbg !18515
  %ref18 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %types, i32 0, i32 0, !dbg !18516
  %dst = getelementptr inbounds %"struct.laya::EmbeddingTask", %"struct.laya::EmbeddingTask"* %t, i32 0, i32 2, !dbg !18517
  %20 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref18, align 4, !dbg !18518
  store %"struct.laya::BufferRef" %20, %"struct.laya::BufferRef"* %dst, align 4, !dbg !18518
  %21 = load i8, i8* %type, align 1, !dbg !18519
  %type_id = getelementptr inbounds %"struct.laya::EmbeddingTask", %"struct.laya::EmbeddingTask"* %t, i32 0, i32 3, !dbg !18520
  store i8 %21, i8* %type_id, align 4, !dbg !18521
  %22 = bitcast %"struct.laya::Check"* %ref.tmp19 to i8*, !dbg !18522
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %22) #285, !dbg !18522
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5issueINS_13EmbeddingTaskEEENS_5CheckERKT_jNS_10OutputUnitE(%"struct.laya::Check"* sret align 8 %ref.tmp19, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, %"struct.laya::EmbeddingTask"* nonnull align 4 dereferenceable(32) %t, i32 1024, i8 zeroext 1), !dbg !18522
  %23 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp19, align 8, !dbg !18523
  store %"struct.laya::Check" %23, %"struct.laya::Check"* %agg.result, align 8, !dbg !18523
  %24 = bitcast %"struct.laya::Check"* %ref.tmp19 to i8*, !dbg !18524
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %24) #285, !dbg !18524
  %25 = bitcast %"struct.laya::EmbeddingTask"* %t to i8*, !dbg !18525
  call void @llvm.lifetime.end.p0i8(i64 32, i8* %25) #285, !dbg !18525
  store i32 0, i32* %cleanup.dest.slot, align 4, !dbg !18525
  br label %cleanup, !dbg !18525

cleanup:                                          ; preds = %if.end17, %if.then16
  %26 = bitcast i1* %used to i8*, !dbg !18525
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %26) #285, !dbg !18525
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 0, label %cleanup.cont
    i32 5, label %for.inc20
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %for.inc20, !dbg !18526

for.inc20:                                        ; preds = %cleanup.cont, %cleanup
  %27 = load i8, i8* %type, align 1, !dbg !18527
  %inc21 = add i8 %27, 1, !dbg !18527
  store i8 %inc21, i8* %type, align 1, !dbg !18527
  br label %for.cond, !dbg !18471, !llvm.loop !18528

for.end23:                                        ; preds = %for.cond.cleanup
  %call24 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18531
  br i1 %call24, label %if.end26, label %if.then25, !dbg !18533

if.then25:                                        ; preds = %for.end23
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup45, !dbg !18534

if.end26:                                         ; preds = %for.end23
  %28 = bitcast %"struct.laya::full::FullOwnerSpec"* %next to i8*, !dbg !18535
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %28) #285, !dbg !18535
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %next, metadata !18536, metadata !DIExpression()), !dbg !18537
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %next) #285, !dbg !18537
  %29 = bitcast %"struct.laya::Check"* %ref.tmp27 to i8*, !dbg !18538
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %29) #285, !dbg !18538
  %30 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18539
  %31 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18540
  %ref28 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %31, i32 0, i32 0, !dbg !18541
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref28, i32 0, i32 1, !dbg !18542
  %32 = load i8, i8* %bank, align 1, !dbg !18542
  %conv29 = zext i8 %32 to i32, !dbg !18540
  %sub = sub nsw i32 1, %conv29, !dbg !18543
  %conv30 = trunc i32 %sub to i8, !dbg !18544
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 1, i8 zeroext %conv30, i8 zeroext 0), !dbg !18545
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6vectorENS_2OpERKNS0_13FullOwnerSpecEPS5_hhNS_9BufferRefEhtRS4_(%"struct.laya::Check"* sret align 8 %ref.tmp27, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 99, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %30, %"struct.laya::full::FullOwnerSpec"* %types, i8 zeroext 3, i8 zeroext -1, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0, i16 zeroext 1024, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %next), !dbg !18538
  %33 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp27, align 8, !dbg !18546
  store %"struct.laya::Check" %33, %"struct.laya::Check"* %agg.result, align 8, !dbg !18546
  %34 = bitcast %"struct.laya::Check"* %ref.tmp27 to i8*, !dbg !18547
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %34) #285, !dbg !18547
  %call31 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18548
  br i1 %call31, label %if.then32, label %if.end35, !dbg !18550

if.then32:                                        ; preds = %if.end26
  %35 = bitcast %"struct.laya::Check"* %ref.tmp33 to i8*, !dbg !18551
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %35) #285, !dbg !18551
  %rt34 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18552
  %36 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt34, align 8, !dbg !18552
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp33, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %36, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %types), !dbg !18551
  %37 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp33, align 8, !dbg !18553
  store %"struct.laya::Check" %37, %"struct.laya::Check"* %agg.result, align 8, !dbg !18553
  %38 = bitcast %"struct.laya::Check"* %ref.tmp33 to i8*, !dbg !18554
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %38) #285, !dbg !18554
  br label %if.end35, !dbg !18554

if.end35:                                         ; preds = %if.then32, %if.end26
  %call36 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18555
  br i1 %call36, label %if.then37, label %if.end40, !dbg !18557

if.then37:                                        ; preds = %if.end35
  %39 = bitcast %"struct.laya::Check"* %ref.tmp38 to i8*, !dbg !18558
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %39) #285, !dbg !18558
  %rt39 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18559
  %40 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt39, align 8, !dbg !18559
  %41 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18560
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp38, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %40, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %41), !dbg !18558
  %42 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp38, align 8, !dbg !18561
  store %"struct.laya::Check" %42, %"struct.laya::Check"* %agg.result, align 8, !dbg !18561
  %43 = bitcast %"struct.laya::Check"* %ref.tmp38 to i8*, !dbg !18562
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %43) #285, !dbg !18562
  br label %if.end40, !dbg !18562

if.end40:                                         ; preds = %if.then37, %if.end35
  %call41 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18563
  br i1 %call41, label %if.then42, label %if.end43, !dbg !18565

if.then42:                                        ; preds = %if.end40
  %44 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18566
  %45 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %next, align 4, !dbg !18568
  store %"struct.laya::full::FullOwnerSpec" %45, %"struct.laya::full::FullOwnerSpec"* %44, align 4, !dbg !18568
  %46 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18569
  call void @_ZN4laya4full12_GLOBAL__N_110Controller10checkpointEPKcRKNS0_13FullOwnerSpecE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.14, i64 0, i64 0), %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %46), !dbg !18570
  br label %if.end43, !dbg !18571

if.end43:                                         ; preds = %if.then42, %if.end40
  store i32 1, i32* %cleanup.dest.slot, align 4
  %47 = bitcast %"struct.laya::full::FullOwnerSpec"* %next to i8*, !dbg !18572
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %47) #285, !dbg !18572
  br label %cleanup45

cleanup45:                                        ; preds = %if.end43, %if.then25, %if.then
  %48 = bitcast %"struct.laya::full::FullOwnerSpec"* %types to i8*, !dbg !18572
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %48) #285, !dbg !18572
  ret void, !dbg !18572

unreachable:                                      ; preds = %cleanup
  unreachable
}
