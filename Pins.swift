//
//  Pins.swift
//  VirtualTourist
//
//  Created by Deborah on 2/23/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData
import MapKit



class Pins: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var pin_photo: NSSet
    
    var coordinate: CLLocationCoordinate2D {
        
       return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
    var title: String? = nil
    var subtitle: String? = nil
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertInto: context)
    }
    
    init(latitude: Double, longitude: Double, photos: NSSet, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
        pin_photo = photos
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext
        
    }
    
}
