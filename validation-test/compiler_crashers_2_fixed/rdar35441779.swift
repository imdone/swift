// RUN: not %target-typecheck-verify-swift

class Q {
  var z: Q.z
  
  init () {
    // FIXME: Per rdar://problem/35469647, this should be well-formed, but id:3285 gh:3297
    // it's no longer crashing the compiler.
    z = Q.z.M
  }
  
  enum z: Int {
    case M = 1
  }
}
