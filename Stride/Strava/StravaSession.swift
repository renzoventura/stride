//
//  StravaSession.swift
//  Stride
//
//  Observable session state for Strava OAuth. Starts login (app or web), handles callback, and keeps athlete in sync.
//

import AuthenticationServices
import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
final class StravaSession {
    var isLoggedIn: Bool { currentAthlete != nil }
    var currentAthlete: StravaAthleteSummary?
    var isLoading = false
    var loginError: String?

    private var webAuthSession: ASWebAuthenticationSession?
    private var webAuthPresentationContextProvider: StravaWebAuthPresentationContextProvider?
    private var pendingCallback: (URL) -> Void = { _ in }

    init() {
        restoreSessionIfNeeded()
    }

    /// Call from the app's .onOpenURL to handle redirect from Strava app or web OAuth.
    func handleCallback(url: URL) {
        guard url.scheme == StravaConfiguration.callbackURLScheme else { return }
        pendingCallback(url)
        pendingCallback = { _ in }
    }

    /// Presents Strava login: opens Strava app if installed, otherwise ASWebAuthenticationSession.
    func presentLogin() {
        guard StravaConfiguration.isConfigured else {
            loginError = "Strava is not configured. Set STRAVA_CLIENT_ID and STRAVA_CLIENT_SECRET."
            return
        }
        loginError = nil
        isLoading = true
        let authURL = buildAuthURL(host: "https://www.strava.com")
        let appURL = buildAuthURL(host: "strava")

        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            pendingCallback = { [weak self] callbackURL in
                Task { @MainActor in
                    self?.completeLogin(with: callbackURL)
                }
            }
            UIApplication.shared.open(appURL)
            isLoading = false
            return
        }

        guard let webURL = authURL else {
            loginError = "Invalid auth URL"
            isLoading = false
            return
        }
        let scheme = StravaConfiguration.callbackURLScheme
        webAuthSession = ASWebAuthenticationSession(url: webURL, callbackURLScheme: scheme) { [weak self] callbackURL, error in
            Task { @MainActor in
                self?.isLoading = false
                self?.webAuthSession = nil
                self?.webAuthPresentationContextProvider = nil
                if let error {
                    self?.loginError = error.localizedDescription
                    return
                }
                guard let callbackURL else {
                    self?.loginError = "No callback URL"
                    return
                }
                self?.completeLogin(with: callbackURL)
            }
        }
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        let provider = StravaWebAuthPresentationContextProvider()
        webAuthSession?.presentationContextProvider = provider
        webAuthPresentationContextProvider = provider
        webAuthSession?.start()
    }

    func logout() {
        if let token = StravaTokenStore.getAccessToken() {
            Task {
                await StravaAuthService.deauthorize(accessToken: token)
            }
        }
        StravaTokenStore.clear()
        currentAthlete = nil
        loginError = nil
    }

    func clearLoginError() {
        loginError = nil
    }

    /// Returns a valid access token for API calls (e.g. activities feed), refreshing if expired. Nil if not logged in.
    func validAccessToken() async -> String? {
        await getValidAccessToken()
    }

    private func buildAuthURL(host: String) -> URL? {
        let path = host == "strava" ? "strava://oauth/mobile/authorize" : "https://www.strava.com/oauth/mobile/authorize"
        var components = URLComponents(string: path)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: String(StravaConfiguration.clientID)),
            URLQueryItem(name: "redirect_uri", value: StravaConfiguration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: StravaConfiguration.scope)
        ]
        return components?.url
    }

    private func completeLogin(with callbackURL: URL) {
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            let comp = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
            if comp?.queryItems?.contains(where: { $0.name == "error" }) == true {
                loginError = "Access denied"
            } else {
                loginError = "Missing authorization code"
            }
            return
        }
        Task {
            await exchangeCodeAndLoadSession(code: code)
        }
    }

    private func exchangeCodeAndLoadSession(code: String) async {
        isLoading = true
        loginError = nil
        defer { isLoading = false }
        do {
            let response = try await StravaAuthService.exchange(code: code)
            StravaTokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken, expiresAt: response.expiresAt)
            if let athlete = response.athlete {
                currentAthlete = athlete
            } else {
                await fetchCurrentAthlete()
            }
        } catch StravaAuthServiceError.exchangeFailed(let message) {
            loginError = message
        } catch {
            loginError = error.localizedDescription
        }
    }

    private func restoreSessionIfNeeded() {
        Task {
            await fetchCurrentAthlete()
        }
    }

    /// Returns a valid access token, refreshing from Keychain if expired or expiring within an hour.
    private func getValidAccessToken() async -> String? {
        let now = Int(Date().timeIntervalSince1970)
        let oneHourFromNow = now + 3600
        if let token = StravaTokenStore.getAccessToken(),
           let expiresAt = StravaTokenStore.getExpiresAt(),
           expiresAt > oneHourFromNow {
            return token
        }
        guard let refreshToken = StravaTokenStore.getRefreshToken() else { return nil }
        do {
            let response = try await StravaAuthService.refresh(refreshToken: refreshToken)
            StravaTokenStore.save(accessToken: response.accessToken, refreshToken: response.refreshToken, expiresAt: response.expiresAt)
            return response.accessToken
        } catch {
            return nil
        }
    }

    private func fetchCurrentAthlete(accessToken: String? = nil) async {
        let token: String? = if let accessToken { accessToken } else { await getValidAccessToken() }
        guard let token else { return }
        do {
            currentAthlete = try await StravaAPIClient.getCurrentAthlete(accessToken: token)
        } catch {
            if accessToken == nil {
                StravaTokenStore.clear()
            }
        }
    }
}
