//===--- SentinelCollection.swift -----------------------------------------===//
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
public // @testable
protocol _Function {
  associatedtype Input
  associatedtype Output
  func apply(_: Input) -> Output
}

protocol _Predicate : _Function where Output == Bool { }

@_fixed_layout // FIXME (sil-serialize-all) id:2063 gh:2070
@_versioned // FIXME (sil-serialize-all) id:2432 gh:2444
internal struct _SentinelIterator<
  Base: IteratorProtocol, 
  IsSentinel : _Predicate
> : IteratorProtocol, Sequence
where IsSentinel.Input == Base.Element {
  @_versioned // FIXME (sil-serialize-all) id:1614 gh:1621
  internal var _base: Base
  @_versioned // FIXME (sil-serialize-all) id:1811 gh:1818
  internal var _isSentinel: IsSentinel
  @_versioned // FIXME (sil-serialize-all) id:1789 gh:1796
  internal var _expired: Bool = false

  @_inlineable // FIXME (sil-serialize-all) id:2067 gh:2074
  @_versioned // FIXME (sil-serialize-all) id:2434 gh:2446
  internal init(_ base: Base, until condition: IsSentinel) {
    _base = base
    _isSentinel = condition
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1617 gh:1624
  @_versioned // FIXME (sil-serialize-all) id:1813 gh:1820
  internal mutating func next() -> Base.Element? {
    guard _fastPath(!_expired) else { return nil }
    let x = _base.next()
    // We don't need this check if it's a precondition that the sentinel will be
    // found
    // guard _fastPath(x != nil), let y = x else { return x }
    guard _fastPath(!_isSentinel.apply(x!)) else { _expired = true; return nil }
    return x
  }
}

@_fixed_layout // FIXME (sil-serialize-all) id:1792 gh:1799
@_versioned // FIXME (sil-serialize-all) id:2069 gh:2076
internal struct _SentinelCollection<
  Base: Collection, 
  IsSentinel : _Predicate
> : Collection
where IsSentinel.Input == Base.Iterator.Element {
  @_versioned // FIXME (sil-serialize-all) id:2436 gh:2448
  internal let _isSentinel: IsSentinel
  @_versioned // FIXME (sil-serialize-all) id:1619 gh:1626
  internal var _base : Base
  
  @_inlineable // FIXME (sil-serialize-all) id:1815 gh:1822
  @_versioned // FIXME (sil-serialize-all) id:1794 gh:1801
  internal func makeIterator() -> _SentinelIterator<Base.Iterator, IsSentinel> {
    return _SentinelIterator(_base.makeIterator(), until: _isSentinel)
  }
  
  @_fixed_layout // FIXME (sil-serialize-all) id:2072 gh:2079
  @_versioned // FIXME (sil-serialize-all) id:2439 gh:2451
  internal struct Index : Comparable {
    @_inlineable // FIXME (sil-serialize-all) id:1622 gh:1629
    @_versioned // FIXME (sil-serialize-all) id:1817 gh:1824
    internal init(
      _impl: (position: Base.Index, element: Base.Iterator.Element)?
    ) {
      self._impl = _impl
    }

    @_versioned // FIXME (sil-serialize-all) id:1797 gh:1804
    internal var _impl: (position: Base.Index, element: Base.Iterator.Element)?

    @_inlineable // FIXME (sil-serialize-all) id:2074 gh:2081
    @_versioned // FIXME (sil-serialize-all) id:2441 gh:2453
    internal static func == (lhs: Index, rhs: Index) -> Bool {
      if rhs._impl == nil { return lhs._impl == nil }
      return lhs._impl != nil && rhs._impl!.position == lhs._impl!.position
    }

    @_inlineable // FIXME (sil-serialize-all) id:1624 gh:1631
    @_versioned // FIXME (sil-serialize-all) id:1819 gh:1826
    internal static func < (lhs: Index, rhs: Index) -> Bool {
      if rhs._impl == nil { return lhs._impl != nil }
      return lhs._impl != nil && rhs._impl!.position < lhs._impl!.position
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:1799 gh:1806
  @_versioned // FIXME (sil-serialize-all) id:2077 gh:2084
  internal var startIndex : Index {
    return _index(at: _base.startIndex)
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:2443 gh:2455
  @_versioned // FIXME (sil-serialize-all) id:1627 gh:1634
  internal var endIndex : Index {
    return Index(_impl: nil)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1821 gh:1828
  @_versioned // FIXME (sil-serialize-all) id:1802 gh:1809
  internal subscript(i: Index) -> Base.Iterator.Element {
    return i._impl!.element
  }

  @_inlineable // FIXME (sil-serialize-all) id:2079 gh:2086
  @_versioned // FIXME (sil-serialize-all) id:2445 gh:2457
  internal func index(after i: Index) -> Index {
    return _index(at: _base.index(after: i._impl!.position))
  }

  @_inlineable // FIXME (sil-serialize-all) id:1629 gh:1636
  @_versioned // FIXME (sil-serialize-all) id:1824 gh:1831
  internal func _index(at i: Base.Index) -> Index {
    // We don't need this check if it's a precondition that the sentinel will be
    // found
    // guard _fastPath(i != _base.endIndex) else { return endIndex }
    let e = _base[i]
    guard _fastPath(!_isSentinel.apply(e)) else { return endIndex }
    return Index(_impl: (position: i, element: e))
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1805 gh:1812
  @_versioned // FIXME (sil-serialize-all) id:2081 gh:2088
  internal init(_ base: Base, until condition: IsSentinel) {
    _base = base
    _isSentinel = condition
  }
}

@_fixed_layout // FIXME (sil-serialize-all) id:2447 gh:2459
@_versioned // FIXME (sil-serialize-all) id:1632 gh:1639
internal struct _IsZero<T : BinaryInteger> : _Predicate {
  @_inlineable // FIXME (sil-serialize-all) id:1828 gh:1835
  @_versioned // FIXME (sil-serialize-all) id:1809 gh:1816
  internal init() {}

  @_inlineable // FIXME (sil-serialize-all) id:2083 gh:2090
  @_versioned // FIXME (sil-serialize-all) id:2449 gh:2461
  internal func apply(_ x: T) -> Bool {
    return x == 0
  }
}
