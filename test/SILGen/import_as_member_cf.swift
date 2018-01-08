// RUN: %target-swift-frontend -enable-sil-ownership -emit-silgen -I %S/../IDE/Inputs/custom-modules %s 2>&1 | %FileCheck --check-prefix=SIL %s
// REQUIRES: objc_interop

import ImportAsMember.C

// SIL-LABEL: sil {{.*}}readSemiModularPowerSupply{{.*}}
public func readSemiModularPowerSupply() -> CCPowerSupply {
  // TODO: actual body id:3559 gh:3571
  // FIXME: this asserts id:3956 gh:3968
  return CCPowerSupply.semiModular
}

