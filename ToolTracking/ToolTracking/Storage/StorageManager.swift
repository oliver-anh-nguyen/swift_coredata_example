//
//  StorageManager.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class StorageManager {
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    let persistentContainer: NSPersistentContainer!
    
    //MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get shared app delegate")
        }
        self.init(container: appDelegate.persistentContainer)
        self.initDefaultValue()
    }
    
    func initDefaultValue() {
    }
    
}
