// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -typecheck -verify -o - -primary-file %s -swift-version 4 -I %S/Inputs/custom-modules/

// REQUIRES: objc_interop

import Foundation
import SubclassExistentialsExtra

class SwiftLaundryService : NSLaundry {
  var g: (Garment & Coat)? = nil

  func wash(_ g: Garment & Coat) {
    self.g = g
  }

  func bleach(_ g: Garment & Coat & Cotton) {}

  func dry() -> Garment & Coat {
    return g!
  }
}

// FIXME: Consider better diagnostics here. id:2969 gh:2981

class OldSwiftLaundryService : NSLaundry {
// expected-error@-1 {{type 'OldSwiftLaundryService' does not conform to protocol 'NSLaundry'}}

  var g: Coat? = nil

  func wash(_ g: Coat) { // expected-note {{candidate has non-matching type '(Coat) -> ()'}}
    self.g = g
  }

  func bleach(_ g: Coat) {} // expected-note {{candidate has non-matching type '(Coat) -> ()'}}

  func dry() -> Coat { // expected-note {{candidate has non-matching type '() -> Coat'}}
    return g!
  }
}

// Make sure the method lookup is not ambiguous

_ = Coat.fashionStatement.wear()


func testInheritanceFromComposition(_ object: CompositionSubObject, _ specific: CompositionSubSpecific) {
  let _: NSObject = object
  let _: NSCopying = object

  let _: SomeSpecificSubclass = specific
  let _: NSCopying = specific
}
