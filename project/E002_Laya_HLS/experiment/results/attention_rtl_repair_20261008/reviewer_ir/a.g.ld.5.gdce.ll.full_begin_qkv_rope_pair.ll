define dso_local void @_ZN4laya4full24full_begin_qkv_rope_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecES6_(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %old_s, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %next_s) #175 !dbg !31756 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %old_s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %next_s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %first_index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %second_index = alloca i32, align 4
  %agg.tmp3 = alloca %"struct.laya::BufferRef", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %first = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %second = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %__range2 = alloca [2 x [2 x [16 x [2 x [32 x i32]]]]]*, align 8
  %__begin2 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__end2 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %shard = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
  %__range3 = alloca [2 x [16 x [2 x [32 x i32]]]]*, align 8
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
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !31759, metadata !DIExpression()), !dbg !31760
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %old_s, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, metadata !31761, metadata !DIExpression()), !dbg !31762
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %next_s, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, metadata !31763, metadata !DIExpression()), !dbg !31764
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31765
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !31767
  %1 = load i1, i1* %request_valid, align 8, !dbg !31767
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !31768

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31769
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !31770
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !31770
  br i1 %3, label %lor.lhs.false1, label %if.then, !dbg !31771

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31772
  %5 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31773
  %6 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !31774
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_rope_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecES8_(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %4, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %5, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %6), !dbg !31775
  br i1 %call, label %if.end, label %if.then, !dbg !31776

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 5), !dbg !31777
  br label %return, !dbg !31778

if.end:                                           ; preds = %lor.lhs.false1
  %7 = bitcast i32* %first_index to i8*, !dbg !31779
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %7) #285, !dbg !31779
  call void @llvm.dbg.declare(metadata i32* %first_index, metadata !31780, metadata !DIExpression()), !dbg !31781
  %8 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31782
  %9 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31783
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %9, i64 0, i64 0, !dbg !31783
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx, i32 0, i32 0, !dbg !31784
  %10 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !31783
  store %"struct.laya::BufferRef" %10, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !31783
  %call2 = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %8, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0), !dbg !31785
  store i32 %call2, i32* %first_index, align 4, !dbg !31781
  %11 = bitcast i32* %second_index to i8*, !dbg !31786
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %11) #285, !dbg !31786
  call void @llvm.dbg.declare(metadata i32* %second_index, metadata !31787, metadata !DIExpression()), !dbg !31788
  %12 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31789
  %13 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31790
  %arrayidx4 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %13, i64 0, i64 1, !dbg !31790
  %ref5 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx4, i32 0, i32 0, !dbg !31791
  %14 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref5, align 4, !dbg !31790
  store %"struct.laya::BufferRef" %14, %"struct.laya::BufferRef"* %agg.tmp3, align 4, !dbg !31790
  %call6 = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %12, %"struct.laya::BufferRef"* byval align 4 %agg.tmp3, i8 zeroext 0), !dbg !31792
  store i32 %call6, i32* %second_index, align 4, !dbg !31788
  %15 = load i32, i32* %first_index, align 4, !dbg !31793
  %cmp = icmp eq i32 %15, 32, !dbg !31795
  br i1 %cmp, label %if.then9, label %lor.lhs.false7, !dbg !31796

lor.lhs.false7:                                   ; preds = %if.end
  %16 = load i32, i32* %second_index, align 4, !dbg !31797
  %cmp8 = icmp eq i32 %16, 32, !dbg !31798
  br i1 %cmp8, label %if.then9, label %if.end10, !dbg !31799

if.then9:                                         ; preds = %lor.lhs.false7, %if.end
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !31800
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup131, !dbg !31801

if.end10:                                         ; preds = %lor.lhs.false7
  %17 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !31802
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %17) #285, !dbg !31802
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %first, metadata !31803, metadata !DIExpression()), !dbg !31804
  %18 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31805
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %18, i32 0, i32 1, !dbg !31806
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !31807
  %19 = load i32, i32* %first_index, align 4, !dbg !31808
  %idxprom = zext i32 %19 to i64, !dbg !31805
  %arrayidx11 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !31805
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx11, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31804
  %20 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !31809
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %20) #285, !dbg !31809
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %second, metadata !31810, metadata !DIExpression()), !dbg !31811
  %21 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31812
  %owners12 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %21, i32 0, i32 1, !dbg !31813
  %record13 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners12, i32 0, i32 0, !dbg !31814
  %22 = load i32, i32* %second_index, align 4, !dbg !31815
  %idxprom14 = zext i32 %22 to i64, !dbg !31812
  %arrayidx15 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record13, i64 0, i64 %idxprom14, !dbg !31812
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx15, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31811
  %23 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31816
  %24 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31818
  %arrayidx16 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %24, i64 0, i64 0, !dbg !31818
  %call17 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %23, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx16), !dbg !31819
  br i1 %call17, label %lor.lhs.false18, label %if.then54, !dbg !31820

lor.lhs.false18:                                  ; preds = %if.end10
  %25 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31821
  %26 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31822
  %arrayidx19 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %26, i64 0, i64 1, !dbg !31822
  %call20 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %25, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx19), !dbg !31823
  br i1 %call20, label %lor.lhs.false21, label %if.then54, !dbg !31824

lor.lhs.false21:                                  ; preds = %lor.lhs.false18
  %27 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31825
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %27, i32 0, i32 17, !dbg !31826
  %28 = load i1, i1* %valid, align 4, !dbg !31826
  br i1 %28, label %lor.lhs.false22, label %if.then54, !dbg !31827

lor.lhs.false22:                                  ; preds = %lor.lhs.false21
  %29 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31828
  %valid23 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %29, i32 0, i32 17, !dbg !31829
  %30 = load i1, i1* %valid23, align 4, !dbg !31829
  br i1 %30, label %lor.lhs.false24, label %if.then54, !dbg !31830

lor.lhs.false24:                                  ; preds = %lor.lhs.false22
  %31 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31831
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %31, i32 0, i32 13, !dbg !31832
  %32 = load i8, i8* %state, align 1, !dbg !31832
  %cmp25 = icmp ne i8 %32, 2, !dbg !31833
  br i1 %cmp25, label %if.then54, label %lor.lhs.false26, !dbg !31834

lor.lhs.false26:                                  ; preds = %lor.lhs.false24
  %33 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31835
  %state27 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %33, i32 0, i32 13, !dbg !31836
  %34 = load i8, i8* %state27, align 1, !dbg !31836
  %cmp28 = icmp ne i8 %34, 2, !dbg !31837
  br i1 %cmp28, label %if.then54, label %lor.lhs.false29, !dbg !31838

lor.lhs.false29:                                  ; preds = %lor.lhs.false26
  %35 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31839
  %readers = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %35, i32 0, i32 14, !dbg !31840
  %36 = load i8, i8* %readers, align 2, !dbg !31840
  %tobool = icmp ne i8 %36, 0, !dbg !31839
  br i1 %tobool, label %if.then54, label %lor.lhs.false30, !dbg !31841

lor.lhs.false30:                                  ; preds = %lor.lhs.false29
  %37 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31842
  %readers31 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %37, i32 0, i32 14, !dbg !31843
  %38 = load i8, i8* %readers31, align 2, !dbg !31843
  %tobool32 = icmp ne i8 %38, 0, !dbg !31842
  br i1 %tobool32, label %if.then54, label %lor.lhs.false33, !dbg !31844

lor.lhs.false33:                                  ; preds = %lor.lhs.false30
  %39 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31845
  %max_claimed_epoch = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %39, i32 0, i32 3, !dbg !31846
  %40 = load i32, i32* %max_claimed_epoch, align 8, !dbg !31846
  %cmp34 = icmp uge i32 %40, -2, !dbg !31847
  br i1 %cmp34, label %if.then54, label %lor.lhs.false35, !dbg !31848

lor.lhs.false35:                                  ; preds = %lor.lhs.false33
  %41 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31849
  %max_claimed_epoch36 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %41, i32 0, i32 3, !dbg !31850
  %42 = load i32, i32* %max_claimed_epoch36, align 8, !dbg !31850
  %cmp37 = icmp uge i32 %42, -2, !dbg !31851
  br i1 %cmp37, label %if.then54, label %lor.lhs.false38, !dbg !31852

lor.lhs.false38:                                  ; preds = %lor.lhs.false35
  %43 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31853
  %identity = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %43, i32 0, i32 0, !dbg !31854
  %44 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31855
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %44, i32 0, i32 0, !dbg !31856
  %identity39 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !31857
  %call40 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity39), !dbg !31858
  br i1 %call40, label %lor.lhs.false41, label %if.then54, !dbg !31859

lor.lhs.false41:                                  ; preds = %lor.lhs.false38
  %45 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31860
  %identity42 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %45, i32 0, i32 0, !dbg !31861
  %46 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31862
  %inputs43 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %46, i32 0, i32 0, !dbg !31863
  %identity44 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs43, i32 0, i32 0, !dbg !31864
  %call45 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity42, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity44), !dbg !31865
  br i1 %call45, label %lor.lhs.false46, label %if.then54, !dbg !31866

lor.lhs.false46:                                  ; preds = %lor.lhs.false41
  %47 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31867
  %48 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31868
  %arrayidx47 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %48, i64 0, i64 0, !dbg !31868
  %49 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31869
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %49, i32 0, i32 15, !dbg !31870
  %arraydecay = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !31869
  %call48 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_17coveredERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecEPKj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %47, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx47, i32* %arraydecay), !dbg !31871
  br i1 %call48, label %lor.lhs.false49, label %if.then54, !dbg !31872

lor.lhs.false49:                                  ; preds = %lor.lhs.false46
  %50 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31873
  %51 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31874
  %arrayidx50 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %51, i64 0, i64 1, !dbg !31874
  %52 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31875
  %covered_rows51 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %52, i32 0, i32 15, !dbg !31876
  %arraydecay52 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows51, i64 0, i64 0, !dbg !31875
  %call53 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_17coveredERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecEPKj(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %50, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx50, i32* %arraydecay52), !dbg !31877
  br i1 %call53, label %if.end55, label %if.then54, !dbg !31878

if.then54:                                        ; preds = %lor.lhs.false49, %lor.lhs.false46, %lor.lhs.false41, %lor.lhs.false38, %lor.lhs.false35, %lor.lhs.false33, %lor.lhs.false30, %lor.lhs.false29, %lor.lhs.false26, %lor.lhs.false24, %lor.lhs.false22, %lor.lhs.false21, %lor.lhs.false18, %if.end10
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !31879
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !31880

if.end55:                                         ; preds = %lor.lhs.false49
  %53 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31881
  %arrayidx56 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %53, i64 0, i64 0, !dbg !31881
  %ref57 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx56, i32 0, i32 0, !dbg !31882
  %54 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31883
  %lease_old_ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %54, i32 0, i32 2, !dbg !31884
  %55 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref57, align 4, !dbg !31885
  store %"struct.laya::BufferRef" %55, %"struct.laya::BufferRef"* %lease_old_ref, align 8, !dbg !31885
  %56 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !31886
  %arrayidx58 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %56, i64 0, i64 0, !dbg !31886
  %ref59 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx58, i32 0, i32 0, !dbg !31887
  %57 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31888
  %ref60 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %57, i32 0, i32 1, !dbg !31889
  %58 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref59, align 4, !dbg !31890
  store %"struct.laya::BufferRef" %58, %"struct.laya::BufferRef"* %ref60, align 8, !dbg !31890
  %59 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !31891
  %arrayidx61 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %59, i64 0, i64 0, !dbg !31891
  %ref62 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx61, i32 0, i32 0, !dbg !31892
  %epoch = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref62, i32 0, i32 2, !dbg !31893
  %60 = load i32, i32* %epoch, align 4, !dbg !31893
  %61 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31894
  %max_claimed_epoch63 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %61, i32 0, i32 3, !dbg !31895
  store i32 %60, i32* %max_claimed_epoch63, align 8, !dbg !31896
  %62 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31897
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %62, i32 0, i32 12, !dbg !31898
  store i8 3, i8* %content, align 8, !dbg !31899
  %63 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31900
  %state64 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %63, i32 0, i32 13, !dbg !31901
  store i8 4, i8* %state64, align 1, !dbg !31902
  %64 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31903
  %valid65 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %64, i32 0, i32 17, !dbg !31904
  store i1 false, i1* %valid65, align 4, !dbg !31905
  %65 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31906
  %covered_rows66 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %65, i32 0, i32 15, !dbg !31907
  %arraydecay67 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows66, i64 0, i64 0, !dbg !31906
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay67), !dbg !31908
  %66 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !31909
  %old_consumed_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %66, i32 0, i32 16, !dbg !31910
  %arraydecay68 = getelementptr inbounds [64 x i32], [64 x i32]* %old_consumed_rows, i64 0, i64 0, !dbg !31909
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay68), !dbg !31911
  %67 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %old_s.addr, align 8, !dbg !31912
  %arrayidx69 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %67, i64 0, i64 1, !dbg !31912
  %ref70 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx69, i32 0, i32 0, !dbg !31913
  %68 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31914
  %lease_old_ref71 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %68, i32 0, i32 2, !dbg !31915
  %69 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref70, align 4, !dbg !31916
  store %"struct.laya::BufferRef" %69, %"struct.laya::BufferRef"* %lease_old_ref71, align 8, !dbg !31916
  %70 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !31917
  %arrayidx72 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %70, i64 0, i64 1, !dbg !31917
  %ref73 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx72, i32 0, i32 0, !dbg !31918
  %71 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31919
  %ref74 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %71, i32 0, i32 1, !dbg !31920
  %72 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref73, align 4, !dbg !31921
  store %"struct.laya::BufferRef" %72, %"struct.laya::BufferRef"* %ref74, align 8, !dbg !31921
  %73 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !31922
  %arrayidx75 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %73, i64 0, i64 1, !dbg !31922
  %ref76 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx75, i32 0, i32 0, !dbg !31923
  %epoch77 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref76, i32 0, i32 2, !dbg !31924
  %74 = load i32, i32* %epoch77, align 4, !dbg !31924
  %75 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31925
  %max_claimed_epoch78 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %75, i32 0, i32 3, !dbg !31926
  store i32 %74, i32* %max_claimed_epoch78, align 8, !dbg !31927
  %76 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31928
  %content79 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %76, i32 0, i32 12, !dbg !31929
  store i8 3, i8* %content79, align 8, !dbg !31930
  %77 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31931
  %state80 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %77, i32 0, i32 13, !dbg !31932
  store i8 4, i8* %state80, align 1, !dbg !31933
  %78 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31934
  %valid81 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %78, i32 0, i32 17, !dbg !31935
  store i1 false, i1* %valid81, align 4, !dbg !31936
  %79 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31937
  %covered_rows82 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %79, i32 0, i32 15, !dbg !31938
  %arraydecay83 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows82, i64 0, i64 0, !dbg !31937
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay83), !dbg !31939
  %80 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !31940
  %old_consumed_rows84 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %80, i32 0, i32 16, !dbg !31941
  %arraydecay85 = getelementptr inbounds [64 x i32], [64 x i32]* %old_consumed_rows84, i64 0, i64 0, !dbg !31940
  call void @_ZN4laya4full12_GLOBAL__N_110clear_bitsEPj(i32* %arraydecay85), !dbg !31942
  %81 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31943
  %owner_leases = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %81, i32 0, i32 28, !dbg !31944
  %82 = load i32, i32* %owner_leases, align 4, !dbg !31945
  %add = add i32 %82, 2, !dbg !31945
  store i32 %add, i32* %owner_leases, align 4, !dbg !31945
  br label %VITIS_LOOP_383_1, !dbg !31943

VITIS_LOOP_383_1:                                 ; preds = %if.end55
  %83 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !31946
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %83) #285, !dbg !31946
  call void @llvm.dbg.declare(metadata [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2, metadata !31948, metadata !DIExpression()), !dbg !31950
  %84 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !31946
  %owners86 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %84, i32 0, i32 1, !dbg !31951
  %qkv_rope_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners86, i32 0, i32 2, !dbg !31952
  store [2 x [2 x [16 x [2 x [32 x i32]]]]]* %qkv_rope_rows, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !31946
  %85 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !31953
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %85) #285, !dbg !31953
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__begin2, metadata !31954, metadata !DIExpression()), !dbg !31950
  %86 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !31953
  %arraydecay87 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %86, i64 0, i64 0, !dbg !31953
  store [2 x [16 x [2 x [32 x i32]]]]* %arraydecay87, [2 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !31953
  %87 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !31953
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %87) #285, !dbg !31953
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__end2, metadata !31958, metadata !DIExpression()), !dbg !31950
  %88 = load [2 x [2 x [16 x [2 x [32 x i32]]]]]*, [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2, align 8, !dbg !31953
  %arraydecay88 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %88, i64 0, i64 0, !dbg !31953
  %add.ptr = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %arraydecay88, i64 2, !dbg !31953
  store [2 x [16 x [2 x [32 x i32]]]]* %add.ptr, [2 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !31953
  br label %for.cond, !dbg !31953

for.cond:                                         ; preds = %for.inc127, %VITIS_LOOP_383_1
  %89 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !31953
  %90 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__end2, align 8, !dbg !31953
  %cmp89 = icmp ne [2 x [16 x [2 x [32 x i32]]]]* %89, %90, !dbg !31953
  br i1 %cmp89, label %for.body, label %for.cond.cleanup, !dbg !31953

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  %91 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__end2 to i8*, !dbg !31953
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %91) #285, !dbg !31953
  %92 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__begin2 to i8*, !dbg !31953
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %92) #285, !dbg !31953
  %93 = bitcast [2 x [2 x [16 x [2 x [32 x i32]]]]]** %__range2 to i8*, !dbg !31953
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %93) #285, !dbg !31953
  br label %for.end129

for.body:                                         ; preds = %for.cond
  %94 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !31959
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %94) #285, !dbg !31959
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %shard, metadata !31961, metadata !DIExpression()), !dbg !31963
  %95 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !31964
  store [2 x [16 x [2 x [32 x i32]]]]* %95, [2 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !31963
  br label %VITIS_LOOP_384_2, !dbg !31959

VITIS_LOOP_384_2:                                 ; preds = %for.body
  %96 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !31965
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %96) #285, !dbg !31965
  call void @llvm.dbg.declare(metadata [2 x [16 x [2 x [32 x i32]]]]** %__range3, metadata !31967, metadata !DIExpression()), !dbg !31968
  %97 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %shard, align 8, !dbg !31965
  store [2 x [16 x [2 x [32 x i32]]]]* %97, [2 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !31965
  %98 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !31969
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %98) #285, !dbg !31969
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__begin3, metadata !31970, metadata !DIExpression()), !dbg !31968
  %99 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !31969
  %arraydecay90 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %99, i64 0, i64 0, !dbg !31969
  store [16 x [2 x [32 x i32]]]* %arraydecay90, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !31969
  %100 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !31969
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %100) #285, !dbg !31969
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__end3, metadata !31972, metadata !DIExpression()), !dbg !31968
  %101 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__range3, align 8, !dbg !31969
  %arraydecay91 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %101, i64 0, i64 0, !dbg !31969
  %add.ptr92 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arraydecay91, i64 2, !dbg !31969
  store [16 x [2 x [32 x i32]]]* %add.ptr92, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !31969
  br label %for.cond93, !dbg !31969

for.cond93:                                       ; preds = %for.inc124, %VITIS_LOOP_384_2
  %102 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !31969
  %103 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__end3, align 8, !dbg !31969
  %cmp94 = icmp ne [16 x [2 x [32 x i32]]]* %102, %103, !dbg !31969
  br i1 %cmp94, label %for.body96, label %for.cond.cleanup95, !dbg !31969

for.cond.cleanup95:                               ; preds = %for.cond93
  store i32 6, i32* %cleanup.dest.slot, align 4
  %104 = bitcast [16 x [2 x [32 x i32]]]** %__end3 to i8*, !dbg !31969
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %104) #285, !dbg !31969
  %105 = bitcast [16 x [2 x [32 x i32]]]** %__begin3 to i8*, !dbg !31969
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %105) #285, !dbg !31969
  %106 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %__range3 to i8*, !dbg !31969
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %106) #285, !dbg !31969
  br label %for.end126

for.body96:                                       ; preds = %for.cond93
  %107 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !31973
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %107) #285, !dbg !31973
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %plane, metadata !31975, metadata !DIExpression()), !dbg !31976
  %108 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !31977
  store [16 x [2 x [32 x i32]]]* %108, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !31976
  br label %VITIS_LOOP_385_3, !dbg !31973

VITIS_LOOP_385_3:                                 ; preds = %for.body96
  %109 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !31978
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %109) #285, !dbg !31978
  call void @llvm.dbg.declare(metadata [16 x [2 x [32 x i32]]]** %__range4, metadata !31980, metadata !DIExpression()), !dbg !31981
  %110 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %plane, align 8, !dbg !31978
  store [16 x [2 x [32 x i32]]]* %110, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !31978
  %111 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !31982
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %111) #285, !dbg !31982
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__begin4, metadata !31983, metadata !DIExpression()), !dbg !31981
  %112 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !31982
  %arraydecay97 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %112, i64 0, i64 0, !dbg !31982
  store [2 x [32 x i32]]* %arraydecay97, [2 x [32 x i32]]** %__begin4, align 8, !dbg !31982
  %113 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !31982
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %113) #285, !dbg !31982
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__end4, metadata !31984, metadata !DIExpression()), !dbg !31981
  %114 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__range4, align 8, !dbg !31982
  %arraydecay98 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %114, i64 0, i64 0, !dbg !31982
  %add.ptr99 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arraydecay98, i64 16, !dbg !31982
  store [2 x [32 x i32]]* %add.ptr99, [2 x [32 x i32]]** %__end4, align 8, !dbg !31982
  br label %for.cond100, !dbg !31982

for.cond100:                                      ; preds = %for.inc121, %VITIS_LOOP_385_3
  %115 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !31982
  %116 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__end4, align 8, !dbg !31982
  %cmp101 = icmp ne [2 x [32 x i32]]* %115, %116, !dbg !31982
  br i1 %cmp101, label %for.body103, label %for.cond.cleanup102, !dbg !31982

for.cond.cleanup102:                              ; preds = %for.cond100
  store i32 9, i32* %cleanup.dest.slot, align 4
  %117 = bitcast [2 x [32 x i32]]** %__end4 to i8*, !dbg !31982
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %117) #285, !dbg !31982
  %118 = bitcast [2 x [32 x i32]]** %__begin4 to i8*, !dbg !31982
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %118) #285, !dbg !31982
  %119 = bitcast [16 x [2 x [32 x i32]]]** %__range4 to i8*, !dbg !31982
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %119) #285, !dbg !31982
  br label %for.end123

for.body103:                                      ; preds = %for.cond100
  %120 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !31985
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %120) #285, !dbg !31985
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %head, metadata !31987, metadata !DIExpression()), !dbg !31988
  %121 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !31989
  store [2 x [32 x i32]]* %121, [2 x [32 x i32]]** %head, align 8, !dbg !31988
  br label %VITIS_LOOP_386_4, !dbg !31985

VITIS_LOOP_386_4:                                 ; preds = %for.body103
  %122 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !31990
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %122) #285, !dbg !31990
  call void @llvm.dbg.declare(metadata [2 x [32 x i32]]** %__range5, metadata !31992, metadata !DIExpression()), !dbg !31993
  %123 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %head, align 8, !dbg !31990
  store [2 x [32 x i32]]* %123, [2 x [32 x i32]]** %__range5, align 8, !dbg !31990
  %124 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !31994
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %124) #285, !dbg !31994
  call void @llvm.dbg.declare(metadata [32 x i32]** %__begin5, metadata !31995, metadata !DIExpression()), !dbg !31993
  %125 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !31994
  %arraydecay104 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %125, i64 0, i64 0, !dbg !31994
  store [32 x i32]* %arraydecay104, [32 x i32]** %__begin5, align 8, !dbg !31994
  %126 = bitcast [32 x i32]** %__end5 to i8*, !dbg !31994
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %126) #285, !dbg !31994
  call void @llvm.dbg.declare(metadata [32 x i32]** %__end5, metadata !31996, metadata !DIExpression()), !dbg !31993
  %127 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__range5, align 8, !dbg !31994
  %arraydecay105 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %127, i64 0, i64 0, !dbg !31994
  %add.ptr106 = getelementptr inbounds [32 x i32], [32 x i32]* %arraydecay105, i64 2, !dbg !31994
  store [32 x i32]* %add.ptr106, [32 x i32]** %__end5, align 8, !dbg !31994
  br label %for.cond107, !dbg !31994

for.cond107:                                      ; preds = %for.inc118, %VITIS_LOOP_386_4
  %128 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !31994
  %129 = load [32 x i32]*, [32 x i32]** %__end5, align 8, !dbg !31994
  %cmp108 = icmp ne [32 x i32]* %128, %129, !dbg !31994
  br i1 %cmp108, label %for.body110, label %for.cond.cleanup109, !dbg !31994

for.cond.cleanup109:                              ; preds = %for.cond107
  store i32 12, i32* %cleanup.dest.slot, align 4
  %130 = bitcast [32 x i32]** %__end5 to i8*, !dbg !31994
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %130) #285, !dbg !31994
  %131 = bitcast [32 x i32]** %__begin5 to i8*, !dbg !31994
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %131) #285, !dbg !31994
  %132 = bitcast [2 x [32 x i32]]** %__range5 to i8*, !dbg !31994
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %132) #285, !dbg !31994
  br label %for.end120

for.body110:                                      ; preds = %for.cond107
  %133 = bitcast [32 x i32]** %batch to i8*, !dbg !31997
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %133) #285, !dbg !31997
  call void @llvm.dbg.declare(metadata [32 x i32]** %batch, metadata !31999, metadata !DIExpression()), !dbg !32000
  %134 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !32001
  store [32 x i32]* %134, [32 x i32]** %batch, align 8, !dbg !32000
  br label %VITIS_LOOP_387_5, !dbg !31997

VITIS_LOOP_387_5:                                 ; preds = %for.body110
  %135 = bitcast [32 x i32]** %__range6 to i8*, !dbg !32002
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %135) #285, !dbg !32002
  call void @llvm.dbg.declare(metadata [32 x i32]** %__range6, metadata !32004, metadata !DIExpression()), !dbg !32005
  %136 = load [32 x i32]*, [32 x i32]** %batch, align 8, !dbg !32002
  store [32 x i32]* %136, [32 x i32]** %__range6, align 8, !dbg !32002
  %137 = bitcast i32** %__begin6 to i8*, !dbg !32006
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %137) #285, !dbg !32006
  call void @llvm.dbg.declare(metadata i32** %__begin6, metadata !32007, metadata !DIExpression()), !dbg !32005
  %138 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !32006
  %arraydecay111 = getelementptr inbounds [32 x i32], [32 x i32]* %138, i64 0, i64 0, !dbg !32006
  store i32* %arraydecay111, i32** %__begin6, align 8, !dbg !32006
  %139 = bitcast i32** %__end6 to i8*, !dbg !32006
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %139) #285, !dbg !32006
  call void @llvm.dbg.declare(metadata i32** %__end6, metadata !32008, metadata !DIExpression()), !dbg !32005
  %140 = load [32 x i32]*, [32 x i32]** %__range6, align 8, !dbg !32006
  %arraydecay112 = getelementptr inbounds [32 x i32], [32 x i32]* %140, i64 0, i64 0, !dbg !32006
  %add.ptr113 = getelementptr inbounds i32, i32* %arraydecay112, i64 32, !dbg !32006
  store i32* %add.ptr113, i32** %__end6, align 8, !dbg !32006
  br label %for.cond114, !dbg !32006

for.cond114:                                      ; preds = %for.inc, %VITIS_LOOP_387_5
  %141 = load i32*, i32** %__begin6, align 8, !dbg !32006
  %142 = load i32*, i32** %__end6, align 8, !dbg !32006
  %cmp115 = icmp ne i32* %141, %142, !dbg !32006
  br i1 %cmp115, label %for.body117, label %for.cond.cleanup116, !dbg !32006

for.cond.cleanup116:                              ; preds = %for.cond114
  store i32 15, i32* %cleanup.dest.slot, align 4
  %143 = bitcast i32** %__end6 to i8*, !dbg !32006
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %143) #285, !dbg !32006
  %144 = bitcast i32** %__begin6 to i8*, !dbg !32006
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %144) #285, !dbg !32006
  %145 = bitcast [32 x i32]** %__range6 to i8*, !dbg !32006
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %145) #285, !dbg !32006
  br label %for.end

for.body117:                                      ; preds = %for.cond114
  %146 = bitcast i32** %word to i8*, !dbg !32009
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %146) #285, !dbg !32009
  call void @llvm.dbg.declare(metadata i32** %word, metadata !32011, metadata !DIExpression()), !dbg !32012
  %147 = load i32*, i32** %__begin6, align 8, !dbg !32013
  store i32* %147, i32** %word, align 8, !dbg !32012
  %148 = load i32*, i32** %word, align 8, !dbg !32014
  store i32 0, i32* %148, align 4, !dbg !32015
  %149 = bitcast i32** %word to i8*, !dbg !32016
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %149) #285, !dbg !32016
  br label %for.inc, !dbg !32017

for.inc:                                          ; preds = %for.body117
  %150 = load i32*, i32** %__begin6, align 8, !dbg !32006
  %incdec.ptr = getelementptr inbounds i32, i32* %150, i32 1, !dbg !32006
  store i32* %incdec.ptr, i32** %__begin6, align 8, !dbg !32006
  br label %for.cond114, !dbg !32006, !llvm.loop !32018

for.end:                                          ; preds = %for.cond.cleanup116
  %151 = bitcast [32 x i32]** %batch to i8*, !dbg !32020
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %151) #285, !dbg !32020
  br label %for.inc118, !dbg !32021

for.inc118:                                       ; preds = %for.end
  %152 = load [32 x i32]*, [32 x i32]** %__begin5, align 8, !dbg !31994
  %incdec.ptr119 = getelementptr inbounds [32 x i32], [32 x i32]* %152, i32 1, !dbg !31994
  store [32 x i32]* %incdec.ptr119, [32 x i32]** %__begin5, align 8, !dbg !31994
  br label %for.cond107, !dbg !31994, !llvm.loop !32022

for.end120:                                       ; preds = %for.cond.cleanup109
  %153 = bitcast [2 x [32 x i32]]** %head to i8*, !dbg !32024
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %153) #285, !dbg !32024
  br label %for.inc121, !dbg !32025

for.inc121:                                       ; preds = %for.end120
  %154 = load [2 x [32 x i32]]*, [2 x [32 x i32]]** %__begin4, align 8, !dbg !31982
  %incdec.ptr122 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %154, i32 1, !dbg !31982
  store [2 x [32 x i32]]* %incdec.ptr122, [2 x [32 x i32]]** %__begin4, align 8, !dbg !31982
  br label %for.cond100, !dbg !31982, !llvm.loop !32026

for.end123:                                       ; preds = %for.cond.cleanup102
  %155 = bitcast [16 x [2 x [32 x i32]]]** %plane to i8*, !dbg !32028
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %155) #285, !dbg !32028
  br label %for.inc124, !dbg !32029

for.inc124:                                       ; preds = %for.end123
  %156 = load [16 x [2 x [32 x i32]]]*, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !31969
  %incdec.ptr125 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %156, i32 1, !dbg !31969
  store [16 x [2 x [32 x i32]]]* %incdec.ptr125, [16 x [2 x [32 x i32]]]** %__begin3, align 8, !dbg !31969
  br label %for.cond93, !dbg !31969, !llvm.loop !32030

for.end126:                                       ; preds = %for.cond.cleanup95
  %157 = bitcast [2 x [16 x [2 x [32 x i32]]]]** %shard to i8*, !dbg !32032
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %157) #285, !dbg !32032
  br label %for.inc127, !dbg !32033

for.inc127:                                       ; preds = %for.end126
  %158 = load [2 x [16 x [2 x [32 x i32]]]]*, [2 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !31953
  %incdec.ptr128 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %158, i32 1, !dbg !31953
  store [2 x [16 x [2 x [32 x i32]]]]* %incdec.ptr128, [2 x [16 x [2 x [32 x i32]]]]** %__begin2, align 8, !dbg !31953
  br label %for.cond, !dbg !31953, !llvm.loop !32034

for.end129:                                       ; preds = %for.cond.cleanup
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret align 8 %agg.result), !dbg !32036
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !32037

cleanup:                                          ; preds = %for.end129, %if.then54
  %159 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !32038
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %159) #285, !dbg !32038
  %160 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !32038
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %160) #285, !dbg !32038
  br label %cleanup131

cleanup131:                                       ; preds = %cleanup, %if.then9
  %161 = bitcast i32* %second_index to i8*, !dbg !32038
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %161) #285, !dbg !32038
  %162 = bitcast i32* %first_index to i8*, !dbg !32038
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %162) #285, !dbg !32038
  br label %return

return:                                           ; preds = %cleanup131, %if.then
  ret void, !dbg !32038
}
