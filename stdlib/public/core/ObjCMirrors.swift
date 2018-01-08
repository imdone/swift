//===--- ObjCMirrors.swift ------------------------------------------------===//
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

#if _runtime(_ObjC)
@_inlineable // FIXME (sil-serialize-all) id:1265 gh:1272
@_versioned // FIXME (sil-serialize-all) id:2226 gh:2238
@_silgen_name("swift_ObjCMirror_count") 
internal func _getObjCCount(_: _MagicMirrorData) -> Int
@_inlineable // FIXME (sil-serialize-all) id:1223 gh:1230
@_versioned // FIXME (sil-serialize-all) id:1571 gh:1578
@_silgen_name("swift_ObjCMirror_subscript") 
internal func _getObjCChild<T>(_: Int, _: _MagicMirrorData) -> (T, _Mirror)

@_inlineable // FIXME (sil-serialize-all) id:1575 gh:1582
@_versioned // FIXME (sil-serialize-all) id:1268 gh:1275
internal func _getObjCSummary(_ data: _MagicMirrorData) -> String {
  let theDescription = _swift_stdlib_objcDebugDescription(data._loadValue(ofType: AnyObject.self)) as AnyObject
  return _cocoaStringToSwiftString_NonASCII(theDescription)
}

public // SPI(runtime)
struct _ObjCMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:2229 gh:2241
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1225 gh:1232
  public var value: Any { return data.objcValue }
  @_inlineable // FIXME (sil-serialize-all) id:1574 gh:1581
  public var valueType: Any.Type { return data.objcValueType }
  @_inlineable // FIXME (sil-serialize-all) id:1578 gh:1585
  public var objectIdentifier: ObjectIdentifier? {
    return data._loadValue(ofType: ObjectIdentifier.self)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1271 gh:1278
  public var count: Int {
    return _getObjCCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2231 gh:2243
  public subscript(i: Int) -> (String, _Mirror) {
    return _getObjCChild(i, data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1228 gh:1235
  public var summary: String {
    return _getObjCSummary(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1577 gh:1584
  public var quickLookObject: PlaygroundQuickLook? {
    let object = _swift_ClassMirror_quickLookObject(data)
    return _getClassPlaygroundQuickLook(object)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1580 gh:1587
  public var disposition: _MirrorDisposition { return .objCObject }
}

public // SPI(runtime)
struct _ObjCSuperMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:1275 gh:1283
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:2233 gh:2245
  public var value: Any { return data.objcValue }
  @_inlineable // FIXME (sil-serialize-all) id:1232 gh:1239
  public var valueType: Any.Type { return data.objcValueType }

  // Suppress the value identifier for super mirrors.
  @_inlineable // FIXME (sil-serialize-all) id:1581 gh:1588
  public var objectIdentifier: ObjectIdentifier? {
    return nil
  }
  @_inlineable // FIXME (sil-serialize-all) id:1582 gh:1589
  public var count: Int {
    return _getObjCCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1278 gh:1285
  public subscript(i: Int) -> (String, _Mirror) {
    return _getObjCChild(i, data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2235 gh:2247
  public var summary: String {
    return _getObjCSummary(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1236 gh:1243
  public var quickLookObject: PlaygroundQuickLook? {
    let object = _swift_ClassMirror_quickLookObject(data)
    return _getClassPlaygroundQuickLook(object)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1585 gh:1592
  public var disposition: _MirrorDisposition { return .objCObject }
}
#endif
