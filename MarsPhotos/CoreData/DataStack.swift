//
//  DataStack.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/30/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import CoreData

class DataStack {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MarsPhotos")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
     static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
