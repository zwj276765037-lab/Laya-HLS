define internal void @"(anonymous namespace)::vector_impl.2"(i16* noalias nocapture align 512 %ref.tmp33.0147, i32* noalias nocapture align 512 %ref.tmp33.1148, i8 %cond32, i8* noalias nocapture align 512 %hidden.ref.id, i8* noalias nocapture align 512 %hidden.ref.bank, i32* noalias nocapture align 512 %hidden.ref.epoch, i8* noalias nocapture align 512 %hidden.region, i8 %layer, i32* noalias nocapture align 512 %probe.issued.ctx.task_id, i8* noalias nocapture align 512 %probe.issued.ctx.op, i8* noalias nocapture align 512 %probe.issued.ctx.stage, i8* noalias nocapture align 512 %probe.issued.ctx.layer, i8* noalias nocapture align 512 %probe.issued.ctx.batch, i8* noalias nocapture align 512 %probe.issued.ctx.row_space, i16* noalias nocapture align 512 %probe.issued.ctx.row0, i8* noalias nocapture align 512 %probe.issued.ctx.rows, i8* noalias nocapture align 512 %probe.issued.src0.id, i8* noalias nocapture align 512 %probe.issued.src0.bank, i32* noalias nocapture align 512 %probe.issued.src0.epoch, i8* noalias nocapture align 512 %probe.issued.src1.id, i8* noalias nocapture align 512 %probe.issued.src1.bank, i32* noalias nocapture align 512 %probe.issued.src1.epoch, i8* noalias nocapture align 512 %probe.issued.dst.id, i8* noalias nocapture align 512 %probe.issued.dst.bank, i32* noalias nocapture align 512 %probe.issued.dst.epoch, i16* noalias nocapture align 512 %probe.issued.length, i8* noalias nocapture align 512 %probe.issued.src0_region, i8* noalias nocapture align 512 %probe.issued.src1_region, i8* noalias nocapture align 512 %probe.issued.dst_region, i16* noalias nocapture align 512 %probe.issued.bias_id) #0 {
newFuncRoot:
  call void (...) @_ssdm_InlineSelf(i64 2, [1 x i8]* @1)
  %.026.i = load i8, i8* %hidden.ref.id, align 512, !alias.scope !416, !noalias !419
  %.127.i = load i8, i8* %hidden.ref.bank, align 512, !alias.scope !448, !noalias !449
  %.228.i = load i32, i32* %hidden.ref.epoch, align 512, !alias.scope !450, !noalias !451
  %0 = load i8, i8* %hidden.region, align 512, !alias.scope !452, !noalias !453
  %add.i = add i32 %.228.i, 1
  %cmp.i.i = icmp eq i8 %.026.i, 0
  %storemerge17.i = select i1 %cmp.i.i, i16 5, i16 0
  %storemerge.i = select i1 %cmp.i.i, i32 67108870, i32 0
  store i16 %storemerge17.i, i16* %ref.tmp33.0147, align 512, !alias.scope !454, !noalias !459
  store i32 %storemerge.i, i32* %ref.tmp33.1148, align 512, !alias.scope !463, !noalias !465
  store i32 0, i32* %probe.issued.ctx.task_id, align 512, !alias.scope !466, !noalias !467
  store i8 %cond32, i8* %probe.issued.ctx.op, align 512, !alias.scope !468, !noalias !469
  store i8 2, i8* %probe.issued.ctx.stage, align 512, !alias.scope !470, !noalias !471
  store i8 %layer, i8* %probe.issued.ctx.layer, align 512, !alias.scope !472, !noalias !473
  store i8 0, i8* %probe.issued.ctx.batch, align 512, !alias.scope !474, !noalias !475
  store i8 0, i8* %probe.issued.ctx.row_space, align 512, !alias.scope !476, !noalias !477
  store i16 0, i16* %probe.issued.ctx.row0, align 512, !alias.scope !478, !noalias !479
  store i8 0, i8* %probe.issued.ctx.rows, align 512, !alias.scope !480, !noalias !481
  store i8 %.026.i, i8* %probe.issued.src0.id, align 512, !alias.scope !482, !noalias !483
  store i8 %.127.i, i8* %probe.issued.src0.bank, align 512, !alias.scope !484, !noalias !485
  store i32 %.228.i, i32* %probe.issued.src0.epoch, align 512, !alias.scope !486, !noalias !487
  store i8 0, i8* %probe.issued.src1.id, align 512, !alias.scope !488, !noalias !489
  store i8 0, i8* %probe.issued.src1.bank, align 512, !alias.scope !490, !noalias !491
  store i32 0, i32* %probe.issued.src1.epoch, align 512, !alias.scope !492, !noalias !493
  store i8 1, i8* %probe.issued.dst.id, align 512, !alias.scope !494, !noalias !495
  store i8 1, i8* %probe.issued.dst.bank, align 512, !alias.scope !496, !noalias !497
  store i32 %add.i, i32* %probe.issued.dst.epoch, align 512, !alias.scope !498, !noalias !499
  store i16 1024, i16* %probe.issued.length, align 512, !alias.scope !500, !noalias !501
  store i8 %0, i8* %probe.issued.src0_region, align 512, !alias.scope !502, !noalias !503
  store i8 0, i8* %probe.issued.src1_region, align 512, !alias.scope !504, !noalias !505
  store i8 0, i8* %probe.issued.dst_region, align 512, !alias.scope !506, !noalias !507
  store i16 -1, i16* %probe.issued.bias_id, align 512, !alias.scope !508, !noalias !509
  %cmp.i16.i = icmp eq i16 %storemerge17.i, 0
  br i1 %cmp.i16.i, label %if.then23.i, label %_ZN12_GLOBAL__N_111vector_implEN4laya2OpERKNS0_4full13FullOwnerSpecEPS4_hhRNS_5ProbeE.62.130.141.180.191.230.243.282.295.334.346.385.396.435.446.465.exit

if.then23.i:                                      ; preds = %newFuncRoot
  %.off.i.i = add i8 %cond32, -98
  %switch.i.i = icmp ult i8 %.off.i.i, 2
  %ref.tmp24.029.0.i = select i1 %switch.i.i, i16 3, i16 0
  %ref.tmp24.130.0.i = select i1 %switch.i.i, i32 117637121, i32 0
  store i16 %ref.tmp24.029.0.i, i16* %ref.tmp33.0147, align 512, !alias.scope !510, !noalias !511
  store i32 %ref.tmp24.130.0.i, i32* %ref.tmp33.1148, align 512, !alias.scope !512, !noalias !513
  br label %_ZN12_GLOBAL__N_111vector_implEN4laya2OpERKNS0_4full13FullOwnerSpecEPS4_hhRNS_5ProbeE.62.130.141.180.191.230.243.282.295.334.346.385.396.435.446.465.exit

_ZN12_GLOBAL__N_111vector_implEN4laya2OpERKNS0_4full13FullOwnerSpecEPS4_hhRNS_5ProbeE.62.130.141.180.191.230.243.282.295.334.346.385.396.435.446.465.exit: ; preds = %if.then23.i, %newFuncRoot
  ret void
}
