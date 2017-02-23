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
    
    @NSManaged var imageURL : Photo
    @NSManaged var path : Photo

 
    
    }
