//
//  CoreDataPins.swift
//  VirtualTourist
//
//  Created by Deborah on 2/18/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import CoreData

extension Pins {
    
    @NSManaged var number: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var alreadyHasPhotos: NSNumber?
    @NSManaged var photos: NSSet?
    
}
