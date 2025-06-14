//
//  Number+StringAndPrecision.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

#if canImport(Foundation)
import Foundation

public extension Number {
    init?(_ value: String, andPrecision precision: Int) {
        let separator = "."

        var value = value

        if value.hasSuffix(separator) {
            value.removeLast()
        }

        guard isValidDecimal(value) else {
            return nil
        }

        guard let decimalValue = Decimal(string: value) else {
            return nil
        }

        let scaledDecimal = decimalValue * pow(10, precision)

        let scaledString = scaledDecimal.description
        let integerPart = scaledString.split(separator: separator).first.map(String.init)

        if let integerPart = integerPart, let numberValue = Number(integerPart) {
            self.init(numberValue)
        } else {
            return nil
        }
    }
}

private func isValidDecimal(_ string: String) -> Bool {
    // Check if it's a valid double
    guard let _ = Double(string) else { return false }

    // Ensure it doesn't contain invalid characters like 'e' for scientific notation
    let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
    return string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
}
#endif
