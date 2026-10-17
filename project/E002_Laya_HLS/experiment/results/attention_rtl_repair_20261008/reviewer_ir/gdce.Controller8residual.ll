define internal void @_ZN4laya4full12_GLOBAL__N_110Controller8residualEhhRKNS0_13FullOwnerSpecERS3_(%"struct.laya::Check"* noalias sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this, i8 zeroext %stage, i8 zeroext %layer, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %tmp, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %hidden) #62 align 2 !dbg !18187 !type !18188 {
entry:
  %this.addr = alloca %"struct.laya::full::(anonymous namespace)::Controller"*, align 8
  %stage.addr = alloca i8, align 1
  %layer.addr = alloca i8, align 1
  %tmp.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %hidden.addr = alloca %"struct.laya::full::FullOwnerSpec"*, align 8
  %next = alloca %"struct.laya::full::FullOwnerSpec", align 4
  %agg.tmp = alloca %"struct.laya::BufferRef", align 4
  %ref.tmp = alloca %"struct.laya::Check", align 8
  %ref.tmp5 = alloca %"struct.laya::Check", align 8
  store %"struct.laya::full::(anonymous namespace)::Controller"* %this, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, metadata !18190, metadata !DIExpression()), !dbg !18191
  store i8 %stage, i8* %stage.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %stage.addr, metadata !18192, metadata !DIExpression()), !dbg !18193
  store i8 %layer, i8* %layer.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %layer.addr, metadata !18194, metadata !DIExpression()), !dbg !18195
  store %"struct.laya::full::FullOwnerSpec"* %tmp, %"struct.laya::full::FullOwnerSpec"** %tmp.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %tmp.addr, metadata !18196, metadata !DIExpression()), !dbg !18197
  store %"struct.laya::full::FullOwnerSpec"* %hidden, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"** %hidden.addr, metadata !18198, metadata !DIExpression()), !dbg !18199
  %this1 = load %"struct.laya::full::(anonymous namespace)::Controller"*, %"struct.laya::full::(anonymous namespace)::Controller"** %this.addr, align 8
  %0 = load i8, i8* %stage.addr, align 1, !dbg !18200
  call void @_ZN4laya4full12_GLOBAL__N_110Controller5phaseEhNS_2OpE(%"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext %0, i8 zeroext 98), !dbg !18201
  %1 = bitcast %"struct.laya::full::FullOwnerSpec"* %next to i8*, !dbg !18202
  call void @llvm.lifetime.start.p0i8(i64 24, i8* %1) #285, !dbg !18202
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullOwnerSpec"* %next, metadata !18203, metadata !DIExpression()), !dbg !18204
  call void @_ZN4laya4full13FullOwnerSpecC2Ev(%"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %next) #285, !dbg !18204
  call void @llvm.dbg.declare(metadata %"struct.laya::Check"* %agg.result, metadata !18205, metadata !DIExpression()), !dbg !18206
  %2 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %tmp.addr, align 8, !dbg !18207
  %3 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18208
  %4 = load i8, i8* %stage.addr, align 1, !dbg !18209
  %5 = load i8, i8* %layer.addr, align 1, !dbg !18210
  %6 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18211
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %6, i32 0, i32 0, !dbg !18212
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 1, !dbg !18213
  %7 = load i8, i8* %bank, align 1, !dbg !18213
  %conv = zext i8 %7 to i32, !dbg !18211
  %sub = sub nsw i32 1, %conv, !dbg !18214
  %conv2 = trunc i32 %sub to i8, !dbg !18215
  call void @_ZNK4laya4full12_GLOBAL__N_110Controller5freshENS_6BufferEhh(%"struct.laya::BufferRef"* sret align 4 %agg.tmp, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 1, i8 zeroext %conv2, i8 zeroext 0), !dbg !18216
  call void @_ZN4laya4full12_GLOBAL__N_110Controller6vectorENS_2OpERKNS0_13FullOwnerSpecEPS5_hhNS_9BufferRefEhtRS4_(%"struct.laya::Check"* sret align 8 %agg.result, %"struct.laya::full::(anonymous namespace)::Controller"* nonnull align 8 dereferenceable(32) %this1, i8 zeroext 98, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %2, %"struct.laya::full::FullOwnerSpec"* %3, i8 zeroext %4, i8 zeroext %5, %"struct.laya::BufferRef"* byval align 4 %agg.tmp, i8 zeroext 0, i16 zeroext 1024, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %next), !dbg !18217
  %call = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18218
  br i1 %call, label %if.then, label %if.end, !dbg !18220

if.then:                                          ; preds = %entry
  %8 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !18221
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %8) #285, !dbg !18221
  %rt = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18222
  %9 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt, align 8, !dbg !18222
  %10 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %tmp.addr, align 8, !dbg !18223
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %9, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %10), !dbg !18221
  %11 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp, align 8, !dbg !18224
  store %"struct.laya::Check" %11, %"struct.laya::Check"* %agg.result, align 8, !dbg !18224
  %12 = bitcast %"struct.laya::Check"* %ref.tmp to i8*, !dbg !18225
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %12) #285, !dbg !18225
  br label %if.end, !dbg !18225

if.end:                                           ; preds = %if.then, %entry
  %call3 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18226
  br i1 %call3, label %if.then4, label %if.end7, !dbg !18228

if.then4:                                         ; preds = %if.end
  %13 = bitcast %"struct.laya::Check"* %ref.tmp5 to i8*, !dbg !18229
  call void @llvm.lifetime.start.p0i8(i64 16, i8* %13) #285, !dbg !18229
  %rt6 = getelementptr inbounds %"struct.laya::full::(anonymous namespace)::Controller", %"struct.laya::full::(anonymous namespace)::Controller"* %this1, i32 0, i32 0, !dbg !18230
  %14 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt6, align 8, !dbg !18230
  %15 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18231
  call void @_ZN4laya4full18full_release_ownerERNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::Check"* sret align 8 %ref.tmp5, %"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %14, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %15), !dbg !18229
  %16 = load %"struct.laya::Check", %"struct.laya::Check"* %ref.tmp5, align 8, !dbg !18232
  store %"struct.laya::Check" %16, %"struct.laya::Check"* %agg.result, align 8, !dbg !18232
  %17 = bitcast %"struct.laya::Check"* %ref.tmp5 to i8*, !dbg !18233
  call void @llvm.lifetime.end.p0i8(i64 16, i8* %17) #285, !dbg !18233
  br label %if.end7, !dbg !18233

if.end7:                                          ; preds = %if.then4, %if.end
  %call8 = call zeroext i1 @_ZNK4laya5CheckcvbEv(%"struct.laya::Check"* nonnull align 8 dereferenceable(16) %agg.result), !dbg !18234
  br i1 %call8, label %if.then9, label %if.end10, !dbg !18236

if.then9:                                         ; preds = %if.end7
  %18 = load %"struct.laya::full::FullOwnerSpec"*, %"struct.laya::full::FullOwnerSpec"** %hidden.addr, align 8, !dbg !18237
  %19 = load %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %next, align 4, !dbg !18238
  store %"struct.laya::full::FullOwnerSpec" %19, %"struct.laya::full::FullOwnerSpec"* %18, align 4, !dbg !18238
  br label %if.end10, !dbg !18237

if.end10:                                         ; preds = %if.then9, %if.end7
  %20 = bitcast %"struct.laya::full::FullOwnerSpec"* %next to i8*, !dbg !18239
  call void @llvm.lifetime.end.p0i8(i64 24, i8* %20) #285, !dbg !18239
  ret void, !dbg !18239
}
