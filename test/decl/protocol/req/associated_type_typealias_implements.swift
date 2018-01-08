// RUN: %target-typecheck-verify-swift

protocol P { }

protocol Q {
  associatedtype T
  associatedtype U // expected-note 2{{protocol requires nested type 'U'; do you want to add it?}}
}

protocol R: Q {
}

struct XT: P { }
struct XTWithoutP { }

struct XU { }

extension R where T: P {
  @_implements(Q, U)
  typealias _Default_U = XU
}

struct Y1: R {
  typealias T = XT
  // okay: infers U = XU
}

struct Y2: R { // expected-error{{type 'Y2' does not conform to protocol 'Q'}}
  typealias T = XTWithoutP

  // FIXME: More detail from diagnostic. id:4082 gh:4094
  // error: T: P fails
}

struct Y3: Q { // expected-error{{type 'Y3' does not conform to protocol 'Q'}}
  typealias T = XT
  // FIXME: More detail from diagnostic. id:3028 gh:3040
}
