//===--- CharacterUnicodeScalars.swift ------------------------------------===//
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
extension Character {
  @_fixed_layout // FIXME (sil-serialize-all) id:864 gh:871
  public struct UnicodeScalarView {
    @_versioned // FIXME (sil-serialize-all) id:963 gh:970
    internal let _base: Character

    @_inlineable // FIXME (sil-serialize-all) id:658 gh:665
    @_versioned // FIXME (sil-serialize-all) id:1541 gh:1548
    internal init(_base: Character) {
      self._base = _base
    }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:669 gh:676
  public var unicodeScalars : UnicodeScalarView {
    return UnicodeScalarView(_base: self)
  }
}

extension Character.UnicodeScalarView {
  @_fixed_layout // FIXME (sil-serialize-all) id:866 gh:873
  public struct Iterator {
    @_versioned // FIXME (sil-serialize-all) id:965 gh:972
    internal var _base: IndexingIterator<Character.UnicodeScalarView>

    @_inlineable // FIXME (sil-serialize-all) id:663 gh:670
    @_versioned // FIXME (sil-serialize-all) id:1544 gh:1551
    internal init(_base: IndexingIterator<Character.UnicodeScalarView>) {
      self._base = _base
    }
  }
}
    
extension Character.UnicodeScalarView.Iterator : IteratorProtocol {
  @_inlineable // FIXME (sil-serialize-all) id:671 gh:678
  public mutating func next() -> UnicodeScalar? {
    return _base.next()
  }
}

extension Character.UnicodeScalarView : Sequence {
  @_inlineable // FIXME (sil-serialize-all) id:869 gh:876
  public func makeIterator() -> Iterator {
    return Iterator(_base: IndexingIterator(_elements: self))
  }
}

extension Character.UnicodeScalarView {
  @_fixed_layout // FIXME (sil-serialize-all) id:968 gh:975
  public struct Index {
    @_versioned // FIXME (sil-serialize-all) id:667 gh:674
    internal let _encodedOffset: Int
    @_versioned // FIXME (sil-serialize-all) id:1546 gh:1553
    internal let _scalar: Unicode.UTF16.EncodedScalar
    @_versioned // FIXME (sil-serialize-all) id:674 gh:681
    internal let _stride: UInt8

    @_inlineable // FIXME (sil-serialize-all) id:872 gh:880
    @_versioned // FIXME (sil-serialize-all) id:970 gh:977
    internal init(_encodedOffset: Int, _scalar: Unicode.UTF16.EncodedScalar, _stride: UInt8) {
      self._encodedOffset = _encodedOffset
      self._scalar = _scalar
      self._stride = _stride
    }
  }
}

extension Character.UnicodeScalarView.Index : Equatable {
  @_inlineable // FIXME (sil-serialize-all) id:670 gh:677
  public static func == (
    lhs: Character.UnicodeScalarView.Index,
    rhs: Character.UnicodeScalarView.Index
  ) -> Bool {
    return lhs._encodedOffset == rhs._encodedOffset
  }
}

extension Character.UnicodeScalarView.Index : Comparable {
  @_inlineable // FIXME (sil-serialize-all) id:1550 gh:1557
  public static func < (
    lhs: Character.UnicodeScalarView.Index,
    rhs: Character.UnicodeScalarView.Index
  ) -> Bool {
    return lhs._encodedOffset < rhs._encodedOffset
  }
}

extension Character.UnicodeScalarView : Collection {
  @_inlineable // FIXME (sil-serialize-all) id:676 gh:683
  public var startIndex: Index {
    return index(
      after: Index(
        _encodedOffset: 0,
        _scalar: Unicode.UTF16.EncodedScalar(),
        _stride: 0
      ))
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:875 gh:882
  public var endIndex: Index {
    return Index(
        _encodedOffset: _base._smallUTF16?.count ?? _base._largeUTF16!.count,
        _scalar: Unicode.UTF16.EncodedScalar(),
        _stride: 0
      )
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:973 gh:980
  public func index(after i: Index) -> Index {
    var parser = Unicode.UTF16.ForwardParser()
    let startOfNextScalar = i._encodedOffset + numericCast(i._stride)
    let r: Unicode.ParseResult<Unicode.UTF16.EncodedScalar>
    
    let small_ = _base._smallUTF16
    if _fastPath(small_ != nil), let u16 = small_ {
      var i = u16[u16.index(u16.startIndex, offsetBy: startOfNextScalar)...]
        .makeIterator()
      r = parser.parseScalar(from: &i)
    }
    else {
      var i = _base._largeUTF16![startOfNextScalar...].makeIterator()
      r = parser.parseScalar(from: &i)
    }
    
    switch r {
    case .valid(let s):
      return Index(
        _encodedOffset: startOfNextScalar, _scalar: s,
        _stride: UInt8(truncatingIfNeeded: s.count))
    case .error:
      return Index(
        _encodedOffset: startOfNextScalar,
        _scalar: Unicode.UTF16.encodedReplacementCharacter,
        _stride: 1)
    case .emptyInput:
      if i._stride != 0 { return endIndex }
      fatalError("no position after end of Character's last Unicode.Scalar")
    }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:673 gh:680
  public subscript(_ i: Index) -> UnicodeScalar {
    return Unicode.UTF16.decode(i._scalar)
  }
}

extension Character.UnicodeScalarView : BidirectionalCollection {
  @_inlineable // FIXME (sil-serialize-all) id:1553 gh:1560
  public func index(before i: Index) -> Index {
    var parser = Unicode.UTF16.ReverseParser()
    let r: Unicode.ParseResult<Unicode.UTF16.EncodedScalar>
    
    let small_ = _base._smallUTF16
    if _fastPath(small_ != nil), let u16 = small_ {
      var i = u16[..<u16.index(u16.startIndex, offsetBy: i._encodedOffset)]
        .reversed().makeIterator()
      r = parser.parseScalar(from: &i)
    }
    else {
      var i = _base._largeUTF16![..<i._encodedOffset].reversed().makeIterator()
      r = parser.parseScalar(from: &i)
    }
    
    switch r {
    case .valid(let s):
      return Index(
        _encodedOffset: i._encodedOffset - s.count, _scalar: s,
        _stride: UInt8(truncatingIfNeeded: s.count))
    case .error:
      return Index(
        _encodedOffset: i._encodedOffset - 1,
        _scalar: Unicode.UTF16.encodedReplacementCharacter,
        _stride: 1)
    case .emptyInput:
      fatalError("no position before Character's last Unicode.Scalar")
    }
  }
}

