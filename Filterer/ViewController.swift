import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    var image = UIImage(named: "port")
    var currentImage: UIImage?
    var currentImageTop: Int?
    var currentImageBottom: Int?
    var currentImageLead: Int?
    var currentImageTrail: Int?
    var currentImageX: CGFloat?
    var currentImageY: CGFloat?
    var currentImageWidth: CGFloat?
    var currentImageHeight: CGFloat?
    
    var RGBA: RGBAImage?
    var tempRGBA: RGBAImage?

    var sepiaImage: UIImage?
    var monochromeImage: UIImage?
    var brightenImage: UIImage?
    var intensifyImage: UIImage?
    var softenImage:UIImage?
    var negativeImage: UIImage?
    
    var sepiaImageCheck: Bool?
    var monochromeImageCheck: Bool?
    var brightenImageCheck: Bool?
    var intensifyImageCheck: Bool?
    var negativeImageCheck: Bool?
    var softenImageCheck: Bool?
    
    var sepiaCheck: Bool?
    var monochromeCheck: Bool?
    var brightenCheck: Bool?
    var softenCheck: Bool?
    var intensifyCheck: Bool?
    var negativeCheck: Bool?

    var adjVal: Int?
    var sliderCheck: Bool?
    
    @IBOutlet weak var originalLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var sepiaButton: UIButton!
    @IBOutlet weak var monochromeButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var intensifyButton: UIButton!
    @IBOutlet weak var softenButton: UIButton!
    @IBOutlet weak var brightenButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var imageViewCompareButton: UIButton!
    @IBOutlet var sliderMenu: UIView!
    @IBOutlet weak var adjustSlider: UISlider!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let RGBA1 = resizeImage(image!, newWidth: 300)
        RGBA = RGBAImage(image: RGBA1)
        
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        sliderMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = resizeImage(image!, newWidth: 300)
        
        sepiaCheck = false
        monochromeCheck = false
        brightenCheck = false
        intensifyCheck = false
        softenCheck = false
        negativeCheck = false
    
        sliderCheck = false
        
        imageViewCompareButton.isEnabled = false
        originalLabel.alpha = 0
        compareButton.isEnabled = false
        
        updateMinZoomScaleForSize(scrollView.bounds.size)
        
        //sepiaButton.setBackgroundImage(image, forState: .Normal)
        //sepiaButton.setTitle("", forState: .Normal)
        //sepiaButton.setTitle("Original", forState: .Selected)
        
        /*compareButton.addTarget(self, action: #selector(ViewController.onCompareRelease(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        compareButton.addTarget(self, action: #selector(ViewController.onCompare(_:)), forControlEvents: UIControlEvents.TouchDown)
        */
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @IBAction func onToggleCompare(_ sender: AnyObject) {
        if (compareButton.isSelected == false) {
            imageViewCompareButton.isEnabled = false
            compareButton.isSelected = true
            onCompare(sender)
        } else {
            imageViewCompareButton.isEnabled = true
            compareButton.isSelected = false
            onCompareRelease(sender)
        }
    }
    
    @IBAction func onCompare(_ sender: AnyObject) {
        currentImage = imageView.image
        
        UIView.animate(withDuration: 0.4, animations: {
            self.imageView.image = self.RGBA?.toUIImage()
            self.originalLabel.alpha = 1
        }) 
    }

    @IBAction func onCompareRelease(_ sender: AnyObject) {
        /*if sepiaCheck == true {
            imageView.image = sepiaImage
        } else if monochromeCheck == true {
            imageView.image = monochromeImage
        } else if brightenCheck == true {
            imageView.image = brightenImage
        } else if intensifyCheck == true {
            imageView.image = intensifyImage
        } else if negativeCheck == true {
            imageView.image = negativeImage
        }*/
        
        UIView.animate(withDuration: 0.4, animations: {
            self.imageView.image = self.currentImage
            self.originalLabel.alpha = 0
        }) 
    }
    
    @IBAction func onSepia(_ sender: AnyObject) {
        showSlider()
        
        if sepiaCheck == false {
            tempRGBA = RGBA
            tempRGBA?.sepiafy(1)
            sepiaImage = tempRGBA!.toUIImage()
            sepiaCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        sepiaButton.isEnabled = false
        softenButton.isEnabled = true
        monochromeButton.isEnabled = true
        negativeButton.isEnabled = true
        brightenButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
        sepiaButton.selected = true
        monochromeButton.selected = false
        negativeButton.selected = false
        intensifyButton.selected = false
        brightenButton.selected = false
        */
        imageView.image = sepiaImage
        
        /*if sepiaButton.selected {
            imageView.image = image
            sepiaButton.selected = false
        } else {
            imageView.image = filteredImage
            sepiaButton.selected = true
        }*/
    }

    @IBAction func onMonochrome(_ sender: AnyObject) {
        showSlider()
        
        if monochromeCheck == false {
            tempRGBA = RGBA
            tempRGBA?.monochromify(1)
            monochromeImage = tempRGBA!.toUIImage()
            monochromeCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        monochromeButton.isEnabled = false
        softenButton.isEnabled = true
        sepiaButton.isEnabled = true
        negativeButton.isEnabled = true
        brightenButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
        monochromeButton.selected = true
        sepiaButton.selected = false
        negativeButton.selected = false
        intensifyButton.selected = false
        brightenButton.selected = false
        */
        imageView.image = monochromeImage
    }
    
    @IBAction func onNegative(_ sender: AnyObject) {
        showSlider()
        
        if negativeCheck == false {
            tempRGBA = RGBA
            tempRGBA?.negativify(1)
            negativeImage = tempRGBA!.toUIImage()
            negativeCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        negativeButton.isEnabled = false
        softenButton.isEnabled = true
        sepiaButton.isEnabled = true
        monochromeButton.isEnabled = true
        brightenButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
        negativeButton.selected = true
        sepiaButton.selected = false
        monochromeButton.selected = false
        intensifyButton.selected = false
        brightenButton.selected = false
        */
        imageView.image = negativeImage
    }
    
    @IBAction func onBrighten(_ sender: AnyObject) {
        showSlider()
        
        if brightenCheck == false {
            tempRGBA = RGBA
            tempRGBA?.brightenify(5)
            brightenImage = tempRGBA!.toUIImage()
            brightenCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        brightenButton.isEnabled = false
        softenButton.isEnabled = true
        sepiaButton.isEnabled = true
        monochromeButton.isEnabled = true
        negativeButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
        brightenButton.selected = true
        sepiaButton.selected = false
        monochromeButton.selected = false
        intensifyButton.selected = false
        negativeButton.selected = false
        */
        imageView.image = brightenImage
    }
    
    @IBAction func onIntensify(_ sender: AnyObject) {
        if intensifyCheck == false {
            tempRGBA = RGBA
            tempRGBA?.intensify(RGBAImage.ColorChannel.RGB, manipulateValue: 5)
            intensifyImage = tempRGBA!.toUIImage()
            intensifyCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        intensifyButton.isEnabled = false
        softenButton.isEnabled = true
        sepiaButton.isEnabled = true
        monochromeButton.isEnabled = true
        negativeButton.isEnabled = true
        brightenButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
        intensifyButton.selected = true
        sepiaButton.selected = false
        monochromeButton.selected = false
        negativeButton.selected = false
        brightenButton.selected = false
        */
        imageView.image = intensifyImage
    }
    
    @IBAction func onSoften(_ sender: AnyObject) {
        showSlider()
        
        if softenCheck == false {
            tempRGBA = RGBA
            tempRGBA?.softenify(5)
            softenImage = tempRGBA!.toUIImage()
            softenCheck = true
        }
        
        compareButton.isEnabled = true
        imageViewCompareButton.isEnabled = true
        softenButton.isEnabled = false
        sepiaButton.isEnabled = true
        monochromeButton.isEnabled = true
        negativeButton.isEnabled = true
        brightenButton.isEnabled = true
        
        compareButton.isSelected = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        
        /*
         intensifyButton.selected = true
         sepiaButton.selected = false
         monochromeButton.selected = false
         negativeButton.selected = false
         brightenButton.selected = false
         */
        imageView.image = softenImage
    }
    
    // MARK: Share
    @IBAction func onShare(_ sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Flickr", style: .default, handler: { action in
            //self.performSegueWithIdentifier("showFlickrImages", sender: self)
            self.performSegue(withIdentifier: "showFlickrImages", sender: self)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showSlider() {
        sliderCheck = true
        
        view.addSubview(sliderMenu)
        
        let bottomConstraint = sliderMenu.bottomAnchor.constraint(equalTo: secondaryMenu.topAnchor)
        let leftConstraint = sliderMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = sliderMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = sliderMenu.heightAnchor.constraint(equalToConstant: 44)
    
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        adjustSlider.value = 6
        
        self.sliderMenu.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.sliderMenu.alpha = 1.0
        }) 
        
        view.layoutIfNeeded()
    }
    
    func hideSlider() {
        UIView.animate(withDuration: 0.5, animations: {
            self.sliderMenu.alpha = 0
        }, completion: { completed in
            if completed == true {
                self.sliderMenu.removeFromSuperview()
            }
        }) 
    }
    
    @IBAction func onSlide(_ sender: UISlider) {
        var intensifyVal: Double
        tempRGBA = RGBA
        UIView.animate(withDuration: 0.4, animations: {
            self.originalLabel.alpha = 0
        }) 
        compareButton.isSelected = false
        if softenButton.isEnabled == false {
            tempRGBA?.softenify(Int(sender.value))
            softenImage = tempRGBA?.toUIImage()
            imageView.image = softenImage
            softenCheck = false
        } else if sepiaButton.isEnabled == false {
            intensifyVal = Double(sender.value / 10 + 0.4)
            tempRGBA?.sepiafy(intensifyVal)
            sepiaImage = tempRGBA?.toUIImage()
            imageView.image = sepiaImage
            sepiaCheck = false
        } else if monochromeButton.isEnabled == false {
            intensifyVal = Double(sender.value / 10 + 0.4)
            tempRGBA?.monochromify(intensifyVal)
            monochromeImage = tempRGBA?.toUIImage()
            imageView.image = monochromeImage
            monochromeCheck = false
        } else if negativeButton.isEnabled == false {
            intensifyVal = Double(sender.value / 10 + 0.4)
            tempRGBA?.negativify(intensifyVal)
            negativeImage = tempRGBA?.toUIImage()
            imageView.image = negativeImage
            negativeCheck = false
        } else if brightenButton.isEnabled == false {
            tempRGBA?.brightenify(Int(sender.value))
            brightenImage = tempRGBA?.toUIImage()
            imageView.image = brightenImage
            brightenCheck = false
        }
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = resizeImage(image, newWidth: 300)
            self.image = resizeImage(image, newWidth: 300)
            
            let RGBA1 = resizeImage(self.image!, newWidth: 300)
            RGBA = RGBAImage(image: RGBA1)
            
            sepiaCheck = false
            monochromeCheck = false
            brightenCheck = false
            intensifyCheck = false
            negativeCheck = false
            softenCheck = false
            
            sepiaButton.isEnabled = true
            monochromeButton.isEnabled = true
            negativeButton.isEnabled = true
            brightenButton.isEnabled = true
            softenButton.isEnabled = true
            
            filterButton.isSelected = false
            sliderCheck = false
            compareButton.isEnabled = false
            imageViewCompareButton.isEnabled = false
            hideSlider()
            hideSecondaryMenu()
            
            /*
            sepiaButton.selected = false
            monochromeButton.selected = false
            negativeButton.selected = false
            brightenButton.selected = false
            intensifyButton.selected = false
            */
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(_ sender: UIButton) {
        if (sender.isSelected) {
            hideSlider()
            if (sliderCheck == true) {
                adjVal = Int(adjustSlider.value)
            }
            hideSecondaryMenu()
            sender.isSelected = false
        } else {
            showSecondaryMenu()
            if (sliderCheck == true) {
                showSlider()
                adjustSlider.value = Float(adjVal!)
            }
            sender.isSelected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 80)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        let img = resizeImage(image!, newWidth: 100)
        var img1 = RGBAImage(image: img)
        var img2 = RGBAImage(image: img)
        var img3 = RGBAImage(image: img)
        var img4 = RGBAImage(image: img)
        var img5 = RGBAImage(image: img)
        img1?.sepiafy(1)
        img2?.monochromify(1)
        img3?.negativify(5)
        img4?.brightenify(5)
        img5?.softenify(5)
        
        sepiaButton.setBackgroundImage(img1?.toUIImage(), for: UIControlState())
        monochromeButton.setBackgroundImage(img2?.toUIImage(), for: UIControlState())
        negativeButton.setBackgroundImage(img3?.toUIImage(), for: UIControlState())
        brightenButton.setBackgroundImage(img4?.toUIImage(), for: UIControlState())
        softenButton.setBackgroundImage(img5?.toUIImage(), for: UIControlState())
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 1.0
        }) 
    }

    func hideSecondaryMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 0
            }, completion: { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }) 
    }
    
    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(scrollView.bounds.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTags" {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.dataController.managedObjectContext
            
            //let tagsVC = segue.destinationViewController as! TagsTableViewController
            
            let imgController = UIApplication.sharedApplication().delegate as! ImageFeedTableViewController
            let feedItem = [FeedItem]()
            
            
            
            let request = NSFetchRequest(entityName: "Tag")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            tagsVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFlickrImages" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destination = destinationNavigationController.topViewController as! ImageFeedTableViewController
            
            //let destination = segue.destinationViewController as! ImageFeedTableViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let urlString = UserDefaults.standard.string(forKey: "PhotoFeedURLString")
            
            guard let foundURLString = urlString else {
                return
            }
            
            if let url = URL(string: foundURLString) {
                appDelegate.loadOrUpdateFeed(url, completion: { (feed) -> Void in
                    destination.feed = feed
                })
            }
        }
    }
}
