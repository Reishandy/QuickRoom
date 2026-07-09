//
//  APIClient.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation

enum APIError: LocalizedError {
	case unauthorized
	case conflict(String)
	case server(status: Int, message: String)
	case transport(Error)

	var errorDescription: String? {
		switch self {
		case .unauthorized: return "Sign in to book rooms."
		case .conflict(let message): return message
		case .server(_, let message): return message
		case .transport: return "Network error. Check your connection."
		}
	}
}

final class APIClient {
	static var shared = APIClient(baseURL: AppConfig.API.baseURL, tokenProvider: { KeychainStore.sessionToken })

	private let baseURL: URL
	private let session: URLSession
	private let tokenProvider: () -> String?

	/// Fired on a 401 for a request that carried a token, so AuthService can
	/// drop the dead session. Set once at AuthService init; called off the
	/// main actor.
	var onUnauthorized: (() -> Void)?

	init(baseURL: URL, session: URLSession = .shared, tokenProvider: @escaping () -> String?) {
		self.baseURL = baseURL
		self.session = session
		self.tokenProvider = tokenProvider
	}

	func get<T: Decodable>(_ path: String) async throws -> T {
		try await send("GET", path, body: Optional<AppleAuthRequest>.none)
	}

	func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
		try await send("POST", path, body: body)
	}

	func post<T: Decodable>(_ path: String) async throws -> T {
		try await send("POST", path, body: Optional<AppleAuthRequest>.none)
	}

	func patch<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
		try await send("PATCH", path, body: body)
	}

	private func send<T: Decodable, B: Encodable>(_ method: String, _ path: String, body: B?) async throws -> T {
		var request = URLRequest(url: baseURL.appending(path: path))
		request.httpMethod = method
		if let body {
			request.httpBody = try Self.encoder.encode(body)
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}
		let token = tokenProvider()
		if let token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		let data: Data
		let response: URLResponse
		do {
			(data, response) = try await session.data(for: request)
		} catch {
			throw APIError.transport(error)
		}

		let status = (response as? HTTPURLResponse)?.statusCode ?? 0
		guard (200..<300).contains(status) else {
			let message = (try? Self.decoder.decode(ServerErrorBody.self, from: data))?.error ?? "Request failed (\(status))"
			switch status {
			case 401:
				// Only a rejected token means the session is dead. A 401 on a
				// request that carried no token (keychain unreadable during a
				// locked-phone background wakeup) must not wipe the session —
				// that was signing users out overnight.
				if token != nil {
					onUnauthorized?()
				}
				throw APIError.unauthorized
			case 409: throw APIError.conflict(message)
			default: throw APIError.server(status: status, message: message)
			}
		}
		return try Self.decoder.decode(T.self, from: data)
	}

	private struct ServerErrorBody: Decodable {
		let error: String
	}

	static let decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .custom { decoder in
			let container = try decoder.singleValueContainer()
			let raw = try container.decode(String.self)
			guard let date = parseRFC3339(raw) else {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "unparseable date \(raw)")
			}
			return date
		}
		return decoder
	}()

	static let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()

	private static let isoPlain: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()

	private static let isoFractional: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()

	/// Go emits RFC 3339 with up to nanosecond precision, but
	/// ISO8601DateFormatter's fractional mode parses exactly three digits —
	/// so truncate the fraction to milliseconds before parsing.
	static func parseRFC3339(_ raw: String) -> Date? {
		if let date = isoPlain.date(from: raw) {
			return date
		}
		guard let dotIndex = raw.firstIndex(of: ".") else { return nil }
		var fractionEnd = raw.index(after: dotIndex)
		while fractionEnd < raw.endIndex, raw[fractionEnd].isNumber {
			fractionEnd = raw.index(after: fractionEnd)
		}
		let fraction = raw[raw.index(after: dotIndex)..<fractionEnd].prefix(3)
		let trimmed = raw[..<dotIndex] + "." + fraction + raw[fractionEnd...]
		return isoFractional.date(from: String(trimmed))
	}
}
