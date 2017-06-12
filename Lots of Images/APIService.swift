//
//  APIService.swift
//  Lots of Images
//
//  Created by Vince Kearney on 11/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

public protocol APIServiceDelegate {
    func downloadedImages()
}

class APIService: NSObject
{
    // MARK: Properties
    private static var service : APIService?
    open var delegates : MulticastDelegate<APIServiceDelegate>?
    
    open static func sharedInstance() -> APIService
    {
        if self.service == nil {
            self.service = APIService()
        }
        
        return self.service!
    }
    
    override init() {
        print("Init APIService")
        super.init()
        delegates = MulticastDelegate()
    }
    
    public func getImagesForGallery(withId : String)
    {
        let request : URLRequest = URLRequest(url: APIConstants.getGalleryPhotosUrl(withId: withId))
        
        /// Task
        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            
            guard error == nil else { print("Got an error"); return }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("We received a status code other than 2xx!")
                return
            }
            
            guard let newData = data else { print("Did not get data"); return }
            
            let parsed : [String : AnyObject]!
            do {
                parsed = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : AnyObject]
            } catch {
                print("Could not parse the data as JSON: \(newData)")
                return
            }
            
            guard let status = parsed["stat"] as? String, status == "ok" else { print("Flickr response is NOT ok"); return }
            
            // or [[String : AnyObject]]
            guard let photosDictionary = parsed["photos"] as? [String : AnyObject], let photosArray = photosDictionary["photo"] as? Array<Dictionary<String, AnyObject>> else {
                print("Did not find the keys in the dictionary")
                return
            }
            
            print("Total images are -> \(photosDictionary["total"] ?? "Did not find key 'total'" as AnyObject)")
            
//            let randomIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//            let chosenPhoto = photosArray[randomIndex]
            
            for dictionary in photosArray
            {
                guard let imageUrlString = dictionary[APIConstants.Response.imageURL] as? String else { print("Could not find image url string"); return }
                
                guard let imageTitle = dictionary[APIConstants.Response.title] as? String else { print("Could not find image title"); return }
                
                print("Have both the URL and title")
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!)
                {
                    let newPhoto : Photo = Photo.init(withData: imageData, title: imageTitle)
                    Gallery.sharedInstance().addPhoto(newPhoto)
                    if Gallery.sharedInstance().galleryPhotoCount() == 16 {
                        DispatchQueue.main.async { self.delegates?.invokeDelegates { delegates in delegates.downloadedImages() } }
                    }
                }
                else {
                    print("Seems that no image exists at this URL!")
                }
            }
        }
        
        task.resume()
        /// Task
    }
}
