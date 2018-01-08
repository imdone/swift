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

// This file contains "existentials" for the protocols defined in
// Policy.swift.  Similar components should usually be defined next to
// their respective protocols.

@_fixed_layout // FIXME (sil-serialize-all) id:743 gh:750
@_versioned // FIXME (sil-serialize-all) id:1631 gh:1638
internal struct _CollectionOf<
  IndexType : Strideable, Element
> : Collection {

  @_inlineable // FIXME (sil-serialize-all) id:760 gh:767
  @_versioned // FIXME (sil-serialize-all) id:955 gh:962
  internal init(
    _startIndex: IndexType, endIndex: IndexType,
    _ subscriptImpl: @escaping (IndexType) -> Element
  ) {
    self.startIndex = _startIndex
    self.endIndex = endIndex
    self._subscriptImpl = subscriptImpl
  }

  /// Returns an iterator over the elements of this sequence.
  ///
  /// - Complexity: O(1).
  @_inlineable // FIXME (sil-serialize-all) id:1101 gh:1108
  @_versioned // FIXME (sil-serialize-all) id:748 gh:755
  internal func makeIterator() -> AnyIterator<Element> {
    var index = startIndex
    return AnyIterator {
      () -> Element? in
      if _fastPath(index != self.endIndex) {
        self.formIndex(after: &index)
        return self._subscriptImpl(index)
      }
      return nil
    }
  }

  @_versioned // FIXME (sil-serialize-all) id:1635 gh:1642
  internal let startIndex: IndexType
  @_versioned // FIXME (sil-serialize-all) id:763 gh:770
  internal let endIndex: IndexType

  @_inlineable // FIXME (sil-serialize-all) id:958 gh:965
  @_versioned // FIXME (sil-serialize-all) id:1104 gh:1111
  internal func index(after i: IndexType) -> IndexType {
    return i.advanced(by: 1)
  }

  @_inlineable // FIXME (sil-serialize-all) id:751 gh:758
  @_versioned // FIXME (sil-serialize-all) id:1640 gh:1647
  internal subscript(i: IndexType) -> Element {
    return _subscriptImpl(i)
  }

  @_versioned // FIXME (sil-serialize-all) id:766 gh:773
  internal let _subscriptImpl: (IndexType) -> Element
}

