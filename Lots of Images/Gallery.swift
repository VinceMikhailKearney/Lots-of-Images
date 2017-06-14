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
    public var name : String
    public var identifier : String
    public var totalImageCount : Int
    private var photoList : Array<Photo>
    
    override init()
    {
        self.name = ""
        self.identifier = ""
        self.totalImageCount = 0
        self.photoList = Array<Photo>()
    
        super.init()
    }
    
    convenience init(name : String, identifier : String) {
        self.init()
        self.name = name
        self.identifier = identifier
    }
    
    public func images() -> Array<Photo> {
        return self.photoList
    }
    
    public func photoCount() -> Int {
        return self.photoList.count
    }
    
    public func addPhoto(_ photo : Photo) {
        var filtered = Array<Photo>()
        filtered = self.photoList.filter { $0.imageIdentifier == photo.imageIdentifier }
        if filtered.count == 0 {
            self.photoList.append(photo)
        }
    }
}
