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

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var newCollectionOutlet: UICollectionView!
    @IBOutlet var noPhoto: UILabel!
    @IBOutlet var trash: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var newCollectionButton: UIButton!
    
    
    //Variables & Enum
    
    let spacing: CGFloat = 6.0
    let columns = 3
    var pinAnnotation: PinAnnotation?
    var photos: [Photo]?
    var photoStatus = PhotosStatus.incomplete
    var isDeleting = false
    var selectedIndexofCollectionViewCells = [IndexPath]()
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin? = nil

    enum PhotosStatus {
        
        case incomplete
        case done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide New Collection Button
        
        newCollectionButton.isHidden = false
        
        //Collection View Setup
        
        newCollectionOutlet.dataSource = self
        newCollectionOutlet.delegate = self
        newCollectionOutlet.allowsMultipleSelection = true
        
        //New Collection Button Enabled
        
        newCollectionButton.isEnabled = false
        
        
        //Annotation
        
        if let pinAnnotation = pinAnnotation {
            
            let region = MKCoordinateRegionMake(pinAnnotation.coordinate, MKCoordinateSpanMake(0.4, 0.4))
            
            mapView.setRegion(region, animated: true)
            
            mapView.addAnnotation(pinAnnotation)
            
            photos = pinAnnotation.pin.pictures
            
            if photos!.count == 0 {
                
                photoStatus = .incomplete
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
                retrieveURLsForPinAnnotation(pinAnnotation)
                
            } else {
                
                photoStatus = .done
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                newCollectionOutlet.reloadData()
            }
        }
    }
    
    //Get Flickr For Pins
    
    func retrieveURLsForPinAnnotation(_ pinAnnotation: PinAnnotation) {
        
        FlickrNetwork.sharedClient.taskForURLsWithPinAnnotation(pinAnnotation) { urls, error in
            if error != nil {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "Could Not Retrieve Photos", message: "Photos Cannot Be Retrieved At This Time", preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alert, animated: true, completion: nil)
                    self.photoStatus = .done
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.newCollectionOutlet.reloadData()
                }
                
            } else {
                
                for (_, url) in (urls!).enumerated() {
                    
                    let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
                    let path = "/" + pinAnnotation.pin.latitude.description.replacingOccurrences(of: ".", with: "_", options: .literal, range: nil) + "-" + pinAnnotation.pin.longitude.description.replacingOccurrences(of: ".", with: "_", options: .literal, range: nil) + "-" + url.lastPathComponent
                    let dict = ["imagePath" : path, "pin" : pinAnnotation.pin] as [String : Any]
                    let photo = Photo(dictionary: dict as [String : AnyObject], context: sharedContext())
                    FlickrNetwork.sharedClient.downloadImageURL(url, toPath: (docPath + path)) { success, error in
                        DispatchQueue.main.async {
                            
                            if error != nil {
                                sharedContext().delete(photo)
                                
                                do {
                                    
                                    try sharedContext().save()
                                    
                                } catch _ {
                                    
                                }
                                
                            } else {
                                
                                self.newCollectionOutlet.reloadData()
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.photoStatus = .done
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.newCollectionOutlet.reloadData()
                }
            }
        }
    }
    
    //Number Of Sections
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    //Collection View Number Of Items
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch photoStatus {
            
        case .incomplete:
            noPhoto.isHidden = true
            return 0
        case .done:
            let photos = pinAnnotation?.pin.pictures
            if let cellCount = photos?.count, cellCount > 0 {
                
                noPhoto.isHidden = true
                return cellCount
                
            } else {
                
                noPhoto.isHidden = false
                return 0
            }
        }
    }
    
    //Collection View Cell For Item
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let imagePath = pinAnnotation?.pin.pictures[indexPath.row].imagePath
        if let imagePath = imagePath,
            let image = UIImage(contentsOfFile: (docPath + imagePath)) {
            
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.imageView.image = image
            
        } else {
            
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    //Collection View Size Item
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spaces = CGFloat(2 * columns)
        let width = (collectionView.bounds.width - (spacing * spaces)) / CGFloat(columns)
        
        return CGSize(width: width, height: width)
    }
    
    //Collection View Spacing
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacing
    }
    
    //Collection View Select Item
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.alpha = 0.4
        trash.isEnabled = true
    }
    
    //Collection View Deselect Item
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.alpha = 1.0
        if collectionView.indexPathsForSelectedItems != nil {
            
            trash.isEnabled = false
        }
        
    }
    
    //New Collection Button
    
    @IBAction func newCollectionButton(_ sender: Any) {
        
        newCollectionButton.isHidden = true
        
        //Delete Photo
        
        if isDeleting == true
            
        {
            //Remove Photo
            
            for indexPath in selectedIndexofCollectionViewCells {
                
                //Get Photo With IndexPath
                
                let photo = fetchedResultsController.object(at: indexPath)
                
                print("Deleting this -- \(photo)")
                
                //Delete Photo
                
                sharedContext().delete(photo)
                
            }
            
            //Empty IndexPath After Deleting
            
            selectedIndexofCollectionViewCells.removeAll()
            
            //Save To Core Data
            
            try! CoreDataStack.sharedInstance().saveContext()
            
            //Update Cells
            
            fetch()
            newCollectionOutlet.reloadData()
            
            //Change Button After Deleting
            
            newCollectionButton.setTitle("New Collection", for: UIControlState())
            newCollectionButton.isHidden = false
            
            isDeleting = false
            
        } else {
            
            //Wipe Photo Album From Previous
            
            for photo in fetchedResultsController.fetchedObjects! {
                
                sharedContext().delete(photo)
            }
            
            //Save To Core Data
            
            try! CoreDataStack.sharedInstance().saveContext()
            
            //Download New Photos
            
            FlickrNetwork.sharedInstance().downloadPhotosForPin(pin!, completionHandler: { success, error in
                
                if success {
                    
                    DispatchQueue.main.async(execute: {
                        
                        CoreDataStack.sharedInstance().saveContext()
                    })
                    
                } else {
                    
                    DispatchQueue.main.async(execute: {
                        
                        print("error downloading a new set of photos")
                        
                        self.newCollectionButton.isHidden = false
                    })
                }
                
                //Update cells
                
                DispatchQueue.main.async(execute: {
                    self.reFetch()
                    self.collectionView.reloadData()
                })
                
            })
        }

    }

    //Refresh Photos

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        
        photoStatus = .incomplete
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        if let indexPaths = newCollectionOutlet.indexPathsForSelectedItems {
            
            for index in indexPaths {
                
                newCollectionOutlet.deselectItem(at: index, animated: true)
                collectionView(newCollectionOutlet, didDeselectItemAt: index)
            }
        }
        
        for photo in pinAnnotation!.pin.pictures {
            
            sharedContext().delete(photo)
        }
        newCollectionOutlet.reloadData()
        
        retrieveURLsForPinAnnotation(pinAnnotation!)
    }
    
    //Delete Photos
    
    @IBAction func deleteSelectedPhotos(_ sender: UIBarButtonItem) {
        
        while let index = newCollectionOutlet.indexPathsForSelectedItems?.first {
            
            let row = index.row
            let photo = pinAnnotation?.pin.pictures[row]
            sharedContext().delete(photo!)
            do {
                try sharedContext().save()
                
            } catch _ {
                
            }
            
            newCollectionOutlet.deleteItems(at: [index])
        }
    }
    
    //Fetch Data Again
    
    func fetch() {
        
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            
            print("reFetch - \(error)")
        }
    }
    
}
