//
//  StravaTokenStore.swift
//  Stride
//
//  Securely stores and retrieves Strava OAuth tokens in the Keychain.
//

import Foundation
import Security

enum StravaTokenStore {
    private static let service = "com.pacepal.strava"
    private static let accessTokenKey = "access_token"
    private static let refreshTokenKey = "refresh_token"
    private static let expiresAtKey = "expires_at"

    static func save(accessToken: String, refreshToken: String, expiresAt: Int) {
        let expiresAtData = String(expiresAt).data(using: .utf8)
        save(key: accessTokenKey, value: accessToken)
        save(key: refreshTokenKey, value: refreshToken)
        if let data = expiresAtData {
            save(key: expiresAtKey, data: data)
        }
    }

    static func getAccessToken() -> String? {
        load(key: accessTokenKey)
    }

    static func getRefreshToken() -> String? {
        load(key: refreshTokenKey)
    }

    static func getExpiresAt() -> Int? {
        guard let data = loadData(key: expiresAtKey),
              let string = String(data: data, encoding: .utf8),
              let value = Int(string) else { return nil }
        return value
    }

    static func clear() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
        delete(key: expiresAtKey)
    }

    private static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(key: key, data: data)
    }

    private static func save(key: String, data: Data) {
        delete(key: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load(key: String) -> String? {
        guard let data = loadData(key: key),
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }

    private static func loadData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }

    private static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
