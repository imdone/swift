// Testing #if condition does not disturb code completion

// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_IF_MEMATTR | %FileCheck %s -check-prefix=ATTR
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_IF_MEMBER | %FileCheck %s -check-prefix=MEMBER
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_ELSE_MEMBER | %FileCheck %s -check-prefix=MEMBER
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_ELSE_MEMATTR | %FileCheck %s -check-prefix=ATTR

// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_IF_GBLATTR | %FileCheck %s -check-prefix=ATTR
// FIXME: SR-2364 the following line triggers an assertion id:2684 gh:2696
// RUN_DISABLED: not --crash %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_IF_GBLNAME
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_ELIF_GBLNAME | %FileCheck %s -check-prefix=GLOBAL
// RUN: %target-swift-ide-test -code-completion -source-filename %s -code-completion-token=POUND_ELIF_GBLATTR | %FileCheck %s -check-prefix=ATTR

// MEMBER: Begin completions
// MEMBER: override func foo() {|}; name=foo()
// MEMBER: End completions

// ATTR: Begin completions
// ATTR: available[#Func Attribute#]; name=available
// ATTR: End completions

// GLOBAL: Begin completions
// GLOBAL: Foo[#Foo#]; name=Foo
// GLOBAL: End completions

class Foo {
  func foo() {}
}

class Bar : Foo {
#if true
  @#^POUND_IF_MEMATTR^#
  func f1() {}

  #^POUND_IF_MEMBER^#
#else
  #^POUND_ELSE_MEMBER^#

  @#^POUND_ELSE_MEMATTR^#
  func f1() {}
#endif
}

#if true
@#^POUND_IF_GBLATTR^#
func bar() {}

#^POUND_IF_GBLNAME^#
#elseif false
#^POUND_ELIF_GBLNAME^#

@#^POUND_ELIF_GBLATTR^#
func bar() {}
#endif
