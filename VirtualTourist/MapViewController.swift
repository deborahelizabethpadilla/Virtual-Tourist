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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Location On Map
        
        self.locationManager.delegate = self as? CLLocationManagerDelegate
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        self.mapView.showsUserLocation = true
 
        self.mapView.userTrackingMode = .follow
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
    }

    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        //Set Long Gesture Recognizer
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            
            //Set And Add Annotation
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Title"
            annotation.subtitle = "subtitle"
            self.mapView.addAnnotation(annotation)
        }
        
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
    }

}

}
