//
//  Shifts.swift
//  SwiftNumber
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Modified by Legend on 2025-06-13.
//  Copyright © 2016-2017 Károly Lőrentey.
//  Copyright © 2025 Legend Labs, Inc.
//

extension Number {

    //MARK: Shift Operators
    
    internal func shiftedLeft(by amount: Word) -> Number {
        guard amount > 0 else { return self }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let up = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up
        
        var result = Number()
        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < self.count || lowbits > 0 {
                let word = self[i]
                result[i + ext] = word << up | lowbits
                lowbits = word >> down
                i += 1
            }
        }
        else {
            for i in 0 ..< self.count {
                result[i + ext] = self[i]
            }
        }
        return result
    }
    
    internal mutating func shiftLeft(by amount: Word) {
        guard amount > 0 else { return }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let up = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up
        
        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < self.count || lowbits > 0 {
                let word = self[i]
                self[i] = word << up | lowbits
                lowbits = word >> down
                i += 1
            }
        }
        if ext > 0 && self.count > 0 {
            self.shiftLeft(byWords: ext)
        }
    }
    
    internal func shiftedRight(by amount: Word) -> Number {
        guard amount > 0 else { return self }
        guard amount < self.bitWidth else { return 0 }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let down = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let up = Word(Word.bitWidth) - down
        
        var result = Number()
        if down > 0 {
            var highbits: Word = 0
            for i in (ext ..< self.count).reversed() {
                let word = self[i]
                result[i - ext] = highbits | word >> down
                highbits = word << up
            }
        }
        else {
            for i in (ext ..< self.count).reversed() {
                result[i - ext] = self[i]
            }
        }
        return result
    }

    internal mutating func shiftRight(by amount: Word) {
        guard amount > 0 else { return }
        guard amount < self.bitWidth else { self.clear(); return }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let down = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let up = Word(Word.bitWidth) - down
        
        if ext > 0 {
            self.shiftRight(byWords: ext)
        }
        if down > 0 {
            var i = self.count - 1
            var highbits: Word = 0
            while i >= 0 {
                let word = self[i]
                self[i] = highbits | word >> down
                highbits = word << up
                i -= 1
            }
        }
    }
    
    public static func >>=<Other: BinaryInteger>(lhs: inout Number, rhs: Other) {
        if rhs < (0 as Other) {
            lhs <<= (0 - rhs)
        }
        else if rhs >= lhs.bitWidth {
            lhs.clear()
        }
        else {
            lhs.shiftRight(by: UInt(rhs))
        }
    }
    
    public static func <<=<Other: BinaryInteger>(lhs: inout Number, rhs: Other) {
        if rhs < (0 as Other) {
            lhs >>= (0 - rhs)
            return
        }
        lhs.shiftLeft(by: Word(exactly: rhs)!)
    }

    public static func >><Other: BinaryInteger>(lhs: Number, rhs: Other) -> Number {
        if rhs < (0 as Other) {
            return lhs << (0 - rhs)
        }
        if rhs > Word.max {
            return 0
        }
        return lhs.shiftedRight(by: UInt(rhs))
    }

    public static func <<<Other: BinaryInteger>(lhs: Number, rhs: Other) -> Number {
        if rhs < (0 as Other) {
            return lhs >> (0 - rhs)
        }
        return lhs.shiftedLeft(by: Word(exactly: rhs)!)
    }
}

extension SNumber {
    func shiftedLeft(by amount: Word) -> SNumber {
        return SNumber(sign: self.sign, magnitude: self.magnitude.shiftedLeft(by: amount))
    }
    
    mutating func shiftLeft(by amount: Word) {
        self.magnitude.shiftLeft(by: amount)
    }
    
    func shiftedRight(by amount: Word) -> SNumber {
        let m = self.magnitude.shiftedRight(by: amount)
        return SNumber(sign: self.sign, magnitude: self.sign == .minus && m.isZero ? 1 : m)
    }
    
    mutating func shiftRight(by amount: Word) {
        magnitude.shiftRight(by: amount)
        if sign == .minus, magnitude.isZero {
            magnitude.load(1)
        }
    }
    
    public static func &<<(left: SNumber, right: SNumber) -> SNumber {
        return left.shiftedLeft(by: right.words[0])
    }
    
    public static func &<<=(left: inout SNumber, right: SNumber) {
        left.shiftLeft(by: right.words[0])
    }
    
    public static func &>>(left: SNumber, right: SNumber) -> SNumber {
        return left.shiftedRight(by: right.words[0])
    }
    
    public static func &>>=(left: inout SNumber, right: SNumber) {
        left.shiftRight(by: right.words[0])
    }
    
    public static func <<<Other: BinaryInteger>(lhs: SNumber, rhs: Other) -> SNumber {
        guard rhs >= (0 as Other) else { return lhs >> (0 - rhs) }
        return lhs.shiftedLeft(by: Word(rhs))
    }
    
    public static func <<=<Other: BinaryInteger>(lhs: inout SNumber, rhs: Other) {
        if rhs < (0 as Other) {
            lhs >>= (0 - rhs)
        }
        else {
            lhs.shiftLeft(by: Word(rhs))
        }
    }
    
    public static func >><Other: BinaryInteger>(lhs: SNumber, rhs: Other) -> SNumber {
        guard rhs >= (0 as Other) else { return lhs << (0 - rhs) }
        return lhs.shiftedRight(by: Word(rhs))
    }
    
    public static func >>=<Other: BinaryInteger>(lhs: inout SNumber, rhs: Other) {
        if rhs < (0 as Other) {
            lhs <<= (0 - rhs)
        }
        else {
            lhs.shiftRight(by: Word(rhs))
        }
    }
}
