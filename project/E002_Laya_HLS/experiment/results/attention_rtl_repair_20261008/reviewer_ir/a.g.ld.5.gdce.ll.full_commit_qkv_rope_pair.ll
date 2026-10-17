define dso_local void @_ZN4laya4full25full_commit_qkv_rope_pairERNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %next_s) #176 !dbg !32141 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %next_s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  %first_index = alloca i32, align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %second_index = alloca i32, align 4
  %agg.tmp26 = alloca %"struct.laya::BufferRef", align 4
  %cleanup.dest.slot = alloca i32, align 4
  %first = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %second = alloca %"struct.laya::full::FullOwnerRecord"*, align 8
  %plane = alloca i32, align 4
  %head = alloca i32, align 4
  %batch = alloca i32, align 4
  %batch103 = alloca i32, align 4
  %row = alloca i32, align 4
  %ref.tmp = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp137 = alloca %"struct.laya::BufferRef", align 4
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !32144, metadata !DIExpression()), !dbg !32145
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %next_s, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, metadata !32146, metadata !DIExpression()), !dbg !32147
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32148
  %request_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %0, i32 0, i32 42, !dbg !32150
  %1 = load i1, i1* %request_valid, align 8, !dbg !32150
  br i1 %1, label %lor.lhs.false, label %if.then, !dbg !32151

lor.lhs.false:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32152
  %model_header_valid = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %2, i32 0, i32 43, !dbg !32153
  %3 = load i1, i1* %model_header_valid, align 1, !dbg !32153
  br i1 %3, label %lor.lhs.false1, label %if.then, !dbg !32154

lor.lhs.false1:                                   ; preds = %lor.lhs.false
  %4 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32155
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %4, i64 0, i64 0, !dbg !32155
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx, i32 0, i32 0, !dbg !32156
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !32157
  %5 = load i8, i8* %id, align 4, !dbg !32157
  %cmp = icmp ne i8 %5, 5, !dbg !32158
  br i1 %cmp, label %if.then, label %lor.lhs.false2, !dbg !32159

lor.lhs.false2:                                   ; preds = %lor.lhs.false1
  %6 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32160
  %arrayidx3 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %6, i64 0, i64 1, !dbg !32160
  %ref4 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx3, i32 0, i32 0, !dbg !32161
  %id5 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref4, i32 0, i32 0, !dbg !32162
  %7 = load i8, i8* %id5, align 4, !dbg !32162
  %cmp6 = icmp ne i8 %7, 5, !dbg !32163
  br i1 %cmp6, label %if.then, label %lor.lhs.false7, !dbg !32164

lor.lhs.false7:                                   ; preds = %lor.lhs.false2
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32165
  %arrayidx8 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !32165
  %ref9 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx8, i32 0, i32 0, !dbg !32166
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref9, i32 0, i32 1, !dbg !32167
  %9 = load i8, i8* %bank, align 1, !dbg !32167
  %conv = zext i8 %9 to i32, !dbg !32165
  %cmp10 = icmp ne i32 %conv, 0, !dbg !32168
  br i1 %cmp10, label %if.then, label %lor.lhs.false11, !dbg !32169

lor.lhs.false11:                                  ; preds = %lor.lhs.false7
  %10 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32170
  %arrayidx12 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %10, i64 0, i64 1, !dbg !32170
  %ref13 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx12, i32 0, i32 0, !dbg !32171
  %bank14 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref13, i32 0, i32 1, !dbg !32172
  %11 = load i8, i8* %bank14, align 1, !dbg !32172
  %conv15 = zext i8 %11 to i32, !dbg !32170
  %cmp16 = icmp ne i32 %conv15, 1, !dbg !32173
  br i1 %cmp16, label %if.then, label %lor.lhs.false17, !dbg !32174

lor.lhs.false17:                                  ; preds = %lor.lhs.false11
  %12 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32175
  %arrayidx18 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %12, i64 0, i64 0, !dbg !32175
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx18, i32 0, i32 9, !dbg !32176
  %13 = load i8, i8* %content, align 4, !dbg !32176
  %cmp19 = icmp ne i8 %13, 3, !dbg !32177
  br i1 %cmp19, label %if.then, label %lor.lhs.false20, !dbg !32178

lor.lhs.false20:                                  ; preds = %lor.lhs.false17
  %14 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32179
  %arrayidx21 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %14, i64 0, i64 1, !dbg !32179
  %content22 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx21, i32 0, i32 9, !dbg !32180
  %15 = load i8, i8* %content22, align 4, !dbg !32180
  %cmp23 = icmp ne i8 %15, 3, !dbg !32181
  br i1 %cmp23, label %if.then, label %if.end, !dbg !32182

if.then:                                          ; preds = %lor.lhs.false20, %lor.lhs.false17, %lor.lhs.false11, %lor.lhs.false7, %lor.lhs.false2, %lor.lhs.false1, %lor.lhs.false, %entry
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 5), !dbg !32183
  br label %return, !dbg !32184

if.end:                                           ; preds = %lor.lhs.false20
  %16 = bitcast i32* %first_index to i8*, !dbg !32185
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %16) #285, !dbg !32185
  call void @llvm.dbg.declare(metadata i32* %first_index, metadata !32186, metadata !DIExpression()), !dbg !32187
  %17 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32188
  %18 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32189
  %arrayidx24 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %18, i64 0, i64 0, !dbg !32189
  %ref25 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx24, i32 0, i32 0, !dbg !32190
  %19 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref25, align 4, !dbg !32189
  store %"struct.laya::BufferRef" %19, %"struct.laya::BufferRef"* %agg.tmp, align 4, !dbg !32189
  %call = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %17, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0), !dbg !32191
  store i32 %call, i32* %first_index, align 4, !dbg !32187
  %20 = bitcast i32* %second_index to i8*, !dbg !32192
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %20) #285, !dbg !32192
  call void @llvm.dbg.declare(metadata i32* %second_index, metadata !32193, metadata !DIExpression()), !dbg !32194
  %21 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32195
  %22 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32196
  %arrayidx27 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %22, i64 0, i64 1, !dbg !32196
  %ref28 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx27, i32 0, i32 0, !dbg !32197
  %23 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref28, align 4, !dbg !32196
  store %"struct.laya::BufferRef" %23, %"struct.laya::BufferRef"* %agg.tmp26, align 4, !dbg !32196
  %call29 = call i32 @_ZN4laya4full12_GLOBAL__N_110find_indexERKNS0_11FullRuntimeENS_9BufferRefEh(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %21, %"struct.laya::BufferRef"* byval align 4 %agg.tmp26, i8 zeroext 0), !dbg !32198
  store i32 %call29, i32* %second_index, align 4, !dbg !32194
  %24 = load i32, i32* %first_index, align 4, !dbg !32199
  %cmp30 = icmp eq i32 %24, 32, !dbg !32201
  br i1 %cmp30, label %if.then33, label %lor.lhs.false31, !dbg !32202

lor.lhs.false31:                                  ; preds = %if.end
  %25 = load i32, i32* %second_index, align 4, !dbg !32203
  %cmp32 = icmp eq i32 %25, 32, !dbg !32204
  br i1 %cmp32, label %if.then33, label %if.end34, !dbg !32205

if.then33:                                        ; preds = %lor.lhs.false31, %if.end
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !32206
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup148, !dbg !32207

if.end34:                                         ; preds = %lor.lhs.false31
  %26 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !32208
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %26) #285, !dbg !32208
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %first, metadata !32209, metadata !DIExpression()), !dbg !32210
  %27 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32211
  %owners = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %27, i32 0, i32 1, !dbg !32212
  %record = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners, i32 0, i32 0, !dbg !32213
  %28 = load i32, i32* %first_index, align 4, !dbg !32214
  %idxprom = zext i32 %28 to i64, !dbg !32211
  %arrayidx35 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record, i64 0, i64 %idxprom, !dbg !32211
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx35, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32210
  %29 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !32215
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %29) #285, !dbg !32215
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerRecord"** %second, metadata !32216, metadata !DIExpression()), !dbg !32217
  %30 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32218
  %owners36 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %30, i32 0, i32 1, !dbg !32219
  %record37 = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners36, i32 0, i32 0, !dbg !32220
  %31 = load i32, i32* %second_index, align 4, !dbg !32221
  %idxprom38 = zext i32 %31 to i64, !dbg !32218
  %arrayidx39 = getelementptr inbounds [32 x %"struct.laya::full::FullOwnerRecord"], [32 x %"struct.laya::full::FullOwnerRecord"]* %record37, i64 0, i64 %idxprom38, !dbg !32218
  store %"struct.laya::full::FullOwnerRecord"* %arrayidx39, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32217
  %32 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32222
  %33 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32224
  %arrayidx40 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %33, i64 0, i64 0, !dbg !32224
  %call41 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %32, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx40), !dbg !32225
  br i1 %call41, label %lor.lhs.false42, label %if.then65, !dbg !32226

lor.lhs.false42:                                  ; preds = %if.end34
  %34 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32227
  %35 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32228
  %arrayidx43 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %35, i64 0, i64 1, !dbg !32228
  %call44 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_19same_specERKNS0_15FullOwnerRecordERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullOwnerRecord"* nonnull align 8 dereferenceable(640) %34, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx43), !dbg !32229
  br i1 %call44, label %lor.lhs.false45, label %if.then65, !dbg !32230

lor.lhs.false45:                                  ; preds = %lor.lhs.false42
  %36 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32231
  %state = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %36, i32 0, i32 13, !dbg !32232
  %37 = load i8, i8* %state, align 1, !dbg !32232
  %cmp46 = icmp ne i8 %37, 4, !dbg !32233
  br i1 %cmp46, label %if.then65, label %lor.lhs.false47, !dbg !32234

lor.lhs.false47:                                  ; preds = %lor.lhs.false45
  %38 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32235
  %state48 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %38, i32 0, i32 13, !dbg !32236
  %39 = load i8, i8* %state48, align 1, !dbg !32236
  %cmp49 = icmp ne i8 %39, 4, !dbg !32237
  br i1 %cmp49, label %if.then65, label %lor.lhs.false50, !dbg !32238

lor.lhs.false50:                                  ; preds = %lor.lhs.false47
  %40 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32239
  %lease_old_ref = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %40, i32 0, i32 2, !dbg !32240
  %id51 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %lease_old_ref, i32 0, i32 0, !dbg !32241
  %41 = load i8, i8* %id51, align 8, !dbg !32241
  %cmp52 = icmp ne i8 %41, 5, !dbg !32242
  br i1 %cmp52, label %if.then65, label %lor.lhs.false53, !dbg !32243

lor.lhs.false53:                                  ; preds = %lor.lhs.false50
  %42 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32244
  %lease_old_ref54 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %42, i32 0, i32 2, !dbg !32245
  %id55 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %lease_old_ref54, i32 0, i32 0, !dbg !32246
  %43 = load i8, i8* %id55, align 8, !dbg !32246
  %cmp56 = icmp ne i8 %43, 5, !dbg !32247
  br i1 %cmp56, label %if.then65, label %lor.lhs.false57, !dbg !32248

lor.lhs.false57:                                  ; preds = %lor.lhs.false53
  %44 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32249
  %identity = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %44, i32 0, i32 0, !dbg !32250
  %45 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32251
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %45, i32 0, i32 0, !dbg !32252
  %identity58 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !32253
  %call59 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity58), !dbg !32254
  br i1 %call59, label %lor.lhs.false60, label %if.then65, !dbg !32255

lor.lhs.false60:                                  ; preds = %lor.lhs.false57
  %46 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32256
  %identity61 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %46, i32 0, i32 0, !dbg !32257
  %47 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32258
  %inputs62 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %47, i32 0, i32 0, !dbg !32259
  %identity63 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs62, i32 0, i32 0, !dbg !32260
  %call64 = call zeroext i1 @_ZN4laya22numeric_identity_equalERKNS_15NumericIdentityES2_(%"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity61, %"struct.laya::NumericIdentity"* nonnull align 8 dereferenceable(88) %identity63), !dbg !32261
  br i1 %call64, label %if.end66, label %if.then65, !dbg !32262

if.then65:                                        ; preds = %lor.lhs.false60, %lor.lhs.false57, %lor.lhs.false53, %lor.lhs.false50, %lor.lhs.false47, %lor.lhs.false45, %lor.lhs.false42, %if.end34
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !32263
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup146, !dbg !32264

if.end66:                                         ; preds = %lor.lhs.false60
  br label %VITIS_LOOP_450_1, !dbg !32265

VITIS_LOOP_450_1:                                 ; preds = %if.end66
  %48 = bitcast i32* %plane to i8*, !dbg !32266
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %48) #285, !dbg !32266
  call void @llvm.dbg.declare(metadata i32* %plane, metadata !32268, metadata !DIExpression()), !dbg !32269
  store i32 0, i32* %plane, align 4, !dbg !32269
  br label %for.cond, !dbg !32266

for.cond:                                         ; preds = %for.inc98, %VITIS_LOOP_450_1
  %49 = load i32, i32* %plane, align 4, !dbg !32270
  %cmp67 = icmp ult i32 %49, 2, !dbg !32272
  br i1 %cmp67, label %for.body, label %for.cond.cleanup, !dbg !32273

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 3, i32* %cleanup.dest.slot, align 4
  br label %cleanup100, !dbg !32273

for.body:                                         ; preds = %for.cond
  br label %VITIS_LOOP_451_2, !dbg !32273

VITIS_LOOP_451_2:                                 ; preds = %for.body
  %50 = bitcast i32* %head to i8*, !dbg !32274
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %50) #285, !dbg !32274
  call void @llvm.dbg.declare(metadata i32* %head, metadata !32276, metadata !DIExpression()), !dbg !32277
  store i32 0, i32* %head, align 4, !dbg !32277
  br label %for.cond68, !dbg !32274

for.cond68:                                       ; preds = %for.inc93, %VITIS_LOOP_451_2
  %51 = load i32, i32* %head, align 4, !dbg !32278
  %cmp69 = icmp ult i32 %51, 16, !dbg !32280
  br i1 %cmp69, label %for.body71, label %for.cond.cleanup70, !dbg !32281

for.cond.cleanup70:                               ; preds = %for.cond68
  store i32 7, i32* %cleanup.dest.slot, align 4
  br label %cleanup95, !dbg !32281

for.body71:                                       ; preds = %for.cond68
  br label %VITIS_LOOP_452_3, !dbg !32281

VITIS_LOOP_452_3:                                 ; preds = %for.body71
  %52 = bitcast i32* %batch to i8*, !dbg !32282
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %52) #285, !dbg !32282
  call void @llvm.dbg.declare(metadata i32* %batch, metadata !32284, metadata !DIExpression()), !dbg !32285
  store i32 0, i32* %batch, align 4, !dbg !32285
  br label %for.cond72, !dbg !32282

for.cond72:                                       ; preds = %for.inc, %VITIS_LOOP_452_3
  %53 = load i32, i32* %batch, align 4, !dbg !32286
  %54 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32288
  %inputs73 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %54, i32 0, i32 0, !dbg !32289
  %identity74 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs73, i32 0, i32 0, !dbg !32290
  %B = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity74, i32 0, i32 2, !dbg !32291
  %55 = load i16, i16* %B, align 8, !dbg !32291
  %conv75 = zext i16 %55 to i32, !dbg !32288
  %cmp76 = icmp ult i32 %53, %conv75, !dbg !32292
  br i1 %cmp76, label %for.body78, label %for.cond.cleanup77, !dbg !32293

for.cond.cleanup77:                               ; preds = %for.cond72
  store i32 11, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !32293

for.body78:                                       ; preds = %for.cond72
  %56 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32294
  %owners79 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %56, i32 0, i32 1, !dbg !32296
  %qkv_rope_rows = getelementptr inbounds %"struct.laya::full::FullOwners", %"struct.laya::full::FullOwners"* %owners79, i32 0, i32 2, !dbg !32297
  %57 = load i32, i32* %head, align 4, !dbg !32298
  %rem = urem i32 %57, 2, !dbg !32299
  %idxprom80 = zext i32 %rem to i64, !dbg !32294
  %arrayidx81 = getelementptr inbounds [2 x [2 x [16 x [2 x [32 x i32]]]]], [2 x [2 x [16 x [2 x [32 x i32]]]]]* %qkv_rope_rows, i64 0, i64 %idxprom80, !dbg !32294
  %58 = load i32, i32* %plane, align 4, !dbg !32300
  %idxprom82 = zext i32 %58 to i64, !dbg !32294
  %arrayidx83 = getelementptr inbounds [2 x [16 x [2 x [32 x i32]]]], [2 x [16 x [2 x [32 x i32]]]]* %arrayidx81, i64 0, i64 %idxprom82, !dbg !32294
  %59 = load i32, i32* %head, align 4, !dbg !32301
  %idxprom84 = zext i32 %59 to i64, !dbg !32294
  %arrayidx85 = getelementptr inbounds [16 x [2 x [32 x i32]]], [16 x [2 x [32 x i32]]]* %arrayidx83, i64 0, i64 %idxprom84, !dbg !32294
  %60 = load i32, i32* %batch, align 4, !dbg !32302
  %idxprom86 = zext i32 %60 to i64, !dbg !32294
  %arrayidx87 = getelementptr inbounds [2 x [32 x i32]], [2 x [32 x i32]]* %arrayidx85, i64 0, i64 %idxprom86, !dbg !32294
  %arraydecay = getelementptr inbounds [32 x i32], [32 x i32]* %arrayidx87, i64 0, i64 0, !dbg !32294
  %61 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32303
  %inputs88 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %61, i32 0, i32 0, !dbg !32304
  %identity89 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs88, i32 0, i32 0, !dbg !32305
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity89, i32 0, i32 3, !dbg !32306
  %62 = load i16, i16* %S, align 2, !dbg !32306
  %call90 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_18all_rowsEPKjt(i32* %arraydecay, i16 zeroext %62), !dbg !32307
  br i1 %call90, label %if.end92, label %if.then91, !dbg !32308

if.then91:                                        ; preds = %for.body78
  call void @_ZN4laya4full12_GLOBAL__N_15errorENS_6BufferEt(%"struct.laya::Check"* sret align 8 %agg.result, i8 zeroext 5, i16 zeroext 9), !dbg !32309
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup, !dbg !32310

if.end92:                                         ; preds = %for.body78
  br label %for.inc, !dbg !32311

for.inc:                                          ; preds = %if.end92
  %63 = load i32, i32* %batch, align 4, !dbg !32312
  %inc = add i32 %63, 1, !dbg !32312
  store i32 %inc, i32* %batch, align 4, !dbg !32312
  br label %for.cond72, !dbg !32313, !llvm.loop !32314

cleanup:                                          ; preds = %if.then91, %for.cond.cleanup77
  %64 = bitcast i32* %batch to i8*, !dbg !32313
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %64) #285, !dbg !32313
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup95 [
    i32 11, label %for.end
  ]

for.end:                                          ; preds = %cleanup
  br label %for.inc93, !dbg !32315

for.inc93:                                        ; preds = %for.end
  %65 = load i32, i32* %head, align 4, !dbg !32317
  %inc94 = add i32 %65, 1, !dbg !32317
  store i32 %inc94, i32* %head, align 4, !dbg !32317
  br label %for.cond68, !dbg !32318, !llvm.loop !32319

cleanup95:                                        ; preds = %cleanup, %for.cond.cleanup70
  %66 = bitcast i32* %head to i8*, !dbg !32318
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %66) #285, !dbg !32318
  %cleanup.dest96 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest96, label %cleanup100 [
    i32 7, label %for.end97
  ]

for.end97:                                        ; preds = %cleanup95
  br label %for.inc98, !dbg !32320

for.inc98:                                        ; preds = %for.end97
  %67 = load i32, i32* %plane, align 4, !dbg !32322
  %inc99 = add i32 %67, 1, !dbg !32322
  store i32 %inc99, i32* %plane, align 4, !dbg !32322
  br label %for.cond, !dbg !32323, !llvm.loop !32324

cleanup100:                                       ; preds = %cleanup95, %for.cond.cleanup
  %68 = bitcast i32* %plane to i8*, !dbg !32323
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %68) #285, !dbg !32323
  %cleanup.dest101 = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest101, label %cleanup146 [
    i32 3, label %for.end102
  ]

for.end102:                                       ; preds = %cleanup100
  br label %VITIS_LOOP_455_4, !dbg !32325

VITIS_LOOP_455_4:                                 ; preds = %for.end102
  %69 = bitcast i32* %batch103 to i8*, !dbg !32327
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %69) #285, !dbg !32327
  call void @llvm.dbg.declare(metadata i32* %batch103, metadata !32329, metadata !DIExpression()), !dbg !32330
  store i32 0, i32* %batch103, align 4, !dbg !32330
  br label %for.cond104, !dbg !32327

for.cond104:                                      ; preds = %for.inc129, %VITIS_LOOP_455_4
  %70 = load i32, i32* %batch103, align 4, !dbg !32331
  %71 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32333
  %inputs105 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %71, i32 0, i32 0, !dbg !32334
  %identity106 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs105, i32 0, i32 0, !dbg !32335
  %B107 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity106, i32 0, i32 2, !dbg !32336
  %72 = load i16, i16* %B107, align 8, !dbg !32336
  %conv108 = zext i16 %72 to i32, !dbg !32333
  %cmp109 = icmp ult i32 %70, %conv108, !dbg !32337
  br i1 %cmp109, label %for.body111, label %for.cond.cleanup110, !dbg !32338

for.cond.cleanup110:                              ; preds = %for.cond104
  store i32 15, i32* %cleanup.dest.slot, align 4
  %73 = bitcast i32* %batch103 to i8*, !dbg !32339
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %73) #285, !dbg !32339
  br label %for.end132

for.body111:                                      ; preds = %for.cond104
  br label %VITIS_LOOP_456_5, !dbg !32338

VITIS_LOOP_456_5:                                 ; preds = %for.body111
  %74 = bitcast i32* %row to i8*, !dbg !32340
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %74) #285, !dbg !32340
  call void @llvm.dbg.declare(metadata i32* %row, metadata !32342, metadata !DIExpression()), !dbg !32343
  store i32 0, i32* %row, align 4, !dbg !32343
  br label %for.cond112, !dbg !32340

for.cond112:                                      ; preds = %for.inc125, %VITIS_LOOP_456_5
  %75 = load i32, i32* %row, align 4, !dbg !32344
  %76 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32346
  %inputs113 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %76, i32 0, i32 0, !dbg !32347
  %identity114 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs113, i32 0, i32 0, !dbg !32348
  %S115 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity114, i32 0, i32 3, !dbg !32349
  %77 = load i16, i16* %S115, align 2, !dbg !32349
  %conv116 = zext i16 %77 to i32, !dbg !32346
  %cmp117 = icmp ult i32 %75, %conv116, !dbg !32350
  br i1 %cmp117, label %for.body119, label %for.cond.cleanup118, !dbg !32351

for.cond.cleanup118:                              ; preds = %for.cond112
  store i32 19, i32* %cleanup.dest.slot, align 4
  %78 = bitcast i32* %row to i8*, !dbg !32352
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %78) #285, !dbg !32352
  br label %for.end128

for.body119:                                      ; preds = %for.cond112
  %79 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32353
  %covered_rows = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %79, i32 0, i32 15, !dbg !32355
  %arraydecay120 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows, i64 0, i64 0, !dbg !32353
  %80 = load i32, i32* %batch103, align 4, !dbg !32356
  %mul = mul i32 %80, 1024, !dbg !32357
  %81 = load i32, i32* %row, align 4, !dbg !32358
  %add = add i32 %mul, %81, !dbg !32359
  call void @_ZN4laya4full12_GLOBAL__N_17set_bitEPjj(i32* %arraydecay120, i32 %add), !dbg !32360
  %82 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32361
  %covered_rows121 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %82, i32 0, i32 15, !dbg !32362
  %arraydecay122 = getelementptr inbounds [64 x i32], [64 x i32]* %covered_rows121, i64 0, i64 0, !dbg !32361
  %83 = load i32, i32* %batch103, align 4, !dbg !32363
  %mul123 = mul i32 %83, 1024, !dbg !32364
  %84 = load i32, i32* %row, align 4, !dbg !32365
  %add124 = add i32 %mul123, %84, !dbg !32366
  call void @_ZN4laya4full12_GLOBAL__N_17set_bitEPjj(i32* %arraydecay122, i32 %add124), !dbg !32367
  br label %for.inc125, !dbg !32368

for.inc125:                                       ; preds = %for.body119
  %85 = load i32, i32* %row, align 4, !dbg !32369
  %inc126 = add i32 %85, 1, !dbg !32369
  store i32 %inc126, i32* %row, align 4, !dbg !32369
  br label %for.cond112, !dbg !32352, !llvm.loop !32370

for.end128:                                       ; preds = %for.cond.cleanup118
  br label %for.inc129, !dbg !32371

for.inc129:                                       ; preds = %for.end128
  %86 = load i32, i32* %batch103, align 4, !dbg !32373
  %inc130 = add i32 %86, 1, !dbg !32373
  store i32 %inc130, i32* %batch103, align 4, !dbg !32373
  br label %for.cond104, !dbg !32339, !llvm.loop !32374

for.end132:                                       ; preds = %for.cond.cleanup110
  %87 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32377
  %state133 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %87, i32 0, i32 13, !dbg !32378
  store i8 2, i8* %state133, align 1, !dbg !32379
  %88 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32380
  %valid = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %88, i32 0, i32 17, !dbg !32381
  store i1 true, i1* %valid, align 4, !dbg !32382
  %89 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !32383
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %89) #285, !dbg !32383
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret align 4 %ref.tmp), !dbg !32383
  %90 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %first, align 8, !dbg !32384
  %lease_old_ref134 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %90, i32 0, i32 2, !dbg !32385
  %91 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp, align 4, !dbg !32386
  store %"struct.laya::BufferRef" %91, %"struct.laya::BufferRef"* %lease_old_ref134, align 8, !dbg !32386
  %92 = bitcast %"struct.laya::BufferRef"* %ref.tmp to i8*, !dbg !32384
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %92) #285, !dbg !32384
  %93 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32387
  %state135 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %93, i32 0, i32 13, !dbg !32388
  store i8 2, i8* %state135, align 1, !dbg !32389
  %94 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32390
  %valid136 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %94, i32 0, i32 17, !dbg !32391
  store i1 true, i1* %valid136, align 4, !dbg !32392
  %95 = bitcast %"struct.laya::BufferRef"* %ref.tmp137 to i8*, !dbg !32393
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %95) #285, !dbg !32393
  call void @_ZN4laya4noneEv(%"struct.laya::BufferRef"* sret align 4 %ref.tmp137), !dbg !32393
  %96 = load %"struct.laya::full::FullOwnerRecord"*, %"struct.laya::full::FullOwnerRecord"** %second, align 8, !dbg !32394
  %lease_old_ref138 = getelementptr inbounds %"struct.laya::full::FullOwnerRecord", %"struct.laya::full::FullOwnerRecord"* %96, i32 0, i32 2, !dbg !32395
  %97 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref.tmp137, align 4, !dbg !32396
  store %"struct.laya::BufferRef" %97, %"struct.laya::BufferRef"* %lease_old_ref138, align 8, !dbg !32396
  %98 = bitcast %"struct.laya::BufferRef"* %ref.tmp137 to i8*, !dbg !32394
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %98) #285, !dbg !32394
  %99 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32397
  %arrayidx139 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %99, i64 0, i64 0, !dbg !32397
  %ref140 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx139, i32 0, i32 0, !dbg !32398
  %100 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32399
  %final_qkv_ref = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %100, i32 0, i32 6, !dbg !32400
  %arrayidx141 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref, i64 0, i64 0, !dbg !32399
  %101 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref140, align 4, !dbg !32401
  store %"struct.laya::BufferRef" %101, %"struct.laya::BufferRef"* %arrayidx141, align 8, !dbg !32401
  %102 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %next_s.addr, align 8, !dbg !32402
  %arrayidx142 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %102, i64 0, i64 1, !dbg !32402
  %ref143 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx142, i32 0, i32 0, !dbg !32403
  %103 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !32404
  %final_qkv_ref144 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %103, i32 0, i32 6, !dbg !32405
  %arrayidx145 = getelementptr inbounds [2 x %"struct.laya::BufferRef"], [2 x %"struct.laya::BufferRef"]* %final_qkv_ref144, i64 0, i64 1, !dbg !32404
  %104 = load %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref143, align 4, !dbg !32406
  store %"struct.laya::BufferRef" %104, %"struct.laya::BufferRef"* %arrayidx145, align 8, !dbg !32406
  call void @_ZN4laya2okEv(%"struct.laya::Check"* sret align 8 %agg.result), !dbg !32407
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup146, !dbg !32408

cleanup146:                                       ; preds = %for.end132, %cleanup100, %if.then65
  %105 = bitcast %"struct.laya::full::FullOwnerRecord"** %second to i8*, !dbg !32409
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %105) #285, !dbg !32409
  %106 = bitcast %"struct.laya::full::FullOwnerRecord"** %first to i8*, !dbg !32409
  call void @llvm.lifetime.end.p0i8(i64 8, i8* %106) #285, !dbg !32409
  br label %cleanup148

cleanup148:                                       ; preds = %cleanup146, %if.then33
  %107 = bitcast i32* %second_index to i8*, !dbg !32409
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %107) #285, !dbg !32409
  %108 = bitcast i32* %first_index to i8*, !dbg !32409
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %108) #285, !dbg !32409
  br label %return

return:                                           ; preds = %cleanup148, %if.then
  ret void, !dbg !32409
}
