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
    @IBOutlet weak var nextImageButton : UIButton!
    @IBOutlet weak var previousImageButton : UIButton!
    private var imagePosition : Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APIService.sharedInstance().delegates?.addDelegate(self)
        self.imagePosition = 0
        self.imageView.contentMode = .scaleAspectFit
        self.previousImageButton.isHidden = true
        self.nextImageButton.isHidden = true
    }
    
    // MARK: APIService Delegate methods
    func downloadedImages()
    {
        print("Got a delegate callback from downloading an image")
        self.view.isUserInteractionEnabled = true
        self.previousImageButton.isHidden = false
        self.nextImageButton.isHidden = false
        let firstPhoto = Gallery.sharedInstance().images()[self.imagePosition!]
        self.updateImage(firstPhoto)
    }
    
    func updateImage(_ image : Photo) {
        self.imageView.image = UIImage(data: image.imageData!)
        self.imageTitle.text = image.imageTitle!
    }
    
    @IBAction func downloadImage(_ sender : UIButton) {
        print("Pressed download image button")
        APIService.sharedInstance().getImagesForGallery(withId: APIConstants.Values.ColourGalleryId)
        self.view.isUserInteractionEnabled = false
    }
    
    @IBAction func nextImageFromGallery(_ sender : UIButton) {
        self.imagePosition? += 1
        if self.imagePosition == Gallery.sharedInstance().images().count { self.imagePosition = 0 }
        updateImage(Gallery.sharedInstance().images()[self.imagePosition!])
    }
    
    @IBAction func previousImageFromGallery(_ sender : UIButton) {
        self.imagePosition? -= 1
        if self.imagePosition == -1 { self.imagePosition = Gallery.sharedInstance().images().count - 1 }
        updateImage(Gallery.sharedInstance().images()[self.imagePosition!])
    }
}

