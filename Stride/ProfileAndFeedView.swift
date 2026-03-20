//
//  ProfileAndFeedView.swift
//  Stride
//
//  Single screen: profile at top, run feed grid below. Dark immersive theme.
//

import SwiftUI

struct ProfileAndFeedView: View {
    @Bindable var session: StravaSession
    @Bindable var feedViewModel: RunFeedViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileSection
                runsSection
            }
        }
        .scrollIndicators(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("STRIDE")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                    session.logout()
                }
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .task {
            if feedViewModel.runs.isEmpty {
                await feedViewModel.loadFirstPage()
            }
        }
        .navigationDestination(item: $feedViewModel.selectedRunForBackground) { runItem in
            BackgroundSelectionView(runItem: runItem) {
                feedViewModel.selectedRunForBackground = nil
            }
        }
    }

    @ViewBuilder
    private var profileSection: some View {
        if let athlete = session.currentAthlete {
            AthleteContentView(athlete: athlete, onLogOut: { session.logout() })
        } else {
            ProgressView("Loading profile…")
                .tint(AppColors.accent)
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.lg)
        }
    }

    private var runsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Runs")
                .font(AppFont.sectionHeader)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)

            if feedViewModel.runs.isEmpty, feedViewModel.isLoading {
                ProgressView("Loading runs…")
                    .tint(AppColors.accent)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
            } else if feedViewModel.runs.isEmpty, feedViewModel.loadError != nil {
                ContentUnavailableView(
                    "Couldn't load runs",
                    systemImage: "exclamationmark.triangle",
                    description: Text(feedViewModel.loadError ?? "")
                )
                .foregroundStyle(AppColors.textSecondary)
                .padding(.vertical, AppSpacing.xl)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ], spacing: 2) {
                    ForEach(feedViewModel.runs) { item in
                        Button {
                            feedViewModel.selectedRunForBackground = item
                        } label: {
                            RunCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    Color.clear
                        .frame(height: 1)
                        .onAppear { feedViewModel.didScrollNearBottom() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileAndFeedView(session: StravaSession(), feedViewModel: RunFeedViewModel(session: StravaSession()))
    }
}
