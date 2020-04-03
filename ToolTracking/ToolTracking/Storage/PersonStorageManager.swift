//
//  PersonStorageManager.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PersonStorageManager : StorageManager{
    
    override func initDefaultValue() {
        if fetchData().count == 0 {
            _ = insert(id: 1, name: "Brian")
            _ = insert(id: 2, name: "Luke")
            _ = insert(id: 3, name: "Letty")
            _ = insert(id: 4, name: "Shaw")
            _ = insert(id: 5, name: "Parker")
            save()
        }
    }
    
    //MARK: Function
    func fetchData() -> [Person] {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Person]()
    }
    
    func insert(id: Int32, name: String) -> Person? {
        guard let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: backgroundContext) as? Person else { return nil}
        person.id = id
        person.name = name
        return person
    }

    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
    
}
