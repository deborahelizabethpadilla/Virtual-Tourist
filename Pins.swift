//
//  Pins.swift
//  VirtualTourist
//
//  Created by Deborah on 2/14/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

class Pins: NSManagedObject {
        
        convenience init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
            if let entity = NSEntityDescription.entity(forEntityName: "Pins", in: context) {
                self.init(entity: entity, insertInto: context)
                self.latitude = dictionary["latitude"] as! Double as NSNumber
                self.longitude = dictionary["longitude"] as! Double as NSNumber
                self.alreadyHasPhotos = false
            } else {
                fatalError("Unable to find Entity naem!")
            }
        }
        
    }
