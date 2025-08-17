//
//  TaskRow.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI
import CoreData

struct TaskRow: View {
    var task: TaskModel
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack (alignment: .top) {
                Button {
                    viewModel.toggleTaskCompletion(task)
                } label: {
                    Image(systemName: task.completed ? "checkmark.circle" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(task.completed ? .accent : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 5){
                Text(task.displayTitle)
                    .font(.title2)
                    .strikethrough(task.completed ? true : false)
                
                Text(task.wrappedEntry)
                Text(viewModel.dateFormatter.string(from: task.wrappedDate))
                    .font(.subheadline)
            }
            .foregroundStyle(task.completed ? .secondary : .primary)
            .transition(.opacity)
            
        }
        .animation(.bouncy, value: task.completed)
        .contextMenu {
            Button {
                // edit
                viewModel.taskToEdit = task
                viewModel.isEditingTask = true
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
                viewModel.deleteTask(task)
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
    let context = PersistenceController.preview.container.viewContext
        
        // Create a sample task in the preview's in-memory Core Data
        let sampleTask = TaskModel(context: context)
        sampleTask.id = 123
        sampleTask.title = "Preview Task"
        sampleTask.entry = "This is just a preview entry."
        sampleTask.dateCreated = .now
        sampleTask.completed = false
        
    return TaskRow(task: sampleTask)
        .environmentObject(ViewModel(context: context))
        .environment(\.managedObjectContext, context)
}
