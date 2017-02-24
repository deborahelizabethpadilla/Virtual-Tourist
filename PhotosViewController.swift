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
    
    var pins = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewOutlet.delegate = self as? UICollectionViewDelegate
        self.collectionViewOutlet.dataSource = self as? UICollectionViewDataSource
        self.collectionViewOutlet.allowsMultipleSelection = true
        
    }

}
    
   
