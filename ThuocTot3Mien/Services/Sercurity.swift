//
//  Sercurity.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 08/12/2023.
//

import Foundation
import Security

enum KeychainService {
    static func saveToken(token: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "LoginToken",
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(keychainQuery as CFDictionary, nil)

        if status != errSecSuccess {
            print("Error saving token to Keychain")
        }
    }

    static func getToken() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "LoginToken",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
        ]

        var dataTypeRef: AnyObject?

        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                let token = String(data: retrievedData, encoding: .utf8)
                return token
            }
        }

        return nil
    }

    static func deleteToken() {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "LoginToken",
        ]

        let status = SecItemDelete(keychainQuery as CFDictionary)

        if status != errSecSuccess {
            print("Error deleting token from Keychain")
        }
    }
}
