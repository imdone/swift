// RUN: %target-swift-frontend -emit-ir %S/Inputs/keypath.swift -primary-file %s

func f<T>(_: T) {
  _ = \C<T>.b
  _ = \C<T>[0]

  _ = \D<T>.b
  _ = \D<T>[0]

  _ = \P.b

  // FIXME: crashes id:3888 gh:3898
  // _ = \P[0]
}
