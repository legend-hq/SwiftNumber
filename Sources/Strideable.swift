//
//  Strideable.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2017-08-11.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

extension Number: Strideable {
    /// A type that can represent the distance between two values ofa `Number`.
    public typealias Stride = SNumber

    /// Adds `n` to `self` and returns the result. Traps if the result would be less than zero.
    public func advanced(by n: SNumber) -> Number {
        return n.sign == .minus ? self - n.magnitude : self + n.magnitude
    }

    /// Returns the (potentially negative) difference between `self` and `other` as a `SNumber`. Never traps.
    public func distance(to other: Number) -> SNumber {
        return SNumber(other) - SNumber(self)
    }
}

extension SNumber: Strideable {
    public typealias Stride = SNumber

    /// Returns `self + n`.
    public func advanced(by n: Stride) -> SNumber {
        return self + n
    }

    /// Returns `other - self`.
    public func distance(to other: SNumber) -> Stride {
        return other - self
    }
}


