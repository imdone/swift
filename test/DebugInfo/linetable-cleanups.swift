// RUN: %target-swift-frontend %s -emit-ir -g -o - | %FileCheck %s

// TODO: check why this is failing on linux id:3010 gh:3022
// REQUIRES: OS=macosx

func markUsed<T>(_ t: T) {}

class Person {
    var name = "No Name"
    var age = 0
}

func main() {
    var person = Person()
    var b = [0,1,13]
    for element in b {
        markUsed("element = \(element)")
    }
    markUsed("Done with the for loop")
// CHECK: call {{.*}}void @"$S4main8markUsedyyxlF"
// CHECK: br label
// CHECK: <label>:
// CHECK: call %Ts16IndexingIteratorVySaySiGG* @"$Ss16IndexingIteratorVySaySiGGWh0_"(%Ts16IndexingIteratorVySaySiGG* %{{.*}}), !dbg ![[LOOPHEADER_LOC:.*]]
// CHECK: call {{.*}}void @"$S4main8markUsedyyxlF"
// The cleanups should share the line number with the ret stmt.
// CHECK:  call %TSa* @"$SSaySiGWh0_"(%TSa* %{{.*}}), !dbg ![[CLEANUPS:.*]]
// CHECK-NEXT:  !dbg ![[CLEANUPS]]
// CHECK-NEXT:  llvm.lifetime.end
// CHECK-NEXT:  load
// CHECK-NEXT:  swift_rt_swift_release
// CHECK-NEXT:  bitcast
// CHECK-NEXT:  llvm.lifetime.end
// CHECK-NEXT:  ret void, !dbg ![[CLEANUPS]]
// CHECK: ![[CLEANUPS]] = !DILocation(line: [[@LINE+1]], column: 1,
}
main()
