import SwiftUI

struct DragNDrop: View {
    @State var enablePaper = true;
    let font = Font.system(size: 125)
    var body: some View {
        Text("🗑️")
            .font(font)
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
        }
    }
}

#Preview {
    DragNDrop()
}
