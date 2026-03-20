//
//  PolylineDecoder.swift
//  Stride
//
//  Decodes Google/Strava encoded polyline to coordinates (CLLocationCoordinate2D).
//  See: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
//

import CoreLocation
import Foundation

enum PolylineDecoder {
    /// Decodes an encoded polyline string (e.g. Strava map.summary_polyline) to an array of coordinates.
    /// Returns empty array if string is empty or decoding fails.
    static func decode(_ encoded: String?) -> [CLLocationCoordinate2D] {
        guard let encoded, !encoded.isEmpty else { return [] }
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat = 0.0
        var lng = 0.0
        while index < encoded.endIndex {
            let dLat = decodeScalar(encoded: encoded, index: &index)
            let dLng = decodeScalar(encoded: encoded, index: &index)
            lat += dLat
            lng += dLng
            coordinates.append(CLLocationCoordinate2D(latitude: lat / 1e5, longitude: lng / 1e5))
        }
        return coordinates
    }

    private static func decodeScalar(encoded: String, index: inout String.Index) -> Double {
        var result = 0
        var shift = 0
        repeat {
            guard index < encoded.endIndex else { break }
            let char = encoded[index]
            index = encoded.index(after: index)
            let value = Int(char.asciiValue ?? 0) - 63
            result |= (value & 0x1F) << shift
            shift += 5
            if value < 0x20 { break }
        } while true
        let signed = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
        return Double(signed)
    }
}
