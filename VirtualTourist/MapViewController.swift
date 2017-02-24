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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    //Set Up Core Data
    
    var context: NSManagedObjectContext = {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initiate Map View
        
        mapView.delegate = self
        
        //Set Location On Map
        
        self.locationManager.delegate = self as? CLLocationManagerDelegate
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.mapView.userTrackingMode = .follow
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
        
        //Set Long Gesture Recognizer
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: self.mapView)
            
            //Coordinates
            
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            
            //Create A New Pin
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Title"
            annotation.subtitle = "subtitle"
            self.mapView.addAnnotation(annotation)
            
            let pins = Pins(latitude: coordinate.latitude, longitude: coordinate.longitude, photos: NSSet(), context: context)
            
            do {
                try
                    self.context.save()
                
            } catch let error  as NSError {
                
                print("Error saving new pin: \(error)")
            }
            
            DispatchQueue.main.async(execute: {
                
                self.mapView.addAnnotation(pins)
            })
        }
        
    }
    
    //Set Location
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
            
            let location = locations.last
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: (location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)) //zoom on map
            self.mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
            
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            
            print("Errors: " + error.localizedDescription)
        }
        
        //Adds and Saves To Map
        
        func setMapView() {
            let defaults = UserDefaults.standard
            var mapDefaultsSet: Bool
            mapDefaultsSet = defaults.bool(forKey: FlickrNetwork.NSUserDefaultKeys.StartMapPositionSaved)
            
            if mapDefaultsSet {
                let startCenterLatitude = defaults.double(forKey: FlickrNetwork.NSUserDefaultKeys.StartMapCenterLatitude)
                let startCenterLongitude = defaults.double(forKey: FlickrNetwork.NSUserDefaultKeys.StartMapCenterLongitude)
                let startDeltaLatitude = defaults.double(forKey: FlickrNetwork.NSUserDefaultKeys.StartMapDeltaLatitude)
                let startDeltaLongitude = defaults.double(forKey: FlickrNetwork.NSUserDefaultKeys.StartMapDeltaLongitude)
                let centerCoordinate = CLLocationCoordinate2D(latitude: startCenterLatitude, longitude: startCenterLongitude)
                let centerSpan = MKCoordinateSpanMake(startDeltaLatitude, startDeltaLongitude)
                let region = MKCoordinateRegionMake(centerCoordinate, centerSpan)
                DispatchQueue.main.async(execute: {
                    self.mapView.setRegion(region, animated: true)
                })
                
            }
            
            //Transition To Photo VC When Pin Is Tapped
            
            func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                
                let latitudePredicate = NSPredicate(format: "latitude = %@", NSNumber(value: (view.annotation?.coordinate.latitude)! as Double))
                let longitudePredicate = NSPredicate(format: "longitude = %@", NSNumber(value: (view.annotation?.coordinate.longitude)! as Double))
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate])
                
                var pin: Pins
                
                do {
                    
                    let result = try context.fetch(fetchRequest) as! [Pins]
                    
                    if result.count > 0 {
                        
                        pin = result.first! as Pins
                        self.mapView.deselectAnnotation(view.annotation, animated: true)
                        self.performSegue(withIdentifier: "PhotosViewController", sender: pin)
                    }
                    
                } catch let error as NSError {
                    
                    print("Error fetching pin for the annotation view: \(error)")
                }
                
            }
            
        }
        //Get The View
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView {
            
            let reuseIdentifier = "pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            
            return view!
            
        }
        
    }
    //Save Pin
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        let latitudePredicate = NSPredicate(format: "latitude = %@", NSNumber(value: (view.annotation?.coordinate.latitude)! as Double))
        let longitudePredicate = NSPredicate(format: "longitude = %@", NSNumber(value: (view.annotation?.coordinate.longitude)! as Double))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latitudePredicate, longitudePredicate])
        
        var pin: Pins
        
        do {
            
            let result = try context.fetch(fetchRequest) as! [Pins]
            if result.count > 0 {
                pin = result.first! as Pins
                self.mapView.deselectAnnotation(view.annotation, animated: true)
                self.performSegue(withIdentifier: "PhotosViewController", sender: pin)
            }
        } catch let error as NSError {
            print("Error Fetching Pin For The Annotation View: \(error)")
        }
        
    }
    
}
