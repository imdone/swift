//===--- UIntBuffer.swift - Bounded Collection of Unsigned Integer --------===//
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
//  Stores a smaller unsigned integer type inside a larger one, with a limit of
//  255 elements.
//
//===----------------------------------------------------------------------===//
@_fixed_layout
public struct _UIntBuffer<
  Storage: UnsignedInteger & FixedWidthInteger, 
  Element: UnsignedInteger & FixedWidthInteger
> {
  public var _storage: Storage
  public var _bitCount: UInt8

  @_inlineable // FIXME (sil-serialize-all) id:3164 gh:3176
  @inline(__always)
  public init(_storage: Storage, _bitCount: UInt8) {
    self._storage = _storage
    self._bitCount = _bitCount
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2203 gh:2215
  @inline(__always)
  public init(containing e: Element) {
    _storage = Storage(truncatingIfNeeded: e)
    _bitCount = UInt8(truncatingIfNeeded: Element.bitWidth)
  }
}

extension _UIntBuffer : Sequence {
  public typealias SubSequence = Slice<_UIntBuffer>
  
  @_fixed_layout
  public struct Iterator : IteratorProtocol, Sequence {
    @_inlineable // FIXME (sil-serialize-all) id:2813 gh:2825
    @inline(__always)
    public init(_ x: _UIntBuffer) { _impl = x }
    
    @_inlineable // FIXME (sil-serialize-all) id:2417 gh:2429
    @inline(__always)
    public mutating func next() -> Element? {
      if _impl._bitCount == 0 { return nil }
      defer {
        _impl._storage = _impl._storage &>> Element.bitWidth
        _impl._bitCount = _impl._bitCount &- _impl._elementWidth
      }
      return Element(truncatingIfNeeded: _impl._storage)
    }
    public
    var _impl: _UIntBuffer
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2593 gh:2605
  @inline(__always)
  public func makeIterator() -> Iterator {
    return Iterator(self)
  }
}

extension _UIntBuffer : Collection {  
  @_fixed_layout // FIXME (sil-serialize-all) id:3167 gh:3179
  public struct Index : Comparable {
    @_versioned
    internal var bitOffset: UInt8
    
    @_inlineable // FIXME (sil-serialize-all) id:2207 gh:2219
    @_versioned
    internal init(bitOffset: UInt8) { self.bitOffset = bitOffset }
    
    @_inlineable // FIXME (sil-serialize-all) id:2817 gh:2829
    public static func == (lhs: Index, rhs: Index) -> Bool {
      return lhs.bitOffset == rhs.bitOffset
    }
    @_inlineable // FIXME (sil-serialize-all) id:2420 gh:2432
    public static func < (lhs: Index, rhs: Index) -> Bool {
      return lhs.bitOffset < rhs.bitOffset
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:2595 gh:2607
  public var startIndex : Index {
    @inline(__always)
    get { return Index(bitOffset: 0) }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:3171 gh:3183
  public var endIndex : Index {
    @inline(__always)
    get { return Index(bitOffset: _bitCount) }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2210 gh:2222
  @inline(__always)
  public func index(after i: Index) -> Index {
    return Index(bitOffset: i.bitOffset &+ _elementWidth)
  }

  @_inlineable // FIXME (sil-serialize-all) id:2821 gh:2833
  @_versioned
  internal var _elementWidth : UInt8 {
    return UInt8(truncatingIfNeeded: Element.bitWidth)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2422 gh:2434
  public subscript(i: Index) -> Element {
    @inline(__always)
    get {
      return Element(truncatingIfNeeded: _storage &>> i.bitOffset)
    }
  }
}

extension _UIntBuffer : BidirectionalCollection {
  @_inlineable // FIXME (sil-serialize-all) id:2597 gh:2609
  @inline(__always)
  public func index(before i: Index) -> Index {
    return Index(bitOffset: i.bitOffset &- _elementWidth)
  }
}

extension _UIntBuffer : RandomAccessCollection {
  public typealias Indices = DefaultRandomAccessIndices<_UIntBuffer>
  
  @_inlineable // FIXME (sil-serialize-all) id:3173 gh:3185
  @inline(__always)
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    let x = Int(i.bitOffset) &+ n &* Element.bitWidth
    return Index(bitOffset: UInt8(truncatingIfNeeded: x))
  }

  @_inlineable // FIXME (sil-serialize-all) id:2213 gh:2225
  @inline(__always)
  public func distance(from i: Index, to j: Index) -> Int {
    return (Int(j.bitOffset) &- Int(i.bitOffset)) / Element.bitWidth
  }
}

extension FixedWidthInteger {
  @inline(__always)
  @_inlineable // FIXME (sil-serialize-all) id:2824 gh:2836
  @_versioned
  internal func _fullShiftLeft<N: FixedWidthInteger>(_ n: N) -> Self {
    return (self &<< ((n &+ 1) &>> 1)) &<< (n &>> 1)
  }
  @inline(__always)
  @_inlineable // FIXME (sil-serialize-all) id:2424 gh:2436
  @_versioned
  internal func _fullShiftRight<N: FixedWidthInteger>(_ n: N) -> Self {
    return (self &>> ((n &+ 1) &>> 1)) &>> (n &>> 1)
  }
  @inline(__always)
  @_inlineable // FIXME (sil-serialize-all) id:2599 gh:2611
  @_versioned
  internal static func _lowBits<N: FixedWidthInteger>(_ n: N) -> Self {
    return ~((~0 as Self)._fullShiftLeft(n))
  }
}

extension Range {
  @inline(__always)
  @_inlineable // FIXME (sil-serialize-all) id:3176 gh:3188
  @_versioned
  internal func _contains_(_ other: Range) -> Bool {
    return other.clamped(to: self) == other
  }
}

extension _UIntBuffer : RangeReplaceableCollection {
  @_inlineable // FIXME (sil-serialize-all) id:2216 gh:2229
  @inline(__always)
  public init() {
    _storage = 0
    _bitCount = 0
  }

  @_inlineable // FIXME (sil-serialize-all) id:2827 gh:2839
  public var capacity: Int {
    return Storage.bitWidth / Element.bitWidth
  }

  @_inlineable // FIXME (sil-serialize-all) id:2425 gh:2437
  @inline(__always)
  public mutating func append(_ newElement: Element) {
    _debugPrecondition(count + 1 <= capacity)
    _storage |= Storage(newElement) &<< _bitCount
    _bitCount = _bitCount &+ _elementWidth
  }

  @_inlineable // FIXME (sil-serialize-all) id:2601 gh:2613
  @inline(__always)
  public mutating func removeFirst() {
    _debugPrecondition(!isEmpty)
    _bitCount = _bitCount &- _elementWidth
    _storage = _storage._fullShiftRight(_elementWidth)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:3179 gh:3191
  @inline(__always)
  public mutating func replaceSubrange<C: Collection>(
    _ target: Range<Index>, with replacement: C
  ) where C.Element == Element {
    _debugPrecondition(
      (0..<_bitCount)._contains_(
        target.lowerBound.bitOffset..<target.upperBound.bitOffset))
    
    let replacement1 = _UIntBuffer(replacement)

    let targetCount = distance(
      from: target.lowerBound, to: target.upperBound)
    let growth = replacement1.count &- targetCount
    _debugPrecondition(count + growth <= capacity)

    let headCount = distance(from: startIndex, to: target.lowerBound)
    let tailOffset = distance(from: startIndex, to: target.upperBound)

    let w = Element.bitWidth
    let headBits = _storage & ._lowBits(headCount &* w)
    let tailBits = _storage._fullShiftRight(tailOffset &* w)

    _storage = headBits
    _storage |= replacement1._storage &<< (headCount &* w)
    _storage |= tailBits &<< ((tailOffset &+ growth) &* w)
    _bitCount = UInt8(
      truncatingIfNeeded: Int(_bitCount) &+ growth &* w)
  }
}
