// RUN: %target-build-swift %s
// REQUIRES: executable_test

// FIXME: iOS does not have Cocoa.framework id:3409 gh:3421
// REQUIRES: OS=macosx

import Cocoa

// Make sure the ObjectiveC adapter module gets imported, including ObjCSel.
func rdar14759044(obj: NSObject) -> Bool {
  return obj.responds(to: "abc") // no-warning
}
