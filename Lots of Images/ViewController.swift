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
    private var progressHUD : MBProgressHUD?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APIService.sharedInstance().delegates?.addDelegate(self)
        self.imagePosition = 0
        self.imageView.contentMode = .scaleAspectFit
        self.previousImageButton.isHidden = true
        self.nextImageButton.isHidden = true
    }
    
    func updateImage(_ image : Photo) {
        self.imageView.image = UIImage(data: image.imageData!)
        self.imageTitle.text = image.imageTitle!
    }
    
    func displayToast() {
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD?.mode = .annularDeterminate
        progressHUD?.label.text = "Downloading images"
    }
    
    // MARK: APIService Delegate methods
    func downloadedImages()
    {
        print("Got a delegate callback from downloading an image")
        self.view.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self.view, animated: true)
        self.previousImageButton.isHidden = false
        self.nextImageButton.isHidden = false
        self.updateImage(Gallery.sharedInstance().images()[self.imagePosition!])
    }
    
    func updateToastProgress(_ progress: Float, imageCount : Int) {
        print("Should be updating the progress of the HUD. This is the progress -> \(progress)")
        progressHUD?.progress = progress
        progressHUD?.detailsLabel.text = "\(imageCount)/\(APIService.totalImages ?? 0)"
    }
    
    // MARK: Actions
    @IBAction func downloadImage(_ sender : UIButton)
    {
        print("Pressed download image button")
        self.displayToast()
        Gallery.sharedInstance().clear() // First clear the gallery that we have before we refill it
        APIService.sharedInstance().getImagesForGallery(withId: APIConstants.Values.ChristmasMarketGalleryID)
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

