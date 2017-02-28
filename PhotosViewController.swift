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
    @IBOutlet var noPhotos: UILabel!
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        //Download New Photos From Flickr
        
        fetchedResults = nil
        deletePhotosForPin()
        loadPicturesFromFlickr()
    }
    
    //Variables For Map
    
    var lat: Double!
    var lon: Double!
    var imageView: UIImageView!
    var startAnimate = 0
    var stopAnimate = 0
    var loadingComplete = false
    var pin: Pins!
    
    var Pins = [NSManagedObject]()
    
    var fetchedResults: NSFetchedResultsController<NSFetchRequestResult>!
    
    let reuseIdentifier = "photoCell"
    
    let fileManager = FileManager.default
    
    lazy var sharedContext: NSManagedObjectContext = {
        
        return CoreDataStack.sharedInstance().managedObjectContext
        
    }()
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapToPin()
        
        newCollectionButton.isEnabled = false
        
        collectionViewOutlet.register(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        collectionViewOutlet.delegate = self as UICollectionViewDelegate
        collectionViewOutlet.dataSource = self as? UICollectionViewDataSource
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.tappedCell(_:)))
        self.collectionViewOutlet.addGestureRecognizer(tapRecognizer)
        
        fetchedResultsController = getFetchedResultsController()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching photos for pin: \(error)")
        }
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            
            loadPicturesFromFlickr()
            
        } else {
            
            DispatchQueue.main.async(execute: {
                
                self.collectionViewOutlet.reloadData()
                
                self.newCollectionButton.isEnabled = true
                
            })
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //How Many Returned
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedResultsController.fetchedObjects?.count {
            
            return count
            
        } else {
            
            return 0
        }
    }
    
    //Cell With Image
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        
        cell.imageView.image = UIImage(named: "collectionImage")
        
        guard (fetchedResultsController.fetchedObjects?.count != 0) else {
            return cell
        }
        
        let p = fetchedResultsController.object(at: indexPath) as! Photos
        
        var imageData: Data?
        
        let photoPath = documentsDirectory.appendingPathComponent(p.path)
        if fileManager.fileExists(atPath: photoPath) {
            imageData  = try! Data(contentsOf: URL(fileURLWithPath: photoPath))
            DispatchQueue.main.async(execute: {
                
                cell.imageView.image = UIImage(data: imageData!)
                
                cell.activityIndicator.stopAnimating()
            })
            
        } else {
            
            if let photoUrl = p.url {
                FlickrNetwork.sharedInstance().getPhotoFromUrl(photoUrl) { data, error in
                    
                    if data != nil {
                        
                        imageData = data
                        DispatchQueue.main.async(execute: {
                            
                            cell.imageView.image = UIImage(data: imageData!)
                            cell.activityIndicator.stopAnimating()
                        })
                        
                    } else {
                        
                        DispatchQueue.main.async(execute: {
                            cell.activityIndicator.stopAnimating()
                        })
                    }
                }
            }
        }
        
        return cell
        
    }
    
    //Delete Photo When Tapped
    
    func tappedCell(_ gestureRecognizer: UITapGestureRecognizer) {
        
        let tappedPoint: CGPoint = gestureRecognizer.location(in: collectionViewOutlet)
        if let tappedCellPath: IndexPath = collectionViewOutlet.indexPathForItem(at: tappedPoint) {
            let photo = fetchedResultsController.object(at: tappedCellPath) as! Photos
            sharedContext.delete(photo)
            do {
                try sharedContext.save()
            } catch let error as NSError {
                print("Error deleting photo: \(error)")
            }
        }
    }
    
    //Fetching Photos Within Pin
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "photo_pin == %@", self.pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    //Delete Photos Within Pin
    
    func deletePhotosForPin() {
        
        if pin.pin_photo.count > 0 {
            
            for photo in pin.pin_photo {
                
                sharedContext.delete(photo as! Photos)
            }
            
            do {
                
                try sharedContext.save()
                
            } catch let error as NSError {
                
                print("Error clearing photos from Pin: \(error)")
            }
        }
    }
    
    //Get Photos From Flickr Within Location
    
    func loadPicturesFromFlickr() {
        
        newCollectionButton.isEnabled = false
        DispatchQueue.main.async(execute: {
            
            self.noPhotos.isHidden = true
        })
        
        fetchedResultsController = getFetchedResultsController()
        
        FlickrNetwork.sharedInstance().getPhotosForPin(pin) { hasPhotos, error in
            guard (error == nil) else {
                
                print("getPhotosForPin returned an error: \(String(describing: error))")
                return
            }
            
            if hasPhotos {
                
                do {
                    
                    
                    try self.fetchedResultsController.performFetch()
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.collectionViewOutlet.reloadData()
                        
                        self.newCollectionButton.isEnabled = true
                        
                    })
                    
                } catch let error as NSError {
                    
                    print("Error fetching photos for pin: \(error)")
                }
            } else {
                
                DispatchQueue.main.async(execute: {
                    
                    self.noPhotos.isHidden = false
                })
                
            }
        }
    }
    
    //Set Pins On Map
    
    func setMapToPin() {
        
        let location = CLLocationCoordinate2DMake(pin.latitude as! Double, pin.longitude as! Double)
        let span = MKCoordinateSpanMake(FlickrNetwork.Constants.LatitudeDelta, FlickrNetwork.Constants.LongitudeDelta)
        let region = MKCoordinateRegionMake(location, span)
        DispatchQueue.main.async(execute: {
            self.mapView.addAnnotation(self.pin)
            self.mapView.setRegion(region, animated: true)
        })
    }
    
}


//Design Cells In Collection View

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let picDimension = self.view.frame.size.width / 4.0
        
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftRightInset = self.view.frame.size.width / 14.0
        
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
}


extension PhotosViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            break
        case .delete:
            
            collectionViewOutlet.deleteItems(at: [indexPath!])
            
            DispatchQueue.main.async(execute: {
                
                self.collectionViewOutlet.reloadData()
            })
            
        case .update:
            break
            
        case .move:
            break
        }
    }
}
