; ModuleID = 'array.c'
;
; From (clang -g -c -O0):
;
; void f(int* p) {
;   p[0] = 42;
; }
;
; int main(int argc, char** argv) {
;   int array[4] = { 0, 1, 2, 3 };
;   f(array);
;   return array[0];
; }
;
; RUN: opt %s -O2 -S -o - | FileCheck %s
; Test that we correctly lower dbg.declares for arrays.
;
; CHECK: define i32 @main
; CHECK: call void @llvm.dbg.value(metadata i32 42, i64 0, metadata ![[ARRAY:[0-9]+]], metadata ![[EXPR:[0-9]+]])
; CHECK: ![[ARRAY]] = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "array",{{.*}} line: 6
; CHECK: ![[EXPR]] = !MDExpression(DW_OP_bit_piece, 0, 32)
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

@main.array = private unnamed_addr constant [4 x i32] [i32 0, i32 1, i32 2, i32 3], align 16

; Function Attrs: nounwind ssp uwtable
define void @f(i32* %p) #0 {
entry:
  %p.addr = alloca i32*, align 8
  store i32* %p, i32** %p.addr, align 8
  call void @llvm.dbg.declare(metadata i32** %p.addr, metadata !19, metadata !MDExpression()), !dbg !20
  %0 = load i32*, i32** %p.addr, align 8, !dbg !21
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 0, !dbg !21
  store i32 42, i32* %arrayidx, align 4, !dbg !21
  ret void, !dbg !22
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: nounwind ssp uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
entry:
  %retval = alloca i32, align 4
  %argc.addr = alloca i32, align 4
  %argv.addr = alloca i8**, align 8
  %array = alloca [4 x i32], align 16
  store i32 0, i32* %retval
  store i32 %argc, i32* %argc.addr, align 4
  call void @llvm.dbg.declare(metadata i32* %argc.addr, metadata !23, metadata !MDExpression()), !dbg !24
  store i8** %argv, i8*** %argv.addr, align 8
  call void @llvm.dbg.declare(metadata i8*** %argv.addr, metadata !25, metadata !MDExpression()), !dbg !24
  call void @llvm.dbg.declare(metadata [4 x i32]* %array, metadata !26, metadata !MDExpression()), !dbg !30
  %0 = bitcast [4 x i32]* %array to i8*, !dbg !30
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %0, i8* bitcast ([4 x i32]* @main.array to i8*), i64 16, i32 16, i1 false), !dbg !30
  %arraydecay = getelementptr inbounds [4 x i32], [4 x i32]* %array, i32 0, i32 0, !dbg !31
  call void @f(i32* %arraydecay), !dbg !31
  %arrayidx = getelementptr inbounds [4 x i32], [4 x i32]* %array, i32 0, i64 0, !dbg !32
  %1 = load i32, i32* %arrayidx, align 4, !dbg !32
  ret i32 %1, !dbg !32
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #2

attributes #0 = { nounwind ssp uwtable }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!16, !17}
!llvm.ident = !{!18}

!0 = !MDCompileUnit(language: DW_LANG_C99, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "array.c", directory: "")
!2 = !{}
!3 = !{!4, !10}
!4 = !MDSubprogram(name: "f", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 1, file: !1, scope: !5, type: !6, function: void (i32*)* @f, variables: !2)
!5 = !MDFile(filename: "array.c", directory: "")
!6 = !MDSubroutineType(types: !7)
!7 = !{null, !8}
!8 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !9)
!9 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!10 = !MDSubprogram(name: "main", line: 5, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 5, file: !1, scope: !5, type: !11, function: i32 (i32, i8**)* @main, variables: !2)
!11 = !MDSubroutineType(types: !12)
!12 = !{!9, !9, !13}
!13 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !14)
!14 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !15)
!15 = !MDBasicType(tag: DW_TAG_base_type, name: "char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!16 = !{i32 2, !"Dwarf Version", i32 2}
!17 = !{i32 1, !"Debug Info Version", i32 3}
!18 = !{!"clang version 3.5.0 "}
!19 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "p", line: 1, arg: 1, scope: !4, file: !5, type: !8)
!20 = !MDLocation(line: 1, scope: !4)
!21 = !MDLocation(line: 2, scope: !4)
!22 = !MDLocation(line: 3, scope: !4)
!23 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "argc", line: 5, arg: 1, scope: !10, file: !5, type: !9)
!24 = !MDLocation(line: 5, scope: !10)
!25 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "argv", line: 5, arg: 2, scope: !10, file: !5, type: !13)
!26 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "array", line: 6, scope: !10, file: !5, type: !27)
!27 = !MDCompositeType(tag: DW_TAG_array_type, size: 128, align: 32, baseType: !9, elements: !28)
!28 = !{!29}
!29 = !MDSubrange(count: 4)
!30 = !MDLocation(line: 6, scope: !10)
!31 = !MDLocation(line: 7, scope: !10)
!32 = !MDLocation(line: 8, scope: !10)
