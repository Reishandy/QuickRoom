//
//  KeychainStore.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation
import Security

enum KeychainStore {
	private static let service = Bundle.main.bundleIdentifier ?? "QuickRoom"

	static var sessionToken: String? {
		get { string(for: "session_token") }
		set { setString(newValue, for: "session_token") }
	}

	static var currentUserJSON: String? {
		get { string(for: "current_user") }
		set { setString(newValue, for: "current_user") }
	}

	static var appleUserID: String? {
		get { string(for: "apple_user_id") }
		set { setString(newValue, for: "apple_user_id") }
	}

	private static func string(for key: String) -> String? {
		var query = baseQuery(for: key)
		query[kSecReturnData as String] = true
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		var item: CFTypeRef?
		guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
			  let data = item as? Data else { return nil }
		return String(data: data, encoding: .utf8)
	}

	private static func setString(_ value: String?, for key: String) {
		SecItemDelete(baseQuery(for: key) as CFDictionary)
		guard let value else { return }
		var query = baseQuery(for: key)
		query[kSecValueData as String] = Data(value.utf8)
		SecItemAdd(query as CFDictionary, nil)
	}

	private static func baseQuery(for key: String) -> [String: Any] {
		[
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: service,
			kSecAttrAccount as String: key,
		]
	}
}
