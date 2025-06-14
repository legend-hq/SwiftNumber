//
//  NumberTests.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

import XCTest
import Foundation
@testable import SwiftNumber

extension Number.Kind: Equatable {
    public static func ==(left: Number.Kind, right: Number.Kind) -> Bool {
        switch (left, right) {
        case let (.inline(l0, l1), .inline(r0, r1)): return l0 == r0 && l1 == r1
        case let (.slice(from: ls, to: le), .slice(from: rs, to: re)): return ls == rs && le == re
        case (.array, .array): return true
        default: return false
        }
    }
}

class NumberTests: XCTestCase {
    typealias Word = Number.Word

    func check(_ value: Number, _ kind: Number.Kind?, _ words: [Word], file: StaticString = #file, line: UInt = #line) {
        if let kind = kind {
            XCTAssertEqual(
                value.kind, kind,
                "Mismatching kind: \(value.kind) vs. \(kind)",
                file: file, line: line)
        }
        XCTAssertEqual(
            Array(value.words), words,
            "Mismatching words: \(value.words) vs. \(words)",
            file: file, line: line)
        XCTAssertEqual(
            value.isZero, words.isEmpty,
            "Mismatching isZero: \(value.isZero) vs. \(words.isEmpty)",
            file: file, line: line)
        XCTAssertEqual(
            value.count, words.count,
            "Mismatching count: \(value.count) vs. \(words.count)",
            file: file, line: line)
        for i in 0 ..< words.count {
            XCTAssertEqual(
                value[i], words[i],
                "Mismatching word at index \(i): \(value[i]) vs. \(words[i])",
                file: file, line: line)
        }
        for i in words.count ..< words.count + 10 {
            XCTAssertEqual(
                value[i], 0,
                "Expected 0 word at index \(i), got \(value[i])",
                file: file, line: line)
        }
    }

    func check(_ value: Number?, _ kind: Number.Kind?, _ words: [Word], file: StaticString = #file, line: UInt = #line) {
        guard let value = value else {
            XCTFail("Expected non-nil Number", file: file, line: line)
            return
        }
        check(value, kind, words, file: file, line: line)
    }

    func testInit_WordBased() {
        check(Number(), .inline(0, 0), [])

        check(Number(word: 0), .inline(0, 0), [])
        check(Number(word: 1), .inline(1, 0), [1])
        check(Number(word: Word.max), .inline(Word.max, 0), [Word.max])

        check(Number(low: 0, high: 0), .inline(0, 0), [])
        check(Number(low: 0, high: 1), .inline(0, 1), [0, 1])
        check(Number(low: 1, high: 0), .inline(1, 0), [1])
        check(Number(low: 1, high: 2), .inline(1, 2), [1, 2])

        check(Number(words: []), .array, [])
        check(Number(words: [0, 0, 0, 0]), .array, [])
        check(Number(words: [1]), .array, [1])
        check(Number(words: [1, 2, 3, 0, 0]), .array, [1, 2, 3])
        check(Number(words: [0, 1, 2, 3, 4]), .array, [0, 1, 2, 3, 4])

        check(Number(words: [], from: 0, to: 0), .inline(0, 0), [])
        check(Number(words: [1, 2, 3, 4], from: 0, to: 4), .array, [1, 2, 3, 4])
        check(Number(words: [1, 2, 3, 4], from: 0, to: 3), .slice(from: 0, to: 3), [1, 2, 3])
        check(Number(words: [1, 2, 3, 4], from: 1, to: 4), .slice(from: 1, to: 4), [2, 3, 4])
        check(Number(words: [1, 2, 3, 4], from: 0, to: 2), .inline(1, 2), [1, 2])
        check(Number(words: [1, 2, 3, 4], from: 0, to: 1), .inline(1, 0), [1])
        check(Number(words: [1, 2, 3, 4], from: 1, to: 1), .inline(0, 0), [])
        check(Number(words: [0, 0, 0, 1, 0, 0, 0, 2], from: 0, to: 4), .slice(from: 0, to: 4), [0, 0, 0, 1])
        check(Number(words: [0, 0, 0, 1, 0, 0, 0, 2], from: 0, to: 3), .inline(0, 0), [])
        check(Number(words: [0, 0, 0, 1, 0, 0, 0, 2], from: 2, to: 6), .inline(0, 1), [0, 1])

        check(Number(words: [].lazy), .inline(0, 0), [])
        check(Number(words: [1].lazy), .inline(1, 0), [1])
        check(Number(words: [1, 2].lazy), .inline(1, 2), [1, 2])
        check(Number(words: [1, 2, 3].lazy), .array, [1, 2, 3])
        check(Number(words: [1, 2, 3, 0, 0, 0, 0].lazy), .array, [1, 2, 3])

        check(Number(words: IteratorSequence([].makeIterator())), .inline(0, 0), [])
        check(Number(words: IteratorSequence([1].makeIterator())), .inline(1, 0), [1])
        check(Number(words: IteratorSequence([1, 2].makeIterator())), .inline(1, 2), [1, 2])
        check(Number(words: IteratorSequence([1, 2, 3].makeIterator())), .array, [1, 2, 3])
        check(Number(words: IteratorSequence([1, 2, 3, 0, 0, 0, 0].makeIterator())), .array, [1, 2, 3])
    }

    func testInit_BinaryInteger() {
        XCTAssertNil(Number(exactly: -42))
        check(Number(exactly: 0 as Int), .inline(0, 0), [])
        check(Number(exactly: 42 as Int), .inline(42, 0), [42])
        check(Number(exactly: 43 as UInt), .inline(43, 0), [43])
        check(Number(exactly: 44 as UInt8), .inline(44, 0), [44])
        check(Number(exactly: Number(words: [])), .inline(0, 0), [])
        check(Number(exactly: Number(words: [1])), .inline(1, 0), [1])
        check(Number(exactly: Number(words: [1, 2])), .inline(1, 2), [1, 2])
        check(Number(exactly: Number(words: [1, 2, 3, 4])), .array, [1, 2, 3, 4])
    }

    func testInit_FloatingPoint() {
        check(Number(exactly: -0.0 as Float), nil, [])
        check(Number(exactly: -0.0 as Double), nil, [])

        XCTAssertNil(Number(exactly: -42.0 as Float))
        XCTAssertNil(Number(exactly: -42.0 as Double))

        XCTAssertNil(Number(exactly: 42.5 as Float))
        XCTAssertNil(Number(exactly: 42.5 as Double))

        check(Number(exactly: 100 as Float), nil, [100])
        check(Number(exactly: 100 as Double), nil, [100])

        check(Number(exactly: Float.greatestFiniteMagnitude), nil,
              convertWords([0, 0xFFFFFF0000000000]))

        check(Number(exactly: Double.greatestFiniteMagnitude), nil,
              convertWords([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFFFFFFFFFFFFF800]))

        XCTAssertNil(Number(exactly: Float.leastNormalMagnitude))
        XCTAssertNil(Number(exactly: Double.leastNormalMagnitude))

        XCTAssertNil(Number(exactly: Float.infinity))
        XCTAssertNil(Number(exactly: Double.infinity))

        XCTAssertNil(Number(exactly: Float.nan))
        XCTAssertNil(Number(exactly: Double.nan))

        check(Number(0 as Float), nil, [])
        check(Number(Float.leastNonzeroMagnitude), nil, [])
        check(Number(Float.leastNormalMagnitude), nil, [])
        check(Number(0.5 as Float), nil, [])
        check(Number(1.5 as Float), nil, [1])
        check(Number(42 as Float), nil, [42])
        check(Number(Double(sign: .plus, exponent: 2 * Word.bitWidth, significand: 1.0)),
              nil, [0, 0, 1])
    }

    func testInit_Decimal() throws {
        XCTAssertEqual(Number(exactly: Decimal(0)), 0)
        XCTAssertEqual(Number(exactly: Decimal(Double.nan)), nil)
        XCTAssertEqual(Number(exactly: Decimal(10)), 10)
        XCTAssertEqual(Number(exactly: Decimal(1000)), 1000)
        XCTAssertEqual(Number(exactly: Decimal(1000.1)), nil)
        XCTAssertEqual(Number(exactly: Decimal(1000.9)), nil)
        XCTAssertEqual(Number(exactly: Decimal(1001.5)), nil)
        XCTAssertEqual(Number(exactly: Decimal(UInt.max) + 5), "18446744073709551620")
        XCTAssertEqual(Number(exactly: (Decimal(UInt.max) + 5.5)), nil)
        XCTAssertEqual(Number(exactly: Decimal.greatestFiniteMagnitude),
                       "3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(Number(truncating: Decimal(0)), 0)
        XCTAssertEqual(Number(truncating: Decimal(Double.nan)), nil)
        XCTAssertEqual(Number(truncating: Decimal(10)), 10)
        XCTAssertEqual(Number(truncating: Decimal(1000)), 1000)
        XCTAssertEqual(Number(truncating: Decimal(1000.1)), 1000)
        XCTAssertEqual(Number(truncating: Decimal(1000.9)), 1000)
        XCTAssertEqual(Number(truncating: Decimal(1001.5)), 1001)
        XCTAssertEqual(Number(truncating: Decimal(UInt.max) + 5), "18446744073709551620")
        XCTAssertEqual(Number(truncating: (Decimal(UInt.max) + 5.5)), "18446744073709551620")

        XCTAssertEqual(Number(exactly: -Decimal(10)), nil)
        XCTAssertEqual(Number(exactly: -Decimal(1000)), nil)
        XCTAssertEqual(Number(exactly: -Decimal(1000.1)), nil)
        XCTAssertEqual(Number(exactly: -Decimal(1000.9)), nil)
        XCTAssertEqual(Number(exactly: -Decimal(1001.5)), nil)
        XCTAssertEqual(Number(exactly: -Decimal(UInt.max) + 5), nil)
        XCTAssertEqual(Number(exactly: -(Decimal(UInt.max) + 5.5)), nil)
        XCTAssertEqual(Number(exactly: Decimal.leastFiniteMagnitude), nil)
        XCTAssertEqual(Number(truncating: -Decimal(10)), nil)
        XCTAssertEqual(Number(truncating: -Decimal(1000)), nil)
        XCTAssertEqual(Number(truncating: -Decimal(1000.1)), nil)
        XCTAssertEqual(Number(truncating: -Decimal(1000.9)), nil)
        XCTAssertEqual(Number(truncating: -Decimal(1001.5)), nil)
        XCTAssertEqual(Number(truncating: -Decimal(UInt.max) + 5), nil)
        XCTAssertEqual(Number(truncating: -(Decimal(UInt.max) + 5.5)), nil)
    }

    func testInit_Buffer() {
        func test(_ b: Number, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
            d.withUnsafeBytes { buffer in
                let initialized = Number(buffer)
                XCTAssertEqual(initialized, b, file: file, line: line)
            }
        }
        
        // Positive integers
        test(Number(), [])
        test(Number(1), [0x01])
        test(Number(2), [0x02])
        test(Number(0x0102030405060708), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(Number(0x01) << 64 + Number(0x0203040506070809), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])
    }

    func testConversionToFloatingPoint() {
        func test<F: BinaryFloatingPoint>(_ a: Number, _ b: F, file: StaticString = #file, line: UInt = #line)
        where F.RawExponent: FixedWidthInteger, F.RawSignificand: FixedWidthInteger {
            let f = F(a)
            XCTAssertEqual(f, b, file: file, line: line)
        }

        for i in 0 ..< 100 {
            test(Number(i), Double(i))
        }
        test(Number(0x5A5A5A), 0x5A5A5A as Double)
        test(Number(1) << 64, 0x1p64 as Double)
        test(Number(0x5A5A5A) << 64, 0x5A5A5Ap64 as Double)
        test(Number(1) << 1023, 0x1p1023 as Double)
        test(Number(10) << 1020, 0xAp1020 as Double)
        test(Number(1) << 1024, Double.infinity)
        test(Number(words: convertWords([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFFFFFFFFFFFFF800])),
             Double.greatestFiniteMagnitude)
        test(Number(UInt64.max), 0x1p64 as Double)

        for i in 0 ..< 100 {
            test(Number(i), Float(i))
        }
        test(Number(0x5A5A5A), 0x5A5A5A as Float)
        test(Number(1) << 64, 0x1p64 as Float)
        test(Number(0x5A5A5A) << 64, 0x5A5A5Ap64 as Float)
        test(Number(1) << 1023, 0x1p1023 as Float)
        test(Number(10) << 1020, 0xAp1020 as Float)
        test(Number(1) << 1024, Float.infinity)
        test(Number(words: convertWords([0, 0xFFFFFF0000000000])),
             Float.greatestFiniteMagnitude)

        // Test rounding
        test(Number(0xFFFFFF0000000000 as UInt64), 0xFFFFFFp40 as Float)
        test(Number(0xFFFFFF7FFFFFFFFF as UInt64), 0xFFFFFFp40 as Float)
        test(Number(0xFFFFFF8000000000 as UInt64), 0x1p64 as Float)
        test(Number(0xFFFFFFFFFFFFFFFF as UInt64), 0x1p64 as Float)

        test(Number(0xFFFFFE0000000000 as UInt64), 0xFFFFFEp40 as Float)
        test(Number(0xFFFFFE7FFFFFFFFF as UInt64), 0xFFFFFEp40 as Float)
        test(Number(0xFFFFFE8000000000 as UInt64), 0xFFFFFEp40 as Float)
        test(Number(0xFFFFFEFFFFFFFFFF as UInt64), 0xFFFFFEp40 as Float)

        test(Number(0x8000010000000000 as UInt64), 0x800001p40 as Float)
        test(Number(0x8000017FFFFFFFFF as UInt64), 0x800001p40 as Float)
        test(Number(0x8000018000000000 as UInt64), 0x800002p40 as Float)
        test(Number(0x800001FFFFFFFFFF as UInt64), 0x800002p40 as Float)

        test(Number(0x8000020000000000 as UInt64), 0x800002p40 as Float)
        test(Number(0x8000027FFFFFFFFF as UInt64), 0x800002p40 as Float)
        test(Number(0x8000028000000000 as UInt64), 0x800002p40 as Float)
        test(Number(0x800002FFFFFFFFFF as UInt64), 0x800002p40 as Float)

        XCTAssertEqual(Decimal(Number(0)), 0)
        XCTAssertEqual(Decimal(Number(20)), 20)
        XCTAssertEqual(Decimal(Number(123456789)), 123456789)
        XCTAssertEqual(Decimal(Number(exactly: Decimal.greatestFiniteMagnitude)!), .greatestFiniteMagnitude)
        XCTAssertEqual(Decimal(Number(exactly: Decimal.greatestFiniteMagnitude)! * 2), .greatestFiniteMagnitude)
    }

    func testInit_Misc() {
        check(Number(0), .inline(0, 0), [])
        check(Number(42), .inline(42, 0), [42])
        check(Number(Number(words: [1, 2, 3])), .array, [1, 2, 3])

        check(Number(truncatingIfNeeded: 0 as Int8), .inline(0, 0), [])
        check(Number(truncatingIfNeeded: 1 as Int8), .inline(1, 0), [1])
        check(Number(truncatingIfNeeded: -1 as Int8), .inline(Word.max, 0), [Word.max])
        check(Number(truncatingIfNeeded: Number(words: [1, 2, 3])), .array, [1, 2, 3])

        check(Number(clamping: 0), .inline(0, 0), [])
        check(Number(clamping: -100), .inline(0, 0), [])
        check(Number(clamping: Word.max), .inline(Word.max, 0), [Word.max])
    }

    func testEnsureArray() {
        var a = Number()
        a.ensureArray()
        check(a, .array, [])

        a = Number(word: 1)
        a.ensureArray()
        check(a, .array, [1])

        a = Number(low: 1, high: 2)
        a.ensureArray()
        check(a, .array, [1, 2])

        a = Number(words: [1, 2, 3, 4])
        a.ensureArray()
        check(a, .array, [1, 2, 3, 4])

        a = Number(words: [1, 2, 3, 4, 5, 6], from: 1, to: 5)
        a.ensureArray()
        check(a, .array, [2, 3, 4, 5])
    }

    func testCapacity() {
        XCTAssertEqual(Number(low: 1, high: 2).capacity, 0)
        XCTAssertEqual(Number(words: 1 ..< 10).extract(2 ..< 5).capacity, 0)
        var words: [Word] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        words.reserveCapacity(100)
        XCTAssertGreaterThanOrEqual(Number(words: words).capacity, 100)
    }

    func testReserveCapacity() {
        var a = Number()
        a.reserveCapacity(100)
        check(a, .array, [])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a = Number(word: 1)
        a.reserveCapacity(100)
        check(a, .array, [1])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a = Number(low: 1, high: 2)
        a.reserveCapacity(100)
        check(a, .array, [1, 2])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a = Number(words: [1, 2, 3, 4])
        a.reserveCapacity(100)
        check(a, .array, [1, 2, 3, 4])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a = Number(words: [1, 2, 3, 4, 5, 6], from: 1, to: 5)
        a.reserveCapacity(100)
        check(a, .array, [2, 3, 4, 5])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)
    }

    func testLoad() {
        var a: Number = 0
        a.reserveCapacity(100)

        a.load(Number(low: 1, high: 2))
        check(a, .array, [1, 2])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a.load(Number(words: [1, 2, 3, 4, 5, 6]))
        check(a, .array, [1, 2, 3, 4, 5, 6])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)

        a.clear()
        check(a, .array, [])
        XCTAssertGreaterThanOrEqual(a.capacity, 100)
    }

    func testInitFromLiterals() {
        check(0, .inline(0, 0), [])
        check(42, .inline(42, 0), [42])
        check("42", .inline(42, 0), [42])

        check("1512366075204170947332355369683137040",
              .inline(0xFEDCBA9876543210, 0x0123456789ABCDEF),
              [0xFEDCBA9876543210, 0x0123456789ABCDEF])

        // I have no idea how to exercise these in the wild
        check(Number(unicodeScalarLiteral: UnicodeScalar(52)), .inline(4, 0), [4])
        check(Number(extendedGraphemeClusterLiteral: "4"), .inline(4, 0), [4])
    }

    func testSubscriptingGetter() {
        let a = Number(words: [1, 2])
        XCTAssertEqual(a[0], 1)
        XCTAssertEqual(a[1], 2)
        XCTAssertEqual(a[2], 0)
        XCTAssertEqual(a[3], 0)
        XCTAssertEqual(a[10000], 0)

        let b = Number(low: 1, high: 2)
        XCTAssertEqual(b[0], 1)
        XCTAssertEqual(b[1], 2)
        XCTAssertEqual(b[2], 0)
        XCTAssertEqual(b[3], 0)
        XCTAssertEqual(b[10000], 0)
    }

    func testSubscriptingSetter() {
        var a = Number()

        check(a, .inline(0, 0), [])
        a[10] = 0
        check(a, .inline(0, 0), [])
        a[0] = 42
        check(a, .inline(42, 0), [42])
        a[10] = 23
        check(a, .array, [42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23])
        a[0] = 0
        check(a, .array, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23])
        a[10] = 0
        check(a, .array, [])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 5)
        a[2] = 42
        check(a, .array, [1, 2, 42, 4])
    }

    func testSlice() {
        let a = Number(words: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        check(a.extract(3 ..< 6), .slice(from: 3, to: 6), [3, 4, 5])
        check(a.extract(3 ..< 5), .inline(3, 4), [3, 4])
        check(a.extract(3 ..< 4), .inline(3, 0), [3])
        check(a.extract(3 ..< 3), .inline(0, 0), [])
        check(a.extract(0 ..< 100), .array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        check(a.extract(100 ..< 200), .inline(0, 0), [])

        let b = Number(low: 1, high: 2)
        check(b.extract(0 ..< 2), .inline(1, 2), [1, 2])
        check(b.extract(0 ..< 1), .inline(1, 0), [1])
        check(b.extract(1 ..< 2), .inline(2, 0), [2])
        check(b.extract(1 ..< 1), .inline(0, 0), [])
        check(b.extract(0 ..< 100), .inline(1, 2), [1, 2])
        check(b.extract(100 ..< 200), .inline(0, 0), [])

        let c = Number(words: [1, 0, 0, 0, 2, 0, 0, 0, 3, 4, 5, 0, 0, 6, 0, 0, 0, 7])
        check(c.extract(0 ..< 4), .inline(1, 0), [1])
        check(c.extract(1 ..< 5), .slice(from: 1, to: 5), [0, 0, 0, 2])
        check(c.extract(1 ..< 8), .slice(from: 1, to: 5), [0, 0, 0, 2])
        check(c.extract(6 ..< 12), .slice(from: 6, to: 11), [0, 0, 3, 4, 5])
        check(c.extract(4 ..< 7), .inline(2, 0), [2])

        let d = c.extract(3 ..< 14)
                                        // 0  1  2  3  4  5  6  7  8  9 10
        check(d, .slice(from: 3, to: 14), [0, 2, 0, 0, 0, 3, 4, 5, 0, 0, 6])
        check(d.extract(1 ..< 5), .inline(2, 0), [2])
        check(d.extract(0 ..< 3), .inline(0, 2), [0, 2])
        check(d.extract(1 ..< 6), .slice(from: 4, to: 9), [2, 0, 0, 0, 3])
        check(d.extract(7 ..< 1000), .slice(from: 10, to: 14), [5, 0, 0, 6])
        check(d.extract(10 ..< 1000), .inline(6, 0), [6])
        check(d.extract(11 ..< 1000), .inline(0, 0), [])
    }

    func testSigns() {
        XCTAssertFalse(Number.isSigned)

        XCTAssertEqual(Number().signum(), 0)
        XCTAssertEqual(Number(words: []).signum(), 0)
        XCTAssertEqual(Number(words: [0, 1, 2]).signum(), 1)
        XCTAssertEqual(Number(word: 42).signum(), 1)
    }

    func testBits() {
        let indices: Set<Int> = [0, 13, 59, 64, 79, 130]
        var value: Number = 0
        for i in indices {
            value[bitAt: i] = true
        }
        for i in 0 ..< 300 {
            XCTAssertEqual(value[bitAt: i], indices.contains(i))
        }
        check(value, nil, convertWords([0x0800000000002001, 0x8001, 0x04]))
        for i in indices {
            value[bitAt: i] = false
        }
        check(value, nil, [])
    }

    func testStrideableRequirements() {
        XCTAssertEqual(Number(10), Number(4).advanced(by: SNumber(6)))
        XCTAssertEqual(Number(4), Number(10).advanced(by: SNumber(-6)))
        XCTAssertEqual(SNumber(6), Number(4).distance(to: 10))
        XCTAssertEqual(SNumber(-6), Number(10).distance(to: 4))
    }

    func testRightShift_ByWord() {
        var a = Number()
        a.shiftRight(byWords: 1)
        check(a, .inline(0, 0), [])

        a = Number(low: 1, high: 2)
        a.shiftRight(byWords: 0)
        check(a, .inline(1, 2), [1, 2])

        a = Number(low: 1, high: 2)
        a.shiftRight(byWords: 1)
        check(a, .inline(2, 0), [2])

        a = Number(low: 1, high: 2)
        a.shiftRight(byWords: 2)
        check(a, .inline(0, 0), [])

        a = Number(low: 1, high: 2)
        a.shiftRight(byWords: 10)
        check(a, .inline(0, 0), [])


        a = Number(words: [0, 1, 2, 3, 4])
        a.shiftRight(byWords: 1)
        check(a, .array, [1, 2, 3, 4])

        a = Number(words: [0, 1, 2, 3, 4])
        a.shiftRight(byWords: 2)
        check(a, .array, [2, 3, 4])

        a = Number(words: [0, 1, 2, 3, 4])
        a.shiftRight(byWords: 5)
        check(a, .array, [])

        a = Number(words: [0, 1, 2, 3, 4])
        a.shiftRight(byWords: 100)
        check(a, .array, [])


        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        check(a, .slice(from: 1, to: 6), [1, 2, 3, 4, 5])
        a.shiftRight(byWords: 1)
        check(a, .slice(from: 2, to: 6), [2, 3, 4, 5])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        a.shiftRight(byWords: 2)
        check(a, .slice(from: 3, to: 6), [3, 4, 5])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        a.shiftRight(byWords: 3)
        check(a, .inline(4, 5), [4, 5])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        a.shiftRight(byWords: 4)
        check(a, .inline(5, 0), [5])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        a.shiftRight(byWords: 5)
        check(a, .inline(0, 0), [])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 1, to: 6)
        a.shiftRight(byWords: 10)
        check(a, .inline(0, 0), [])
    }

    func testLeftShift_ByWord() {
        var a = Number()
        a.shiftLeft(byWords: 1)
        check(a, .inline(0, 0), [])

        a = Number(word: 1)
        a.shiftLeft(byWords: 0)
        check(a, .inline(1, 0), [1])

        a = Number(word: 1)
        a.shiftLeft(byWords: 1)
        check(a, .inline(0, 1), [0, 1])

        a = Number(word: 1)
        a.shiftLeft(byWords: 2)
        check(a, .array, [0, 0, 1])

        a = Number(low: 1, high: 2)
        a.shiftLeft(byWords: 1)
        check(a, .array, [0, 1, 2])

        a = Number(low: 1, high: 2)
        a.shiftLeft(byWords: 2)
        check(a, .array, [0, 0, 1, 2])

        a = Number(words: [1, 2, 3, 4, 5, 6])
        a.shiftLeft(byWords: 1)
        check(a, .array, [0, 1, 2, 3, 4, 5, 6])

        a = Number(words: [1, 2, 3, 4, 5, 6])
        a.shiftLeft(byWords: 10)
        check(a, .array, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 2, to: 6)
        a.shiftLeft(byWords: 1)
        check(a, .array, [0, 2, 3, 4, 5])

        a = Number(words: [0, 1, 2, 3, 4, 5, 6], from: 2, to: 6)
        a.shiftLeft(byWords: 3)
        check(a, .array, [0, 0, 0, 2, 3, 4, 5])
    }

    func testSplit() {
        let a = Number(words: [0, 1, 2, 3])
        XCTAssertEqual(a.split.low, Number(words: [0, 1]))
        XCTAssertEqual(a.split.high, Number(words: [2, 3]))
    }

    func testLowHigh() {
        let a = Number(words: [0, 1, 2, 3])
        check(a.low, .inline(0, 1), [0, 1])
        check(a.high, .inline(2, 3), [2, 3])
        check(a.low.low, .inline(0, 0), [])
        check(a.low.high, .inline(1, 0), [1])
        check(a.high.low, .inline(2, 0), [2])
        check(a.high.high, .inline(3, 0), [3])

        let b = Number(words: [0, 1, 2, 3, 4, 5])

        let bl = b.low
        check(bl, .slice(from: 0, to: 3), [0, 1, 2])
        let bh = b.high
        check(bh, .slice(from: 3, to: 6), [3, 4, 5])

        let bll = bl.low
        check(bll, .inline(0, 1), [0, 1])
        let blh = bl.high
        check(blh, .inline(2, 0), [2])
        let bhl = bh.low
        check(bhl, .inline(3, 4), [3, 4])
        let bhh = bh.high
        check(bhh, .inline(5, 0), [5])

        let blhl = bll.low
        check(blhl, .inline(0, 0), [])
        let blhh = bll.high
        check(blhh, .inline(1, 0), [1])
        let bhhl = bhl.low
        check(bhhl, .inline(3, 0), [3])
        let bhhh = bhl.high
        check(bhhh, .inline(4, 0), [4])
    }

    func testComparison() {
        XCTAssertEqual(Number(words: [1, 2, 3]), Number(words: [1, 2, 3]))
        XCTAssertNotEqual(Number(words: [1, 2]), Number(words: [1, 2, 3]))
        XCTAssertNotEqual(Number(words: [1, 2, 3]), Number(words: [1, 3, 3]))
        XCTAssertEqual(Number(words: [1, 2, 3, 4, 5, 6]).low.high, Number(words: [3]))

        XCTAssertTrue(Number(words: [1, 2]) < Number(words: [1, 2, 3]))
        XCTAssertTrue(Number(words: [1, 2, 2]) < Number(words: [1, 2, 3]))
        XCTAssertFalse(Number(words: [1, 2, 3]) < Number(words: [1, 2, 3]))
        XCTAssertTrue(Number(words: [3, 3]) < Number(words: [1, 2, 3, 4, 5, 6]).extract(2 ..< 4))
        XCTAssertTrue(Number(words: [1, 2, 3, 4, 5, 6]).low.high < Number(words: [3, 5]))
    }

    func testHashing() {
        var hashes: [Int] = []
        hashes.append(Number(words: []).hashValue)
        hashes.append(Number(words: [1]).hashValue)
        hashes.append(Number(words: [2]).hashValue)
        hashes.append(Number(words: [0, 1]).hashValue)
        hashes.append(Number(words: [1, 1]).hashValue)
        hashes.append(Number(words: [1, 2]).hashValue)
        hashes.append(Number(words: [2, 1]).hashValue)
        hashes.append(Number(words: [2, 2]).hashValue)
        hashes.append(Number(words: [1, 2, 3, 4, 5]).hashValue)
        hashes.append(Number(words: [5, 4, 3, 2, 1]).hashValue)
        hashes.append(Number(words: [Word.max]).hashValue)
        hashes.append(Number(words: [Word.max, Word.max]).hashValue)
        hashes.append(Number(words: [Word.max, Word.max, Word.max]).hashValue)
        hashes.append(Number(words: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).hashValue)
        XCTAssertEqual(hashes.count, Set(hashes).count)
    }

    func checkData(_ bytes: [UInt8], _ value: Number, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(Number(Data(bytes)), value, file: file, line: line)
        XCTAssertEqual(bytes.withUnsafeBytes { buffer in Number(buffer) }, value, file: file, line: line)
    }

    func testConversionFromBytes() {
        checkData([], 0)
        checkData([0], 0)
        checkData([0, 0, 0, 0, 0, 0, 0, 0], 0)
        checkData([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0)
        checkData([1], 1)
        checkData([2], 2)
        checkData([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], 1)
        checkData([0x01, 0x02, 0x03, 0x04, 0x05], 0x0102030405)
        checkData([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08], 0x0102030405060708)
        checkData([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A],
                  Number(0x0102) << 64 + Number(0x030405060708090A))
        checkData([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
                  Number(1) << 80)
        checkData([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10],
                  Number(0x0102030405060708) << 64 + Number(0x090A0B0C0D0E0F10))
        checkData([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11],
                  ((Number(1) << 128) as Number) + Number(0x0203040506070809) << 64 + Number(0x0A0B0C0D0E0F1011))
    }

    func testConversionToData() {
        func test(_ b: Number, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
            let expected = Data(d)
            let actual = b.serialize()
            XCTAssertEqual(actual, expected, file: file, line: line)
            XCTAssertEqual(Number(actual), b, file: file, line: line)
        }

        test(Number(), [])
        test(Number(1), [0x01])
        test(Number(2), [0x02])
        test(Number(0x010203), [0x1, 0x2, 0x3])
        test(Number(0x0102030405060708), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(Number(0x01) << 64 + Number(0x0203040506070809), [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09])
    }

    func testCodable() {
        func test(_ a: Number, file: StaticString = #file, line: UInt = #line) {
            do {
                let json: Data = try JSONEncoder().encode(a)
                XCTAssertEqual(String(data: json, encoding: .utf8)!, "\"\(a.description)\"", file: file, line: line)
                let b = try JSONDecoder().decode(Number.self, from: json)
                XCTAssertEqual(a, b, file: file, line: line)

            }
            catch let error {
                XCTFail("Error thrown: \(error.localizedDescription)", file: file, line: line)
            }
        }
        test(0)
        test(1)
        test(0x0102030405060708)
        test(Number(1) << 64)
        test(Number(words: [1, 2, 3, 4, 5, 6, 7]))

        XCTAssertThrowsError(try JSONDecoder().decode(Number.self, from: "\"zz\"".data(using: .utf8)!)) { error in
            guard let error = error as? DecodingError else { XCTFail("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { XCTFail("Expected a dataCorrupted error"); return }
            XCTAssertEqual(context.debugDescription, "Invalid number")
        }
        XCTAssertThrowsError(try JSONDecoder().decode(Number.self, from: "\"-1\"".data(using: .utf8)!)) { error in
            guard let error = error as? DecodingError else { XCTFail("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { XCTFail("Expected a dataCorrupted error"); return }
            XCTAssertEqual(context.debugDescription, "Number cannot hold a negative value")
        }
    }

    func testDecodableFromInt() {
        func test(_ a: Int, file: StaticString = #file, line: UInt = #line) {
            do {
                let b = try JSONDecoder().decode(Number.self, from: "\(a)".data(using: .utf8)!)
                XCTAssertEqual(Number(a), b, file: file, line: line)

            }
            catch let error {
                XCTFail("Error thrown: \(error.localizedDescription)", file: file, line: line)
            }
        }
        test(0)
        test(1)
        test(0x0102030405060708)

        XCTAssertThrowsError(try JSONDecoder().decode(Number.self, from: "-1".data(using: .utf8)!)) { error in
            guard let error = error as? DecodingError else { XCTFail("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { XCTFail("Expected a dataCorrupted error"); return }
            XCTAssertEqual(context.debugDescription, "Number cannot hold a negative value")
        }
    }

    func testDescription() {
        XCTAssertEqual(Number(0).description, "0")
        XCTAssertEqual(Number(1).description, "1")
        XCTAssertEqual(Number(0x0102030405060708).description, "72623859790382856")
        XCTAssertEqual(Number(1) << 64, "18446744073709551616")
        XCTAssertEqual(Number(words: [1, 2, 3, 4, 5, 6, 7]).description, "275814043374761354498769202916530757130507265576462020340397244295844955282485437854954978440130377144912032963756033")
    }

    func testDebugDescription() {
        XCTAssertEqual(Number(0).debugDescription, "Number(\"0\")")
        XCTAssertEqual(Number(1).debugDescription, "Number(\"1\")")
        XCTAssertEqual(Number(0x0102030405060708).debugDescription, "Number(\"72623859790382856\")")
        XCTAssertEqual((Number(1) << 64).debugDescription, "Number(\"18446744073709551616\")")
        XCTAssertEqual(Number(words: [1, 2, 3, 4, 5, 6, 7]).debugDescription, "Number(\"275814043374761354498769202916530757130507265576462020340397244295844955282485437854954978440130377144912032963756033\")")
    }

    func testFromLiterals() {
        XCTAssertEqual(Number(0), 0)
        XCTAssertEqual(Number(1), 1)
        XCTAssertEqual(Number(100), "100")
    }

    func testAddition() {
        XCTAssertEqual(Number(0) + Number(0), Number(0))
        XCTAssertEqual(Number(0) + Number(Word.max), Number(Word.max))
        XCTAssertEqual(Number(Word.max) + Number(1), Number(words: [0, 1]))

        check(Number(3) + Number(42), .inline(45, 0), [45])
        check(Number(3) + Number(42), .inline(45, 0), [45])

        check(0 + Number(Word.max), .inline(Word.max, 0), [Word.max])
        check(1 + Number(Word.max), .inline(0, 1), [0, 1])
        check(Number(low: 0, high: 1) + Number(low: 3, high: 4), .inline(3, 5), [3, 5])
        check(Number(low: 3, high: 5) + Number(low: 0, high: Word.max), .array, [3, 4, 1])
        check(Number(words: [3, 4, 1]) + Number(low: 0, high: Word.max), .array, [3, 3, 2])
        check(Number(words: [3, 3, 2]) + 2, .array, [5, 3, 2])
        check(Number(words: [Word.max - 5, Word.max, 4, Word.max]).addingWord(6), .array, [0, 0, 5, Word.max])

        var b = Number(words: [Word.max, 2, Word.max])
        b.increment()
        check(b, .array, [0, 3, Word.max])
    }

    func testShiftedAddition() {
        var b = Number()
        b.add(1, shiftedBy: 1)
        check(b, .inline(0, 1), [0, 1])

        b.add(2, shiftedBy: 3)
        check(b, .array, [0, 1, 0, 2])

        b.add(Number(Word.max), shiftedBy: 1)
        check(b, .array, [0, 0, 1, 2])
    }

    func testSubtraction() {
        var a1 = Number(words: [1, 2, 3, 4])
        XCTAssertEqual(false, a1.subtractWordReportingOverflow(3, shiftedBy: 1))
        check(a1, .array, [1, Word.max, 2, 4])

        let (diff, overflow) = Number(words: [1, 2, 3, 4]).subtractingWordReportingOverflow(2)
        XCTAssertEqual(false, overflow)
        check(diff, .array, [Word.max, 1, 3, 4])

        var a2 = Number(words: [1, 2, 3, 4])
        XCTAssertEqual(true, a2.subtractWordReportingOverflow(5, shiftedBy: 3))
        check(a2, .array, [1, 2, 3, Word.max])

        var a3 = Number(words: [1, 2, 3, 4])
        a3.subtractWord(4, shiftedBy: 3)
        check(a3, .array, [1, 2, 3])

        var a4 = Number(words: [1, 2, 3, 4])
        a4.decrement()
        check(a4, .array, [0, 2, 3, 4])
        a4.decrement()
        check(a4, .array, [Word.max, 1, 3, 4])

        check(Number(words: [1, 2, 3, 4]).subtractingWord(5),
              .array, [Word.max - 3, 1, 3, 4])

        check(Number(0) - Number(0), .inline(0, 0), [])

        var b = Number(words: [1, 2, 3, 4])
        XCTAssertEqual(false, b.subtractReportingOverflow(Number(words: [0, 1, 1, 1])))
        check(b, .array, [1, 1, 2, 3])

        let b1 = Number(words: [1, 1, 2, 3]).subtractingReportingOverflow(Number(words: [1, 1, 3, 3]))
        XCTAssertEqual(true, b1.overflow)
        check(b1.partialValue, .array, [0, 0, Word.max, Word.max])

        let b2 = Number(words: [0, 0, 1]) - Number(words: [1])
        check(b2, .array, [Word.max, Word.max])

        var b3 = Number(words: [1, 0, 0, 1])
        b3 -= 2
        check(b3, .array, [Word.max, Word.max, Word.max])

        check(Number(42) - Number(23), .inline(19, 0), [19])
    }

    func testMultiplyByWord() {
        check(Number(words: [1, 2, 3, 4]).multiplied(byWord: 0), .inline(0, 0), [])
        check(Number(words: [1, 2, 3, 4]).multiplied(byWord: 2), .array, [2, 4, 6, 8])

        let full = Word.max

        check(Number(words: [full, 0, full, 0, full]).multiplied(byWord: 2),
              .array, [full - 1, 1, full - 1, 1, full - 1, 1])

        check(Number(words: [full, full, full]).multiplied(byWord: 2),
              .array, [full - 1, full, full, 1])

        check(Number(words: [full, full, full]).multiplied(byWord: full),
              .array, [1, full, full, full - 1])

        check(Number("11111111111111111111111111111111", radix: 16)!.multiplied(byWord: 15),
              .array, convertWords([UInt64.max, UInt64.max]))

        check(Number("11111111111111111111111111111112", radix: 16)!.multiplied(byWord: 15),
              .array, convertWords([0xE, 0, 0x1]))

        check(Number(low: 1, high: 2).multiplied(byWord: 3), .inline(3, 6), [3, 6])
    }

    func testMultiplication() {
        func test() {
            check(Number(low: 1, high: 1) * Number(word: 3), .inline(3, 3), [3, 3])
            check(Number(word: 4) * Number(low: 1, high: 2), .inline(4, 8), [4, 8])

            XCTAssertEqual(
                Number(words: [1, 2, 3, 4]) * Number(),
                Number())
            XCTAssertEqual(
                Number() * Number(words: [1, 2, 3, 4]),
                Number())
            XCTAssertEqual(
                Number(words: [1, 2, 3, 4]) * Number(words: [2]),
                Number(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                Number(words: [1, 2, 3, 4]).multiplied(by: Number(words: [2])),
                Number(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                Number(words: [2]) * Number(words: [1, 2, 3, 4]),
                Number(words: [2, 4, 6, 8]))
            XCTAssertEqual(
                Number(words: [1, 2, 3, 4]) * Number(words: [0, 1]),
                Number(words: [0, 1, 2, 3, 4]))
            XCTAssertEqual(
                Number(words: [0, 1]) * Number(words: [1, 2, 3, 4]),
                Number(words: [0, 1, 2, 3, 4]))
            XCTAssertEqual(
                Number(words: [4, 3, 2, 1]) * Number(words: [1, 2, 3, 4]),
                Number(words: [4, 11, 20, 30, 20, 11, 4]))
            // 999 * 99 = 98901
            XCTAssertEqual(
                Number(words: [Word.max, Word.max, Word.max]) * Number(words: [Word.max, Word.max]),
                Number(words: [1, 0, Word.max, Word.max - 1, Word.max]))
            XCTAssertEqual(
                Number(words: [1, 2]) * Number(words: [2, 1]),
                Number(words: [2, 5, 2]))

            var b = Number("2637AB28", radix: 16)!
            b *= Number("164B", radix: 16)!
            XCTAssertEqual(b, Number("353FB0494B8", radix: 16))

            XCTAssertEqual(Number("16B60", radix: 16)! * Number("33E28", radix: 16)!, Number("49A5A0700", radix: 16)!)
        }

        test()
        // Disable brute force multiplication.
//        let limit = Number.directMultiplicationLimit
//        Number.directMultiplicationLimit = 0
//        defer { Number.directMultiplicationLimit = limit }
//
//        test()
    }

    func testDivision() {
        func test(_ a: [Word], _ b: [Word], file: StaticString = #file, line: UInt = #line) {
            let x = Number(words: a)
            let y = Number(words: b)
            let (div, mod) = x.quotientAndRemainder(dividingBy: y)
            if mod >= y {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }
            if div * y + mod != x {
                XCTFail("x:\(x) = div:\(div) * y:\(y) + mod:\(mod)", file: file, line: line)
            }

            let shift = y.leadingZeroBitCount
            let norm = y << shift
            var rem = x
            rem.formRemainder(dividingBy: norm, normalizedBy: shift)
            XCTAssertEqual(rem, mod, file: file, line: line)
        }

        // These cases exercise all code paths in the division when Word is UInt8 or UInt64.
        test([], [1])
        test([1], [1])
        test([1], [2])
        test([2], [1])
        test([], [0, 1])
        test([1], [0, 1])
        test([0, 1], [0, 1])
        test([0, 0, 1], [0, 1])
        test([0, 0, 1], [1, 1])
        test([0, 0, 1], [3, 1])
        test([0, 0, 1], [75, 1])
        test([0, 0, 0, 1], [0, 1])
        test([2, 4, 6, 8], [1, 2])
        test([2, 3, 4, 5], [4, 5])
        test([Word.max, Word.max - 1, Word.max], [Word.max, Word.max])
        test([0, Word.max, Word.max - 1], [Word.max, Word.max])
        test([0, 0, 0, 0, 0, Word.max / 2 + 1, Word.max / 2], [1, 0, 0, Word.max / 2 + 1])
        test([0, Word.max - 1, Word.max / 2 + 1], [Word.max, Word.max / 2 + 1])
        test([0, 0, 0x41 << Word(Word.bitWidth - 8)], [Word.max, 1 << Word(Word.bitWidth - 1)])

        XCTAssertEqual(Number(328) / Number(21), Number(15))
        XCTAssertEqual(Number(328) % Number(21), Number(13))

        var a = Number(328)
        a /= 21
        XCTAssertEqual(a, 15)
        a %= 7
        XCTAssertEqual(a, 1)

        #if false
            for x0 in (0 ... Int(Word.max)) {
                for x1 in (0 ... Int(Word.max)).reverse() {
                    for y0 in (0 ... Int(Word.max)).reverse() {
                        for y1 in (1 ... Int(Word.max)).reverse() {
                            for x2 in (1 ... y1).reverse() {
                                test(
                                    [Word(x0), Word(x1), Word(x2)],
                                    [Word(y0), Word(y1)])
                            }
                        }
                    }
                }
            }
        #endif
    }

    func testFactorial() {
        let power = 10
        var forward = Number(1)
        for i in 1 ..< (1 << power) {
            forward *= Number(i)
        }
        print("\(1 << power - 1)! = \(forward) [\(forward.count)]")
        var backward = Number(1)
        for i in (1 ..< (1 << power)).reversed() {
            backward *= Number(i)
        }

        func balancedFactorial(level: Int, offset: Int) -> Number {
            if level == 0 {
                return Number(offset == 0 ? 1 : offset)
            }
            let a = balancedFactorial(level: level - 1, offset: 2 * offset)
            let b = balancedFactorial(level: level - 1, offset: 2 * offset + 1)
            return a * b
        }
        let balanced = balancedFactorial(level: power, offset: 0)

        XCTAssertEqual(backward, forward)
        XCTAssertEqual(balanced, forward)

        var remaining = balanced
        for i in 1 ..< (1 << power) {
            let (div, mod) = remaining.quotientAndRemainder(dividingBy: Number(i))
            XCTAssertEqual(mod, 0)
            remaining = div
        }
        XCTAssertEqual(remaining, 1)
    }

    func testExponentiation() {
        XCTAssertEqual(Number(0).power(0), Number(1))
        XCTAssertEqual(Number(0).power(1), Number(0))

        XCTAssertEqual(Number(1).power(0), Number(1))
        XCTAssertEqual(Number(1).power(1), Number(1))
        XCTAssertEqual(Number(1).power(-1), Number(1))
        XCTAssertEqual(Number(1).power(-2), Number(1))
        XCTAssertEqual(Number(1).power(-3), Number(1))
        XCTAssertEqual(Number(1).power(-4), Number(1))

        XCTAssertEqual(Number(2).power(0), Number(1))
        XCTAssertEqual(Number(2).power(1), Number(2))
        XCTAssertEqual(Number(2).power(2), Number(4))
        XCTAssertEqual(Number(2).power(3), Number(8))
        XCTAssertEqual(Number(2).power(-1), Number(0))
        XCTAssertEqual(Number(2).power(-2), Number(0))
        XCTAssertEqual(Number(2).power(-3), Number(0))

        XCTAssertEqual(Number(3).power(0), Number(1))
        XCTAssertEqual(Number(3).power(1), Number(3))
        XCTAssertEqual(Number(3).power(2), Number(9))
        XCTAssertEqual(Number(3).power(3), Number(27))
        XCTAssertEqual(Number(3).power(-1), Number(0))
        XCTAssertEqual(Number(3).power(-2), Number(0))

        XCTAssertEqual((Number(1) << 256).power(0), Number(1))
        XCTAssertEqual((Number(1) << 256).power(1), Number(1) << 256)
        XCTAssertEqual((Number(1) << 256).power(2), Number(1) << 512)

        XCTAssertEqual(Number(0).power(577), Number(0))
        XCTAssertEqual(Number(1).power(577), Number(1))
        XCTAssertEqual(Number(2).power(577), Number(1) << 577)
    }

    func testModularExponentiation() {
        XCTAssertEqual(Number(2).power(11, modulus: 1), 0)
        XCTAssertEqual(Number(2).power(11, modulus: 1000), 48)

        func test(a: Number, p: Number, file: StaticString = #file, line: UInt = #line) {
            // For all primes p and integers a, a % p == a^p % p. (Fermat's Little Theorem)
            let x = a % p
            let y = x.power(p, modulus: p)
            XCTAssertEqual(x, y, file: file, line: line)
        }

        // Here are some primes

        let m61 = (Number(1) << 61) - Number(1)
        let m127 = (Number(1) << 127) - Number(1)
        let m521 = (Number(1) << 521) - Number(1)

        test(a: 2, p: m127)
        test(a: Number(1) << 42, p: m127)
        test(a: Number(1) << 42 + Number(1), p: m127)
        test(a: m61, p: m127)
        test(a: m61 + 1, p: m127)
        test(a: m61, p: m521)
        test(a: m61 + 1, p: m521)
        test(a: m127, p: m521)
    }

    func testBitWidth() {
        XCTAssertEqual(Number(0).bitWidth, 0)
        XCTAssertEqual(Number(1).bitWidth, 1)
        XCTAssertEqual(Number(Word.max).bitWidth, Word.bitWidth)
        XCTAssertEqual(Number(words: [Word.max, 1]).bitWidth, Word.bitWidth + 1)
        XCTAssertEqual(Number(words: [2, 12]).bitWidth, Word.bitWidth + 4)
        XCTAssertEqual(Number(words: [1, Word.max]).bitWidth, 2 * Word.bitWidth)

        XCTAssertEqual(Number(0).leadingZeroBitCount, 0)
        XCTAssertEqual(Number(1).leadingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(Number(Word.max).leadingZeroBitCount, 0)
        XCTAssertEqual(Number(words: [Word.max, 1]).leadingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(Number(words: [14, Word.max]).leadingZeroBitCount, 0)

        XCTAssertEqual(Number(0).trailingZeroBitCount, 0)
        XCTAssertEqual(Number((1 as Word) << (Word.bitWidth - 1)).trailingZeroBitCount, Word.bitWidth - 1)
        XCTAssertEqual(Number(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual(Number(words: [0, 1]).trailingZeroBitCount, Word.bitWidth)
        XCTAssertEqual(Number(words: [0, 1 << Word(Word.bitWidth - 1)]).trailingZeroBitCount, 2 * Word.bitWidth - 1)
    }

    func testBitwise() {
        let a = Number("1234567890ABCDEF13579BDF2468ACE", radix: 16)!
        let b = Number("ECA8642FDB97531FEDCBA0987654321", radix: 16)!

        //                                    a = 01234567890ABCDEF13579BDF2468ACE
        //                                    b = 0ECA8642FDB97531FEDCBA0987654321
        XCTAssertEqual(String(~a,    radix: 16), "fedcba9876f543210eca86420db97531")
        XCTAssertEqual(String(a | b, radix: 16),  "febc767fdbbfdfffffdfbbdf767cbef")
        XCTAssertEqual(String(a & b, radix: 16),    "2044289083410f014380982440200")
        XCTAssertEqual(String(a ^ b, radix: 16),  "fe9c32574b3c9ef0fe9c3b47523c9ef")

        let ffff = Number(words: Array(repeating: Word.max, count: 30))
        let not = ~ffff
        let zero = Number()
        XCTAssertEqual(not, zero)
        XCTAssertEqual(Array((~ffff).words), [])
        XCTAssertEqual(a | ffff, ffff)
        XCTAssertEqual(a | 0, a)
        XCTAssertEqual(a & a, a)
        XCTAssertEqual(a & 0, 0)
        XCTAssertEqual(a & ffff, a)
        XCTAssertEqual(~(a | b), (~a & ~b))
        XCTAssertEqual(~(a & b), (~a | ~b).extract(..<(a&b).count))
        XCTAssertEqual(a ^ a, 0)
        XCTAssertEqual((a ^ b) ^ b, a)
        XCTAssertEqual((a ^ b) ^ a, b)

        var z = a * b
        z |= a
        z &= b
        z ^= ffff
        XCTAssertEqual(z, (((a * b) | a) & b) ^ ffff)
    }

    func testLeftShifts() {
        let sample = Number("123456789ABCDEF01234567891631832727633", radix: 16)!

        var a = sample

        a <<= 0
        XCTAssertEqual(a, sample)

        a = sample
        a <<= 1
        XCTAssertEqual(a, 2 * sample)

        a = sample
        a <<= Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a[0], 0)
        XCTAssertEqual(a.extract(1 ... sample.count + 1), sample)

        a = sample
        a <<= 100 * Word.bitWidth
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a.extract(0 ..< 100), 0)
        XCTAssertEqual(a.extract(100 ... sample.count + 100), sample)

        a = sample
        a <<= 100 * Word.bitWidth + 2
        XCTAssertEqual(a.count, sample.count + 100)
        XCTAssertEqual(a.extract(0 ..< 100), 0)
        XCTAssertEqual(a.extract(100 ... sample.count + 100), sample << 2)

        a = sample
        a <<= Word.bitWidth - 1
        XCTAssertEqual(a.count, sample.count + 1)
        XCTAssertEqual(a, Number(words: [0] + sample.words) / 2)


        a = sample
        a <<= -4
        XCTAssertEqual(a, sample / 16)

        XCTAssertEqual(sample << 0, sample)
        XCTAssertEqual(sample << 1, 2 * sample)
        XCTAssertEqual(sample << 2, 4 * sample)
        XCTAssertEqual(sample << 4, 16 * sample)
        XCTAssertEqual(sample << Word.bitWidth, Number(words: [0 as Word] + sample.words))
        XCTAssertEqual(sample << (Word.bitWidth - 1), Number(words: [0] + sample.words) / 2)
        XCTAssertEqual(sample << (Word.bitWidth + 1), Number(words: [0] + sample.words) * 2)
        XCTAssertEqual(sample << (Word.bitWidth + 2), Number(words: [0] + sample.words) * 4)
        XCTAssertEqual(sample << (2 * Word.bitWidth), Number(words: [0, 0] + sample.words))
        XCTAssertEqual(sample << (2 * Word.bitWidth + 2), Number(words: [0, 0] + (4 * sample).words))

        XCTAssertEqual(sample << -1, sample / 2)
        XCTAssertEqual(sample << -4, sample / 16)
    }

    func testRightShifts() {
        let sample = Number("123456789ABCDEF1234567891631832727633", radix: 16)!

        var a = sample

        a >>= Number(0)
        XCTAssertEqual(a, sample)

        a >>= 0
        XCTAssertEqual(a, sample)

        a = sample
        a >>= 1
        XCTAssertEqual(a, sample / 2)

        a = sample
        a >>= Word.bitWidth
        XCTAssertEqual(a, sample.extract(1...))

        a = sample
        a >>= Word.bitWidth + 2
        XCTAssertEqual(a, sample.extract(1...) / 4)

        a = sample
        a >>= sample.count * Word.bitWidth
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 1000
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 100 * Word.bitWidth
        XCTAssertEqual(a, 0)

        a = sample
        a >>= 100 * Number(Word.max)
        XCTAssertEqual(a, 0)

        a = sample
        a >>= -1
        XCTAssertEqual(a, sample * 2)

        a = sample
        a >>= -4
        XCTAssertEqual(a, sample * 16)

        XCTAssertEqual(sample >> Number(0), sample)
        XCTAssertEqual(sample >> 0, sample)
        XCTAssertEqual(sample >> 1, sample / 2)
        XCTAssertEqual(sample >> 3, sample / 8)
        XCTAssertEqual(sample >> Word.bitWidth, sample.extract(1 ..< sample.count))
        XCTAssertEqual(sample >> (Word.bitWidth + 2), sample.extract(1...) / 4)
        XCTAssertEqual(sample >> (Word.bitWidth + 3), sample.extract(1...) / 8)
        XCTAssertEqual(sample >> (sample.count * Word.bitWidth), 0)
        XCTAssertEqual(sample >> (100 * Word.bitWidth), 0)
        XCTAssertEqual(sample >> (100 * Number(Word.max)), 0)

        XCTAssertEqual(sample >> -1, sample * 2)
        XCTAssertEqual(sample >> -4, sample * 16)
    }

    func testSquareRoot() {
        let sample = Number("123456789ABCDEF1234567891631832727633", radix: 16)!

        XCTAssertEqual(Number(0).squareRoot(), 0)
        XCTAssertEqual(Number(256).squareRoot(), 16)

        func checkSqrt(_ value: Number, file: StaticString = #file, line: UInt = #line) {
            let root = value.squareRoot()
            XCTAssertLessThanOrEqual(root * root, value, "\(value)", file: file, line: line)
            XCTAssertGreaterThan((root + 1) * (root + 1), value, "\(value)", file: file, line: line)
        }
        for i in 0 ... 100 {
            checkSqrt(Number(i))
            checkSqrt(Number(i) << 100)
        }
        checkSqrt(sample)
        checkSqrt(sample * sample)
        checkSqrt(sample * sample - 1)
        checkSqrt(sample * sample + 1)
    }

    func testGCD() {
        XCTAssertEqual(Number(0).greatestCommonDivisor(with: 2982891), 2982891)
        XCTAssertEqual(Number(2982891).greatestCommonDivisor(with: 0), 2982891)
        XCTAssertEqual(Number(0).greatestCommonDivisor(with: 0), 0)

        XCTAssertEqual(Number(4).greatestCommonDivisor(with: 6), 2)
        XCTAssertEqual(Number(15).greatestCommonDivisor(with: 10), 5)
        XCTAssertEqual(Number(8 * 3 * 25 * 7).greatestCommonDivisor(with: 2 * 9 * 5 * 49), 2 * 3 * 5 * 7)

        var fibo: [Number] = [0, 1]
        for i in 0...10000 {
            fibo.append(fibo[i] + fibo[i + 1])
        }

        XCTAssertEqual(Number(fibo[100]).greatestCommonDivisor(with: fibo[101]), 1)
        XCTAssertEqual(Number(fibo[1000]).greatestCommonDivisor(with: fibo[1001]), 1)
        XCTAssertEqual(Number(fibo[10000]).greatestCommonDivisor(with: fibo[10001]), 1)

        XCTAssertEqual(Number(3 * 5 * 7 * 9).greatestCommonDivisor(with: 5 * 7 * 7), 5 * 7)
        XCTAssertEqual(Number(fibo[4]).greatestCommonDivisor(with: fibo[2]), fibo[2])
        XCTAssertEqual(Number(fibo[3 * 5 * 7 * 9]).greatestCommonDivisor(with: fibo[5 * 7 * 7 * 9]), fibo[5 * 7 * 9])
        XCTAssertEqual(Number(fibo[7 * 17 * 83]).greatestCommonDivisor(with: fibo[6 * 17 * 83]), fibo[17 * 83])
    }

    func testInverse() {
        XCTAssertNil(Number(4).inverse(2))
        XCTAssertNil(Number(4).inverse(8))
        XCTAssertNil(Number(12).inverse(15))
        XCTAssertEqual(Number(13).inverse(15), 7)

        XCTAssertEqual(Number(251).inverse(1023), 269)
        XCTAssertNil(Number(252).inverse(1023))
        XCTAssertEqual(Number(2).inverse(1023), 512)
    }


    func testStrongProbablePrimeTest() {
        let primes: [Number.Word] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 79, 83, 89, 97]
        let pseudoPrimes: [Number] = [
            /*  2 */ 2_047,
            /*  3 */ 1_373_653,
            /*  5 */ 25_326_001,
            /*  7 */ 3_215_031_751,
            /* 11 */ 2_152_302_898_747,
            /* 13 */ 3_474_749_660_383,
            /* 17 */ 341_550_071_728_321,
            /* 19 */ 341_550_071_728_321,
            /* 23 */ 3_825_123_056_546_413_051,
            /* 29 */ 3_825_123_056_546_413_051,
            /* 31 */ 3_825_123_056_546_413_051,
            /* 37 */ "318665857834031151167461",
            /* 41 */ "3317044064679887385961981",
        ]
        for i in 0..<pseudoPrimes.count {
            let candidate = pseudoPrimes[i]
            print(candidate)
            // SPPT should not rule out candidate's primality for primes less than prime[i + 1]
            for j in 0...i {
                XCTAssertTrue(candidate.isStrongProbablePrime(Number(primes[j])))
            }
            // But the pseudoprimes aren't prime, so there is a base that disproves them.
            let foo = (i + 1 ... i + 3).filter { !candidate.isStrongProbablePrime(Number(primes[$0])) }
            XCTAssertNotEqual(foo, [])
        }

        // Try the SPPT for some Mersenne numbers.

        // Mersenne exponents from OEIS: https://oeis.org/A000043
        XCTAssertFalse((Number(1) << 606 - Number(1)).isStrongProbablePrime(5))
        XCTAssertTrue((Number(1) << 607 - Number(1)).isStrongProbablePrime(5)) // 2^607 - 1 is prime
        XCTAssertFalse((Number(1) << 608 - Number(1)).isStrongProbablePrime(5))

        XCTAssertFalse((Number(1) << 520 - Number(1)).isStrongProbablePrime(7))
        XCTAssertTrue((Number(1) << 521 - Number(1)).isStrongProbablePrime(7)) // 2^521 -1 is prime
        XCTAssertFalse((Number(1) << 522 - Number(1)).isStrongProbablePrime(7))

        XCTAssertFalse((Number(1) << 88 - Number(1)).isStrongProbablePrime(128))
        XCTAssertTrue((Number(1) << 89 - Number(1)).isStrongProbablePrime(128)) // 2^89 -1 is prime
        XCTAssertFalse((Number(1) << 90 - Number(1)).isStrongProbablePrime(128))

        // One extra test to exercise an a^2 % modulus == 1 case
        XCTAssertFalse(Number(217).isStrongProbablePrime(129))
    }

    func testIsPrime() {
        XCTAssertFalse(Number(0).isPrime())
        XCTAssertFalse(Number(1).isPrime())
        XCTAssertTrue(Number(2).isPrime())
        XCTAssertTrue(Number(3).isPrime())
        XCTAssertFalse(Number(4).isPrime())
        XCTAssertTrue(Number(5).isPrime())

        // Try primality testing the first couple hundred Mersenne numbers comparing against the first few Mersenne exponents from OEIS: https://oeis.org/A000043
        let mp: Set<Int> = [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521]
        for exponent in 2..<200 {
            let m = Number(1) << exponent - 1
            XCTAssertEqual(m.isPrime(), mp.contains(exponent), "\(exponent)")
        }
    }

    func testConversionToString() {
        let sample = Number("123456789ABCDEFEDCBA98765432123456789ABCDEF", radix: 16)!
        // Radix = 10
        XCTAssertEqual(String(Number()), "0")
        XCTAssertEqual(String(Number(1)), "1")
        XCTAssertEqual(String(Number(100)), "100")
        XCTAssertEqual(String(Number(12345)), "12345")
        XCTAssertEqual(String(Number(123456789)), "123456789")
        XCTAssertEqual(String(sample), "425693205796080237694414176550132631862392541400559")

        // Radix = 16
        XCTAssertEqual(String(Number(0x1001), radix: 16), "1001")
        XCTAssertEqual(String(Number(0x0102030405060708), radix: 16), "102030405060708")
        XCTAssertEqual(String(sample, radix: 16), "123456789abcdefedcba98765432123456789abcdef")
        XCTAssertEqual(String(sample, radix: 16, uppercase: true), "123456789ABCDEFEDCBA98765432123456789ABCDEF")

        // Radix = 2
        XCTAssertEqual(String(Number(12), radix: 2), "1100")
        XCTAssertEqual(String(Number(123), radix: 2), "1111011")
        XCTAssertEqual(String(Number(1234), radix: 2), "10011010010")
        XCTAssertEqual(String(sample, radix: 2), "1001000110100010101100111100010011010101111001101111011111110110111001011101010011000011101100101010000110010000100100011010001010110011110001001101010111100110111101111")

        // Radix = 31
        XCTAssertEqual(String(Number(30), radix: 31), "u")
        XCTAssertEqual(String(Number(31), radix: 31), "10")
        XCTAssertEqual(String(Number("10000000000000000", radix: 16)!, radix: 31), "nd075ib45k86g")
        XCTAssertEqual(String(Number("2908B5129F59DB6A41", radix: 16)!, radix: 31), "100000000000000")
        XCTAssertEqual(String(sample, radix: 31), "ptf96helfaqi7ogc3jbonmccrhmnc2b61s")

        if let quickLook = Number(513).playgroundDescription as? String {
            XCTAssertEqual(quickLook, "Number(\"513\")")
        } else {
            XCTFail("Failed to produce quick look for Number(513)")
        }
    }

    func testConversionFromString() {
        let sample = "123456789ABCDEFEDCBA98765432123456789ABCDEF"

        XCTAssertEqual(Number("1"), 1)
        XCTAssertEqual(Number("123456789ABCDEF", radix: 16)!, 0x123456789ABCDEF)
        XCTAssertEqual(Number("1000000000000000000000"), Number("3635C9ADC5DEA00000", radix: 16))
        XCTAssertEqual(Number("10000000000000000", radix: 16), Number("18446744073709551616"))
        XCTAssertEqual(Number(sample, radix: 16)!, Number("425693205796080237694414176550132631862392541400559"))

        // We have to call Number.init here because we don't want Literal initialization via coercion (SE-0213)
        XCTAssertNil(Number.init("Not a number"))
        XCTAssertNil(Number.init("X"))
        XCTAssertNil(Number.init("12349A"))
        XCTAssertNil(Number.init("000000000000000000000000A000"))
        XCTAssertNil(Number.init("00A0000000000000000000000000"))
        XCTAssertNil(Number.init("00 0000000000000000000000000"))
        XCTAssertNil(Number.init("\u{4e00}\u{4e03}")) // Chinese numerals "1", "7"

        XCTAssertEqual(Number("u", radix: 31)!, 30)
        XCTAssertEqual(Number("10", radix: 31)!, 31)
        XCTAssertEqual(Number("100000000000000", radix: 31)!, Number("2908B5129F59DB6A41", radix: 16)!)
        XCTAssertEqual(Number("nd075ib45k86g", radix: 31)!, Number("10000000000000000", radix: 16)!)
        XCTAssertEqual(Number("ptf96helfaqi7ogc3jbonmccrhmnc2b61s", radix: 31)!, Number(sample, radix: 16)!)

        XCTAssertNotNil(Number(sample.repeated(100), radix: 16))
   }

    func testRandomIntegerWithMaximumWidth() {
        XCTAssertEqual(Number.randomInteger(withMaximumWidth: 0), 0)

        let randomByte = Number.randomInteger(withMaximumWidth: 8)
        XCTAssertLessThan(randomByte, 256)

        for _ in 0 ..< 100 {
            XCTAssertLessThanOrEqual(Number.randomInteger(withMaximumWidth: 1024).bitWidth, 1024)
        }

        // Verify that all widths <= maximum are produced (with a tiny maximum)
        var widths: Set<Int> = [0, 1, 2, 3]
        var i = 0
        while !widths.isEmpty {
            let random = Number.randomInteger(withMaximumWidth: 3)
            XCTAssertLessThanOrEqual(random.bitWidth, 3)
            widths.remove(random.bitWidth)
            i += 1
            if i > 4096 {
                XCTFail("randomIntegerWithMaximumWidth doesn't seem random")
                break
            }
        }

        // Verify that all bits are sometimes zero, sometimes one.
        var oneBits = Set<Int>(0..<1024)
        var zeroBits = Set<Int>(0..<1024)
        while !oneBits.isEmpty || !zeroBits.isEmpty {
            var random = Number.randomInteger(withMaximumWidth: 1024)
            for i in 0..<1024 {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
    }

    func testRandomIntegerWithExactWidth() {
        XCTAssertEqual(Number.randomInteger(withExactWidth: 0), 0)
        XCTAssertEqual(Number.randomInteger(withExactWidth: 1), 1)

        for _ in 0 ..< 1024 {
            let randomByte = Number.randomInteger(withExactWidth: 8)
            XCTAssertEqual(randomByte.bitWidth, 8)
            XCTAssertLessThan(randomByte, 256)
            XCTAssertGreaterThanOrEqual(randomByte, 128)
        }

        for _ in 0 ..< 100 {
            XCTAssertEqual(Number.randomInteger(withExactWidth: 1024).bitWidth, 1024)
        }

        // Verify that all bits except the top are sometimes zero, sometimes one.
        var oneBits = Set<Int>(0..<1023)
        var zeroBits = Set<Int>(0..<1023)
        while !oneBits.isEmpty || !zeroBits.isEmpty {
            var random = Number.randomInteger(withExactWidth: 1024)
            for i in 0..<1023 {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
    }

    func testRandomIntegerLessThan() {
        // Verify that all bits in random integers generated by `randomIntegerLessThan` are sometimes zero, sometimes one.
        //
        // The limit starts with "11" so that generated random integers may easily begin with all combos.
        // Also, 25% of the time the initial random int will be rejected as higher than the
        // limit -- this helps stabilize code coverage.
        let limit = Number(3) << 1024
        var oneBits = Set<Int>(0..<limit.bitWidth)
        var zeroBits = Set<Int>(0..<limit.bitWidth)
        for _ in 0..<100 {
            var random = Number.randomInteger(lessThan: limit)
            XCTAssertLessThan(random, limit)
            for i in 0..<limit.bitWidth {
                if random[0] & 1 == 1 { oneBits.remove(i) }
                else { zeroBits.remove(i) }
                random >>= 1
            }
        }
        XCTAssertEqual(oneBits, [])
        XCTAssertEqual(zeroBits, [])
    }

    func testRandomFunctionsUseProvidedGenerator() {
        // Here I verify that each of the randomInteger functions uses the provided RNG, and not SystemRandomNumberGenerator.
        // This is important because all but Number.randomInteger(withMaximumWidth:using:) are built on that base function, and it is easy to forget to pass along the provided generator and get a default SystemRandomNumberGenerator instead.

        // Since SystemRandomNumberGenerator is seeded randomly, repeated uses should give varying results.
        // So here I pass the same deterministic RNG repeatedly and verify that I get the same result each time.

        struct CountingRNG: RandomNumberGenerator {
            var i: UInt64 = 12345
            mutating func next() -> UInt64 {
                i += 1
                return i
            }
        }

        func gen(_ body: (inout CountingRNG) -> Number) -> Number {
            var rng = CountingRNG()
            return body(&rng)
        }

        func check(_ body: (inout CountingRNG) -> Number) {
            let expected = gen(body)
            for _ in 0 ..< 100 {
                let actual = gen(body)
                XCTAssertEqual(expected, actual)
            }
        }

        check { Number.randomInteger(withMaximumWidth: 200, using: &$0) }
        check { Number.randomInteger(withExactWidth: 200, using: &$0) }
        let limit = Number(UInt64.max) * Number(UInt64.max) * Number(UInt64.max)
        check { Number.randomInteger(lessThan: limit, using: &$0) }
    }

    func testConversionsToSNumber() {
        let number = Number(123456789)
        let sNumber = number.asSNumber
        let int = try? number.toInt()
        XCTAssertEqual(int, 123456789)
    }

    func testConversionsToInt() {
        let number = Number(123456789)
        let int = try? number.toInt()
        XCTAssertEqual(int, 123456789)

        let number2 = Number("99999999999999999999999999999999999999999999999999999999")
        XCTAssertThrowsError(try number2.toInt()) { error in
            XCTAssertEqual(error as? Number.ConversionError, Number.ConversionError.sNumberTooLarge)
        }
    }

    func testPow10() {
        let number = Number.pow10(18)
        XCTAssertEqual(number, Number("1000000000000000000"))
    }

    func testStringAndPrecision() {
        let number = Number("123456789.123456789", andPrecision: 18)
        XCTAssertEqual(number, Number("123456789123456789000000000"))

        let number2 = Number("123456789.123456789", andPrecision: 0)
        XCTAssertEqual(number2, Number("123456789"))

        let number3 = Number("123456789.123456789", andPrecision: 1)
        XCTAssertEqual(number3, Number("1234567891"))

        let number4 = Number("fff.vv", andPrecision: 1)
        XCTAssertEqual(number4, nil)
    }
}
