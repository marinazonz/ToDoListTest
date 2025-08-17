//
//  TaskModel+CoreDataProperties.swift
//  ToDoList
//
//  Created by Марина on 14.08.2025.
//
//

import Foundation
import CoreData


extension TaskModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskModel> {
        return NSFetchRequest<TaskModel>(entityName: "TaskEntity")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var entry: String?
    @NSManaged public var id: Int32
    @NSManaged public var title: String?

}

extension TaskModel : Identifiable {
    var wrappedTitle: String {
        title ?? "Задача №\(id)"
    }
    
    var displayTitle: String {
        if let t = title, !t.isEmpty {
            return t
        } else {
            return "Задача №\(id)"
        }
    }
    
    var wrappedEntry: String {
        entry ?? ""
    }
    
    var wrappedDate: Date {
        dateCreated ?? .now
    }
}
