//
//  StrideApp.swift
//  Stride
//
//  Created by Renzo on 13/2/2026.
//

import SwiftUI

@main
struct StrideApp: App {
    @State private var session = StravaSession()

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
                .onOpenURL { url in
                    session.handleCallback(url: url)
                }
                .tint(AppColors.accent)
                .preferredColorScheme(.dark)
        }
    }
}
