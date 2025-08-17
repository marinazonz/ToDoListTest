//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Марина on 12.08.2025.
//

import SwiftUI
import CoreData

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView(context: persistenceController.container.viewContext)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
