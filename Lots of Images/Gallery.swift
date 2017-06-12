//
//  Gallery.swift
//  Lots of Images
//
//  Created by Vince Kearney on 12/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class Gallery: NSObject
{
    // MARK: Properties
    private var name : String
    private var photoList : Array<Photo>
    private static var gallery : Gallery?
    
    public static func sharedInstance() -> Gallery {
        if self.gallery == nil {
            self.gallery = Gallery()
        }
        
        return self.gallery!
    }
    
    override init()
    {
        self.name = ""
        self.photoList = Array<Photo>()
    
        super.init()
    }
    
    public func images() -> Array<Photo> {
        return self.photoList
    }
    
    public func galleryPhotoCount() -> Int {
        return self.photoList.count
    }
    
    public func addPhoto(_ photo : Photo) {
        // Need to check if Gallery already contains photo with title or ID? (Func programming playground)
        self.photoList.append(photo)
    }
}
