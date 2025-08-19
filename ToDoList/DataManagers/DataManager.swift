//
//  DataManager.swift
//  ToDoList
//
//  Created by Марина on 19.08.2025.
//

import Foundation
import CoreData

struct DataManager {
    static let shared = DataManager()
    private init() {}
    
    // MARK: - Fetch data from API
    func fetchInitialTodosFromAPI(context: NSManagedObjectContext) async -> [TaskModel] {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return []
        }
        do {
            var tempTasks: [TaskModel] = []
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let todos = json["todos"] as? [[String: Any]] {
                for iteam in todos {
                    let id = iteam["id"] as? Int ?? 0
                    let entry = iteam["todo"] as? String ?? ""
                    let completed = iteam["completed"] as? Bool ?? false
                    
                    let task = TaskModel(context: context)
                    task.id = Int32(id)
                    task.title = "Задача №\(String(describing: id))"
                    task.entry = entry
                    task.completed = completed
                    task.dateCreated = Date()
                    
                    tempTasks.append(task)
                }
            }
            saveContext(context)
          return tempTasks
        } catch {
            print("Error fetching todos: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch data from Core Data
    
    // add here working on different threads
    func fetchTasksFromCoreData(context: NSManagedObjectContext) -> [TaskModel] {
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskModel.dateCreated, ascending: true)]
        
        do {
            print("Fetching from coreData")
            let tasks = try context.fetch(request)
            return tasks
        } catch {
            print("Fetch error: \(error)")
        return []
        }
    }
    
    // MARK: - Saving Data in CoreData
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Context saved successfully.")
        } catch {
            print("Failed to save the context: \(error)")
        }
    }
}
