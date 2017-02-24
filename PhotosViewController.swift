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

class PhotosViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var newCollectionButton: UIBarButtonItem!
    @IBOutlet var collectionViewOutlet: UICollectionView!
    
    //Variables For Map
    
    var lat: Double!
    var lon: Double!
    var imageView: UIImageView!
    var startAnimate = 0
    var stopAnimate = 0
    var loadingComplete = false
    var pin: Pin!
    
    var Pins = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Annotation For Small Map
        
        let latDelta:CLLocationDegrees = 0.1
        let lonDelta:CLLocationDegrees = 0.1
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
        mapView.addAnnotation(annotation)
        
        //Delegate and Datasource For Collection View Cell
        
        self.collectionViewOutlet.delegate = self as? UICollectionViewDelegate
        self.collectionViewOutlet.dataSource = self as? UICollectionViewDataSource
        self.collectionViewOutlet.allowsMultipleSelection = true
        
    }
        
        
}
