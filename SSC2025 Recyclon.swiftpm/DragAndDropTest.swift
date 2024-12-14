import SwiftUI

struct DragNDrop: View {
    @State var enablePaper = true;
    let font = Font.system(size: 125)
    var body: some View {
        Text("Drag the trash into the bin!")
            .font(.largeTitle)
        Text("🗑️")
            .font(font)
            .offset(CGSize(width: CGFloat.random(in: -200...200), height: CGFloat.random(in: -200...200)))
            .dropDestination(for: String.self) { items, location in
                if  items.first == "📄" {
                            enablePaper = false;
                        }
                return true
            }
        if enablePaper {
            Text("📄")
                .draggable(String("📄"))
                .font(font)
                .offset(CGSize(width: CGFloat.random(in: -200...200), height: CGFloat.random(in: -200...200)))
        }
    }
}

#Preview {
    DragNDrop()
}


