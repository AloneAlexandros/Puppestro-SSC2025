import Foundation

class CGTools {
    static func distanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        let answer = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
        if answer.isNaN {
            return 0
        }
        return answer
    }
    
    static func avarage(_ numbers: [CGPoint]) -> CGPoint {
        var xSum = 0.0
        var ySum = 0.0
        for i in 0..<numbers.count {
            xSum += numbers[i].x
            ySum += numbers[i].y
        }
        let count = Double(numbers.count)
        return CGPoint(x: xSum/count, y: ySum/count)
    }
}
