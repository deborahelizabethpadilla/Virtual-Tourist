//
//  FlickrNetwork.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation

    //Network

class FlickrNetwork {
    
    //Keys
    
    private static let flickrEndpoint  = "https://api.flickr.com/services/rest/"
    private static let flickrAPIKey    = "2a2ad0534c538cea62c640e0d2520400"
    private static let flickrSearch    = "flickr.photos.search"
    private static let format          = "json"
    private static let searchRangeKM   = 100
    
    //Get Images
    
    static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(flickrEndpoint)?method=\(flickrSearch)&format=\(format)&api_key=\(flickrAPIKey)&lat=\(lat)&lon=\(lng)&radius=\(searchRangeKM)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                completion(false, nil)
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let photosMeta = json?["photos"] as? [String:Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var flickrImages:[FlickrImage] = []
                
                for photo in photos {
                    
                    if let flickrImage = photo as? [String:Any],
                        let id = flickrImage["id"] as? String,
                        let secret = flickrImage["secret"] as? String,
                        let server = flickrImage["server"] as? String,
                        let farm = flickrImage["farm"] as? Int {
                        flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                completion(true, flickrImages)
                
            } else {
                
                completion(false, nil)
            }
        }
        
        task.resume()
    }
}
