// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import SwiftNumber

private typealias Word = SNumber.Word

/// This class tests `SNumber -> Swift.Integer` inits!
/// Our `SNumber.inits` are quite trivial (because we can represent any number),
/// so we will not test them.
class SNumberIntegerInitTests: XCTestCase {

  // MARK: - Exactly

  func test_exactly_signed() {
    self.exactly_inRange(type: Int8.self)
    self.exactly_inRange(type: Int16.self)
    self.exactly_inRange(type: Int32.self)
    self.exactly_inRange(type: Int64.self)
    self.exactly_inRange(type: Int.self)
  }

  func test_exactly_unsigned() {
    self.exactly_inRange(type: UInt8.self)
    self.exactly_inRange(type: UInt16.self)
    self.exactly_inRange(type: UInt32.self)
    self.exactly_inRange(type: UInt64.self)
    self.exactly_inRange(type: UInt.self)
  }

  private func exactly_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let SNumber = SNumber(value)

      // String representation should be equal - trivial test for value
      let SNumberString = String(SNumber, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(SNumberString, valueString, "\(header) - String", file: file, line: line)

      // T -> SNumber -> T
      if let revert = T(exactly: SNumber) {
        let msg = "\(header) - \(typeName) -> SNumber -> \(typeName)"
        XCTAssertEqual(value, revert, msg, file: file, line: line)
      } else {
        XCTFail("\(header) - failed SNumber -> \(typeName)", file: file, line: line)
      }
    }
  }

  func test_exactly_signed_biggerThanMax_returnsNil() {
    self.exactly_biggerThanMax(type: Int8.self)
    self.exactly_biggerThanMax(type: Int16.self)
    self.exactly_biggerThanMax(type: Int32.self)
    self.exactly_biggerThanMax(type: Int64.self)
    self.exactly_biggerThanMax(type: Int.self)
  }

  func test_exactly_unsigned_biggerThanMax_returnsNil() {
    self.exactly_biggerThanMax(type: UInt8.self)
    self.exactly_biggerThanMax(type: UInt16.self)
    self.exactly_biggerThanMax(type: UInt32.self)
    self.exactly_biggerThanMax(type: UInt64.self)
    self.exactly_biggerThanMax(type: UInt.self)
  }

  private func exactly_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let max = type.max

    var maxPlus1 = SNumber(max)
    maxPlus1 += 1
    XCTAssertNil(T(exactly: maxPlus1), "\(max) + 1", file: file, line: line)

    let moreWordsHeap = SNumberPrototype(isNegative: false, words: [0, 1])
    let moreWords = moreWordsHeap.create()
    XCTAssertNil(T(exactly: moreWords), "\(moreWordsHeap)", file: file, line: line)
  }

  func test_exactly_signed_lessThanMin_returnsNil() {
    self.exactly_lessThanMin(type: Int8.self)
    self.exactly_lessThanMin(type: Int16.self)
    self.exactly_lessThanMin(type: Int32.self)
    self.exactly_lessThanMin(type: Int64.self)
    self.exactly_lessThanMin(type: Int.self)
  }

  func test_exactly_unsigned_lessThanMin_returnsNil() {
    self.exactly_lessThanMin(type: UInt8.self)
    self.exactly_lessThanMin(type: UInt16.self)
    self.exactly_lessThanMin(type: UInt32.self)
    self.exactly_lessThanMin(type: UInt64.self)
    self.exactly_lessThanMin(type: UInt.self)
  }

  private func exactly_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let min = type.min

    var minMinus1 = SNumber(min)
    minMinus1 -= 1
    XCTAssertNil(T(exactly: minMinus1), "\(min) - 1", file: file, line: line)

    let moreWordsHeap = SNumberPrototype(isNegative: true, words: [0, 1])
    let moreWords = moreWordsHeap.create()
    XCTAssertNil(T(exactly: moreWords), "\(moreWordsHeap)", file: file, line: line)
  }

  // MARK: - Clamping

  func test_clamping_signed() {
    self.clamping_inRange(type: Int8.self)
    self.clamping_inRange(type: Int16.self)
    self.clamping_inRange(type: Int32.self)
    self.clamping_inRange(type: Int64.self)
    self.clamping_inRange(type: Int.self)
  }

  func test_clamping_unsigned() {
    self.clamping_inRange(type: UInt8.self)
    self.clamping_inRange(type: UInt16.self)
    self.clamping_inRange(type: UInt32.self)
    self.clamping_inRange(type: UInt64.self)
    self.clamping_inRange(type: UInt.self)
  }

  private func clamping_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {

    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let SNumber = SNumber(value)

      // String representation should be equal - trivial test for value
      let SNumberString = String(SNumber, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(SNumberString, valueString, "\(header) - String", file: file, line: line)

      // T -> SNumber -> T
      let revert = T(clamping: SNumber)
      let msg = "\(header) - \(typeName) -> SNumber -> \(typeName)"
      XCTAssertEqual(value, revert, msg, file: file, line: line)
    }
  }

  func test_clamping_signed_biggerThanMax_returnsNil() {
    self.clamping_biggerThanMax(type: Int8.self)
    self.clamping_biggerThanMax(type: Int16.self)
    self.clamping_biggerThanMax(type: Int32.self)
    self.clamping_biggerThanMax(type: Int64.self)
    self.clamping_biggerThanMax(type: Int.self)
  }

  func test_clamping_unsigned_biggerThanMax_returnsNil() {
    self.clamping_biggerThanMax(type: UInt8.self)
    self.clamping_biggerThanMax(type: UInt16.self)
    self.clamping_biggerThanMax(type: UInt32.self)
    self.clamping_biggerThanMax(type: UInt64.self)
    self.clamping_biggerThanMax(type: UInt.self)
  }

  private func clamping_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = SNumber(maxT)

    do {
      let maxPlus1 = max + 1
      let clamped = T(clamping: maxPlus1)
      let clampedSNumber = SNumber(clamped)
      XCTAssertEqual(clampedSNumber, max, "\(max) + 1", file: file, line: line)
    }

    do {
      let moreWordsHeap = SNumberPrototype(isNegative: false, words: [0, 1])
      let moreWords = moreWordsHeap.create()

      let clamped = T(clamping: moreWords)
      let clampedSNumber = SNumber(clamped)
      XCTAssertEqual(clampedSNumber, max, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  func test_clamping_signed_lessThanMin_returnsNil() {
    self.clamping_lessThanMin(type: Int8.self)
    self.clamping_lessThanMin(type: Int16.self)
    self.clamping_lessThanMin(type: Int32.self)
    self.clamping_lessThanMin(type: Int64.self)
    self.clamping_lessThanMin(type: Int.self)
  }

  func test_clamping_unsigned_lessThanMin_returnsNil() {
    self.clamping_lessThanMin(type: UInt8.self)
    self.clamping_lessThanMin(type: UInt16.self)
    self.clamping_lessThanMin(type: UInt32.self)
    self.clamping_lessThanMin(type: UInt64.self)
    self.clamping_lessThanMin(type: UInt.self)
  }

  private func clamping_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let minT = type.min
    let min = SNumber(minT)

    do {
      let minMinus1 = min - 1
      let clamped = T(clamping: minMinus1)
      let clampedSNumber = SNumber(clamped)
      XCTAssertEqual(clampedSNumber, min, "\(min) - 1", file: file, line: line)
    }

    do {
      let moreWordsHeap = SNumberPrototype(isNegative: true, words: [0, 1])
      let moreWords = moreWordsHeap.create()

      let clamped = T(clamping: moreWords)
      let clampedSNumber = SNumber(clamped)
      XCTAssertEqual(clampedSNumber, min, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  // MARK: - Truncating if needed

  func test_truncatingIfNeeded_signed() {
    self.truncatingIfNeeded_inRange(type: Int8.self)
    self.truncatingIfNeeded_inRange(type: Int16.self)
    self.truncatingIfNeeded_inRange(type: Int32.self)
    self.truncatingIfNeeded_inRange(type: Int64.self)
    self.truncatingIfNeeded_inRange(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned() {
    self.truncatingIfNeeded_inRange(type: UInt8.self)
    self.truncatingIfNeeded_inRange(type: UInt16.self)
    self.truncatingIfNeeded_inRange(type: UInt32.self)
    self.truncatingIfNeeded_inRange(type: UInt64.self)
    self.truncatingIfNeeded_inRange(type: UInt.self)
  }

  private func truncatingIfNeeded_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {

    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let SNumber = SNumber(value)

      // String representation should be equal - trivial test for value
      let SNumberString = String(SNumber, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(SNumberString, valueString, "\(header) - String", file: file, line: line)

      // T -> SNumber -> T
      let revert = T(truncatingIfNeeded: SNumber)
      let msg = "\(header) - \(typeName) -> SNumber -> \(typeName)"
      XCTAssertEqual(value, revert, msg, file: file, line: line)
    }
  }

  func test_truncatingIfNeeded_signed_biggerThanMax_returnsNil() {
    self.truncatingIfNeeded_biggerThanMax(type: Int8.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int16.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int32.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int64.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned_biggerThanMax_returnsNil() {
    self.truncatingIfNeeded_biggerThanMax(type: UInt8.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt16.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt32.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt64.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt.self)
  }

  private func truncatingIfNeeded_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = SNumber(maxT)
    let minT = type.min
    let min = SNumber(minT)
    let zero = SNumber()

    do {
      // signed:   0111 + 1 =   1000 -> min
      // unsigned: 1111 + 1 = 1 0000 -> 0
      let maxPlus1 = max + 1
      let truncated = T(truncatingIfNeeded: maxPlus1)
      let truncatedSNumber = SNumber(truncated)

      let expected = T.isSigned ? min : zero
      XCTAssertEqual(truncatedSNumber, expected, "\(max) + 1", file: file, line: line)
    }

    do {
      let lowWord = Word(12)
      let moreWordsHeap = SNumberPrototype(isNegative: false, words: [lowWord, 1])
      let moreWords = moreWordsHeap.create()

      let truncated = T(truncatingIfNeeded: moreWords)
      let truncatedSNumber = SNumber(truncated)

      let expected = SNumber(lowWord)
      XCTAssertEqual(truncatedSNumber, expected, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  func test_truncatingIfNeeded_signed_lessThanMin_returnsNil() {
    self.truncatingIfNeeded_lessThanMin(type: Int8.self)
    self.truncatingIfNeeded_lessThanMin(type: Int16.self)
    self.truncatingIfNeeded_lessThanMin(type: Int32.self)
    self.truncatingIfNeeded_lessThanMin(type: Int64.self)
    self.truncatingIfNeeded_lessThanMin(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned_lessThanMin_returnsNil() {
    self.truncatingIfNeeded_lessThanMin(type: UInt8.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt16.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt32.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt64.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt.self)
  }

  private func truncatingIfNeeded_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = SNumber(maxT)
    let minT = type.min
    let min = SNumber(minT)

    do {
      // signed:   1000 - 1 = 0111 = max
      // unsigned: 0000 - 1 = 1111 = max
      let minMinus1 = min - 1
      let truncated = T(truncatingIfNeeded: minMinus1)
      let truncatedSNumber = SNumber(truncated)

      let expected = max
      XCTAssertEqual(truncatedSNumber, expected, "\(min) - 1", file: file, line: line)
    }

    do {
      // signed:   -12 = (1111) 0100 = -12
      // unsigned: -12 = (1111) 0100 = ?
      // 11110100
      let lowWord = Word(12)
      let moreWordsHeap = SNumberPrototype(isNegative: true, words: [lowWord, 1])
      let moreWords = moreWordsHeap.create()

      let truncated = T(truncatingIfNeeded: moreWords)
      let truncatedSNumber = SNumber(truncated)

      let complement = ~lowWord + 1 // no overflow possible
      let expected = SNumber(T(truncatingIfNeeded: complement))
      XCTAssertEqual(truncatedSNumber, expected, "\(moreWordsHeap)", file: file, line: line)
    }
  }
}
