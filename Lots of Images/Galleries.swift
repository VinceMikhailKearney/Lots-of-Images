//
//  Galleries.swift
//  Lots of Images
//
//  Created by Vince Kearney on 13/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class Galleries: NSObject
{
    // MARK: Properties
    public var list : Array<Gallery>
    private static var galleries : Galleries?
    
    public static func sharedInstance() -> Galleries
    {
        if self.galleries == nil {
            self.galleries = Galleries()
        }
        return self.galleries!
    }
    
    override init() {
        list = Array<Gallery>()
        super.init()
    }
    
    public func addGallery(_ gallery : Gallery) {
        guard checkIfGalleryExists(gallery.identifier) == false else { return }
        self.list.append(gallery)
    }
    
    public func getGallery(withId id : String) -> Gallery?
    {
        var filtered = Array<Gallery>()
        filtered = self.list.filter { $0.identifier == id }
        if filtered.count == 1 {
            return filtered.first!
        }
        
        return nil
    }
    
    public func checkIfGalleryExists(_ galleryId : String) -> Bool {
        return self.list.contains { $0.identifier == galleryId }
    }
}
