//
//  TaskDetailView..swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI

struct TaskDetailView: View {
    var task: TaskModel? // If nil → new task, otherwise existing
    @State private var taskId: Int32 = 0
    @State private var title: String = ""
    @State private var entry: String = ""
    @State private var dateCreated: Date = Date()
    @EnvironmentObject var viewModel: ViewModel
    
    func saveTask() {
        viewModel.saveTask(taskId: task?.id, title: title, entry: entry)
    }
    
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
           
            VStack(alignment: .leading, spacing: 10){
                if viewModel.isEditingTask {
                    TextField("Введите название", text: $title)
                        .font(.title)
                        .bold()
                        .textFieldStyle(.plain)
                    
                    TextEditor(text: $entry)
                        .frame(height: 200)
                        .textEditorStyle(.plain)
                } else {
                    Text(title.isEmpty ? "Задача №\(taskId)" : title)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.primary)
                    
                    Text(viewModel.dateFormatter.string(from: dateCreated))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    
                    Text(entry)
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                if let t = task {
                    taskId = t.id
                    title = t.displayTitle
                    entry = t.wrappedEntry
                    dateCreated = t.wrappedDate
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isEditingTask {
                        Button {
                            saveTask()
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
    let context = PersistenceController.preview.container.viewContext
        
        // Create a sample task in the preview's in-memory Core Data
        let sampleTask = TaskModel(context: context)
        sampleTask.id = 123
        sampleTask.title = "Preview Task"
        sampleTask.entry = "This is just a preview entry."
        sampleTask.dateCreated = .now
        sampleTask.completed = false
    
    return TaskDetailView(task: sampleTask)
        .environmentObject(ViewModel(context: context))
        .environment(\.managedObjectContext, context)
}
