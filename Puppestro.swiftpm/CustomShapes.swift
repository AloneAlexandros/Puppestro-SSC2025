import SwiftUI

struct HandPolygon: Shape {
    var points: [CGPoint]
    var scale: CGFloat = 1.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !points.isEmpty else { return path }

        let center = CGTools.avarage(points)
        
        // Scale points about the centroid.
        let scaledPoints = points.map { point -> CGPoint in
            let dx = point.x - center.x
            let dy = point.y - center.y
            return CGPoint(x: center.x + dx * scale, y: center.y + dy * scale)
        }

        // Draw the polygon.
        path.move(to: scaledPoints[0])
        for point in scaledPoints.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}
