//
//  TaskDetailView..swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI

struct TaskDetailView: View {
    var task: TaskRowViewData? // If nil → new task, otherwise existing
    let isEditMode: Bool
    @Binding var title: String
    @Binding var entry: String
    let onSave: () -> Void

    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
           
            VStack(alignment: .leading, spacing: 10){
                if isEditMode {
                    TextField("Введите название", text: $title)
                        .font(.title)
                        .bold()
                        .textFieldStyle(.plain)
                    
                    TextEditor(text: $entry)
                        .frame(height: 200)
                        .textEditorStyle(.plain)
                } else {
                    if let task = task {
                        Text(task.title)
                            .font(.title)
                            .bold()
                            .foregroundStyle(.primary)
                        
                        Text(task.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                        
                        Text(task.entry)
                            .foregroundStyle(.primary)
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditMode {
                        Button {
                           onSave()
                        } label: {
                            Text("Готово")
                                .foregroundStyle(.accent)
                        }

                    }
                }
            })
        }
    }
}

#Preview {
    TaskDetailView(
        task:TaskRowViewData.mock,
        isEditMode: false,
        title: .constant("Preview title"),
        entry: .constant("Preview entry"),
        onSave: {}
    )
}
