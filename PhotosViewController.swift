//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Deborah on 2/14/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var newCollectionButton: UIBarButtonItem!
    @IBOutlet var collectionViewOutlet: UICollectionView!
    
    let locationManager2 = CLLocationManager()
    
    var pins = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Delegate
        
        mapView.delegate = self as! MKMapViewDelegate
        
        getPin()
        
        //Add Long Press Gesture Recognizer
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        longPressGesture.minimumPressDuration = 1.5
        self.mapView.addGestureRecognizer(longPressGesture)
        
        //Ask User For Authorization And Activate
        
        self.locationManager2.requestAlwaysAuthorization()
        
        self.locationManager2.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager2.delegate = self as? CLLocationManagerDelegate
            locationManager2.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager2.startUpdatingLocation()
            
        }
        
        func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
        }
        
        self.collectionViewOutlet.delegate = self as? UICollectionViewDelegate
        self.collectionViewOutlet.dataSource = self as? UICollectionViewDataSource
        self.collectionViewOutlet.allowsMultipleSelection = true
        
    }
    
    //Add Annotations With Long Press Gesture Recognizer
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            
            //Save To Core Data
            
            do {
                
                try context.save()
                
            } catch {
                
                print("There Was A Problem!")
                
            }
            
            
        }
        
    }
    
    //Transition To Photo Album When Pin Is Tapped
    
    func getPin() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do {
            
            let results = try! context.fetch(fetchRequest)
            pins = results as! [NSManagedObject]
            
            for pin in pins {
                let pinLat = pin.value(forKey: "latitude") as! Double
                let pinLon = pin.value(forKey: "longitude") as! Double
                
                let pinCoordinate = CLLocationCoordinate2D(latitude: pinLat, longitude: pinLon)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = pinCoordinate
                
                self.mapView.delegate = self as! MKMapViewDelegate
                
                self.mapView.addAnnotation(annotation)
                
                //Save To Core Data
                
                do {
                    
                    try context.save()
                    
                } catch {
                    
                    print("There Was A Problem!")
                    
                }
                
            }
            
            //Pin Tapped
            
            func mapView(_ mapView: MKMapView, didSelectPinView view: MKAnnotationView) {
                
                let coordinate = view.annotation?.coordinate
                
                let photoVC = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
                
                print("Pin Tapped!")
                
                
            }
            
            
        }
        
    }
    
}

        
        
    }

}
