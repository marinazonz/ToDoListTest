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
    var viewModel: ViewModel!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Self.inMemoryContext()
        viewModel = ViewModel(context: context)
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
        XCTAssertNotEqual(id, 3)
    }
    
    func testSaveTask_addsNewTask() {
        // Given
        let expectation = XCTestExpectation(description: "Task should be created")
        let initialCount = viewModel.filteredTasks.count
        // When
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.viewModel.filteredTasks.count, initialCount + 1)
            XCTAssertEqual(self.viewModel.filteredTasks.last?.title, "Test Task")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testSaveTask_editsExistingTask() {
        // Given
        let expectation = XCTestExpectation(description: "Task should be edited")
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // When
            guard let taskToEdit = self.viewModel.filteredTasks.first else {
                XCTFail("No task created")
                expectation.fulfill()
                return
            }
            self.viewModel.saveTask(taskId: taskToEdit.id, title: "Updated", entry: "Updated Entry")
            
            // Then
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(self.viewModel.filteredTasks.first?.title, "Updated")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    func testToggleTaskCompletion_marksTaskAsComplete() {
        // Given
        let expectation = XCTestExpectation(description: "Task should be completed")
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // When
            guard let taskToToggle = self.viewModel.filteredTasks.first else {
                XCTFail("No task created")
                expectation.fulfill()
                return
            }
            
            self.viewModel.toggleTaskCompletion(taskToToggle)
            
            // Then
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(self.viewModel.filteredTasks.first?.completed, true)
                expectation.fulfill()
            }
        }
    }
    
    func testDeleteTask_deletesTaskFromStore() {
        // Given
        let expectation = XCTestExpectation(description: "Task should be deleted")
        viewModel.saveTask(taskId: nil, title: "Test Task", entry: "Test Entry")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // When
            guard let taskToDelete = self.viewModel.filteredTasks.first else {
                XCTFail("No task created")
                expectation.fulfill()
                return
            }
            
            self.viewModel.deleteTask(taskToDelete)
            
            // Then
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(self.viewModel.filteredTasks.isEmpty, true)
                expectation.fulfill()
            }
        }
    }
    
    
}
