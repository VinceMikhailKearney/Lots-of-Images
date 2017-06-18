//
//  TableViewController.swift
//  Lots of Images
//
//  Created by Vince Kearney on 13/06/2017.
//  Copyright © 2017 vince. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, APIServiceDelegate
{
    // MARK: Properties
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var downloadImageButton : UIButton!
    public var galleries : Array<Gallery>?
    private var progressHUD : MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.downloadImageButton.layer.cornerRadius = 5
        APIService.sharedInstance().delegates?.addDelegate(self)
        self.galleries = Galleries.sharedInstance().list
    }
    
    func displayToast() {
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD?.mode = .annularDeterminate
        progressHUD?.label.text = "Downloading images"
    }
    
    func showToast(withText text : String)
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.label.numberOfLines = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: APIServiceDelegate
    func downloadedImages()
    {
        print("Got a delegate callback from downloading an image")
        self.view.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self.view, animated: true)
        self.galleries = Galleries.sharedInstance().list
        self.tableView.reloadData()
        self.textField.text = "" // reset text only if images are downloaded
    }
    
    func updateToastProgress(_ progress: Float, imageCount : Int) {
        print("Should be updating the progress of the HUD. This is the progress -> \(progress)")
        progressHUD?.progress = progress
        progressHUD?.detailsLabel.text = "\(imageCount)/\(APIService.totalImageCount ?? 0)"
    }
    
    func downloadError(reason: String) {
        self.view.isUserInteractionEnabled = true
        MBProgressHUD.hide(for: self.view, animated: true)
        self.showToast(withText: reason)
    }
    
    // MARK: Actions
    @IBAction func downloadGallery(_ sender : UIButton)
    {
        print("Pressed download image button")
        guard (self.textField.text?.characters.count)! > 0 else { self.showToast(withText: "No ID Entered"); return }
        guard Galleries.sharedInstance().checkIfGalleryExists(self.textField.text!) == false else { self.showToast(withText: "Gallery ID already download"); return }
        
        self.view.isUserInteractionEnabled = false
        self.textField.resignFirstResponder()
        self.displayToast()
        APIService.sharedInstance().getGalleryInfo(withId: self.textField.text!)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationView = segue.destination as? ViewController
        destinationView?.gallery = sender as? Gallery
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryCell", for: indexPath)
        cell.textLabel!.text = self.galleries?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showGallery", sender: self.galleries?[indexPath.row])
    }
}
