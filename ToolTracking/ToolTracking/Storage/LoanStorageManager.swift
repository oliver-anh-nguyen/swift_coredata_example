//
//  LoanStorageManager.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LoanStorageManager : StorageManager {
    
    //MARK: Function
    func fetchData() -> [Loan] {
        let request: NSFetchRequest<Loan> = Loan.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Loan]()
    }
    
    func getTools(idPerson: Int32) -> [Loan] {
        let request: NSFetchRequest<Loan> = Loan.fetchRequest()

        request.predicate = NSPredicate(format: "idPerson = %@",
                                             argumentArray: [idPerson])
        
        let results = try? backgroundContext.fetch(request)
        if results?.count != 0 {
            return results ?? [Loan]()
        }
        return [Loan]()
    }
    
    func getNameTool(idTool: Int32) -> String {
        let request: NSFetchRequest<Tool> = Tool.fetchRequest()

        request.predicate = NSPredicate(format: "id = %@",
                                             argumentArray: [idTool])
        
        let results = try? backgroundContext.fetch(request)
        if results?.count != 0 {
            return results?[0].name ?? ""
        }
        return ""
    }
    
    func updateLoan(idPerson: Int32, idTool: Int32, isIncrease: Bool) {
        let request: NSFetchRequest<Loan> = Loan.fetchRequest()

        request.predicate = NSPredicate(format: "idPerson = %@ AND idTool = %@",
                                             argumentArray: [idPerson, idTool])
        
        do {
            let results = try backgroundContext.fetch(request)
            if results.count != 0 {
                let loan = results[0]
                let newValue = isIncrease ? loan.totalTool+1 : loan.totalTool-1
                if (newValue == 0) {
                    self.remove(objectID: loan.objectID)
                } else {
                    loan.setValue(newValue, forKey: "totalTool")
                }
            } else {
                _ = self.insert(idPerson: idPerson, idTool: idTool)
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        self.save()
    }
    
    func insert(idPerson: Int32, idTool: Int32 ) -> Loan? {
        guard let loan = NSEntityDescription.insertNewObject(forEntityName: "Loan", into: backgroundContext) as? Loan else { return nil }
        loan.idPerson = idPerson
        loan.idTool = idTool
        loan.nameTool = self.getNameTool(idTool: idTool)
        loan.totalTool = 1
        return loan
    }

    func remove( objectID: NSManagedObjectID ) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
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
