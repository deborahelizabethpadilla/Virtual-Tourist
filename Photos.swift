//
//  Photos.swift
//  VirtualTourist
//
//  Created by Deborah on 2/20/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

class Photos: NSManagedObject {
    
    convenience init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.path = dictionary["path"] as? String
            self.imageUrl = dictionary["imageUrl"] as? String
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
