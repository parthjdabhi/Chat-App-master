//
//  PDKeyboard.swift
//
//  Created by iParth on 12/13/16.
//  Copyright © 2016 iParth. All rights reserved.
//

import UIKit

// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol KeyboardDelegate: class {
    func keyWasTapped(data: String)
    func dismissKeyboard()
}

class PDKeyboard: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    
    let imagePadding:CGFloat = 8.0
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
        
        var collectionViewLayout = PDHorizontalFlowLayout()
        collectionViewLayout.itemSize = CGSizeMake(UIScreen.mainScreen().bounds.width/3, self.frame.height/2)
        //collectionViewLayout.nbColumns = 5;
        //collectionViewLayout.nbLines = 2;
        stickerCollectionView.collectionViewLayout = collectionViewLayout
        stickerCollectionView.pagingEnabled = true
        
        self.stickerCollectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier:"StickerCell")
        
//        var flowLayout = stickerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        flowLayout.estimatedItemSize = CGSizeMake(self.frame.width - 10, 10)
//        flowLayout.minimumLineSpacing = 2
//        flowLayout.minimumInteritemSpacing = 2
//        flowLayout.sectionInset = UIEdgeInsetsMake(2, 2, 0, 0)
        
        stickerCollectionView.dataSource=self
        stickerCollectionView.delegate=self
    }
    
    func initializeSubviews() {
        let xibFileName = "PDKeyboard" // xib extention not included
        let view = NSBundle.mainBundle().loadNibNamed(xibFileName, owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    // MARK:- Button actions from .xib file
    @IBAction func keyTapped(sender: UIButton) {
        self.delegate?.keyWasTapped(sender.titleLabel!.text!) // alternatively we can send a tag value
    }
    
    @IBAction func closeKeyTapped(sender: UIButton) {
        self.delegate?.dismissKeyboard()
    }
    
    // MARK:- UICollectionView 
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 51
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StickerCell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        
        var imageView:UIImageView = UIImageView()
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: cell.frame.width-imagePadding, height: cell.frame.height-imagePadding)
        imageView.image = UIImage(named: "popo_\(indexPath.row)")
        imageView.contentMode = .ScaleAspectFit
        
        cell.addSubview(imageView)
        //imageView.center = cell.center
        
        //cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.lightGrayColor() : UIColor.whiteColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.keyWasTapped("popo_\(indexPath.row)")
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: 90, height: 50) // The size of one cell
//    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.frame.width, 0)  // Header size
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let frame : CGRect = self.frame
        let margin: CGFloat  = 2
        return UIEdgeInsetsMake(0, margin, 0, margin) // margin between cells
    }
}