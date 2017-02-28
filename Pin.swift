//
//  Pin.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData
import MapKit
@objc(Pin)

class Pin: NSManagedObject {
    
    //Pin Management
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pictures: [Photo]
    
    //Keys
    
    struct Keys {
        
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let photos = "photos"
    }
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertInto: context)
    }
    
    //Save
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        latitude = dictionary[Keys.latitude] as! Double
        
        longitude = dictionary[Keys.longitude] as! Double
        
        do {
            
            try context.save()
            
        } catch _ {
            
        }
    }
}
