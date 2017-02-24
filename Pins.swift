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
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entity, insertInto: context)
            
        } else {
            
            fatalError("Not Able To Find Entity Name!")
        }
    }
    
}
