//
//  StravaWebAuthPresentationContextProvider.swift
//  Stride
//
//  Provides the presentation anchor for ASWebAuthenticationSession (requires NSObject).
//

import AuthenticationServices
import UIKit

final class StravaWebAuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive })
            ?? scenes.compactMap({ $0 as? UIWindowScene }).first else {
            return ASPresentationAnchor()
        }
        if let keyWindow = windowScene.windows.first(where: \.isKeyWindow) {
            return keyWindow
        }
        guard let firstWindow = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return firstWindow
    }
}
