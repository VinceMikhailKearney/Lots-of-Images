//
//  Photo.swift
//  Lots of Images
//
//  Created by Vince Kearney on 12/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class Photo: NSObject
{
    // MARK: Properties
    public var imageData : Data?
    public var imageTitle : String?
    public var imageIdentifier : String?
    
    override init() {
        super.init()
    }
    
    convenience init(withData : Data, title : String, id : String) {
        self.init()
        
        self.imageData = withData
        self.imageTitle = title
        self.imageIdentifier = id
    }
}
