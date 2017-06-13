//
//  APIConstants.swift
//  Lots of Images
//
//  Created by Vince Kearney on 10/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class APIConstants : NSObject
{
    static let baseURL = "https://api.flickr.com/services/rest/"

    struct Keys {
        static let method = "method"
        static let API_Key = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct Values {
        static let API_Key = "7dc182fa62d5ded06cb54094e8e88b99"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" // 1 means 'yes'
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryInfoMethod = "flickr.galleries.getInfo"
        static let ColourGalleryId = "72157679219461630"
        static let ChristmasMarketGalleryID = "72157673812981594"
    }
    
    struct Response {
        static let title = "title"
        static let imageURL = "url_m"
    }
    
    public static func getGalleryPhotosUrl(withId : String) -> URL {
        return APIConstants.getGallery(withMethod: APIConstants.Values.GalleryPhotosMethod, galleryId: withId)
    }
    
    public static func getGalleryInfoUrl(withId : String) -> URL {
        return APIConstants.getGallery(withMethod: APIConstants.Values.GalleryInfoMethod, galleryId: withId)
    }
    
    public static func getGallery(withMethod method : String, galleryId : String) -> URL
    {
        let methodParameters = [
            APIConstants.Keys.method : method,
            APIConstants.Keys.API_Key : APIConstants.Values.API_Key,
            APIConstants.Keys.GalleryID : galleryId,
            APIConstants.Keys.Extras : "url_m",
            APIConstants.Keys.Format : APIConstants.Values.ResponseFormat,
            APIConstants.Keys.NoJSONCallback : APIConstants.Values.DisableJSONCallback
        ]
        
        let urlString : String = APIConstants.baseURL + encoding(withParameters: methodParameters as [String : AnyObject])
        print("This is the urlString -> \(urlString)")
        return URL(string: urlString)!
    }
    
    private static func encoding(withParameters parameters: [String:AnyObject]) -> String
    {
        if parameters.isEmpty
        {
            return ""
        }
        else
        {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters
            {
                let stringValue = "\(value)"
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
