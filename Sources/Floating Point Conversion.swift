//
//  Floating Point Conversion.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2017-08-11.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

#if canImport(Foundation)
import Foundation
#endif

extension Number {
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard source.isFinite else { return nil }
        guard !source.isZero else { self = 0; return }
        guard source.sign == .plus else { return nil }
        let value = source.rounded(.towardZero)
        guard value == source else { return nil }
        assert(value.floatingPointClass == .positiveNormal)
        assert(value.exponent >= 0)
        let significand = value.significandBitPattern
        self = (Number(1) << value.exponent) + Number(significand) >> (T.significandBitCount - Int(value.exponent))
    }

    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(exactly: source.rounded(.towardZero))!
    }

    #if canImport(Foundation)
    public init?(exactly source: Decimal) {
        guard source.exponent >= 0 else { return nil }
        self.init(commonDecimal: source)
    }

    public init?(truncating source: Decimal) {
        self.init(commonDecimal: source)
    }

    private init?(commonDecimal source: Decimal) {
        var integer = source
        if source.exponent < 0 {
            var source = source
            NSDecimalRound(&integer, &source, 0, .down)
        }

        guard !integer.isZero else { self = 0; return }
        guard integer.isFinite else { return nil }
        guard integer.sign == .plus else { return nil }
        assert(integer.floatingPointClass == .positiveNormal)

        #if os(Linux) || os(Windows)
        // `Decimal._mantissa` has an internal access level on linux, and it might get
        // deprecated in the future, so keeping the string implementation around for now.
        let significand = Number("\(integer.significand)")!
        #else
        let significand = {
            var start = Number(0)
            for (place, value) in integer.significand.mantissaParts.enumerated() {
                guard value > 0 else { continue }
                start += (1 << (place * 16)) * Number(value)
            }
            return start
        }()
        #endif
        let exponent = Number(10).power(integer.exponent)

        self = significand * exponent
    }
    #endif
}

extension SNumber {
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let magnitude = Number(exactly: source.magnitude) else { return nil }
        let sign = SNumber.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }

    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(exactly: source.rounded(.towardZero))!
    }

    #if canImport(Foundation)
    public init?(exactly source: Decimal) {
        guard let magnitude = Number(exactly: source.magnitude) else { return nil }
        let sign = SNumber.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }

    public init?(truncating source: Decimal) {
        guard let magnitude = Number(truncating: source.magnitude) else { return nil }
        let sign = SNumber.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }
    #endif
}

extension BinaryFloatingPoint where RawExponent: FixedWidthInteger, RawSignificand: FixedWidthInteger {
    public init(_ value: SNumber) {
        guard !value.isZero else { self = 0; return }
        let v = value.magnitude
        let bitWidth = v.bitWidth
        var exponent = bitWidth - 1
        let shift = bitWidth - Self.significandBitCount - 1
        var significand = value.magnitude >> (shift - 1)
        if significand[0] & 3 == 3 { // Handle rounding
            significand >>= 1
            significand += 1
            if significand.trailingZeroBitCount >= Self.significandBitCount {
                exponent += 1
            }
        }
        else {
            significand >>= 1
        }
        let bias = 1 << (Self.exponentBitCount - 1) - 1
        guard exponent <= bias else { self = Self.infinity; return }
        significand &= 1 << Self.significandBitCount - 1
        self = Self.init(sign: value.sign == .plus ? .plus : .minus,
                         exponentBitPattern: RawExponent(bias + exponent),
                         significandBitPattern: RawSignificand(significand))
    }

    public init(_ value: Number) {
        self.init(SNumber(sign: .plus, magnitude: value))
    }
}

extension SNumber.Sign {
    public init(_ sign: FloatingPointSign) {
        switch sign {
        case .plus:
            self = .plus
        case .minus:
            self = .minus
        }
    }
}

#if canImport(Foundation)
public extension Decimal {
    init(_ value: Number) {
        guard
            value < Number(exactly: Decimal.greatestFiniteMagnitude)!
        else {
            self = .greatestFiniteMagnitude
            return
        }
        guard !value.isZero else { self = 0; return }

        self.init(string: "\(value)")!
    }

    init(_ value: SNumber) {
        if value >= 0 {
            self.init(Number(value))
        } else {
            self.init(value.magnitude)
            self *= -1
        }
    }
}
#endif

#if canImport(Foundation) && !(os(Linux) || os(Windows))
private extension Decimal {
    var mantissaParts: [UInt16] {
        [
            _mantissa.0,
            _mantissa.1,
            _mantissa.2,
            _mantissa.3,
            _mantissa.4,
            _mantissa.5,
            _mantissa.6,
            _mantissa.7,
        ]
    }
}
#endif
