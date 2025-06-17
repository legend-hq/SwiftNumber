//
//  Number+Conversions.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

public extension Number {
    enum ConversionError: Error {
        case numberTooLarge
    }

    /// Returns an SNumber, which is always safe
    var asSNumber: SNumber {
        SNumber(self)
    }

    /// Returns a UInt, returning nil on a conversion failure
    var uInt: UInt? {
        if self <= Number(UInt.max) {
            UInt(self)
        } else {
            nil
        }
    }

    /// Returns a UInt, panicking on conversion failure
    var asUInt: UInt {
        try! toUInt()
    }

    /// Returns a UInt, throwing on conversion failure
    func toUInt() throws -> UInt {
        guard self <= Number(UInt.max) else {
            throw ConversionError.numberTooLarge
        }
        return UInt(self)
    }

    /// Returns an Int, returning nil on a conversion failure
    var int: Int? {
        if self <= Number(Int.max) {
            Int(self)
        } else {
            nil
        }
    }

    /// Returns an Int, panicking on conversion failure
    var asInt: Int {
        try! toInt()
    }

    /// Returns an Int, throwing on conversion failure
    func toInt() throws -> Int {
        guard self <= Number(Int.max) else {
            throw ConversionError.numberTooLarge
        }
        return Int(self)
    }
}
