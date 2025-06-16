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
}
