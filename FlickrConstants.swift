//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Deborah on 2/13/17.
//  Copyright © 2017 Deborah. All rights reserved.
//

import Foundation

class FlickrClient {
    
    func searchByLatLon(lat latitude: Double, lon longitude: Double) {
        
        if isValueInRange(latitude, forRange: Constants.Flickr.SearchLatRange) && isValueInRange(longitude, forRange: Constants.Flickr.SearchLonRange) {
            let methodParameters = [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(lat: latitude, lon: longitude),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ]
            searchForImages(methodParameters as [String:AnyObject])
        }
        else {
            // TODO: Manage error.
            // photoTitleLabel.text = "Lat should be [-90, 90].\nLon should be [-180, 180]."
        }
}
