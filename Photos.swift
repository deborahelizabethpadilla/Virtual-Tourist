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


class Photos: NSManagedObject {
    
    //Managed By Core Data
 
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
    }
    
    override func prepareForDeletion() {
        
        
    }
    
}
