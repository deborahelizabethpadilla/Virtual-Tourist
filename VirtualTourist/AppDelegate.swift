//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Deborah on 1/15/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import UIKit
import CoreData

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "CoreDataModel")!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
}
