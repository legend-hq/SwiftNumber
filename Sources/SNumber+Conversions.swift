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

    /// Returns an Int, returning nil on conversion failure
    var int: Int? {
        guard self <= SNumber(Int.max) else {
            return nil
        }
        guard self >= SNumber(Int.min) else {
            return nil
        }
        return Int(self)
    }

    /// Returns an Int, panicking on conversion failure
    var asInt: Int {
        try! toInt()
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
