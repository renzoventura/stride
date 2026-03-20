//
//  StravaAuthService.swift
//  Stride
//
//  Handles Strava OAuth token exchange and refresh per https://developers.strava.com/docs/authentication/
//

import Foundation

struct StravaTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int
    let athlete: StravaAthleteSummary?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case athlete
    }
}

struct StravaAthleteSummary: Decodable {
    let id: Int
    let firstname: String
    let lastname: String
    let profileMedium: String?
    let profile: String?
    let city: String?
    let state: String?
    let country: String?
    let premium: Bool?

    enum CodingKeys: String, CodingKey {
        case id, firstname, lastname, city, state, country, premium
        case profileMedium = "profile_medium"
        case profile
    }
}

enum StravaAuthServiceError: Error {
    case notConfigured
    case invalidURL
    case exchangeFailed(String)
    case refreshFailed(String)
}

enum StravaAuthService {
    private static let tokenURL = URL(string: "https://www.strava.com/api/v3/oauth/token")!
    private static let deauthorizeURL = URL(string: "https://www.strava.com/oauth/deauthorize")!

    /// Exchange authorization code for access and refresh tokens.
    static func exchange(code: String) async throws -> StravaTokenResponse {
        guard StravaConfiguration.isConfigured else { throw StravaAuthServiceError.notConfigured }
        var components = URLComponents(url: tokenURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: String(StravaConfiguration.clientID)),
            URLQueryItem(name: "client_secret", value: StravaConfiguration.clientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = components.url else { throw StravaAuthServiceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StravaAuthServiceError.exchangeFailed("Invalid response") }
        if http.statusCode != 200 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw StravaAuthServiceError.exchangeFailed("\(http.statusCode): \(message)")
        }
        let decoder = JSONDecoder()
        return try decoder.decode(StravaTokenResponse.self, from: data)
    }

    /// Refresh access token using stored refresh token. Returns new tokens; caller should persist them.
    static func refresh(refreshToken: String) async throws -> StravaTokenResponse {
        guard StravaConfiguration.isConfigured else { throw StravaAuthServiceError.notConfigured }
        var components = URLComponents(url: tokenURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: String(StravaConfiguration.clientID)),
            URLQueryItem(name: "client_secret", value: StravaConfiguration.clientSecret),
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        guard let url = components.url else { throw StravaAuthServiceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StravaAuthServiceError.refreshFailed("Invalid response") }
        if http.statusCode != 200 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw StravaAuthServiceError.refreshFailed("\(http.statusCode): \(message)")
        }
        let decoder = JSONDecoder()
        return try decoder.decode(StravaTokenResponse.self, from: data)
    }

    /// Revoke access (deauthorize). Call this on logout.
    static func deauthorize(accessToken: String) async {
        var components = URLComponents(url: deauthorizeURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "access_token", value: accessToken)]
        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }
}
