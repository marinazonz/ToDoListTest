//
//  TaskRow.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI

struct TaskRow: View {
    var data: TaskRowViewData
    let onToggleCompleted: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack (alignment: .top) {
                Button {
                    onToggleCompleted()
                } label: {
                    Image(systemName: data.completed ? "checkmark.circle" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(data.completed ? .accent : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 5){
                Text(data.title)
                    .font(.title2)
                    .strikethrough(data.completed ? true : false)
                
                Text(data.entry)
                
                Text(data.formattedDate)
                    .font(.subheadline)
            }
            .foregroundStyle(data.completed ? .secondary : .primary)
            .transition(.opacity)
            
        }
        .animation(.bouncy, value: data.completed)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                HStack{
                    Text("Редактировать")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }

            Button {
                // share
            } label: {
                HStack{
                    Text("Поделиться")
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                HStack{
                    Text("Удалить")
                    Spacer()
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    TaskRow(data: TaskRowViewData.mock, onToggleCompleted: {}, onDelete: {}, onEdit: {})
}
