//
//  ViewModel_Tests.swift
//  ToDoListTests
//
//  Created by Марина on 17.08.2025.
//

import XCTest
@testable import ToDoList
import CoreData

final class ViewModel_Tests: XCTestCase {
    var viewModel: MainViewModel!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Self.inMemoryContext()
        viewModel = MainViewModel(context: context)
    }

    override func tearDownWithError() throws {
        context = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    
    static func inMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container.viewContext
    }

    func testGenerateNewId_returnsUniqueId() {
        // Given
        viewModel.createTask(title: "Test Task 1", entry: "Test Entry")
        viewModel.createTask(title: "Test Task 2", entry: "Test Entry")
        // When
        let id = viewModel.generateNewId()
        // Then
        XCTAssertEqual(id, 3)
    }
    
    func testSaveTask_addsNewTask() {
        // Given
        let initialCount = viewModel.filteredTasks.count
        // When
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        // Then
        XCTAssertEqual(self.viewModel.filteredTasks.count, initialCount + 1)
        XCTAssertEqual(self.viewModel.filteredTasks.last?.title, "Test Task")
    }

    func testSaveTask_editsExistingTask() {
        // Given
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        // When
        guard let taskToEdit = self.viewModel.filteredTasks.first else {
            XCTFail("No task created")
            return
        }
        self.viewModel.saveTask(taskId: taskToEdit.id, title: "Updated", entry: "Updated Entry")
        
        // Then
        XCTAssertEqual(self.viewModel.filteredTasks.first?.title, "Updated")
    }
    func testToggleTaskCompletion_marksTaskAsComplete() {
        // Given
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        // When
        guard let taskToToggle = self.viewModel.filteredTasks.first else {
            XCTFail("No task created")
            return
        }
        
        self.viewModel.toggleTaskCompletion(taskId: taskToToggle.id)
        
        // Then
        XCTAssertEqual(self.viewModel.filteredTasks.first?.completed, true)
    }
    
    func testDeleteTask_deletesTaskFromStore() {
        // Given
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        // When
        guard let taskToDelete = self.viewModel.filteredTasks.first else {
            XCTFail("No task created")
            return
        }
        
        self.viewModel.deleteTask(taskId: taskToDelete.id)
        
        // Then
        XCTAssertEqual(self.viewModel.filteredTasks.isEmpty, true)
    }
}
