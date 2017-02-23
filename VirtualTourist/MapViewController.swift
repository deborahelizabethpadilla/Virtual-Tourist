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
        
        //Add Long Press Gesture Recognizer
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
        //Ask User For Authorization And Activate
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
        
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    //Add Annotations With Long Press Gesture Recognizer
    
    func addAnnotation(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Title"
            annotation.subtitle = "subtitle"
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
}
