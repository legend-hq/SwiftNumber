//
//  Number+Pow10.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

public extension Number {
    static func pow10(_ decimals: Int) -> Number {
        Number(10).power(decimals)
    }
}
