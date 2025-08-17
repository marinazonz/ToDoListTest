//
//  MainView.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    @StateObject private var viewModel: ViewModel
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ViewModel(context: context))
    }
    
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack{
                List {
                    ForEach(viewModel.filteredTasks, id: \.id) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                                .environmentObject(viewModel)
                        } label: {
                            TaskRow(task: task)
                                .environmentObject(viewModel)
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
                        viewModel.isEditingTask = true
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isEditingTask) {
                // passing nil to add new task in the view
                // passing existing task to edit
                TaskDetailView(task: viewModel.taskToEdit)
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    MainView(context: PersistenceController.preview.container.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
