//
//  PersonStorageManagerTests.swift
//  ToolTrackingTests
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import XCTest
import CoreData

@testable import ToolTracking

class PersonStorageManagerTests: XCTestCase {
    
    var mockStorageManager: PersonStorageManager!
    var saveNotificationCompleteHandler: ((Notification)->())?
    
    //MARK: mock in-memory persistant store
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentPersonStorageManager", managedObjectModel: self.managedObjectModel)
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
        mockStorageManager = PersonStorageManager(container: mockPersistantContainer)
        
        //Listen to the change in context
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave , object: nil)
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        flushData()
        super.tearDown()
    }
    
    func test_add_person() {
        // Given
        let id: Int32 = 1
        let name: String = "Person1"
        
        // When
        let newPerson = mockStorageManager.insert(id: id, name: name)
        
        // Then
        XCTAssertNotNil(newPerson)
    }
    
    func test_fetch_all_persons() {
        // Given
        
        // When
        let results = mockStorageManager.fetchData()
        
        // Then
        XCTAssertEqual(results.count, 5)
    }
    
    func test_save() {
        // Give
        let id: Int32 = 1
        let name: String = "Person1"
        
        _ = expectationForSaveNotification()
        _ = mockStorageManager.insert(id: id, name: name)
        
        // When
        
        // Then
        expectation(forNotification: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue), object: nil, handler: nil)
        mockStorageManager.save()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}


extension PersonStorageManagerTests {
    
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
        func insert(id: Int32, name: String) -> Person? {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Person", into: mockPersistantContainer.viewContext)
            
            obj.setValue("person1", forKey: "name")
            obj.setValue(1, forKey: "id")
            
            return obj as? Person
        }
        
        _ = insert(id: 1, name: "person1")
        _ = insert(id: 2, name: "person2")
        _ = insert(id: 3, name: "person3")
        _ = insert(id: 4, name: "person4")
        _ = insert(id: 5, name: "person5")
        
        do {
            try mockPersistantContainer.viewContext.save()
        }  catch {
            print("create fakes error \(error)")
        }
        
    }
    
    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
    
}

