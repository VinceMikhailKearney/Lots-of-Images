//
//  APIService.swift
//  Lots of Images
//
//  Created by Vince Kearney on 11/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

extension Dictionary
{
    mutating func addEntriesFrom(_ other : Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public protocol APIServiceDelegate {
    func downloadedImages()
    func updateToastProgress(_ progress : Float, imageCount : Int)
    func downloadError(reason : String)
}

class APIService: NSObject
{
    // MARK: Properties
    private static var service : APIService?
    open var delegates : MulticastDelegate<APIServiceDelegate>?
    public static var totalImageCount : Int?
    
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
    
    private func gotAnError(reason : String) {
        print(reason)
        DispatchQueue.main.sync { self.delegates?.invokeDelegates { delegates in delegates.downloadError(reason: reason) } }
    }
    
    private func runDataTask(withUrl url : URL, completion: @escaping (_ result : Dictionary<String, AnyObject>?) -> Void)
    {
        let request : URLRequest = URLRequest(url: url)
        /// Task
        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            
            var failure = "Got an error in response"
            
            guard error == nil else { self.gotAnError(reason: failure); return }
            
            failure = "We received a status code other than 2xx!"
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.gotAnError(reason: failure)
                return
            }
            
            failure = "Did not get data"
            guard let newData = data else { self.gotAnError(reason: failure); return }
            
            let parsed : [String : AnyObject]!
            do {
                parsed = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : AnyObject]
            } catch {
                failure = "Could not parse the data as JSON: \(newData)"
                self.gotAnError(reason: failure)
                return
            }
            
            failure = "Flickr response is NOT ok"
            guard let status = parsed["stat"] as? String, status == "ok" else { self.gotAnError(reason: failure); return }
            
            completion(parsed)
        }
        
        task.resume()
        /// Task
    }
    
    public func getGalleryInfo(withId id : String)
    {
        self.runDataTask(withUrl: APIConstants.getGalleryInfoUrl(withId: id))
        { (result) in
            
            guard let gallery = result?["gallery"] as? [String : AnyObject], let galleryTitle = gallery["title"]?["_content"] as? String else {
                self.gotAnError(reason: "Did not get gallery title")
                return
            }
            
            Galleries.sharedInstance().addGallery(Gallery.init(name: galleryTitle, identifier: id))
            APIService.sharedInstance().getImagesForGallery(withId: id)
        }
    }
    
    public func getImagesForGallery(withId : String)
    {
        self.runDataTask(withUrl: APIConstants.getGalleryPhotosUrl(withId: withId))
        { (result) in
            
            // or [[String : AnyObject]]
            guard let photosDictionary = result?["photos"] as? [String : AnyObject], let photosArray = photosDictionary["photo"] as? Array<Dictionary<String, AnyObject>> else {
                self.gotAnError(reason: "Did not find the keys in the dictionary")
                return
            }
            
            guard let totalImageCount = photosDictionary["total"] as? Int else { self.gotAnError(reason: "Did not get a Total Count"); return }
            
            let gallery : Gallery = Galleries.sharedInstance().getGallery(withId: withId)!
            gallery.totalImageCount = totalImageCount
            APIService.totalImageCount = totalImageCount
            
            print("Total images for gallery (\(gallery.name)) are -> \(gallery.totalImageCount)")
            let percent = (1.00 / Float(gallery.totalImageCount))
            print("Each image is \(percent * 100)%")
            
            var totalPercent = percent
            for dictionary in photosArray
            {
                guard let imageUrlString = dictionary[APIConstants.Response.imageURL] as? String else { self.gotAnError(reason: "Could not find image url string"); return }
                guard let imageTitle = dictionary[APIConstants.Response.title] as? String else { self.gotAnError(reason: "Could not find image title"); return }
                guard let imageId = dictionary[APIConstants.Response.identifier] as? String else { self.gotAnError(reason: "Could not get image ID"); return}
                
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!)
                {
                    let newPhoto : Photo = Photo.init(withData: imageData, title: imageTitle, id: imageId)
                    gallery.addPhoto(newPhoto)
                    
                    DispatchQueue.main.sync { self.delegates?.invokeDelegates { delegates in delegates.updateToastProgress(Float(totalPercent), imageCount: Int(totalPercent/percent)) } }
                    totalPercent += percent
                    
                    if gallery.photoCount() == totalImageCount {
                        DispatchQueue.main.async { self.delegates?.invokeDelegates { delegates in delegates.downloadedImages() } }
                    }
                }
                else {
                    self.gotAnError(reason: "Seems that no image exists at this URL!")
                }
            }
        }
    }
}
