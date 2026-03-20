//
//  StravaAPIClient.swift
//  Stride
//
//  Fetches current athlete and other Strava API resources using the access token.
//

import Foundation

enum StravaAPIClientError: Error {
    case noAccessToken
    case invalidResponse
    case apiError(Int, String)
}

enum StravaAPIClient {
    private static let baseURL = URL(string: "https://www.strava.com/api/v3")!
    private static let activitiesPageSize = 30

    static func getCurrentAthlete(accessToken: String) async throws -> StravaAthleteSummary {
        let url = baseURL.appending(path: "athlete")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StravaAPIClientError.invalidResponse }
        if http.statusCode != 200 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw StravaAPIClientError.apiError(http.statusCode, message)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(StravaAthleteSummary.self, from: data)
    }

    /// Lists activities for the authenticated athlete. Pagination: page is 1-based, per_page default 30.
    /// Returns activity summaries sorted newest first. Stop when returned array is empty.
    static func listActivities(accessToken: String, page: Int, perPage: Int = activitiesPageSize) async throws -> [StravaActivitySummary] {
        var components = URLComponents(url: baseURL.appending(path: "athlete/activities"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        guard let url = components.url else { throw StravaAPIClientError.invalidResponse }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StravaAPIClientError.invalidResponse }
        if http.statusCode != 200 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw StravaAPIClientError.apiError(http.statusCode, message)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([StravaActivitySummary].self, from: data)
    }
}
