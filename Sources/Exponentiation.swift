//
//  Exponentiation.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

extension Number {
    //MARK: Exponentiation

    /// Returns this integer raised to the power `exponent`.
    ///
    /// This function calculates the result by [successively squaring the base while halving the exponent][expsqr].
    ///
    /// [expsqr]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// - Note: This function can be unreasonably expensive for large exponents, which is why `exponent` is
    ///         a simple integer value. If you want to calculate big exponents, you'll probably need to use
    ///         the modulo arithmetic variant.
    /// - Returns: 1 if `exponent == 0`, otherwise `self` raised to `exponent`. (This implies that `0.power(0) == 1`.)
    /// - SeeAlso: `Number.power(_:, modulus:)`
    /// - Complexity: O((exponent * self.count)^log2(3)) or somesuch. The result may require a large amount of memory, too.
    public func power(_ exponent: Int) -> Number {
        if exponent == 0 { return 1 }
        if exponent == 1 { return self }
        if exponent < 0 {
            precondition(!self.isZero)
            return self == 1 ? 1 : 0
        }
        if self <= 1 { return self }
        var result = Number(1)
        var b = self
        var e = exponent
        while e > 0 {
            if e & 1 == 1 {
                result *= b
            }
            e >>= 1
            b *= b
        }
        return result
    }

    /// Returns the remainder of this integer raised to the power `exponent` in modulo arithmetic under `modulus`.
    ///
    /// Uses the [right-to-left binary method][rtlb].
    ///
    /// [rtlb]: https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
    ///
    /// - Complexity: O(exponent.count * modulus.count^log2(3)) or somesuch
    public func power(_ exponent: Number, modulus: Number) -> Number {
        precondition(!modulus.isZero)
        if modulus == (1 as Number) { return 0 }
        let shift = modulus.leadingZeroBitCount
        let normalizedModulus = modulus << shift
        var result = Number(1)
        var b = self
        b.formRemainder(dividingBy: normalizedModulus, normalizedBy: shift)
        for var e in exponent.words {
            for _ in 0 ..< Word.bitWidth {
                if e & 1 == 1 {
                    result *= b
                    result.formRemainder(dividingBy: normalizedModulus, normalizedBy: shift)
                }
                e >>= 1
                b *= b
                b.formRemainder(dividingBy: normalizedModulus, normalizedBy: shift)
            }
        }
        return result
    }
}

extension SNumber {
    /// Returns this integer raised to the power `exponent`.
    ///
    /// This function calculates the result by [successively squaring the base while halving the exponent][expsqr].
    ///
    /// [expsqr]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// - Note: This function can be unreasonably expensive for large exponents, which is why `exponent` is
    ///         a simple integer value. If you want to calculate big exponents, you'll probably need to use
    ///         the modulo arithmetic variant.
    /// - Returns: 1 if `exponent == 0`, otherwise `self` raised to `exponent`. (This implies that `0.power(0) == 1`.)
    /// - SeeAlso: `Number.power(_:, modulus:)`
    /// - Complexity: O((exponent * self.count)^log2(3)) or somesuch. The result may require a large amount of memory, too.
    public func power(_ exponent: Int) -> SNumber {
        return SNumber(sign: self.sign == .minus && exponent & 1 != 0 ? .minus : .plus,
                      magnitude: self.magnitude.power(exponent))
    }

    /// Returns the remainder of this integer raised to the power `exponent` in modulo arithmetic under `modulus`.
    ///
    /// Uses the [right-to-left binary method][rtlb].
    ///
    /// [rtlb]: https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
    ///
    /// - Complexity: O(exponent.count * modulus.count^log2(3)) or somesuch
    public func power(_ exponent: SNumber, modulus: SNumber) -> SNumber {
        precondition(!modulus.isZero)
        if modulus.magnitude == 1 { return 0 }
        if exponent.isZero { return 1 }
        if exponent == 1 { return self.modulus(modulus) }
        if exponent < 0 {
            precondition(!self.isZero)
            guard magnitude == 1 else { return 0 }
            guard sign == .minus else { return 1 }
            guard exponent.magnitude[0] & 1 != 0 else { return 1 }
            return SNumber(modulus.magnitude - 1)
        }
        let power = self.magnitude.power(exponent.magnitude,
                                         modulus: modulus.magnitude)
        if self.sign == .plus || exponent.magnitude[0] & 1 == 0 || power.isZero {
            return SNumber(power)
        }
        return SNumber(modulus.magnitude - power)
    }
}
