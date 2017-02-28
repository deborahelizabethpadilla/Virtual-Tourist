//
//  Annotation.swift
//  VirtualTourist
//
//  Created by Deborah on 2/28/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: MKPointAnnotation {
    
    let pin: Pin
    
    init(pin: Pin) {
        
        self.pin = pin
    }
}
