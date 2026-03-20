//
//  RunFeedItem.swift
//  Stride
//
//  Display model for a single run in the feed (distance, pace, date, optional route polyline for Apple Maps).
//

import Foundation

struct RunFeedItem: Identifiable, Hashable {
    let id: Int
    /// Distance in kilometers, 2 decimal places for display.
    let distanceKm: Double
    /// Pace string per km, e.g. "5:17"; nil if distance or moving time is zero.
    let pacePerKmDisplay: String?
    /// Moving time in seconds.
    let movingTimeSeconds: Int
    /// Activity date formatted for display (e.g. "Jan 15, 2024").
    let dateDisplay: String
    /// Optional location string derived from Strava's city/state/country fields.
    let locationDisplay: String?
    /// Strava map.summary_polyline for route; nil if none. Used by AppleMapRouteImageView to draw the route.
    let polyline: String?

    init(
        id: Int,
        distanceKm: Double,
        pacePerKmDisplay: String?,
        movingTimeSeconds: Int,
        dateDisplay: String,
        locationDisplay: String?,
        polyline: String?
    ) {
        self.id = id
        self.distanceKm = distanceKm
        self.pacePerKmDisplay = pacePerKmDisplay
        self.movingTimeSeconds = movingTimeSeconds
        self.dateDisplay = dateDisplay
        self.locationDisplay = locationDisplay
        self.polyline = polyline
    }
}

extension RunFeedItem {
    /// Builds a feed item from a Strava activity summary. Only use for type == "Run".
    init(activity: StravaActivitySummary) {
        id = activity.id
        distanceKm = (activity.distance / 1000).rounded(toPlaces: 2)
        pacePerKmDisplay = Self.formatPacePerKm(movingTimeSeconds: activity.movingTime, distanceMeters: activity.distance)
        movingTimeSeconds = activity.movingTime
        dateDisplay = Self.formatActivityDate(activity.startDate)
        locationDisplay = Self.formatLocation(city: activity.locationCity, state: activity.locationState, country: activity.locationCountry)
        polyline = activity.map?.summaryPolyline
    }

    private static func formatActivityDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns "M:SS" per km, or nil if pace cannot be computed.
    private static func formatPacePerKm(movingTimeSeconds: Int, distanceMeters: Double) -> String? {
        guard distanceMeters > 0, movingTimeSeconds > 0 else { return nil }
        let distanceKm = distanceMeters / 1000
        let secondsPerKm = Double(movingTimeSeconds) / distanceKm
        let totalSeconds = Int(secondsPerKm.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let secondsString = seconds.formatted(.number.precision(.integerLength(2)))
        return "\(minutes):\(secondsString)"
    }

    private static func formatLocation(city: String?, state: String?, country: String?) -> String? {
        let parts = [city, state, country]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
