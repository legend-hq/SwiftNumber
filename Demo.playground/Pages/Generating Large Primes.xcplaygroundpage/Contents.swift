//: [Previous](@previous)
import Foundation
import SwiftNumber
//: # Generating Large Prime Numbers
//:
//: `Number` has an `isPrime()` method that does a [Miller-Rabin Primality Test][mrpt]. Let's use
//: this to create a function that finds the next prime number after any integer:
//:
//: [mrpt]: https://en.wikipedia.org/wiki/Miller%2dRabin_primality_test
func findNextPrime(after integer: Number) -> Number {
    var candidate = integer
    repeat {
        candidate += 1
    } while !candidate.isPrime()
    return candidate
}

findNextPrime(after: 100)
findNextPrime(after: 1000)
findNextPrime(after: 10000)
findNextPrime(after: 100000000000)
findNextPrime(after: Number(1) << 64)
findNextPrime(after: Number(1) << 128)
findNextPrime(after: Number(1) << 256)
//: [Next](@next)
