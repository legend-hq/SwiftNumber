//
//  SNumber+Pow10.swift
//  SwiftNumber
//
//  Crafted by Legend on 2025-06-13.
//  Copyright © 2025 Legend Labs, Inc.
//

public extension SNumber {
    static func pow10(_ decimals: Int) -> SNumber {
        SNumber(10).power(decimals)
    }
}
