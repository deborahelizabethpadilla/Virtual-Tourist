//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Deborah on 1/15/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set AppDelegate With Core Data
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        var newPin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context)
        
        newPin.setValue("Pins", forKey: "latitude")
        
        do {
            
           try context.save()
            
        } catch {
            
            print("Oh No! There's A Problem!")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        request.returnsObjectsAsFaults = false
        
        do {
        
        let results = try context.execute(request)
            
            print(results)
        
        print(results)
        
        } catch {
            
            print("Results Failed!")
        }

}

}
