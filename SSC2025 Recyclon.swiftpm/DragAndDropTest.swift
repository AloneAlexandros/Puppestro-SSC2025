import SwiftUI

struct DragNDrop: View {
    @State var enablePaper = true;
    let font = Font.system(size: 125)
    var body: some View {
        Text("Drag the trash into the bin!")
            .font(.largeTitle)
        Bin(binEmoji: "♻️")
        Trash(trashEmoji: "📄")
    }
}

#Preview {
    DragNDrop()
}


