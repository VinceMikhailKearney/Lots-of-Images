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
    // MARK: Properties
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var nextImageButton : UIButton!
    @IBOutlet weak var previousImageButton : UIButton!
    private var imagePosition : Int?
    public var gallery : Gallery?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.imagePosition = 0
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(imageDetails)))
        self.updateView(withPhoto: (gallery?.images()[self.imagePosition!])!)
    }
    
    func updateView(withPhoto photo : Photo) {
        self.imageView.image = UIImage(data: photo.imageData!)
    }
    
    // MARK: Actions
    
    @IBAction func nextImageFromGallery(_ sender : UIButton) {
        self.imagePosition? += 1
        if self.imagePosition == gallery?.images().count { self.imagePosition = 0 }
        self.updateView(withPhoto: (gallery?.images()[self.imagePosition!])!)
    }
    
    @IBAction func previousImageFromGallery(_ sender : UIButton) {
        self.imagePosition? -= 1
        if self.imagePosition == -1 { self.imagePosition = (gallery?.images().count)! - 1 }
        self.updateView(withPhoto: (gallery?.images()[self.imagePosition!])!)
    }
    
    func imageDetails() {
        UIAlertView.init(title: "Image Details",
                        message: "Gallery Title: \(self.gallery?.name ?? "No gallery title")\n\nImage Name: \(self.gallery?.images()[self.imagePosition!].imageTitle ?? "No image title")",
                        delegate: nil,
                cancelButtonTitle: "Ok").show()
    }
}

