//
//  ViewModel.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import Foundation
import SwiftUI
import CoreData

final class ViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [TaskModel] = []
    @Published var filteredTasks: [TaskModel] = []
    @Published var isEditingTask: Bool = false
    @Published var taskToEdit: TaskModel? = nil
    @Published var searchText: String = ""
    
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
    
    // MARK: - Formatters
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    // MARK: - Fetch Tasks
    
    // Note:
    // In production I’d use a dedicated background NSManagedObjectContext
    // instead of just GCD. This prevents threading violations and scales better.
    // For this task I used GCD as required in the instructions.
    
    func fetchTasks() {
        if isFirstLaunch {
            Task {
                await fetchInitialTodosFromAPI()
            }
        } else {
            fetchTasksFromCoreData()
        }
    }
    
    func fetchInitialTodosFromAPI() async {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(TodoResponse.self, from: data)
            
            // Create tasks in the context
            var tempTasks: [TaskModel] = []
            
            for todo in decoded.todos {
                let task = TaskModel(context: context)
                task.id = Int32(todo.id)
                task.title = "Задача №\(todo.id)"
                task.entry = todo.todo
                task.completed = todo.completed
                task.dateCreated = Date()
                
                tempTasks.append(task)
            }
            saveContext()
            
            Task{
                await MainActor.run {
                    tasks = tempTasks
                    filteredTasks = tempTasks
                }
            }
        } catch {
            print("Error fetching todos: \(error)")
        }
    }
    
    func fetchTasksFromCoreData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskModel.dateCreated, ascending: true)]
            
            do {
                print("Fetching from coreData")
                let fetched = try context.fetch(request)
                
                DispatchQueue.main.async {
                    self.tasks = fetched
                    self.filteredTasks = fetched
                }
            } catch {
                print("Fetch error: \(error)")
            }
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
                }
            } catch {
                print("Error fetching filtered tasks: \(error)")
            }
        }
    }
    
    // MARK: - Task Operations
    
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
    
    func saveTask(taskId: Int32?, title: String, entry: String) {
        if let id = taskId {
            editTask(id: id, title: title, entry: entry)
        } else {
            createTask(title: title, entry: entry)
        }
        // reset variables
        taskToEdit = nil
        isEditingTask = false
    }
    
    func editTask(id: Int32, title: String, entry: String) {
        guard let index = filteredTasks.firstIndex(where: { $0.id == id }) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Update Core Data object
            if let task = filteredTasks.first(where: { $0.id == id }) {
                task.title = title
                task.entry = entry
                saveContext()
            }
            // Update UI
            DispatchQueue.main.async {
                self.filteredTasks[index].title = title
                self.filteredTasks[index].entry = entry
            }
        }
    }
    
    func createTask(title: String, entry: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let newTask = TaskModel(context: context)
            newTask.id = generateNewId()
            newTask.title = title
            newTask.entry = entry
            newTask.dateCreated = Date()
            newTask.completed = false
            
            saveContext()
            
            // Update UI
            DispatchQueue.main.async {
                self.filteredTasks.append(newTask)
            }
        }
    }
    
    func generateNewId() -> Int32 {
        // always looks for the highest existing ID and increments it
        (filteredTasks.map { $0.id }.max() ?? 0) + 1
    }
    
    func toggleTaskCompletion(_ task: TaskModel) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            task.completed.toggle()
            saveContext()
        }
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks[index] = filteredTasks[index]
        }
    }
    
    func deleteTask(_ task: TaskModel) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            context.delete(task)
            
            saveContext()
        }
        
        filteredTasks.removeAll(where: { $0.id == task.id })
    }
    
    // MARK: - Core Data Saving
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
