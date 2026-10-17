define dso_local void @_ZN4laya4full19full_claim_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %s) #210 !dbg !38511 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %__range2 = alloca [2 x [3 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end2 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range3 = alloca [3 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end3 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range4 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin4 = alloca [2 x [32 x i32]]*, align 8
  %__end4 = alloca [2 x [32 x i32]]*, align 8
  %head = alloca [2 x [32 x i32]]*, align 8
  %__range5 = alloca [2 x [32 x i32]]*, align 8
  %__begin5 = alloca [32 x i32]*, align 8
  %__end5 = alloca [32 x i32]*, align 8
  %batch = alloca [32 x i32]*, align 8
  %__range6 = alloca [32 x i32]*, align 8
  %__begin6 = alloca i32*, align 8
  %__end6 = alloca i32*, align 8
  %word = alloca i32*, align 8
  %__range274 = alloca [2 x [2 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin276 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end278 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard85 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range386 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__begin387 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__end389 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %plane96 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__range497 = alloca [16 x [2 x [32 x i32]]]*, align 8
  %__begin498 = alloca [2 x [32 x i32]]*, align 8
  %__end4100 = alloca [2 x [32 x i32]]*, align 8
  %head107 = alloca [2 x [32 x i32]]*, align 8
  %__range5108 = alloca [2 x [32 x i32]]*, align 8
  %__begin5109 = alloca [32 x i32]*, align 8
  %__end5111 = alloca [32 x i32]*, align 8
  %batch118 = alloca [32 x i32]*, align 8
  %__range6119 = alloca [32 x i32]*, align 8
  %__begin6120 = alloca i32*, align 8
  %__end6122 = alloca i32*, align 8
  %word129 = alloca i32*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !38512, metadata !DIExpression()), !dbg !38513
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %s, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, metadata !38514, metadata !DIExpression()), !dbg !38515
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38516
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !38518
  %1 = load i1, i1* %request_valid, align 8, !dbg !38518
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !38519

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38520
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !38521
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !38521
  br i1 %3, label %lor.lhs.false1, label %if.then, !dbg !38522

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38523
  %5 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !38524
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %4, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %5), !dbg !38525
  br i1 %call, label %if.end, label %if.then, !dbg !38526

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 5), !dbg !38527
  br label %return, !dbg !38528

if.end:                                           ; preds = %lor.lhs.false1
  %6 = bitcast i32* %first to i8*, !dbg !38529
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #285, !dbg !38529
  call void @llvm.dbg.declare(metadata i32* %first, metadata !38530, metadata !DIExpression()), !dbg !38531
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38532
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !38533
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !38533
  %call2 = call i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %7, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx), !dbg !38534
  store i32 %call2, i32* %first, align 4, !dbg !38531
  %9 = bitcast i32* %second to i8*, !dbg !38535
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %9) #285, !dbg !38535
  call void @llvm.dbg.declare(metadata i32* %second, metadata !38536, metadata !DIExpression()), !dbg !38537
  %10 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38538
  %11 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !38539
  %arrayidx3 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %11, i64 0, i64 1, !dbg !38539
  %call4 = call i32 @_ZN4laya4full12_GLOBAL__N_111claim_indexERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %10, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx3), !dbg !38540
  store i32 %call4, i32* %second, align 4, !dbg !38537
  %12 = load i32, i32* %first, align 4, !dbg !38541
  %cmp = icmp ne i32 %12, 32, !dbg !38543
  br i1 %cmp, label %land.lhs.true, label %if.end11, !dbg !38544

land.lhs.true:                                    ; preds = %if.end
  %13 = load i32, i32* %second, align 4, !dbg !38545
  %14 = load i32, i32* %first, align 4, !dbg !38546
  %cmp5 = icmp eq i32 %13, %14, !dbg !38547
  br i1 %cmp5, label %land.lhs.true6, label %if.end11, !dbg !38548

land.lhs.true6:                                   ; preds = %land.lhs.true
  %15 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38549
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %15, i32 0, i32 1, !dbg !38550
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !38551
  %16 = load i32, i32* %first, align 4, !dbg !38552
  %idxprom = zext i32 %16 to i64, !dbg !38549
  %arrayidx7 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !38549
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %arrayidx7, i32 0, i32 1, !dbg !38553
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !38554
  %17 = load i8, i8* %id, align 8, !dbg !38554
  %cmp8 = icmp eq i8 %17, 0, !dbg !38555
  br i1 %cmp8, label %if.then9, label %if.end11, !dbg !38556

if.then9:                                         ; preds = %land.lhs.true6
  %18 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38557
  %19 = load i32, i32* %first, align 4, !dbg !38558
  %call10 = call i32 @_ZN4laya4full12_GLOBAL__N_111empty_indexERKNS0_11FullRuntimeEj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %18, i32 %19), !dbg !38559
  store i32 %call10, i32* %second, align 4, !dbg !38560
  br label %if.end11, !dbg !38561

if.end11:                                         ; preds = %if.then9, %land.lhs.true6, %land.lhs.true, %if.end
  %20 = load i32, i32* %first, align 4, !dbg !38562
  %cmp12 = icmp eq i32 %20, 32, !dbg !38564
  br i1 %cmp12, label %if.then17, label %lor.lhs.false13, !dbg !38565

lor.lhs.false13:                                  ; preds = %if.end11
  %21 = load i32, i32* %second, align 4, !dbg !38566
  %cmp14 = icmp eq i32 %21, 32, !dbg !38567
  br i1 %cmp14, label %if.then17, label %lor.lhs.false15, !dbg !38568

lor.lhs.false15:                                  ; preds = %lor.lhs.false13
  %22 = load i32, i32* %first, align 4, !dbg !38569
  %23 = load i32, i32* %second, align 4, !dbg !38570
  %cmp16 = icmp eq i32 %22, %23, !dbg !38571
  br i1 %cmp16, label %if.then17, label %if.end18, !dbg !38572

if.then17:                                        ; preds = %lor.lhs.false15, %lor.lhs.false13, %if.end11
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !38573
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !38574

if.end18:                                         ; preds = %lor.lhs.false15
  %24 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38575
  %owners19 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %24, i32 0, i32 1, !dbg !38576
  %record20 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners19, i32 0, i32 0, !dbg !38577
  %25 = load i32, i32* %first, align 4, !dbg !38578
  %idxprom21 = zext i32 %25 to i64, !dbg !38575
  %arrayidx22 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record20, i64 0, i64 %idxprom21, !dbg !38575
  %26 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !38579
  %arrayidx23 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %26, i64 0, i64 0, !dbg !38579
  %27 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38580
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %27, i32 0, i32 0, !dbg !38581
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !38582
  call void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %arrayidx22, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx23, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity), !dbg !38583
  %28 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38584
  %owners24 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %28, i32 0, i32 1, !dbg !38585
  %record25 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners24, i32 0, i32 0, !dbg !38586
  %29 = load i32, i32* %second, align 4, !dbg !38587
  %idxprom26 = zext i32 %29 to i64, !dbg !38584
  %arrayidx27 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record25, i64 0, i64 %idxprom26, !dbg !38584
  %30 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !38588
  %arrayidx28 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %30, i64 0, i64 1, !dbg !38588
  %31 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38589
  %inputs29 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %31, i32 0, i32 0, !dbg !38590
  %identity30 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs29, i32 0, i32 0, !dbg !38591
  call void @_ZN4laya4full12_GLOBAL__N_111fill_recordERNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecERKNS_15NumericIdentityE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %arrayidx27, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx28, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity30), !dbg !38592
  %32 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38593
  %owner_claims = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %32, i32 0, i32 27, !dbg !38594
  %33 = load i32, i32* %owner_claims, align 8, !dbg !38595
  %add = add i32 %33, 2, !dbg !38595
  store i32 %add, i32* %owner_claims, align 8, !dbg !38595
  br label %VITIS_LOOP_272_1, !dbg !38593

VITIS_LOOP_272_1:                                 ; preds = %if.end18
  %34 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !38596
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %34) #285, !dbg !38596
  call void @llvm.dbg.declare(metadata [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, metadata !38598, metadata !DIExpression()), !dbg !38600
  %35 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38596
  %owners31 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %35, i32 0, i32 1, !dbg !38601
  %qkv_plane_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners31, i32 0, i32 1, !dbg !38602
  store [2 x [3 x [16 x [2 x [32 x i32]]]]]* %qkv_plane_head_rows, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !38596
  %36 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !38603
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %36) #285, !dbg !38603
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__begin2, metadata !38604, metadata !DIExpression()), !dbg !38600
  %37 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !38603
  %arraydecay = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %37, i64 0, i64 0, !dbg !38603
  store [3 x [16 x [2 x [32 x i32]]]]* %arraydecay, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !38603
  %38 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !38603
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %38) #285, !dbg !38603
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__end2, metadata !38608, metadata !DIExpression()), !dbg !38600
  %39 = load [2 x [3 x [16 x [2 x [32 x i32]]]]]*, [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !38603
  %arraydecay32 = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %39, i64 0, i64 0, !dbg !38603
  %add.ptr = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %arraydecay32, i64 2, !dbg !38603
  store [3 x [16 x [2 x [32 x i32]]]]* %add.ptr, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !38603
  br label %for.cond, !dbg !38603

for.cond:                                         ; preds = %for.inc71, %VITIS_LOOP_272_1
  %40 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !38603
  %41 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !38603
  %cmp33 = icmp ne [3 x [16 x [2 x [32 x i32]]]]* %40, %41, !dbg !38603
  br i1 %cmp33, label %for.body, label %for.cond.cleanup, !dbg !38603

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %42 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !38603
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %42) #285, !dbg !38603
  %43 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !38603
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %43) #285, !dbg !38603
  %44 = bitcast [2 x [3 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !38603
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %44) #285, !dbg !38603
  br label %for.end73

for.body:                                         ; preds = %for.cond
  %45 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !38609
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %45) #285, !dbg !38609
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %shard, metadata !38611, metadata !DIExpression()), !dbg !38613
  %46 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !38614
  store [3 x [16 x [2 x [32 x i32]]]]* %46, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !38613
  br label %VITIS_LOOP_273_2, !dbg !38609

VITIS_LOOP_273_2:                                 ; preds = %for.body
  %47 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !38615
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %47) #285, !dbg !38615
  call void @llvm.dbg.declare(metadata [3 x [16 x [2 x [32 x i32]]]]** %__range3, metadata !38617, metadata !DIExpression()), !dbg !38618
  %48 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !38615
  store [3 x [16 x [2 x [32 x i32]]]]* %48, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !38615
  %49 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !38619
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %49) #285, !dbg !38619
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin3, metadata !38620, metadata !DIExpression()), !dbg !38618
  %50 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !38619
  %arraydecay34 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %50, i64 0, i64 0, !dbg !38619
  store [16 x [2 x [32 x i32]]]* %arraydecay34, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !38619
  %51 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !38619
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %51) #285, !dbg !38619
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end3, metadata !38621, metadata !DIExpression()), !dbg !38618
  %52 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !38619
  %arraydecay35 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %52, i64 0, i64 0, !dbg !38619
  %add.ptr36 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay35, i64 3, !dbg !38619
  store [16 x [2 x [32 x i32]]]* %add.ptr36, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !38619
  br label %for.cond37, !dbg !38619

for.cond37:                                       ; preds = %for.inc68, %VITIS_LOOP_273_2
  %53 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !38619
  %54 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !38619
  %cmp38 = icmp ne [16 x [2 x [32 x i32]]]* %53, %54, !dbg !38619
  br i1 %cmp38, label %for.body40, label %for.cond.cleanup39, !dbg !38619

for.cond.cleanup39:                               ; preds = %for.cond37
  store i32 6, i32* %cleanup.dest.slot, align 4
  %55 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !38619
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %55) #285, !dbg !38619
  %56 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !38619
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %56) #285, !dbg !38619
  %57 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !38619
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %57) #285, !dbg !38619
  br label %for.end70

for.body40:                                       ; preds = %for.cond37
  %58 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !38622
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %58) #285, !dbg !38622
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane, metadata !38624, metadata !DIExpression()), !dbg !38625
  %59 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !38626
  store [16 x [2 x [32 x i32]]]* %59, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !38625
  br label %VITIS_LOOP_274_3, !dbg !38622

VITIS_LOOP_274_3:                                 ; preds = %for.body40
  %60 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !38627
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %60) #285, !dbg !38627
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range4, metadata !38629, metadata !DIExpression()), !dbg !38630
  %61 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !38627
  store [16 x [2 x [32 x i32]]]* %61, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !38627
  %62 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !38631
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %62) #285, !dbg !38631
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin4, metadata !38632, metadata !DIExpression()), !dbg !38630
  %63 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !38631
  %arraydecay41 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %63, i64 0, i64 0, !dbg !38631
  store [2 x [32 x i32]]* %arraydecay41, [2 x [32 x i32]]** %__begin4, align 8, !dbg !38631
  %64 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !38631
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %64) #285, !dbg !38631
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4, metadata !38633, metadata !DIExpression()), !dbg !38630
  %65 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !38631
  %arraydecay42 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %65, i64 0, i64 0, !dbg !38631
  %add.ptr43 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay42, i64 16, !dbg !38631
  store [2 x [32 x i32]]* %add.ptr43, [2 x [32 x i32]]** %__end4, align 8, !dbg !38631
  br label %for.cond44, !dbg !38631

for.cond44:                                       ; preds = %for.inc65, %VITIS_LOOP_274_3
  %66 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !38631
  %67 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4, align 8, !dbg !38631
  %cmp45 = icmp ne [2 x [32 x i32]]* %66, %67, !dbg !38631
  br i1 %cmp45, label %for.body47, label %for.cond.cleanup46, !dbg !38631

for.cond.cleanup46:                               ; preds = %for.cond44
  store i32 9, i32* %cleanup.dest.slot, align 4
  %68 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !38631
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %68) #285, !dbg !38631
  %69 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !38631
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %69) #285, !dbg !38631
  %70 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !38631
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %70) #285, !dbg !38631
  br label %for.end67

for.body47:                                       ; preds = %for.cond44
  %71 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !38634
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %71) #285, !dbg !38634
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head, metadata !38636, metadata !DIExpression()), !dbg !38637
  %72 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !38638
  store [2 x [32 x i32]]* %72, [2 x [32 x i32]]** %head, align 8, !dbg !38637
  br label %VITIS_LOOP_275_4, !dbg !38634

VITIS_LOOP_275_4:                                 ; preds = %for.body47
  %73 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !38639
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %73) #285, !dbg !38639
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5, metadata !38641, metadata !DIExpression()), !dbg !38642
  %74 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head, align 8, !dbg !38639
  store [2 x [32 x i32]]* %74, [2 x [32 x i32]]** %__range5, align 8, !dbg !38639
  %75 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !38643
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %75) #285, !dbg !38643
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5, metadata !38644, metadata !DIExpression()), !dbg !38642
  %76 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !38643
  %arraydecay48 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %76, i64 0, i64 0, !dbg !38643
  store [32 x i32]* %arraydecay48, [32 x i32]** %__begin5, align 8, !dbg !38643
  %77 = bitcast [32 x i32]** %__end5 to i8*, !dbg !38643
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %77) #285, !dbg !38643
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5, metadata !38645, metadata !DIExpression()), !dbg !38642
  %78 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !38643
  %arraydecay49 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %78, i64 0, i64 0, !dbg !38643
  %add.ptr50 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay49, i64 2, !dbg !38643
  store [32 x i32]* %add.ptr50, [32 x i32]** %__end5, align 8, !dbg !38643
  br label %for.cond51, !dbg !38643

for.cond51:                                       ; preds = %for.inc62, %VITIS_LOOP_275_4
  %79 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !38643
  %80 = load [32 x i32]*, [32 x i32]** %__end5, align 8, !dbg !38643
  %cmp52 = icmp ne [32 x i32]* %79, %80, !dbg !38643
  br i1 %cmp52, label %for.body54, label %for.cond.cleanup53, !dbg !38643

for.cond.cleanup53:                               ; preds = %for.cond51
  store i32 12, i32* %cleanup.dest.slot, align 4
  %81 = bitcast [32 x i32]** %__end5 to i8*, !dbg !38643
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %81) #285, !dbg !38643
  %82 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !38643
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %82) #285, !dbg !38643
  %83 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !38643
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %83) #285, !dbg !38643
  br label %for.end64

for.body54:                                       ; preds = %for.cond51
  %84 = bitcast [32 x i32]** %batch to i8*, !dbg !38646
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %84) #285, !dbg !38646
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch, metadata !38648, metadata !DIExpression()), !dbg !38649
  %85 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !38650
  store [32 x i32]* %85, [32 x i32]** %batch, align 8, !dbg !38649
  br label %VITIS_LOOP_276_5, !dbg !38646

VITIS_LOOP_276_5:                                 ; preds = %for.body54
  %86 = bitcast [32 x i32]** %__range6 to i8*, !dbg !38651
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %86) #285, !dbg !38651
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6, metadata !38653, metadata !DIExpression()), !dbg !38654
  %87 = load [32 x i32]*, [32 x i32]** %batch, align 8, !dbg !38651
  store [32 x i32]* %87, [32 x i32]** %__range6, align 8, !dbg !38651
  %88 = bitcast i32** %__begin6 to i8*, !dbg !38655
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %88) #285, !dbg !38655
  call void @llvm.dbg.declare(metadata i32** %__begin6, metadata !38656, metadata !DIExpression()), !dbg !38654
  %89 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !38655
  %arraydecay55 = getelementptr inbounds [32 x i32], [32 x i32]* %89, i64 0, i64 0, !dbg !38655
  store i32* %arraydecay55, i32** %__begin6, align 8, !dbg !38655
  %90 = bitcast i32** %__end6 to i8*, !dbg !38655
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %90) #285, !dbg !38655
  call void @llvm.dbg.declare(metadata i32** %__end6, metadata !38657, metadata !DIExpression()), !dbg !38654
  %91 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !38655
  %arraydecay56 = getelementptr inbounds [32 x i32], [32 x i32]* %91, i64 0, i64 0, !dbg !38655
  %add.ptr57 = getelementptr inbounds i32, i32* %arraydecay56, i64 32, !dbg !38655
  store i32* %add.ptr57, i32** %__end6, align 8, !dbg !38655
  br label %for.cond58, !dbg !38655

for.cond58:                                       ; preds = %for.inc, %VITIS_LOOP_276_5
  %92 = load i32*, i32** %__begin6, align 8, !dbg !38655
  %93 = load i32*, i32** %__end6, align 8, !dbg !38655
  %cmp59 = icmp ne i32* %92, %93, !dbg !38655
  br i1 %cmp59, label %for.body61, label %for.cond.cleanup60, !dbg !38655

for.cond.cleanup60:                               ; preds = %for.cond58
  store i32 15, i32* %cleanup.dest.slot, align 4
  %94 = bitcast i32** %__end6 to i8*, !dbg !38655
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %94) #285, !dbg !38655
  %95 = bitcast i32** %__begin6 to i8*, !dbg !38655
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %95) #285, !dbg !38655
  %96 = bitcast [32 x i32]** %__range6 to i8*, !dbg !38655
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %96) #285, !dbg !38655
  br label %for.end

for.body61:                                       ; preds = %for.cond58
  %97 = bitcast i32** %word to i8*, !dbg !38658
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %97) #285, !dbg !38658
  call void @llvm.dbg.declare(metadata i32** %word, metadata !38660, metadata !DIExpression()), !dbg !38661
  %98 = load i32*, i32** %__begin6, align 8, !dbg !38662
  store i32* %98, i32** %word, align 8, !dbg !38661
  %99 = load i32*, i32** %word, align 8, !dbg !38663
  store i32 0, i32* %99, align 4, !dbg !38664
  %100 = bitcast i32** %word to i8*, !dbg !38665
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %100) #285, !dbg !38665
  br label %for.inc, !dbg !38666

for.inc:                                          ; preds = %for.body61
  %101 = load i32*, i32** %__begin6, align 8, !dbg !38655
  %incdec.ptr = getelementptr inbounds i32, i32* %101, i32 1, !dbg !38655
  store i32* %incdec.ptr, i32** %__begin6, align 8, !dbg !38655
  br label %for.cond58, !dbg !38655, !llvm.loop !38667

for.end:                                          ; preds = %for.cond.cleanup60
  %102 = bitcast [32 x i32]** %batch to i8*, !dbg !38669
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %102) #285, !dbg !38669
  br label %for.inc62, !dbg !38670

for.inc62:                                        ; preds = %for.end
  %103 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !38643
  %incdec.ptr63 = getelementptr inbounds [32 x i32], [32 x i32]* %103, i32 1, !dbg !38643
  store [32 x i32]* %incdec.ptr63, [32 x i32]** %__begin5, align 8, !dbg !38643
  br label %for.cond51, !dbg !38643, !llvm.loop !38671

for.end64:                                        ; preds = %for.cond.cleanup53
  %104 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !38673
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %104) #285, !dbg !38673
  br label %for.inc65, !dbg !38674

for.inc65:                                        ; preds = %for.end64
  %105 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !38631
  %incdec.ptr66 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %105, i32 1, !dbg !38631
  store [2 x [32 x i32]]* %incdec.ptr66, [2 x [32 x i32]]** %__begin4, align 8, !dbg !38631
  br label %for.cond44, !dbg !38631, !llvm.loop !38675

for.end67:                                        ; preds = %for.cond.cleanup46
  %106 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !38677
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %106) #285, !dbg !38677
  br label %for.inc68, !dbg !38678

for.inc68:                                        ; preds = %for.end67
  %107 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !38619
  %incdec.ptr69 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %107, i32 1, !dbg !38619
  store [16 x [2 x [32 x i32]]]* %incdec.ptr69, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !38619
  br label %for.cond37, !dbg !38619, !llvm.loop !38679

for.end70:                                        ; preds = %for.cond.cleanup39
  %108 = bitcast [3 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !38681
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %108) #285, !dbg !38681
  br label %for.inc71, !dbg !38682

for.inc71:                                        ; preds = %for.end70
  %109 = load [3 x [16 x [2 x [32 x i32]]]]*, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !38603
  %incdec.ptr72 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %109, i32 1, !dbg !38603
  store [3 x [16 x [2 x [32 x i32]]]]* %incdec.ptr72, [3 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !38603
  br label %for.cond, !dbg !38603, !llvm.loop !38683

for.end73:                                        ; preds = %for.cond.cleanup
  br label %VITIS_LOOP_277_6, !dbg !38681

VITIS_LOOP_277_6:                                 ; preds = %for.end73
  %110 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274 to i8*, !dbg !38684
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %110) #285, !dbg !38684
  call void @llvm.dbg.declare(metadata [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, metadata !38686, metadata !DIExpression()), !dbg !38687
  %111 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !38684
  %owners75 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %111, i32 0, i32 1, !dbg !38688
  %qkv_rope_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners75, i32 0, i32 2, !dbg !38689
  store [2 x [2 x [16 x [2 x [32 x i32]]]]]* %qkv_rope_rows, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !38684
  %112 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin276 to i8*, !dbg !38690
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %112) #285, !dbg !38690
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__begin276, metadata !38691, metadata !DIExpression()), !dbg !38687
  %113 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !38690
  %arraydecay77 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %113, i64 0, i64 0, !dbg !38690
  store [2 x [16 x [2 x [32 x i32]]]]* %arraydecay77, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !38690
  %114 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end278 to i8*, !dbg !38690
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %114) #285, !dbg !38690
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__end278, metadata !38692, metadata !DIExpression()), !dbg !38687
  %115 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274, align 8, !dbg !38690
  %arraydecay79 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %115, i64 0, i64 0, !dbg !38690
  %add.ptr80 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %arraydecay79, i64 2, !dbg !38690
  store [2 x [16 x [2 x [32 x i32]]]]* %add.ptr80, [2 x [16 x [2 x [32 x i32]]]]** %__end278, align 8, !dbg !38690
  br label %for.cond81, !dbg !38690

for.cond81:                                       ; preds = %for.inc142, %VITIS_LOOP_277_6
  %116 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !38690
  %117 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__end278, align 8, !dbg !38690
  %cmp82 = icmp ne [2 x [16 x [2 x [32 x i32]]]]* %116, %117, !dbg !38690
  br i1 %cmp82, label %for.body84, label %for.cond.cleanup83, !dbg !38690

for.cond.cleanup83:                               ; preds = %for.cond81
  store i32 18, i32* %cleanup.dest.slot, align 4
  %118 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end278 to i8*, !dbg !38690
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %118) #285, !dbg !38690
  %119 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin276 to i8*, !dbg !38690
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %119) #285, !dbg !38690
  %120 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range274 to i8*, !dbg !38690
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %120) #285, !dbg !38690
  br label %for.end144

for.body84:                                       ; preds = %for.cond81
  %121 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard85 to i8*, !dbg !38693
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %121) #285, !dbg !38693
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %shard85, metadata !38695, metadata !DIExpression()), !dbg !38696
  %122 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !38697
  store [2 x [16 x [2 x [32 x i32]]]]* %122, [2 x [16 x [2 x [32 x i32]]]]** %shard85, align 8, !dbg !38696
  br label %VITIS_LOOP_278_7, !dbg !38693

VITIS_LOOP_278_7:                                 ; preds = %for.body84
  %123 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range386 to i8*, !dbg !38698
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %123) #285, !dbg !38698
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__range386, metadata !38700, metadata !DIExpression()), !dbg !38701
  %124 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %shard85, align 8, !dbg !38698
  store [2 x [16 x [2 x [32 x i32]]]]* %124, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !38698
  %125 = bitcast [16 x [2 x [32 x i32]]]** %__begin387 to i8*, !dbg !38702
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %125) #285, !dbg !38702
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin387, metadata !38703, metadata !DIExpression()), !dbg !38701
  %126 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !38702
  %arraydecay88 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %126, i64 0, i64 0, !dbg !38702
  store [16 x [2 x [32 x i32]]]* %arraydecay88, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !38702
  %127 = bitcast [16 x [2 x [32 x i32]]]** %__end389 to i8*, !dbg !38702
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %127) #285, !dbg !38702
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end389, metadata !38704, metadata !DIExpression()), !dbg !38701
  %128 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range386, align 8, !dbg !38702
  %arraydecay90 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %128, i64 0, i64 0, !dbg !38702
  %add.ptr91 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay90, i64 2, !dbg !38702
  store [16 x [2 x [32 x i32]]]* %add.ptr91, [16 x [2 x [32 x i32]]]** %__end389, align 8, !dbg !38702
  br label %for.cond92, !dbg !38702

for.cond92:                                       ; preds = %for.inc139, %VITIS_LOOP_278_7
  %129 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !38702
  %130 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end389, align 8, !dbg !38702
  %cmp93 = icmp ne [16 x [2 x [32 x i32]]]* %129, %130, !dbg !38702
  br i1 %cmp93, label %for.body95, label %for.cond.cleanup94, !dbg !38702

for.cond.cleanup94:                               ; preds = %for.cond92
  store i32 21, i32* %cleanup.dest.slot, align 4
  %131 = bitcast [16 x [2 x [32 x i32]]]** %__end389 to i8*, !dbg !38702
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %131) #285, !dbg !38702
  %132 = bitcast [16 x [2 x [32 x i32]]]** %__begin387 to i8*, !dbg !38702
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %132) #285, !dbg !38702
  %133 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range386 to i8*, !dbg !38702
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %133) #285, !dbg !38702
  br label %for.end141

for.body95:                                       ; preds = %for.cond92
  %134 = bitcast [16 x [2 x [32 x i32]]]** %plane96 to i8*, !dbg !38705
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %134) #285, !dbg !38705
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane96, metadata !38707, metadata !DIExpression()), !dbg !38708
  %135 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !38709
  store [16 x [2 x [32 x i32]]]* %135, [16 x [2 x [32 x i32]]]** %plane96, align 8, !dbg !38708
  br label %VITIS_LOOP_279_8, !dbg !38705

VITIS_LOOP_279_8:                                 ; preds = %for.body95
  %136 = bitcast [16 x [2 x [32 x i32]]]** %__range497 to i8*, !dbg !38710
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %136) #285, !dbg !38710
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range497, metadata !38712, metadata !DIExpression()), !dbg !38713
  %137 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane96, align 8, !dbg !38710
  store [16 x [2 x [32 x i32]]]* %137, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !38710
  %138 = bitcast [2 x [32 x i32]]** %__begin498 to i8*, !dbg !38714
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %138) #285, !dbg !38714
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin498, metadata !38715, metadata !DIExpression()), !dbg !38713
  %139 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !38714
  %arraydecay99 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %139, i64 0, i64 0, !dbg !38714
  store [2 x [32 x i32]]* %arraydecay99, [2 x [32 x i32]]** %__begin498, align 8, !dbg !38714
  %140 = bitcast [2 x [32 x i32]]** %__end4100 to i8*, !dbg !38714
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %140) #285, !dbg !38714
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4100, metadata !38716, metadata !DIExpression()), !dbg !38713
  %141 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range497, align 8, !dbg !38714
  %arraydecay101 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %141, i64 0, i64 0, !dbg !38714
  %add.ptr102 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay101, i64 16, !dbg !38714
  store [2 x [32 x i32]]* %add.ptr102, [2 x [32 x i32]]** %__end4100, align 8, !dbg !38714
  br label %for.cond103, !dbg !38714

for.cond103:                                      ; preds = %for.inc136, %VITIS_LOOP_279_8
  %142 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !38714
  %143 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4100, align 8, !dbg !38714
  %cmp104 = icmp ne [2 x [32 x i32]]* %142, %143, !dbg !38714
  br i1 %cmp104, label %for.body106, label %for.cond.cleanup105, !dbg !38714

for.cond.cleanup105:                              ; preds = %for.cond103
  store i32 24, i32* %cleanup.dest.slot, align 4
  %144 = bitcast [2 x [32 x i32]]** %__end4100 to i8*, !dbg !38714
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %144) #285, !dbg !38714
  %145 = bitcast [2 x [32 x i32]]** %__begin498 to i8*, !dbg !38714
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %145) #285, !dbg !38714
  %146 = bitcast [16 x [2 x [32 x i32]]]** %__range497 to i8*, !dbg !38714
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %146) #285, !dbg !38714
  br label %for.end138

for.body106:                                      ; preds = %for.cond103
  %147 = bitcast [2 x [32 x i32]]** %head107 to i8*, !dbg !38717
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %147) #285, !dbg !38717
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head107, metadata !38719, metadata !DIExpression()), !dbg !38720
  %148 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !38721
  store [2 x [32 x i32]]* %148, [2 x [32 x i32]]** %head107, align 8, !dbg !38720
  br label %VITIS_LOOP_280_9, !dbg !38717

VITIS_LOOP_280_9:                                 ; preds = %for.body106
  %149 = bitcast [2 x [32 x i32]]** %__range5108 to i8*, !dbg !38722
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %149) #285, !dbg !38722
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5108, metadata !38724, metadata !DIExpression()), !dbg !38725
  %150 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head107, align 8, !dbg !38722
  store [2 x [32 x i32]]* %150, [2 x [32 x i32]]** %__range5108, align 8, !dbg !38722
  %151 = bitcast [32 x i32]** %__begin5109 to i8*, !dbg !38726
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %151) #285, !dbg !38726
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5109, metadata !38727, metadata !DIExpression()), !dbg !38725
  %152 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5108, align 8, !dbg !38726
  %arraydecay110 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %152, i64 0, i64 0, !dbg !38726
  store [32 x i32]* %arraydecay110, [32 x i32]** %__begin5109, align 8, !dbg !38726
  %153 = bitcast [32 x i32]** %__end5111 to i8*, !dbg !38726
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %153) #285, !dbg !38726
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5111, metadata !38728, metadata !DIExpression()), !dbg !38725
  %154 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5108, align 8, !dbg !38726
  %arraydecay112 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %154, i64 0, i64 0, !dbg !38726
  %add.ptr113 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay112, i64 2, !dbg !38726
  store [32 x i32]* %add.ptr113, [32 x i32]** %__end5111, align 8, !dbg !38726
  br label %for.cond114, !dbg !38726

for.cond114:                                      ; preds = %for.inc133, %VITIS_LOOP_280_9
  %155 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !38726
  %156 = load [32 x i32]*, [32 x i32]** %__end5111, align 8, !dbg !38726
  %cmp115 = icmp ne [32 x i32]* %155, %156, !dbg !38726
  br i1 %cmp115, label %for.body117, label %for.cond.cleanup116, !dbg !38726

for.cond.cleanup116:                              ; preds = %for.cond114
  store i32 27, i32* %cleanup.dest.slot, align 4
  %157 = bitcast [32 x i32]** %__end5111 to i8*, !dbg !38726
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %157) #285, !dbg !38726
  %158 = bitcast [32 x i32]** %__begin5109 to i8*, !dbg !38726
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %158) #285, !dbg !38726
  %159 = bitcast [2 x [32 x i32]]** %__range5108 to i8*, !dbg !38726
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %159) #285, !dbg !38726
  br label %for.end135

for.body117:                                      ; preds = %for.cond114
  %160 = bitcast [32 x i32]** %batch118 to i8*, !dbg !38729
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %160) #285, !dbg !38729
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch118, metadata !38731, metadata !DIExpression()), !dbg !38732
  %161 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !38733
  store [32 x i32]* %161, [32 x i32]** %batch118, align 8, !dbg !38732
  br label %VITIS_LOOP_281_10, !dbg !38729

VITIS_LOOP_281_10:                                ; preds = %for.body117
  %162 = bitcast [32 x i32]** %__range6119 to i8*, !dbg !38734
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %162) #285, !dbg !38734
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6119, metadata !38736, metadata !DIExpression()), !dbg !38737
  %163 = load [32 x i32]*, [32 x i32]** %batch118, align 8, !dbg !38734
  store [32 x i32]* %163, [32 x i32]** %__range6119, align 8, !dbg !38734
  %164 = bitcast i32** %__begin6120 to i8*, !dbg !38738
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %164) #285, !dbg !38738
  call void @llvm.dbg.declare(metadata i32** %__begin6120, metadata !38739, metadata !DIExpression()), !dbg !38737
  %165 = load [32 x i32]*, [32 x i32]** %__range6119, align 8, !dbg !38738
  %arraydecay121 = getelementptr inbounds [32 x i32], [32 x i32]* %165, i64 0, i64 0, !dbg !38738
  store i32* %arraydecay121, i32** %__begin6120, align 8, !dbg !38738
  %166 = bitcast i32** %__end6122 to i8*, !dbg !38738
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %166) #285, !dbg !38738
  call void @llvm.dbg.declare(metadata i32** %__end6122, metadata !38740, metadata !DIExpression()), !dbg !38737
  %167 = load [32 x i32]*, [32 x i32]** %__range6119, align 8, !dbg !38738
  %arraydecay123 = getelementptr inbounds [32 x i32], [32 x i32]* %167, i64 0, i64 0, !dbg !38738
  %add.ptr124 = getelementptr inbounds i32, i32* %arraydecay123, i64 32, !dbg !38738
  store i32* %add.ptr124, i32** %__end6122, align 8, !dbg !38738
  br label %for.cond125, !dbg !38738

for.cond125:                                      ; preds = %for.inc130, %VITIS_LOOP_281_10
  %168 = load i32*, i32** %__begin6120, align 8, !dbg !38738
  %169 = load i32*, i32** %__end6122, align 8, !dbg !38738
  %cmp126 = icmp ne i32* %168, %169, !dbg !38738
  br i1 %cmp126, label %for.body128, label %for.cond.cleanup127, !dbg !38738

for.cond.cleanup127:                              ; preds = %for.cond125
  store i32 30, i32* %cleanup.dest.slot, align 4
  %170 = bitcast i32** %__end6122 to i8*, !dbg !38738
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %170) #285, !dbg !38738
  %171 = bitcast i32** %__begin6120 to i8*, !dbg !38738
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %171) #285, !dbg !38738
  %172 = bitcast [32 x i32]** %__range6119 to i8*, !dbg !38738
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %172) #285, !dbg !38738
  br label %for.end132

for.body128:                                      ; preds = %for.cond125
  %173 = bitcast i32** %word129 to i8*, !dbg !38741
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %173) #285, !dbg !38741
  call void @llvm.dbg.declare(metadata i32** %word129, metadata !38743, metadata !DIExpression()), !dbg !38744
  %174 = load i32*, i32** %__begin6120, align 8, !dbg !38745
  store i32* %174, i32** %word129, align 8, !dbg !38744
  %175 = load i32*, i32** %word129, align 8, !dbg !38746
  store i32 0, i32* %175, align 4, !dbg !38747
  %176 = bitcast i32** %word129 to i8*, !dbg !38748
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %176) #285, !dbg !38748
  br label %for.inc130, !dbg !38749

for.inc130:                                       ; preds = %for.body128
  %177 = load i32*, i32** %__begin6120, align 8, !dbg !38738
  %incdec.ptr131 = getelementptr inbounds i32, i32* %177, i32 1, !dbg !38738
  store i32* %incdec.ptr131, i32** %__begin6120, align 8, !dbg !38738
  br label %for.cond125, !dbg !38738, !llvm.loop !38750

for.end132:                                       ; preds = %for.cond.cleanup127
  %178 = bitcast [32 x i32]** %batch118 to i8*, !dbg !38752
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %178) #285, !dbg !38752
  br label %for.inc133, !dbg !38753

for.inc133:                                       ; preds = %for.end132
  %179 = load [32 x i32]*, [32 x i32]** %__begin5109, align 8, !dbg !38726
  %incdec.ptr134 = getelementptr inbounds [32 x i32], [32 x i32]* %179, i32 1, !dbg !38726
  store [32 x i32]* %incdec.ptr134, [32 x i32]** %__begin5109, align 8, !dbg !38726
  br label %for.cond114, !dbg !38726, !llvm.loop !38754

for.end135:                                       ; preds = %for.cond.cleanup116
  %180 = bitcast [2 x [32 x i32]]** %head107 to i8*, !dbg !38756
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %180) #285, !dbg !38756
  br label %for.inc136, !dbg !38757

for.inc136:                                       ; preds = %for.end135
  %181 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin498, align 8, !dbg !38714
  %incdec.ptr137 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %181, i32 1, !dbg !38714
  store [2 x [32 x i32]]* %incdec.ptr137, [2 x [32 x i32]]** %__begin498, align 8, !dbg !38714
  br label %for.cond103, !dbg !38714, !llvm.loop !38758

for.end138:                                       ; preds = %for.cond.cleanup105
  %182 = bitcast [16 x [2 x [32 x i32]]]** %plane96 to i8*, !dbg !38760
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %182) #285, !dbg !38760
  br label %for.inc139, !dbg !38761

for.inc139:                                       ; preds = %for.end138
  %183 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !38702
  %incdec.ptr140 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %183, i32 1, !dbg !38702
  store [16 x [2 x [32 x i32]]]* %incdec.ptr140, [16 x [2 x [32 x i32]]]** %__begin387, align 8, !dbg !38702
  br label %for.cond92, !dbg !38702, !llvm.loop !38762

for.end141:                                       ; preds = %for.cond.cleanup94
  %184 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard85 to i8*, !dbg !38764
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %184) #285, !dbg !38764
  br label %for.inc142, !dbg !38765

for.inc142:                                       ; preds = %for.end141
  %185 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !38690
  %incdec.ptr143 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %185, i32 1, !dbg !38690
  store [2 x [16 x [2 x [32 x i32]]]]* %incdec.ptr143, [2 x [16 x [2 x [32 x i32]]]]** %__begin276, align 8, !dbg !38690
  br label %for.cond81, !dbg !38690, !llvm.loop !38766

for.end144:                                       ; preds = %for.cond.cleanup83
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret align 8 %agg.result), !dbg !38768
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !38769

cleanup:                                          ; preds = %for.end144, %if.then17
  %186 = bitcast i32* %second to i8*, !dbg !38770
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %186) #285, !dbg !38770
  %187 = bitcast i32* %first to i8*, !dbg !38770
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %187) #285, !dbg !38770
  br label %return

return:                                           ; preds = %cleanup, %if.then
  ret void, !dbg !38770
}
