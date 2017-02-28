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
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var deletePins: UILabel!
    
    
    //Set Up Core Data
    
    var editingEnabled = false
    var tempPinAnnotation: PinAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate
        
        mapView.delegate = self
        
        //Long Gesture Press Recognizer For Pins
        
        labelBottom.constant = -deletePins.bounds.height
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        longPressGestureRecognizer.addTarget(self, action: "longPressed:")
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let pins = (try! sharedContext().fetch(request)) as! [Pin]
        for pin in pins {
            let pinAnnotation = PinAnnotation(pin: pin)
            pinAnnotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Edit
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MapViewController.toggleEdit(_:)))
            deletePins.isEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.labelBottom.constant = 0
                self.deletePins.layoutIfNeeded()
            })
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MapViewController.toggleEdit(_:)))
            deletePins.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.labelBottom.constant = -self.tapToDeleteLabel.bounds.height
                self.deletePins.layoutIfNeeded()
            })
        }
    }
    
    //Edit
    
    @IBAction func toggleEdit(_ sender: AnyObject) {
        if self.isEditing {
            self.setEditing(false, animated: true)
        } else {
            self.setEditing(true, animated: true)
        }
    }
    
    //Long Press Gesture Recognizer
    
    func longPressed(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            tempPinAnnotation = mapView.addPinAnnotationAtPoint(point)
        case .changed:
            tempPinAnnotation!.coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        case .cancelled:
            mapView.removeAnnotation(tempPinAnnotation!)
            tempPinAnnotation = nil
        default:
            tempPinAnnotation = nil
        }
    }
    
    //Map View Annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        view.animatesDrop = true
        return view
    }
    
    //Map View Select View
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation as! PinAnnotation
        if isEditing {
            mapView.removeAnnotation(annotation)
            let pin = annotation.pin
            sharedContext().delete(pin)
        } else {
            performSegue(withIdentifier: "PinPhotos", sender: annotation)
        }
    }
    
    //Segue To Photos VC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let id = segue.identifier!
        
        switch id {
        case "PhotosForPin":
            let pinAnnotation = sender as! PinAnnotation
            let destination = segue.destination as! PhotosViewController
            destination.pinAnnotation = pinAnnotation
        default:
            return
        }
    }
    
}

 //Add Pin To Coordinate

extension MKMapView {
    func addPinAnnotationAtPoint(_ point: CGPoint) -> PinAnnotation {
        let coordinate = self.convert(point, toCoordinateFrom: self)
        let pinAnnotation = addPinAnnotationToCoordinate(coordinate)
        return pinAnnotation
    }
    
    //Add Pin To Coordinate
    
    func addPinAnnotationToCoordinate(_ location: CLLocationCoordinate2D) -> PinAnnotation {
        let pin = Pin(entity: ["latitude" : Double(location.latitude) as AnyObject, "longitude" : Double(location.longitude) as AnyObject], insertInto: (UIApplication.shared.delegate as! AppDelegate).managedObjectContext)
        let annotation = PinAnnotation(pin: pin)
        annotation.coordinate = location
        addAnnotation(annotation)
        return annotation
    }
}
