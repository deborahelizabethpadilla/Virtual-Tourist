//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation

extension FlickrNetwork {
    
    struct Constants {
        
        static let FlickrApiKey = "2a2ad0534c538cea62c640e0d2520400"
        static let FlickrBaseUrl = "https://api.flickr.com/services/rest/"
        static let BoundingBoxHeight = 0.1
        static let BoundingBoxWidth = 0.1
        static let Extras = "url_m"
        static let DataFormat = "json"
        static let SafeSearch = "1"
        static let NoJSONCallback = "1"
        static let MinimumLatitude = -90.0
        static let MaximumLatitude = 90.0
        static let MinimumLongitude = -180.0
        static let MaximumLongitude = 180.0
        static let LatitudeDelta = 0.01
        static let LongitudeDelta = 0.01
        static let PerPage = 30
        static let HttpSuccessRange = 200...299
    }
    
    struct Methods {
        
        static let FlickrSearchMethod = "flickr.photos.search"
    }
    
    struct JSONBodyKeys {
        
        static let Method = "method"
        static let ApiKey = "api_key";
        static let BoundingBox = "bbox"
        static let MinTakenDate = "min_taken_date"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
    }
    
    struct JSONResponseKeys {
        
        static let Page = "page"
        static let Pages = "pages"
        static let PerPage = "perpage"
        static let Total = "total"
        static let Id = "id"
        static let Secret = "secret"
        static let Server = "server"
        static let Title = "title"
        static let IsPublic = "ispublic"
        static let Farm = "farm"
    }
    
    struct NSUserDefaultKeys {
        
        static let StartMapPositionSaved = "start_map_position_saved"
        static let StartMapCenterLatitude = "start_map_center_lat"
        static let StartMapCenterLongitude = "start_map_center_lon"
        static let StartMapDeltaLatitude = "start_map_delta_lat"
        static let StartMapDeltaLongitude = "start_map_delta_lon"
    }
}
