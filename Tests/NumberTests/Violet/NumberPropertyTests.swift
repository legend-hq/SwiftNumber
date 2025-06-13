// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import SwiftNumber

private typealias Word = SNumber.Word

class SNumberPropertyTests: XCTestCase {

  // MARK: - Description

  func test_description() {
    for int in generateIntValues(countButNotReally: 100) {
      let value = SNumber(int)
      XCTAssertEqual(value.description, int.description, "\(int)")
    }
  }

  // MARK: - Words

//  func test_words_zero() {
//    let value = SNumber(0)
//    XCTAssertWords(value, WordsTestCases.zeroWords)
//  }
//
//  func test_words_int() {
//    for (value, expected) in WordsTestCases.int {
//      let SNumber = SNumber(value)
//      XCTAssertWords(SNumber, expected)
//    }
//  }

  func test_words_multipleWords_positive() {
    for (words, expected) in WordsTestCases.heapPositive {
      let heap = SNumberPrototype(isNegative: false, words: words)
      let SNumber = heap.create()
      XCTAssertWords(SNumber, expected)
    }
  }

//  func test_words_multipleWords_negative_powerOf2() {
//    for (words, expected) in WordsTestCases.heapNegative_powerOf2 {
//      let heap = SNumberPrototype(isNegative: true, words: words)
//      let SNumber = heap.create()
//      XCTAssertWords(SNumber, expected)
//    }
//  }

  func test_words_multipleWords_negative_notPowerOf2() {
    for (words, expected) in WordsTestCases.heapNegative_notPowerOf2 {
      let heap = SNumberPrototype(isNegative: true, words: words)
      let SNumber = heap.create()
      XCTAssertWords(SNumber, expected)
    }
  }

  // MARK: - Bit width

//  func test_bitWidth_trivial() {
//    let zero = SNumber(0)
//    XCTAssertEqual(zero.bitWidth, 1) //  0 is just 0
//
//    let plus1 = SNumber(1)
//    XCTAssertEqual(plus1.bitWidth, 2) // 1 needs '0' prefix -> '01'
//
//    let minus1 = SNumber(-1)
//    XCTAssertEqual(minus1.bitWidth, 1) // -1 is just 1
//  }

  func test_bitWidth_positivePowersOf2() {
    for (int, power, expected) in BitWidthTestCases.positivePowersOf2 {
      let SNumber = SNumber(int)
      XCTAssertEqual(SNumber.bitWidth, expected, "for \(int) (2^\(power))")
    }
  }

//  func test_bitWidth_negativePowersOf2() {
//    for (int, power, expected) in BitWidthTestCases.negativePowersOf2 {
//      let SNumber = SNumber(int)
//      XCTAssertEqual(SNumber.bitWidth, expected, "for \(int) (2^\(power))")
//    }
//  }
//
//  func test_bitWidth_smiTestCases() {
//    for (value, expected) in BitWidthTestCases.smi {
//      let SNumber = SNumber(value)
//      XCTAssertEqual(SNumber.bitWidth, expected, "\(value)")
//    }
//  }

  func test_bitWidth_multipleWords_positivePowersOf2() {
    let correction = BitWidthTestCases.positivePowersOf2Correction

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth

      for (power, value) in allPositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let heap = SNumberPrototype(isNegative: false, words: words)
        let SNumber = heap.create()

        let expected = power + correction + zeroWordsBitWidth
        XCTAssertEqual(SNumber.bitWidth, expected, "\(heap)")
      }
    }
  }

//  func test_bitWidth_multipleWords_negativePowersOf2() {
//    let correction = BitWidthTestCases.negativePowersOf2Correction
//
//    for zeroWordCount in [1, 2] {
//      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
//      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth
//
//      for (power, value) in allPositivePowersOf2(type: Word.self) {
//        let words = zeroWords + [value]
//        let heap = SNumberPrototype(isNegative: true, words: words)
//        let SNumber = heap.create()
//
//        let expected = power + correction + zeroWordsBitWidth
//        XCTAssertEqual(SNumber.bitWidth, expected, "\(heap)")
//      }
//    }
//  }

  // MARK: - Trailing zero bit count

  func test_trailingZeroBitCount_zero() {
    let zero = SNumber(0)
    XCTAssertEqual(zero.trailingZeroBitCount, 0)
  }

  func test_trailingZeroBitCount_int() {
    for raw in generateIntValues(countButNotReally: 100) {
      if raw == 0 {
        continue
      }

      let int = SNumber(raw)
      let result = int.trailingZeroBitCount

      let expected = raw.trailingZeroBitCount
      XCTAssertEqual(result, expected)
    }
  }

  func test_trailingZeroBitCount_heap_nonZeroFirstWord() {
    for p in generateSNumberValues(countButNotReally: 100, maxWordCount: 3) {
      if p.isZero {
        continue
      }

      // We have separate test for numbers that have '0' last word
      if p.words[0] == 0 {
        continue
      }

      let int = p.create()
      let result = int.trailingZeroBitCount

      let expected = p.words[0].trailingZeroBitCount
      XCTAssertEqual(result, expected)
    }
  }

  func test_trailingZeroBitCount_heap_zeroFirstWord() {
    for p in generateSNumberValues(countButNotReally: 100, maxWordCount: 3) {
      if p.isZero {
        continue
      }

      guard p.words.count > 1 else {
        continue
      }

      var words = p.words
      words[0] = 0

      let heap = SNumberPrototype(isNegative: p.isNegative, words: words)
      let int = heap.create()
      let result = int.trailingZeroBitCount

      let expected = Word.bitWidth + p.words[1].trailingZeroBitCount
      XCTAssertEqual(result, expected)
    }
  }

  // MARK: - Magnitude

  func test_magnitude_int() {
    for raw in generateIntValues(countButNotReally: 100) {
      let int = SNumber(raw)
      let magnitude = int.magnitude

      let expected = raw.magnitude
      XCTAssert(magnitude == expected, "\(raw)")
    }
  }

  func test_magnitude_heap() {
    for p in generateSNumberValues(countButNotReally: 100) {
      if p.isZero {
        continue
      }

      let positiveHeap = SNumberPrototype(isNegative: false, words: p.words)
      let positive = positiveHeap.create()

      let negativeHeap = SNumberPrototype(isNegative: true, words: p.words)
      let negative = negativeHeap.create()

      XCTAssertEqual(positive.magnitude, negative.magnitude)
    }
  }
}
