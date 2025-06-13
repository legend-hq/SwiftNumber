//
//  Square Root.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

//MARK: Square Root

extension Number {
    /// Returns the integer square root of a big integer; i.e., the largest integer whose square isn't greater than `value`.
    ///
    /// - Returns: floor(sqrt(self))
    public func squareRoot() -> Number {
        // This implementation uses Newton's method.
        guard !self.isZero else { return Number() }
        var x = Number(1) << ((self.bitWidth + 1) / 2)
        var y: Number = 0
        while true {
            y.load(self)
            y /= x
            y += x
            y >>= 1
            if x == y || x == y - 1 { break }
            x = y
        }
        return x
    }
}

extension SNumber {
    /// Returns the integer square root of a big integer; i.e., the largest integer whose square isn't greater than `value`.
    ///
    /// - Requires: self >= 0
    /// - Returns: floor(sqrt(self))
    public func squareRoot() -> SNumber {
        precondition(self.sign == .plus)
        return SNumber(sign: .plus, magnitude: self.magnitude.squareRoot())
    }
}
