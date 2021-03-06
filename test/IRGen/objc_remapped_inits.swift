// RUN: %target-swift-frontend -assume-parsing-unqualified-ownership-sil %s -emit-ir -disable-objc-attr-requires-foundation-module | %FileCheck %s

// FIXME: This test could use %clang-importer-sdk, but the compiler crashes. id:2719 gh:2731

// REQUIRES: OS=ios
// REQUIRES: objc_interop

import UIKit

// CHECK-NOT: (initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:)
// CHECK: (initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:)
// CHECK-NOT: (initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:)

_ = UIActionSheet(title: "abc", delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
