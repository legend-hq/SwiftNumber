#if os(Android)

  import Foundation

  public typealias Mantissa = (UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16)

  extension Decimal {
    public var _mantissa: Mantissa {
      self.storage.mantissa
    }

    private struct UnsafeDecimal {
      struct Storage {
        var exponent: Int8
        var lengthFlagsAndReserved: UInt8
        var reserved: UInt16
        var mantissa: Mantissa
      }

      var storage: Storage
    }

    private var storage: UnsafeDecimal.Storage {
      unsafeBitCast(self, to: UnsafeDecimal.self).storage
    }
  }

#endif
