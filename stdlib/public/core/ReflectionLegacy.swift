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

/// How children of this value should be presented in the IDE.
public enum _MirrorDisposition {
  /// As a struct.
  case `struct`
  /// As a class.
  case `class`
  /// As an enum.
  case `enum`
  /// As a tuple.
  case tuple
  /// As a miscellaneous aggregate with a fixed set of children.
  case aggregate
  /// As a container that is accessed by index.
  case indexContainer
  /// As a container that is accessed by key.
  case keyContainer
  /// As a container that represents membership of its values.
  case membershipContainer
  /// As a miscellaneous container with a variable number of children.
  case container
  /// An Optional which can have either zero or one children.
  case optional
  /// An Objective-C object imported in Swift.
  case objCObject
}

/// The type returned by `_reflect(x)`; supplies an API for runtime
/// reflection on `x`.
public protocol _Mirror {
  /// The instance being reflected.
  var value: Any { get }

  /// Identical to `type(of: value)`.
  var valueType: Any.Type { get }

  /// A unique identifier for `value` if it is a class instance; `nil`
  /// otherwise.
  var objectIdentifier: ObjectIdentifier? { get }

  /// The count of `value`'s logical children.
  var count: Int { get }

  /// Get a name and mirror for the `i`th logical child.
  subscript(i: Int) -> (String, _Mirror) { get }

  /// A string description of `value`.
  var summary: String { get }

  /// A rich representation of `value` for an IDE, or `nil` if none is supplied.
  var quickLookObject: PlaygroundQuickLook? { get }

  /// How `value` should be presented in an IDE.
  var disposition: _MirrorDisposition { get }
}

/// An entry point that can be called from C++ code to get the summary string
/// for an arbitrary object. The memory pointed to by "out" is initialized with
/// the summary string.
@_inlineable // FIXME (sil-serialize-all) id:1649 gh:1656
@_silgen_name("swift_getSummary")
public // COMPILER_INTRINSIC
func _getSummary<T>(_ out: UnsafeMutablePointer<String>, x: T) {
  out.initialize(to: String(reflecting: x))
}

/// Produce a mirror for any value.  The runtime produces a mirror that
/// structurally reflects values of any type.
@_inlineable // FIXME (sil-serialize-all) id:1363 gh:1370
@_versioned // FIXME (sil-serialize-all) id:2325 gh:2337
@_silgen_name("swift_reflectAny")
internal func _reflect<T>(_ x: T) -> _Mirror

// -- Implementation details for the runtime's _Mirror implementation

@_inlineable // FIXME (sil-serialize-all) id:1464 gh:1470
@_versioned // FIXME (sil-serialize-all) id:1684 gh:1691
@_silgen_name("swift_MagicMirrorData_summary")
internal func _swift_MagicMirrorData_summaryImpl(
  _ metadata: Any.Type, _ result: UnsafeMutablePointer<String>
)

@_fixed_layout
public struct _MagicMirrorData {
  @_versioned // FIXME (sil-serialize-all) id:1652 gh:1659
  internal let owner: Builtin.NativeObject
  @_versioned // FIXME (sil-serialize-all) id:1367 gh:1374
  internal let ptr: Builtin.RawPointer
  @_versioned // FIXME (sil-serialize-all) id:2328 gh:2340
  internal let metadata: Any.Type

  @_inlineable // FIXME (sil-serialize-all) id:1467 gh:1474
  @_versioned // FIXME (sil-serialize-all) id:1688 gh:1693
  internal var value: Any {
    @_silgen_name("swift_MagicMirrorData_value")get
  }
  @_inlineable // FIXME (sil-serialize-all) id:1655 gh:1662
  @_versioned // FIXME (sil-serialize-all) id:1370 gh:1377
  internal var valueType: Any.Type {
    @_silgen_name("swift_MagicMirrorData_valueType")get
  }

  @_inlineable // FIXME (sil-serialize-all) id:2333 gh:2345
  public var objcValue: Any {
    @_silgen_name("swift_MagicMirrorData_objcValue")get
  }
  @_inlineable // FIXME (sil-serialize-all) id:1470 gh:1477
  public var objcValueType: Any.Type {
    @_silgen_name("swift_MagicMirrorData_objcValueType")get
  }

  @_inlineable // FIXME (sil-serialize-all) id:1694 gh:1701
  @_versioned // FIXME (sil-serialize-all) id:1692 gh:1699
  internal var summary: String {
    let (_, result) = _withUninitializedString {
      _swift_MagicMirrorData_summaryImpl(self.metadata, $0)
    }
    return result
  }

  @_inlineable // FIXME (sil-serialize-all) id:1373 gh:1380
  public func _loadValue<T>(ofType _: T.Type) -> T {
    return Builtin.load(ptr) as T
  }
}

@_versioned
internal struct _OpaqueMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:2337 gh:2349
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1473 gh:1480
  @_versioned // FIXME (sil-serialize-all) id:1702 gh:1709
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:1696 gh:1703
  @_versioned // FIXME (sil-serialize-all) id:1377 gh:1384
  internal var valueType: Any.Type { return data.valueType }
  @_inlineable // FIXME (sil-serialize-all) id:2341 gh:2353
  @_versioned // FIXME (sil-serialize-all) id:1476 gh:1483
  internal var objectIdentifier: ObjectIdentifier? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1707 gh:1714
  @_versioned // FIXME (sil-serialize-all) id:1698 gh:1705
  internal var count: Int { return 0 }
  @_inlineable // FIXME (sil-serialize-all) id:1381 gh:1388
  @_versioned // FIXME (sil-serialize-all) id:2344 gh:2356
  internal subscript(i: Int) -> (String, _Mirror) {
    _preconditionFailure("no children")
  }
  @_inlineable // FIXME (sil-serialize-all) id:1480 gh:1487
  @_versioned // FIXME (sil-serialize-all) id:1712 gh:1719
  internal var summary: String { return data.summary }
  @_inlineable // FIXME (sil-serialize-all) id:1703 gh:1710
  @_versioned // FIXME (sil-serialize-all) id:1384 gh:1392
  internal var quickLookObject: PlaygroundQuickLook? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:2347 gh:2359
  @_versioned // FIXME (sil-serialize-all) id:1482 gh:1489
  internal var disposition: _MirrorDisposition { return .aggregate }
}

@_inlineable // FIXME (sil-serialize-all) id:1715 gh:1722
@_versioned // FIXME (sil-serialize-all) id:1706 gh:1713
@_silgen_name("swift_TupleMirror_count")
internal func _getTupleCount(_: _MagicMirrorData) -> Int

// Like the other swift_*Mirror_subscript functions declared here and
// elsewhere, this is implemented in the runtime.  The Swift CC would
// normally require the String to be returned directly and the _Mirror
// indirectly.  However, Clang isn't currently capable of doing that
// reliably because the size of String exceeds the normal direct-return
// ABI rules on most platforms.  Therefore, we make this function generic,
// which has the disadvantage of passing the String type metadata as an
// extra argument, but does force the string to be returned indirectly.
@_inlineable // FIXME (sil-serialize-all) id:1387 gh:1394
@_versioned // FIXME (sil-serialize-all) id:2350 gh:2362
@_silgen_name("swift_TupleMirror_subscript")
internal func _getTupleChild<T>(_: Int, _: _MagicMirrorData) -> (T, _Mirror)

@_versioned
internal struct _TupleMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:1486 gh:1493
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1718 gh:1725
  @_versioned // FIXME (sil-serialize-all) id:1711 gh:1718
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:1390 gh:1397
  @_versioned // FIXME (sil-serialize-all) id:2353 gh:2365
  internal var valueType: Any.Type { return data.valueType }
  @_inlineable // FIXME (sil-serialize-all) id:1488 gh:1495
  @_versioned // FIXME (sil-serialize-all) id:1721 gh:1728
  internal var objectIdentifier: ObjectIdentifier? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1714 gh:1721
  @_versioned // FIXME (sil-serialize-all) id:1391 gh:1398
  internal var count: Int {
    return _getTupleCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2357 gh:2369
  @_versioned // FIXME (sil-serialize-all) id:1491 gh:1498
  internal subscript(i: Int) -> (String, _Mirror) {
    return _getTupleChild(i, data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1723 gh:1730
  @_versioned // FIXME (sil-serialize-all) id:1717 gh:1724
  internal var summary: String { return "(\(count) elements)" }
  @_inlineable // FIXME (sil-serialize-all) id:1392 gh:1399
  @_versioned // FIXME (sil-serialize-all) id:2361 gh:2373
  internal var quickLookObject: PlaygroundQuickLook? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1493 gh:1500
  @_versioned // FIXME (sil-serialize-all) id:1727 gh:1734
  internal var disposition: _MirrorDisposition { return .tuple }
}

@_inlineable // FIXME (sil-serialize-all) id:1720 gh:1727
@_versioned // FIXME (sil-serialize-all) id:1393 gh:1400
@_silgen_name("swift_StructMirror_count")
internal func _getStructCount(_: _MagicMirrorData) -> Int

@_inlineable // FIXME (sil-serialize-all) id:2365 gh:2377
@_versioned // FIXME (sil-serialize-all) id:1496 gh:1503
@_silgen_name("swift_StructMirror_subscript")
internal func _getStructChild<T>(_: Int, _: _MagicMirrorData) -> (T, _Mirror)

@_versioned
internal struct _StructMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:1730 gh:1737
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1725 gh:1732
  @_versioned // FIXME (sil-serialize-all) id:1394 gh:1401
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:2367 gh:2379
  @_versioned // FIXME (sil-serialize-all) id:1499 gh:1506
  internal var valueType: Any.Type { return data.valueType }
  @_inlineable // FIXME (sil-serialize-all) id:1733 gh:1740
  @_versioned // FIXME (sil-serialize-all) id:1728 gh:1735
  internal var objectIdentifier: ObjectIdentifier? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1395 gh:1402
  @_versioned // FIXME (sil-serialize-all) id:2370 gh:2382
  internal var count: Int {
    return _getStructCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1501 gh:1508
  @_versioned // FIXME (sil-serialize-all) id:1736 gh:1743
  internal subscript(i: Int) -> (String, _Mirror) {
    return _getStructChild(i, data)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1732 gh:1739
  @_versioned // FIXME (sil-serialize-all) id:1396 gh:1403
  internal var summary: String {
    return _typeName(valueType)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2373 gh:2385
  @_versioned // FIXME (sil-serialize-all) id:1504 gh:1511
  internal var quickLookObject: PlaygroundQuickLook? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1739 gh:1746
  @_versioned // FIXME (sil-serialize-all) id:1735 gh:1742
  internal var disposition: _MirrorDisposition { return .`struct` }
}

@_inlineable // FIXME (sil-serialize-all) id:1398 gh:1405
@_versioned // FIXME (sil-serialize-all) id:2376 gh:2388
@_silgen_name("swift_EnumMirror_count")
internal func _getEnumCount(_: _MagicMirrorData) -> Int

@_inlineable // FIXME (sil-serialize-all) id:1506 gh:1513
@_versioned // FIXME (sil-serialize-all) id:1743 gh:1750
@_silgen_name("swift_EnumMirror_subscript")
internal func _getEnumChild<T>(_: Int, _: _MagicMirrorData) -> (T, _Mirror)

@_inlineable // FIXME (sil-serialize-all) id:1737 gh:1744
@_versioned // FIXME (sil-serialize-all) id:1400 gh:1407
@_silgen_name("swift_EnumMirror_caseName")
internal func _swift_EnumMirror_caseName(
    _ data: _MagicMirrorData) -> UnsafePointer<CChar>

@_versioned
internal struct _EnumMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:2380 gh:2392
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1509 gh:1516
  @_versioned // FIXME (sil-serialize-all) id:1746 gh:1753
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:1740 gh:1747
  @_versioned // FIXME (sil-serialize-all) id:1403 gh:1410
  internal var valueType: Any.Type { return data.valueType }
  @_inlineable // FIXME (sil-serialize-all) id:2385 gh:2397
  @_versioned // FIXME (sil-serialize-all) id:1512 gh:1519
  internal var objectIdentifier: ObjectIdentifier? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1749 gh:1756
  @_versioned // FIXME (sil-serialize-all) id:1742 gh:1749
  internal var count: Int {
    return _getEnumCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1410 gh:1417
  @_versioned // FIXME (sil-serialize-all) id:2390 gh:2402
  internal var caseName: UnsafePointer<CChar> {
    return _swift_EnumMirror_caseName(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1514 gh:1521
  @_versioned // FIXME (sil-serialize-all) id:1751 gh:1758
  internal subscript(i: Int) -> (String, _Mirror) {
    return _getEnumChild(i, data)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1745 gh:1752
  @_versioned // FIXME (sil-serialize-all) id:1973 gh:1981
  internal var summary: String {
    let maybeCaseName = String(validatingUTF8: self.caseName)
    let typeName = _typeName(valueType)
    if let caseName = maybeCaseName {
      return typeName + "." + caseName
    }
    return typeName
  }
  @_inlineable // FIXME (sil-serialize-all) id:2393 gh:2405
  @_versioned // FIXME (sil-serialize-all) id:1518 gh:1525
  internal var quickLookObject: PlaygroundQuickLook? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1774 gh:1781
  @_versioned // FIXME (sil-serialize-all) id:1748 gh:1755
  internal var disposition: _MirrorDisposition { return .`enum` }
}

@_inlineable // FIXME (sil-serialize-all) id:1977 gh:1984
@_versioned // FIXME (sil-serialize-all) id:2396 gh:2408
@_silgen_name("swift_ClassMirror_count")
internal func _getClassCount(_: _MagicMirrorData) -> Int

@_inlineable // FIXME (sil-serialize-all) id:1521 gh:1528
@_versioned // FIXME (sil-serialize-all) id:1776 gh:1783
@_silgen_name("swift_ClassMirror_subscript")
internal func _getClassChild<T>(_: Int, _: _MagicMirrorData) -> (T, _Mirror)

#if _runtime(_ObjC)
@_inlineable // FIXME (sil-serialize-all) id:1750 gh:1757
@_silgen_name("swift_ClassMirror_quickLookObject")
public func _swift_ClassMirror_quickLookObject(_: _MagicMirrorData) -> AnyObject

@_inlineable // FIXME (sil-serialize-all) id:1987 gh:1994
@_versioned // FIXME (sil-serialize-all) id:2399 gh:2411
@_silgen_name("_swift_stdlib_NSObject_isKindOfClass")
internal func _swift_NSObject_isImpl(_ object: AnyObject, kindOf: AnyObject) -> Bool

@_inlineable // FIXME (sil-serialize-all) id:1524 gh:1531
@_versioned // FIXME (sil-serialize-all) id:1780 gh:1787
internal func _is(_ object: AnyObject, kindOf `class`: String) -> Bool {
  return _swift_NSObject_isImpl(object, kindOf: `class` as AnyObject)
}

@_inlineable // FIXME (sil-serialize-all) id:1753 gh:1759
@_versioned // FIXME (sil-serialize-all) id:1991 gh:1998
internal func _getClassPlaygroundQuickLook(
  _ object: AnyObject
) -> PlaygroundQuickLook? {
  if _is(object, kindOf: "NSNumber") {
    let number: _NSNumber = unsafeBitCast(object, to: _NSNumber.self)
    switch UInt8(number.objCType[0]) {
    case UInt8(ascii: "d"):
      return .double(number.doubleValue)
    case UInt8(ascii: "f"):
      return .float(number.floatValue)
    case UInt8(ascii: "Q"):
      return .uInt(number.unsignedLongLongValue)
    default:
      return .int(number.longLongValue)
    }
  } else if _is(object, kindOf: "NSAttributedString") {
    return .attributedString(object)
  } else if _is(object, kindOf: "NSImage") ||
            _is(object, kindOf: "UIImage") ||
            _is(object, kindOf: "NSImageView") ||
            _is(object, kindOf: "UIImageView") ||
            _is(object, kindOf: "CIImage") ||
            _is(object, kindOf: "NSBitmapImageRep") {
    return .image(object)
  } else if _is(object, kindOf: "NSColor") ||
            _is(object, kindOf: "UIColor") {
    return .color(object)
  } else if _is(object, kindOf: "NSBezierPath") ||
            _is(object, kindOf: "UIBezierPath") {
    return .bezierPath(object)
  } else if _is(object, kindOf: "NSString") {
    return .text(_forceBridgeFromObjectiveC(object, String.self))
  }

  return .none
}

#endif

@_versioned
internal struct _ClassMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:2401 gh:2413
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1527 gh:1534
  @_versioned // FIXME (sil-serialize-all) id:1783 gh:1790
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:1756 gh:1763
  @_versioned // FIXME (sil-serialize-all) id:1994 gh:2001
  internal var valueType: Any.Type { return data.valueType }
  @_inlineable // FIXME (sil-serialize-all) id:2403 gh:2415
  @_versioned // FIXME (sil-serialize-all) id:1530 gh:1537
  internal var objectIdentifier: ObjectIdentifier? {
    return data._loadValue(ofType: ObjectIdentifier.self)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1786 gh:1793
  @_versioned // FIXME (sil-serialize-all) id:1758 gh:1765
  internal var count: Int {
    return _getClassCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1996 gh:2003
  @_versioned // FIXME (sil-serialize-all) id:2405 gh:2418
  internal subscript(i: Int) -> (String, _Mirror) {
    return _getClassChild(i, data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1532 gh:1539
  @_versioned // FIXME (sil-serialize-all) id:1788 gh:1795
  internal var summary: String {
    return _typeName(valueType)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1761 gh:1768
  @_versioned // FIXME (sil-serialize-all) id:1999 gh:2006
  internal var quickLookObject: PlaygroundQuickLook? {
#if _runtime(_ObjC)
    let object = _swift_ClassMirror_quickLookObject(data)
    return _getClassPlaygroundQuickLook(object)
#else
    return nil
#endif
  }
  @_inlineable // FIXME (sil-serialize-all) id:2407 gh:2419
  @_versioned // FIXME (sil-serialize-all) id:1535 gh:1540
  internal var disposition: _MirrorDisposition { return .`class` }
}

@_versioned
internal struct _ClassSuperMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:1791 gh:1798
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:1764 gh:1771
  @_versioned // FIXME (sil-serialize-all) id:2002 gh:2009
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:2409 gh:2421
  @_versioned // FIXME (sil-serialize-all) id:1539 gh:1546
  internal var valueType: Any.Type { return data.valueType }

  // Suppress the value identifier for super mirrors.
  @_inlineable // FIXME (sil-serialize-all) id:1793 gh:1800
  @_versioned // FIXME (sil-serialize-all) id:1767 gh:1774
  internal var objectIdentifier: ObjectIdentifier? {
    return nil
  }
  @_inlineable // FIXME (sil-serialize-all) id:2005 gh:2013
  @_versioned // FIXME (sil-serialize-all) id:2411 gh:2423
  internal var count: Int {
    return _getClassCount(data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1542 gh:1550
  @_versioned // FIXME (sil-serialize-all) id:1796 gh:1803
  internal subscript(i: Int) -> (String, _Mirror) {
    return _getClassChild(i, data)
  }
  @_inlineable // FIXME (sil-serialize-all) id:1770 gh:1777
  @_versioned // FIXME (sil-serialize-all) id:2007 gh:2014
  internal var summary: String {
    return _typeName(data.metadata)
  }
  @_inlineable // FIXME (sil-serialize-all) id:2414 gh:2428
  @_versioned // FIXME (sil-serialize-all) id:1545 gh:1552
  internal var quickLookObject: PlaygroundQuickLook? { return nil }
  @_inlineable // FIXME (sil-serialize-all) id:1798 gh:1805
  @_versioned // FIXME (sil-serialize-all) id:1773 gh:1780
  internal var disposition: _MirrorDisposition { return .`class` }
}

@_versioned
internal struct _MetatypeMirror : _Mirror {
  @_versioned // FIXME (sil-serialize-all) id:2009 gh:2016
  internal let data: _MagicMirrorData

  @_inlineable // FIXME (sil-serialize-all) id:2416 gh:2427
  @_versioned // FIXME (sil-serialize-all) id:1548 gh:1555
  internal var value: Any { return data.value }
  @_inlineable // FIXME (sil-serialize-all) id:1801 gh:1808
  @_versioned // FIXME (sil-serialize-all) id:1778 gh:1785
  internal var valueType: Any.Type { return data.valueType }

  @_inlineable // FIXME (sil-serialize-all) id:2012 gh:2019
  @_versioned // FIXME (sil-serialize-all) id:2419 gh:2431
  internal var objectIdentifier: ObjectIdentifier? {
    return data._loadValue(ofType: ObjectIdentifier.self)
  }

  @_inlineable // FIXME (sil-serialize-all) id:1552 gh:1559
  @_versioned // FIXME (sil-serialize-all) id:1804 gh:1811
  internal var count: Int {
    return 0
  }
  @_inlineable // FIXME (sil-serialize-all) id:1781 gh:1788
  @_versioned // FIXME (sil-serialize-all) id:2017 gh:2024
  internal subscript(i: Int) -> (String, _Mirror) {
    _preconditionFailure("no children")
  }
  @_inlineable // FIXME (sil-serialize-all) id:2423 gh:2435
  @_versioned // FIXME (sil-serialize-all) id:1556 gh:1563
  internal var summary: String {
    return _typeName(data._loadValue(ofType: Any.Type.self))
  }
  @_inlineable // FIXME (sil-serialize-all) id:1806 gh:1813
  @_versioned // FIXME (sil-serialize-all) id:1784 gh:1791
  internal var quickLookObject: PlaygroundQuickLook? { return nil }

  // Special disposition for types?
  @_inlineable // FIXME (sil-serialize-all) id:2022 gh:2029
  @_versioned // FIXME (sil-serialize-all) id:2429 gh:2441
  internal var disposition: _MirrorDisposition { return .aggregate }
}

