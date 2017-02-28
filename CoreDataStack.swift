//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"

class CoreDataStack {
    
    //Shared Delegate
    
    class func sharedInstance() -> CoreDataStack {
        
        struct Static {
            
            static let instance = CoreDataStack()
        }
        
        return Static.instance
    }
    
    //Moved From AppDelegate
    
    lazy var applicationDocumentsDirectory: URL = {
        
        print("Instantiating the applicationDocumentsDirectory property")
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: Simplified Core data stack
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let applicationDocumentsDirectory = urls[urls.count-1]
        
        let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("VirtualTourist.sqlite")
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            
            // Report any error we got.
            var dict = [String: AnyObject]()
            
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data." as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.andreservidoni", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            coordinator = nil
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    // MARK: Core Data Saving support
    
    func saveContext () throws {
        if managedObjectContext.hasChanges {
            
            // every one that call this function need to handle the error
            try managedObjectContext.save()
        }
    }
}
