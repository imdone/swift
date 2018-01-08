// RUN: %target-typecheck-verify-swift -swift-version 4

// FIXME: make these errors id:3877 gh:3889

func test0(fn: (() -> ()) -> ()) {
  fn { fn {} } // expected-error {{passing a closure which captures a non-escaping function parameter 'fn' to a call to a non-escaping function parameter can allow re-entrant modification of a variable}}
}

func test1(fn: (() -> ()) -> ()) { // expected-note {{parameter 'fn' is implicitly non-escaping}}
  // TODO: infer that this function is noescape from its captures id:4116 gh:4128
  func foo() {
    fn { fn {} } // expected-error {{can allow re-entrant modification}}
    // expected-error@-1 {{declaration closing over non-escaping parameter 'fn' may allow it to escape}}
  }
}

func test2(x: inout Int, fn: (() -> ()) -> ()) {
  func foo(myfn: () -> ()) {
    x += 1
    myfn()
  }

  // Make sure we only complain about calls to noescape parameters.
  foo { fn {} }
}

func test3(fn: (() -> ()) -> ()) {
  { myfn in myfn { fn {} } }(fn) // expected-error {{can allow re-entrant modification}}
}

func test4(fn: (() -> ()) -> ()) { // expected-note {{parameter 'fn' is implicitly non-escaping}}
  // TODO: infer that this function is noescape from its captures id:3135 gh:3147
  func foo() {
    fn {}
    // expected-error@-1 {{declaration closing over non-escaping parameter 'fn' may allow it to escape}}
    // FIXME: if the above is ever not an error, we should diagnose at the call below id:3487 gh:3498
  }

  fn(foo)
}
