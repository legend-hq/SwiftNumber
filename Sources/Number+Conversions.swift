//
//  Number+Conversions.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

public extension Number {
    enum ConversionError: Error {
        case sNumberTooLarge
    }

    var asSNumber: SNumber {
        SNumber(self)
    }

    func toInt() throws -> Int {
        guard self <= Number(Int.max) else {
            throw ConversionError.sNumberTooLarge
        }
        return Int(self)
    }
}
