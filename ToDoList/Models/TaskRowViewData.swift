//
//  JSONModels.swift
//  ToDoList
//
//  Created by Марина on 14.08.2025.
//

import Foundation

struct TaskRowViewData: Identifiable {
    let id: Int32
    let title: String
    let entry: String
    let completed: Bool
    let formattedDate: String
}

extension TaskRowViewData {
    static let mock = TaskRowViewData(
        id: 1,
        title: "Test task",
        entry: "This is a test task",
        completed: false,
        formattedDate: "19/08/2025"
    )
}
