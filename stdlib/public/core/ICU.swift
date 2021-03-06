//===--- ICU.swift --------------------------------------------------------===//
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

extension __swift_stdlib_UErrorCode {
  @_inlineable // FIXME (sil-serialize-all) id:1173 gh:1180
  @_versioned // FIXME (sil-serialize-all) id:817 gh:824
  internal var isFailure: Bool {
    return rawValue > __swift_stdlib_U_ZERO_ERROR.rawValue
  }
  @_inlineable // FIXME (sil-serialize-all) id:1760 gh:1767
  @_versioned // FIXME (sil-serialize-all) id:949 gh:956
  internal var isWarning: Bool {
    return rawValue < __swift_stdlib_U_ZERO_ERROR.rawValue
  }
  @_inlineable // FIXME (sil-serialize-all) id:1045 gh:1052
  @_versioned // FIXME (sil-serialize-all) id:1176 gh:1183
  internal var isSuccess: Bool {
    return rawValue <= __swift_stdlib_U_ZERO_ERROR.rawValue
  }
}
