//
//  FlickrNetwork.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import UIKit
import CoreData

typealias PhotoCompletionHandler = (_ result: Bool, _ error: NSError?) -> Void

typealias PhotoDataCompletionHandler = (_ data: Data?, _ error: NSError?) -> Void


let documentsDirectory: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString


class FlickrNetwork: NSObject {
    
    var session: URLSession
    
    
    static var page = 0
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }()
    
    //Get Location Of Pin
    
    func getPhotosForPin(_ pin: Pins, completionHandler: @escaping PhotoCompletionHandler) -> Void {
        
        let methodArguments: [String : AnyObject] = [
            JSONBodyKeys.Method : Methods.FlickrSearchMethod as AnyObject,
            JSONBodyKeys.ApiKey : Constants.FlickrApiKey as AnyObject,
            JSONBodyKeys.SafeSearch : Constants.SafeSearch as AnyObject,
            JSONBodyKeys.BoundingBox : createBoundingBoxString(pin) as AnyObject,
            JSONBodyKeys.Format : Constants.DataFormat as AnyObject,
            JSONBodyKeys.NoJSONCallback : Constants.NoJSONCallback as AnyObject,
            JSONBodyKeys.PerPage : Constants.PerPage as AnyObject
        ]
        
        let urlString = Constants.FlickrBaseUrl + escapedParameters(methodArguments)
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        var totalPages = 0
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard (error == nil) else {
                
                print("Could not complete the request \(String(describing: error))")
                
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    
                } else if let response = response {
                    
                    print("Your request returned an invalid response! Response: \(response)!")
                    
                } else {
                    
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                
                print("No data was returned")
                return
            }
            
            let parsedResult: Any!
            
            do {
                
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                
            } catch {
                
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = (parsedResult as AnyObject).value(forKey: "photos") as? NSDictionary else {
                
                print("Cannot find key 'photos' in \(parsedResult)")
                return
            }
            
            if let pages = photosDictionary["pages"] as? Int {
                
                totalPages = pages
            }
            
            if totalPages == 0 {
                
                completionHandler(false, nil)
                return
            }
            
            if +FlickrNetwork.page > totalPages {
                
                FlickrNetwork.page = 1
            }
        })
        
        task.resume()
        
        return self.getImageFromFlickrBySearchWithPage(pin, methodArguments: methodArguments, pageNumber: FlickrNetwork.page, completionHandler: completionHandler)
        
    }
    
    //Get Photos From Flickr
    
    func getImageFromFlickrBySearchWithPage(_ pin: Pins, methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: @escaping PhotoCompletionHandler) -> Void {
        
        var argumentsWithPage = methodArguments
        argumentsWithPage["page"] = pageNumber as AnyObject
        
        let session = URLSession.shared
        let urlString = FlickrNetwork.Constants.FlickrBaseUrl + escapedParameters(argumentsWithPage)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (error == nil) else {
                print("Could not complete the request \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                return
            }
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = (parsedResult as AnyObject).value(forKey: "photos") as? NSDictionary else {
                print("Cannot find key 'photos' in \(parsedResult)")
                return
            }
            
            guard let totalPhotos = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(parsedResult)")
                return
            }
            
            if totalPhotos > 0 {
                guard let photosArray = photosDictionary["photo"] as? [[String : AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                
                let photoSet: NSMutableSet = NSMutableSet()
                
                for photo in photosArray {
                    
                    self.sharedContext.performAndWait( {
                        
                        let newPhoto = Photo(url: self.getFlickrUrlForPhoto(photo), pin: pin, context: self.sharedContext)
                        
                        self.getPhotoFromUrl(newPhoto.url!) { data, error in
                            guard (error == nil) else {
                                return
                            }
                        }
                        photoSet.add(newPhoto)
                    })
                }
                
                completionHandler(true, nil)
            }
        })
        task.resume()
        
    }
    
    //Get Photo Image
    
    func getPhotoFromUrl(_ url: URL, completionHandler: @escaping PhotoDataCompletionHandler) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async {
            
            if let imageData = try? Data(contentsOf: url) {
                let photoPath = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                try? imageData.write(to: URL(fileURLWithPath: photoPath), options: [.atomic])
                completionHandler(imageData, nil)
            } else {
                completionHandler(nil, NSError(domain: "getPhotoFromUrl", code: -1, userInfo: [NSLocalizedDescriptionKey : "Could not retrieve image fron url"]))
            }
        }
    }
    
    
    //Create Coords For Flickr Search
    
    func createBoundingBoxString(_ pin: Pins) -> String {
        
        let latitude = pin.latitude as! Double
        let longitude = pin.longitude as! Double
        
        let bottom_left_lon = max(longitude - Constants.BoundingBoxHeight, Constants.MinimumLongitude)
        let bottom_left_lat = max(latitude - Constants.BoundingBoxHeight, Constants.MinimumLatitude)
        let top_right_lon = min(longitude + Constants.BoundingBoxHeight, Constants.MaximumLongitude)
        let top_right_lat = min(latitude + Constants.BoundingBoxHeight, Constants.MaximumLatitude)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    //Check HTTP Response
    
    func checkHttpResponse(_ response: URLResponse) -> (success: Bool, statusCode: Int) {
        let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        //Status Is Success
        
        let success = statusCode >= Constants.HttpSuccessRange.lowerBound && statusCode <= Constants.HttpSuccessRange.upperBound
        return (success, statusCode)
    }
    
    //Convert String To URL
    
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    //Returns URL
    
    func getFlickrUrlForPhoto(_ photoData : [String : AnyObject]) -> URL {
        
        var farm = photoData[JSONResponseKeys.Farm] as? String
        if farm == nil {
            farm = "1"
        }
        let server = photoData[JSONResponseKeys.Server] as? String
        let id = photoData[JSONResponseKeys.Id] as? String
        let secret = photoData[JSONResponseKeys.Secret] as? String
        
        return URL(string: "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!)_m.jpg")!
    }
    
    class func sharedInstance() -> FlickrNetwork {
        struct Singleton {
            static var sharedInstance = FlickrNetwork()
        }
        
        return Singleton.sharedInstance
    }
}
