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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 21
    
    var coreDataPin:Pin!
    var savedImages:[Photo] = []
    var selectedToDelete:[Int] = [] {
        
        didSet {
            
            if selectedToDelete.count > 0 {
                
                bottomButton.setTitle("Remove Selected Pictures", for: .normal)
                
            } else {
                
                bottomButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    //Core Data Stack
    
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    //Fetch Results
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {

        let stack = getCoreDataStack()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //Load Saved Photo
    
    func preloadSavedPhoto() -> [Photo]? {
        
        do {
            
            var photoArray:[Photo] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<photoCount {
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            
            return photoArray.sorted(by: {$0.index < $1.index})
            
        } catch {
            
            return nil
        }
    }
    
    //View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        addAnnotationToMap()
        
        let savedPhoto = preloadSavedPhoto()
        
        if savedPhoto != nil && savedPhoto?.count != 0 {
            
            savedImages = savedPhoto!
            showSavedResult()
            
        } else {
            
            showNewResult()
        }
    }
    
    //Action
    
    @IBAction func bottomButtonAction(_ sender: Any) {
        
        if selectedToDelete.count > 0 {
            
            removeSelectedPicturesAtCoreData()
            unselectAllSelectedCollectionViewCell()
            savedImages = preloadSavedPhoto()!
            showSavedResult()
        } else {
            showNewResult()
        }
    }
    
    //Collection View Cell
    
    func unselectAllSelectedCollectionViewCell() {
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    //Delete Photo
    
    func removeSelectedPicturesAtCoreData() {
        
        for index in 0..<savedImages.count {
            
            if selectedToDelete.contains(index) {
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            
            try getCoreDataStack().saveContext()
            
        } catch {
            
            print("remove coredata photo failed")
        }
        
        selectedToDelete.removeAll()
    }
    
    //Saved Result
    
    func showSavedResult() {
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
        }
    }
    
    //Show Result
    
    func showNewResult() {
        
        bottomButton.isEnabled = false
        
        deleteExistingCoreDataPhoto()
        savedImages.removeAll()
        collectionView.reloadData()
        
        getFlickrImagesRandomResult { (flickrImages) in
            
            if flickrImages != nil {
                
                DispatchQueue.main.async {
                    
                    self.addCoreData(flickrImages: flickrImages!, coreDataPin: self.coreDataPin)
                    self.savedImages = self.preloadSavedPhoto()!
                    self.showSavedResult()
                    self.bottomButton.isEnabled = true
                }
            }
        }
    }
    
    //Add Photo
    
    func addCoreData(flickrImages:[FlickrImage], coreDataPin:Pin) {
        
        for image in flickrImages {
            
            do {
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                let photo = Photo(index: flickrImages.index{$0 === image}!, imageURL: image.imageURLString(), imageData: nil, context: stack.context)
                photo.pin = coreDataPin
                try stack.saveContext()
                
            } catch {
                
                print("add core data failed")
            }
        }
    }
    
    //Delete Photo
    
    func deleteExistingCoreDataPhoto() {
        
        for image in savedImages {
            
            getCoreDataStack().context.delete(image)
        }
    }
    
    //Get Images Randomly
    
    func getFlickrImagesRandomResult(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        
        FlickrNetwork.getFlickrImages(lat: coordinateSelected.latitude, lng: coordinateSelected.longitude) { (success, flickrImages) in
            if success {
                
                if flickrImages!.count > self.totalCellCount {
                    var randomArray:[Int] = []
                    
                    while randomArray.count < self.totalCellCount {
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    
                    for random in randomArray {
                        result.append(flickrImages![random])
                    }
                    
                    completion(result)
                } else {
                    completion(flickrImages!)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    //Add Annotation To Pin
    
    func addAnnotationToMap() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateSelected
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    //Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(savedImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacingBetweenItems
    }
    
    func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
        
        var selected:[Int] = []
        for indexPath in indexPathArray {
            selected.append(indexPath.row)
        }
        return selected
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1
        }
    }
    
}
