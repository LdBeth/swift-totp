import Foundation

func counter() -> UInt64 {
    return UInt64(Date().timeIntervalSince1970 / 30)
}
