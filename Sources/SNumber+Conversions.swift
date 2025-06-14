//
//  SNumber+Conversions.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

public extension SNumber {
    enum ConversionError: Error {
        case sNumberNegative
        case sNumberTooLarge
        case sNumberTooSmall
    }

    /// Returns a Number, throwing on conversion failure
    func toNumber() throws -> Number {
        guard self >= 0 else {
            throw ConversionError.sNumberNegative
        }
        return Number(self)
    }

    /// Returns a Number, panicking on conversion failure
    var asNumber: Number {
        Number(self)
    }

    /// Returns an Int, throwing on conversion failure
    func toInt() throws -> Int {
        guard self <= SNumber(Int.max) else {
            throw ConversionError.sNumberTooLarge
        }
        guard self >= SNumber(Int.min) else {
            throw ConversionError.sNumberTooSmall
        }
        return Int(self)
    }
}
