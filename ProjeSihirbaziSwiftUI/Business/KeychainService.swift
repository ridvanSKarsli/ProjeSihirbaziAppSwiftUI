import Foundation
import Security

public final class KeychainService {
    public static let shared = KeychainService()
    private init() {}

    private let account = "accessToken"
    private let service = Bundle.main.bundleIdentifier ?? "ProjeSihirbazi"

    @discardableResult
    public func saveAccessToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }

        // Önce varsa sil
        _ = deleteAccessToken()

        let query: [String: Any] = [
            kSecClass as String:             kSecClassGenericPassword,
            kSecAttrService as String:       service,
            kSecAttrAccount as String:       account,
            kSecValueData as String:         data,
            kSecAttrAccessible as String:    kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func readAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrService as String:     service,
            kSecAttrAccount as String:     account,
            kSecReturnData as String:      kCFBooleanTrue as Any,
            kSecMatchLimit as String:      kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }

    @discardableResult
    public func deleteAccessToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
