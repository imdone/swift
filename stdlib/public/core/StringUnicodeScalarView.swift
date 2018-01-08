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

extension String {
  /// A view of a string's contents as a collection of Unicode scalar values.
  ///
  /// You can access a string's view of Unicode scalar values by using its
  /// `unicodeScalars` property. Unicode scalar values are the 21-bit codes
  /// that are the basic unit of Unicode. Each scalar value is represented by
  /// a `Unicode.Scalar` instance and is equivalent to a UTF-32 code unit.
  ///
  ///     let flowers = "Flowers 💐"
  ///     for v in flowers.unicodeScalars {
  ///         print(v.value)
  ///     }
  ///     // 70
  ///     // 108
  ///     // 111
  ///     // 119
  ///     // 101
  ///     // 114
  ///     // 115
  ///     // 32
  ///     // 128144
  ///
  /// Some characters that are visible in a string are made up of more than one
  /// Unicode scalar value. In that case, a string's `unicodeScalars` view
  /// contains more elements than the string itself.
  ///
  ///     let flag = "🇵🇷"
  ///     for c in flag {
  ///         print(c)
  ///     }
  ///     // 🇵🇷
  ///
  ///     for v in flag.unicodeScalars {
  ///         print(v.value)
  ///     }
  ///     // 127477
  ///     // 127479
  ///
  /// You can convert a `String.UnicodeScalarView` instance back into a string
  /// using the `String` type's `init(_:)` initializer.
  ///
  ///     let favemoji = "My favorite emoji is 🎉"
  ///     if let i = favemoji.unicodeScalars.index(where: { $0.value >= 128 }) {
  ///         let asciiPrefix = String(favemoji.unicodeScalars[..<i])
  ///         print(asciiPrefix)
  ///     }
  ///     // Prints "My favorite emoji is "
  @_fixed_layout // FIXME (sil-serialize-all) id:2754 gh:2766
  public struct UnicodeScalarView :
    BidirectionalCollection,
    CustomStringConvertible,
    CustomDebugStringConvertible
  {
    @_inlineable // FIXME (sil-serialize-all) id:2369 gh:2381
    @_versioned // FIXME (sil-serialize-all) id:2552 gh:2564
    internal init(_ _core: _StringCore, coreOffset: Int = 0) {
      self._core = _core
      self._coreOffset = coreOffset
    }

    @_fixed_layout // FIXME (sil-serialize-all) id:3111 gh:3123
    @_versioned // FIXME (sil-serialize-all) id:2144 gh:2151
    internal struct _ScratchIterator : IteratorProtocol {
      @_versioned
      internal var core: _StringCore
      @_versioned // FIXME (sil-serialize-all) id:2756 gh:2768
      internal var idx: Int
      @_inlineable // FIXME (sil-serialize-all) id:2372 gh:2384
      @_versioned // FIXME (sil-serialize-all) id:2554 gh:2566
      internal init(_ core: _StringCore, _ pos: Int) {
        self.idx = pos
        self.core = core
      }
      @_inlineable // FIXME (sil-serialize-all) id:3114 gh:3126
      @_versioned // FIXME (sil-serialize-all) id:2145 gh:2152
      @inline(__always)
      internal mutating func next() -> UTF16.CodeUnit? {
        if idx == core.endIndex {
          return nil
        }
        defer { idx += 1 }
        return self.core[idx]
      }
    }

    public typealias Index = String.Index
    
    /// Translates a `_core` index into a `UnicodeScalarIndex` using this view's
    /// `_coreOffset`.
    @_inlineable // FIXME (sil-serialize-all) id:2758 gh:2770
    @_versioned // FIXME (sil-serialize-all) id:2374 gh:2386
    internal func _fromCoreIndex(_ i: Int) -> Index {
      return Index(encodedOffset: i + _coreOffset)
    }
    
    /// Translates a `UnicodeScalarIndex` into a `_core` index using this view's
    /// `_coreOffset`.
    @_inlineable // FIXME (sil-serialize-all) id:2556 gh:2568
    @_versioned // FIXME (sil-serialize-all) id:3118 gh:3130
    internal func _toCoreIndex(_ i: Index) -> Int {
      return i.encodedOffset - _coreOffset
    }
    
    /// The position of the first Unicode scalar value if the string is
    /// nonempty.
    ///
    /// If the string is empty, `startIndex` is equal to `endIndex`.
    @_inlineable // FIXME (sil-serialize-all) id:2148 gh:2155
    public var startIndex: Index {
      return _fromCoreIndex(_core.startIndex)
    }

    /// The "past the end" position---that is, the position one greater than
    /// the last valid subscript argument.
    ///
    /// In an empty Unicode scalars view, `endIndex` is equal to `startIndex`.
    @_inlineable // FIXME (sil-serialize-all) id:2760 gh:2772
    public var endIndex: Index {
      return _fromCoreIndex(_core.endIndex)
    }

    /// Returns the next consecutive location after `i`.
    ///
    /// - Precondition: The next location exists.
    @_inlineable // FIXME (sil-serialize-all) id:2377 gh:2389
    public func index(after i: Index) -> Index {
      let i = _toCoreIndex(i)
      var scratch = _ScratchIterator(_core, i)
      var decoder = UTF16()
      let (_, length) = decoder._decodeOne(&scratch)
      return _fromCoreIndex(i + length)
    }

    /// Returns the previous consecutive location before `i`.
    ///
    /// - Precondition: The previous location exists.
    @_inlineable // FIXME (sil-serialize-all) id:2558 gh:2570
    public func index(before i: Index) -> Index {
      var i = _toCoreIndex(i) - 1
      let codeUnit = _core[i]
      if _slowPath((codeUnit >> 10) == 0b1101_11) {
        if i != 0 && (_core[i - 1] >> 10) == 0b1101_10 {
          i -= 1
        }
      }
      return _fromCoreIndex(i)
    }

    /// Accesses the Unicode scalar value at the given position.
    ///
    /// The following example searches a string's Unicode scalars view for a
    /// capital letter and then prints the character and Unicode scalar value
    /// at the found index:
    ///
    ///     let greeting = "Hello, friend!"
    ///     if let i = greeting.unicodeScalars.index(where: { "A"..."Z" ~= $0 }) {
    ///         print("First capital letter: \(greeting.unicodeScalars[i])")
    ///         print("Unicode scalar value: \(greeting.unicodeScalars[i].value)")
    ///     }
    ///     // Prints "First capital letter: H"
    ///     // Prints "Unicode scalar value: 72"
    ///
    /// - Parameter position: A valid index of the character view. `position`
    ///   must be less than the view's end index.
    @_inlineable // FIXME (sil-serialize-all) id:3121 gh:3133
    public subscript(position: Index) -> Unicode.Scalar {
      var scratch = _ScratchIterator(_core, _toCoreIndex(position))
      var decoder = UTF16()
      switch decoder.decode(&scratch) {
      case .scalarValue(let us):
        return us
      case .emptyInput:
        _sanityCheckFailure("cannot subscript using an endIndex")
      case .error:
        return Unicode.Scalar(0xfffd)!
      }
    }

    /// An iterator over the Unicode scalars that make up a `UnicodeScalarView`
    /// collection.
    @_fixed_layout // FIXME (sil-serialize-all) id:2150 gh:2157
    public struct Iterator : IteratorProtocol {
      @_inlineable // FIXME (sil-serialize-all) id:2762 gh:2774
      @_versioned // FIXME (sil-serialize-all) id:2379 gh:2391
      internal init(_ _base: _StringCore) {
        self._iterator = _base.makeIterator()
        if _base.hasContiguousStorage {
          self._baseSet = true
          if _base.isASCII {
            self._ascii = true
            self._asciiBase = UnsafeBufferPointer(
              start: _base._baseAddress?.assumingMemoryBound(
                to: UTF8.CodeUnit.self),
              count: _base.count).makeIterator()
          } else {
            self._ascii = false
            self._base = UnsafeBufferPointer<UInt16>(
              start: _base._baseAddress?.assumingMemoryBound(
                to: UTF16.CodeUnit.self),
              count: _base.count).makeIterator()
          }
        } else {
          self._ascii = false
          self._baseSet = false
        }
      }

      /// Advances to the next element and returns it, or `nil` if no next
      /// element exists.
      ///
      /// Once `nil` has been returned, all subsequent calls return `nil`.
      ///
      /// - Precondition: `next()` has not been applied to a copy of `self`
      ///   since the copy was made.
      @_inlineable // FIXME (sil-serialize-all) id:2560 gh:2572
      public mutating func next() -> Unicode.Scalar? {
        var result: UnicodeDecodingResult
        if _baseSet {
          if _ascii {
            switch self._asciiBase.next() {
            case let x?:
              result = .scalarValue(Unicode.Scalar(x))
            case nil:
              result = .emptyInput
            }
          } else {
            result = _decoder.decode(&(self._base!))
          }
        } else {
          result = _decoder.decode(&(self._iterator))
        }
        switch result {
        case .scalarValue(let us):
          return us
        case .emptyInput:
          return nil
        case .error:
          return Unicode.Scalar(0xfffd)
        }
      }
      @_versioned // FIXME (sil-serialize-all) id:3124 gh:3136
      internal var _decoder: UTF16 = UTF16()
      @_versioned // FIXME (sil-serialize-all) id:2153 gh:2163
      internal let _baseSet: Bool
      @_versioned // FIXME (sil-serialize-all) id:2764 gh:2776
      internal let _ascii: Bool
      @_versioned // FIXME (sil-serialize-all) id:2382 gh:2395
      internal var _asciiBase: UnsafeBufferPointer<UInt8>.Iterator!
      @_versioned // FIXME (sil-serialize-all) id:2562 gh:2574
      internal var _base: UnsafeBufferPointer<UInt16>.Iterator!
      @_versioned // FIXME (sil-serialize-all) id:3126 gh:3138
      internal var _iterator: IndexingIterator<_StringCore>
    }

    /// Returns an iterator over the Unicode scalars that make up this view.
    ///
    /// - Returns: An iterator over this collection's `Unicode.Scalar` elements.
    @_inlineable // FIXME (sil-serialize-all) id:2157 gh:2167
    public func makeIterator() -> Iterator {
      return Iterator(_core)
    }

    @_inlineable // FIXME (sil-serialize-all) id:2766 gh:2778
    public var description: String {
      return String(_core)
    }

    @_inlineable // FIXME (sil-serialize-all) id:2386 gh:2398
    public var debugDescription: String {
      return "StringUnicodeScalarView(\(self.description.debugDescription))"
    }

    @_versioned // FIXME (sil-serialize-all) id:2564 gh:2576
    internal var _core: _StringCore
    
    /// The offset of this view's `_core` from an original core. This works
    /// around the fact that `_StringCore` is always zero-indexed.
    /// `_coreOffset` should be subtracted from `UnicodeScalarIndex.encodedOffset`
    /// before that value is used as a `_core` index.
    @_versioned // FIXME (sil-serialize-all) id:3128 gh:3140
    internal var _coreOffset: Int
  }

  /// Creates a string corresponding to the given collection of Unicode
  /// scalars.
  ///
  /// You can use this initializer to create a new string from a slice of
  /// another string's `unicodeScalars` view.
  ///
  ///     let picnicGuest = "Deserving porcupine"
  ///     if let i = picnicGuest.unicodeScalars.index(of: " ") {
  ///         let adjective = String(picnicGuest.unicodeScalars[..<i])
  ///         print(adjective)
  ///     }
  ///     // Prints "Deserving"
  ///
  /// The `adjective` constant is created by calling this initializer with a
  /// slice of the `picnicGuest.unicodeScalars` view.
  ///
  /// - Parameter unicodeScalars: A collection of Unicode scalar values.
  @_inlineable // FIXME (sil-serialize-all) id:2161 gh:2173
  public init(_ unicodeScalars: UnicodeScalarView) {
    self.init(unicodeScalars._core)
  }

  /// The index type for a string's `unicodeScalars` view.
  public typealias UnicodeScalarIndex = UnicodeScalarView.Index
}

extension String.UnicodeScalarView : _SwiftStringView {
  @_inlineable // FIXME (sil-serialize-all) id:2768 gh:2780
  @_versioned // FIXME (sil-serialize-all) id:2389 gh:2401
  internal var _persistentContent : String { return String(_core) }
}

extension String {
  /// The string's value represented as a collection of Unicode scalar values.
  @_inlineable // FIXME (sil-serialize-all) id:2566 gh:2579
  public var unicodeScalars: UnicodeScalarView {
    get {
      return UnicodeScalarView(_core)
    }
    set {
      _core = newValue._core
    }
  }
}

extension String.UnicodeScalarView : RangeReplaceableCollection {
  /// Creates an empty view instance.
  @_inlineable // FIXME (sil-serialize-all) id:3132 gh:3144
  public init() {
    self = String.UnicodeScalarView(_StringCore())
  }
  
  /// Reserves enough space in the view's underlying storage to store the
  /// specified number of ASCII characters.
  ///
  /// Because a Unicode scalar value can require more than a single ASCII
  /// character's worth of storage, additional allocation may be necessary
  /// when adding to a Unicode scalar view after a call to
  /// `reserveCapacity(_:)`.
  ///
  /// - Parameter n: The minimum number of ASCII character's worth of storage
  ///   to allocate.
  ///
  /// - Complexity: O(*n*), where *n* is the capacity being reserved.
  @_inlineable // FIXME (sil-serialize-all) id:2164 gh:2176
  public mutating func reserveCapacity(_ n: Int) {
    _core.reserveCapacity(n)
  }
  
  /// Appends the given Unicode scalar to the view.
  ///
  /// - Parameter c: The character to append to the string.
  @_inlineable // FIXME (sil-serialize-all) id:2771 gh:2783
  public mutating func append(_ x: Unicode.Scalar) {
    _core.append(x)
  }

  /// Appends the Unicode scalar values in the given sequence to the view.
  ///
  /// - Parameter newElements: A sequence of Unicode scalar values.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the resulting view.
  @_inlineable // FIXME (sil-serialize-all) id:2392 gh:2404
  public mutating func append<S : Sequence>(contentsOf newElements: S)
    where S.Element == Unicode.Scalar {
    _core.append(contentsOf: newElements.lazy.flatMap { $0.utf16 })
  }
  
  /// Replaces the elements within the specified bounds with the given Unicode
  /// scalar values.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameters:
  ///   - bounds: The range of elements to replace. The bounds of the range
  ///     must be valid indices of the view.
  ///   - newElements: The new Unicode scalar values to add to the string.
  ///
  /// - Complexity: O(*m*), where *m* is the combined length of the view and
  ///   `newElements`. If the call to `replaceSubrange(_:with:)` simply
  ///   removes elements at the end of the string, the complexity is O(*n*),
  ///   where *n* is equal to `bounds.count`.
  @_inlineable // FIXME (sil-serialize-all) id:2568 gh:2580
  public mutating func replaceSubrange<C>(
    _ bounds: Range<Index>,
    with newElements: C
  ) where C : Collection, C.Element == Unicode.Scalar {
    let rawSubRange: Range<Int> = _toCoreIndex(bounds.lowerBound) ..<
      _toCoreIndex(bounds.upperBound)
    let lazyUTF16 = newElements.lazy.flatMap { $0.utf16 }
    _core.replaceSubrange(rawSubRange, with: lazyUTF16)
  }
}

// Index conversions
extension String.UnicodeScalarIndex {
  /// Creates an index in the given Unicode scalars view that corresponds
  /// exactly to the specified `UTF16View` position.
  ///
  /// The following example finds the position of a space in a string's `utf16`
  /// view and then converts that position to an index in the string's
  /// `unicodeScalars` view:
  ///
  ///     let cafe = "Café 🍵"
  ///
  ///     let utf16Index = cafe.utf16.index(of: 32)!
  ///     let scalarIndex = String.Index(utf16Index, within: cafe.unicodeScalars)!
  ///
  ///     print(String(cafe.unicodeScalars[..<scalarIndex]))
  ///     // Prints "Café"
  ///
  /// If the index passed as `sourcePosition` doesn't have an exact
  /// corresponding position in `unicodeScalars`, the result of the
  /// initializer is `nil`. For example, an attempt to convert the position of
  /// the trailing surrogate of a UTF-16 surrogate pair results in `nil`.
  ///
  /// - Parameters:
  ///   - sourcePosition: A position in the `utf16` view of a string. `utf16Index`
  ///     must be an element of `String(unicodeScalars).utf16.indices`.
  ///   - unicodeScalars: The `UnicodeScalarView` in which to find the new
  ///     position.
  @_inlineable // FIXME (sil-serialize-all) id:3134 gh:3146
  public init?(
    _ sourcePosition: String.UTF16Index,
    within unicodeScalars: String.UnicodeScalarView
  ) {
    if !unicodeScalars._isOnUnicodeScalarBoundary(sourcePosition) { return nil }
    self = sourcePosition
  }

  /// Returns the position in the given string that corresponds exactly to this
  /// index.
  ///
  /// This example first finds the position of a space (UTF-8 code point `32`)
  /// in a string's `utf8` view and then uses this method find the same position
  /// in the string.
  ///
  ///     let cafe = "Café 🍵"
  ///     let i = cafe.unicodeScalars.index(of: "🍵")
  ///     let j = i.samePosition(in: cafe)!
  ///     print(cafe[j...])
  ///     // Prints "🍵"
  ///
  /// - Parameter characters: The string to use for the index conversion.
  ///   This index must be a valid index of at least one view of `characters`.
  /// - Returns: The position in `characters` that corresponds exactly to
  ///   this index. If this index does not have an exact corresponding
  ///   position in `characters`, this method returns `nil`. For example,
  ///   an attempt to convert the position of a UTF-8 continuation byte
  ///   returns `nil`.
  @_inlineable // FIXME (sil-serialize-all) id:2167 gh:2179
  public func samePosition(in characters: String) -> String.Index? {
    return String.Index(self, within: characters)
  }
}

extension String.UnicodeScalarView {
  @_inlineable // FIXME (sil-serialize-all) id:2774 gh:2786
  @_versioned // FIXME (sil-serialize-all) id:2395 gh:2406
  internal func _isOnUnicodeScalarBoundary(_ i: Index) -> Bool {
    if _fastPath(_core.isASCII) { return true }
    if i == startIndex || i == endIndex {
      return true
    }
    if i._transcodedOffset != 0 { return false }
    let i2 = _toCoreIndex(i)
    if _fastPath(_core[i2] & 0xFC00 != 0xDC00) { return true }
    return _core[i2 &- 1] & 0xFC00 != 0xD800
  }
  
  // NOTE: Don't make this function inlineable.  Grapheme cluster id:2570 gh:2582
  // segmentation uses a completely different algorithm in Unicode 9.0.
  @_inlineable // FIXME (sil-serialize-all) id:3137 gh:3149
  @_versioned // FIXME (sil-serialize-all) id:2170 gh:2182
  internal func _isOnGraphemeClusterBoundary(_ i: Index) -> Bool {
    if i == startIndex || i == endIndex {
      return true
    }
    if !_isOnUnicodeScalarBoundary(i) { return false }
    let str = String(_core)
    return i == str.index(before: str.index(after: i))
  }
}

// Reflection
extension String.UnicodeScalarView : CustomReflectable {
  /// Returns a mirror that reflects the Unicode scalars view of a string.
  @_inlineable // FIXME (sil-serialize-all) id:2776 gh:2788
  public var customMirror: Mirror {
    return Mirror(self, unlabeledChildren: self)
  }
}

extension String.UnicodeScalarView : CustomPlaygroundQuickLookable {
  @_inlineable // FIXME (sil-serialize-all) id:2398 gh:2410
  public var customPlaygroundQuickLook: PlaygroundQuickLook {
    return .text(description)
  }
}

// backward compatibility for index interchange.  
extension String.UnicodeScalarView {
  @_inlineable // FIXME (sil-serialize-all) id:2572 gh:2584
  @available(
    swift, obsoleted: 4.0,
    message: "Any String view index conversion can fail in Swift 4; please unwrap the optional index")
  public func index(after i: Index?) -> Index {
    return index(after: i!)
  }
  @_inlineable // FIXME (sil-serialize-all) id:3139 gh:3151
  @available(
    swift, obsoleted: 4.0,
    message: "Any String view index conversion can fail in Swift 4; please unwrap the optional index")
  public func index(_ i: Index?,  offsetBy n: Int) -> Index {
    return index(i!, offsetBy: n)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2173 gh:2185
  @available(
    swift, obsoleted: 4.0,
    message: "Any String view index conversion can fail in Swift 4; please unwrap the optional indices")
  public func distance(from i: Index?, to j: Index?) -> Int {
    return distance(from: i!, to: j!)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2779 gh:2791
  @available(
    swift, obsoleted: 4.0,
    message: "Any String view index conversion can fail in Swift 4; please unwrap the optional index")
  public subscript(i: Index?) -> Unicode.Scalar {
    return self[i!]
  }
}

//===--- Slicing Support --------------------------------------------------===//
/// In Swift 3.2, in the absence of type context,
///
///   someString.unicodeScalars[
///     someString.unicodeScalars.startIndex
///     ..< someString.unicodeScalars.endIndex]
///
/// was deduced to be of type `String.UnicodeScalarView`.  Provide a
/// more-specific Swift-3-only `subscript` overload that continues to produce
/// `String.UnicodeScalarView`.
extension String.UnicodeScalarView {
  public typealias SubSequence = Substring.UnicodeScalarView

  @_inlineable // FIXME (sil-serialize-all) id:2400 gh:2412
  @available(swift, introduced: 4)
  public subscript(r: Range<Index>) -> String.UnicodeScalarView.SubSequence {
    return String.UnicodeScalarView.SubSequence(self, _bounds: r)
  }

  /// Accesses the Unicode scalar values in the given range.
  ///
  /// The example below uses this subscript to access the scalar values up
  /// to, but not including, the first comma (`","`) in the string.
  ///
  ///     let str = "All this happened, more or less."
  ///     let i = str.unicodeScalars.index(of: ",")!
  ///     let substring = str.unicodeScalars[str.unicodeScalars.startIndex ..< i]
  ///     print(String(substring))
  ///     // Prints "All this happened"
  ///
  /// - Complexity: O(*n*) if the underlying string is bridged from
  ///   Objective-C, where *n* is the length of the string; otherwise, O(1).
  @_inlineable // FIXME (sil-serialize-all) id:2574 gh:2586
  @available(swift, obsoleted: 4)
  public subscript(r: Range<Index>) -> String.UnicodeScalarView {
    let rawSubRange = _toCoreIndex(r.lowerBound)..<_toCoreIndex(r.upperBound)
    return String.UnicodeScalarView(
      _core[rawSubRange], coreOffset: r.lowerBound.encodedOffset)
  }

  @_inlineable // FIXME (sil-serialize-all) id:3142 gh:3154
  @available(swift, obsoleted: 4)
  public subscript(bounds: ClosedRange<Index>) -> String.UnicodeScalarView {
    return self[bounds.relative(to: self)]
  }
}
