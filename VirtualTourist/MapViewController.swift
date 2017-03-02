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

class TravelLocationsMapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteNoteView: UIView!
    
    var gestureBegin: Bool = false
    var editMode: Bool = false
    var currentPins:[Pin] = []
    
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        // Get the stack
        let stack = getCoreDataStack()
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func preloadSavedPin() -> [Pin]? {
        
        do {
            var pinArray:[Pin] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<pinCount {
                pinArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            return pinArray
        } catch {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRightBarButtonItem()
        
        let savedPins = preloadSavedPin()
        if savedPins != nil {
            currentPins = savedPins!
            for pin in currentPins {
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(fromCoord: coord)
            }
        }
    }
    
    func setRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureBegin = true
        return true
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !editMode {
            performSegue(withIdentifier: "photoAlbumSegue", sender: view.annotation?.coordinate)
        } else {
            removeCoreData(of: view.annotation!)
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    @IBAction func responseLongTapAction(_ sender: Any) {
        if gestureBegin {
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            addAnnotationToMap(fromPoint: gestureTouchLocation)
            gestureBegin = false
        }
    }
    
    func addAnnotationToMap(fromPoint: CGPoint) {
        let coordToAdd = mapView.convert(fromPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordToAdd
        addCoreData(of: annotation)
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoord
        mapView.addAnnotation(annotation)
    }
    
    func addCoreData(of: MKAnnotation) {
        do {
            let coord = of.coordinate
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: getCoreDataStack().context)
            try getCoreDataStack().saveContext()
            currentPins.append(pin)
        } catch {
            print("add core data failed")
        }
    }
    
    func removeCoreData(of: MKAnnotation) {
        let coord = of.coordinate
        for pin in currentPins {
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                do {
                    getCoreDataStack().context.delete(pin)
                    try getCoreDataStack().saveContext()
                } catch {
                    print("remove core data failed")
                }
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinPhotos" {
            let destination = segue.destination as! PhotosViewController
            let coord = sender as! CLLocationCoordinate2D
            destination.coordinateSelected = coord
            for pin in currentPins {
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    destination.coreDataPin = pin
                    break
                }
            }
            
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deleteNoteView.isHidden = !editing
        editMode = editing
    }
    
}
