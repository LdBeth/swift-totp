// Copyright (C) 2023 by LdBeth
//
// Compute RFC 6238
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

let service = "org.sdf.ldbeth.totp"

func findPass(account: String) throws -> Data {
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecAttrService: service,
                 kSecMatchLimit: kSecMatchLimitOne,
                 kSecReturnData: true] as CFDictionary
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    return item as! Data
}

func addPass(account: String, secrete: String) throws {
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecValueData: secrete,
                 kSecAttrService: service] as CFDictionary
    let status = SecItemAdd(query, nil)
    guard status == errSecSuccess else
  { throw KeychainError.unhandledError(status: status) }
}

func rmPass(account: String) throws {
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecAttrService: service] as CFDictionary
    let status = SecItemDelete(query)
    guard status == errSecSuccess || status == errSecItemNotFound else
  { throw KeychainError.unhandledError(status: status) }
}

func queryPass() throws -> [String] {
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrService: service,
                 kSecMatchLimit: kSecMatchLimitAll,
                 kSecReturnAttributes: true] as CFDictionary
    var items: CFTypeRef?
    let status = SecItemCopyMatching(query, &items)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    let array = Array<AnyObject>(_immutableCocoaArray: items as! CFArray)
    return array.compactMap {
        let existingItem = $0 as? [String : Any]
        return existingItem?[kSecAttrAccount as String] as? String
    }
}

let argv = CommandLine.arguments
let argc = CommandLine.argc

var exitValue = EXIT_SUCCESS
do {

    switch argc {
    case 1:
        let accounts = try queryPass()
        for a in accounts {
            print(a)
        }
    case 2:
        let account = argv[1]
        let secreteData = try findPass(account: account)
        guard let secrete = String(data: secreteData, encoding: String.Encoding.utf8),
              let encKey = Data(hexString: secrete)
    else
      { throw KeychainError.unexpectedPasswordData }

        let timeData = Data(counter: counter())
        let hash = HMACSha1(timeData, key: encKey)
        
        let offset = Int(hash[19] & 0xf)

        let binary : UInt64 = (UInt64(hash[offset] & 0x7f) << 24) |
          (UInt64(hash[offset + 1] & 0xff) << 16) |
          (UInt64(hash[offset + 2] & 0xff) << 8) |
          UInt64(hash[offset + 3] & 0xff)

        let otp = binary % 1000000

        print(otp)
    case 3...4:
        if argv[1] == "-d" {
            try rmPass(account: argv[2])
        } else if ((argv[1] == "-a") && (argc == 4)) {
            let pass = base32DecodeToData(argv[3])!.hexDescription
            try addPass(account: argv[2], secrete: pass)
        } else {
            fallthrough
        }
    default:
        print("Invalid arguments", to: &stdErr)
        exitValue = EXIT_FAILURE
    }
} catch KeychainError.noPassword {
    print("Secrete not found", to: &stdErr)
    exitValue = EXIT_FAILURE
} catch KeychainError.unexpectedPasswordData {
    print("Invalid secrete data", to: &stdErr)
    exitValue = EXIT_FAILURE
} catch {
    print("Unknow error", to: &stdErr)
    exitValue = EXIT_FAILURE
}

exit(exitValue)
