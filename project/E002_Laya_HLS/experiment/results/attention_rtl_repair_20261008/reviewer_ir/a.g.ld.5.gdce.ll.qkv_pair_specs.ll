define internal zeroext i1 @_ZN4laya4full12_GLOBAL__N_114qkv_pair_specsERKNS0_11FullRuntimeERA2_KNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %rt, [2 x %"struct.laya::full::FullOwnerSpec"]* nonnull align 4 dereferenceable(48) %s) #195 !dbg !36004 {
entry:
  %rt.addr = alloca %"struct.laya::full::FullRuntime"*, align 8
  %s.addr = alloca [2 x %"struct.laya::full::FullOwnerSpec"]*, align 8
  store %"struct.laya::full::FullRuntime"* %rt, %"struct.laya::full::FullRuntime"** %rt.addr, align 8
  call void @llvm.dbg.declare(metadata %"struct.laya::full::FullRuntime"** %rt.addr, metadata !36007, metadata !DIExpression()), !dbg !36008
  store [2 x %"struct.laya::full::FullOwnerSpec"]* %s, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8
  call void @llvm.dbg.declare(metadata [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, metadata !36009, metadata !DIExpression()), !dbg !36010
  %0 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !36011
  %1 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36012
  %arrayidx = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %1, i64 0, i64 0, !dbg !36012
  %call = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %0, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx), !dbg !36013
  br i1 %call, label %land.lhs.true, label %land.end112, !dbg !36014

land.lhs.true:                                    ; preds = %entry
  %2 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !36015
  %3 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36016
  %arrayidx1 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %3, i64 0, i64 1, !dbg !36016
  %call2 = call zeroext i1 @_ZN4laya4full12_GLOBAL__N_110legal_specERKNS0_11FullRuntimeERKNS0_13FullOwnerSpecE(%"struct.laya::full::FullRuntime"* nonnull align 8 dereferenceable(78704) %2, %"struct.laya::full::FullOwnerSpec"* nonnull align 4 dereferenceable(24) %arrayidx1), !dbg !36017
  br i1 %call2, label %land.lhs.true3, label %land.end112, !dbg !36018

land.lhs.true3:                                   ; preds = %land.lhs.true
  %4 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36019
  %arrayidx4 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %4, i64 0, i64 0, !dbg !36019
  %ref = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx4, i32 0, i32 0, !dbg !36020
  %id = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref, i32 0, i32 0, !dbg !36021
  %5 = load i8, i8* %id, align 4, !dbg !36021
  %cmp = icmp eq i8 %5, 5, !dbg !36022
  br i1 %cmp, label %land.lhs.true5, label %land.end112, !dbg !36023

land.lhs.true5:                                   ; preds = %land.lhs.true3
  %6 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36024
  %arrayidx6 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %6, i64 0, i64 1, !dbg !36024
  %ref7 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx6, i32 0, i32 0, !dbg !36025
  %id8 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref7, i32 0, i32 0, !dbg !36026
  %7 = load i8, i8* %id8, align 4, !dbg !36026
  %cmp9 = icmp eq i8 %7, 5, !dbg !36027
  br i1 %cmp9, label %land.lhs.true10, label %land.end112, !dbg !36028

land.lhs.true10:                                  ; preds = %land.lhs.true5
  %8 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36029
  %arrayidx11 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %8, i64 0, i64 0, !dbg !36029
  %ref12 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx11, i32 0, i32 0, !dbg !36030
  %bank = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref12, i32 0, i32 1, !dbg !36031
  %9 = load i8, i8* %bank, align 1, !dbg !36031
  %conv = zext i8 %9 to i32, !dbg !36029
  %cmp13 = icmp eq i32 %conv, 0, !dbg !36032
  br i1 %cmp13, label %land.lhs.true14, label %land.end112, !dbg !36033

land.lhs.true14:                                  ; preds = %land.lhs.true10
  %10 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36034
  %arrayidx15 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %10, i64 0, i64 1, !dbg !36034
  %ref16 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx15, i32 0, i32 0, !dbg !36035
  %bank17 = getelementptr inbounds %"struct.laya::BufferRef", %"struct.laya::BufferRef"* %ref16, i32 0, i32 1, !dbg !36036
  %11 = load i8, i8* %bank17, align 1, !dbg !36036
  %conv18 = zext i8 %11 to i32, !dbg !36034
  %cmp19 = icmp eq i32 %conv18, 1, !dbg !36037
  br i1 %cmp19, label %land.lhs.true20, label %land.end112, !dbg !36038

land.lhs.true20:                                  ; preds = %land.lhs.true14
  %12 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36039
  %arrayidx21 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %12, i64 0, i64 0, !dbg !36039
  %region = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx21, i32 0, i32 1, !dbg !36040
  %13 = load i8, i8* %region, align 4, !dbg !36040
  %conv22 = zext i8 %13 to i32, !dbg !36039
  %cmp23 = icmp eq i32 %conv22, 0, !dbg !36041
  br i1 %cmp23, label %land.lhs.true24, label %land.end112, !dbg !36042

land.lhs.true24:                                  ; preds = %land.lhs.true20
  %14 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36043
  %arrayidx25 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %14, i64 0, i64 1, !dbg !36043
  %region26 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx25, i32 0, i32 1, !dbg !36044
  %15 = load i8, i8* %region26, align 4, !dbg !36044
  %conv27 = zext i8 %15 to i32, !dbg !36043
  %cmp28 = icmp eq i32 %conv27, 0, !dbg !36045
  br i1 %cmp28, label %land.lhs.true29, label %land.end112, !dbg !36046

land.lhs.true29:                                  ; preds = %land.lhs.true24
  %16 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36047
  %arrayidx30 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %16, i64 0, i64 0, !dbg !36047
  %batch = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx30, i32 0, i32 4, !dbg !36048
  %17 = load i8, i8* %batch, align 1, !dbg !36048
  %conv31 = zext i8 %17 to i32, !dbg !36047
  %cmp32 = icmp eq i32 %conv31, 255, !dbg !36049
  br i1 %cmp32, label %land.lhs.true33, label %land.end112, !dbg !36050

land.lhs.true33:                                  ; preds = %land.lhs.true29
  %18 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36051
  %arrayidx34 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %18, i64 0, i64 1, !dbg !36051
  %batch35 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx34, i32 0, i32 4, !dbg !36052
  %19 = load i8, i8* %batch35, align 1, !dbg !36052
  %conv36 = zext i8 %19 to i32, !dbg !36051
  %cmp37 = icmp eq i32 %conv36, 255, !dbg !36053
  br i1 %cmp37, label %land.lhs.true38, label %land.end112, !dbg !36054

land.lhs.true38:                                  ; preds = %land.lhs.true33
  %20 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36055
  %arrayidx39 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %20, i64 0, i64 0, !dbg !36055
  %row_space = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx39, i32 0, i32 5, !dbg !36056
  %21 = load i8, i8* %row_space, align 4, !dbg !36056
  %cmp40 = icmp eq i8 %21, 0, !dbg !36057
  br i1 %cmp40, label %land.lhs.true41, label %land.end112, !dbg !36058

land.lhs.true41:                                  ; preds = %land.lhs.true38
  %22 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36059
  %arrayidx42 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %22, i64 0, i64 1, !dbg !36059
  %row_space43 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx42, i32 0, i32 5, !dbg !36060
  %23 = load i8, i8* %row_space43, align 4, !dbg !36060
  %cmp44 = icmp eq i8 %23, 0, !dbg !36061
  br i1 %cmp44, label %land.lhs.true45, label %land.end112, !dbg !36062

land.lhs.true45:                                  ; preds = %land.lhs.true41
  %24 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36063
  %arrayidx46 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %24, i64 0, i64 0, !dbg !36063
  %row0 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx46, i32 0, i32 6, !dbg !36064
  %25 = load i16, i16* %row0, align 2, !dbg !36064
  %conv47 = zext i16 %25 to i32, !dbg !36063
  %cmp48 = icmp eq i32 %conv47, 0, !dbg !36065
  br i1 %cmp48, label %land.lhs.true49, label %land.end112, !dbg !36066

land.lhs.true49:                                  ; preds = %land.lhs.true45
  %26 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36067
  %arrayidx50 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %26, i64 0, i64 1, !dbg !36067
  %row051 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx50, i32 0, i32 6, !dbg !36068
  %27 = load i16, i16* %row051, align 2, !dbg !36068
  %conv52 = zext i16 %27 to i32, !dbg !36067
  %cmp53 = icmp eq i32 %conv52, 0, !dbg !36069
  br i1 %cmp53, label %land.lhs.true54, label %land.end112, !dbg !36070

land.lhs.true54:                                  ; preds = %land.lhs.true49
  %28 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36071
  %arrayidx55 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %28, i64 0, i64 0, !dbg !36071
  %rows = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx55, i32 0, i32 7, !dbg !36072
  %29 = load i16, i16* %rows, align 4, !dbg !36072
  %conv56 = zext i16 %29 to i32, !dbg !36071
  %30 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !36073
  %inputs = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %30, i32 0, i32 0, !dbg !36074
  %identity = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs, i32 0, i32 0, !dbg !36075
  %S = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity, i32 0, i32 3, !dbg !36076
  %31 = load i16, i16* %S, align 2, !dbg !36076
  %conv57 = zext i16 %31 to i32, !dbg !36073
  %cmp58 = icmp eq i32 %conv56, %conv57, !dbg !36077
  br i1 %cmp58, label %land.lhs.true59, label %land.end112, !dbg !36078

land.lhs.true59:                                  ; preds = %land.lhs.true54
  %32 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36079
  %arrayidx60 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %32, i64 0, i64 1, !dbg !36079
  %rows61 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx60, i32 0, i32 7, !dbg !36080
  %33 = load i16, i16* %rows61, align 4, !dbg !36080
  %conv62 = zext i16 %33 to i32, !dbg !36079
  %34 = load %"struct.laya::full::FullRuntime"*, %"struct.laya::full::FullRuntime"** %rt.addr, align 8, !dbg !36081
  %inputs63 = getelementptr inbounds %"struct.laya::full::FullRuntime", %"struct.laya::full::FullRuntime"* %34, i32 0, i32 0, !dbg !36082
  %identity64 = getelementptr inbounds %"struct.laya::full::FullInputs", %"struct.laya::full::FullInputs"* %inputs63, i32 0, i32 0, !dbg !36083
  %S65 = getelementptr inbounds %"struct.laya::NumericIdentity", %"struct.laya::NumericIdentity"* %identity64, i32 0, i32 3, !dbg !36084
  %35 = load i16, i16* %S65, align 2, !dbg !36084
  %conv66 = zext i16 %35 to i32, !dbg !36081
  %cmp67 = icmp eq i32 %conv62, %conv66, !dbg !36085
  br i1 %cmp67, label %land.lhs.true68, label %land.end112, !dbg !36086

land.lhs.true68:                                  ; preds = %land.lhs.true59
  %36 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36087
  %arrayidx69 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %36, i64 0, i64 0, !dbg !36087
  %stage = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx69, i32 0, i32 2, !dbg !36088
  %37 = load i8, i8* %stage, align 1, !dbg !36088
  %conv70 = zext i8 %37 to i32, !dbg !36087
  %38 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36089
  %arrayidx71 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %38, i64 0, i64 1, !dbg !36089
  %stage72 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx71, i32 0, i32 2, !dbg !36090
  %39 = load i8, i8* %stage72, align 1, !dbg !36090
  %conv73 = zext i8 %39 to i32, !dbg !36089
  %cmp74 = icmp eq i32 %conv70, %conv73, !dbg !36091
  br i1 %cmp74, label %land.lhs.true75, label %land.end112, !dbg !36092

land.lhs.true75:                                  ; preds = %land.lhs.true68
  %40 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36093
  %arrayidx76 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %40, i64 0, i64 0, !dbg !36093
  %layer = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx76, i32 0, i32 3, !dbg !36094
  %41 = load i8, i8* %layer, align 2, !dbg !36094
  %conv77 = zext i8 %41 to i32, !dbg !36093
  %42 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36095
  %arrayidx78 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %42, i64 0, i64 1, !dbg !36095
  %layer79 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx78, i32 0, i32 3, !dbg !36096
  %43 = load i8, i8* %layer79, align 2, !dbg !36096
  %conv80 = zext i8 %43 to i32, !dbg !36095
  %cmp81 = icmp eq i32 %conv77, %conv80, !dbg !36097
  br i1 %cmp81, label %land.lhs.true82, label %land.end112, !dbg !36098

land.lhs.true82:                                  ; preds = %land.lhs.true75
  %44 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36099
  %arrayidx83 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %44, i64 0, i64 0, !dbg !36099
  %width = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx83, i32 0, i32 8, !dbg !36100
  %45 = load i16, i16* %width, align 2, !dbg !36100
  %conv84 = zext i16 %45 to i32, !dbg !36099
  %cmp85 = icmp eq i32 %conv84, 64, !dbg !36101
  br i1 %cmp85, label %land.lhs.true86, label %land.end112, !dbg !36102

land.lhs.true86:                                  ; preds = %land.lhs.true82
  %46 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36103
  %arrayidx87 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %46, i64 0, i64 1, !dbg !36103
  %width88 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx87, i32 0, i32 8, !dbg !36104
  %47 = load i16, i16* %width88, align 2, !dbg !36104
  %conv89 = zext i16 %47 to i32, !dbg !36103
  %cmp90 = icmp eq i32 %conv89, 64, !dbg !36105
  br i1 %cmp90, label %land.lhs.true91, label %land.end112, !dbg !36106

land.lhs.true91:                                  ; preds = %land.lhs.true86
  %48 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36107
  %arrayidx92 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %48, i64 0, i64 0, !dbg !36107
  %content = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx92, i32 0, i32 9, !dbg !36108
  %49 = load i8, i8* %content, align 4, !dbg !36108
  %50 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36109
  %arrayidx93 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %50, i64 0, i64 1, !dbg !36109
  %content94 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx93, i32 0, i32 9, !dbg !36110
  %51 = load i8, i8* %content94, align 4, !dbg !36110
  %cmp95 = icmp eq i8 %49, %51, !dbg !36111
  br i1 %cmp95, label %land.rhs, label %land.end112, !dbg !36112

land.rhs:                                         ; preds = %land.lhs.true91
  %52 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36113
  %arrayidx96 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %52, i64 0, i64 0, !dbg !36113
  %stage97 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx96, i32 0, i32 2, !dbg !36114
  %53 = load i8, i8* %stage97, align 1, !dbg !36114
  %conv98 = zext i8 %53 to i32, !dbg !36113
  %cmp99 = icmp eq i32 %conv98, 2, !dbg !36115
  br i1 %cmp99, label %land.lhs.true100, label %lor.rhs, !dbg !36116

land.lhs.true100:                                 ; preds = %land.rhs
  %54 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36117
  %arrayidx101 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %54, i64 0, i64 0, !dbg !36117
  %content102 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx101, i32 0, i32 9, !dbg !36118
  %55 = load i8, i8* %content102, align 4, !dbg !36118
  %cmp103 = icmp eq i8 %55, 2, !dbg !36119
  br i1 %cmp103, label %lor.end, label %lor.rhs, !dbg !36120

lor.rhs:                                          ; preds = %land.lhs.true100, %land.rhs
  %56 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36121
  %arrayidx104 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %56, i64 0, i64 0, !dbg !36121
  %stage105 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx104, i32 0, i32 2, !dbg !36122
  %57 = load i8, i8* %stage105, align 1, !dbg !36122
  %conv106 = zext i8 %57 to i32, !dbg !36121
  %cmp107 = icmp eq i32 %conv106, 4, !dbg !36123
  br i1 %cmp107, label %land.rhs108, label %land.end, !dbg !36124

land.rhs108:                                      ; preds = %lor.rhs
  %58 = load [2 x %"struct.laya::full::FullOwnerSpec"]*, [2 x %"struct.laya::full::FullOwnerSpec"]** %s.addr, align 8, !dbg !36125
  %arrayidx109 = getelementptr inbounds [2 x %"struct.laya::full::FullOwnerSpec"], [2 x %"struct.laya::full::FullOwnerSpec"]* %58, i64 0, i64 0, !dbg !36125
  %content110 = getelementptr inbounds %"struct.laya::full::FullOwnerSpec", %"struct.laya::full::FullOwnerSpec"* %arrayidx109, i32 0, i32 9, !dbg !36126
  %59 = load i8, i8* %content110, align 4, !dbg !36126
  %cmp111 = icmp eq i8 %59, 3, !dbg !36127
  br label %land.end

land.end:                                         ; preds = %land.rhs108, %lor.rhs
  %60 = phi i1 [ false, %lor.rhs ], [ %cmp111, %land.rhs108 ], !dbg !36128
  br label %lor.end, !dbg !36120

lor.end:                                          ; preds = %land.end, %land.lhs.true100
  %61 = phi i1 [ true, %land.lhs.true100 ], [ %60, %land.end ]
  br label %land.end112

land.end112:                                      ; preds = %lor.end, %land.lhs.true91, %land.lhs.true86, %land.lhs.true82, %land.lhs.true75, %land.lhs.true68, %land.lhs.true59, %land.lhs.true54, %land.lhs.true49, %land.lhs.true45, %land.lhs.true41, %land.lhs.true38, %land.lhs.true33, %land.lhs.true29, %land.lhs.true24, %land.lhs.true20, %land.lhs.true14, %land.lhs.true10, %land.lhs.true5, %land.lhs.true3, %land.lhs.true, %entry
  %62 = phi i1 [ false, %land.lhs.true91 ], [ false, %land.lhs.true86 ], [ false, %land.lhs.true82 ], [ false, %land.lhs.true75 ], [ false, %land.lhs.true68 ], [ false, %land.lhs.true59 ], [ false, %land.lhs.true54 ], [ false, %land.lhs.true49 ], [ false, %land.lhs.true45 ], [ false, %land.lhs.true41 ], [ false, %land.lhs.true38 ], [ false, %land.lhs.true33 ], [ false, %land.lhs.true29 ], [ false, %land.lhs.true24 ], [ false, %land.lhs.true20 ], [ false, %land.lhs.true14 ], [ false, %land.lhs.true10 ], [ false, %land.lhs.true5 ], [ false, %land.lhs.true3 ], [ false, %land.lhs.true ], [ false, %entry ], [ %61, %lor.end ], !dbg !36128
  ret i1 %62, !dbg !36129
}
