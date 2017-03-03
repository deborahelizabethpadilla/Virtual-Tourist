//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

    //Core Data Stack

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    let context: NSManagedObjectContext
    
    init?(modelName: String) {
    
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable To Find \(modelName).self In The Main Bundle")
            return nil
        }
        
        self.modelURL = modelURL
    
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            print("Unable To Create A Model From \(modelURL)")
            return nil
        }
        
        self.model = model

        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            
            print("Unable To Reach The Documents Folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("VirtualTourist.sqlite")
       
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
            
        } catch {
            
            print("Unable To Add Store At \(dbURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

internal extension CoreDataStack  {
    
    func dropAllData() throws {

        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

extension CoreDataStack {
    
    func saveContext() throws {
        
        if context.hasChanges {
            
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            do {
                
                try saveContext()
                print("Autosaving")
                
            } catch {
                
                print("Error While Autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                self.autoSave(delayInSeconds)
            }
        }
    }
}
