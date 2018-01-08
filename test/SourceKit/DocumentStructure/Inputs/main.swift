class Foo : Bar {
    var test : Int
    @IBOutlet var testOutlet : Int

    func testMethod() {
        if test {
        }
    }

    @IBAction func testAction() {
    }
}

@IBDesignable
class Foo2 {}

class Foo3 {
    @IBInspectable var testIBInspectable : Int
    @GKInspectable var testGKInspectable : Int
}

protocol MyProt {}

class OuterCls {
    class InnerCls1 {}
}

extension OuterCls {
    class InnerCls2 {}
}

class GenCls<T1, T2> {}

class TestParamAndCall {
    func testParams(arg1: Int, name: String) {
        if (arg1) {
            testParams(0, name:"testing")
        }
    }

    func testParamAndArg(arg1: Int, param par: Int) {
    }
}

// FIXME: Whatever. id:3404 gh:3416

class TestMarkers {
    // TODO: Something. id:3701 gh:3713
    func test(arg1: Bool) -> Int {
        // FIXME: Blah. id:3807 gh:3817
        if (arg1) {
            // FIXME: Blah. id:4056 gh:4068
            return 0
        }
        return 1
    }
}

func test2(arg1: Bool) {
    if (arg1) {
        // http://whatever FIXME: http://whatever/fixme. id:3003 gh:3015
    }
}

extension Foo {
    func anExtendedFooFunction() {
    }
}

// rdar://19539259 
var (sd2: Qtys)
{
  417(d: nil)
}

for i in 0...5 {}
for var i = 0, i2 = 1; i == 0; ++i {}
while var v = o, var z = o, v > z {}
repeat {} while v == 0
if var v = o, var z = o, v > z {}
switch v {
  case 1: break;
  case 2, 3: break;
  default: break;
}

let myArray = [1, 2, 3]
let myDict = [1:1, 2:2, 3:3]

// rdar://21203366
@objc
class ClassObjcAttr : NSObject {
    @objc
    func m() {}
}

@objc(Blah)
class ClassObjcAttr2 : NSObject {
    @objc(Foo)
    func m() {}
}

protocol FooProtocol {
    associatedtype Bar
    associatedtype Baz: Equatable
}

// SR-5717
a.b(c: d?.e?.f, h: i)
