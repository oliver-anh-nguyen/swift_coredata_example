//
//  ToolStorageManager.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ToolStorageManager : StorageManager {
    
    override func initDefaultValue() {
        if fetchData().count == 0 {
            _ = insert(id: 1, name: "Wrench", total: 6)
            _ = insert(id: 2, name: "Cutter", total: 15)
            _ = insert(id: 3, name: "Pliers", total: 12)
            _ = insert(id: 4, name: "Screwdriver", total: 13)
            _ = insert(id: 5, name: "Welding machine", total: 3)
            _ = insert(id: 6, name: "Welding glasses", total: 7)
            _ = insert(id: 7, name: "Hammer", total: 4)
            _ = insert(id: 8, name: "Measuring Tape", total: 9)
            _ = insert(id: 9, name: "Alan key set", total: 4)
            _ = insert(id: 10, name: "Air compressor", total: 2)
            save()
        }
    }
    
    //MARK: Function
    func fetchData() -> [Tool] {
        let request: NSFetchRequest<Tool> = Tool.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Tool]()
    }
    
    func insert(id: Int32, name: String, total: Int32 ) -> Tool? {
        guard let tool = NSEntityDescription.insertNewObject(forEntityName: "Tool", into: backgroundContext) as? Tool else { return nil }
        tool.id = id
        tool.name = name
        tool.remain = total
        tool.total = total
        return tool
    }
    
    func updateTool(toolId: Int32, name: String?, isIncrease: Bool) {
        let request: NSFetchRequest<Tool> = Tool.fetchRequest()

        request.predicate = NSPredicate(format: "id = %@ AND name = %@",
                                        argumentArray: [toolId, name ?? ""])
        
        do {
            let results = try backgroundContext.fetch(request)
            if results.count != 0 {
                let tool = results[0]
                let newValue = isIncrease ? tool.remain+1 : tool.remain-1
                tool.setValue(newValue, forKey: "remain")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        self.save()
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
