//
//  AthleteView.swift
//  Stride
//
//  Displays basic Strava athlete info and a log out button. Dark themed.
//

import SwiftUI

struct AthleteView: View {
    @Bindable var session: StravaSession

    var body: some View {
        Group {
            if let athlete = session.currentAthlete {
                ScrollView {
                    AthleteContentView(athlete: athlete, onLogOut: { session.logout() })
                }
            } else {
                ContentUnavailableView(
                    "Loading profile",
                    systemImage: "person.crop.circle",
                    description: Text("Fetching your Strava profile…")
                )
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log out", systemImage: "rectangle.portrait.and.arrow.right") {
                    session.logout()
                }
                .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

/// Profile content (header, details). Dark theme with card surfaces.
struct AthleteContentView: View {
    let athlete: StravaAthleteSummary
    let onLogOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            profileHeader
            detailsSection
        }
        .padding(AppSpacing.md)
    }

    private var profileHeader: some View {
        HStack(spacing: AppSpacing.md) {
            AthleteAvatarView(profileURL: athlete.profileMedium ?? athlete.profile)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(athlete.firstname + " " + athlete.lastname)
                    .font(AppFont.metricMedium)
                    .foregroundStyle(AppColors.textPrimary)
                if athlete.premium == true {
                    Text("Strava Premium")
                        .font(AppFont.metadata)
                        .foregroundStyle(AppColors.accent)
                }
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .themedCard()
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Details")
                .font(AppFont.sectionHeader)
                .foregroundStyle(AppColors.textPrimary)

            if let city = athlete.city, !city.isEmpty {
                detailRow(label: "City", value: city)
            }
            if let state = athlete.state, !state.isEmpty {
                detailRow(label: "State", value: state)
            }
            if let country = athlete.country, !country.isEmpty {
                detailRow(label: "Country", value: country)
            }
            detailRow(label: "Athlete ID", value: String(athlete.id))
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedCard()
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.secondary)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppFont.secondary)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

private struct AthleteAvatarView: View {
    let profileURL: String?

    var body: some View {
        Group {
            if let urlString = profileURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        avatarPlaceholder
                    default:
                        ProgressView()
                            .tint(AppColors.accent)
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(.circle)
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 28))
            .foregroundStyle(AppColors.textMuted)
    }
}

#Preview {
    NavigationStack {
        AthleteView(session: StravaSession())
    }
}
