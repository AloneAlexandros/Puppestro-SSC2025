import SwiftUI

struct Bin : View {
    let binEmoji : String
    var body: some View {
        ZStack{
            Text("🗑️")
                 .font(.largeTitle)
            Text(binEmoji)
                .font(.footnote)
        }
    }
}

#Preview {
    Bin(binEmoji: "♻️")
}
