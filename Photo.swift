//
//  Photo.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    //Photo For Annotation
    
    @NSManaged var imagePath: String
    @NSManaged var pin: Pin?
    
    //Keys 
    
    struct Keys {
        
        static let imagePath = "imagePath"
        static let pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        
        imagePath = dictionary[Keys.imagePath] as! String
        
        pin = dictionary[Keys.pin] as? Pin
        
        do {
            
            try context.save()
            
        } catch _ {
            
        }
    }
    
    //Delete Annotation
    
    override func prepareForDeletion() {
        
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        let fullPath = docPath + imagePath
        
        do {
            
            try FileManager.default.removeItem(atPath: fullPath)
            
        } catch _ {
            
        }
    }
}
