//
//  MainView.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(context: context))
    }
    
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack{
                List {
                    ForEach(viewModel.tasksForRows, id: \.id) { task in
                        NavigationLink {
                            TaskDetailView(
                                task: task,
                                isEditMode: viewModel.isEditingTask,
                                title: $viewModel.titleForDetailView,
                                entry: $viewModel.entryForDetailView,
                                onSave: {
                                    viewModel.saveTask(taskId: task.id, title: viewModel.titleForDetailView, entry: viewModel.entryForDetailView)
                                }
                            )
                        } label: {
                            TaskRow(
                                data: task,
                                onToggleCompleted: { viewModel.toggleTaskCompletion(taskId: task.id)},
                                onDelete: {viewModel.deleteTask(taskId: task.id)},
                                onEdit: {
                                    // passing existing task to edit
                                    viewModel.startEditingTask(taskId: task.id)
                                }
                            )
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $viewModel.searchText, placement: .toolbar, prompt: "Search")
                .listStyle(.plain)
                .onChange(of: viewModel.searchText, {
                    viewModel.updateFilteredTasks()
                })
            }
            .navigationTitle("Задачи")
            .environmentObject(viewModel)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    BottomToolbar(text: viewModel.tasksCountString()) {
                        viewModel.isEditingTask.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isEditingTask) {
                // passing nil to add new task in the view
                TaskDetailView(
                    task: viewModel.selectedTaskToEdit,
                    isEditMode: viewModel.isEditingTask,
                    title: $viewModel.titleForDetailView,
                    entry: $viewModel.entryForDetailView,
                    onSave: {
                        viewModel.saveTask(
                            taskId: viewModel.selectedTaskToEdit?.id,
                            title: viewModel.titleForDetailView,
                            entry: viewModel.entryForDetailView
                        )
                    }
                )
            }
        }
    }
}

#Preview {
    MainView(context: PersistenceController.preview.container.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
