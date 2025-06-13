//
//  SNumber.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2015-12-27.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

//MARK: SNumber

/// An arbitary precision signed integer type, also known as a "big integer".
///
/// Operations on big integers never overflow, but they might take a long time to execute.
/// The amount of memory (and address space) available is the only constraint to the magnitude of these numbers.
///
/// This particular big integer type uses base-2^64 digits to represent integers.
///
/// `SNumber` is essentially a tiny wrapper that extends `Number` with a sign bit and provides signed integer
/// operations. Both the underlying absolute value and the negative/positive flag are available as read-write 
/// properties.
///
/// Not all algorithms of `Number` are available for `SNumber` values; for example, there is no square root or
/// primality test for signed integers. When you need to call one of these, just extract the absolute value:
///
/// ```Swift
/// SNumber(255).magnitude.isPrime()   // Returns false
/// ```
///
public struct SNumber: SignedInteger, Sendable {
    public enum Sign: Sendable {
        case plus
        case minus
    }

    public typealias Magnitude = Number

    /// The type representing a digit in `SNumber`'s underlying number system.
    public typealias Word = Number.Word
    
    public static var isSigned: Bool {
        return true
    }

    /// The absolute value of this integer.
    public var magnitude: Number

    /// True iff the value of this integer is negative.
    public var sign: Sign

    /// Initializes a new big integer with the provided absolute number and sign flag.
    public init(sign: Sign, magnitude: Number) {
        self.sign = (magnitude.isZero ? .plus : sign)
        self.magnitude = magnitude
    }

    /// Return true iff this integer is zero.
    ///
    /// - Complexity: O(1)
    public var isZero: Bool {
        return magnitude.isZero
    }

    /// Returns `-1` if this value is negative and `1` if it’s positive; otherwise, `0`.
    ///
    /// - Returns: The sign of this number, expressed as an integer of the same type.
    public func signum() -> SNumber {
        switch sign {
        case .plus:
            return isZero ? 0 : 1
        case .minus:
            return -1
        }
    }
}
