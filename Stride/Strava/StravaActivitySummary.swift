//
//  StravaActivitySummary.swift
//  Stride
//
//  Summary representation of a Strava activity (from list athlete activities endpoint).
//

import Foundation

struct StravaActivitySummary: Decodable {
    let id: Int
    let distance: Double
    /// Moving time in seconds.
    let movingTime: Int
    let type: String
    /// Activity start time (local timezone from API).
    let startDate: Date
    let locationCity: String?
    let locationState: String?
    let locationCountry: String?
    let map: StravaMapSummary?

    enum CodingKeys: String, CodingKey {
        case id, distance, type, map
        case movingTime = "moving_time"
        case startDate = "start_date_local"
        case locationCity = "location_city"
        case locationState = "location_state"
        case locationCountry = "location_country"
    }
}

struct StravaMapSummary: Decodable {
    let summaryPolyline: String?

    enum CodingKeys: String, CodingKey {
        case summaryPolyline = "summary_polyline"
    }
}
