//
//  DataController.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/30/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer

    // Return persistent container's view context
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // Initialize data controller with name of model
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }

    func configureContexts() {
    
        viewContext.automaticallyMergesChangesFromParent = true
    
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    
    }

    // Load persistent store
    func load(completion: (() -> Void)? = nil ) {
        // We might want to load a function after loading
        persistentContainer.loadPersistentStores {
            (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            //self.configureContexts()
            }
        }
    }
}
