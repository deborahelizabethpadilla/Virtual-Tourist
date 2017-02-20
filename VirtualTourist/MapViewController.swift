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
    
    var locations = [Pins]()
    
    var sharedContext: NSManagedObjectContext {
        return (CoreData.sharedInstance?.context)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: nil, action: nil)
        title = "Virtual Tourist"
        mapView.delegate = self as! MKMapViewDelegate
        
        self.locations = fetchAllPins()
        loadAllPins()
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func handleLongPress(_ getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .began {
            return
        } else {
            let touchPoint = getstureRecognizer.location(in: self.mapView)
            let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            let newPin = Pin(dictionary: ["longitude": annotation.coordinate.longitude as AnyObject, "latitude": annotation.coordinate.latitude as AnyObject], context: (sharedContext))
            print("\(newPin.longitude) + \(newPin.latitude)")
            mapView.addAnnotation(annotation)
            CoreDataStack.sharedInstance?.save()
        }
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pins")
        do {
            return try sharedContext.fetch(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error Getting Pins: \(error)")
            return [Pin]()
        }
    }
    
    func loadAllPins() {
        for pin in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude!), longitude: CLLocationDegrees(pin.longitude!))
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation?.coordinate
        let photoVC = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        for pin in locations {
            if (coordinate?.latitude == pin.latitude && coordinate?.longitude == pin.longitude) {
                photoVC.pin = pin
            }
        }
        navigationController?.pushViewController(photoVC, animated: true)
    }
}



