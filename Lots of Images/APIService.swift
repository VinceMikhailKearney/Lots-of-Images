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
    func updateToastProgress(_ progress : Float, imageCount : Int)
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
    
    public func getGalleryInfo(withId id : String)
    {
        let request : URLRequest = URLRequest(url: APIConstants.getGalleryInfoUrl(withId: id))
        
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
            
            guard let gallery = parsed["gallery"] as? [String : AnyObject], let galleryTitle = gallery["title"]?["_content"] as? String else {
                print("Did not get gallery title")
                return
            }
            
            Galleries.sharedInstance().addGallery(Gallery.init(name: galleryTitle, identifier: id))
            APIService.sharedInstance().getImagesForGallery(withId: id)
        }
        
        task.resume()
        /// Task
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
            
            guard let totalImageCount = photosDictionary["total"] as? Int else { print("Did not get a Total Count"); return }
            
            let gallery : Gallery = Galleries.sharedInstance().getGallery(withId: withId)!
            gallery.totalImageCount = totalImageCount
            APIService.totalImageCount = totalImageCount
            
            print("Total images for gallery (\(gallery.name)) are -> \(gallery.totalImageCount)")
            let percent = (1.00 / Float(gallery.totalImageCount))
            print("Each image is \(percent * 100)%")
            
            var totalPercent = percent
            for dictionary in photosArray
            {
                guard let imageUrlString = dictionary[APIConstants.Response.imageURL] as? String else { print("Could not find image url string"); return }
                
                guard let imageTitle = dictionary[APIConstants.Response.title] as? String else { print("Could not find image title"); return }
                
                print("Have both the URL and title")
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!)
                {
                    let newPhoto : Photo = Photo.init(withData: imageData, title: imageTitle)
                    gallery.addPhoto(newPhoto)
                    
                    DispatchQueue.main.sync { self.delegates?.invokeDelegates { delegates in delegates.updateToastProgress(Float(totalPercent), imageCount: Int(totalPercent/percent)) } }
                    totalPercent += percent
                    
                    if gallery.photoCount() == (photosDictionary["total"] as? Int) {
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
