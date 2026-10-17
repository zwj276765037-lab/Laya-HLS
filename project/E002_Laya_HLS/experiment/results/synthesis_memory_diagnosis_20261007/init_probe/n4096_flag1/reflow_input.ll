; ModuleID = '/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n4096_flag1/work/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%struct.State = type { i8, [4096 x i8] }

@llvm.global_ctors = appending global [0 x { i32, void ()*, i8* }] zeroinitializer
@_ZL5state = internal global %struct.State { i8 1, [4096 x i8] zeroinitializer }, align 1, !dbg !0

; Function Attrs: nounwind
define dso_local zeroext i16 @init_probe_top(i32 %index, i8 zeroext %value) #0 !dbg !27 !fpga.function.pragma !32 {
entry:
  %index.addr = alloca i32, align 4
  %value.addr = alloca i8, align 1
  %i = alloca i32, align 4
  %old = alloca i8, align 1
  %oldflag = alloca i8, align 1
  store i32 %index, i32* %index.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %index.addr, metadata !35, metadata !DIExpression()), !dbg !36
  store i8 %value, i8* %value.addr, align 1
  call void @llvm.dbg.declare(metadata i8* %value.addr, metadata !37, metadata !DIExpression()), !dbg !38
  call void @llvm.sideeffect() #4 [ "xlx_s_axilite"(i32 %index, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !39
  call void @llvm.sideeffect() #5 [ "xlx_s_axilite"(i8 %value, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !40
  call void @llvm.sideeffect() #6 [ "xlx_s_axilite"(i8* null, [7 x i8] c"control", i64 -1, i32 -1, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, [0 x i8] zeroinitializer, i32 0) ], !dbg !41
  call void @llvm.sideeffect() #7 [ "xlx_bind_storage"([4096 x i8]* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 1), i32 666, i32 20, i32 -1, i1 false) ], !dbg !42
  %0 = bitcast i32* %i to i8*, !dbg !43
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #8, !dbg !43
  call void @llvm.dbg.declare(metadata i32* %i, metadata !44, metadata !DIExpression()), !dbg !46
  %1 = load i32, i32* %index.addr, align 4, !dbg !47
  %and = and i32 %1, 4095, !dbg !48
  store i32 %and, i32* %i, align 4, !dbg !46
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %old) #8, !dbg !49
  call void @llvm.dbg.declare(metadata i8* %old, metadata !50, metadata !DIExpression()), !dbg !52
  %2 = load i32, i32* %i, align 4, !dbg !53
  %idxprom = zext i32 %2 to i64, !dbg !54
  %arrayidx = getelementptr inbounds [4096 x i8], [4096 x i8]* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 1), i64 0, i64 %idxprom, !dbg !54
  %3 = load i8, i8* %arrayidx, align 1, !dbg !54
  store i8 %3, i8* %old, align 1, !dbg !52
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %oldflag) #8, !dbg !55
  call void @llvm.dbg.declare(metadata i8* %oldflag, metadata !56, metadata !DIExpression()), !dbg !57
  %4 = load i8, i8* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 0), align 1, !dbg !58
  store i8 %4, i8* %oldflag, align 1, !dbg !57
  %5 = load i8, i8* %value.addr, align 1, !dbg !59
  %6 = load i32, i32* %i, align 4, !dbg !60
  %idxprom1 = zext i32 %6 to i64, !dbg !61
  %arrayidx2 = getelementptr inbounds [4096 x i8], [4096 x i8]* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 1), i64 0, i64 %idxprom1, !dbg !61
  store i8 %5, i8* %arrayidx2, align 1, !dbg !62
  %7 = load i8, i8* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 0), align 1, !dbg !63
  %conv = zext i8 %7 to i32, !dbg !64
  %8 = load i8, i8* %value.addr, align 1, !dbg !65
  %conv3 = zext i8 %8 to i32, !dbg !65
  %xor = xor i32 %conv, %conv3, !dbg !66
  %conv4 = trunc i32 %xor to i8, !dbg !64
  store i8 %conv4, i8* getelementptr inbounds (%struct.State, %struct.State* @_ZL5state, i32 0, i32 0), align 1, !dbg !67
  %9 = load i8, i8* %old, align 1, !dbg !68
  %conv5 = zext i8 %9 to i16, !dbg !68
  %conv6 = zext i16 %conv5 to i32, !dbg !69
  %10 = load i8, i8* %oldflag, align 1, !dbg !70
  %conv7 = zext i8 %10 to i16, !dbg !70
  %conv8 = zext i16 %conv7 to i32, !dbg !71
  %shl = shl i32 %conv8, 8, !dbg !72
  %or = or i32 %conv6, %shl, !dbg !73
  %conv9 = trunc i32 %or to i16, !dbg !69
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %oldflag) #8, !dbg !74
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %old) #8, !dbg !74
  %11 = bitcast i32* %i to i8*, !dbg !74
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %11) #8, !dbg !74
  ret i16 %conv9, !dbg !75
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: inaccessiblememonly nounwind willreturn
declare void @llvm.sideeffect() #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #3

attributes #0 = { nounwind "fpga.demangled.name"="init_probe_top" "fpga.top.func"="init_probe_top" "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nounwind readnone speculatable willreturn }
attributes #2 = { inaccessiblememonly nounwind willreturn }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="32" "xlx.source"="user" }
attributes #5 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="8" "xlx.source"="user" }
attributes #6 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="0" "xlx.source"="user" }
attributes #7 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="32768" "xlx.source"="user" }
attributes #8 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.ident = !{!22, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23, !23}
!llvm.module.flags = !{!24, !25, !26}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "state", linkageName: "_ZL5state", scope: !2, file: !14, line: 15, type: !15, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !3, producer: "AMD/Xilinx clang version 16.0.6", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !4, globals: !13, splitDebugInlining: false, gnuPubnames: true)
!3 = !DIFile(filename: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n4096_flag1/work/hls/.autopilot/db/init_probe.pp.0.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n4096_flag1", checksumkind: CSK_MD5, checksum: "924e374ff01683f5d6a52e1d11fedef5")
!4 = !{!5, !10}
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !6, line: 24, baseType: !7)
!6 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !8, line: 38, baseType: !9)
!8 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!9 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !6, line: 25, baseType: !11)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !8, line: 40, baseType: !12)
!12 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!13 = !{!0}
!14 = !DIFile(filename: "../init_probe.cpp", directory: "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/synthesis_memory_diagnosis_20261007/init_probe/n4096_flag1")
!15 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "State", file: !14, line: 10, size: 32776, flags: DIFlagTypePassByValue, elements: !16, identifier: "_ZTS5State")
!16 = !{!17, !18}
!17 = !DIDerivedType(tag: DW_TAG_member, name: "flag", scope: !15, file: !14, line: 11, baseType: !5, size: 8)
!18 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !15, file: !14, line: 12, baseType: !19, size: 32768, offset: 8)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !5, size: 32768, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 4096)
!22 = !{!"AMD/Xilinx clang version 16.0.6"}
!23 = !{!"clang version 7.0.0 "}
!24 = !{i32 2, !"Dwarf Version", i32 4}
!25 = !{i32 2, !"Debug Info Version", i32 3}
!26 = !{i32 1, !"wchar_size", i32 4}
!27 = distinct !DISubprogram(name: "init_probe_top", scope: !14, file: !14, line: 17, type: !28, isLocal: false, isDefinition: true, scopeLine: 17, flags: DIFlagPrototyped, isOptimized: false, unit: !2, variables: !31)
!28 = !DISubroutineType(types: !29)
!29 = !{!10, !30, !5}
!30 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!31 = !{}
!32 = !{!33}
!33 = !{!"fpga.top", !"user", !34}
!34 = !DILocation(line: 17, column: 27, scope: !27)
!35 = !DILocalVariable(name: "index", arg: 1, scope: !27, file: !14, line: 17, type: !30)
!36 = !DILocation(line: 17, column: 94, scope: !27)
!37 = !DILocalVariable(name: "value", arg: 2, scope: !27, file: !14, line: 17, type: !5)
!38 = !DILocation(line: 17, column: 109, scope: !27)
!39 = !DILocation(line: 18, column: 1, scope: !27)
!40 = !DILocation(line: 19, column: 1, scope: !27)
!41 = !DILocation(line: 20, column: 1, scope: !27)
!42 = !DILocation(line: 21, column: 1, scope: !27)
!43 = !DILocation(line: 22, column: 3, scope: !27)
!44 = !DILocalVariable(name: "i", scope: !27, file: !14, line: 22, type: !45)
!45 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !30)
!46 = !DILocation(line: 22, column: 18, scope: !27)
!47 = !DILocation(line: 22, column: 22, scope: !27)
!48 = !DILocation(line: 22, column: 28, scope: !27)
!49 = !DILocation(line: 23, column: 3, scope: !27)
!50 = !DILocalVariable(name: "old", scope: !27, file: !14, line: 23, type: !51)
!51 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5)
!52 = !DILocation(line: 23, column: 17, scope: !27)
!53 = !DILocation(line: 23, column: 34, scope: !27)
!54 = !DILocation(line: 23, column: 23, scope: !27)
!55 = !DILocation(line: 24, column: 3, scope: !27)
!56 = !DILocalVariable(name: "oldflag", scope: !27, file: !14, line: 24, type: !51)
!57 = !DILocation(line: 24, column: 17, scope: !27)
!58 = !DILocation(line: 24, column: 33, scope: !27)
!59 = !DILocation(line: 25, column: 19, scope: !27)
!60 = !DILocation(line: 25, column: 14, scope: !27)
!61 = !DILocation(line: 25, column: 3, scope: !27)
!62 = !DILocation(line: 25, column: 17, scope: !27)
!63 = !DILocation(line: 26, column: 43, scope: !27)
!64 = !DILocation(line: 26, column: 37, scope: !27)
!65 = !DILocation(line: 26, column: 50, scope: !27)
!66 = !DILocation(line: 26, column: 48, scope: !27)
!67 = !DILocation(line: 26, column: 14, scope: !27)
!68 = !DILocation(line: 27, column: 32, scope: !27)
!69 = !DILocation(line: 27, column: 10, scope: !27)
!70 = !DILocation(line: 28, column: 33, scope: !27)
!71 = !DILocation(line: 28, column: 11, scope: !27)
!72 = !DILocation(line: 28, column: 42, scope: !27)
!73 = !DILocation(line: 27, column: 37, scope: !27)
!74 = !DILocation(line: 29, column: 1, scope: !27)
!75 = !DILocation(line: 27, column: 3, scope: !27)
