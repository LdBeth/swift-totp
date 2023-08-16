import Foundation
import CryptoKit

func HMACSha1(_ input: Data, key:Data) -> Data {
    let signature = HMAC<Insecure.SHA1>.authenticationCode(
      for: input, using: SymmetricKey(data: key))
    return Data(signature)
}


extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }

    init(counter: UInt64) {
        var time = counter.bigEndian
        self = Data(bytes: &time, count: MemoryLayout<UInt64>.size)
    }

    /*
     func toBVec() -> String {
        self.map { String(format: "%d", $0) }.joined(separator:" ")
    } */
}
