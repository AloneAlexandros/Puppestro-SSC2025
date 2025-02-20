import SwiftUI

class Database : ObservableObject {
    @Published var minimumDistance: Float = 1000
    @Published var maximumDistance: Float = -1000
}
