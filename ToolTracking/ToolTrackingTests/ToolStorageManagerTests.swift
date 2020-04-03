//
//  ToolStorageManagerTests.swift
//  ToolTrackingTests
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import XCTest
import CoreData

@testable import ToolTracking

class ToolStorageManagerTests: XCTestCase {
    
    var mockStorageManager: ToolStorageManager!
    var saveNotificationCompleteHandler: ((Notification)->())?
    
    //MARK: mock in-memory persistant store
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentToolStorageManager", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
    
    override func setUp() {
        initStubs()
        mockStorageManager = ToolStorageManager(container: mockPersistantContainer)
        
        //Listen to the change in context
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave , object: nil)
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        flushData()
        super.tearDown()
    }
    
    func test_create_tool() {
        // Given
        let id: Int32 = 1
        let name: String = "tool1"
        let total: Int32 = 10
        
        // When
        let newTool = mockStorageManager.insert(id: id, name: name, total: total)
        
        // Then
        XCTAssertNotNil(newTool)
    }
    
    func test_fetch_all_tools() {
        // Given
        
        // When
        let results = mockStorageManager.fetchData()
        
        // Then
        XCTAssertEqual(results.count, 5)
    }
    
    func test_save() {
        // Give
        let id: Int32 = 1
        let name: String = "tool1"
        let total: Int32 = 10
        
        _ = expectationForSaveNotification()
        _ = mockStorageManager.insert(id: id, name: name, total: total)
        
        // When
        
        // Then
        expectation(forNotification: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue), object: nil, handler: nil)
        mockStorageManager.save()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}


extension ToolStorageManagerTests {
    
    //MARK: Convinient function for notification
    func expectationForSaveNotification() -> XCTestExpectation {
        let expect = expectation(description: "Context Saved")
        waitForSavedNotification { (notification) in
            expect.fulfill()
        }
        return expect
    }
    
    func waitForSavedNotification(completeHandler: @escaping ((Notification)->()) ) {
        saveNotificationCompleteHandler = completeHandler
    }
    
    func contextSaved( notification: Notification ) {
        print("\(notification)")
        saveNotificationCompleteHandler?(notification)
    }
    
    //MARK: Creat some fakes
    func initStubs() {
        
        func insertTool(id: Int32, name: String, total: Int32 ) -> Tool? {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Tool", into: mockPersistantContainer.viewContext)
            
            obj.setValue("tool1", forKey: "name")
            obj.setValue(1, forKey: "id")
            obj.setValue(6, forKey: "total")
            
            return obj as? Tool
        }
        
        _ = insertTool(id: 1, name: "tool1", total: 6)
        _ = insertTool(id: 2, name: "tool2", total: 15)
        _ = insertTool(id: 3, name: "tool3", total: 12)
        _ = insertTool(id: 4, name: "tool4", total: 13)
        _ = insertTool(id: 5, name: "tool5", total: 3)
        
        do {
            try mockPersistantContainer.viewContext.save()
        }  catch {
            print("create fakes error \(error)")
        }

    }
    
    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Tool")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
    
}

