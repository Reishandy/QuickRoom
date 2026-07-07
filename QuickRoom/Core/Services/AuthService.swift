//
//  AuthService.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import AuthenticationServices
import Foundation
import SwiftUI

@Observable
final class AuthService {
	static let shared = AuthService()

	private(set) var currentUser: UserDTO?

	var isSignedIn: Bool { currentUser != nil }

	private let client: APIClient

	init(client: APIClient = .shared) {
		self.client = client
		if KeychainStore.sessionToken != nil, let json = KeychainStore.currentUserJSON {
			currentUser = try? JSONDecoder().decode(UserDTO.self, from: Data(json.utf8))
		}
		client.onUnauthorized = { [weak self] in
			Task { @MainActor in self?.handleUnauthorized() }
		}
	}

	func configure(_ request: ASAuthorizationAppleIDRequest) {
		request.requestedScopes = [.fullName, .email]
	}

	func completeSignIn(_ result: Result<ASAuthorization, Error>) async throws {
		guard case .success(let authorization) = result,
			  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
			  let tokenData = credential.identityToken,
			  let identityToken = String(data: tokenData, encoding: .utf8) else {
			throw APIError.server(status: 0, message: "Apple sign-in was cancelled or failed.")
		}

		// Apple sends the name only on the very first authorization.
		var name: String?
		if let components = credential.fullName {
			let formatted = PersonNameComponentsFormatter().string(from: components)
			name = formatted.isEmpty ? nil : formatted
		}

		let response: AuthResponse = try await client.post("/auth/apple", body: AppleAuthRequest(identityToken: identityToken, name: name))
		KeychainStore.sessionToken = response.sessionToken
		if let data = try? JSONEncoder().encode(response.user) {
			KeychainStore.currentUserJSON = String(data: data, encoding: .utf8)
		}
		currentUser = response.user

		// A device token uploaded before sign-in was deferred (401); now
		// there's a session to attach it to.
		await PushRegistrar.shared.flushPendingToken()
	}

	func signOut() async {
		let _: StatusResponse? = try? await client.post("/auth/logout")
		KeychainStore.sessionToken = nil
		KeychainStore.currentUserJSON = nil
		currentUser = nil
	}

	/// The backend rejected our token (expired or revoked). Clear the session
	/// locally — no /auth/logout call: the token is already dead, and a network
	/// call from here could loop straight back into another 401.
	@MainActor
	func handleUnauthorized() {
		KeychainStore.sessionToken = nil
		KeychainStore.currentUserJSON = nil
		currentUser = nil
	}
}
