//
//  MainViewModel.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import Foundation
import SwiftUI
import CoreData

final class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var filteredTasks: [TaskModel] = [] // source of truth
    //@Published var tasksForRows: [TaskRowViewData] = [] // array for TaskRowView
    
    @Published var selectedTaskToEdit: TaskRowViewData? = nil
    @Published var isEditingTask: Bool = false
    @Published var searchText: String = ""
    
    // Properties for DetailView
    @Published var titleForDetailView: String = ""
    @Published var entryForDetailView: String = ""
    
    // MARK: - Core Data
    private let context: NSManagedObjectContext
    
    // MARK: - Initializer
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
    }
    
    // MARK: - Computed Properties
    var isFirstLaunch: Bool {
        let key = "hasLaunchedBefore"
        let launched = UserDefaults.standard.bool(forKey: key)
        if !launched {
            UserDefaults.standard.set(true, forKey: key)
        }
        print("isFirstLaunch \(!launched)")
        return !launched
    }
    
    var tasksForRows: [TaskRowViewData] {
        filteredTasks.map(makeRowData)
    }
    
    // MARK: - Formatters
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    // MARK: - Fetch Tasks
    
    // Note:
    // use a dedicated background NSManagedObjectContext
    
    func fetchTasks() { // on the first launch fetching from API, saving to CoreData. On the second and further - fetching from CoreData.
        if isFirstLaunch {
            Task {
                let fetched = await DataManager.shared.fetchInitialTodosFromAPI(context: context)
                
                await MainActor.run {
                    filteredTasks = fetched
                    //syncTasks()
                }
            }
        } else {
            let fetched = DataManager.shared.fetchTasksFromCoreData(context: context)
            filteredTasks = fetched
            //syncTasks()
        }
    }

    // MARK: - Filtering
    
    func updateFilteredTasks() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskModel.dateCreated, ascending: true)]
            
            if !query.isEmpty {
                // Predicate: search title OR entry, case-insensitive, diacritic-insensitive
                fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR entry CONTAINS[cd] %@", query, query)
            }
            
            do {
                let results = try context.fetch(fetchRequest)
                
                DispatchQueue.main.async {
                    self.filteredTasks = results
                    //self.syncTasks()
                }
            } catch {
                print("Error fetching filtered tasks: \(error)")
            }
        }
    }
    
    // MARK: - Task Operations
    func makeRowData(from task: TaskModel) -> TaskRowViewData {
        TaskRowViewData(
            id: task.id,
            title: task.displayTitle,
            entry: task.wrappedEntry,
            completed: task.completed,
            formattedDate: dateFormatter.string(from: task.wrappedDate)
        )
    }
    
//    func syncTasks() {
//        tasksForRows = filteredTasks.map(makeRowData)
//    }
    
    func tasksCountString() -> String {
        let count = filteredTasks.count
        let rem100 = count % 100
        let rem10 = count % 10
        
        let word: String
        if rem100 >= 11 && rem100 <= 14 {
            word = "задач"
        } else {
            switch rem10 {
            case 1: word = "задача"
            case 2...4: word = "задачи"
            default: word = "задач"
            }
        }
        
        return "\(count) \(word)"
    }
    
    func startEditingTask(taskId: Int32?) {
        isEditingTask = true
        
        if let id = taskId,
           let task = filteredTasks.first(where: { $0.id == id }) {
            // passing existing task to edit
            let taskToEdit = makeRowData(from: task)
            selectedTaskToEdit = taskToEdit
            titleForDetailView = taskToEdit.title
            entryForDetailView = taskToEdit.entry
        } else {
            // passing nil to add new task in the view
            selectedTaskToEdit = nil
        }
    }
    
    func saveTask(taskId: Int32?, title: String, entry: String) {
        if let id = taskId {
            editTask(id: id, title: title, entry: entry)
        } else {
            createTask(title: title, entry: entry)
        }
        // reset variables
        isEditingTask = false
        selectedTaskToEdit = nil
        titleForDetailView = ""
        entryForDetailView = ""
    }
    
    func editTask(id: Int32, title: String, entry: String) {
        guard let index = filteredTasks.firstIndex(where: { $0.id == id }) else { return }
        
        // Update Core Data object
        if let task = filteredTasks.first(where: { $0.id == id }) {
            task.title = title
            task.entry = entry
            DataManager.shared.saveContext(context)
            }
        // Update UI
        
        filteredTasks[index].title = title
        filteredTasks[index].entry = entry
        //syncTasks()
    }
    
    func createTask(title: String, entry: String) {
        let newTask = TaskModel(context: context)
        newTask.id = generateNewId()
        newTask.title = title
        newTask.entry = entry
        newTask.dateCreated = Date()
        newTask.completed = false
        
        DataManager.shared.saveContext(context)
        
        // Update UI
        filteredTasks.append(newTask)
        //syncTasks()
    }
    
    func generateNewId() -> Int32 {
        // always looks for the highest existing ID and increments it
        (filteredTasks.map { $0.id }.max() ?? 0) + 1
    }
    
    func toggleTaskCompletion(taskId: Int32) {
        if let task = filteredTasks.first(where: { $0.id == taskId }) {
            task.completed.toggle()
            DataManager.shared.saveContext(context)
        }
        
        if let index = filteredTasks.firstIndex(where: { $0.id == taskId }) {
            filteredTasks[index] = filteredTasks[index]
        }
        //syncTasks()
    }
    
    func deleteTask(taskId: Int32) {
        if let task = filteredTasks.first(where: { $0.id == taskId }) {
            context.delete(task)
        }
        // Update UI
        filteredTasks.removeAll(where: { $0.id == taskId })
        
        DataManager.shared.saveContext(context)
    }
}
