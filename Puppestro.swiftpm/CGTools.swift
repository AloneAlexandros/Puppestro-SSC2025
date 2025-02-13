import Foundation

class CGTools {
    static func distanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        let answer = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
        if answer.isNaN {
            return 0
        }
        return answer
    }
}
