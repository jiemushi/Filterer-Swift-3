//
//  ImageFeedTableViewController.swift
//  PhotoFeed
//
//  Created by Mike Spears on 2016-01-08.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit
import CoreData

class ImageFeedTableViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var feed: Feed? {
        didSet {
            self.collectionView!.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        img = UIImage()
        super.init(coder: aDecoder)!
    }

    var img: UIImage?
    var urlSession: URLSession!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.urlSession.invalidateAndCancel()
        self.urlSession = nil
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feed?.items.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageFeedItemTableViewCell", for: indexPath) as! ImageFeedItemTableViewCell
        
        let item = self.feed!.items[indexPath.row]
        //cell.itemTitle.text = item.title
        
        let request = URLRequest(url: item.imageURL as URL)
        
        cell.dataTask = self.urlSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            OperationQueue.main.addOperation({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    cell.itemImageView.image = image
                }
            })
        }) 
        
        cell.dataTask?.resume()
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageFeedItemTableViewCell {
            cell.dataTask?.cancel()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*let cell = tableView.dequeueReusableCellWithIdentifier("ImageFeedItemTableViewCell", forIndexPath: indexPath) as! ImageFeedItemTableViewCell
        
        let item = self.feed!.items[indexPath.row]
        
        let request = NSURLRequest(URL: item.imageURL)
        
        cell.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                //if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    self.img = image!
                //}
            })
        }
        cell.dataTask?.resume()*/
        
        //self.img = cell.itemImageView.image
        
        self.performSegue(withIdentifier: "showMain", sender: self)
        
        /*
        let alertController = UIAlertController(title: "Add Tag", message: "Type your tag", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            if let tagTitle = alertController.textFields![0].text {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.dataController.tagFeedItem(tagTitle, feedItem: item)
            }
            
        }
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler(nil)
        self.presentViewController(alertController, animated: true, completion: nil)
         */
        
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMain" {
            let destination = segue.destinationViewController as! ViewController
            
            destination.imageView.image = self.img
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMain" {
            let destination = segue.destination as! ViewController
            //let path = self.collectionView?.indexPathsForSelectedItems() as! NSIndexPath
            var cell: ImageFeedItemTableViewCell?

            if let indexPath = getIndexPathForSelectedCell() {
                cell = self.collectionView?.cellForItem(at: indexPath) as? ImageFeedItemTableViewCell
            }
            
            destination.image = cell!.itemImageView.image
        }
    }
    
    func getIndexPathForSelectedCell() -> IndexPath? {
        var indexPath:IndexPath?
        
        if collectionView!.indexPathsForSelectedItems!.count > 0 {
            indexPath = collectionView!.indexPathsForSelectedItems![0]
        }
        return indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // http://stackoverflow.com/questions/28872001/uicollectionview-cell-spacing-based-on-device-sceen-size
        
        let length = (UIScreen.main.bounds.width-10)/2 //min 10
        return CGSize(width: length,height: length);
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTags" {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.dataController.managedObjectContext
            
            let tagsVC = segue.destinationViewController as! TagsTableViewController
            
            let request = NSFetchRequest(entityName: "Tag")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            tagsVC.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        }
    }
     */
}
