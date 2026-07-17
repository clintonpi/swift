//===--- StringUTF8StorageProperty.swift ----------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// RUN: %target-run-stdlib-swift

// REQUIRES: executable_test

import StdlibUnittest

var suite = TestSuite("StringUTF8StorageProperty")
defer { runAllTests() }

suite.test("Span from Small String")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  var s = "123456789".utf8
  let u = Array(s)
#if os(watchOS) && _pointerBitWidth(_32)
  expectNil(s._span)
#endif
  var string = String(s)
  string.reserveCapacity(12)
  s = (consume string).utf8
  guard let span = expectNotNil(s._span) else { return }

  let count = span.count
  expectEqual(count, s.count)

  for i in span.indices {
    expectEqual(span[i], u[i])
  }
}

suite.test("Span from Large Native String")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let s = "A long string that is altogether not smol.".utf8
  let u = Array(s)
  guard let span = expectNotNil(s._span) else { return }

  let count = span.count
  expectEqual(count, s.count)

  for i in span.indices {
    expectEqual(span[i], u[i])
  }
}

suite.test("Span from Small String's Substring")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let s = "A small string.".dropFirst(8).utf8
  let u = Array("string.".utf8)
  guard let span = expectNotNil(s._span) else { return }

  let count = span.count
  expectEqual(count, s.count)

  for i in span.indices {
    expectEqual(span[i], u[i])
  }
}

suite.test("Span from Large Native String's Substring")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let t = "A long string that is altogether not smol."
  let s = t.dropFirst(22).prefix(10).utf8
  let u = Array("altogether".utf8)
  guard let span = expectNotNil(s._span) else { return }

  let count = span.count
  expectEqual(count, s.count)

  for i in span.indices {
    expectEqual(span[i], u[i])
  }
}

suite.test("Span from String.utf8Span")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let s = String(200)
  guard let utf8span = expectNotNil(s._utf8Span) else { return }
  let span1 = utf8span.span
  let utf8view = s.utf8
  guard let span2 = expectNotNil(utf8view._span) else { return }
  expectEqual(span1.count, span2.count)
  for (i,j) in zip(span1.indices, span2.indices) {
    expectEqual(span1[i], span2[j])
  }
}

suite.test("UTF8Span from Span")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let s = String(200).utf8
  guard let span1 = expectNotNil(s._span) else { return }
  guard let utf8 = expectNotNil(try? UTF8Span(validating: span1)) else { return }

  let span2 = utf8.span
  expectTrue(span1.isIdentical(to: span2))
}

suite.test("Span from Substring.utf8Span")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let s = String(22000).dropFirst().dropLast()
  guard let utf8span = expectNotNil(s._utf8Span) else { return }
  let span1 = utf8span.span
  let utf8view = s.utf8
  guard let span2 = expectNotNil(utf8view._span) else { return }
  expectEqual(span1.count, span2.count)
  for (i,j) in zip(span1.indices, span2.indices) {
    expectEqual(span1[i], span2[j])
  }
}

suite.test("String.append(copying: UTF8Span) where UTF8Span.isEmpty is true")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  var s = "café"
  let t = ""
  expectTrue(t.utf8Span.isEmpty)
  s.append(copying: t.utf8Span)
  expectEqual(s, "café")
}

suite.test("String.append(copying: UTF8Span) where the result fits in a smol string")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  var s = "café"
  let t = "-"
  s.append(copying: t.utf8Span)
  expectEqual(s, "café-")

  s.reserveCapacity(16)
  s.append(copying: t.utf8Span)
  expectEqual(s, "café--")
}

suite.test("String.append(copying: UTF8Span) where the allocated buffer had to grow")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  var s = "A"
  let t = " long string that is altogether not smol."

  s.reserveCapacity(16)
  s.append(copying: t.utf8Span)
  expectEqual(s, "A long string that is altogether not smol.")
}

suite.test("String.append(copying: UTF8Span) into a shared (non-unique) native string")
.require(.stdlib_6_2).code {
  guard #available(SwiftStdlib 6.2, *) else { return }

  let base = "A native string well over fifteen bytes"
  var s = base
  let t = s
  s.append(copying: "!".utf8Span)
  expectEqual(s, base + "!")
  expectEqual(t, base)
}
