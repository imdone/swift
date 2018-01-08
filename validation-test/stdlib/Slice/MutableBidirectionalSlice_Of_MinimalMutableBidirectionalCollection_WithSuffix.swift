// -*- swift -*-

//===----------------------------------------------------------------------===//
// Automatically Generated From validation-test/stdlib/Slice/Inputs/Template.swift.gyb
// Do Not Edit Directly!
//===----------------------------------------------------------------------===//

// RUN: %target-run-simple-swift
// REQUIRES: executable_test

// FIXME: the test is too slow when the standard library is not optimized. id:3328 gh:3340
// REQUIRES: optimized_stdlib

import StdlibUnittest
import StdlibCollectionUnittest

var SliceTests = TestSuite("Collection")

let prefix: [Int] = []
let suffix: [Int] = []

func makeCollection(elements: [OpaqueValue<Int>])
  -> MutableBidirectionalSlice<MinimalMutableBidirectionalCollection<OpaqueValue<Int>>> {
  var baseElements = prefix.map(OpaqueValue.init)
  baseElements.append(contentsOf: elements)
  baseElements.append(contentsOf: suffix.map(OpaqueValue.init))
  let base = MinimalMutableBidirectionalCollection(elements: baseElements)
  let startIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count))
  let endIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count + elements.count))
  return MutableBidirectionalSlice(
    base: base,
    bounds: startIndex..<endIndex)
}

func makeCollectionOfEquatable(elements: [MinimalEquatableValue])
  -> MutableBidirectionalSlice<MinimalMutableBidirectionalCollection<MinimalEquatableValue>> {
  var baseElements = prefix.map(MinimalEquatableValue.init)
  baseElements.append(contentsOf: elements)
  baseElements.append(contentsOf: suffix.map(MinimalEquatableValue.init))
  let base = MinimalMutableBidirectionalCollection(elements: baseElements)
  let startIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count))
  let endIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count + elements.count))
  return MutableBidirectionalSlice(
    base: base,
    bounds: startIndex..<endIndex)
}

func makeCollectionOfComparable(elements: [MinimalComparableValue])
  -> MutableBidirectionalSlice<MinimalMutableBidirectionalCollection<MinimalComparableValue>> {
  var baseElements = prefix.map(MinimalComparableValue.init)
  baseElements.append(contentsOf: elements)
  baseElements.append(contentsOf: suffix.map(MinimalComparableValue.init))
  let base = MinimalMutableBidirectionalCollection(elements: baseElements)
  let startIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count))
  let endIndex = base.index(
    base.startIndex,
    offsetBy: numericCast(prefix.count + elements.count))
  return MutableBidirectionalSlice(
    base: base,
    bounds: startIndex..<endIndex)
}

var resiliencyChecks = CollectionMisuseResiliencyChecks.all
resiliencyChecks.creatingOutOfBoundsIndicesBehavior = .trap
resiliencyChecks.subscriptOnOutOfBoundsIndicesBehavior = .trap
resiliencyChecks.subscriptRangeOnOutOfBoundsRangesBehavior = .trap

SliceTests.addMutableBidirectionalCollectionTests(
  "MutableBidirectionalSlice_Of_MinimalMutableBidirectionalCollection_WithSuffix.swift.",
  makeCollection: makeCollection,
  wrapValue: identity,
  extractValue: identity,
  makeCollectionOfEquatable: makeCollectionOfEquatable,
  wrapValueIntoEquatable: identityEq,
  extractValueFromEquatable: identityEq,
  makeCollectionOfComparable: makeCollectionOfComparable,
  wrapValueIntoComparable: identityComp,
  extractValueFromComparable: identityComp,
  resiliencyChecks: resiliencyChecks,
  outOfBoundsIndexOffset: 6
  , withUnsafeMutableBufferPointerIsSupported: false,
  isFixedLengthCollection: true
)

runAllTests()
