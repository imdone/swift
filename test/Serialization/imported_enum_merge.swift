// RUN: rm -rf %t
// RUN: mkdir -p %t

// FIXME: BEGIN -enable-source-import hackaround id:3383 gh:3395
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -emit-module -o %t %clang-importer-sdk-path/swift-modules/CoreGraphics.swift
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) -emit-module -o %t %clang-importer-sdk-path/swift-modules/Foundation.swift
// FIXME: END -enable-source-import hackaround id:3687 gh:3699

// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk-nosource -I %t) -emit-module -o %t/UsesImportedEnums-a.swiftmodule -parse-as-library %S/Inputs/use_imported_enums.swift -module-name UsesImportedEnums
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk-nosource -I %t) -merge-modules -module-name UsesImportedEnums -emit-module -o %t/UsesImportedEnums.swiftmodule %t/UsesImportedEnums-a.swiftmodule

// REQUIRES: objc_interop
