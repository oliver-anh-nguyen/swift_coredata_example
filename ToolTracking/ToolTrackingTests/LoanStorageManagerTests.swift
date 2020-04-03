//
//  LoanStorageManagerTests.swift
//  ToolTrackingTests
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import XCTest
import CoreData

@testable import ToolTracking

class LoanStorageManagerTests: XCTestCase {
    
    var mockStorageManager: LoanStorageManager!
    var saveNotificationCompleteHandler: ((Notification)->())?
    
    //MARK: mock in-memory persistant store
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentLoanStorageManager", managedObjectModel: self.managedObjectModel)
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
        mockStorageManager = LoanStorageManager(container: mockPersistantContainer)
        
        //Listen to the change in context
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave , object: nil)
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        flushData()
        super.tearDown()
    }
    
    func test_add_loan() {
        // Given
        let idPeson: Int32 = 1
        let idTool: Int32 = 11
        
        // When
        let newLoan = mockStorageManager.insert(idPerson: idPeson, idTool: idTool)
        
        // Then
        XCTAssertNotNil(newLoan)
    }
    
    func test_fetch_all_loans() {
        // Given
        
        // When
        let results = mockStorageManager.fetchData()
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func test_remove_loan() {
        // Given
        let items = mockStorageManager.fetchData()
        let item = items[0]
        
        let numberOfItems = items.count
        
        // When
        mockStorageManager.remove(objectID: item.objectID)
        mockStorageManager.save()
        
        // Then
        XCTAssertEqual(numberOfItemsInPersistentStore(), numberOfItems-1)
    }
    
    func test_save() {
        // Give
        let idPerson: Int32 = 2
        let idTool: Int32 = 22
        
        _ = expectationForSaveNotification()
        _ = mockStorageManager.insert(idPerson: idPerson, idTool: idTool)
        
        // When
        
        // Then
        expectation(forNotification: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue), object: nil, handler: nil)
        mockStorageManager.save()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func test_get_tool() {
        // Given
        let listIdPerson = 2
    
        // When
        let arrLoan = mockStorageManager.getTools(idPerson: Int32(listIdPerson))
        
        // Then
        XCTAssertEqual(arrLoan.count, 1)
    }
}


extension LoanStorageManagerTests {
    
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
        func insert(idPerson: Int32, idTool: Int32) -> Loan? {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Loan", into: mockPersistantContainer.viewContext)
            
            obj.setValue(idPerson, forKey: "idPerson")
            obj.setValue(idTool, forKey: "idTool")
            
            return obj as? Loan
        }
        
        _ = insert(idPerson: 1, idTool: 11)
        _ = insert(idPerson: 2, idTool: 22)
        
        do {
            try mockPersistantContainer.viewContext.save()
        }  catch {
            print("create fakes error \(error)")
        }
        
    }
    
    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Loan")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
    
    func numberOfItemsInPersistentStore() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Loan")
        let results = try! mockPersistantContainer.viewContext.fetch(request)
        return results.count
    }
    
}
