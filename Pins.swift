//
//  Pins.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

class Pins: NSManagedObject {
    
    struct Components {
        
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    //Core Data Properties
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pins: [Pin]
    @NSManaged var photos: [Photo]

    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entity, insertInto: context)
            
        } else {
            
            fatalError("Not Able To Locate!")
        }
    }
    
    //Core Data Init
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        super.init(entity: entity, insertInto: context)
        
        latitude = dictionary[Components.Latitude] as! Double
        longitude = dictionary[Components.Longitude] as! Double
    }
    
}
