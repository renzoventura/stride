//
//  RootView.swift
//  Stride
//
//  Root navigation: login when unauthenticated; profile + feed on one screen when logged in.
//

import SwiftUI

struct RootView: View {
    @Bindable var session: StravaSession

    @State private var feedViewModel: RunFeedViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if session.isLoggedIn {
                    if let feedViewModel {
                        ProfileAndFeedView(session: session, feedViewModel: feedViewModel)
                    } else {
                        ProgressView()
                            .tint(AppColors.accent)
                    }
                } else {
                    LoginView(session: session)
                }
            }
            .task(id: session.isLoggedIn) {
                if session.isLoggedIn, feedViewModel == nil {
                    feedViewModel = RunFeedViewModel(session: session)
                }
            }
            .onChange(of: session.isLoggedIn) { _, isLoggedIn in
                if !isLoggedIn { feedViewModel = nil }
            }
        }
    }
}

#Preview {
    RootView(session: StravaSession())
}
