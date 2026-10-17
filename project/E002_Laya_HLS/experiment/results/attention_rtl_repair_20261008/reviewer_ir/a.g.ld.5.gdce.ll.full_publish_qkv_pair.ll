define dso_local void @_ZN4laya4full21full_publish_qkv_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %s) #212 !dbg !39000 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %first_index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %second_index = alloca i32, align 4
  %agg.tmp3 = alloca %"struct.laya::BufferRef", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %first = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %second = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %plane = alloca i32, align 4
  %head = alloca i32, align 4
  %batch = alloca i32, align 4
  %batch71 = alloca i32, align 4
  %row = alloca i32, align 4
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !39001, metadata !DIExpression()), !dbg !39002
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %s, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, metadata !39003, metadata !DIExpression()), !dbg !39004
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39005
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !39007
  %1 = load i1, i1* %request_valid, align 8, !dbg !39007
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !39008

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39009
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !39010
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !39010
  br i1 %3, label %lor.lhs.false1, label %if.then, !dbg !39011

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %4 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39012
  %5 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39013
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %4, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %5), !dbg !39014
  br i1 %call, label %if.end, label %if.then, !dbg !39015

if.then:                                          ; preds = %lor.lhs.false1, %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !39016
  br label %return, !dbg !39017

if.end:                                           ; preds = %lor.lhs.false1
  %6 = bitcast i32* %first_index to i8*, !dbg !39018
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %6) #285, !dbg !39018
  call void @llvm.dbg.declare(metadata i32* %first_index, metadata !39019, metadata !DIExpression()), !dbg !39020
  %7 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39021
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39022
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !39022
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx, i32 0, i32 0, !dbg !39023
  %9 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, align 4, !dbg !39022
  store %"struct.laya::BufferRef" %9, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !39022
  %call2 = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %7, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0), !dbg !39024
  store i32 %call2, i32* %first_index, align 4, !dbg !39020
  %10 = bitcast i32* %second_index to i8*, !dbg !39025
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %10) #285, !dbg !39025
  call void @llvm.dbg.declare(metadata i32* %second_index, metadata !39026, metadata !DIExpression()), !dbg !39027
  %11 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39028
  %12 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39029
  %arrayidx4 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %12, i64 0, i64 1, !dbg !39029
  %ref5 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx4, i32 0, i32 0, !dbg !39030
  %13 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref5, align 4, !dbg !39029
  store %"struct.laya::BufferRef" %13, %"struct.laya::BufferRef"* %agg.tmp3, align 4, !dbg !39029
  %call6 = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %11, %"struct.laya::BufferRef"* byval align 4 %agg.tmp3, i8 zeroext 0), !dbg !39031
  store i32 %call6, i32* %second_index, align 4, !dbg !39027
  %14 = load i32, i32* %first_index, align 4, !dbg !39032
  %cmp = icmp eq i32 %14, 32, !dbg !39034
  br i1 %cmp, label %if.then9, label %lor.lhs.false7, !dbg !39035

lor.lhs.false7:                                   ; preds = %if.end
  %15 = load i32, i32* %second_index, align 4, !dbg !39036
  %cmp8 = icmp eq i32 %15, 32, !dbg !39037
  br i1 %cmp8, label %if.then9, label %if.end10, !dbg !39038

if.then9:                                         ; preds = %lor.lhs.false7, %if.end
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !39039
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup117, !dbg !39040

if.end10:                                         ; preds = %lor.lhs.false7
  %16 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !39041
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %16) #285, !dbg !39041
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %first, metadata !39042, metadata !DIExpression()), !dbg !39043
  %17 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39044
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %17, i32 0, i32 1, !dbg !39045
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !39046
  %18 = load i32, i32* %first_index, align 4, !dbg !39047
  %idxprom = zext i32 %18 to i64, !dbg !39044
  %arrayidx11 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !39044
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx11, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39043
  %19 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !39048
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %19) #285, !dbg !39048
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %second, metadata !39049, metadata !DIExpression()), !dbg !39050
  %20 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39051
  %owners12 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %20, i32 0, i32 1, !dbg !39052
  %record13 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners12, i32 0, i32 0, !dbg !39053
  %21 = load i32, i32* %second_index, align 4, !dbg !39054
  %idxprom14 = zext i32 %21 to i64, !dbg !39051
  %arrayidx15 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record13, i64 0, i64 %idxprom14, !dbg !39051
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx15, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39050
  %22 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39055
  %23 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39057
  %arrayidx16 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %23, i64 0, i64 0, !dbg !39057
  %call17 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %22, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx16), !dbg !39058
  br i1 %call17, label %lor.lhs.false18, label %if.then34, !dbg !39059

lor.lhs.false18:                                  ; preds = %if.end10
  %24 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39060
  %25 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39061
  %arrayidx19 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %25, i64 0, i64 1, !dbg !39061
  %call20 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %24, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx19), !dbg !39062
  br i1 %call20, label %lor.lhs.false21, label %if.then34, !dbg !39063

lor.lhs.false21:                                  ; preds = %lor.lhs.false18
  %26 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39064
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %26, i32 0, i32 13, !dbg !39065
  %27 = load i8, i8* %state, align 1, !dbg !39065
  %cmp22 = icmp ne i8 %27, 1, !dbg !39066
  br i1 %cmp22, label %if.then34, label %lor.lhs.false23, !dbg !39067

lor.lhs.false23:                                  ; preds = %lor.lhs.false21
  %28 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39068
  %state24 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %28, i32 0, i32 13, !dbg !39069
  %29 = load i8, i8* %state24, align 1, !dbg !39069
  %cmp25 = icmp ne i8 %29, 1, !dbg !39070
  br i1 %cmp25, label %if.then34, label %lor.lhs.false26, !dbg !39071

lor.lhs.false26:                                  ; preds = %lor.lhs.false23
  %30 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39072
  %identity = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %30, i32 0, i32 0, !dbg !39073
  %31 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39074
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %31, i32 0, i32 0, !dbg !39075
  %identity27 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !39076
  %call28 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity27), !dbg !39077
  br i1 %call28, label %lor.lhs.false29, label %if.then34, !dbg !39078

lor.lhs.false29:                                  ; preds = %lor.lhs.false26
  %32 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39079
  %identity30 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %32, i32 0, i32 0, !dbg !39080
  %33 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39081
  %inputs31 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %33, i32 0, i32 0, !dbg !39082
  %identity32 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs31, i32 0, i32 0, !dbg !39083
  %call33 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity30, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity32), !dbg !39084
  br i1 %call33, label %if.end35, label %if.then34, !dbg !39085

if.then34:                                        ; preds = %lor.lhs.false29, %lor.lhs.false26, %lor.lhs.false23, %lor.lhs.false21, %lor.lhs.false18, %if.end10
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !39086
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup115, !dbg !39087

if.end35:                                         ; preds = %lor.lhs.false29
  br label %VITIS_LOOP_323_1, !dbg !39088

VITIS_LOOP_323_1:                                 ; preds = %if.end35
  %34 = bitcast i32* %plane to i8*, !dbg !39089
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %34) #285, !dbg !39089
  call void @llvm.dbg.declare(metadata i32* %plane, metadata !39091, metadata !DIExpression()), !dbg !39092
  store i32 0, i32* %plane, align 4, !dbg !39092
  br label %for.cond, !dbg !39089

for.cond:                                         ; preds = %for.inc66, %VITIS_LOOP_323_1
  %35 = load i32, i32* %plane, align 4, !dbg !39093
  %cmp36 = icmp ult i32 %35, 3, !dbg !39095
  br i1 %cmp36, label %for.body, label %for.cond.cleanup, !dbg !39096

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup68, !dbg !39096

for.body:                                         ; preds = %for.cond
  br label %VITIS_LOOP_324_2, !dbg !39096

VITIS_LOOP_324_2:                                 ; preds = %for.body
  %36 = bitcast i32* %head to i8*, !dbg !39097
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %36) #285, !dbg !39097
  call void @llvm.dbg.declare(metadata i32* %head, metadata !39099, metadata !DIExpression()), !dbg !39100
  store i32 0, i32* %head, align 4, !dbg !39100
  br label %for.cond37, !dbg !39097

for.cond37:                                       ; preds = %for.inc61, %VITIS_LOOP_324_2
  %37 = load i32, i32* %head, align 4, !dbg !39101
  %cmp38 = icmp ult i32 %37, 16, !dbg !39103
  br i1 %cmp38, label %for.body40, label %for.cond.cleanup39, !dbg !39104

for.cond.cleanup39:                               ; preds = %for.cond37
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup63, !dbg !39104

for.body40:                                       ; preds = %for.cond37
  br label %VITIS_LOOP_325_3, !dbg !39104

VITIS_LOOP_325_3:                                 ; preds = %for.body40
  %38 = bitcast i32* %batch to i8*, !dbg !39105
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %38) #285, !dbg !39105
  call void @llvm.dbg.declare(metadata i32* %batch, metadata !39107, metadata !DIExpression()), !dbg !39108
  store i32 0, i32* %batch, align 4, !dbg !39108
  br label %for.cond41, !dbg !39105

for.cond41:                                       ; preds = %for.inc, %VITIS_LOOP_325_3
  %39 = load i32, i32* %batch, align 4, !dbg !39109
  %40 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39111
  %inputs42 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %40, i32 0, i32 0, !dbg !39112
  %identity43 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs42, i32 0, i32 0, !dbg !39113
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity43, i32 0, i32 2, !dbg !39114
  %41 = load i16, i16* %B, align 8, !dbg !39114
  %conv = zext i16 %41 to i32, !dbg !39111
  %cmp44 = icmp ult i32 %39, %conv, !dbg !39115
  br i1 %cmp44, label %for.body46, label %for.cond.cleanup45, !dbg !39116

for.cond.cleanup45:                               ; preds = %for.cond41
  store i32 11, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !39116

for.body46:                                       ; preds = %for.cond41
  %42 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39117
  %owners47 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %42, i32 0, i32 1, !dbg !39119
  %qkv_plane_head_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners47, i32 0, i32 1, !dbg !39120
  %43 = load i32, i32* %head, align 4, !dbg !39121
  %rem = urem i32 %43, 2, !dbg !39122
  %idxprom48 = zext i32 %rem to i64, !dbg !39117
  %arrayidx49 = getelementptr inbounds [2 x [3 x [16 x [2 x [32 x i32]]]]], [2 x [3 x [16 x [2 x [32 x i32]]]]]* %qkv_plane_head_rows, i64 0, i64 %idxprom48, !dbg !39117
  %44 = load i32, i32* %plane, align 4, !dbg !39123
  %idxprom50 = zext i32 %44 to i64, !dbg !39117
  %arrayidx51 = getelementptr inbounds [3 x [16 x [2 x [32 x i32]]]], [3 x [16 x [2 x [32 x i32]]]]* %arrayidx49, i64 0, i64 %idxprom50, !dbg !39117
  %45 = load i32, i32* %head, align 4, !dbg !39124
  %idxprom52 = zext i32 %45 to i64, !dbg !39117
  %arrayidx53 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arrayidx51, i64 0, i64 %idxprom52, !dbg !39117
  %46 = load i32, i32* %batch, align 4, !dbg !39125
  %idxprom54 = zext i32 %46 to i64, !dbg !39117
  %arrayidx55 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arrayidx53, i64 0, i64 %idxprom54, !dbg !39117
  %arraydecay = getelementptr inbounds [32 x i32], [32 x i32]* %arrayidx55, i64 0, i64 0, !dbg !39117
  %47 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39126
  %inputs56 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %47, i32 0, i32 0, !dbg !39127
  %identity57 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs56, i32 0, i32 0, !dbg !39128
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity57, i32 0, i32 3, !dbg !39129
  %48 = load i16, i16* %S, align 2, !dbg !39129
  %call58 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_18all_rowsEPKjt(i32* %arraydecay, i16 zeroext %48), !dbg !39130
  br i1 %call58, label %if.end60, label %if.then59, !dbg !39131

if.then59:                                        ; preds = %for.body46
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !39132
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !39133

if.end60:                                         ; preds = %for.body46
  br label %for.inc, !dbg !39134

for.inc:                                          ; preds = %if.end60
  %49 = load i32, i32* %batch, align 4, !dbg !39135
  %inc = add i32 %49, 1, !dbg !39135
  store i32 %inc, i32* %batch, align 4, !dbg !39135
  br label %for.cond41, !dbg !39136, !llvm.loop !39137

cleanup:                                          ; preds = %if.then59, %for.cond.cleanup45
  %50 = bitcast i32* %batch to i8*, !dbg !39136
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %50) #285, !dbg !39136
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup63 [
    i32 11, label %for.end
  ]

for.end:                                          ; preds = %cleanup
  br label %for.inc61, !dbg !39138

for.inc61:                                        ; preds = %for.end
  %51 = load i32, i32* %head, align 4, !dbg !39140
  %inc62 = add i32 %51, 1, !dbg !39140
  store i32 %inc62, i32* %head, align 4, !dbg !39140
  br label %for.cond37, !dbg !39141, !llvm.loop !39142

cleanup63:                                        ; preds = %cleanup, %for.cond.cleanup39
  %52 = bitcast i32* %head to i8*, !dbg !39141
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %52) #285, !dbg !39141
  %cleanup.dest64 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest64, label %cleanup68 [
    i32 7, label %for.end65
  ]

for.end65:                                        ; preds = %cleanup63
  br label %for.inc66, !dbg !39143

for.inc66:                                        ; preds = %for.end65
  %53 = load i32, i32* %plane, align 4, !dbg !39145
  %inc67 = add i32 %53, 1, !dbg !39145
  store i32 %inc67, i32* %plane, align 4, !dbg !39145
  br label %for.cond, !dbg !39146, !llvm.loop !39147

cleanup68:                                        ; preds = %cleanup63, %for.cond.cleanup
  %54 = bitcast i32* %plane to i8*, !dbg !39146
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %54) #285, !dbg !39146
  %cleanup.dest69 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest69, label %cleanup115 [
    i32 3, label %for.end70
  ]

for.end70:                                        ; preds = %cleanup68
  br label %VITIS_LOOP_328_4, !dbg !39148

VITIS_LOOP_328_4:                                 ; preds = %for.end70
  %55 = bitcast i32* %batch71 to i8*, !dbg !39150
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %55) #285, !dbg !39150
  call void @llvm.dbg.declare(metadata i32* %batch71, metadata !39152, metadata !DIExpression()), !dbg !39153
  store i32 0, i32* %batch71, align 4, !dbg !39153
  br label %for.cond72, !dbg !39150

for.cond72:                                       ; preds = %for.inc97, %VITIS_LOOP_328_4
  %56 = load i32, i32* %batch71, align 4, !dbg !39154
  %57 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39156
  %inputs73 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %57, i32 0, i32 0, !dbg !39157
  %identity74 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs73, i32 0, i32 0, !dbg !39158
  %B75 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity74, i32 0, i32 2, !dbg !39159
  %58 = load i16, i16* %B75, align 8, !dbg !39159
  %conv76 = zext i16 %58 to i32, !dbg !39156
  %cmp77 = icmp ult i32 %56, %conv76, !dbg !39160
  br i1 %cmp77, label %for.body79, label %for.cond.cleanup78, !dbg !39161

for.cond.cleanup78:                               ; preds = %for.cond72
  store i32 15, i32* %cleanup.dest.slot, align 4
  %59 = bitcast i32* %batch71 to i8*, !dbg !39162
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %59) #285, !dbg !39162
  br label %for.end100

for.body79:                                       ; preds = %for.cond72
  br label %VITIS_LOOP_329_5, !dbg !39161

VITIS_LOOP_329_5:                                 ; preds = %for.body79
  %60 = bitcast i32* %row to i8*, !dbg !39163
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %60) #285, !dbg !39163
  call void @llvm.dbg.declare(metadata i32* %row, metadata !39165, metadata !DIExpression()), !dbg !39166
  store i32 0, i32* %row, align 4, !dbg !39166
  br label %for.cond80, !dbg !39163

for.cond80:                                       ; preds = %for.inc93, %VITIS_LOOP_329_5
  %61 = load i32, i32* %row, align 4, !dbg !39167
  %62 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39169
  %inputs81 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %62, i32 0, i32 0, !dbg !39170
  %identity82 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs81, i32 0, i32 0, !dbg !39171
  %S83 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity82, i32 0, i32 3, !dbg !39172
  %63 = load i16, i16* %S83, align 2, !dbg !39172
  %conv84 = zext i16 %63 to i32, !dbg !39169
  %cmp85 = icmp ult i32 %61, %conv84, !dbg !39173
  br i1 %cmp85, label %for.body87, label %for.cond.cleanup86, !dbg !39174

for.cond.cleanup86:                               ; preds = %for.cond80
  store i32 19, i32* %cleanup.dest.slot, align 4
  %64 = bitcast i32* %row to i8*, !dbg !39175
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %64) #285, !dbg !39175
  br label %for.end96

for.body87:                                       ; preds = %for.cond80
  %65 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39176
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %65, i32 0, i32 15, !dbg !39178
  %arraydecay88 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !39176
  %66 = load i32, i32* %batch71, align 4, !dbg !39179
  %mul = mul i32 %66, 1024, !dbg !39180
  %67 = load i32, i32* %row, align 4, !dbg !39181
  %add = add i32 %mul, %67, !dbg !39182
  call void @_ZN4laya4full12_GLOBAL__N_17set_bitEPjj(i32* %arraydecay88, i32 %add), !dbg !39183
  %68 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39184
  %covered_rows89 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %68, i32 0, i32 15, !dbg !39185
  %arraydecay90 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows89, i64 0, i64 0, !dbg !39184
  %69 = load i32, i32* %batch71, align 4, !dbg !39186
  %mul91 = mul i32 %69, 1024, !dbg !39187
  %70 = load i32, i32* %row, align 4, !dbg !39188
  %add92 = add i32 %mul91, %70, !dbg !39189
  call void @_ZN4laya4full12_GLOBAL__N_17set_bitEPjj(i32* %arraydecay90, i32 %add92), !dbg !39190
  br label %for.inc93, !dbg !39191

for.inc93:                                        ; preds = %for.body87
  %71 = load i32, i32* %row, align 4, !dbg !39192
  %inc94 = add i32 %71, 1, !dbg !39192
  store i32 %inc94, i32* %row, align 4, !dbg !39192
  br label %for.cond80, !dbg !39175, !llvm.loop !39193

for.end96:                                        ; preds = %for.cond.cleanup86
  br label %for.inc97, !dbg !39194

for.inc97:                                        ; preds = %for.end96
  %72 = load i32, i32* %batch71, align 4, !dbg !39196
  %inc98 = add i32 %72, 1, !dbg !39196
  store i32 %inc98, i32* %batch71, align 4, !dbg !39196
  br label %for.cond72, !dbg !39162, !llvm.loop !39197

for.end100:                                       ; preds = %for.cond.cleanup78
  %73 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39200
  %state101 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %73, i32 0, i32 13, !dbg !39201
  store i8 2, i8* %state101, align 1, !dbg !39202
  %74 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !39203
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %74, i32 0, i32 17, !dbg !39204
  store i1 true, i1* %valid, align 4, !dbg !39205
  %75 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39206
  %state102 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %75, i32 0, i32 13, !dbg !39207
  store i8 2, i8* %state102, align 1, !dbg !39208
  %76 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !39209
  %valid103 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %76, i32 0, i32 17, !dbg !39210
  store i1 true, i1* %valid103, align 4, !dbg !39211
  %77 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39212
  %arrayidx104 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %77, i64 0, i64 0, !dbg !39212
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx104, i32 0, i32 9, !dbg !39214
  %78 = load i8, i8* %content, align 4, !dbg !39214
  %cmp105 = icmp eq i8 %78, 3, !dbg !39215
  br i1 %cmp105, label %if.then106, label %if.end114, !dbg !39216

if.then106:                                       ; preds = %for.end100
  %79 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39217
  %arrayidx107 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %79, i64 0, i64 0, !dbg !39217
  %ref108 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx107, i32 0, i32 0, !dbg !39219
  %80 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39220
  %final_qkv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %80, i32 0, i32 6, !dbg !39221
  %arrayidx109 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref, i64 0, i64 0, !dbg !39220
  %81 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref108, align 4, !dbg !39222
  store %"struct.laya::BufferRef" %81, %"struct.laya::BufferRef"* %arrayidx109, align 8, !dbg !39222
  %82 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !39223
  %arrayidx110 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %82, i64 0, i64 1, !dbg !39223
  %ref111 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx110, i32 0, i32 0, !dbg !39224
  %83 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !39225
  %final_qkv_ref112 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %83, i32 0, i32 6, !dbg !39226
  %arrayidx113 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref112, i64 0, i64 1, !dbg !39225
  %84 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref111, align 4, !dbg !39227
  store %"struct.laya::BufferRef" %84, %"struct.laya::BufferRef"* %arrayidx113, align 8, !dbg !39227
  br label %if.end114, !dbg !39228

if.end114:                                        ; preds = %if.then106, %for.end100
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret align 8 %agg.result), !dbg !39229
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup115, !dbg !39230

cleanup115:                                       ; preds = %if.end114, %cleanup68, %if.then34
  %85 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !39231
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %85) #285, !dbg !39231
  %86 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !39231
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %86) #285, !dbg !39231
  br label %cleanup117

cleanup117:                                       ; preds = %cleanup115, %if.then9
  %87 = bitcast i32* %second_index to i8*, !dbg !39231
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %87) #285, !dbg !39231
  %88 = bitcast i32* %first_index to i8*, !dbg !39231
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %88) #285, !dbg !39231
  br label %return

return:                                           ; preds = %cleanup117, %if.then
  ret void, !dbg !39231
}
