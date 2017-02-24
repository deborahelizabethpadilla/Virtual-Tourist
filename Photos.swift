//
//  Photos.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var path: String
    @NSManaged var id: NSNumber
    @NSManaged var photo_pin: Pins
    
    //URL To Fetch Photo And Get Path
    
    var url: URL?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity:entity, insertInto: context)
    }
    
    init(url: URL, pin: Pins, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.url = url

        self.path = (url.lastPathComponent)
        self.photo_pin = pin
        
    }
    
    //Delete Image From Directory
    
    override func prepareForDeletion() {
        
        let photoPath = documentsDirectory.appendingPathComponent(path)
        do {
           
            if FileManager.default.fileExists(atPath: photoPath) {
                
                try FileManager.default.removeItem(atPath: photoPath)
            }
            
        } catch let error as NSError {
            
            print("Error Deleting Photo From Documents Directory: \(error)")
        }
    }
    
    
}

