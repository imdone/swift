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

import SwiftShims
typealias _HeapObject = SwiftShims.HeapObject

@_versioned
internal protocol _HeapBufferHeader_ {
  associatedtype Value
  init(_ value: Value)
  var value: Value { get set }
}

@_fixed_layout // FIXME (sil-serialize-all) id:811 gh:818
@_versioned
internal struct _HeapBufferHeader<T> : _HeapBufferHeader_ {
  internal typealias Value = T
  @_inlineable // FIXME (sil-serialize-all) id:1754 gh:1761
  @_versioned // FIXME (sil-serialize-all) id:943 gh:950
  internal init(_ value: T) { self.value = value }
  @_versioned // FIXME (sil-serialize-all) id:1041 gh:1048
  internal var value: T
}

internal typealias _HeapBuffer<Value,Element>
  = ManagedBufferPointer<_HeapBufferHeader<Value>, Element>

internal typealias _HeapBufferStorage<Value,Element>
  = ManagedBuffer<_HeapBufferHeader<Value>, Element>

extension ManagedBufferPointer where Header : _HeapBufferHeader_ {
  internal typealias Value = Header.Value

  @_inlineable // FIXME (sil-serialize-all) id:1170 gh:1177
  @_versioned
  internal init(
    _ storageClass: AnyClass,
    _ initializer: Value, _ capacity: Int
  ) {
    self.init(
      _uncheckedBufferClass: storageClass,
      minimumCapacity: capacity)
    self.withUnsafeMutablePointerToHeader {
      $0.initialize(to: Header(initializer))
    }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:814 gh:821
  @_versioned
  internal var value: Value {
    @inline(__always)
    get {
      return header.value
    }
    @inline(__always)
    set {
      return header.value = newValue
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:1757 gh:1764
  @_versioned
  internal subscript(i: Int) -> Element {
    @inline(__always)
    get {
      return withUnsafeMutablePointerToElements { $0[i] }
    }
  }

  @_inlineable // FIXME (sil-serialize-all) id:946 gh:953
  @_versioned
  internal var baseAddress: UnsafeMutablePointer<Element> {
    @inline(__always)
    get {
      return withUnsafeMutablePointerToElements { $0 }
    }
  }
  
  @_inlineable // FIXME (sil-serialize-all) id:1043 gh:1050
  @_versioned
  internal var storage: AnyObject? {
    @inline(__always)
    get {
      return buffer
    }
  }
}
