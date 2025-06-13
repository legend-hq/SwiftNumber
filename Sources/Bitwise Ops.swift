//
//  Bitwise Ops.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

//MARK: Bitwise Operations

extension Number {
    /// Return the ones' complement of `a`.
    ///
    /// - Complexity: O(a.count)
    public static prefix func ~(a: Number) -> Number {
        return Number(words: a.words.map { ~$0 })
    }

    /// Calculate the bitwise OR of `a` and `b`, and store the result in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func |= (a: inout Number, b: Number) {
        a.reserveCapacity(b.count)
        for i in 0 ..< b.count {
            a[i] |= b[i]
        }
    }

    /// Calculate the bitwise AND of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func &= (a: inout Number, b: Number) {
        for i in 0 ..< Swift.max(a.count, b.count) {
            a[i] &= b[i]
        }
    }

    /// Calculate the bitwise XOR of `a` and `b` and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func ^= (a: inout Number, b: Number) {
        a.reserveCapacity(b.count)
        for i in 0 ..< b.count {
            a[i] ^= b[i]
        }
    }
}

extension SNumber {
    public static prefix func ~(x: SNumber) -> SNumber {
        switch x.sign {
        case .plus:
            return SNumber(sign: .minus, magnitude: x.magnitude + 1)
        case .minus:
            return SNumber(sign: .plus, magnitude: x.magnitude - 1)
        }
    }
    
    public static func &(lhs: inout SNumber, rhs: SNumber) -> SNumber {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] & right[i])
        }
        if lhs.sign == .minus && rhs.sign == .minus {
            words.twosComplement()
            return SNumber(sign: .minus, magnitude: Number(words: words))
        }
        return SNumber(sign: .plus, magnitude: Number(words: words))
    }
    
    public static func |(lhs: inout SNumber, rhs: SNumber) -> SNumber {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] | right[i])
        }
        if lhs.sign == .minus || rhs.sign == .minus {
            words.twosComplement()
            return SNumber(sign: .minus, magnitude: Number(words: words))
        }
        return SNumber(sign: .plus, magnitude: Number(words: words))
    }
    
    public static func ^(lhs: inout SNumber, rhs: SNumber) -> SNumber {
        let left = lhs.words
        let right = rhs.words
        // Note we aren't using left.count/right.count here; we account for the sign bit separately later.
        let count = Swift.max(lhs.magnitude.count, rhs.magnitude.count)
        var words: [UInt] = []
        words.reserveCapacity(count)
        for i in 0 ..< count {
            words.append(left[i] ^ right[i])
        }
        if (lhs.sign == .minus) != (rhs.sign == .minus) {
            words.twosComplement()
            return SNumber(sign: .minus, magnitude: Number(words: words))
        }
        return SNumber(sign: .plus, magnitude: Number(words: words))
    }
    
    public static func &=(lhs: inout SNumber, rhs: SNumber) {
        lhs = lhs & rhs
    }
    
    public static func |=(lhs: inout SNumber, rhs: SNumber) {
        lhs = lhs | rhs
    }
    
    public static func ^=(lhs: inout SNumber, rhs: SNumber) {
        lhs = lhs ^ rhs
    }
}
