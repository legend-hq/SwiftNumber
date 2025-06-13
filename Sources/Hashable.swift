//
//  Hashable.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

extension Number: Hashable {
    //MARK: Hashing

    /// Append this `Number` to the specified hasher.
    public func hash(into hasher: inout Hasher) {
        for word in self.words {
            hasher.combine(word)
        }
    }
}

extension SNumber: Hashable {
    /// Append this `SNumber` to the specified hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(sign)
        hasher.combine(magnitude)
    }
}
