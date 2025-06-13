// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import SwiftNumber

// swiftlint:disable file_length

private typealias Smi = Int32
private typealias Word = SNumber.Word

class SNumberCOWTests: XCTestCase {

  // This can't be '1' because 'n *= 1 -> n' (which is one of our test cases)
  private let smiValue = SNumber(2)
  private let heapValue = SNumber(Word.max)
  private let shiftCount = 3

  // MARK: - Plus

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_plus_doesNotModifyOriginal() {
    // +smi
    var value = SNumber(Smi.max)
    _ = +value
    XCTAssertEqual(value, SNumber(Smi.max))

    // +heap
    value = SNumber(Word.max)
    _ = +value
    XCTAssertEqual(value, SNumber(Word.max))
  }

  // MARK: - Minus

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_minus_doesNotModifyOriginal() {
    // -smi
    var value = SNumber(Smi.max)
    _ = -value
    XCTAssertEqual(value, SNumber(Smi.max))

    // -heap
    value = SNumber(Word.max)
    _ = -value
    XCTAssertEqual(value, SNumber(Word.max))
  }

  // MARK: - Invert

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_invert_doesNotModifyOriginal() {
    // ~smi
    var value = SNumber(Smi.max)
    _ = ~value
    XCTAssertEqual(value, SNumber(Smi.max))

    // ~heap
    value = SNumber(Word.max)
    _ = ~value
    XCTAssertEqual(value, SNumber(Word.max))
  }

  // MARK: - Add

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_add_toCopy_doesNotModifyOriginal() {
    // smi + smi
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy + self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi + heap
    value = SNumber(Smi.max)
    copy = value
    _ = copy + self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap + smi
    value = SNumber(Word.max)
    copy = value
    _ = copy + self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap + heap
    value = SNumber(Word.max)
    copy = value
    _ = copy + self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_add_toInout_doesNotModifyOriginal() {
    // smi + smi
    var value = SNumber(Smi.max)
    self.addSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi + heap
    value = SNumber(Smi.max)
    self.addHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap + smi
    value = SNumber(Word.max)
    self.addSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))

    // heap + heap
    value = SNumber(Word.max)
    self.addHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func addSmi(toInout value: inout SNumber) {
    _ = value + self.smiValue
  }

  private func addHeap(toInout value: inout SNumber) {
    _ = value + self.heapValue
  }

  func test_addEqual_toCopy_doesNotModifyOriginal() {
    // smi + smi
    var value = SNumber(Smi.max)
    var copy = value
    copy += self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi + heap
    value = SNumber(Smi.max)
    copy = value
    copy += self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap + smi
    value = SNumber(Word.max)
    copy = value
    copy += self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap + heap
    value = SNumber(Word.max)
    copy = value
    copy += self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_addEqual_toInout_doesModifyOriginal() {
    // smi + smi
    var value = SNumber(Smi.max)
    self.addEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // smi + heap
    value = SNumber(Smi.max)
    self.addEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap + smi
    value = SNumber(Word.max)
    self.addEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))

    // heap + heap
    value = SNumber(Word.max)
    self.addEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func addEqualSmi(toInout value: inout SNumber) {
    value += self.smiValue
  }

  private func addEqualHeap(toInout value: inout SNumber) {
    value += self.heapValue
  }

  // MARK: - Sub

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_sub_toCopy_doesNotModifyOriginal() {
    // smi - smi
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy - self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi - heap
    value = SNumber(Smi.max)
    copy = value
    _ = copy - self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap - smi
    value = SNumber(Word.max)
    copy = value
    _ = copy - self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap - heap
    value = SNumber(Word.max)
    copy = value
    _ = copy - self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_sub_toInout_doesNotModifyOriginal() {
    // smi - smi
    var value = SNumber(Smi.max)
    self.subSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi - heap
    value = SNumber(Smi.max)
    self.subHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap - smi
    value = SNumber(Word.max)
    self.subSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))

    // heap - heap
    value = SNumber(Word.max)
    self.subHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func subSmi(toInout value: inout SNumber) {
    _ = value - self.smiValue
  }

  private func subHeap(toInout value: inout SNumber) {
    _ = value - self.heapValue
  }

  func test_subEqual_toCopy_doesNotModifyOriginal() {
    // smi - smi
    var value = SNumber(Smi.max)
    var copy = value
    copy -= self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi - heap
    value = SNumber(Smi.max)
    copy = value
    copy -= self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap - smi
    value = SNumber(Word.max)
    copy = value
    copy -= self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap - heap
    value = SNumber(Word.max)
    copy = value
    copy -= self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_subEqual_toInout_doesModifyOriginal() {
    // smi - smi
    var value = SNumber(Smi.max)
    self.subEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // smi - heap
    value = SNumber(Smi.max)
    self.subEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap - smi
    value = SNumber(Word.max)
    self.subEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))

    // heap - heap
    value = SNumber(Word.max)
    self.subEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func subEqualSmi(toInout value: inout SNumber) {
    value -= self.smiValue
  }

  private func subEqualHeap(toInout value: inout SNumber) {
    value -= self.heapValue
  }

  // MARK: - Mul

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_mul_toCopy_doesNotModifyOriginal() {
    // smi * smi
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy * self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi * heap
    value = SNumber(Smi.max)
    copy = value
    _ = copy * self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap * smi
    value = SNumber(Word.max)
    copy = value
    _ = copy * self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap * heap
    value = SNumber(Word.max)
    copy = value
    _ = copy * self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_mul_toInout_doesNotModifyOriginal() {
    // smi * smi
    var value = SNumber(Smi.max)
    self.mulSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi * heap
    value = SNumber(Smi.max)
    self.mulHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap * smi
    value = SNumber(Word.max)
    self.mulSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))

    // heap * heap
    value = SNumber(Word.max)
    self.mulHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func mulSmi(toInout value: inout SNumber) {
    _ = value * self.smiValue
  }

  private func mulHeap(toInout value: inout SNumber) {
    _ = value * self.heapValue
  }

  func test_mulEqual_toCopy_doesNotModifyOriginal() {
    // smi * smi
    var value = SNumber(Smi.max)
    var copy = value
    copy *= self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi * heap
    value = SNumber(Smi.max)
    copy = value
    copy *= self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap * smi
    value = SNumber(Word.max)
    copy = value
    copy *= self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap * heap
    value = SNumber(Word.max)
    copy = value
    copy *= self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_mulEqual_toInout_doesModifyOriginal() {
    // smi * smi
    var value = SNumber(Smi.max)
    self.mulEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // smi * heap
    value = SNumber(Smi.max)
    self.mulEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap * smi
    value = SNumber(Word.max)
    self.mulEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))

    // heap * heap
    value = SNumber(Word.max)
    self.mulEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func mulEqualSmi(toInout value: inout SNumber) {
    value *= self.smiValue
  }

  private func mulEqualHeap(toInout value: inout SNumber) {
    value *= self.heapValue
  }

  // MARK: - Div

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_div_toCopy_doesNotModifyOriginal() {
    // smi / smi
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy / self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi / heap
    value = SNumber(Smi.max)
    copy = value
    _ = copy / self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap / smi
    value = SNumber(Word.max)
    copy = value
    _ = copy / self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap / heap
    value = SNumber(Word.max)
    copy = value
    _ = copy / self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_div_toInout_doesNotModifyOriginal() {
    // smi / smi
    var value = SNumber(Smi.max)
    self.divSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi / heap
    value = SNumber(Smi.max)
    self.divHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap / smi
    value = SNumber(Word.max)
    self.divSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))

    // heap / heap
    value = SNumber(Word.max)
    self.divHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func divSmi(toInout value: inout SNumber) {
    _ = value / self.smiValue
  }

  private func divHeap(toInout value: inout SNumber) {
    _ = value / self.heapValue
  }

  func test_divEqual_toCopy_doesNotModifyOriginal() {
    // smi / smi
    var value = SNumber(Smi.max)
    var copy = value
    copy /= self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi / heap
    value = SNumber(Smi.max)
    copy = value
    copy /= self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap / smi
    value = SNumber(Word.max)
    copy = value
    copy /= self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap / heap
    value = SNumber(Word.max)
    copy = value
    copy /= self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_divEqual_toInout_doesModifyOriginal() {
    // smi / smi
    var value = SNumber(Smi.max)
    self.divEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // smi / heap
    value = SNumber(Smi.max)
    self.divEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap / smi
    value = SNumber(Word.max)
    self.divEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))

    // heap / heap
    value = SNumber(Word.max)
    self.divEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func divEqualSmi(toInout value: inout SNumber) {
    value /= self.smiValue
  }

  private func divEqualHeap(toInout value: inout SNumber) {
    value /= self.heapValue
  }

  // MARK: - Mod

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_mod_toCopy_doesNotModifyOriginal() {
    // smi % smi
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy % self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi % heap
    value = SNumber(Smi.max)
    copy = value
    _ = copy % self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap % smi
    value = SNumber(Word.max)
    copy = value
    _ = copy % self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap % heap
    value = SNumber(Word.max)
    copy = value
    _ = copy % self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_mod_toInout_doesNotModifyOriginal() {
    // smi % smi
    var value = SNumber(Smi.max)
    self.modSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi % heap
    value = SNumber(Smi.max)
    self.modHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap % smi
    value = SNumber(Word.max)
    self.modSmi(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))

    // heap % heap
    value = SNumber(Word.max)
    self.modHeap(toInout: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func modSmi(toInout value: inout SNumber) {
    _ = value % self.smiValue
  }

  private func modHeap(toInout value: inout SNumber) {
    _ = value % self.heapValue
  }

  func test_modEqual_toCopy_doesNotModifyOriginal() {
    // smi % smi
    var value = SNumber(Smi.max)
    var copy = value
    copy %= self.smiValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // smi % heap
    value = SNumber(Smi.max)
    copy = value
    copy %= self.heapValue
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap % smi
    value = SNumber(Word.max)
    copy = value
    copy %= self.smiValue
    XCTAssertEqual(value, SNumber(Word.max))

    // heap % heap
    value = SNumber(Word.max)
    copy = value
    copy %= self.heapValue
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_modEqual_toInout_doesModifyOriginal() {
    // smi % smi
    var value = SNumber(Smi.max)
    self.modEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // smi % heap
    // 'heap' is always greater than 'smi', so modulo is actually equal to 'smi'
//    value = SNumber(Smi.max)
//    self.modEqualHeap(toInout: &value)
//    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap % smi
    value = SNumber(Word.max)
    self.modEqualSmi(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))

    // heap % heap
    value = SNumber(Word.max)
    self.modEqualHeap(toInout: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func modEqualSmi(toInout value: inout SNumber) {
    value %= self.smiValue
  }

  private func modEqualHeap(toInout value: inout SNumber) {
    value %= self.heapValue
  }

  // MARK: - Shift left

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_shiftLeft_copy_doesNotModifyOriginal() {
    // smi << int
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy << self.shiftCount
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap << int
    value = SNumber(Word.max)
    copy = value
    _ = copy << self.shiftCount
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_shiftLeft_inout_doesNotModifyOriginal() {
    // smi << int
    var value = SNumber(Smi.max)
    self.shiftLeft(value: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap << int
    value = SNumber(Word.max)
    self.shiftLeft(value: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func shiftLeft(value: inout SNumber) {
    _ = value << self.shiftCount
  }

  func test_shiftLeftEqual_copy_doesNotModifyOriginal() {
    // smi << int
    var value = SNumber(Smi.max)
    var copy = value
    copy <<= self.shiftCount
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap << int
    value = SNumber(Word.max)
    copy = value
    copy <<= self.shiftCount
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_shiftLeftEqual_inout_doesModifyOriginal() {
    // smi << int
    var value = SNumber(Smi.max)
    self.shiftLeftEqual(value: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap << int
    value = SNumber(Word.max)
    self.shiftLeftEqual(value: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func shiftLeftEqual(value: inout SNumber) {
    value <<= self.shiftCount
  }

  // MARK: - Shift right

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_shiftRight_copy_doesNotModifyOriginal() {
    // smi >> int
    var value = SNumber(Smi.max)
    var copy = value
    _ = copy >> self.shiftCount
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap >> int
    value = SNumber(Word.max)
    copy = value
    _ = copy >> self.shiftCount
    XCTAssertEqual(value, SNumber(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'SNumber' is immutable,
  /// the heap that is points to is not.
  func test_shiftRight_inout_doesNotModifyOriginal() {
    // smi >> int
    var value = SNumber(Smi.max)
    self.shiftRight(value: &value)
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap >> int
    value = SNumber(Word.max)
    self.shiftRight(value: &value)
    XCTAssertEqual(value, SNumber(Word.max))
  }

  private func shiftRight(value: inout SNumber) {
    _ = value >> self.shiftCount
  }

  func test_shiftRightEqual_copy_doesNotModifyOriginal() {
    // smi >> int
    var value = SNumber(Smi.max)
    var copy = value
    copy >>= self.shiftCount
    XCTAssertEqual(value, SNumber(Smi.max))

    // heap >> int
    value = SNumber(Word.max)
    copy = value
    copy >>= self.shiftCount
    XCTAssertEqual(value, SNumber(Word.max))
  }

  func test_shiftRightEqual_inout_doesModifyOriginal() {
    // smi >> int
    var value = SNumber(Smi.max)
    self.shiftRightEqual(value: &value)
    XCTAssertNotEqual(value, SNumber(Smi.max))

    // heap >> int
    value = SNumber(Word.max)
    self.shiftRightEqual(value: &value)
    XCTAssertNotEqual(value, SNumber(Word.max))
  }

  private func shiftRightEqual(value: inout SNumber) {
    value >>= self.shiftCount
  }
}
