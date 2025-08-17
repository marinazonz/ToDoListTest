//
//  JSONModels.swift
//  ToDoList
//
//  Created by Марина on 14.08.2025.
//

import Foundation

struct TodoResponse: Codable {
    let todos: [TodoJSON]
}

struct TodoJSON: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

struct TODOforCoreData: Codable {
    let id: Int32
    let title: String
    let entry: String
    let completed: Bool
    let dateCreated: Date
}
