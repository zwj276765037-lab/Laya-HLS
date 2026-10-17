define internal void @"(anonymous namespace)::linear_impl.1"(i16* noalias nocapture align 512 %ref.tmp.0165, i32* noalias nocapture align 512 %ref.tmp.1166, i8 %conv7, i8 %layer, i32 %add, i8 %load_ok, i8* noalias nocapture align 512 %output.ref.id, i8* noalias nocapture align 512 %output.ref.bank, i32* noalias nocapture align 512 %output.ref.epoch, i8* noalias nocapture align 512 %output.region, i8* noalias nocapture align 512 %output.stage, i8* noalias nocapture align 512 %output.layer, i8* noalias nocapture align 512 %output.batch, i8* noalias nocapture align 512 %output.row_space, i16* noalias nocapture align 512 %output.row0, i16* noalias nocapture align 512 %output.rows, i16* noalias nocapture align 512 %output.width, i8* noalias nocapture align 512 %output.content, i8* noalias nocapture align 512 %probe.output.ref.id, i8* noalias nocapture align 512 %probe.output.ref.bank, i32* noalias nocapture align 512 %probe.output.ref.epoch, i8* noalias nocapture align 512 %probe.output.region, i8* noalias nocapture align 512 %probe.output.stage, i8* noalias nocapture align 512 %probe.output.layer, i8* noalias nocapture align 512 %probe.output.batch, i8* noalias nocapture align 512 %probe.output.row_space, i16* noalias nocapture align 512 %probe.output.row0, i16* noalias nocapture align 512 %probe.output.rows, i16* noalias nocapture align 512 %probe.output.width, i8* noalias nocapture align 512 %probe.output.content) #0 {
newFuncRoot:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1)
  %tobool.i.i = icmp ne i8 %load_ok, 0
  %c.detail.0.i = select i1 %tobool.i.i, i32 0, i32 67108881
  %c.code.0.i = select i1 %tobool.i.i, i16 0, i16 5
  br i1 %tobool.i.i, label %if.end.i, label %if.then.i

if.then.i:                                        ; preds = %newFuncRoot
  br label %_ZN12_GLOBAL__N_111linear_implEN4laya2OpERKNS0_4full13FullOwnerSpecEhhjhRS3_PS3_RNS_5ProbeE.69.76.82.88.108.114.158.164.208.214.260.266.312.318.363.369.413.419.464.exit

if.end.i:                                         ; preds = %newFuncRoot
  %cmp1.i = icmp eq i8 %conv7, 4
  %cond2.i = select i1 %cmp1.i, i8 3, i8 2
  store i8 5, i8* %output.ref.id, align 512, !alias.scope !336, !noalias !339
  store i8 0, i8* %output.ref.bank, align 512, !alias.scope !366, !noalias !367
  store i32 %add, i32* %output.ref.epoch, align 512, !alias.scope !368, !noalias !369
  store i8 0, i8* %output.region, align 512, !alias.scope !370, !noalias !371
  store i8 %conv7, i8* %output.stage, align 512, !alias.scope !372, !noalias !373
  store i8 %layer, i8* %output.layer, align 512, !alias.scope !374, !noalias !375
  store i8 -1, i8* %output.batch, align 512, !alias.scope !376, !noalias !377
  store i8 0, i8* %output.row_space, align 512, !alias.scope !378, !noalias !379
  store i16 0, i16* %output.row0, align 512, !alias.scope !380, !noalias !381
  store i16 128, i16* %output.rows, align 512, !alias.scope !382, !noalias !383
  store i16 64, i16* %output.width, align 512, !alias.scope !384, !noalias !385
  store i8 %cond2.i, i8* %output.content, align 512, !alias.scope !386, !noalias !387
  store i8 5, i8* %probe.output.ref.id, align 512, !alias.scope !388, !noalias !389
  store i8 0, i8* %probe.output.ref.bank, align 512, !alias.scope !390, !noalias !391
  store i32 %add, i32* %probe.output.ref.epoch, align 512, !alias.scope !392, !noalias !393
  store i8 0, i8* %probe.output.region, align 512, !alias.scope !394, !noalias !395
  store i8 %conv7, i8* %probe.output.stage, align 512, !alias.scope !396, !noalias !397
  store i8 %layer, i8* %probe.output.layer, align 512, !alias.scope !398, !noalias !399
  store i8 -1, i8* %probe.output.batch, align 512, !alias.scope !400, !noalias !401
  store i8 0, i8* %probe.output.row_space, align 512, !alias.scope !402, !noalias !403
  store i16 0, i16* %probe.output.row0, align 512, !alias.scope !404, !noalias !405
  store i16 128, i16* %probe.output.rows, align 512, !alias.scope !406, !noalias !407
  store i16 64, i16* %probe.output.width, align 512, !alias.scope !408, !noalias !409
  store i8 %cond2.i, i8* %probe.output.content, align 512, !alias.scope !410, !noalias !411
  br label %_ZN12_GLOBAL__N_111linear_implEN4laya2OpERKNS0_4full13FullOwnerSpecEhhjhRS3_PS3_RNS_5ProbeE.69.76.82.88.108.114.158.164.208.214.260.266.312.318.363.369.413.419.464.exit

_ZN12_GLOBAL__N_111linear_implEN4laya2OpERKNS0_4full13FullOwnerSpecEhhjhRS3_PS3_RNS_5ProbeE.69.76.82.88.108.114.158.164.208.214.260.266.312.318.363.369.413.419.464.exit: ; preds = %if.end.i, %if.then.i
  %storemerge1 = phi i16 [ 8, %if.end.i ], [ %c.code.0.i, %if.then.i ]
  %storemerge = phi i32 [ %c.detail.0.i, %if.then.i ], [ 117440516, %if.end.i ]
  store i16 %storemerge1, i16* %ref.tmp.0165, align 512, !alias.scope !412, !noalias !413
  store i32 %storemerge, i32* %ref.tmp.1166, align 512, !alias.scope !414, !noalias !415
  ret void
}
