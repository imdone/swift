// RUN: %swift-syntax-test -input-source-filename %s -parse-gen > %t
// RUN: diff -u %s %t
// RUN: %swift-syntax-test -input-source-filename %s -parse-gen -print-node-kind > %t.withkinds
// RUN: diff -u %S/Outputs/round_trip_parse_gen.swift.withkinds %t.withkinds

import ABC
import A.B.C
@objc import A.B
@objc import typealias A.B
import struct A.B

#if Blah
class C {
  func bar(_ a: Int) {}
  func bar1(_ a: Float) -> Float { return -0.6 + 0.1 - 0.3 }
  func bar2(a: Int, b: Int, c:Int) -> Int { return 1 }
  func bar3(a: Int) -> Int { return 1 }
  func bar4(_ a: Int) -> Int { return 1 }
  func foo() {
    var a = /*comment*/"ab\(x)c"/*comment*/
    var b = /*comment*/+2/*comment*/
    bar(1)
    bar(+10)
    bar(-10)
    bar1(-1.1)
    bar1(1.1)
    var f = /*comments*/+0.1/*comments*/
    foo()
  }

  func foo1() {
    _ = bar2(a:1, b:2, c:2)
    _ = bar2(a:1 + 1, b:2 * 2 + 2, c:2 + 2)
    _ = bar2(a : bar2(a: 1, b: 2, c: 3), b: 2, c: 3)
    _ = bar3(a : bar3(a: bar3(a: 1)))
    _ = bar4(bar4(bar4(1)))
    _ = [:]
    _ = [1, 2, 3, 4]
    _ = [1:1, 2:2, 3:3, 4:4]
    _ = [bar3(a:1), bar3(a:1), bar3(a:1), bar3(a:1)]
    _ = ["a": bar3(a:1), "b": bar3(a:1), "c": bar3(a:1), "d": bar3(a:1)]
    foo(nil, nil, nil)
  }
  func boolAnd() -> Bool { return true && false }
  func boolOr() -> Bool { return true || false }

  func foo2() {
    _ = true ? 1 : 0
    _ = (true ? 1 : 0) ? (true ? 1 : 0) : (true ? 1 : 0)
    _ = (1, 2)
    _ = (first: 1, second: 2)
    _ = (1)
    _ = (first: 1)
    if !true {
      return
    }
  }

  func foo3() {
    _ = [Any]()
    _ = a.a.a
    _ = a.b
    _ = 1.a
    (1 + 1).a.b.foo
    _ = a as Bool || a as! Bool || a as? Bool
    _ = a is Bool
  }

  func superExpr() {
    _ = super.foo
    super.bar()
    super[12] = 1
    super.init()
  }

  func implictMember() {
    _ = .foo
    _ = .foo(x: 12)
    _ = .foo { 12 }
    _ = .foo[12]
    _ = .foo.bar
  }
}

#endif

#if blah
typealias A = Any
#elseif blahblah
typealias B = (Array<Array<Any>>.Element, x: Int)
#else
typealias C = [Int]
#endif
typealias D = [Int: String]
typealias E = Int?.Protocol
typealias F = [Int]!.Type
typealias G = (a x: Int, _ y: Int ... = 1) throw -> () -> ()
typealias H = () rethrows -> ()
typealias I = (A & B<C>) -> C & D
typealias J = inout @autoclosure () -> Int
typealias K = (@invalidAttr Int, inout Int, __shared Int, __owned Int) -> ()

@objc private typealias T<a,b> = Int
@objc private typealias T<a,b>

class Foo {
  let bar: Int
}

class Bar: Foo {
  var foo: Int = 42
}

class C<A, B> where A: Foo, B == Bar {}

@available(*, unavailable)
private class C {}

struct foo {
  struct foo {
    struct foo {
      func foo() {
      }
    }
  }
  struct foo {}
}

struct foo {
  @available(*, unavailable)
  struct foo {}
  public class foo {
    @available(*, unavailable)
    @objc(fooObjc)
    private static func foo() {}
  }
}

struct S<A, B, C, @objc D> where A:B, B==C, A : C, B.C == D.A, A.B: C.D {}

private struct S<A, B>: Base where A: B {
  private struct S: A, B {}
}

protocol P: class {}

func foo(_ _: Int,
         a b: Int = 3 + 2,
         _ c: Int = 2,
         d _: Int = true ? 2: 3,
         @objc e: X = true,
         f: inout Int,
         g: Int...) throws -> [Int: String] {}

func foo(_ a: Int) throws -> Int {}
func foo( a: Int) rethrows -> Int {}

struct C {
@objc
@available(*, unavailable)
private static override func foo<a, b, c>(a b: Int, c: Int) throws -> [Int] where a==p1, b:p2 { ddd }
func rootView() -> Label {}
static func ==() -> bool {}
static func !=<a, b, c>() -> bool {}
}

@objc
private protocol foo : bar where A==B {}
protocol foo { func foo() }
private protocol foo{}
@objc
public protocol foo where A:B {}

#if blah
func tryfoo() {
  try foo()
  try! foo()
  try? foo()
  try! foo().bar().foo().bar()
}
#else
func closure() {
  _ = {[weak a,
    unowned(safe) self,
    b = 3,
    unowned(unsafe) c = foo().bar] in
  }
  _ = {[] in }

  _ = { [] a, b, _ -> Int in
    return 2
  }
  _ = { [] (a: Int, b: Int, _: Int) -> Int in
    return 2
  }
  _ = { [] a, b, _ throws -> Int in
    return 2
  }
  _ = { [] (a: Int, _ b: Int) throws -> Int in
    return 2
  }
  _ = { a, b in }
  _ = {}
  _ = { s1, s2 in s1 > s2 }
  _ = { $0 > $1 }
}
#endif

func postfix() {
  foo()
  foo() {}
  foo {}
  foo.bar()
  foo.bar() {}
  foo.bar {}
  foo[]
  foo[1]
  foo[] {}
  foo[1] {}
  foo[1][2,x:3]
  foo?++.bar!(baz)

  foo(x:y:)()
  _ = .foo(x:y:)
  _ = x.foo(x:y:)
}

#if blah
#else
#endif

class C {
  var a: Int {
    @objc mutating set(value) {}
    mutating get { return 3 }
    @objc didSet {}
    willSet(newValue){ }
  }
  var a : Int {
    return 3
  }
}

protocol P {
  var a: Int { get set }
  var a: Int {}
}

class C {
  @objc
  static private var a: Int = 3 { return 3 }, b: Int, c = 4, d : Int { get {} get {}}, (a, b): (Int, Int)
  let (a, b) = (1,2), _ = 4 {}

  func patternTests() {
    for let (x, _) in foo {}
    for var x: Int in foo {}
  }
}

do {
  switch foo {
    case let a: break
    case let a as Int: break
    case let (a, b): break
    case (let a, var b): break
    case is Int: break
    case let .bar(x): break
    case MyEnum.foo: break
    case let a as Int: break
    case let a?: break
  }
}

func statementTests() {
  do {
  } catch (var x, let y) {
  } catch where false {
  } catch let e where e.foo == bar {
  } catch {
  }
  repeat { } while true
  LABEL: repeat { } while false
  LABEL: do {}
  LABEL: switch foo {
    case 1:
      fallthrough
    case 2:
      break LABEL
    case 3:
      break
  }

  for a in b {
    defer { () }
    if c {
      throw MyError()
      continue
    } else {
      continue LABEL
    }
  }

  if
    foo,
    let a = foo,
    let b: Int = foo,
    var c = foo,
    case (let v, _) = foo,
    case (let v, _): (Int, Int) = foo {
  } else if foo {
  } else {
  }

  guard let a = b else {}

  for var i in foo where i.foo {}
  for case is Int in foo {}
}

// MARK: - ExtensionDecl id:4062 gh:4074

extension ext {
  var s: Int {
    return 42
  }
}

@available(*, unavailable)
fileprivate extension ext {}

extension ext : extProtocol {}

extension ext where A == Int, B: Numeric {}

extension ext.a.b {}

func foo() {
  var a = "abc \(foo()) def \(a + b + "a \(3)") gh"
  var a = """
  abc \( foo() + bar() )
  de \(3 + 3 + "abc \(foo()) def")
  fg
  """
}
