//
//  SwiftUIView.swift
//  Recyclon
//
//  Created by Αλέξανδρος Σαμωνάκης on 16/12/24.
//

import SwiftUI

struct Trash: View {
    let trashEmoji : String
    var body: some View {
        Text(trashEmoji)
            .draggable(String(trashEmoji))
            .font(.largeTitle)
    }
}

#Preview {
    Trash(trashEmoji: "📄")
}
