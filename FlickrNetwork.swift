//
//  FlickrNetwork.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation
import UIKit

class FlickrNetwork: NSObject {
    
    //Main Functions
    
    static let sharedClient = FlickrNetwork()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    fileprivate override init() {}
    
    //Task From Flickr
    
    func taskForURLsWithParameters(_ parameters: [String:String], completionHandler: @escaping (_ urls: [URL]?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let urlString = APIConstants.baseURL + "?" + escapedParameters(parameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                
                completionHandler(nil, error as NSError)
                
            } else {
                
                let json = (try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)) as! NSDictionary
                
                if let results = json["photos"] as? [String:AnyObject],
                    let photos = results["photo"] as? [[String:AnyObject]] {
                    
                    let total = Int((results["total"] as! String))!
                    var slice = photos
                    slice.shuffle()
                    let max = min(21, total)
                    slice = Array(slice[0..<max])
                    let urls = slice.map { (photo: [String:AnyObject]) -> URL in
                        let urlString = photo[APIConstants.urlExtra] as! String
                        return URL(string: urlString)!
                    }
                    
                    completionHandler(urls, nil)
                    
                } else {
                    
                    completionHandler(nil, nil)
                }
            }
        })
        
        task.resume()
        return task
    }
    
    //Download From Flick To Pin
    
    func taskForURLsWithPinAnnotation(_ pinAnnotation: PinAnnotation, completionHandler: @escaping (_ urls: [URL]?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let params = [
            "method" : SearchMethod.searchPhotos,
            "api_key" : APIConstants.apiKey,
            "extras" : APIConstants.urlExtra,
            "format" : APIConstants.jsonFormat,
            "nojsoncallback" : "1",
            "lat" : pinAnnotation.coordinate.latitude.description,
            "lon" : pinAnnotation.coordinate.longitude.description,
            "radius" : "5",
            "per_page" : SearchMethod.perPage.description
        ]
        
        return taskForURLsWithParameters(params, completionHandler: completionHandler)
    }
    
    //Download Image From Flickr
    
    func downloadImageURL(_ url: URL, toPath path: String, completionHandler: @escaping (_ success: Bool, _ error: NSError?)->Void) {
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.downloadTask(with: request, completionHandler: { url, response, error in
            if let error = error {
                completionHandler(false, error as NSError)
                
            } else {
                
                let data = try! Data(contentsOf: url!)
                try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
                completionHandler(true, nil)
            }
        })
        
        task.resume()
    }
    
    //Parameters
    
    func escapedParameters(_ dictionary: [String:String]) -> String {
        
        let queryItems = dictionary.map {
            URLQueryItem(name: $0, value: $1)
        }
        
        var comps = URLComponents()
        comps.queryItems = queryItems
        return comps.percentEncodedQuery ?? ""
    }
}

    //Constants For Flickr

struct APIConstants {
    
    static let apiKey = "2a2ad0534c538cea62c640e0d2520400"
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let urlExtra = "url_m"
    static let jsonFormat = "json"
}

    //Search

struct SearchMethod {
    
    static let searchPhotos = "flickr.photos.search"
    static let maxReturnedPhotos = 500
    static let perPage = 500
    
}

    //Array

extension Array {
    
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}
