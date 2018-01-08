//===--- SequenceWrapper.swift - sequence/collection wrapper protocols ----===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
//  To create a Sequence that forwards requirements to an
//  underlying Sequence, have it conform to this protocol.
//
//===----------------------------------------------------------------------===//

/// A type that is just a wrapper over some base Sequence
@_show_in_interface
public // @testable
protocol _SequenceWrapper : Sequence {
  associatedtype Base : Sequence where Base.Element == Element
  associatedtype Iterator = Base.Iterator
  associatedtype SubSequence = Base.SubSequence
  
  var _base: Base { get }
}

extension _SequenceWrapper  {
  @_inlineable // FIXME (sil-serialize-all) id:2085 gh:2092
  public var underestimatedCount: Int {
    return _base.underestimatedCount
  }

  @_inlineable // FIXME (sil-serialize-all) id:2451 gh:2463
  public func _preprocessingPass<R>(
    _ preprocess: () throws -> R
  ) rethrows -> R? {
    return try _base._preprocessingPass(preprocess)
  }
}

extension _SequenceWrapper where Iterator == Base.Iterator {
  @_inlineable // FIXME (sil-serialize-all) id:1637 gh:1644
  public func makeIterator() -> Iterator {
    return self._base.makeIterator()
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1834 gh:1841
  @discardableResult
  public func _copyContents(
    initializing buf: UnsafeMutableBufferPointer<Element>
  ) -> (Iterator, UnsafeMutableBufferPointer<Element>.Index) {
    return _base._copyContents(initializing: buf)
  }
}

extension _SequenceWrapper {
  @_inlineable // FIXME (sil-serialize-all) id:1816 gh:1823
  public func map<T>(
    _ transform: (Element) throws -> T
) rethrows -> [T] {
    return try _base.map(transform)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2088 gh:2095
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> [Element] {
    return try _base.filter(isIncluded)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2453 gh:2465
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    return try _base.forEach(body)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1639 gh:1646
  public func _customContainsEquatableElement(
    _ element: Element
  ) -> Bool? { 
    return _base._customContainsEquatableElement(element)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1837 gh:1844
  public func _copyToContiguousArray()
    -> ContiguousArray<Element> {
    return _base._copyToContiguousArray()
  }
}

extension _SequenceWrapper where SubSequence == Base.SubSequence {
  @_inlineable // FIXME (sil-serialize-all) id:1820 gh:1827
  public func dropFirst(_ n: Int) -> SubSequence {
    return _base.dropFirst(n)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2091 gh:2098
  public func dropLast(_ n: Int) -> SubSequence {
    return _base.dropLast(n)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2455 gh:2466
  public func prefix(_ maxLength: Int) -> SubSequence {
    return _base.prefix(maxLength)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1642 gh:1649
  public func suffix(_ maxLength: Int) -> SubSequence {
    return _base.suffix(maxLength)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1840 gh:1847
  public func drop(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    return try _base.drop(while: predicate)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1823 gh:1830
  public func prefix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    return try _base.prefix(while: predicate)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2094 gh:2101
  public func split(
    maxSplits: Int, omittingEmptySubsequences: Bool,
    whereSeparator isSeparator: (Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    return try _base.split(
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences,
      whereSeparator: isSeparator
    )
  }
}
