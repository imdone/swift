//===----------------------------------------------------------------------===//
// Automatically Generated From validation-test/stdlib/Array/Inputs/ArrayConformanceTests.swift.gyb
// Do Not Edit Directly!
//===----------------------------------------------------------------------===//

// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: optimized_stdlib

import StdlibUnittest
import StdlibCollectionUnittest


let tests = TestSuite("ContiguousArray_RangeReplaceableRandomAccessCollectionRef")



do {
  var resiliencyChecks = CollectionMisuseResiliencyChecks.all
  resiliencyChecks.creatingOutOfBoundsIndicesBehavior = .none


  // Test RangeReplaceableCollectionType conformance with reference type elements.
  tests.addRangeReplaceableRandomAccessCollectionTests(
    "ContiguousArray.",
    makeCollection: { (elements: [LifetimeTracked]) in
      return ContiguousArray(elements)
    },
    wrapValue: { (element: OpaqueValue<Int>) in LifetimeTracked(element.value) },
    extractValue: { (element: LifetimeTracked) in OpaqueValue(element.value) },
    makeCollectionOfEquatable: { (elements: [MinimalEquatableValue]) in
      // FIXME: use LifetimeTracked. id:4192 gh:4205
      return ContiguousArray(elements)
    },
    wrapValueIntoEquatable: identityEq,
    extractValueFromEquatable: identityEq,
    resiliencyChecks: resiliencyChecks)


} // do

runAllTests()

