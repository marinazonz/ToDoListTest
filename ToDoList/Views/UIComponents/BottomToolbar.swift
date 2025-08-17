//
//  BottomToolbar.swift
//  ToDoList
//
//  Created by Марина on 17.08.2025.
//

import SwiftUI

struct BottomToolbar: View {
    let text: String
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.accent)
            }
        }
    }
}

#Preview {
    BottomToolbar(text: "5 Задач", onAdd: {})
}
