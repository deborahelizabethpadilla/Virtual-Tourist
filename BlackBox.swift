//
//  BlackBox.swift
//  VirtualTourist
//
//  Created by Deborah on 2/20/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
