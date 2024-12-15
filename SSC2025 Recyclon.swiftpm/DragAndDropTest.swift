import SwiftUI

struct DragNDrop: View {
    @State var enablePaper = true;
    let font = Font.system(size: 125)
    var body: some View {
        Text("Drag the trash into the bin!")
            .font(.largeTitle)
        ZStack{
            let offset = CGSize(width: CGFloat.random(in: -200...200), height: CGFloat.random(in: -200...200))
            Text("🗑️")
                .font(font)
                .offset(offset)
                .dropDestination(for: String.self) { items, location in
                    if  items.first == "📄" {
                        enablePaper = false;
                    }
                    return true
                }
            Text("♻️")
                .offset(offset)
                .font(.system(size: 62))
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


