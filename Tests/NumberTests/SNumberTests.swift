//
//  SNumberTests.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.

import XCTest
@testable import SwiftNumber
import Foundation

class SNumberTests: XCTestCase {
    typealias Word = SNumber.Word

    func testSigns() {
        XCTAssertTrue(SNumber.isSigned)

        XCTAssertEqual(SNumber().signum(), 0)
        XCTAssertEqual(SNumber(-2).signum(), -1)
        XCTAssertEqual(SNumber(-1).signum(), -1)
        XCTAssertEqual(SNumber(0).signum(), 0)
        XCTAssertEqual(SNumber(1).signum(), 1)
        XCTAssertEqual(SNumber(2).signum(), 1)

        XCTAssertEqual(SNumber(words: [0, Word.max]).signum(), -1)
        XCTAssertEqual(SNumber(words: [0, 1]).signum(), 1)
    }

    func testInit() {
        XCTAssertEqual(SNumber().sign, .plus)
        XCTAssertEqual(SNumber().magnitude, 0)

        XCTAssertEqual(SNumber(Int64.min).sign, .minus)
        XCTAssertEqual(SNumber(Int64.min).magnitude - 1, SNumber(Int64.max).magnitude)

        let zero = SNumber(0)
        XCTAssertTrue(zero.magnitude.isZero)
        XCTAssertEqual(zero.sign, .plus)

        let minusOne = SNumber(-1)
        XCTAssertEqual(minusOne.magnitude, 1)
        XCTAssertEqual(minusOne.sign, .minus)

        let b: SNumber = 42
        XCTAssertEqual(b.magnitude, 42)
        XCTAssertEqual(b.sign, .plus)

        XCTAssertEqual(SNumber(UInt64.max).magnitude, Number(UInt64.max))

        let b2: SNumber = "+300"
        XCTAssertEqual(b2.magnitude, 300)
        XCTAssertEqual(b2.sign, .plus)

        let b3: SNumber = "-300"
        XCTAssertEqual(b3.magnitude, 300)
        XCTAssertEqual(b3.sign, .minus)

        // We have to call SNumber.init here because we don't want Literal initialization via coercion (SE-0213)
        XCTAssertNil(SNumber.init("Not a number"))
        XCTAssertEqual(SNumber(unicodeScalarLiteral: UnicodeScalar(52)), SNumber(4))
        XCTAssertEqual(SNumber(extendedGraphemeClusterLiteral: "4"), SNumber(4))

        XCTAssertEqual(SNumber(words: []), 0)
        XCTAssertEqual(SNumber(words: [1, 1]), SNumber(1) << Word.bitWidth + 1)
        XCTAssertEqual(SNumber(words: [1, 2]), SNumber(2) << Word.bitWidth + 1)
        XCTAssertEqual(SNumber(words: [0, Word.max]), -(SNumber(1) << Word.bitWidth))
        XCTAssertEqual(SNumber(words: [1, Word.max]), -SNumber(Word.max))
        XCTAssertEqual(SNumber(words: [1, Word.max, Word.max]), -SNumber(Word.max))
        
        XCTAssertEqual(SNumber(exactly: 1), SNumber(1))
        XCTAssertEqual(SNumber(exactly: -1), SNumber(-1))
    }

    func testInit_FloatingPoint() {
        XCTAssertEqual(SNumber(42.0), 42)
        XCTAssertEqual(SNumber(-42.0), -42)
        XCTAssertEqual(SNumber(42.5), 42)
        XCTAssertEqual(SNumber(-42.5), -42)
        XCTAssertEqual(SNumber(exactly: 42.0), 42)
        XCTAssertEqual(SNumber(exactly: -42.0), -42)
        XCTAssertNil(SNumber(exactly: 42.5))
        XCTAssertNil(SNumber(exactly: -42.5))
        XCTAssertNil(SNumber(exactly: Double.leastNormalMagnitude))
        XCTAssertNil(SNumber(exactly: Double.leastNonzeroMagnitude))
        XCTAssertNil(SNumber(exactly: Double.infinity))
        XCTAssertNil(SNumber(exactly: Double.nan))
        XCTAssertNil(SNumber(exactly: Double.signalingNaN))
        XCTAssertEqual(SNumber(clamping: -42), -42)
        XCTAssertEqual(SNumber(clamping: 42), 42)
        XCTAssertEqual(SNumber(truncatingIfNeeded: -42), -42)
        XCTAssertEqual(SNumber(truncatingIfNeeded: 42), 42)
    }

    func testInit_Decimal() throws {
        XCTAssertEqual(SNumber(exactly: Decimal(0)), 0)
        XCTAssertEqual(SNumber(exactly: Decimal(Double.nan)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal(10)), 10)
        XCTAssertEqual(SNumber(exactly: Decimal(1000)), 1000)
        XCTAssertEqual(SNumber(exactly: Decimal(1000.1)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal(1000.9)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal(1001.5)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal(UInt.max) + 5), "18446744073709551620")
        XCTAssertEqual(SNumber(exactly: (Decimal(UInt.max) + 5.5)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal.greatestFiniteMagnitude),
                       "3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(SNumber(truncating: Decimal(0)), 0)
        XCTAssertEqual(SNumber(truncating: Decimal(Double.nan)), nil)
        XCTAssertEqual(SNumber(truncating: Decimal(10)), 10)
        XCTAssertEqual(SNumber(truncating: Decimal(1000)), 1000)
        XCTAssertEqual(SNumber(truncating: Decimal(1000.1)), 1000)
        XCTAssertEqual(SNumber(truncating: Decimal(1000.9)), 1000)
        XCTAssertEqual(SNumber(truncating: Decimal(1001.5)), 1001)
        XCTAssertEqual(SNumber(truncating: Decimal(UInt.max) + 5), "18446744073709551620")
        XCTAssertEqual(SNumber(truncating: (Decimal(UInt.max) + 5.5)), "18446744073709551620")

        XCTAssertEqual(SNumber(exactly: -Decimal(10)), -10)
        XCTAssertEqual(SNumber(exactly: -Decimal(1000)), -1000)
        XCTAssertEqual(SNumber(exactly: -Decimal(1000.1)), nil)
        XCTAssertEqual(SNumber(exactly: -Decimal(1000.9)), nil)
        XCTAssertEqual(SNumber(exactly: -Decimal(1001.5)), nil)
        XCTAssertEqual(SNumber(exactly: -(Decimal(UInt.max) + 5)), "-18446744073709551620")
        XCTAssertEqual(SNumber(exactly: -(Decimal(UInt.max) + 5.5)), nil)
        XCTAssertEqual(SNumber(exactly: Decimal.leastFiniteMagnitude),
                       "-3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertEqual(SNumber(truncating: -Decimal(10)), -10)
        XCTAssertEqual(SNumber(truncating: -Decimal(1000)), -1000)
        XCTAssertEqual(SNumber(truncating: -Decimal(1000.1)), -1000)
        XCTAssertEqual(SNumber(truncating: -Decimal(1000.9)), -1000)
        XCTAssertEqual(SNumber(truncating: -Decimal(1001.5)), -1001)
        XCTAssertEqual(SNumber(truncating: -(Decimal(UInt.max) + 5)), "-18446744073709551620")
        XCTAssertEqual(SNumber(truncating: -(Decimal(UInt.max) + 5.5)), "-18446744073709551620")
    }

    func testInit_Buffer() {
        func test(_ b: SNumber, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
            d.withUnsafeBytes { buffer in
                let initialized = SNumber(buffer)
                XCTAssertEqual(initialized, b, file: file, line: line)
            }
        }
        
        // Positive integers
        test(SNumber(), [])
        test(SNumber(1), [0x00, 0x01])
        test(SNumber(2), [0x00, 0x02])
        test(SNumber(0x0102030405060708), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(SNumber(0x01) << 64 + SNumber(0x0203040506070809), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09])
        
        // Negative integers
        test(SNumber(), [])
        test(SNumber(-1), [0x01, 0x01])
        test(SNumber(-2), [0x01, 0x02])
        test(SNumber(0x0102030405060708) * SNumber(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test((SNumber(0x01) << 64 + SNumber(0x0203040506070809)) * SNumber(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09])
    }

    func testConversionToFloatingPoint() {
        func test<F: BinaryFloatingPoint>(_ a: SNumber, _ b: F, file: StaticString = #file, line: UInt = #line)
        where F.RawExponent: FixedWidthInteger, F.RawSignificand: FixedWidthInteger {
                let f = F(a)
                XCTAssertEqual(f, b, file: file, line: line)
        }

        for i in -100 ..< 100 {
            test(SNumber(i), Double(i))
        }
        test(SNumber(0x5A5A5A), 0x5A5A5A as Double)
        test(SNumber(1) << 64, 0x1p64 as Double)
        test(SNumber(0x5A5A5A) << 64, 0x5A5A5Ap64 as Double)
        test(SNumber(1) << 1023, 0x1p1023 as Double)
        test(SNumber(10) << 1020, 0xAp1020 as Double)
        test(SNumber(1) << 1024, Double.infinity)
        test(SNumber(words: convertWords([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFFFFFFFFFFFFF800, 0])),
             Double.greatestFiniteMagnitude)

        for i in -100 ..< 100 {
            test(SNumber(i), Float(i))
        }
        test(SNumber(0x5A5A5A), 0x5A5A5A as Float)
        test(SNumber(1) << 64, 0x1p64 as Float)
        test(SNumber(0x5A5A5A) << 64, 0x5A5A5Ap64 as Float)
        test(SNumber(1) << 1023, 0x1p1023 as Float)
        test(SNumber(10) << 1020, 0xAp1020 as Float)
        test(SNumber(1) << 1024, Float.infinity)
        test(SNumber(words: convertWords([0, 0xFFFFFF0000000000, 0])),
             Float.greatestFiniteMagnitude)

        XCTAssertEqual(Decimal(SNumber(0)), 0)
        XCTAssertEqual(Decimal(SNumber(20)), 20)
        XCTAssertEqual(Decimal(SNumber(123456789)), 123456789)
        XCTAssertEqual(Decimal(SNumber(exactly: Decimal.greatestFiniteMagnitude)!), .greatestFiniteMagnitude)
        XCTAssertEqual(Decimal(SNumber(exactly: Decimal.greatestFiniteMagnitude)! * 2), .greatestFiniteMagnitude)
        XCTAssertEqual(Decimal(-SNumber(0)), 0)
        XCTAssertEqual(Decimal(-SNumber(20)), -20)
        XCTAssertEqual(Decimal(-SNumber(123456789)), -123456789)
        XCTAssertEqual(Decimal(-SNumber(exactly: Decimal.greatestFiniteMagnitude)!), -.greatestFiniteMagnitude)
        XCTAssertEqual(Decimal(-SNumber(exactly: Decimal.greatestFiniteMagnitude)! * 2), -.greatestFiniteMagnitude)

    }

    func testTwosComplement() {
        func check(_ a: [Word], _ b: [Word], file: StaticString = #file, line: UInt = #line) {
            var a2 = a
            a2.twosComplement()
            XCTAssertEqual(a2, b, file: file, line: line)
            var b2 = b
            b2.twosComplement()
            XCTAssertEqual(b2, a, file: file, line: line)
        }
        check([1], [Word.max])
        check([Word.max], [1])
        check([1, 1], [Word.max, Word.max - 1])
        check([(1 as Word) << (Word.bitWidth - 1)], [(1 as Word) << (Word.bitWidth - 1)])
        check([0], [0])
        check([0, 0, 1], [0, 0, Word.max])
        check([0, 0, 1, 0, 1], [0, 0, Word.max, Word.max, Word.max - 1])
        check([0, 0, 1, 1], [0, 0, Word.max, Word.max - 1])
        check([0, 0, 1, 0, 0, 0], [0, 0, Word.max, Word.max, Word.max, Word.max])
    }

    func testSign() {
        XCTAssertEqual(SNumber(-1).sign, .minus)
        XCTAssertEqual(SNumber(0).sign, .plus)
        XCTAssertEqual(SNumber(1).sign, .plus)
    }

    func testBitWidth() {
        XCTAssertEqual(SNumber(0).bitWidth, 0)
        XCTAssertEqual(SNumber(1).bitWidth, 2)
        XCTAssertEqual(SNumber(-1).bitWidth, 2)
        XCTAssertEqual((SNumber(1) << 64).bitWidth, Word.bitWidth + 2)
        XCTAssertEqual(SNumber(Word.max).bitWidth, Word.bitWidth + 1)
        XCTAssertEqual(SNumber(Word.max >> 1).bitWidth, Word.bitWidth)
    }

    func testTrailingZeroBitCount() {
        XCTAssertEqual(SNumber(0).trailingZeroBitCount, 0)
        XCTAssertEqual(SNumber(1).trailingZeroBitCount, 0)
        XCTAssertEqual(SNumber(-1).trailingZeroBitCount, 0)
        XCTAssertEqual(SNumber(2).trailingZeroBitCount, 1)
        XCTAssertEqual(SNumber(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual(SNumber(-2).trailingZeroBitCount, 1)
        XCTAssertEqual(-SNumber(Word.max).trailingZeroBitCount, 0)
        XCTAssertEqual((SNumber(1) << 100).trailingZeroBitCount, 100)
        XCTAssertEqual(((-SNumber(1)) << 100).trailingZeroBitCount, 100)
    }

    func testWords() {
        XCTAssertEqual(Array(SNumber(0).words), [])
        XCTAssertEqual(Array(SNumber(1).words), [1])
        XCTAssertEqual(Array(SNumber(-1).words), [Word.max])

        let highBit = (1 as Word) << (Word.bitWidth - 1)
        XCTAssertEqual(Array(SNumber(highBit).words), [highBit, 0])
        XCTAssertEqual(Array((-SNumber(highBit)).words), [highBit, Word.max])

        XCTAssertEqual(Array(SNumber(sign: .plus, magnitude: Number(words: [Word.max])).words), [Word.max, 0])
        XCTAssertEqual(Array(SNumber(sign: .minus, magnitude: Number(words: [Word.max])).words), [1, Word.max])

        XCTAssertEqual(Array((SNumber(1) << Word.bitWidth).words), [0, 1])
        XCTAssertEqual(Array((-(SNumber(1) << Word.bitWidth)).words), [0, Word.max])

        XCTAssertEqual(Array((SNumber(42) << Word.bitWidth).words), [0, 42])
        XCTAssertEqual(Array((-(SNumber(42) << Word.bitWidth)).words), [0, Word.max - 41])

        let huge = Number(words: [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(SNumber(sign: .plus, magnitude: huge).words), [0, 1, 2, 3, 4])
        XCTAssertEqual(Array(SNumber(sign: .minus, magnitude: huge).words),
                       [0, Word.max, ~2, ~3, ~4] as [Word])


        XCTAssertEqual(SNumber(1).words[100], 0)
        XCTAssertEqual(SNumber(-1).words[100], Word.max)

        XCTAssertEqual(SNumber(words: [0, 1, 2, 3, 4]).words.indices, 0 ..< 5)
    }

    func testComplement() {
        XCTAssertEqual(~SNumber(-3), SNumber(2))
        XCTAssertEqual(~SNumber(-2), SNumber(1))
        XCTAssertEqual(~SNumber(-1), SNumber(0))
        XCTAssertEqual(~SNumber(0), SNumber(-1))
        XCTAssertEqual(~SNumber(1), SNumber(-2))
        XCTAssertEqual(~SNumber(2), SNumber(-3))

        XCTAssertEqual(~SNumber(words: [1, 2, 3, 4]),
                       SNumber(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]))
        XCTAssertEqual(~SNumber(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]),
                       SNumber(words: [1, 2, 3, 4]))
    }

    func testBinaryAnd() {
        XCTAssertEqual(SNumber(1) & SNumber(2), 0)
        XCTAssertEqual(SNumber(-1) & SNumber(2), 2)
        XCTAssertEqual(SNumber(-1) & SNumber(words: [1, 2, 3, 4]), SNumber(words: [1, 2, 3, 4]))
        XCTAssertEqual(SNumber(-1) & -SNumber(words: [1, 2, 3, 4]), -SNumber(words: [1, 2, 3, 4]))
        XCTAssertEqual(SNumber(Word.max) & SNumber(words: [1, 2, 3, 4]), SNumber(1))
        XCTAssertEqual(SNumber(Word.max) & SNumber(words: [Word.max, 1, 2]), SNumber(Word.max))
        XCTAssertEqual(SNumber(Word.max) & SNumber(words: [Word.max, Word.max - 1]), SNumber(Word.max))
    }

    func testBinaryOr() {
        XCTAssertEqual(SNumber(1) | SNumber(2), 3)
        XCTAssertEqual(SNumber(-1) | SNumber(2), -1)
        XCTAssertEqual(SNumber(-1) | SNumber(words: [1, 2, 3, 4]), -1)
        XCTAssertEqual(SNumber(-1) | -SNumber(words: [1, 2, 3, 4]), -1)
        XCTAssertEqual(SNumber(Word.max) | SNumber(words: [1, 2, 3, 4]),
                       SNumber(words: [Word.max, 2, 3, 4]))
        XCTAssertEqual(SNumber(Word.max) | SNumber(words: [1, 2, 3, Word.max]),
                       SNumber(words: [Word.max, 2, 3, Word.max]))
        XCTAssertEqual(SNumber(Word.max) | SNumber(words: [Word.max - 1, Word.max - 1]),
                       SNumber(words: [Word.max, Word.max - 1]))
    }

    func testBinaryXor() {
        XCTAssertEqual(SNumber(1) ^ SNumber(2), 3)
        XCTAssertEqual(SNumber(-1) ^ SNumber(2), -3)
        XCTAssertEqual(SNumber(1) ^ SNumber(-2), -1)
        XCTAssertEqual(SNumber(-1) ^ SNumber(-2), 1)
        XCTAssertEqual(SNumber(-1) ^ SNumber(words: [1, 2, 3, 4]),
                       SNumber(words: [~1, ~2, ~3, ~4] as [Word]))
        XCTAssertEqual(SNumber(-1) ^ -SNumber(words: [1, 2, 3, 4]),
                       SNumber(words: [0, 2, 3, 4]))
        XCTAssertEqual(SNumber(Word.max) ^ SNumber(words: [1, 2, 3, 4]),
                       SNumber(words: [~1, 2, 3, 4] as [Word]))
        XCTAssertEqual(SNumber(Word.max) ^ SNumber(words: [1, 2, 3, Word.max]),
                       SNumber(words: [~1, 2, 3, Word.max] as [Word]))
        XCTAssertEqual(SNumber(Word.max) ^ SNumber(words: [Word.max - 1, Word.max - 1]),
                       SNumber(words: [1, Word.max - 1]))
    }

    func testConversionToString() {
        let b = SNumber(-256)
        XCTAssertEqual(b.description, "-256")
        XCTAssertEqual(String(b, radix: 16, uppercase: true), "-100")
        if let pql = b.playgroundDescription as? String {
            XCTAssertEqual(pql, "SNumber(\"-256\")")
        } else {
            XCTFail("Unexpected Playground Quick Look: \(b.playgroundDescription)")
        }
    }

    func testComparable() {
        XCTAssertTrue(SNumber(1) == SNumber(1))
        XCTAssertFalse(SNumber(1) == SNumber(-1))

        XCTAssertTrue(SNumber(1) < SNumber(42))
        XCTAssertFalse(SNumber(1) < -SNumber(42))
        XCTAssertTrue(SNumber(-1) < SNumber(42))
        XCTAssertTrue(SNumber(-42) < SNumber(-1))
    }

    func testHashable() {
        XCTAssertEqual(SNumber(1).hashValue, SNumber(1).hashValue)
        XCTAssertNotEqual(SNumber(1).hashValue, SNumber(2).hashValue)
        XCTAssertNotEqual(SNumber(42).hashValue, SNumber(-42).hashValue)
        XCTAssertNotEqual(SNumber(1).hashValue, SNumber(-1).hashValue)
    }

    func testStrideable() {
        XCTAssertEqual(SNumber(1).advanced(by: 100), 101)
        XCTAssertEqual(SNumber(Word.max).advanced(by: 1 as SNumber.Stride), SNumber(1) << Word.bitWidth)

        XCTAssertEqual(SNumber(Word.max).distance(to: SNumber(words: [0, 1])), SNumber(1))
        XCTAssertEqual(SNumber(words: [0, 1]).distance(to: SNumber(Word.max)), SNumber(-1))
        XCTAssertEqual(SNumber(0).distance(to: SNumber(words: [0, 1])), SNumber(words: [0, 1]))
    }

    func compare(_ a: Int, _ b: Int, r: Int, file: StaticString = #file, line: UInt = #line, op: (SNumber, SNumber) -> SNumber) {
        XCTAssertEqual(op(SNumber(a), SNumber(b)), SNumber(r), file: file, line: line)
    }

    func testAddition() {
        compare(0, 0, r: 0, op: +)
        compare(1, 2, r: 3, op: +)
        compare(1, -2, r: -1, op: +)
        compare(-1, 2, r: 1, op: +)
        compare(-1, -2, r: -3, op: +)
        compare(2, -1, r: 1, op: +)
    }

    func testNegation() {
        XCTAssertEqual(-SNumber(0), SNumber(0))
        XCTAssertEqual(-SNumber(1), SNumber(-1))
        XCTAssertEqual(-SNumber(-1), SNumber(1))
    }

    func testSubtraction() {
        compare(0, 0, r: 0, op: -)
        compare(2, 1, r: 1, op: -)
        compare(2, -1, r: 3, op: -)
        compare(-2, 1, r: -3, op: -)
        compare(-2, -1, r: -1, op: -)
    }

    func testMultiplication() {
        compare(0, 0, r: 0, op: *)
        compare(0, 1, r: 0, op: *)
        compare(1, 0, r: 0, op: *)
        compare(0, -1, r: 0, op: *)
        compare(-1, 0, r: 0, op: *)
        compare(2, 3, r: 6, op: *)
        compare(2, -3, r: -6, op: *)
        compare(-2, 3, r: -6, op: *)
        compare(-2, -3, r: 6, op: *)
    }

    func testQuotientAndRemainder() {
        func compare(_ a: SNumber, _ b: SNumber, r: (SNumber, SNumber), file: StaticString = #file, line: UInt = #line) {
            let actual = a.quotientAndRemainder(dividingBy: b)
            XCTAssertEqual(actual.quotient, r.0, "quotient", file: file, line: line)
            XCTAssertEqual(actual.remainder, r.1, "remainder", file: file, line: line)
        }

        compare(0, 1, r: (0, 0))
        compare(0, -1, r: (0, 0))
        compare(7, 4, r: (1, 3))
        compare(7, -4, r: (-1, 3))
        compare(-7, 4, r: (-1, -3))
        compare(-7, -4, r: (1, -3))
    }

    func testDivision() {
        compare(0, 1, r: 0, op: /)
        compare(0, -1, r: 0, op: /)
        compare(7, 4, r: 1, op: /)
        compare(7, -4, r: -1, op: /)
        compare(-7, 4, r: -1, op: /)
        compare(-7, -4, r: 1, op: /)
    }

    func testRemainder() {
        compare(0, 1, r: 0, op: %)
        compare(0, -1, r: 0, op: %)
        compare(7, 4, r: 3, op: %)
        compare(7, -4, r: 3, op: %)
        compare(-7, 4, r: -3, op: %)
        compare(-7, -4, r:-3, op: %)
    }

    func testModulo() {
        XCTAssertEqual(SNumber(22).modulus(5), 2)
        XCTAssertEqual(SNumber(-22).modulus(5), 3)
        XCTAssertEqual(SNumber(22).modulus(-5), 2)
        XCTAssertEqual(SNumber(-22).modulus(-5), 3)
    }

    func testStrideableRequirements() {
        XCTAssertEqual(5, SNumber(3).advanced(by: 2))
        XCTAssertEqual(2, SNumber(3).distance(to: 5))
    }

    func testAbsoluteValuableRequirements() {
        XCTAssertEqual(SNumber(5), abs(5 as SNumber))
        XCTAssertEqual(SNumber(0), abs(0 as SNumber))
        XCTAssertEqual(SNumber(5), abs(-5 as SNumber))
    }

    func testIntegerArithmeticRequirements() {
        XCTAssertEqual(3 as Int64, Int64(3 as SNumber))
        XCTAssertEqual(-3 as Int64, Int64(-3 as SNumber))
    }

    func testAssignmentOperators() {
        var a = SNumber(1)
        a += 13
        XCTAssertEqual(a, 14)

        a -= 7
        XCTAssertEqual(a, 7)

        a *= 3
        XCTAssertEqual(a, 21)

        a /= 2
        XCTAssertEqual(a, 10)

        a %= 7
        XCTAssertEqual(a, 3)
    }

    func testExponentiation() {
        XCTAssertEqual(SNumber(0).power(0), 1)
        XCTAssertEqual(SNumber(0).power(1), 0)
        XCTAssertEqual(SNumber(0).power(2), 0)

        XCTAssertEqual(SNumber(1).power(-2), 1)
        XCTAssertEqual(SNumber(1).power(-1), 1)
        XCTAssertEqual(SNumber(1).power(0), 1)
        XCTAssertEqual(SNumber(1).power(1), 1)
        XCTAssertEqual(SNumber(1).power(2), 1)

        XCTAssertEqual(SNumber(2).power(-4), 0)
        XCTAssertEqual(SNumber(2).power(-3), 0)
        XCTAssertEqual(SNumber(2).power(-2), 0)
        XCTAssertEqual(SNumber(2).power(-1), 0)
        XCTAssertEqual(SNumber(2).power(0), 1)
        XCTAssertEqual(SNumber(2).power(1), 2)
        XCTAssertEqual(SNumber(2).power(2), 4)
        XCTAssertEqual(SNumber(2).power(3), 8)
        XCTAssertEqual(SNumber(2).power(4), 16)

        XCTAssertEqual(SNumber(-1).power(-4), 1)
        XCTAssertEqual(SNumber(-1).power(-3), -1)
        XCTAssertEqual(SNumber(-1).power(-2), 1)
        XCTAssertEqual(SNumber(-1).power(-1), -1)
        XCTAssertEqual(SNumber(-1).power(0), 1)
        XCTAssertEqual(SNumber(-1).power(1), -1)
        XCTAssertEqual(SNumber(-1).power(2), 1)
        XCTAssertEqual(SNumber(-1).power(3), -1)
        XCTAssertEqual(SNumber(-1).power(4), 1)

        XCTAssertEqual(SNumber(-2).power(-4), 0)
        XCTAssertEqual(SNumber(-2).power(-3), 0)
        XCTAssertEqual(SNumber(-2).power(-2), 0)
        XCTAssertEqual(SNumber(-2).power(-1), 0)
        XCTAssertEqual(SNumber(-2).power(0), 1)
        XCTAssertEqual(SNumber(-2).power(1), -2)
        XCTAssertEqual(SNumber(-2).power(2), 4)
        XCTAssertEqual(SNumber(-2).power(3), -8)
        XCTAssertEqual(SNumber(-2).power(4), 16)
    }

    func testModularExponentiation() {
        for i in -5 ... 5 {
            for j in -5 ... 5 {
                for m in [-7, -5, -3, -2, -1, 1, 2, 3, 5, 7] {
                    guard i != 0 || j >= 0 else { continue }
                    XCTAssertEqual(SNumber(i).power(SNumber(j), modulus: SNumber(m)),
                                   SNumber(i).power(j).modulus(SNumber(m)),
                                   "\(i), \(j), \(m)")
                }
            }
        }
    }

    func testSquareRoot() {
        XCTAssertEqual(SNumber(0).squareRoot(), 0)
        XCTAssertEqual(SNumber(1).squareRoot(), 1)
        XCTAssertEqual(SNumber(2).squareRoot(), 1)
        XCTAssertEqual(SNumber(3).squareRoot(), 1)
        XCTAssertEqual(SNumber(4).squareRoot(), 2)
        XCTAssertEqual(SNumber(5).squareRoot(), 2)
        XCTAssertEqual(SNumber(9).squareRoot(), 3)
    }

    func testGCD() {
        XCTAssertEqual(SNumber(12).greatestCommonDivisor(with: 15), 3)
        XCTAssertEqual(SNumber(-12).greatestCommonDivisor(with: 15), 3)
        XCTAssertEqual(SNumber(12).greatestCommonDivisor(with: -15), 3)
        XCTAssertEqual(SNumber(-12).greatestCommonDivisor(with: -15), 3)
    }

    func testInverse() {
        for base in -100 ... 100 {
            for modulus in [2, 3, 4, 5] {
                let base = SNumber(base)
                let modulus = SNumber(modulus)
                if let inverse = base.inverse(modulus) {
                    XCTAssertEqual((base * inverse).modulus(modulus), 1, "\(base), \(modulus), \(inverse)")
                }
                else {
                    XCTAssertGreaterThan(SNumber(base).greatestCommonDivisor(with: modulus), 1, "\(base), \(modulus)")
                }
            }
        }
    }

    func testPrimes() {
        XCTAssertFalse(SNumber(-7).isPrime())
        XCTAssertTrue(SNumber(103).isPrime())

        XCTAssertFalse(SNumber(-3_215_031_751).isStrongProbablePrime(7))
        XCTAssertTrue(SNumber(3_215_031_751).isStrongProbablePrime(7))
        XCTAssertFalse(SNumber(3_215_031_751).isPrime())
    }

    func testShifts() {
        XCTAssertEqual(SNumber(1) << Word.bitWidth, SNumber(words: [0, 1]))
        XCTAssertEqual(SNumber(-1) << Word.bitWidth, SNumber(words: [0, Word.max]))
        XCTAssertEqual(SNumber(words: [0, 1]) << -Word.bitWidth, SNumber(1))

        XCTAssertEqual(SNumber(words: [0, 1]) >> Word.bitWidth, SNumber(1))
        XCTAssertEqual(SNumber(-1) >> Word.bitWidth, SNumber(-1))
        XCTAssertEqual(SNumber(1) >> Word.bitWidth, SNumber(0))
        XCTAssertEqual(SNumber(words: [0, Word.max]) >> Word.bitWidth, SNumber(-1))
        XCTAssertEqual(SNumber(1) >> -Word.bitWidth, SNumber(words: [0, 1]))

        XCTAssertEqual(SNumber(1) &<< SNumber(Word.bitWidth), SNumber(words: [0, 1]))
        XCTAssertEqual(SNumber(words: [0, 1]) &>> SNumber(Word.bitWidth), SNumber(1))
    }

    func testShiftAssignments() {

        var a: SNumber = 1
        a <<= Word.bitWidth
        XCTAssertEqual(a, SNumber(words: [0, 1]))

        a = -1
        a <<= Word.bitWidth
        XCTAssertEqual(a, SNumber(words: [0, Word.max]))

        a = SNumber(words: [0, 1])
        a <<= -Word.bitWidth
        XCTAssertEqual(a, 1)

        a = SNumber(words: [0, 1])
        a >>= Word.bitWidth
        XCTAssertEqual(a, 1)

        a = -1
        a >>= Word.bitWidth
        XCTAssertEqual(a, -1)

        a = 1
        a >>= Word.bitWidth
        XCTAssertEqual(a, 0)

        a = SNumber(words: [0, Word.max])
        a >>= Word.bitWidth
        XCTAssertEqual(a, SNumber(-1))

        a = 1
        a >>= -Word.bitWidth
        XCTAssertEqual(a, SNumber(words: [0, 1]))

        a = 1
        a &<<= SNumber(Word.bitWidth)
        XCTAssertEqual(a, SNumber(words: [0, 1]))

        a = SNumber(words: [0, 1])
        a &>>= SNumber(Word.bitWidth)
        XCTAssertEqual(a, SNumber(1))

    }

    func testCodable() {
        func test(_ a: SNumber, file: StaticString = #file, line: UInt = #line) {
            do {
                let json = try JSONEncoder().encode(a)
                print(String(data: json, encoding: .utf8)!)
                let b = try JSONDecoder().decode(SNumber.self, from: json)
                XCTAssertEqual(a, b, file: file, line: line)
            }
            catch let error {
                XCTFail("Error thrown: \(error.localizedDescription)", file: file, line: line)
            }
        }
        test(0)
        test(1)
        test(-1)
        test(0x0102030405060708)
        test(-0x0102030405060708)
        test(SNumber(1) << 64)
        test(-SNumber(1) << 64)
        test(SNumber(words: [1, 2, 3, 4, 5, 6, 7]))
        test(-SNumber(words: [1, 2, 3, 4, 5, 6, 7]))

        XCTAssertThrowsError(try JSONDecoder().decode(SNumber.self, from: "\"zz\"".data(using: .utf8)!)) { error in
            guard let error = error as? DecodingError else { XCTFail("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { XCTFail("Expected a dataCorrupted error"); return }
            XCTAssertEqual(context.debugDescription, "Invalid number")
        }
    }

    func testDecodableFromInt() {
        func test(_ a: Int, file: StaticString = #file, line: UInt = #line) {
            do {
                let b = try JSONDecoder().decode(SNumber.self, from: "\(a)".data(using: .utf8)!)
                XCTAssertEqual(SNumber(a), b, file: file, line: line)

            }
            catch let error {
                XCTFail("Error thrown: \(error.localizedDescription)", file: file, line: line)
            }
        }
        test(0)
        test(1)
        test(-1)
        test(-44444444)
    }

    func testDescription() {
        XCTAssertEqual(SNumber(0).description, "0")
        XCTAssertEqual(SNumber(1).description, "1")
        XCTAssertEqual(SNumber(-1).description, "-1")
        XCTAssertEqual(SNumber(-44444444).description, "-44444444")
    }

    func testDebugDescription() {
        XCTAssertEqual(SNumber(0).debugDescription, "SNumber(\"0\")")
        XCTAssertEqual(SNumber(1).debugDescription, "SNumber(\"1\")")
        XCTAssertEqual(SNumber(-1).debugDescription, "SNumber(\"-1\")")
        XCTAssertEqual(SNumber(-44444444).debugDescription, "SNumber(\"-44444444\")")
    }

    func testFromLiterals() {
        XCTAssertEqual(SNumber(0), 0)
        XCTAssertEqual(SNumber(1), 1)
        XCTAssertEqual(SNumber(-1), -1)
        XCTAssertEqual(SNumber(100), "100")
        XCTAssertEqual(SNumber(-100), "-100")
    }
    
    func testConversionToData() {
        func test(_ b: SNumber, _ d: Array<UInt8>, file: StaticString = #file, line: UInt = #line) {
            let expected = Data(d)
            let actual = b.serialize()
            XCTAssertEqual(actual, expected, file: file, line: line)
            XCTAssertEqual(SNumber(actual), b, file: file, line: line)
        }
        
        // Positive integers
        test(SNumber(), [])
        test(SNumber(1), [0x00, 0x01])
        test(SNumber(2), [0x00, 0x02])
        test(SNumber(0x0102030405060708), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(SNumber(0x01) << 64 + SNumber(0x0203040506070809), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])
        
        // Negative integers
        test(SNumber(), [])
        test(SNumber(-1), [0x01, 0x01])
        test(SNumber(-2), [0x01, 0x02])
        test(SNumber(0x0102030405060708) * SNumber(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test((SNumber(0x01) << 64 + SNumber(0x0203040506070809)) * SNumber(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])

    }

    func testConversionsToNumber() {
        let number = SNumber(123456789)
        let number2 = number.asNumber
        XCTAssertEqual(number2, Number(123456789))

        let number3 = SNumber(-10)
        XCTAssertThrowsError(try number3.toNumber()) { error in
            XCTAssertEqual(error as? SNumber.ConversionError, SNumber.ConversionError.sNumberNegative)
        }
    }

    func testConversionsToInt() {
        let number = SNumber(123456789)
        let int = try? number.toInt()
        XCTAssertEqual(int, 123456789)

        let number2 = SNumber(-123456789)
        let int2 = try? number2.toInt()
        XCTAssertEqual(int2, -123456789)

        let number3 = SNumber("99999999999999999999999999999999999999999999999999999999")
        XCTAssertThrowsError(try number3.toInt()) { error in
            XCTAssertEqual(error as? SNumber.ConversionError, SNumber.ConversionError.sNumberTooLarge)
        }

        let number4 = SNumber("-99999999999999999999999999999999999999999999999999999999")
        XCTAssertThrowsError(try number4.toInt()) { error in
            XCTAssertEqual(error as? SNumber.ConversionError, SNumber.ConversionError.sNumberTooSmall)
        }
    }

    func testPow10() {
        let number = SNumber.pow10(18)
        XCTAssertEqual(number, SNumber("1000000000000000000"))

        let number2 = SNumber(.pow10(18))
        XCTAssertEqual(number2, SNumber("1000000000000000000"))
    }
}
