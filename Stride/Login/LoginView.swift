//
//  LoginView.swift
//  Stride
//
//  Login screen with "Log in with Strava" button. Dark, minimal, athletic.
//

import SwiftUI

struct LoginView: View {
    @Bindable var session: StravaSession

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "figure.run")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(AppColors.accent)

            VStack(spacing: AppSpacing.sm) {
                Text("Stride")
                    .font(AppFont.metricLarge)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Connect your Strava account to get started.")
                    .font(AppFont.secondary)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let error = session.loginError {
                Text(error)
                    .font(AppFont.metadata)
                    .foregroundStyle(AppColors.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            Button(action: logInWithStrava) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "link")
                    Text("Log in with Strava")
                }
            }
            .buttonStyle(AccentButtonStyle(isEnabled: !session.isLoading))
            .disabled(session.isLoading)

            if session.isLoading {
                ProgressView()
                    .tint(AppColors.accent)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear { session.clearLoginError() }
    }

    private func logInWithStrava() {
        session.presentLogin()
    }
}

#Preview {
    LoginView(session: StravaSession())
}
