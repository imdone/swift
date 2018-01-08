//===----------------------------------------------------------------------===//
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

/// A view into a subsequence of elements of another collection.
///
/// A slice stores a base collection and the start and end indices of the view.
/// It does not copy the elements from the collection into separate storage.
/// Thus, creating a slice has O(1) complexity.
///
/// Slices Share Indices
/// --------------------
///
/// Indices of a slice can be used interchangeably with indices of the base
/// collection. An element of a slice is located under the same index in the
/// slice and in the base collection, as long as neither the collection nor
/// the slice has been mutated since the slice was created.
///
/// For example, suppose you have an array holding the number of absences from
/// each class during a session.
///
///     var absences = [0, 2, 0, 4, 0, 3, 1, 0]
///
/// You're tasked with finding the day with the most absences in the second
/// half of the session. To find the index of the day in question, follow
/// these setps:
///
/// 1) Create a slice of the `absences` array that holds the second half of the
///    days.
/// 2) Use the `max(by:)` method to determine the index of the day with the
///    most absences.
/// 3) Print the result using the index found in step 2 on the original
///    `absences` array.
///
/// Here's an implementation of those steps:
///
///     let secondHalf = absences.suffix(absences.count / 2)
///     if let i = secondHalf.indices.max(by: { secondHalf[$0] < secondHalf[$1] }) {
///         print("Highest second-half absences: \(absences[i])")
///     }
///     // Prints "Highest second-half absences: 3"
///
/// Slices Inherit Semantics
/// ------------------------
///
/// A slice inherits the value or reference semantics of its base collection.
/// That is, if a `Slice` instance is wrapped around a mutable collection that
/// has value semantics, such as an array, mutating the original collection
/// would trigger a copy of that collection, and not affect the base
/// collection stored inside of the slice.
///
/// For example, if you update the last element of the `absences` array from
/// `0` to `2`, the `secondHalf` slice is unchanged.
///
///     absences[7] = 2
///     print(absences)
///     // Prints "[0, 2, 0, 4, 0, 3, 1, 2]"
///     print(secondHalf)
///     // Prints "[0, 3, 1, 0]"
///
/// Use slices only for transient computation. A slice may hold a reference to
/// the entire storage of a larger collection, not just to the portion it
/// presents, even after the base collection's lifetime ends. Long-term
/// storage of a slice may therefore prolong the lifetime of elements that are
/// no longer otherwise accessible, which can erroneously appear to be memory
/// leakage.
///
/// - Note: Using a `Slice` instance with a mutable collection requires that
///   the base collection's `subscript(_: Index)` setter does not invalidate
///   indices. If mutations need to invalidate indices in your custom
///   collection type, don't use `Slice` as its subsequence type. Instead,
///   define your own subsequence type that takes your index invalidation
///   requirements into account.
@_fixed_layout // FIXME (sil-serialize-all) id:1849 gh:1856
public struct Slice<Base: Collection> {
  public var _startIndex: Base.Index
  public var _endIndex: Base.Index

  @_versioned // FIXME (sil-serialize-all) id:1833 gh:1840
  internal var _base: Base

  /// Creates a view into the given collection that allows access to elements
  /// within the specified range.
  ///
  /// It is unusual to need to call this method directly. Instead, create a
  /// slice of a collection by using the collection's range-based subscript or
  /// by using methods that return a subsequence.
  ///
  ///     let singleDigits = 0...9
  ///     let subSequence = singleDigits.dropFirst(5)
  ///     print(Array(subSequence))
  ///     // Prints "[5, 6, 7, 8, 9]"
  ///
  /// In this example, the expression `singleDigits.dropFirst(5))` is
  /// equivalent to calling this initializer with `singleDigits` and a
  /// range covering the last five items of `singleDigits.indices`.
  ///
  /// - Parameters:
  ///   - base: The collection to create a view into.
  ///   - bounds: The range of indices to allow access to in the new slice.
  @_inlineable // FIXME (sil-serialize-all) id:2101 gh:2108
  public init(base: Base, bounds: Range<Base.Index>) {
    self._base = base
    self._startIndex = bounds.lowerBound
    self._endIndex = bounds.upperBound
  }

  /// The underlying collection of the slice.
  ///
  /// You can use a slice's `base` property to access its base collection. The
  /// following example declares `singleDigits`, a range of single digit
  /// integers, and then drops the first element to create a slice of that
  /// range, `singleNonZeroDigits`. The `base` property of the slice is equal
  /// to `singleDigits`.
  ///
  ///     let singleDigits = 0..<10
  ///     let singleNonZeroDigits = singleDigits.dropFirst()
  ///     // singleNonZeroDigits is a Slice<CountableRange<Int>>
  ///
  ///     print(singleNonZeroDigits.count)
  ///     // Prints "9"
  ///     prints(singleNonZeroDigits.base.count)
  ///     // Prints "10"
  ///     print(singleDigits == singleNonZeroDigits.base)
  ///     // Prints "true"
  @_inlineable // FIXME (sil-serialize-all) id:2463 gh:2475
  public var base: Base {
    return _base
  }
}

extension Slice: Collection {
  public typealias Index = Base.Index
  public typealias Indices = Base.Indices
  public typealias Element = Base.Element
  public typealias SubSequence = Slice<Base>
  public typealias Iterator = IndexingIterator<Slice<Base>>

  @_inlineable // FIXME (sil-serialize-all) id:1681 gh:1688
  public var startIndex: Index {
    return _startIndex
  }

  @_inlineable // FIXME (sil-serialize-all) id:1852 gh:1859
  public var endIndex: Index {
    return _endIndex
  }

  @_inlineable // FIXME (sil-serialize-all) id:1836 gh:1843
  public subscript(index: Index) -> Base.Element {
    get {
      _failEarlyRangeCheck(index, bounds: startIndex..<endIndex)
      return _base[index]
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:2104 gh:2111
  public subscript(bounds: Range<Index>) -> Slice<Base> {
    get {
      _failEarlyRangeCheck(bounds, bounds: startIndex..<endIndex)
      return Slice(base: _base, bounds: bounds)
    }
  }

  public var indices: Indices { 
    return _base.indices[_startIndex..<_endIndex]
  }

  @_inlineable // FIXME (sil-serialize-all) id:2465 gh:2477
  public func index(after i: Index) -> Index {
    // FIXME: swift-3-indexing-model: range check. id:1683 gh:1690
    return _base.index(after: i)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1855 gh:1862
  public func formIndex(after i: inout Index) {
    // FIXME: swift-3-indexing-model: range check. id:1839 gh:1846
    _base.formIndex(after: &i)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2108 gh:2115
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    // FIXME: swift-3-indexing-model: range check. id:2467 gh:2479
    return _base.index(i, offsetBy: n)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1685 gh:1692
  public func index(
    _ i: Index, offsetBy n: Int, limitedBy limit: Index
  ) -> Index? {
    // FIXME: swift-3-indexing-model: range check. id:1858 gh:1865
    return _base.index(i, offsetBy: n, limitedBy: limit)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1841 gh:1848
  public func distance(from start: Index, to end: Index) -> Int {
    // FIXME: swift-3-indexing-model: range check. id:2112 gh:2119
    return _base.distance(from: start, to: end)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2469 gh:2481
  public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) {
    _base._failEarlyRangeCheck(index, bounds: bounds)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1687 gh:1695
  public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) {
    _base._failEarlyRangeCheck(range, bounds: bounds)
  }
}

extension Slice: BidirectionalCollection where Base: BidirectionalCollection {
  @_inlineable // FIXME (sil-serialize-all) id:1861 gh:1868
  public func index(before i: Index) -> Index {
    // FIXME: swift-3-indexing-model: range check. id:1844 gh:1851
    return _base.index(before: i)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2115 gh:2122
  public func formIndex(before i: inout Index) {
    // FIXME: swift-3-indexing-model: range check. id:2471 gh:2483
    _base.formIndex(before: &i)
  }
}


extension Slice: MutableCollection where Base: MutableCollection {
  @_inlineable // FIXME (sil-serialize-all) id:1689 gh:1696
  public subscript(index: Index) -> Base.Element {
    get {
      _failEarlyRangeCheck(index, bounds: startIndex..<endIndex)
      return _base[index]
    }
    set {
      _failEarlyRangeCheck(index, bounds: startIndex..<endIndex)
      _base[index] = newValue
      // MutableSlice requires that the underlying collection's subscript
      // setter does not invalidate indices, so our `startIndex` and `endIndex`
      // continue to be valid.
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:1864 gh:1871
  public subscript(bounds: Range<Index>) -> Slice<Base> {
    get {
      _failEarlyRangeCheck(bounds, bounds: startIndex..<endIndex)
      return Slice(base: _base, bounds: bounds)
    }
    set {
      _writeBackMutableSlice(&self, bounds: bounds, slice: newValue)
    }
  }
}


extension Slice: RandomAccessCollection where Base: RandomAccessCollection { }

extension Slice: RangeReplaceableCollection
  where Base: RangeReplaceableCollection {
  @_inlineable // FIXME (sil-serialize-all) id:1848 gh:1855
  public init() {
    self._base = Base()
    self._startIndex = _base.startIndex
    self._endIndex = _base.endIndex
  }

  @_inlineable // FIXME (sil-serialize-all) id:2120 gh:2127
  public init(repeating repeatedValue: Base.Element, count: Int) {
    self._base = Base(repeating: repeatedValue, count: count)
    self._startIndex = _base.startIndex
    self._endIndex = _base.endIndex
  }

  @_inlineable // FIXME (sil-serialize-all) id:2473 gh:2485
  public init<S>(_ elements: S) where S: Sequence, S.Element == Base.Element {
    self._base = Base(elements)
    self._startIndex = _base.startIndex
    self._endIndex = _base.endIndex
  }

  @_inlineable // FIXME (sil-serialize-all) id:1691 gh:1698
  public mutating func replaceSubrange<C>(
    _ subRange: Range<Index>, with newElements: C
  ) where C : Collection, C.Element == Base.Element {

    // FIXME: swift-3-indexing-model: range check. id:1867 gh:1874
    let sliceOffset =
      _base.distance(from: _base.startIndex, to: _startIndex)
    let newSliceCount =
      _base.distance(from: _startIndex, to: subRange.lowerBound)
      + _base.distance(from: subRange.upperBound, to: _endIndex)
      + (numericCast(newElements.count) as Int)
    _base.replaceSubrange(subRange, with: newElements)
    _startIndex = _base.index(_base.startIndex, offsetBy: sliceOffset)
    _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1850 gh:1857
  public mutating func insert(_ newElement: Base.Element, at i: Index) {
    // FIXME: swift-3-indexing-model: range check. id:2123 gh:2130
    let sliceOffset = _base.distance(from: _base.startIndex, to: _startIndex)
    let newSliceCount = count + 1
    _base.insert(newElement, at: i)
    _startIndex = _base.index(_base.startIndex, offsetBy: sliceOffset)
    _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2475 gh:2487
  public mutating func insert<S>(contentsOf newElements: S, at i: Index)
  where S: Collection, S.Element == Base.Element {

    // FIXME: swift-3-indexing-model: range check. id:1693 gh:1700
    let sliceOffset = _base.distance(from: _base.startIndex, to: _startIndex)
    let newSliceCount = count + newElements.count
    _base.insert(contentsOf: newElements, at: i)
    _startIndex = _base.index(_base.startIndex, offsetBy: sliceOffset)
    _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1870 gh:1877
  public mutating func remove(at i: Index) -> Base.Element {
    // FIXME: swift-3-indexing-model: range check. id:1853 gh:1860
    let sliceOffset = _base.distance(from: _base.startIndex, to: _startIndex)
    let newSliceCount = count - 1
    let result = _base.remove(at: i)
    _startIndex = _base.index(_base.startIndex, offsetBy: sliceOffset)
    _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
    return result
  }

  @_inlineable // FIXME (sil-serialize-all) id:2128 gh:2136
  public mutating func removeSubrange(_ bounds: Range<Index>) {
    // FIXME: swift-3-indexing-model: range check. id:2477 gh:2489
    let sliceOffset = _base.distance(from: _base.startIndex, to: _startIndex)
    let newSliceCount =
      count - distance(from: bounds.lowerBound, to: bounds.upperBound)
    _base.removeSubrange(bounds)
    _startIndex = _base.index(_base.startIndex, offsetBy: sliceOffset)
    _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
  }
}

extension Slice
  where Base: RangeReplaceableCollection, Base: BidirectionalCollection {
  
  @_inlineable // FIXME (sil-serialize-all) id:1697 gh:1704
  public mutating func replaceSubrange<C>(
    _ subRange: Range<Index>, with newElements: C
  ) where C : Collection, C.Element == Base.Element {
    // FIXME: swift-3-indexing-model: range check. id:1873 gh:1880
    if subRange.lowerBound == _base.startIndex {
      let newSliceCount =
        _base.distance(from: _startIndex, to: subRange.lowerBound)
        + _base.distance(from: subRange.upperBound, to: _endIndex)
        + (numericCast(newElements.count) as Int)
      _base.replaceSubrange(subRange, with: newElements)
      _startIndex = _base.startIndex
      _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
    } else {
      let shouldUpdateStartIndex = subRange.lowerBound == _startIndex
      let lastValidIndex = _base.index(before: subRange.lowerBound)
      let newEndIndexOffset =
        _base.distance(from: subRange.upperBound, to: _endIndex)
        + (numericCast(newElements.count) as Int) + 1
      _base.replaceSubrange(subRange, with: newElements)
      if shouldUpdateStartIndex {
        _startIndex = _base.index(after: lastValidIndex)
      }
      _endIndex = _base.index(lastValidIndex, offsetBy: newEndIndexOffset)
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:1856 gh:1863
  public mutating func insert(_ newElement: Base.Element, at i: Index) {
    // FIXME: swift-3-indexing-model: range check. id:2130 gh:2137
    if i == _base.startIndex {
      let newSliceCount = count + 1
      _base.insert(newElement, at: i)
      _startIndex = _base.startIndex
      _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
    } else {
      let shouldUpdateStartIndex = i == _startIndex
      let lastValidIndex = _base.index(before: i)
      let newEndIndexOffset = _base.distance(from: i, to: _endIndex) + 2
      _base.insert(newElement, at: i)
      if shouldUpdateStartIndex {
        _startIndex = _base.index(after: lastValidIndex)
      }
      _endIndex = _base.index(lastValidIndex, offsetBy: newEndIndexOffset)
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:2479 gh:2491
  public mutating func insert<S>(contentsOf newElements: S, at i: Index)
  where S : Collection, S.Element == Base.Element {
    // FIXME: swift-3-indexing-model: range check. id:1700 gh:1707
    if i == _base.startIndex {
      let newSliceCount = count + numericCast(newElements.count)
      _base.insert(contentsOf: newElements, at: i)
      _startIndex = _base.startIndex
      _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
    } else {
      let shouldUpdateStartIndex = i == _startIndex
      let lastValidIndex = _base.index(before: i)
      let newEndIndexOffset =
        _base.distance(from: i, to: _endIndex)
        + numericCast(newElements.count) + 1
      _base.insert(contentsOf: newElements, at: i)
      if shouldUpdateStartIndex {
        _startIndex = _base.index(after: lastValidIndex)
      }
      _endIndex = _base.index(lastValidIndex, offsetBy: newEndIndexOffset)
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:1875 gh:1882
  public mutating func remove(at i: Index) -> Base.Element {
    // FIXME: swift-3-indexing-model: range check. id:1859 gh:1866
    if i == _base.startIndex {
      let newSliceCount = count - 1
      let result = _base.remove(at: i)
      _startIndex = _base.startIndex
      _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
      return result
    } else {
      let shouldUpdateStartIndex = i == _startIndex
      let lastValidIndex = _base.index(before: i)
      let newEndIndexOffset = _base.distance(from: i, to: _endIndex)
      let result = _base.remove(at: i)
      if shouldUpdateStartIndex {
        _startIndex = _base.index(after: lastValidIndex)
      }
      _endIndex = _base.index(lastValidIndex, offsetBy: newEndIndexOffset)
      return result
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:2132 gh:2139
  public mutating func removeSubrange(_ bounds: Range<Index>) {
    // FIXME: swift-3-indexing-model: range check. id:2481 gh:2493
    if bounds.lowerBound == _base.startIndex {
      let newSliceCount =
        count - _base.distance(from: bounds.lowerBound, to: bounds.upperBound)
      _base.removeSubrange(bounds)
      _startIndex = _base.startIndex
      _endIndex = _base.index(_startIndex, offsetBy: newSliceCount)
    } else {
      let shouldUpdateStartIndex = bounds.lowerBound == _startIndex
      let lastValidIndex = _base.index(before: bounds.lowerBound)
      let newEndIndexOffset =
          _base.distance(from: bounds.lowerBound, to: _endIndex)
        - _base.distance(from: bounds.lowerBound, to: bounds.upperBound)
        + 1
      _base.removeSubrange(bounds)
      if shouldUpdateStartIndex {
        _startIndex = _base.index(after: lastValidIndex)
      }
      _endIndex = _base.index(lastValidIndex, offsetBy: newEndIndexOffset)
    }
  }
}

@available(*, deprecated, renamed: "Slice")
public typealias BidirectionalSlice<T> = Slice<T> where T : BidirectionalCollection
@available(*, deprecated, renamed: "Slice")
public typealias RandomAccessSlice<T> = Slice<T> where T : RandomAccessCollection
@available(*, deprecated, renamed: "Slice")
public typealias RangeReplaceableSlice<T> = Slice<T> where T : RangeReplaceableCollection
@available(*, deprecated, renamed: "Slice")
public typealias RangeReplaceableBidirectionalSlice<T> = Slice<T> where T : RangeReplaceableCollection & BidirectionalCollection
@available(*, deprecated, renamed: "Slice")
public typealias RangeReplaceableRandomAccessSlice<T> = Slice<T> where T : RangeReplaceableCollection & RandomAccessCollection

@available(*, deprecated, renamed: "Slice")
public typealias MutableSlice<T> = Slice<T> where T : MutableCollection
@available(*, deprecated, renamed: "Slice")
public typealias MutableBidirectionalSlice<T> = Slice<T> where T : MutableCollection & BidirectionalCollection
@available(*, deprecated, renamed: "Slice")
public typealias MutableRandomAccessSlice<T> = Slice<T> where T : MutableCollection & RandomAccessCollection
@available(*, deprecated, renamed: "Slice")
public typealias MutableRangeReplaceableSlice<T> = Slice<T> where T : MutableCollection & RangeReplaceableCollection
@available(*, deprecated, renamed: "Slice")
public typealias MutableRangeReplaceableBidirectionalSlice<T> = Slice<T> where T : MutableCollection & RangeReplaceableCollection & BidirectionalCollection
@available(*, deprecated, renamed: "Slice")
public typealias MutableRangeReplaceableRandomAccessSlice<T> = Slice<T> where T : MutableCollection & RangeReplaceableCollection & RandomAccessCollection
