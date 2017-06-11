//
//  ViewController.swift
//  Lots of Images
//
//  Created by Vince Kearney on 08/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.getImagesForGallery(withId: APIConstants.Values.ColourGalleryId)
    }
    
    private func getImagesForGallery(withId : String)
    {
        let request : URLRequest = URLRequest(url: APIConstants.getGalleryPhotosUrl(withId: withId))
        
        /// Task
        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
        
            if error == nil
            {
                if let newData = data
                {
                    let parsed : [String : AnyObject]!
                    do {
                        parsed = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : AnyObject]
                    } catch {
                        print("Could not parse the data as JSON: \(newData)")
                        return
                    }
                    
                    print("Total images are -> \(((parsed["photos"] as? [String : AnyObject])?["total"])!)")
                    let photosDictionary = parsed["photos"] as? [String : AnyObject]
                    let photoArrays = photosDictionary?["photo"] as? Array<Dictionary<String, AnyObject>> // or [[String : AnyObject]]
                    
                    print(photoArrays?[0] ?? "Did not get the array of photos back")
                }
            }
        }
        
        task.resume()
        /// Task
    }
}

