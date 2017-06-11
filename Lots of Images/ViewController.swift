//
//  ViewController.swift
//  Lots of Images
//
//  Created by Vince Kearney on 08/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class ViewController: UIViewController, APIServiceDelegate
{
    // MARK: Properties
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var imageTitle : UILabel!
    @IBOutlet weak var downloadImageButton : UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APIService.sharedInstance().delegates?.addDelegate(self)
        
        self.imageView.contentMode = .scaleAspectFit
    }
    
    // MARK: APIService Delegate methods
    func downloaded(image: Data, title: String)
    {
        print("Got a delegate callback from downloading an image")
        self.imageView.image = UIImage(data: image)
        self.imageTitle.text = title
    }
    
    @IBAction func downloadImage(_ sender : UIButton) {
        print("Pressed download image button")
        APIService.sharedInstance().getImagesForGallery(withId: APIConstants.Values.ColourGalleryId)
    }
}

