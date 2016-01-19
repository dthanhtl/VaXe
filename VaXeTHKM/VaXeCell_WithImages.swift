//
//  VaXeCell_WithImages.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 1/10/16.
//  Copyright © 2016 vaxe. All rights reserved.
//

import UIKit
import Kingfisher


class VaXeCell_WithImages: UITableViewCell, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDistance: UILabel!

    @IBOutlet weak var lblPhone: UILabel!
    var listOfPhotos: [String] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewBG.layer.cornerRadius = 5
        self.viewBG.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewBG.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.viewBG.layer.shadowOpacity = 0.5
        self.viewBG.layer.shadowRadius = 2
        self.viewBG.clipsToBounds = false
        self.viewBG.layer.masksToBounds = false
        self.collectionView.reloadData()
        
    }
    func refresh(){
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listOfPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let name: String = self.listOfPhotos[indexPath.row]
        let photoName: String = "http://104.155.199.97/imgupload/uploadedimages/\(name)";
        print(photoName)
        cell.ivPhoto.kf_setImageWithURL(NSURL(string: photoName)!, placeholderImage: UIImage(named: "ic_photo_placeholder"))

        
        return cell
    }
//    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
//        
//        collectionView.delegate = dataSourceDelegate
//        collectionView.dataSource = dataSourceDelegate
//        collectionView.tag = row
//        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
//        collectionView.reloadData()
//    }
//    
//    var collectionViewOffset: CGFloat {
//        set {
//            collectionView.contentOffset.x = newValue
//        }
//        
//        get {
//            return collectionView.contentOffset.x
//        }
//    }
}


    



