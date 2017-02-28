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
    
    //Variables
    
    let spacing: CGFloat = 6.0
    let columns = 3
    var pinAnnotation: PinAnnotation?
    var photos: [Photo]?
    var photoStatus = PhotosStatus.incomplete
    
    enum PhotosStatus {
        case incomplete
        case done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Collection View Setup
        
        newCollectionOutlet.dataSource = self
        newCollectionOutlet.delegate = self
        newCollectionOutlet.allowsMultipleSelection = true
        
        
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
                    let alert = UIAlertController(title: "Could not retrieve photos", message: "Photos cannot be retrieved at this time", preferredStyle: UIAlertControllerStyle.alert)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
    
}
