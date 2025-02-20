import SwiftUI

struct HandPolygon: Shape {
    var points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !points.isEmpty else { return path }
        
        // Move to the first point
        path.move(to: points[0])
        
        // Add lines to each subsequent point
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}
