//
//  MapSnapshotService.swift
//  Stride
//
//  Shared map snapshot renderer used by both the background picker and the canvas overlay system.
//

import MapKit
import UIKit

struct MapSnapshotService {
    /// Generates a map snapshot with the route drawn on it at the given output size.
    static func makeSnapshot(polyline: String, size: CGSize, routeLineWidth: CGFloat = 4, mapOpacity: CGFloat = 1) async -> UIImage? {
        let coords = PolylineDecoder.decode(polyline)
        guard !coords.isEmpty else { return nil }

        let region = regionThatFits(coordinates: coords)
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.scale = 1
        options.mapType = .mutedStandard

        let snapshotter = MKMapSnapshotter(options: options)
        return await withCheckedContinuation { continuation in
            snapshotter.start { snapshot, _ in
                guard let snapshot else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: drawRoute(on: snapshot, coordinates: coords, lineWidth: routeLineWidth, mapOpacity: mapOpacity))
            }
        }
    }

    private static func regionThatFits(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates[0].latitude
        var maxLat = minLat
        var minLng = coordinates[0].longitude
        var maxLng = minLng
        for c in coordinates.dropFirst() {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLng = min(minLng, c.longitude)
            maxLng = max(maxLng, c.longitude)
        }
        let padding = 0.01
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, padding) * 1.4,
            longitudeDelta: max(maxLng - minLng, padding) * 1.4
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private static func drawRoute(
        on snapshot: MKMapSnapshotter.Snapshot,
        coordinates: [CLLocationCoordinate2D],
        lineWidth: CGFloat,
        mapOpacity: CGFloat
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: snapshot.image.size)
        return renderer.image { context in
            context.cgContext.setAlpha(mapOpacity)
            snapshot.image.draw(at: .zero)
            context.cgContext.setAlpha(1)
            let rect = CGRect(origin: .zero, size: snapshot.image.size)
            context.cgContext.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 0.4))
            context.cgContext.fill(rect)
            guard coordinates.count >= 2 else { return }
            let points = coordinates.map { snapshot.point(for: $0) }
            context.cgContext.setStrokeColor(CGColor(red: 1, green: 0.45, blue: 0, alpha: 1))
            context.cgContext.setLineWidth(lineWidth)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            context.cgContext.addLines(between: points)
            context.cgContext.strokePath()
        }
    }
}
