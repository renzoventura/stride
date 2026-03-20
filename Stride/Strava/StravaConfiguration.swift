//
//  StravaConfiguration.swift
//  Stride
//
//  Strava OAuth client configuration. Do not commit client secret to the repository.
//  Set STRAVA_CLIENT_ID and STRAVA_CLIENT_SECRET in your scheme's environment or xcconfig.
//

import Foundation

enum StravaConfiguration {
    private static let clientIDKey = "STRAVA_CLIENT_ID"
    private static let clientSecretKey = "STRAVA_CLIENT_SECRET"

    static var clientID: Int {
        guard let value = ProcessInfo.processInfo.environment[clientIDKey] ?? Bundle.main.object(forInfoDictionaryKey: clientIDKey) as? String,
              let id = Int(value) else {
            return 0
        }
        return id
    }

    static var clientSecret: String {
        ProcessInfo.processInfo.environment[clientSecretKey] ?? (Bundle.main.object(forInfoDictionaryKey: clientSecretKey) as? String) ?? ""
    }

    static var isConfigured: Bool {
        clientID != 0 && !clientSecret.isEmpty
    }

    /// Callback URL scheme registered in the app (must match CFBundleURLSchemes in Info.plist).
    static var callbackURLScheme: String { redirectScheme }

    /// Scheme for the OAuth redirect (e.g. pacepal).
    static var redirectScheme: String { "pacepal" }

    /// Host for the OAuth redirect. Must exactly match "Authorization Callback Domain" in Strava API settings.
    /// Use "127.0.0.1" for simulator, "pacepal" or "pacepal.com" for production.
    static var redirectHost: String {
        ProcessInfo.processInfo.environment["STRAVA_REDIRECT_HOST"] ?? "pacepal.com"
    }

    /// Optional path for the redirect URI (usually empty).
    static var redirectPath: String { "" }

    /// Redirect URI sent to Strava: scheme://host + path (e.g. pacepal://127.0.0.1 or pacepal://pacepal.com).
    static var redirectURI: String {
         "pacepal://127.0.0.1"
//        "\(redirectScheme)://\(redirectHost)\(redirectPath)"
    }

    /// Scopes for basic read and profile. Request only what the app needs.
    static var scope: String { "activity:read_all,profile:read_all" }
}
